#Requires -Module Pester

BeforeAll {
    # Import test helper
    . (Join-Path $PSScriptRoot 'TestHelper.ps1')
    
    # Import the module using the helper
    Import-TestModule
    
    # Test configuration
    $script:TestBaseUri = "https://test.fleetdm.example.com"
    $script:TestToken = "test-api-token-12345"
    
    # Mock Invoke-RestMethod for API calls
    Mock Invoke-RestMethod {
        param($Uri, $Method, $Headers, $ContentType, $WebSession, $ErrorAction)
        
        if ($Uri -like "*/api/v1/fleet/login") {
            return @{
                user = @{
                    name = "Test User"
                    email = "test@example.com"
                    global_role = "admin"
                    id = 1
                }
                token = $script:TestToken
            }
        }
        elseif ($Uri -like "*/api/v1/fleet/me") {
            return @{
                user = @{
                    name = "Test User"
                    email = "test@example.com"
                    global_role = "admin"
                    id = 1
                }
            }
        }
        elseif ($Uri -like "*/api/v1/fleet/hosts") {
            return @{
                hosts = @(
                    @{
                        id = 1
                        hostname = "test-host-1"
                        status = "online"
                        platform = "ubuntu"
                    }
                )
            }
        }
    } -ModuleName FleetDM-PowerShell
    
    # Mock Invoke-WebRequest for version endpoint
    Mock Invoke-WebRequest {
        param($Uri, $Method, $Headers, $WebSession, $ErrorAction)
        
        if ($Uri -like "*/api/v1/fleet/version*") {
            return [PSCustomObject]@{
                Content = '{"version": "4.0.0"}'
                Headers = @{ 'Content-Type' = 'application/json' }
                StatusCode = 200
                StatusDescription = "OK"
            }
        }
    } -ModuleName FleetDM-PowerShell
    
    # Mock Invoke-FleetDMRequest
    Mock Invoke-FleetDMRequest {
        param($Endpoint, $Method, $Body, $QueryParameters)
        
        if ($Endpoint -eq "hosts") {
            return @{
                hosts = @(
                    @{
                        id = 1
                        hostname = "test-host-1"
                        status = "online"
                        platform = "ubuntu"
                    }
                )
            }
        }
        throw "Not connected to FleetDM. Please run Connect-FleetDM first."
    } -ModuleName FleetDM-PowerShell
}

Describe "Disconnect-FleetDM Tests" {
    Context "When connected to FleetDM" {
        BeforeEach {
            # Ensure we're connected before each test
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            $null = Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token
        }
        
        AfterEach {
            # Clean up connection state
            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection = $null
                $script:FleetDMWebSession = $null
            }
        }
        
        It "Should disconnect successfully" {
            $result = Disconnect-FleetDM
            
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.TypeNames | Should -Contain 'FleetDM.Disconnection'
            $result.BaseUri | Should -Be $script:TestBaseUri
            $result.DisconnectedAt | Should -BeOfType [DateTime]
            $result.Message | Should -BeLike "*Successfully disconnected*"
        }
        
        It "Should clear the connection state" {
            # Disconnect
            $null = Disconnect-FleetDM
            
            # Verify connection is cleared
            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection | Should -BeNullOrEmpty
                $script:FleetDMWebSession | Should -BeNullOrEmpty
            }
        }
        
        It "Should support -WhatIf" {
            # Run with -WhatIf
            $null = Disconnect-FleetDM -WhatIf
            
            # Should not actually disconnect - connection should still exist
            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection | Should -Not -BeNullOrEmpty
            }
        }
        
        It "Should show verbose information when requested" {
            $verboseOutput = Disconnect-FleetDM -Verbose 4>&1 | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
            
            $verboseOutput | Should -Not -BeNullOrEmpty
            $verboseMessages = $verboseOutput | ForEach-Object { $_.ToString() }
            $verboseMessages -join ' ' | Should -BeLike "*Disconnecting from FleetDM*"
        }
    }
    
    Context "When not connected to FleetDM" {
        BeforeEach {
            # Ensure we're disconnected
            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection = $null
                $script:FleetDMWebSession = $null
            }
        }
        
        It "Should show warning when not connected" {
            $warningOutput = Disconnect-FleetDM 3>&1 | Where-Object { $_ -is [System.Management.Automation.WarningRecord] }
            
            $warningOutput | Should -Not -BeNullOrEmpty
            $warningOutput.ToString() | Should -BeLike "*Not currently connected to FleetDM*"
        }
        
        It "Should not throw error when disconnecting while not connected" {
            { Disconnect-FleetDM } | Should -Not -Throw
        }
    }
    
    Context "Connection lifecycle" {
        AfterEach {
            # Clean up connection state
            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection = $null
                $script:FleetDMWebSession = $null
            }
        }
        
        It "Should allow reconnection after disconnect" {
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            # Connect
            $connectResult = Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token
            $connectResult | Should -Not -BeNullOrEmpty
            
            # Disconnect
            $disconnectResult = Disconnect-FleetDM
            $disconnectResult | Should -Not -BeNullOrEmpty
            
            # Verify disconnected
            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection | Should -BeNullOrEmpty
            }
            
            # Reconnect
            $reconnectResult = Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token
            $reconnectResult | Should -Not -BeNullOrEmpty
            
            # Verify reconnected
            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection | Should -Not -BeNullOrEmpty
                $script:FleetDMConnection.BaseUri | Should -Not -BeNullOrEmpty
            }
        }
        
        It "Should handle multiple disconnect calls gracefully" {
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            
            # Connect once
            Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token
            
            # Disconnect multiple times
            { Disconnect-FleetDM } | Should -Not -Throw
            { Disconnect-FleetDM } | Should -Not -Throw  # Second disconnect should work without error
            
            # Verify warning on second disconnect
            $warningOutput = Disconnect-FleetDM 3>&1 | Where-Object { $_ -is [System.Management.Automation.WarningRecord] }
            $warningOutput | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Error handling" {
        It "Should provide clear disconnection object" {
            $token = ConvertTo-SecureString $script:TestToken -AsPlainText -Force
            Connect-FleetDM -BaseUri $script:TestBaseUri -ApiToken $token
            
            $result = Disconnect-FleetDM
            
            # Verify all expected properties exist
            $result.PSObject.Properties.Name | Should -Contain 'BaseUri'
            $result.PSObject.Properties.Name | Should -Contain 'DisconnectedAt'
            $result.PSObject.Properties.Name | Should -Contain 'Message'
            $result.PSObject.TypeNames[0] | Should -Be 'FleetDM.Disconnection'
        }
    }
}