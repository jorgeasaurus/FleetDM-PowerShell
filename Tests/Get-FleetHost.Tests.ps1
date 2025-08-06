BeforeAll {
    # Import test helper
    . (Join-Path $PSScriptRoot 'TestHelper.ps1')
    
    # Import the module using the helper
    Import-TestModule
    
    # Mock connection - set in module scope
    InModuleScope FleetDM-PowerShell {
        $script:FleetDMConnection = @{
            BaseUri = "https://test.fleetdm.example.com"
            Headers = @{ 'Authorization' = 'Bearer test-token' }
            Version = "4.0.0"
        }
    }
    
    # Mock Invoke-FleetDMRequest function
    Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
        param($Endpoint, $Method, $QueryParameters, $FollowPagination)
        
        # Define mock hosts data within the mock
        $mockHosts = @(
            @{
                id = 1
                hostname = "test-host-1"
                platform = "darwin"
                osquery_version = "5.0.0"
                status = "online"
                team_id = 1
                team_name = "Team A"
                issues = @{ total = 2 }
            },
            @{
                id = 2
                hostname = "test-host-2"
                platform = "windows"
                osquery_version = "5.0.0"
                status = "offline"
                team_id = 2
                team_name = "Team B"
                issues = @{ total = 0 }
            },
            @{
                id = 3
                hostname = "production-server"
                platform = "ubuntu"
                osquery_version = "5.0.0"
                status = "online"
                team_id = 1
                team_name = "Team A"
                issues = @{ total = 1 }
            }
        )
        
        if ($Endpoint -match "hosts/(\d+)") {
            $hostId = [int]$matches[1]
            $fleetHost = $mockHosts | Where-Object { $_.id -eq $hostId }
            if ($fleetHost) {
                return @{
                    host = [PSCustomObject]$fleetHost
                }
            }
            else {
                throw "Host not found"
            }
        }
        elseif ($Endpoint -eq "hosts") {
            $filteredHosts = $mockHosts
            
            # Apply filters based on query parameters
            if ($QueryParameters) {
                if ($QueryParameters.status) {
                    $filteredHosts = $filteredHosts | Where-Object { $_.status -eq $QueryParameters.status }
                }
                if ($QueryParameters.team_id) {
                    $filteredHosts = $filteredHosts | Where-Object { $_.team_id -eq [int]$QueryParameters.team_id }
                }
                if ($QueryParameters.query) {
                    $filteredHosts = $filteredHosts | Where-Object { $_.hostname -like "*$($QueryParameters.query)*" }
                }
            }
            
            # Return just the array of hosts, as Get-FleetHost extracts them
            return $filteredHosts | ForEach-Object { [PSCustomObject]$_ }
        }
        else {
            throw "Unexpected endpoint: $Endpoint"
        }
    }
}

