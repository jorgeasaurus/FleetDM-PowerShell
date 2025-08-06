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
                    $Uri -like "*query=test%20query*" -or $Uri -like "*query=test+query*"
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
    
    Context "Raw Output" {
        It "Should return raw response when Raw is specified" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-RestMethod {
                    return @{ raw = "data" }
                }
                
                $result = Invoke-FleetDMRequest -Endpoint "hosts" -Raw
                
                $result.raw | Should -Be "data"
            }
        }
    }
}