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
    
    # Mock test data
    $script:MockQueries = @(
        @{
            id = 1
            name = "System Info Query"
            description = "Get basic system information"
            query = "SELECT hostname, version FROM system_info;"
            author_name = "Admin"
            created_at = "2023-01-01T00:00:00Z"
            updated_at = "2023-01-01T00:00:00Z"
            observer_can_run = $true
            platform = ""
            stats = @{
                total_executions = 25
                system_time_p50 = 125.5
                system_time_p95 = 250.0
                user_time_p50 = 75.2
                user_time_p95 = 150.4
            }
        },
        @{
            id = 2
            name = "Running Processes"
            description = "List all running processes"
            query = "SELECT name, pid, cmdline FROM processes WHERE state = 'R';"
            author_name = "SecurityTeam"
            created_at = "2023-01-02T00:00:00Z"
            updated_at = "2023-01-02T00:00:00Z"
            observer_can_run = $false
            platform = "linux"
            stats = @{
                total_executions = 10
                system_time_p50 = 500.0
                system_time_p95 = 1000.0
                user_time_p50 = 200.0
                user_time_p95 = 400.0
            }
        }
    )
    
    # Mock Invoke-FleetDMRequest function
    Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
        param($Endpoint, $Method, $QueryParameters)
        
        if ($Endpoint -match "queries/(\d+)") {
            $queryId = [int]$matches[1]
            $query = $script:MockQueries | Where-Object { $_.id -eq $queryId }
            if ($query) {
                # Return the query wrapped in a query property as the API does
                return @{
                    query = [PSCustomObject]$query
                }
            }
            else {
                throw "Query not found"
            }
        }
        elseif ($Endpoint -eq "queries") {
            $filteredQueries = $script:MockQueries
            
            # Apply filters based on query parameters
            # Note: Name filtering is done client-side in Get-FleetQuery, not via API
            if ($QueryParameters) {
                if ($QueryParameters.team_id) {
                    # Mock team filtering (though our test data doesn't have team_id)
                    # In real API, this would filter by team
                }
            }
            
            # Check if pagination is being used (Page parameter is present)
            # When Page is specified, Get-FleetQuery expects response.queries
            # When Page is not specified (FollowPagination), it expects just the array
            if ($QueryParameters -and $QueryParameters.ContainsKey('page')) {
                # Return wrapped response for pagination
                return @{
                    queries = $filteredQueries | ForEach-Object { [PSCustomObject]$_ }
                }
            }
            else {
                # Return just the array for FollowPagination
                return $filteredQueries | ForEach-Object { [PSCustomObject]$_ }
            }
        }
        else {
            throw "Unexpected endpoint: $Endpoint"
        }
    }
}

