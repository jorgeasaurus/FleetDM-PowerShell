BeforeAll {
    # Import the module
    $modulePath = Join-Path $PSScriptRoot '../FleetDM-PowerShell.psd1'
    Import-Module $modulePath -Force
    
    # Mock connection - set in module scope
    InModuleScope FleetDM-PowerShell {
        $script:FleetDMConnection = @{
            BaseUri = "https://test.fleetdm.example.com"
            Headers = @{ 'Authorization' = 'Bearer test-token' }
            Version = "4.0.0"
        }
    }
    
    # Mock test data
    $script:MockCampaignResponse = @{
        campaign = @{
            id = 123
            query_id = 1
            status = "running"
            created_at = "2024-01-01T00:00:00Z"
        }
    }
    
    $script:MockQueryResults = @{
        campaign = @{
            id = 123
            query_id = 1
            status = "finished"
        }
        results = @(
            @{
                host_id = 1
                host_name = "test-host-1"
                rows = @(
                    @{
                        hostname = "test-host-1"
                        version = "10.15.7"
                        platform = "darwin"
                    }
                )
            },
            @{
                host_id = 2
                host_name = "test-host-2"
                rows = @(
                    @{
                        hostname = "test-host-2"
                        version = "20.04"
                        platform = "ubuntu"
                    }
                )
            }
        )
    }
    
    # Mock Invoke-FleetDMRequest function
    Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
        param($Endpoint, $Method, $Body)
        
        if ($Endpoint -eq "queries/run" -and $Method -eq "POST") {
            return [PSCustomObject]$script:MockCampaignResponse
        }
        elseif ($Endpoint -like "queries/run/*") {
            # Return results for campaign endpoint
            return [PSCustomObject]$script:MockQueryResults
        }
        elseif ($Endpoint -eq "queries" -and $Method -eq "POST") {
            # Creating temporary query - the Body parameter comes as a hashtable from Invoke-FleetQuery
            $queryText = if ($Body -is [hashtable]) { $Body.query } else { $Body }
            return [PSCustomObject]@{
                query = @{
                    id = 999
                    name = "temp_query"
                    query = $queryText
                }
            }
        }
        elseif ($Endpoint -like "queries/*" -and $Method -eq "DELETE") {
            # Deleting temporary query
            return $null
        }
        else {
            return [PSCustomObject]@{ success = $true }
        }
    }
    
    # Mock Invoke-FleetSavedQuery function
    Mock Invoke-FleetSavedQuery -ModuleName FleetDM-PowerShell {
        param($QueryId, $HostId, $TimeoutSeconds)
        return [PSCustomObject]$script:MockQueryResults
    }
}

