BeforeAll {
    # Import the module
    $modulePath = Join-Path $PSScriptRoot '../FleetDM-PowerShell.psd1'
    Import-Module $modulePath -Force
}

Describe "Invoke-FleetDMRequest" -Tags @('Unit', 'Core') {
    BeforeEach {
        # Setup mock connection for each test - must be done in module scope
        InModuleScope FleetDM-PowerShell {
            $script:FleetDMConnection = @{
                BaseUri = "https://test.fleetdm.example.com"
                Headers = @{ 
                    'Authorization' = 'Bearer test-token'
                    'Content-Type' = 'application/json'
                }
                Version = "4.0.0"
            }
            $script:FleetDMWebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        }
    }
    
    Context "Basic Request Execution" {
        It "Should execute GET request successfully" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        hosts = @(
                            @{ id = 1; hostname = "host1" },
                            @{ id = 2; hostname = "host2" }
                        )
                    }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts" -Method GET
                
                $result | Should -Not -BeNullOrEmpty
                $result.hosts | Should -HaveCount 2
                $result.hosts[0].hostname | Should -Be "host1"
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Method -eq 'GET' -and $Uri -like "*/hosts"
                }
            }
        }
        
        It "Should execute POST request successfully" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        policy = @{ id = 1; name = "test policy" }
                    }
                }
                
                $body = @{ name = "test"; query = "SELECT 1;" }
                $result = Invoke-FleetDMRequest -Endpoint "policies" -Method POST -Body $body
                
                $result | Should -Not -BeNullOrEmpty
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Method -eq 'POST' -and $Body -ne $null
                }
            }
        }
        
        It "Should execute PUT request successfully" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ success = $true }
                }
                
                $body = @{ test = "value" }
                $result = Invoke-FleetDMRequest -Endpoint "hosts/1" -Method PUT -Body $body
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Method -eq 'PUT'
                }
            }
        }
        
        It "Should execute PATCH request successfully" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ success = $true }
                }
                
                $body = @{ test = "value" }
                $result = Invoke-FleetDMRequest -Endpoint "hosts/1" -Method PATCH -Body $body
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Method -eq 'PATCH'
                }
            }
        }
        
        It "Should execute DELETE request successfully" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ success = $true }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts/1" -Method DELETE
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Method -eq 'DELETE'
                }
            }
        }
    }
    
    Context "Query Parameter Handling" {
        It "Should add query parameters to URL" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ hosts = @() }
                }
                
                $queryParams = @{
                    status = "online"
                    per_page = 50
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts" -QueryParameters $queryParams
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -like "*status=online*" -and $Uri -like "*per_page=50*"
                }
            }
        }
        
        It "Should URL encode query parameter values" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ hosts = @() }
                }
                
                $queryParams = @{
                    query = "test query"  # Space should be encoded
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts" -QueryParameters $queryParams
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri.OriginalString -like "*query=test%20query*" -or $Uri.OriginalString -like "*query=test+query*" -or $Uri.OriginalString -like "*query=test query*"
                }
            }
        }
        
        It "Should handle empty query parameters" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ hosts = @() }
                }
                
                { Invoke-FleetDMRequest -Endpoint "hosts" -QueryParameters @{} } | Should -Not -Throw
            }
        }
    }
    
    Context "Request Body Handling" {
        It "Should serialize hashtable body to JSON" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ success = $true }
                }
                
                $body = @{ name = "test"; value = 123 }
                
                $result = Invoke-FleetDMRequest -Endpoint "test" -Method POST -Body $body
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Body -ne $null -and $Body -is [string]
                }
            }
        }
        
        It "Should serialize nested objects in body" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ success = $true }
                }
                
                $body = @{
                    name = "test"
                    nested = @{
                        key = "value"
                        array = @(1, 2, 3)
                    }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "test" -Method POST -Body $body
                
                Should -Invoke Invoke-RestMethod -Times 1
            }
        }
    }
    
    Context "URL Construction" {
        It "Should construct correct API URL" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ hosts = @() }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts"
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq "https://test.fleetdm.example.com/api/v1/fleet/hosts"
                }
            }
        }
        
        It "Should handle endpoints with leading slash" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ hosts = @() }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "/hosts"
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq "https://test.fleetdm.example.com/api/v1/fleet/hosts"
                }
            }
        }
        
        It "Should handle endpoints with parameters" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ host = @{ id = 123 } }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts/123"
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq "https://test.fleetdm.example.com/api/v1/fleet/hosts/123"
                }
            }
        }
    }
    
    Context "Header Management" {
        It "Should include authorization header" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ hosts = @() }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts"
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Headers['Authorization'] -eq 'Bearer test-token'
                }
            }
        }
        
        It "Should include content-type header" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ hosts = @() }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts"
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $ContentType -eq 'application/json'
                }
            }
        }
        
        It "Should use web session for connection pooling" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ hosts = @() }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts"
                
                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $WebSession -ne $null
                }
            }
        }
    }
    
    Context "Pagination Support" {
        It "Should follow pagination when FollowPagination is true" {
            InModuleScope FleetDM-PowerShell {
                $script:PageCount = 0
                Mock Invoke-RestMethod {
                    $script:PageCount++
                    
                    if ($script:PageCount -eq 1) {
                        # First page
                        return [PSCustomObject]@{
                            hosts = @(@{ id = 1; hostname = "host1" })
                            meta = @{ has_next_results = $true }
                        }
                    }
                    else {
                        # Second page
                        return [PSCustomObject]@{
                            hosts = @(@{ id = 2; hostname = "host2" })
                            meta = @{ has_next_results = $false }
                        }
                    }
                }
                
                Mock Get-FleetPaginatedData {
                    param($Response, [switch]$ReturnMetadata)
                    
                    if ($ReturnMetadata) {
                        return @{
                            Data = $Response.hosts
                            HasMore = $Response.meta.has_next_results
                            Metadata = $Response.meta
                        }
                    }
                    return $Response.hosts
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts" -FollowPagination
                
                $result | Should -HaveCount 2
                Should -Invoke Invoke-RestMethod -Times 2
            }
        }
        
        It "Should not follow pagination by default" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        hosts = @(
                            @{ id = 1; hostname = "host1" },
                            @{ id = 2; hostname = "host2" }
                        )
                        meta = @{ has_next_results = $true }
                    }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts"
                
                # Should return single response, not follow pagination
                $result.hosts | Should -HaveCount 2
                Should -Invoke Invoke-RestMethod -Times 1
            }
        }
        
        It "Should handle pagination with query parameters" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    param($Uri)
                    
                    if ($Uri -like "*page=1*") {
                        return [PSCustomObject]@{
                            hosts = @(@{ id = 2 })
                            meta = @{ has_next_results = $false }
                        }
                    }
                    else {
                        return [PSCustomObject]@{
                            hosts = @(@{ id = 1 })
                            meta = @{ has_next_results = $true }
                        }
                    }
                }
                
                Mock Get-FleetPaginatedData {
                    param($Response, [switch]$ReturnMetadata)
                    
                    if ($ReturnMetadata) {
                        return @{
                            Data = $Response.hosts
                            HasMore = $Response.meta.has_next_results
                            Metadata = $Response.meta
                        }
                    }
                    return $Response.hosts
                }
                
                $queryParams = @{ status = "online" }
                $result = Invoke-FleetDMRequest -Endpoint "hosts" -QueryParameters $queryParams -FollowPagination
                
                Should -Invoke Invoke-RestMethod -Times 2
            }
        }
    }
    
    Context "Connection Validation" {
        It "Should throw when not connected to FleetDM" {
            InModuleScope FleetDM-PowerShell {
                # Clear connection
                $script:FleetDMConnection = $null
                
                { Invoke-FleetDMRequest -Endpoint "hosts" } | 
                    Should -Throw "*Not connected to FleetDM*"
            }
        }
    }
    
    Context "Error Handling" {
        It "Should handle API errors" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod { 
                    throw [System.Net.WebException]::new("API Error")
                }
                
                { Invoke-FleetDMRequest -Endpoint "hosts" } | 
                    Should -Throw "*API Error*"
            }
        }
        
        It "Should handle network timeouts" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod { 
                    throw [System.TimeoutException]::new("Request timeout")
                }
                
                { Invoke-FleetDMRequest -Endpoint "hosts" } | 
                    Should -Throw "*timeout*"
            }
        }
        
        It "Should handle JSON parsing errors" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod { 
                    throw [System.InvalidOperationException]::new("Invalid JSON")
                }
                
                { Invoke-FleetDMRequest -Endpoint "hosts" } | 
                    Should -Throw "*Invalid JSON*"
            }
        }
    }
    
    Context "Response Handling" {
        It "Should return response data directly" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return @{ data = "test" }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts"
                
                $result.data | Should -Be "test"
            }
        }
    }

    Context "Secret redaction" {
        It "Should keep passwords and bearer tokens out of the verbose stream" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ user = @{ id = 1 } }
                }

                $records = @(
                    Invoke-FleetDMRequest -Endpoint 'users/admin' -Method POST -Body @{
                        name = 'module-test'
                        email = 'api@example.com'
                        password = 'ex"ample-password'
                        token = 'api-token-value'
                    } -Verbose 4>&1
                )

                $log = @(
                    $records |
                        Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } |
                        ForEach-Object { $_.Message }
                ) -join "`n"

                $log | Should -Not -BeNullOrEmpty
                $log | Should -Match 'api@example.com'
                $log | Should -Match '\[REDACTED\]'
                $log | Should -Not -Match 'ex\\"ample-password'
                $log | Should -Not -Match 'ample-password'
                $log | Should -Not -Match 'api-token-value'
                $log | Should -Not -Match 'test-token'

                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Body -match 'ex\\"ample-password' -and
                    $Body -match 'api-token-value' -and
                    $Headers['Authorization'] -eq 'Bearer test-token'
                }
            }
        }

        It "Should redact secrets nested deeper than ConvertTo-Json depth 10" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ user = @{ id = 1 } }
                }

                $node = [pscustomobject]@{
                    label         = 'keep-visible'
                    password      = 'REDACT-TEST-PASSWORD'
                    token         = 'gg_test_not_a_real_secret'
                    authorization = 'Bearer gg_test_not_a_real_bearer'
                }
                for ($i = 0; $i -lt 11; $i++) {
                    $node = [pscustomobject]@{ child = $node }
                }

                $script:FleetDMConnection.Headers = @{
                    'Authorization' = 'Bearer test-token'
                    'X-Nested'      = $node
                }

                $body = @{
                    name    = 'module-test'
                    email   = 'api@example.com'
                    profile = $node
                }

                $records = @(
                    Invoke-FleetDMRequest -Endpoint 'users/admin' -Method POST -Body $body -Verbose 4>&1
                )

                $log = @(
                    $records |
                        Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } |
                        ForEach-Object { $_.Message }
                ) -join "`n"

                $log | Should -Match 'keep-visible'
                $log | Should -Match 'api@example.com'
                $log | Should -Match '\[REDACTED\]'
                $log | Should -Not -Match 'REDACT-TEST-PASSWORD'
                $log | Should -Not -Match 'gg_test_not_a_real_secret'
                $log | Should -Not -Match 'gg_test_not_a_real_bearer'
                $log | Should -Not -Match 'test-token'

                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Body -match 'REDACT-TEST-PASSWORD' -and
                    $Body -match 'gg_test_not_a_real_secret' -and
                    $Body -match 'gg_test_not_a_real_bearer' -and
                    $Body -notmatch '\[REDACTED\]' -and
                    $Headers['Authorization'] -eq 'Bearer test-token' -and
                    $Headers['X-Nested'].child.child.child.child.child.child.child.child.child.child.child.password -eq 'REDACT-TEST-PASSWORD'
                }
            }
        }

        It "Should redact secrets nested past the ConvertTo-Json maximum depth" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ user = @{ id = 1 } }
                }

                $node = [pscustomobject]@{
                    label         = 'keep-visible-deep'
                    password      = 'REDACT-TEST-PASSWORD-DEEP'
                    token         = 'gg_test_not_a_real_secret_deep'
                    authorization = 'Bearer gg_test_not_a_real_bearer_deep'
                }
                for ($i = 0; $i -lt 101; $i++) {
                    $node = [pscustomobject]@{ child = $node }
                }

                $body = @{ profile = $node }
                $expectedBody = ConvertTo-FleetJson -InputObject $body -Depth 10

                $records = @(
                    Invoke-FleetDMRequest -Endpoint 'users/admin' -Method POST -Body $body -Verbose 4>&1
                )

                $log = @(
                    $records |
                        Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } |
                        ForEach-Object { $_.Message }
                ) -join "`n"

                $log | Should -Match 'keep-visible-deep'
                $log | Should -Match '\[REDACTED\]'
                $log | Should -Not -Match 'REDACT-TEST-PASSWORD-DEEP'
                $log | Should -Not -Match 'gg_test_not_a_real_secret_deep'
                $log | Should -Not -Match 'gg_test_not_a_real_bearer_deep'
                $expectedBody | Should -Not -Match 'keep-visible-deep'
                $expectedBody | Should -Not -Match '\[REDACTED\]'

                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Body -eq $expectedBody -and
                    $Headers['Authorization'] -eq 'Bearer test-token'
                }
            }
        }

        It "Should redact stringified secrets and Windows PowerShell 5.1 Key/Value JSON" {
            InModuleScope FleetDM-PowerShell {
                $literal = 'prefix @{password=REDACT-TEST-PASSWORD; token=gg_test_not_a_real_secret; authorization=Bearer gg_test_not_a_real_bearer}'
                $redactedLiteral = Get-FleetRedactedLogText -Text $literal
                $redactedLiteral | Should -Match 'prefix'
                $redactedLiteral | Should -Not -Match 'REDACT-TEST-PASSWORD'
                $redactedLiteral | Should -Not -Match 'gg_test_not_a_real_secret'
                $redactedLiteral | Should -Not -Match 'gg_test_not_a_real_bearer'

                $entryJson = '[{"Key":"name","Value":"ok"},{"Key":"password","Value":"REDACT-TEST-PASSWORD"},{"Key":"token","Value":"gg_test_not_a_real_secret"},{"Key":"Authorization","Value":"Bearer gg_test_not_a_real_bearer"}]'
                $redactedEntries = Get-FleetRedactedLogText -Text $entryJson
                $redactedEntries | Should -Match 'ok'
                $redactedEntries | Should -Match '\[REDACTED\]'
                $redactedEntries | Should -Not -Match 'REDACT-TEST-PASSWORD'
                $redactedEntries | Should -Not -Match 'gg_test_not_a_real_secret'
                $redactedEntries | Should -Not -Match 'gg_test_not_a_real_bearer'
            }
        }

        It "Should redact array and object values of secret keys" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ user = @{ id = 1 } }
                }

                $json = '{"name":"keep-visible","token":["gg_test_not_a_real_first","gg_test_not_a_real_second"],"secret":{"nested":"gg_test_not_a_real_object"}}'
                $redactedJson = Get-FleetRedactedLogText -Text $json
                $redactedJson | Should -Match 'keep-visible'
                $redactedJson | Should -Not -Match 'gg_test_not_a_real_first'
                $redactedJson | Should -Not -Match 'gg_test_not_a_real_second'
                $redactedJson | Should -Not -Match 'gg_test_not_a_real_object'

                $entryJson = '{"Key":"token","Value":["gg_test_not_a_real_first","gg_test_not_a_real_second"]}'
                $redactedEntry = Get-FleetRedactedLogText -Text $entryJson
                $redactedEntry | Should -Not -Match 'gg_test_not_a_real_first'
                $redactedEntry | Should -Not -Match 'gg_test_not_a_real_second'

                $records = @(
                    Invoke-FleetDMRequest -Endpoint 'users/admin' -Method POST -Body @{
                        name   = 'keep-visible'
                        token  = @('gg_test_not_a_real_first', 'gg_test_not_a_real_second')
                        secret = @{ nested = 'gg_test_not_a_real_object' }
                    } -Verbose 4>&1
                )

                $log = @(
                    $records |
                        Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } |
                        ForEach-Object { $_.Message }
                ) -join "`n"

                $log | Should -Match 'keep-visible'
                $log | Should -Match '\[REDACTED\]'
                $log | Should -Not -Match 'gg_test_not_a_real_first'
                $log | Should -Not -Match 'gg_test_not_a_real_second'
                $log | Should -Not -Match 'gg_test_not_a_real_object'

                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Body -match 'gg_test_not_a_real_first' -and
                    $Body -match 'gg_test_not_a_real_second' -and
                    $Body -match 'gg_test_not_a_real_object' -and
                    $Body -notmatch '\[REDACTED\]'
                }
            }
        }

        It "Should suppress PowerShell literal secret values that contain delimiters" {
            InModuleScope FleetDM-PowerShell {
                $semicolon = Get-FleetRedactedLogText -Text '@{password=REDACT-TEST-PREFIX;REDACT-TEST-TAIL}'
                $semicolon | Should -Not -Match 'REDACT-TEST-PREFIX'
                $semicolon | Should -Not -Match 'REDACT-TEST-TAIL'

                $brace = Get-FleetRedactedLogText -Text '@{password=REDACT-TEST-PREFIX}REDACT-TEST-BRACE}'
                $brace | Should -Not -Match 'REDACT-TEST-PREFIX'
                $brace | Should -Not -Match 'REDACT-TEST-BRACE'

                $newline = Get-FleetRedactedLogText -Text "@{password=REDACT-TEST-PREFIX}`nREDACT-TEST-LINE"
                $newline | Should -Not -Match 'REDACT-TEST-PREFIX'
                $newline | Should -Not -Match 'REDACT-TEST-LINE'

                $longerName = Get-FleetRedactedLogText -Text 'host_token=keep-visible; query=SELECT 1'
                $longerName | Should -Match 'host_token=keep-visible'
                $longerName | Should -Match 'SELECT 1'
            }
        }

        It "Should redact secret query parameters in verbose URIs only" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return [PSCustomObject]@{ hosts = @() }
                }

                $records = @(
                    Invoke-FleetDMRequest -Endpoint 'hosts' -QueryParameters @{
                        status = 'online'
                        token  = 'gg_test_not_a_real_query'
                    } -Verbose 4>&1
                )

                $log = @(
                    $records |
                        Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } |
                        ForEach-Object { $_.Message }
                ) -join "`n"

                $log | Should -Match 'status=online'
                $log | Should -Match 'token=\[REDACTED\]'
                $log | Should -Not -Match 'gg_test_not_a_real_query'

                Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                    "$Uri" -match 'token=gg_test_not_a_real_query' -and
                    "$Uri" -match 'status=online'
                }
            }
        }
    }

    Context "Automatic retry" {
        BeforeAll {
            function global:New-FleetMockHttpError {
                param(
                    [int]$StatusCode,
                    [string]$StatusDescription,
                    [string]$Body,
                    [object]$Headers
                )

                if (-not $Headers) {
                    $Headers = @{}
                }

                $response = [PSCustomObject]@{
                    StatusCode = $StatusCode
                    StatusDescription = $StatusDescription
                    Headers = $Headers
                }
                $exception = New-Object System.Exception $StatusDescription
                $exception | Add-Member -NotePropertyName Response -NotePropertyValue $response -Force
                $record = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    "FleetHttp$StatusCode",
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $null
                )
                if ($Body) {
                    $record.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($Body)
                }

                return $record
            }

            function global:New-FleetOneShotHttpError {
                param(
                    [int]$StatusCode = 429,
                    [string]$StatusDescription = 'Too Many Requests',
                    [string]$Body,
                    [object]$Headers
                )

                if (-not $Headers) {
                    $Headers = [System.Net.WebHeaderCollection]::new()
                }

                $payload = [System.Text.Encoding]::UTF8.GetBytes($Body)
                $state = @{ Reads = 0; Payload = $payload }
                $response = [PSCustomObject]@{
                    StatusCode = $StatusCode
                    StatusDescription = $StatusDescription
                    Headers = $Headers
                }
                $response | Add-Member -MemberType ScriptMethod -Name GetResponseStream -Value {
                    $state.Reads++
                    if ($state.Reads -gt 1) {
                        return [System.IO.MemoryStream]::new()
                    }

                    return [System.IO.MemoryStream]::new($state.Payload)
                }.GetNewClosure()

                $exception = New-Object System.Exception $StatusDescription
                $exception | Add-Member -NotePropertyName Response -NotePropertyValue $response -Force
                return [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    "FleetHttp$StatusCode",
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $null
                )
            }
        }

        AfterAll {
            Remove-Item -Path function:New-FleetMockHttpError -ErrorAction SilentlyContinue
            Remove-Item -Path function:New-FleetOneShotHttpError -ErrorAction SilentlyContinue
        }

        It "succeeds after waiting when HTTP 429 is followed by HTTP 200" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $record = New-FleetMockHttpError -StatusCode 429 -StatusDescription 'Too Many Requests' -Headers @{
                            'Retry-After' = '5'
                        } -Body '{"message":"Rate limit exceeded. Retry after: 30s"}'
                        throw $record
                    }

                    return [PSCustomObject]@{
                        hosts = @(@{ id = 1; hostname = 'host1' })
                    }
                }

                $records = @(
                    Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET -Verbose 4>&1
                )
                $result = $records | Where-Object { $_ -isnot [System.Management.Automation.VerboseRecord] -and $_ -isnot [System.Management.Automation.WarningRecord] }
                $log = @(
                    $records |
                        Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } |
                        ForEach-Object { $_.Message }
                ) -join "`n"

                @($result)[0].hosts[0].hostname | Should -Be 'host1'
                $log | Should -Match 'Retrying GET'
                $log | Should -Match 'HTTP 429'
                $log | Should -Match '5 seconds'
                $log | Should -Match 'retry 1 of 3'
                Should -Invoke Invoke-RestMethod -Times 2 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 5 }
            }
        }

        It "retries any method after the retry-after text when HTTP 429 has no header" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $record = New-FleetMockHttpError -StatusCode 429 -StatusDescription 'Too Many Requests' -Body '{"message":"Rate limit exceeded. Retry after: 7s"}'
                        throw $record
                    }

                    return [PSCustomObject]@{ policy = @{ id = 4 } }
                }

                $result = Invoke-FleetDMRequest -Endpoint 'policies' -Method POST -Body @{ name = 'retry' }
                $result.policy.id | Should -Be 4
                Should -Invoke Invoke-RestMethod -Times 2 -Exactly -ParameterFilter { $Method -eq 'POST' }
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 7 }
            }
        }

        It "reads a PowerShell 7 Retry-After date as seconds from now" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $headers = [PSCustomObject]@{
                            RetryAfter = [PSCustomObject]@{
                                Delta = $null
                                Date = [datetimeoffset]::UtcNow.AddSeconds(11)
                            }
                        }
                        $record = New-FleetMockHttpError -StatusCode 429 -StatusDescription 'Too Many Requests' -Headers $headers
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                Invoke-FleetDMRequest -Endpoint 'hosts' | Out-Null
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -ge 9 -and $Seconds -le 12 }
            }
        }

        It "uses the PowerShell 7 Retry-After delta when that header shape is present" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $headers = [PSCustomObject]@{
                            RetryAfter = [PSCustomObject]@{ Delta = [timespan]::FromSeconds(6) }
                        }
                        $record = New-FleetMockHttpError -StatusCode 429 -StatusDescription 'Too Many Requests' -Headers $headers
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                Invoke-FleetDMRequest -Endpoint 'hosts' | Out-Null
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 6 }
            }
        }

        It "throws the last error after three retries when GET receives HTTP 503" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetDelays = [System.Collections.Generic.List[int]]::new()
                Mock Wait-FleetRequestRetry {
                    $script:FleetDelays.Add([int]$Seconds)
                }
                Mock Invoke-RestMethod {
                    $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable' -Body '{"message":"unavailable"}'
                    throw $record
                }

                $failed = $false
                $verbose = [System.Collections.Generic.List[string]]::new()
                try {
                    Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET -Verbose 4>&1 |
                        Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } |
                        ForEach-Object { $verbose.Add($_.Message) }
                }
                catch {
                    $failed = $true
                    $_.Exception.Message | Should -Be 'Service unavailable. FleetDM service is temporarily unavailable.'
                    $_.Exception.Message | Should -Not -Match 'Failed to communicate'
                }

                $failed | Should -BeTrue
                @($verbose | Where-Object { $_ -match 'Retrying GET' }).Count | Should -Be 3
                Should -Invoke Invoke-RestMethod -Times 4 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 3 -Exactly
                @($script:FleetDelays) | Should -Be @(2, 4, 8)
            }
        }

        It "throws HTTP 503 on POST without retrying" {
            InModuleScope FleetDM-PowerShell {
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable' -Body '{"message":"unavailable"}'
                    throw $record
                }

                { Invoke-FleetDMRequest -Endpoint 'software/install' -Method POST -Body @{ host_id = 1 } } |
                    Should -Throw '*Service unavailable*'
                Should -Invoke Invoke-RestMethod -Times 1 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 0 -Exactly
            }
        }

        It "does not retry <Method> after HTTP 503 unless RetryNonIdempotent is set" -TestCases @(
            @{ Method = 'PUT' }
            @{ Method = 'PATCH' }
            @{ Method = 'DELETE' }
        ) {
            InModuleScope FleetDM-PowerShell -Parameters @{ MethodName = $Method } {
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable'
                    throw $record
                }

                { Invoke-FleetDMRequest -Endpoint 'hosts/1' -Method $MethodName -Body @{ name = 'once' } } |
                    Should -Throw '*Service unavailable*'
                Should -Invoke Invoke-RestMethod -Times 1 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 0 -Exactly
            }
        }

        It "retries POST after HTTP 503 when RetryNonIdempotent is set" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable'
                        throw $record
                    }

                    return [PSCustomObject]@{ install = 'queued' }
                }

                $result = Invoke-FleetDMRequest -Endpoint 'software/install' -Method POST -Body @{ host_id = 1 } -RetryNonIdempotent
                $result.install | Should -Be 'queued'
                Should -Invoke Invoke-RestMethod -Times 2 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 2 }
            }
        }

        It "retries GET after HTTP <StatusCode> and then returns the host" -TestCases @(
            @{ StatusCode = 502 }
            @{ StatusCode = 504 }
        ) {
            InModuleScope FleetDM-PowerShell -Parameters @{ Code = $StatusCode } {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $record = New-FleetMockHttpError -StatusCode $Code -StatusDescription "HTTP $Code"
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @(@{ id = 9 }) }
                }

                $result = Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET
                $result.hosts[0].id | Should -Be 9
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 2 }
            }
        }

        It "does not retry HTTP 500" {
            InModuleScope FleetDM-PowerShell {
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $record = New-FleetMockHttpError -StatusCode 500 -StatusDescription 'Internal Server Error' -Body '{"message":"boom"}'
                    throw $record
                }

                { Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET } |
                    Should -Throw '*Internal server error*'
                Should -Invoke Invoke-RestMethod -Times 1 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 0 -Exactly
            }
        }

        It "stops after MaxRetries 0 without waiting" {
            InModuleScope FleetDM-PowerShell {
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable'
                    throw $record
                }

                { Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET -MaxRetries 0 } |
                    Should -Throw '*Service unavailable*'
                Should -Invoke Invoke-RestMethod -Times 1 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 0 -Exactly
            }
        }

        It "uses the backoff when HTTP 429 has no Retry-After hint" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $record = New-FleetMockHttpError -StatusCode 429 -StatusDescription 'Too Many Requests'
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET | Out-Null
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 2 }
            }
        }

        It "keeps secret query values out of the retry verbose line" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable'
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                $records = @(
                    Invoke-FleetDMRequest -Endpoint 'hosts' -QueryParameters @{
                        status = 'online'
                        token  = 'gg_test_not_a_real_query'
                    } -Verbose 4>&1
                )
                $log = @(
                    $records |
                        Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } |
                        ForEach-Object { $_.Message }
                ) -join "`n"

                $log | Should -Match 'Retrying GET'
                $log | Should -Match 'token=\[REDACTED\]'
                $log | Should -Not -Match 'gg_test_not_a_real_query'
            }
        }

        It "retries one paginated page and still reads the next page" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable'
                        throw $record
                    }

                    if ("$Uri" -like '*page=1*') {
                        return [PSCustomObject]@{
                            hosts = @(
                                [PSCustomObject]@{ id = 3; hostname = 'host3' }
                            )
                            meta = [PSCustomObject]@{ has_next_results = $false }
                        }
                    }

                    return [PSCustomObject]@{
                        hosts = @(
                            [PSCustomObject]@{ id = 1; hostname = 'host1' }
                            [PSCustomObject]@{ id = 2; hostname = 'host2' }
                        )
                        meta = [PSCustomObject]@{ has_next_results = $true }
                    }
                }

                $result = @(Invoke-FleetDMRequest -Endpoint 'hosts' -FollowPagination)
                $result.Count | Should -Be 3
                $result[0].hostname | Should -Be 'host1'
                $result[2].hostname | Should -Be 'host3'
                Should -Invoke Invoke-RestMethod -Times 3 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 2 }
            }
        }

        It "throws the rate-limit error after three retries" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetDelays = [System.Collections.Generic.List[int]]::new()
                Mock Wait-FleetRequestRetry {
                    $script:FleetDelays.Add([int]$Seconds)
                }
                Mock Invoke-RestMethod {
                    $headers = [System.Net.WebHeaderCollection]::new()
                    $headers['Retry-After'] = '9'
                    $record = New-FleetMockHttpError -StatusCode 429 -StatusDescription 'Too Many Requests' -Headers $headers -Body '{"message":"Rate limit exceeded. Retry after: 9s"}'
                    throw $record
                }

                $failed = $false
                try {
                    Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET
                }
                catch {
                    $failed = $true
                    $_.Exception.Message | Should -Be 'Rate limit exceeded. Retry after 9 seconds.'
                }

                $failed | Should -BeTrue
                @($script:FleetDelays) -join ',' | Should -Be '9,9,9'
                Should -Invoke Invoke-RestMethod -Times 4 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 3 -Exactly
            }
        }

        It "throws the body retry-after text when the stream can be read once" {
            InModuleScope FleetDM-PowerShell {
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $record = New-FleetOneShotHttpError -Body '{"message":"Rate limit exceeded. Retry after: 4s"}'
                    throw $record
                }

                { Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET -MaxRetries 0 } |
                    Should -Throw 'Rate limit exceeded. Retry after 4 seconds.*'
                Should -Invoke Invoke-RestMethod -Times 1 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 0 -Exactly
            }
        }

        It "uses backoff when Retry-After is <Header>" -TestCases @(
            @{ Header = '0' }
            @{ Header = '-5' }
        ) {
            InModuleScope FleetDM-PowerShell -Parameters @{ HeaderValue = $Header } {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $headers = [System.Net.WebHeaderCollection]::new()
                        $headers['Retry-After'] = $HeaderValue
                        $record = New-FleetMockHttpError -StatusCode 429 -StatusDescription 'Too Many Requests' -Headers $headers
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET | Out-Null
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 2 }
            }
        }

        It "caps a day-long Retry-After at the default maximum" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $headers = [System.Net.WebHeaderCollection]::new()
                        $headers['Retry-After'] = '86400'
                        $record = New-FleetMockHttpError -StatusCode 429 -StatusDescription 'Too Many Requests' -Headers $headers
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET | Out-Null
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 120 }
            }
        }

        It "caps an oversized Retry-After without replacing the rate-limit error" {
            InModuleScope FleetDM-PowerShell {
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $record = New-FleetMockHttpError -StatusCode 429 -StatusDescription 'Too Many Requests' -Body '{"message":"Rate limit exceeded. Retry after: 999999999999999999999s"}'
                    throw $record
                }

                { Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET -MaxRetries 1 -MaxRetryDelaySeconds 45 } |
                    Should -Throw 'Rate limit exceeded. Retry after 45 seconds.*'
                Should -Invoke Invoke-RestMethod -Times 2 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 45 }
            }
        }

        It "reads an HTTP-date Retry-After from WebHeaderCollection" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $headers = [System.Net.WebHeaderCollection]::new()
                        $headers['Retry-After'] = [datetime]::UtcNow.AddSeconds(30).ToString('r')
                        $record = New-FleetMockHttpError -StatusCode 429 -StatusDescription 'Too Many Requests' -Headers $headers
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET | Out-Null
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -ge 20 -and $Seconds -le 35 }
            }
        }

        It "uses backoff when the Retry-After HTTP-date is in the past" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $headers = [System.Net.WebHeaderCollection]::new()
                        $headers['Retry-After'] = [datetime]::UtcNow.AddHours(-1).ToString('r')
                        $record = New-FleetMockHttpError -StatusCode 429 -StatusDescription 'Too Many Requests' -Headers $headers
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET | Out-Null
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 2 }
            }
        }

        It "reads Retry-After <Shape> from HttpResponseMessage headers" -TestCases @(
            @{ Shape = 'delta' }
            @{ Shape = 'date' }
        ) {
            if (-not ('System.Net.Http.Headers.RetryConditionHeaderValue' -as [type])) {
                Set-ItResult -Skipped -Because 'HttpResponseMessage Retry-After headers need PowerShell 7'
            }

            InModuleScope FleetDM-PowerShell -Parameters @{ HeaderShape = $Shape } {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $message = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::TooManyRequests)
                        if ($HeaderShape -eq 'date') {
                            $retryAfter = [System.Net.Http.Headers.RetryConditionHeaderValue]::new([datetimeoffset]::UtcNow.AddSeconds(11))
                        }
                        else {
                            $retryAfter = [System.Net.Http.Headers.RetryConditionHeaderValue]::new([timespan]::FromSeconds(6))
                        }
                        $message.Headers.RetryAfter = $retryAfter
                        $exception = New-Object System.Exception 'Too Many Requests'
                        $exception | Add-Member -NotePropertyName Response -NotePropertyValue $message -Force
                        $record = [System.Management.Automation.ErrorRecord]::new(
                            $exception,
                            'FleetHttp429',
                            [System.Management.Automation.ErrorCategory]::InvalidOperation,
                            $null
                        )
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET | Out-Null
                if ($HeaderShape -eq 'date') {
                    Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -ge 9 -and $Seconds -le 12 }
                }
                else {
                    Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 6 }
                }
            }
        }

        It "honors Retry-After on HTTP 503" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $headers = [System.Net.WebHeaderCollection]::new()
                        $headers['Retry-After'] = '9'
                        $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable' -Headers $headers
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET | Out-Null
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 9 }
            }
        }

        It "retries <Method> after HTTP 503 when RetryNonIdempotent is set" -TestCases @(
            @{ Method = 'PUT' }
            @{ Method = 'PATCH' }
            @{ Method = 'DELETE' }
        ) {
            InModuleScope FleetDM-PowerShell -Parameters @{ MethodName = $Method } {
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable'
                        throw $record
                    }

                    return [PSCustomObject]@{ ok = $true }
                }

                $result = Invoke-FleetDMRequest -Endpoint 'hosts/1' -Method $MethodName -Body @{ name = 'again' } -RetryNonIdempotent
                $result.ok | Should -BeTrue
                Should -Invoke Invoke-RestMethod -Times 2 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 1 -Exactly -ParameterFilter { $Seconds -eq 2 }
            }
        }

        It "throws the gateway timeout message after GET retries are exhausted" {
            InModuleScope FleetDM-PowerShell {
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $record = New-FleetMockHttpError -StatusCode 504 -StatusDescription 'Gateway Timeout'
                    throw $record
                }

                { Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET } |
                    Should -Throw 'Gateway timeout. FleetDM service may be temporarily unavailable.'
                Should -Invoke Invoke-RestMethod -Times 4 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 3 -Exactly
            }
        }

        It "caps the backoff when MaxRetries would overflow the timer" {
            InModuleScope FleetDM-PowerShell {
                $script:FleetDelays = [System.Collections.Generic.List[int]]::new()
                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry {
                    $script:FleetDelays.Add([int]$Seconds)
                }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -le 7) {
                        $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable'
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET -MaxRetries 7 | Out-Null
                @($script:FleetDelays) -join ',' | Should -Be '2,4,8,16,32,64,120'
                Should -Invoke Invoke-RestMethod -Times 8 -Exactly
            }
        }

        It "keeps a one-element array page intact for pagination" {
            InModuleScope FleetDM-PowerShell {
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    return , @(
                        [PSCustomObject]@{
                            hosts = @([PSCustomObject]@{ id = 1; hostname = 'keep' })
                            meta = [PSCustomObject]@{ has_next_results = $false }
                        }
                    )
                }

                $result = @(Invoke-FleetDMRequest -Endpoint 'hosts' -FollowPagination)
                $result.Count | Should -Be 1
                $result[0].hosts[0].hostname | Should -Be 'keep'
                Should -Invoke Invoke-RestMethod -Times 1 -Exactly
            }
        }

        It "throws after retries when the second page keeps returning HTTP 503" {
            InModuleScope FleetDM-PowerShell {
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    if ("$Uri" -like '*page=1*') {
                        $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable'
                        throw $record
                    }

                    return [PSCustomObject]@{
                        hosts = @(
                            [PSCustomObject]@{ id = 1; hostname = 'host1' }
                            [PSCustomObject]@{ id = 2; hostname = 'host2' }
                        )
                        meta = [PSCustomObject]@{ has_next_results = $true }
                    }
                }

                { Invoke-FleetDMRequest -Endpoint 'hosts' -FollowPagination } |
                    Should -Throw 'Service unavailable. FleetDM service is temporarily unavailable.'
                Should -Invoke Invoke-RestMethod -Times 5 -Exactly
                Should -Invoke Wait-FleetRequestRetry -Times 3 -Exactly
            }
        }

        It "redacts Fleet secret query values in the retry verbose line" {
            InModuleScope FleetDM-PowerShell {
                $redacted = Get-FleetRedactedUriText -Text 'https://fleet.example/api?enroll_secret=keep-enroll&access_token=keep-access&node_key=keep-node&status=online'
                $redacted | Should -Match 'status=online'
                $redacted | Should -Match 'enroll_secret=\[REDACTED\]'
                $redacted | Should -Match 'access_token=\[REDACTED\]'
                $redacted | Should -Match 'node_key=\[REDACTED\]'
                $redacted | Should -Not -Match 'keep-enroll'
                $redacted | Should -Not -Match 'keep-access'
                $redacted | Should -Not -Match 'keep-node'

                $script:FleetAttempt = 0
                Mock Wait-FleetRequestRetry { }
                Mock Invoke-RestMethod {
                    $script:FleetAttempt++
                    if ($script:FleetAttempt -eq 1) {
                        $record = New-FleetMockHttpError -StatusCode 503 -StatusDescription 'Service Unavailable'
                        throw $record
                    }

                    return [PSCustomObject]@{ hosts = @() }
                }

                $records = @(
                    Invoke-FleetDMRequest -Endpoint 'hosts' -QueryParameters @{
                        enroll_secret = 'keep-enroll'
                        status = 'online'
                    } -Verbose 4>&1
                )
                $log = @(
                    $records |
                        Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } |
                        ForEach-Object { $_.Message }
                ) -join "`n"
                $log | Should -Match 'Retrying GET'
                $log | Should -Match 'enroll_secret=\[REDACTED\]'
                $log | Should -Not -Match 'keep-enroll'
            }
        }
    }
}