Describe "Get-FleetQuery" -Tags @('Unit', 'Queries') {
    Context "Single Query Retrieval" {
        It "Should retrieve a specific query by ID" {
            $result = Get-FleetQuery -Id 1
            
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.TypeNames | Should -Contain 'FleetDM.Query'
            $result.id | Should -Be 1
            $result.name | Should -Be "System Info Query"
            $result.description | Should -Be "Get basic system information"
            $result.query | Should -Be "SELECT hostname, version FROM system_info;"
        }
        
        It "Should handle non-existent query ID" {
            { Get-FleetQuery -Id 999 } | Should -Throw "*Query not found*"
        }
        
        It "Should add custom type name to single query result" {
            $result = Get-FleetQuery -Id 1
            
            $result.PSObject.TypeNames[0] | Should -Be 'FleetDM.Query'
        }
        
        It "Should include query statistics" {
            $result = Get-FleetQuery -Id 1
            
            $result.stats | Should -Not -BeNullOrEmpty
            $result.stats.total_executions | Should -Be 25
            $result.stats.system_time_p50 | Should -Be 125.5
            $result.stats.system_time_p95 | Should -Be 250.0
        }
    }
    
    Context "Multiple Query Retrieval" {
        It "Should retrieve all queries when no parameters provided" {
            $result = Get-FleetQuery
            
            $result | Should -HaveCount 2
            $result[0].PSObject.TypeNames | Should -Contain 'FleetDM.Query'
            $result[1].PSObject.TypeNames | Should -Contain 'FleetDM.Query'
        }
        
        It "Should filter queries by name pattern" {
            $result = Get-FleetQuery -Name "System*"
            
            $result | Should -HaveCount 1
            $result.name | Should -Be "System Info Query"
        }
        
    }
    
    Context "Parameter Handling" {
        
        It "Should accept valid Page and PerPage values" {
            { Get-FleetQuery -Page 0 -PerPage 50 } | Should -Not -Throw
            { Get-FleetQuery -PerPage 500 } | Should -Not -Throw
            { Get-FleetQuery -PerPage 501 } | Should -Throw "*Cannot validate argument on parameter 'PerPage'*"
        }
        
        It "Should support wildcard patterns in name parameter" {
            # Name filtering is done client-side, not passed as query parameter
            Get-FleetQuery -Name "System*" | Out-Null
            
            # Should still call the API without the name in query parameters
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1
        }
    }
    
    Context "Pipeline Support" {
        It "Should accept query ID from pipeline by value" {
            $result = 1 | Get-FleetQuery
            
            $result.id | Should -Be 1
            $result.name | Should -Be "System Info Query"
        }
        
        It "Should accept multiple query IDs from pipeline" {
            $result = @(1, 2) | Get-FleetQuery
            
            $result | Should -HaveCount 2
            $result[0].id | Should -Be 1
            $result[1].id | Should -Be 2
        }
        
        It "Should accept query objects with ID property from pipeline" {
            $queryObjects = @(
                [PSCustomObject]@{ Id = 1; Name = "Query1" },
                [PSCustomObject]@{ Id = 2; Name = "Query2" }
            )
            
            $result = $queryObjects | Get-FleetQuery
            
            $result | Should -HaveCount 2
            $result[0].id | Should -Be 1
            $result[1].id | Should -Be 2
        }
    }
    
    Context "Query Properties" {
        It "Should include all expected query properties" {
            $result = Get-FleetQuery -Id 1
            
            $result.id | Should -Not -BeNullOrEmpty
            $result.name | Should -Not -BeNullOrEmpty
            $result.description | Should -Not -BeNullOrEmpty
            $result.query | Should -Not -BeNullOrEmpty
            $result.author_name | Should -Not -BeNullOrEmpty
            $result.created_at | Should -Not -BeNullOrEmpty
            $result.updated_at | Should -Not -BeNullOrEmpty
            $result.observer_can_run | Should -BeOfType [bool]
            $result.platform | Should -BeOfType [string]
        }
        
        It "Should include performance statistics" {
            $result = Get-FleetQuery -Id 2
            
            $result.stats | Should -Not -BeNullOrEmpty
            $result.stats.total_executions | Should -BeOfType [int]
            $result.stats.system_time_p50 | Should -BeOfType [double]
            $result.stats.system_time_p95 | Should -BeOfType [double]
            $result.stats.user_time_p50 | Should -BeOfType [double]
            $result.stats.user_time_p95 | Should -BeOfType [double]
        }
    }
    
    Context "Error Handling" {
        It "Should handle API errors gracefully" {
            Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell { throw "API Error: Unauthorized" }
            
            { Get-FleetQuery } | Should -Throw "*API Error: Unauthorized*"
        }
        
        It "Should handle network errors gracefully" {
            Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell { throw "Network timeout" }
            
            { Get-FleetQuery -Id 1 } | Should -Throw "*Network timeout*"
        }
    }
    
    Context "Type Name Assignment" {
        It "Should assign FleetDM.Query type to all returned queries" {
            $result = Get-FleetQuery
            
            $result | ForEach-Object {
                $_.PSObject.TypeNames | Should -Contain 'FleetDM.Query'
            }
        }
        
        It "Should assign type name to single query result" {
            $result = Get-FleetQuery -Id 1
            
            $result.PSObject.TypeNames[0] | Should -Be 'FleetDM.Query'
        }
    }
    
    Context "Query Parameter Construction" {
        It "Should construct correct query parameters for pagination" {
            Get-FleetQuery -Page 2 -PerPage 50
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $QueryParameters.page -eq 2 -and
                $QueryParameters.per_page -eq 50
            }
        }
        
        It "Should use default per_page when no pagination params provided" {
            Get-FleetQuery -Name "verbose"
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $QueryParameters.per_page -eq 100
            }
        }
        
        It "Should not pass name filter to API (client-side filtering)" {
            Get-FleetQuery -Name "test*"
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                -not $QueryParameters.ContainsKey('name') -and
                -not $QueryParameters.ContainsKey('query')
            }
        }
        
        It "Should include default per_page parameter" {
            Get-FleetQuery
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $QueryParameters.per_page -eq 100
            }
        }
    }
}