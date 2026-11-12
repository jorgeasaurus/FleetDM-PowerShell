BeforeAll {
    function New-ConnectHttpErrorRecord {
        param(
            [Parameter(Mandatory)]
            $StatusCode,

            [string]$Message
        )

        if (-not $Message) {
            $Message = [string]$StatusCode
        }

        $exception = [System.Net.WebException]::new($Message)
        $response = [PSCustomObject]@{
            StatusCode = $StatusCode
        }
        Add-Member -InputObject $exception -MemberType NoteProperty -Name 'Response' -Value $response -Force

        return [System.Management.Automation.ErrorRecord]::new(
            $exception,
            'WebCmdletWebResponseException',
            [System.Management.Automation.ErrorCategory]::InvalidOperation,
            $null
        )
    }

    # Import test helper
    . (Join-Path $PSScriptRoot 'TestHelper.ps1')
    
    # Import the module using the helper
    Import-TestModule
    
    # Mock variables
    $script:TestBaseUri = "https://test.fleetdm.example.com"
    $script:TestToken = "test-api-token-12345"
    $script:TestUser = @{
        user = @{
            name = "Test User"
            email = "test@example.com"
            global_role = "admin"
            id = 1
        }
        token = $script:TestToken
    }
    
    # Mock web requests - handle all parameters that Connect-FleetDM passes
    Mock Invoke-RestMethod {
        param($Uri, $Method, $Body, $Headers, $ContentType, $WebSession, $ErrorAction)
        
        Write-Host "Mock Invoke-RestMethod called with URI: $Uri" -ForegroundColor Cyan
        
        if ($Uri -like "*/api/v1/fleet/login") {
            return $script:TestUser
        }
        elseif ($Uri -like "*/api/v1/fleet/me") {
            return @{
                user = $script:TestUser.user
            }
        }
        else {
            Write-Warning "Unexpected URI in Invoke-RestMethod: $Uri"
            return @{ version = "4.0.0" }
        }
    } -ModuleName FleetDM-PowerShell
    
    Mock Invoke-WebRequest {
        param($Uri, $Method, $Headers, $WebSession, $ErrorAction)
        
        Write-Host "Mock Invoke-WebRequest called with URI: $Uri" -ForegroundColor Cyan
        
        if ($Uri -like "*/api/v1/fleet/version*") {
            $response = [PSCustomObject]@{
                Content = '{"version": "4.0.0"}'
                Headers = @{ 'Content-Type' = 'application/json' }
                StatusCode = 200
                StatusDescription = "OK"
            }
            return $response
        }
        else {
            Write-Warning "Unexpected URI in Invoke-WebRequest: $Uri"
            $response = [PSCustomObject]@{
                Content = '{"version": "4.0.0"}'
                Headers = @{ 'Content-Type' = 'application/json' }
                StatusCode = 200
                StatusDescription = "OK"
            }
            return $response
        }
    } -ModuleName FleetDM-PowerShell
    
}