Describe "Get-FleetHost" -Tags @('Unit', 'Hosts') {
    Context "Single Host Retrieval" {
        It "Should retrieve a specific host by ID" {
            $result = Get-FleetHost -Id 1
            
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.TypeNames | Should -Contain 'FleetDM.Host'
            $result.id | Should -Be 1
            $result.hostname | Should -Be "test-host-1"
            $result.platform | Should -Be "darwin"
            $result.status | Should -Be "online"
        }
        
        It "Should handle non-existent host ID" {
            { Get-FleetHost -Id 999 } | Should -Throw "*Host not found*"
        }
        
        It "Should add custom type name to single host result" {
            $result = Get-FleetHost -Id 1
            
            $result.PSObject.TypeNames[0] | Should -Be 'FleetDM.Host'
        }
    }
    
    Context "Multiple Host Retrieval" {
        It "Should retrieve all hosts when no parameters provided" {
            $result = Get-FleetHost
            
            $result | Should -HaveCount 3
            $result[0].PSObject.TypeNames | Should -Contain 'FleetDM.Host'
            $result[1].PSObject.TypeNames | Should -Contain 'FleetDM.Host'
        }
        
        It "Should filter hosts by status" {
            $result = Get-FleetHost -Status "online"
            
            $result | Should -HaveCount 2
            $result[0].hostname | Should -Be "test-host-1"
            $result[0].status | Should -Be "online"
            $result[1].status | Should -Be "online"
        }
        
        It "Should filter hosts by hostname pattern" {
            $result = Get-FleetHost -Hostname "host-1"
            
            $result | Should -HaveCount 1
            $result[0].hostname | Should -Be "test-host-1"
        }
        
        It "Should support multiple filters simultaneously" {
            $result = Get-FleetHost -Status "offline" -Hostname "host-2"
            
            $result | Should -HaveCount 1
            $result[0].hostname | Should -Be "test-host-2"
            $result[0].status | Should -Be "offline"
        }
    }
    
    Context "Parameter Handling" {
        It "Should include software when IncludeSoftware switch is used" {
            Get-FleetHost -IncludeSoftware
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $QueryParameters.populate_software -eq 'true'
            }
        }
        
        It "Should include policies when IncludePolicies switch is used" {
            Get-FleetHost -IncludePolicies
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $QueryParameters.populate_policies -eq 'true'
            }
        }
        
        It "Should include both software and policies when both switches are used" {
            Get-FleetHost -IncludeSoftware -IncludePolicies
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $QueryParameters.populate_software -eq 'true' -and
                $QueryParameters.populate_policies -eq 'true'
            }
        }
        
        It "Should validate status parameter values" {
            { Get-FleetHost -Status "invalid" } | 
                Should -Throw "*Cannot validate argument on parameter 'Status'*"
        }
        
        It "Should accept valid status values" {
            { Get-FleetHost -Status "online" } | Should -Not -Throw
            { Get-FleetHost -Status "offline" } | Should -Not -Throw
            { Get-FleetHost -Status "missing" } | Should -Not -Throw
        }
    }
    
    Context "Pipeline Support" {
        It "Should accept host ID from pipeline by value" {
            $result = 1 | Get-FleetHost
            
            $result.id | Should -Be 1
            $result.hostname | Should -Be "test-host-1"
        }
        
        It "Should accept multiple host IDs from pipeline" {
            $result = @(1, 2) | Get-FleetHost
            
            $result | Should -HaveCount 2
            $result[0].id | Should -Be 1
            $result[1].id | Should -Be 2
        }
        
        It "Should accept host objects with ID property from pipeline" {
            $hostObjects = @(
                [PSCustomObject]@{ Id = 1; Name = "Host1" },
                [PSCustomObject]@{ Id = 2; Name = "Host2" }
            )
            
            $result = $hostObjects | Get-FleetHost
            
            $result | Should -HaveCount 2
            $result[0].id | Should -Be 1
            $result[1].id | Should -Be 2
        }
    }
    
    Context "Error Handling" {
        It "Should handle API errors gracefully" {
            Mock Invoke-FleetDMRequest { throw "API Error: Unauthorized" } -ModuleName FleetDM-PowerShell
            
            { Get-FleetHost } | Should -Throw "*API Error: Unauthorized*"
        }
        
        It "Should handle network errors gracefully" {
            Mock Invoke-FleetDMRequest { throw "Network timeout" } -ModuleName FleetDM-PowerShell
            
            { Get-FleetHost -Id 1 } | Should -Throw "*Network timeout*"
        }
    }
    
    Context "Type Name Assignment" {
        It "Should assign FleetDM.Host type to all returned hosts" {
            $result = Get-FleetHost
            
            $result | ForEach-Object {
                $_.PSObject.TypeNames | Should -Contain 'FleetDM.Host'
            }
        }
        
        It "Should assign type name to single host result" {
            $result = Get-FleetHost -Id 1
            
            $result.PSObject.TypeNames[0] | Should -Be 'FleetDM.Host'
        }
    }
    
    Context "Query Parameter Construction" {
        It "Should construct correct query parameters for complex filter" {
            Get-FleetHost -Status "online" -Hostname "test" -IncludeSoftware -IncludePolicies
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $QueryParameters.status -eq "online" -and
                $QueryParameters.query -eq "test" -and
                $QueryParameters.populate_software -eq 'true' -and
                $QueryParameters.populate_policies -eq 'true'
            }
        }
        
        It "Should omit empty query parameters" {
            Get-FleetHost
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                # Check that basic query parameters are set but filter parameters are not
                $QueryParameters.order_key -eq 'hostname' -and
                $QueryParameters.order_direction -eq 'asc' -and
                $QueryParameters.per_page -eq 100
            }
        }
    }
}