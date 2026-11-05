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
}