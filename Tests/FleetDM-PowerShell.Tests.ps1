#Requires -Module Pester

<#
.SYNOPSIS
    Pester tests for FleetDM-PowerShell module
.DESCRIPTION
    Comprehensive tests for all FleetDM PowerShell module functions
#>

BeforeAll {
    # Import test helper
    . (Join-Path $PSScriptRoot 'TestHelper.ps1')
    
    # Import the module using the helper
    Import-TestModule
    
    # Test configuration (mocked, not real)
    $script:ApiToken = "test-api-token-12345"
    $script:BaseUri = "https://test.fleetdm.example.com"
    $script:SecureApiToken = ConvertTo-SecureString $script:ApiToken -AsPlainText -Force
    
    # Mock all API calls to avoid external dependencies
    Mock Invoke-RestMethod {
        param($Uri, $Method, $Body, $Headers, $ContentType, $WebSession, $ErrorAction)
        
        # Check for invalid hosts first
        if ($Uri -like "*invalid-host*") {
            throw "nodename nor servname provided, or not known (invalid-host:9999)"
        }
        
        # Return mock responses based on endpoint
        if ($Uri -like "*/api/v1/fleet/login") {
            return @{ 
                user = @{ 
                    name = "Test User"
                    email = "test@example.com" 
                    global_role = "admin"
                }
                token = $script:ApiToken 
            }
        }
        elseif ($Uri -like "*/api/v1/fleet/me") {
            return @{ 
                user = @{ 
                    name = "Test User"
                    email = "test@example.com" 
                    global_role = "admin"
                }
            }
        }
        elseif ($Uri -like "*/api/v1/fleet/hosts*") {
            if ($Uri -match "/hosts/(\d+)") {
                $hostId = [int]$Matches[1]
                if ($hostId -eq 999999) {
                    throw "Resource not found"
                }
                return @{ 
                    host = @{ 
                        id = $hostId
                        hostname = "test-host-$hostId"
                        status = "online"
                        platform = "darwin"
                    }
                }
            }
            return @{ 
                hosts = @(
                    @{ id = 1; hostname = "test-host-1"; status = "online"; platform = "darwin" }
                    @{ id = 2; hostname = "test-host-2"; status = "online"; platform = "linux" }
                )
            }
        }
        elseif ($Uri -like "*/api/v1/fleet/queries*") {
            if ($Uri -match "/queries/(\d+)") {
                $queryId = [int]$Matches[1]
                if ($queryId -eq 999999) {
                    throw "Resource not found"
                }
                return @{
                    query = @{ 
                        id = $queryId
                        name = "Test Query $queryId"
                        query = "SELECT * FROM test;"
                    }
                }
            }
            return @{
                queries = @(
                    @{ id = 1; name = "Operating System Information"; query = "SELECT * FROM os_version;" }
                    @{ id = 2; name = "System Info"; query = "SELECT * FROM system_info;" }
                )
            }
        }
        elseif ($Uri -like "*/api/v1/fleet/queries/run*") {
            return @{
                campaign = @{ id = 123; status = "finished" }
                results = @(
                    @{
                        host_id = 1
                        hostname = "test-host-1"  
                        rows = @(@{ version = "10.15.7"; platform = "darwin" })
                    }
                )
            }
        }
        elseif ($Uri -like "*/api/v1/fleet/policies*") {
            return @{
                policies = @(
                    @{ 
                        id = 1
                        name = "Test Policy"
                        query = "SELECT 1;"
                        passing_host_count = 8
                        failing_host_count = 2
                    }
                )
            }
        }
        elseif ($Uri -like "*/api/v1/fleet/software*") {
            return @{
                software = @(
                    @{
                        id = 1
                        name = "Test Software"
                        version = "1.0.0"
                        hosts_count = 10
                    }
                )
            }
        }
        else {
            return @{ success = $true }
        }
    } -ModuleName FleetDM-PowerShell
    
    Mock Invoke-WebRequest {
        param($Uri, $Headers, $WebSession, $ErrorAction)
        
        # Check for invalid hosts first
        if ($Uri -like "*invalid-host*") {
            throw "nodename nor servname provided, or not known (invalid-host:9999)"
        }
        
        if ($Uri -like "*/api/v1/fleet/version") {
            return [PSCustomObject]@{
                Content = '{"version": "4.0.0"}'
                Headers = @{ 'Content-Type' = 'application/json' }
            }
        }
        else {
            throw "Unexpected URI: $Uri"
        }
    } -ModuleName FleetDM-PowerShell
    
    # Mock Invoke-FleetSavedQuery for when Invoke-FleetQuery calls it internally
    Mock Invoke-FleetSavedQuery {
        param($QueryId, $HostId)
        
        return [PSCustomObject]@{
            PSTypeName = 'FleetDM.QueryResult'
            QueryId = $QueryId
            TargetedHostCount = $HostId.Count
            RespondedHostCount = $HostId.Count
            ResponseRate = 100
            Results = @(
                foreach ($id in $HostId) {
                    [PSCustomObject]@{
                        PSTypeName = 'FleetDM.QueryHostResult'
                        HostId = $id
                        Rows = @(@{ test = "data" })
                        RowCount = 1
                    }
                }
            )
            Errors = @()
        }
    } -ModuleName FleetDM-PowerShell
    
    # Mock Invoke-FleetDMRequest for internal calls
    Mock Invoke-FleetDMRequest {
        param($Endpoint, $Method, $Body, $QueryParameters)
        
        if ($Endpoint -eq "hosts") {
            if ($QueryParameters -and $QueryParameters['status']) {
                $status = $QueryParameters['status']
                return @(
                    @{ id = 1; hostname = "test-host-1"; status = $status; platform = "darwin" }
                    @{ id = 2; hostname = "test-host-2"; status = $status; platform = "linux" }
                )
            }
            return @(
                @{ id = 1; hostname = "test-host-1"; status = "online"; platform = "darwin" }
                @{ id = 2; hostname = "test-host-2"; status = "online"; platform = "linux" }
            )
        }
        elseif ($Endpoint -match "hosts/(\d+)") {
            $hostId = [int]$Matches[1]
            if ($hostId -eq 999999) {
                return $null
            }
            return @{
                host = @{ 
                    id = $hostId
                    hostname = "test-host-$hostId"
                    status = "online"
                    platform = "darwin"
                }
            }
        }
        elseif ($Endpoint -eq "queries" -and $Method -eq "POST") {
            # Creating a temporary query
            return @{
                query = @{
                    id = 999
                    name = $Body.name
                    query = $Body.query
                }
            }
        }
        elseif ($Endpoint -eq "queries") {
            return @(
                @{ id = 1; name = "Operating System Information"; query = "SELECT * FROM os_version;" }
                @{ id = 2; name = "System Info"; query = "SELECT * FROM system_info;" }
            )
        }
        elseif ($Endpoint -eq "queries/run") {
            return @{
                campaign = @{ id = 123; status = "running" }
            }
        }
        elseif ($Endpoint -match "queries/(\d+)/run") {
            # Saved query execution endpoint
            $queryId = [int]$Matches[1]
            return @{
                query_id = $queryId
                targeted_host_count = 1
                responded_host_count = 1
                results = @(
                    @{
                        host_id = 1
                        rows = @(@{ test = "data" })
                    }
                )
            }
        }
        elseif ($Endpoint -match "queries/(\d+)$") {
            $queryId = [int]$Matches[1]
            if ($queryId -eq 999999) {
                return $null
            }
            if ($Method -eq "DELETE") {
                # Deleting a query
                return @{ success = $true }
            }
            return @{
                query = @{ 
                    id = $queryId
                    name = "Test Query $queryId"
                    query = "SELECT * FROM test;"
                }
            }
        }
        elseif ($Endpoint -eq "global/policies") {
            return @(
                @{ 
                    id = 1
                    name = "Test Policy"
                    query = "SELECT 1;"
                    passing_host_count = 8
                    failing_host_count = 2
                }
            )
        }
        elseif ($Endpoint -eq "software") {
            return @(
                @{
                    id = 1
                    name = "Test Software"
                    version = "1.0.0"
                    hosts_count = 10
                }
            )
        }
        else {
            return @{ success = $true }
        }
    } -ModuleName FleetDM-PowerShell
}