Describe "Connect-FleetDM" -Tags @('Unit', 'Authentication') {
    BeforeEach {
        # Clear any existing connection in module scope
        InModuleScope FleetDM-PowerShell {
            $script:FleetDMConnection = $null
            $script:FleetDMWebSession = $null
        }
    }
    
    Context "Token Authentication" {
        It "Should connect with valid API token" {
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            $result = Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token
            
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.TypeNames | Should -Contain 'FleetDM.Connection'
            $result.BaseUri | Should -Be $script:TestBaseUri
            $result.Version | Should -Be "4.0.0"
            $result.User | Should -Be "test@example.com"
            $result.GlobalRole | Should -Be "admin"
            
            # Verify connection was stored in module scope
            InModuleScope FleetDM-PowerShell {
                param($expectedBaseUri, $expectedToken)
                $script:FleetDMConnection | Should -Not -BeNullOrEmpty
                $script:FleetDMConnection.BaseUri | Should -Be $expectedBaseUri
                $script:FleetDMConnection.Headers['Authorization'] | Should -Be "Bearer $expectedToken"
            } -ArgumentList $script:TestBaseUri, $script:TestToken
        }
        
        It "Should handle trailing slash in BaseUri" {
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            $result = Connect-FleetDM -BaseUri "$script:TestBaseUri/" -ApiToken $token
            
            $result.BaseUri | Should -Be $script:TestBaseUri
            InModuleScope FleetDM-PowerShell {
                param($expectedBaseUri)
                $script:FleetDMConnection.BaseUri | Should -Be $expectedBaseUri
            } -ArgumentList $script:TestBaseUri
        }
        
        It "Should create web session for connection pooling" {
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token
            
            InModuleScope FleetDM-PowerShell {
                $script:FleetDMWebSession | Should -Not -BeNullOrEmpty
                $script:FleetDMWebSession | Should -BeOfType [Microsoft.PowerShell.Commands.WebRequestSession]
            }
        }
    }
    
    Context "Credential Authentication" {
        It "Should connect with valid credentials" {
            $cred = [PSCredential]::new("test@example.com", (ConvertTo-SecureString "password" -AsPlainText -Force))
            
            $result = Connect-FleetDM -BaseUri $script:TestBaseUri -Credential $cred
            
            $result | Should -Not -BeNullOrEmpty
            $result.User | Should -Be "test@example.com"
            
            # Verify login was called with correct parameters
            Should -Invoke Invoke-RestMethod -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $Uri -like "*/api/v1/fleet/login" -and
                $Method -eq "POST" -and
                ($Body | ConvertFrom-Json).email -eq "test@example.com"
            }
        }
        
        It "Should handle login failure gracefully" {
            Mock Invoke-RestMethod {
                throw "Authentication failed"
            } -ParameterFilter { $Uri -like "*/login" } -ModuleName FleetDM-PowerShell
            
            $cred = [PSCredential]::new("bad@example.com", (ConvertTo-SecureString "badpass" -AsPlainText -Force))
            
            { Connect-FleetDM -BaseUri $script:TestBaseUri -Credential $cred } | 
                Should -Throw "*Failed to authenticate with FleetDM*"
        }
        
        It "Should log in with email and password" {
            $password = ConvertTo-SecureString "password" -AsPlainText -Force

            $result = Connect-FleetDM -BaseUri $script:TestBaseUri -Email "admin@example.com" -Password $password

            $result.User | Should -Be "test@example.com"
            Should -Invoke Invoke-RestMethod -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $Uri -like "*/api/v1/fleet/login" -and
                $Method -eq "POST" -and
                ($Body | ConvertFrom-Json).email -eq "admin@example.com" -and
                ($Body | ConvertFrom-Json).password -eq "password"
            }
        }

        It "Should handle missing token in login response" {
            Mock Invoke-RestMethod {
                return @{ user = @{ email = "test@example.com" } }
            } -ParameterFilter { $Uri -like "*/login" } -ModuleName FleetDM-PowerShell
            
            $cred = [PSCredential]::new("test@example.com", (ConvertTo-SecureString "password" -AsPlainText -Force))
            
            { Connect-FleetDM -BaseUri $script:TestBaseUri -Credential $cred } | 
                Should -Throw "*No token received from FleetDM login endpoint*"
        }
    }
    
    
    Context "Error Handling" {
        It "Should validate BaseUri parameter" {
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            { Connect-FleetDM -BaseUri "invalid-uri" -ApiToken $token } | 
                Should -Throw "*Cannot validate argument on parameter 'BaseUri'*"
        }
        
        It "Should handle version endpoint failure" {
            Mock Invoke-WebRequest {
                $exception = [System.Net.WebException]::new("Unauthorized")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception, 
                    "WebException", 
                    [System.Management.Automation.ErrorCategory]::ConnectionError, 
                    $null
                )
                # Create a mock response object
                Add-Member -InputObject $exception -MemberType NoteProperty -Name 'Response' -Value @{
                    StatusCode = 'Unauthorized'
                } -Force
                throw $errorRecord
            } -ParameterFilter { $Uri -like "*/version" } -ModuleName FleetDM-PowerShell
            
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            { Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token } | 
                Should -Throw "*Authentication failed*"
        }
        
        It "Should handle unexpected response format from version endpoint" {
            Mock Invoke-WebRequest {
                return [PSCustomObject]@{
                    Content = "Not JSON"
                    Headers = @{ 'Content-Type' = 'text/html' }
                }
            } -ParameterFilter { $Uri -like "*/version" } -ModuleName FleetDM-PowerShell
            
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            { Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token } | 
                Should -Throw "*Unexpected response format*"
        }
        
        It "Should clear connection data on failure" {
            Mock Invoke-WebRequest { throw "Connection failed" } -ParameterFilter { $Uri -like "*/version" } -ModuleName FleetDM-PowerShell
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            { Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token } | Should -Throw
            
            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection | Should -BeNullOrEmpty
                $script:FleetDMWebSession | Should -BeNullOrEmpty
            }
        }
        
        It "Should handle user info retrieval failure gracefully" {
            Mock Invoke-RestMethod {
                throw "Failed to get user info"
            } -ParameterFilter { $Uri -like "*/me" } -ModuleName FleetDM-PowerShell
            
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            $warnings = @()
            $result = Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token -WarningAction SilentlyContinue -WarningVariable warnings
            
            $result | Should -Not -BeNullOrEmpty
            $result.User | Should -Be "Unknown"
            $result.GlobalRole | Should -Be "Unknown"
            $warnings.Count | Should -BeGreaterThan 0
            $warnings[0] | Should -BeLike "*Could not retrieve user information*"
        }
    }
    
    Context "Parameter Validation" {
        It "Should require BaseUri parameter" {
            $command = Get-Command Connect-FleetDM
            $baseUriParam = $command.Parameters['BaseUri']
            $baseUriParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | 
                ForEach-Object { $_.Mandatory } | Should -Contain $true
        }
        
        It "Should require either ApiToken or Credential" {
            $command = Get-Command Connect-FleetDM
            
            # Check that ApiToken is mandatory in Token parameter set
            $apiTokenParam = $command.Parameters['ApiToken']
            $tokenParamSet = $apiTokenParam.Attributes | Where-Object { $_.ParameterSetName -eq 'Token' }
            $tokenParamSet.Mandatory | Should -Be $true
            
            # Check that Credential is mandatory in Credential parameter set  
            $credParam = $command.Parameters['Credential']
            $credParamSet = $credParam.Attributes | Where-Object { $_.ParameterSetName -eq 'Credential' }
            $credParamSet.Mandatory | Should -Be $true
        }
        
        It "Should not allow both ApiToken and Credential" {
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            $cred = [PSCredential]::new("test@example.com", $token)
            
            { Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token -Credential $cred -ErrorAction Stop } | 
                Should -Throw "*Parameter set cannot be resolved*"
        }
    }
    
    Context "SecureString Handling" {
        It "Should properly handle SecureString token conversion" {
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token
            
            # Verify the token was properly converted and used
            InModuleScope FleetDM-PowerShell {
                param($expectedToken)
                $script:FleetDMConnection.Headers['Authorization'] | Should -Be "Bearer $expectedToken"
            } -ArgumentList $script:TestToken
        }
        
        It "Should clean up BSTR after SecureString conversion" {
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            # This test verifies that no exception is thrown during BSTR cleanup
            { Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token } | Should -Not -Throw
        }
    }

    Context "Restricted API-only users" {
        It "Should connect when GET /version returns 403 and GET /me returns 200" {
            Mock Invoke-WebRequest {
                throw (New-ConnectHttpErrorRecord -StatusCode ([System.Net.HttpStatusCode]::Forbidden) -Message 'The remote server returned an error: (403) Forbidden.')
            } -ParameterFilter { $Uri -like '*/api/v1/fleet/version*' } -ModuleName FleetDM-PowerShell

            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            $warnings = @()
            $result = Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token -WarningVariable warnings

            $result | Should -Not -BeNullOrEmpty
            $result.BaseUri | Should -Be $script:TestBaseUri
            $result.User | Should -Be 'test@example.com'
            $result.GlobalRole | Should -Be 'admin'
            $null -eq $result.Version | Should -BeTrue
            @($warnings) | Should -BeNullOrEmpty

            Should -Invoke Invoke-WebRequest -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $Uri -like '*/api/v1/fleet/version*'
            }
            Should -Invoke Invoke-RestMethod -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $Uri -like '*/api/v1/fleet/me*'
            }

            InModuleScope FleetDM-PowerShell {
                param($ExpectedBaseUri)
                $script:FleetDMConnection | Should -Not -BeNullOrEmpty
                $script:FleetDMConnection.BaseUri | Should -Be $ExpectedBaseUri
                $null -eq $script:FleetDMConnection.Version | Should -BeTrue
                $script:FleetDMConnection.User.email | Should -Be 'test@example.com'
            } -ArgumentList $script:TestBaseUri
        }

        It "Should throw when GET /version returns 403 and GET /me returns 403" {
            Mock Invoke-WebRequest {
                throw (New-ConnectHttpErrorRecord -StatusCode ([System.Net.HttpStatusCode]::Forbidden) -Message 'The remote server returned an error: (403) Forbidden.')
            } -ParameterFilter { $Uri -like '*/api/v1/fleet/version*' } -ModuleName FleetDM-PowerShell
            Mock Invoke-RestMethod {
                throw (New-ConnectHttpErrorRecord -StatusCode ([System.Net.HttpStatusCode]::Forbidden) -Message 'The remote server returned an error: (403) Forbidden.')
            } -ParameterFilter { $Uri -like '*/api/v1/fleet/me*' } -ModuleName FleetDM-PowerShell

            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force

            $thrown = $null
            try {
                Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token
            }
            catch {
                $thrown = $_
            }

            $thrown | Should -Not -BeNullOrEmpty
            $thrown.Exception.Message | Should -BeLike '*Failed to connect to FleetDM*'
            $thrown.Exception.Message | Should -Not -BeLike '*Authentication failed*'

            Should -Invoke Invoke-RestMethod -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $Uri -like '*/api/v1/fleet/me*'
            }

            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection | Should -BeNullOrEmpty
                $script:FleetDMWebSession | Should -BeNullOrEmpty
            }
        }

        It "Should throw Authentication failed when GET /version returns 401" {
            Mock Invoke-WebRequest {
                throw (New-ConnectHttpErrorRecord -StatusCode ([System.Net.HttpStatusCode]::Unauthorized) -Message 'The remote server returned an error: (401) Unauthorized.')
            } -ParameterFilter { $Uri -like '*/api/v1/fleet/version*' } -ModuleName FleetDM-PowerShell

            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force

            { Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token } |
                Should -Throw '*Authentication failed*'

            Should -Invoke Invoke-RestMethod -ModuleName FleetDM-PowerShell -Times 0 -ParameterFilter {
                $Uri -like '*/api/v1/fleet/me*'
            }

            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection | Should -BeNullOrEmpty
                $script:FleetDMWebSession | Should -BeNullOrEmpty
            }
        }

        It "Should connect with SkipVersionCheck when GET /me returns 200 and should not call GET /version" {
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force

            $result = Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token -SkipVersionCheck

            $result.User | Should -Be 'test@example.com'
            $result.GlobalRole | Should -Be 'admin'
            $null -eq $result.Version | Should -BeTrue

            Should -Invoke Invoke-WebRequest -ModuleName FleetDM-PowerShell -Times 0 -ParameterFilter {
                $Uri -like '*/api/v1/fleet/version*'
            }
            Should -Invoke Invoke-RestMethod -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $Uri -like '*/api/v1/fleet/me*'
            }

            InModuleScope FleetDM-PowerShell {
                $null -eq $script:FleetDMConnection.Version | Should -BeTrue
                $script:FleetDMConnection.User.email | Should -Be 'test@example.com'
            }
        }

        It "Should throw Authentication failed when SkipVersionCheck is set and GET /me returns 401" {
            Mock Invoke-RestMethod {
                throw (New-ConnectHttpErrorRecord -StatusCode ([System.Net.HttpStatusCode]::Unauthorized) -Message 'The remote server returned an error: (401) Unauthorized.')
            } -ParameterFilter { $Uri -like '*/api/v1/fleet/me*' } -ModuleName FleetDM-PowerShell

            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force

            { Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token -SkipVersionCheck } |
                Should -Throw '*Authentication failed*'

            Should -Invoke Invoke-WebRequest -ModuleName FleetDM-PowerShell -Times 0 -ParameterFilter {
                $Uri -like '*/api/v1/fleet/version*'
            }

            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection | Should -BeNullOrEmpty
            }
        }

        It "Should throw when SkipVersionCheck is set and GET /me returns 403" {
            Mock Invoke-RestMethod {
                throw (New-ConnectHttpErrorRecord -StatusCode ([System.Net.HttpStatusCode]::Forbidden) -Message 'The remote server returned an error: (403) Forbidden.')
            } -ParameterFilter { $Uri -like '*/api/v1/fleet/me*' } -ModuleName FleetDM-PowerShell

            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force

            { Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token -SkipVersionCheck } |
                Should -Throw '*Failed to connect to FleetDM*'

            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection | Should -BeNullOrEmpty
                $script:FleetDMWebSession | Should -BeNullOrEmpty
            }
        }
    }
}