Describe "Invoke-FleetQuery" -Tags @('Unit', 'Queries') {
    Context "Parameter Validation" {
        It "Should require at least one target (HostId, Label, or All)" {
            # The function requires at least one target to be specified
            { Invoke-FleetQuery -Query "SELECT 1;" -ErrorAction Stop } | Should -Throw "*You must specify at least one target*"
        }
        
        It "Should not allow both Query and QueryId parameters" {
            # Both parameters are in different parameter sets, so this should fail
            { Invoke-FleetQuery -Query "SELECT 1;" -QueryId 1 -HostId 1 -ErrorAction Stop } | Should -Throw
        }
        
        It "Should validate QueryId range" {
            { Invoke-FleetQuery -QueryId 0 -HostId 1 -ErrorAction Stop } | Should -Throw "*Cannot validate argument*"
        }
        
        
        It "Should validate MaxWaitTime range" {
            { Invoke-FleetQuery -Query "SELECT 1;" -HostId 1 -MaxWaitTime 301 -ErrorAction Stop } | Should -Throw "*Cannot validate argument*"
        }
    }
    
    Context "Ad-hoc Query Execution" {
        It "Should execute ad-hoc query on specific hosts" {
            # Ad-hoc queries with host IDs use the temporary query approach
            Mock Invoke-FleetSavedQuery -ModuleName FleetDM-PowerShell {
                return [PSCustomObject]$script:MockQueryResults
            }
            
            $result = Invoke-FleetQuery -Query "SELECT * FROM system_info;" -HostId 1,2
            
            $result | Should -Not -BeNullOrEmpty
            
            # Should create a temporary query
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
                $Endpoint -eq "queries" -and $Method -eq "POST"
            }
        }
        
        It "Should handle single host ID" {
            $result = Invoke-FleetQuery -Query "SELECT 1;" -HostId 1
            
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Should accept host IDs from pipeline" {
            Mock Invoke-FleetSavedQuery -ModuleName FleetDM-PowerShell {
                return [PSCustomObject]$script:MockQueryResults
            }
            
            $result = @(1, 2, 3) | Invoke-FleetQuery -Query "SELECT 1;"
            
            $result | Should -Not -BeNullOrEmpty
            
            # Should create a temporary query and then call Invoke-FleetSavedQuery
            Should -Invoke Invoke-FleetSavedQuery -ModuleName FleetDM-PowerShell -ParameterFilter {
                $HostId -contains 1 -and
                $HostId -contains 2 -and
                $HostId -contains 3
            }
        }
        
        It "Should accept host objects from pipeline" {
            $hosts = @(
                [PSCustomObject]@{ Id = 1; hostname = "host1" },
                [PSCustomObject]@{ Id = 2; hostname = "host2" }
            )
            
            $result = $hosts | Invoke-FleetQuery -Query "SELECT 1;"
            
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Saved Query Execution" {
        It "Should execute saved query by ID" {
            $result = Invoke-FleetQuery -QueryId 42 -HostId 1,2
            
            $result | Should -Not -BeNullOrEmpty
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
                $Body.query_id -eq 42
            }
        }
        
        It "Should use direct result endpoint when Wait is specified" {
            $result = Invoke-FleetQuery -QueryId 42 -HostId 1,2 -Wait
            
            $result | Should -Not -BeNullOrEmpty
            
            Should -Invoke Invoke-FleetSavedQuery -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
                $QueryId -eq 42 -and $HostId -contains 1 -and $HostId -contains 2
            }
        }
    }
    
    Context "Query Targeting" {
        It "Should support label-based queries" {
            $result = Invoke-FleetQuery -Query "SELECT 1;" -Label "production", "linux"
            
            $result | Should -Not -BeNullOrEmpty
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
                $Body.selected.labels -contains "production" -and
                $Body.selected.labels -contains "linux"
            }
        }
        
        It "Should combine different target types" {
            $result = Invoke-FleetQuery -Query "SELECT 1;" -HostId 1 -Label "test"
            
            $result | Should -Not -BeNullOrEmpty
            
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
                $Body.selected.hosts -contains 1 -and
                $Body.selected.labels -contains "test"
            }
        }
        
        It "Should require at least one target" {
            # The function now throws when no targets are specified
            { Invoke-FleetQuery -Query "SELECT 1;" } | 
                Should -Throw "*must specify at least one target*"
        }
    }
    
    Context "Wait Functionality" {
        It "Should wait for results when -Wait is specified" {
            # Mock Invoke-FleetSavedQuery since Wait with HostIds uses temporary query approach
            Mock Invoke-FleetSavedQuery -ModuleName FleetDM-PowerShell {
                return [PSCustomObject]$script:MockQueryResults
            }
            
            $result = Invoke-FleetQuery -Query "SELECT 1;" -HostId 1 -Wait -MaxWaitTime 5
            
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Should handle wait with label-based queries" {
            # When using labels, it falls back to campaign approach
            Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
                param($Endpoint)
                
                if ($Endpoint -like "queries/run/*") {
                    return [PSCustomObject]@{
                        campaign = @{ id = 123; status = "finished" }
                        results = @()
                    }
                }
                return [PSCustomObject]$script:MockCampaignResponse
            }
            
            $result = Invoke-FleetQuery -Query "SELECT 1;" -Label "test" -Wait -MaxWaitTime 2
            
            # Should return campaign info
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Error Handling" {
        It "Should handle query execution errors" {
            Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
                throw "Query execution failed"
            }
            
            { Invoke-FleetQuery -Query "SELECT 1;" -HostId 1 } | 
                Should -Throw "*Query execution failed*"
        }
        
        It "Should handle invalid SQL queries" {
            Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
                throw "Invalid SQL syntax"
            }
            
            { Invoke-FleetQuery -Query "INVALID SQL" -HostId 1 } | 
                Should -Throw "*Invalid SQL*"
        }
        
        It "Should handle missing campaign ID in response" {
            Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
                param($Endpoint, $Method)
                if ($Endpoint -eq "queries" -and $Method -eq "POST") {
                    # Return a valid temp query response
                    return [PSCustomObject]@{
                        query = @{
                            id = 999
                            name = "temp_query"
                        }
                    }
                }
                return [PSCustomObject]@{ campaign = @{} }
            }
            
            Mock Invoke-FleetSavedQuery -ModuleName FleetDM-PowerShell {
                return [PSCustomObject]@{ campaign = @{} }
            }
            
            $result = Invoke-FleetQuery -Query "SELECT 1;" -HostId 1
            
            # Should return result even without full data
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Type Tagging" {
        It "Should add FleetDM.QueryExecution type to campaign results" {
            # Use Label to force campaign approach instead of temporary query
            $result = Invoke-FleetQuery -Query "SELECT 1;" -Label "test"
            
            $result.PSObject.TypeNames | Should -Contain 'FleetDM.QueryExecution'
        }
    }
    
    Context "Verbose Output" {
        It "Should provide verbose information when requested" {
            # Mock to return results from Invoke-FleetSavedQuery for ad-hoc queries with host IDs
            Mock Invoke-FleetSavedQuery -ModuleName FleetDM-PowerShell {
                return [PSCustomObject]$script:MockQueryResults
            }
            
            $verboseOutput = Invoke-FleetQuery -Query "SELECT 1;" -HostId 1 -Verbose 4>&1 | 
                Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
            
            $verboseOutput | Should -Not -BeNullOrEmpty
            $verboseMessages = $verboseOutput | ForEach-Object { $_.ToString() }
            # The function creates a temporary query for ad-hoc queries with host IDs
            $verboseMessages -join ' ' | Should -BeLike "*temporary query*"
        }
    }
}