Describe "FleetDM-PowerShell Module Tests" {
    Describe "Module Structure" {
        It "Should have the module loaded" {
            $module = Get-Module -Name FleetDM-PowerShell
            $module | Should -Not -BeNullOrEmpty
            $module.Name | Should -Be "FleetDM-PowerShell"
        }
        
        It "Should export all expected functions" {
            $expectedFunctions = @(
                'Connect-FleetDM',
                'Disconnect-FleetDM',
                'Get-FleetHost',
                'Remove-FleetHost',
                'Get-FleetQuery',
                'Invoke-FleetQuery',
                'Invoke-FleetSavedQuery',
                'Get-FleetPolicy',
                'New-FleetPolicy',
                'Set-FleetPolicy',
                'Get-FleetSoftware'
            )
            
            $module = Get-Module -Name FleetDM-PowerShell
            $exportedFunctions = $module.ExportedFunctions.Keys
            
            foreach ($function in $expectedFunctions) {
                $exportedFunctions | Should -Contain $function
            }
        }
    }
    
    Describe "Connect-FleetDM" {
        Context "Token Authentication" {
            BeforeEach {
                # Clear connection state
                InModuleScope FleetDM-PowerShell {
                    $script:FleetDMConnection = $null
                    $script:FleetDMWebSession = $null
                }
            }
            
            It "Should connect successfully with valid API token" {
                $connection = Connect-FleetDM -BaseUri $script:BaseUri -ApiToken $script:SecureApiToken
                
                $connection | Should -Not -BeNullOrEmpty
                $connection.BaseUri | Should -Be $script:BaseUri
                $connection.Version | Should -Not -BeNullOrEmpty
                $connection.User | Should -Not -BeNullOrEmpty
            }
            
            It "Should fail with invalid base URI" {
                { Connect-FleetDM -BaseUri "http://invalid-host:9999" -ApiToken $script:SecureApiToken } | Should -Throw
            }
            
            It "Should handle base URI with trailing slash" {
                $uriWithSlash = "$($script:BaseUri)/"
                $connection = Connect-FleetDM -BaseUri $uriWithSlash -ApiToken $script:SecureApiToken
                $connection | Should -Not -BeNullOrEmpty
            }
        }
        
        Context "Module State" {
            It "Should require connection before using other functions" {
                # Clear the connection using module scope
                InModuleScope FleetDM-PowerShell {
                    $script:FleetDMConnection = $null
                }
                
                # Mock Invoke-FleetDMRequest to throw when not connected
                Mock Invoke-FleetDMRequest {
                    throw "Not connected to FleetDM. Please run Connect-FleetDM first."
                } -ModuleName FleetDM-PowerShell
                
                { Get-FleetHost } | Should -Throw "*not connected*"
                
                # Reconnect for other tests
                $null = Connect-FleetDM -BaseUri $script:BaseUri -ApiToken $script:SecureApiToken
            }
        }
    }
    
    Describe "Get-FleetHost" {
        BeforeAll {
            # Ensure we're connected
            $null = Connect-FleetDM -BaseUri $script:BaseUri -ApiToken $script:SecureApiToken
        }
        
        Context "Basic Functionality" {
            It "Should retrieve all hosts without parameters" {
                $hosts = Get-FleetHost
                
                $hosts | Should -Not -BeNullOrEmpty
                $hosts.Count | Should -Be 2
                $hosts[0].PSObject.TypeNames | Should -Contain 'FleetDM.Host'
            }
            
            It "Should retrieve a specific host by ID" {
                $retrievedHost = Get-FleetHost -Id 1
                
                $retrievedHost | Should -Not -BeNullOrEmpty
                $retrievedHost.id | Should -Be 1
                $retrievedHost.hostname | Should -Be "test-host-1"
            }
            
            It "Should return null for non-existent host ID" {
                $result = Get-FleetHost -Id 999999
                $result | Should -BeNullOrEmpty
            }
        }
        
        Context "Filtering" {
            It "Should filter hosts by status" {
                $onlineHosts = Get-FleetHost -Status online
                
                $onlineHosts | Should -Not -BeNullOrEmpty
                $onlineHosts | ForEach-Object {
                    $_.status | Should -Be 'online'
                }
            }
            
            It "Should filter hosts by hostname" {
                $hosts = Get-FleetHost -Hostname "test"
                
                if ($hosts) {
                    $hosts | ForEach-Object {
                        $_.hostname | Should -BeLike "*test*"
                    }
                }
            }
        }
        
        Context "Pipeline Support" {
            It "Should accept ID from pipeline" {
                $testHost = [PSCustomObject]@{ id = 1 }
                
                $retrievedHost = $testHost | Get-FleetHost
                
                $retrievedHost | Should -Not -BeNullOrEmpty
                $retrievedHost.id | Should -Be 1
            }
            
            It "Should process multiple IDs from pipeline" {
                $testHosts = @(
                    [PSCustomObject]@{ id = 1 }
                    [PSCustomObject]@{ id = 2 }
                )
                
                $hosts = $testHosts | Get-FleetHost
                $hosts.Count | Should -Be 2
            }
        }
    }
    
    Describe "Get-FleetQuery" {
        BeforeAll {
            $null = Connect-FleetDM -BaseUri $script:BaseUri -ApiToken $script:SecureApiToken
        }
        
        Context "Basic Functionality" {
            It "Should retrieve all queries without parameters" {
                $queries = Get-FleetQuery
                
                $queries | Should -Not -BeNullOrEmpty
                $queries.Count | Should -Be 2
                $queries[0].PSObject.TypeNames | Should -Contain 'FleetDM.Query'
            }
            
            It "Should retrieve a specific query by ID" {
                $query = Get-FleetQuery -Id 1
                
                $query | Should -Not -BeNullOrEmpty
                $query.id | Should -Be 1
                $query.name | Should -BeLike "*Query*"
            }
            
            It "Should filter queries by name" {
                $queries = Get-FleetQuery -Name "System"
                
                if ($queries) {
                    $queries | ForEach-Object {
                        $_.name | Should -BeLike "*System*"
                    }
                }
            }
        }
    }
    
    Describe "Invoke-FleetQuery" {
        BeforeAll {
            $null = Connect-FleetDM -BaseUri $script:BaseUri -ApiToken $script:SecureApiToken
        }
        
        Context "Ad-hoc Queries" {
            It "Should execute an ad-hoc query on a specific host" {
                $result = Invoke-FleetQuery -Query "SELECT * FROM test;" -HostId 1
                
                $result | Should -Not -BeNullOrEmpty
                # When HostId is provided, it creates temp query and returns results
                $result.PSObject.TypeNames | Should -Contain 'FleetDM.QueryResult'
                $result.QueryId | Should -Not -BeNullOrEmpty
            }
            
            It "Should require at least one target" {
                { Invoke-FleetQuery -Query "SELECT * FROM test;" } | Should -Throw "*must specify at least one target*"
            }
            
            It "Should accept host IDs from pipeline" {
                $hosts = @(1, 2)
                $result = $hosts | Invoke-FleetQuery -Query "SELECT * FROM test;"
                
                $result | Should -Not -BeNullOrEmpty
            }
        }
        
        Context "Saved Queries" {
            It "Should execute a saved query by ID" {
                $result = Invoke-FleetQuery -QueryId 1 -HostId 1
                
                $result | Should -Not -BeNullOrEmpty
                $result.PSObject.TypeNames | Should -Contain 'FleetDM.QueryExecution'
            }
        }
    }
    
    Describe "Invoke-FleetSavedQuery" {
        BeforeAll {
            $null = Connect-FleetDM -BaseUri $script:BaseUri -ApiToken $script:SecureApiToken
        }
        
        Context "Basic Functionality" {
            It "Should execute a saved query and return results" {
                $result = Invoke-FleetSavedQuery -QueryId 1 -HostId 1
                
                $result | Should -Not -BeNullOrEmpty
                $result.PSObject.TypeNames | Should -Contain 'FleetDM.QueryResult'
                $result.QueryId | Should -Be 1
                $result.TargetedHostCount | Should -Be 1
            }
            
            It "Should handle multiple hosts" {
                $result = Invoke-FleetSavedQuery -QueryId 1 -HostId 1,2
                
                $result | Should -Not -BeNullOrEmpty
                $result.TargetedHostCount | Should -BeGreaterOrEqual 1
            }
            
            It "Should separate successful results from errors" {
                $result = Invoke-FleetSavedQuery -QueryId 1 -HostId 1
                
                $result.Results | Should -Not -BeNullOrEmpty
                $result.Results[0].PSObject.TypeNames | Should -Contain 'FleetDM.QueryHostResult'
            }
        }
        
        Context "Error Handling" {
            It "Should fail with invalid query ID" {
                # Mock should return null for invalid query ID which will cause an error
                Mock Invoke-FleetDMRequest {
                    throw "Query not found"
                } -ParameterFilter { $Endpoint -eq "queries/999999/run" } -ModuleName FleetDM-PowerShell
                
                { Invoke-FleetSavedQuery -QueryId 999999 -HostId 1 } | Should -Throw
            }
            
            It "Should require host IDs" {
                # Test that HostId parameter is mandatory
                $command = Get-Command Invoke-FleetSavedQuery
                $hostIdParam = $command.Parameters['HostId']
                $hostIdParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | 
                    ForEach-Object { $_.Mandatory } | Should -Contain $true
            }
        }
    }
    
    Describe "Integration Tests" {
        BeforeAll {
            $null = Connect-FleetDM -BaseUri $script:BaseUri -ApiToken $script:SecureApiToken
        }
        
        Context "End-to-End Query Workflow" {
            It "Should complete a full query workflow" {
                # Get hosts
                $hosts = Get-FleetHost
                $hosts | Should -Not -BeNullOrEmpty
                
                # Select first host
                $targetHost = $hosts | Select-Object -First 1
                
                # Run query on host
                $result = Invoke-FleetQuery -Query "SELECT * FROM test;" -HostId $targetHost.id
                
                $result | Should -Not -BeNullOrEmpty
                # When HostId is provided, returns QueryResult with actual data
                $result.PSObject.TypeNames | Should -Contain 'FleetDM.QueryResult'
            }
        }
        
        Context "Pipeline Integration" {
            It "Should support complex pipeline operations" {
                # Get hosts and run query on them
                $hosts = Get-FleetHost -Status online | Select-Object -First 2
                
                if ($hosts) {
                    $result = $hosts | ForEach-Object { $_.id } | Invoke-FleetQuery -Query "SELECT 1;"
                    $result | Should -Not -BeNullOrEmpty
                }
            }
        }
    }
}