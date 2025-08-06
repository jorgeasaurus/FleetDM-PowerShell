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
    $script:MockQueryResult = @{
        query_id = 5
        targeted_host_count = 2
        responded_host_count = 2
        results = @(
            @{
                host_id = 1
                host_name = "test-host-1"
                rows = @(
                    @{
                        hostname = "test-host-1"
                        version = "10.15.7"
                    }
                )
                error = $null
            },
            @{
                host_id = 2
                host_name = "test-host-2"
                rows = @(
                    @{
                        hostname = "test-host-2"
                        version = "20.04"
                    }
                )
                error = $null
            }
        )
    }
    
    $script:MockQueryResultWithErrors = @{
        query_id = 5
        targeted_host_count = 3
        responded_host_count = 2
        results = @(
            @{
                host_id = 1
                host_name = "test-host-1"
                rows = @(
                    @{
                        hostname = "test-host-1"
                        version = "10.15.7"
                    }
                )
                error = $null
            },
            @{
                host_id = 2
                host_name = "test-host-2"
                rows = @()
                error = "Query execution failed"
            },
            @{
                host_id = 3
                host_name = "test-host-3"
                rows = @()
                error = $null
            }
        )
    }
}

Describe "Invoke-FleetSavedQuery" -Tags @('Unit', 'Queries') {
    Context "Parameter Validation" {
        It "Should validate QueryId is mandatory" {
            # Get parameter metadata to verify mandatory status
            $command = Get-Command Invoke-FleetSavedQuery
            $param = $command.Parameters['QueryId']
            $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | 
                Select-Object -ExpandProperty Mandatory | Should -Be $true
        }
        
        It "Should validate HostId is mandatory" {
            # Get parameter metadata to verify mandatory status
            $command = Get-Command Invoke-FleetSavedQuery
            $param = $command.Parameters['HostId']
            $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | 
                Select-Object -ExpandProperty Mandatory | Should -Be $true
        }
        
        It "Should validate QueryId range" {
            { Invoke-FleetSavedQuery -QueryId 0 -HostId 1 -ErrorAction Stop } | Should -Throw "*Cannot validate argument*"
        }
        
    }
    
    Context "Query Execution" {
        It "Should execute saved query on specified hosts" {
            InModuleScope FleetDM-PowerShell -Parameters @{ MockData = $script:MockQueryResult } {
                param($MockData)
                
                Mock Invoke-FleetDMRequest {
                    param($Endpoint, $Method, $Body)
                    
                    if ($Endpoint -eq "queries/5/run" -and $Method -eq "POST") {
                        return [PSCustomObject]$MockData
                    }
                    throw "Unexpected endpoint: $Endpoint"
                }
                
                $result = Invoke-FleetSavedQuery -QueryId 5 -HostId 1,2
                
                $result | Should -Not -BeNullOrEmpty
                $result.QueryId | Should -Be 5
                $result.TargetedHostCount | Should -Be 2
                $result.RespondedHostCount | Should -Be 2
                $result.ResponseRate | Should -Be 100
                
                Should -Invoke Invoke-FleetDMRequest -Times 1 -ParameterFilter {
                    $Endpoint -eq "queries/5/run" -and
                    $Method -eq "POST" -and
                    $Body.host_ids -contains 1 -and
                    $Body.host_ids -contains 2
                }
            }
        }
        
        It "Should handle single host ID" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    param($Endpoint, $Method, $Body)
                    
                    if ($Endpoint -eq "queries/5/run" -and $Method -eq "POST") {
                        return [PSCustomObject]@{
                            query_id = 5
                            targeted_host_count = 1
                            responded_host_count = 1
                            results = @(
                                @{
                                    host_id = 1
                                    host_name = "test-host-1"
                                    rows = @(@{ hostname = "test-host-1" })
                                    error = $null
                                }
                            )
                        }
                    }
                    throw "Unexpected endpoint: $Endpoint"
                }
                
                $result = Invoke-FleetSavedQuery -QueryId 5 -HostId 1
                
                $result | Should -Not -BeNullOrEmpty
                $result.ResponseRate | Should -Be 100
                
                Should -Invoke Invoke-FleetDMRequest -Times 1 -ParameterFilter {
                    $Body.host_ids.Count -eq 1 -and $Body.host_ids[0] -eq 1
                }
            }
        }
        
        It "Should accept host IDs from pipeline" {
            InModuleScope FleetDM-PowerShell -Parameters @{ MockData = $script:MockQueryResult } {
                param($MockData)
                
                Mock Invoke-FleetDMRequest {
                    param($Endpoint, $Method, $Body)
                    
                    if ($Endpoint -like "queries/*/run" -and $Method -eq "POST") {
                        return [PSCustomObject]$MockData
                    }
                    throw "Unexpected endpoint: $Endpoint"
                }
                
                $result = @(1, 2, 3) | Invoke-FleetSavedQuery -QueryId 5
                
                $result | Should -Not -BeNullOrEmpty
                
                Should -Invoke Invoke-FleetDMRequest -Times 1 -ParameterFilter {
                    $Body.host_ids.Count -eq 3 -and
                    $Body.host_ids -contains 1 -and
                    $Body.host_ids -contains 2 -and
                    $Body.host_ids -contains 3
                }
            }
        }
        
        It "Should accept host objects from pipeline" {
            InModuleScope FleetDM-PowerShell -Parameters @{ MockData = $script:MockQueryResult } {
                param($MockData)
                
                Mock Invoke-FleetDMRequest {
                    param($Endpoint, $Method, $Body)
                    
                    if ($Endpoint -like "queries/*/run" -and $Method -eq "POST") {
                        return [PSCustomObject]$MockData
                    }
                    throw "Unexpected endpoint: $Endpoint"
                }
                
                $hosts = @(
                    [PSCustomObject]@{ Id = 1; hostname = "host1" },
                    [PSCustomObject]@{ Id = 2; hostname = "host2" }
                )
                
                $result = $hosts | Invoke-FleetSavedQuery -QueryId 5
                
                $result | Should -Not -BeNullOrEmpty
                
                Should -Invoke Invoke-FleetDMRequest -Times 1 -ParameterFilter {
                    $Body.host_ids.Count -eq 2 -and
                    $Body.host_ids -contains 1 -and
                    $Body.host_ids -contains 2
                }
            }
        }
    }
    
    Context "Result Processing" {
        It "Should format results correctly" {
            InModuleScope FleetDM-PowerShell -Parameters @{ MockData = $script:MockQueryResult } {
                param($MockData)
                
                Mock Invoke-FleetDMRequest {
                    return [PSCustomObject]$MockData
                }
                
                $result = Invoke-FleetSavedQuery -QueryId 5 -HostId 1,2
                
                $result.PSObject.TypeNames | Should -Contain 'FleetDM.QueryResult'
                $result.Results | Should -HaveCount 2
                $result.Results[0].HostId | Should -Be 1
                $result.Results[0].Rows | Should -Not -BeNullOrEmpty
                $result.Results[0].RowCount | Should -Be 1
            }
        }
        
        It "Should calculate response rate correctly" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    return [PSCustomObject]@{
                        query_id = 5
                        targeted_host_count = 10
                        responded_host_count = 7
                        results = @()
                    }
                }
                
                $result = Invoke-FleetSavedQuery -QueryId 5 -HostId 1
                
                $result.ResponseRate | Should -Be 70
            }
        }
        
        It "Should handle zero targeted hosts" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    return [PSCustomObject]@{
                        query_id = 5
                        targeted_host_count = 0
                        responded_host_count = 0
                        results = @()
                    }
                }
                
                $result = Invoke-FleetSavedQuery -QueryId 5 -HostId 1
                
                $result.ResponseRate | Should -Be 0
            }
        }
        
        It "Should separate errors from successful results" {
            InModuleScope FleetDM-PowerShell -Parameters @{ MockData = $script:MockQueryResultWithErrors } {
                param($MockData)
                
                Mock Invoke-FleetDMRequest {
                    return [PSCustomObject]$MockData
                }
                
                $result = Invoke-FleetSavedQuery -QueryId 5 -HostId 1,2,3
                
                $result.Results | Should -HaveCount 2  # Results without errors (host 1 and 3)
                $result.Results[0].HostId | Should -Be 1
                $result.Results[1].HostId | Should -Be 3
                $result.Errors | Should -HaveCount 1   # Only error results
                $result.Errors[0].HostId | Should -Be 2
                $result.Errors[0].Error | Should -Be "Query execution failed"
            }
        }
    }
    
    Context "Error Handling" {
        It "Should throw when no host IDs are provided" {
            InModuleScope FleetDM-PowerShell {
                { 
                    # Create empty pipeline input
                    $emptyArray = @()
                    $emptyArray | Invoke-FleetSavedQuery -QueryId 5
                } | Should -Throw "*No host IDs provided*"
            }
        }
        
        It "Should handle API errors" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    throw "API Error: Query not found"
                }
                
                { Invoke-FleetSavedQuery -QueryId 999 -HostId 1 } | Should -Throw "*Query not found*"
            }
        }
        
        It "Should handle network errors" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    throw "Network connection failed"
                }
                
                { Invoke-FleetSavedQuery -QueryId 5 -HostId 1 } | Should -Throw "*Network connection failed*"
            }
        }
        
        It "Should handle authentication errors" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    throw "Authentication failed"
                }
                
                { Invoke-FleetSavedQuery -QueryId 5 -HostId 1 } | Should -Throw "*Authentication failed*"
            }
        }
    }
    
    Context "Verbose Output" {
        It "Should provide verbose information when requested" {
            InModuleScope FleetDM-PowerShell -Parameters @{ MockData = $script:MockQueryResult } {
                param($MockData)
                
                Mock Invoke-FleetDMRequest {
                    return [PSCustomObject]$MockData
                }
                
                $verboseOutput = Invoke-FleetSavedQuery -QueryId 5 -HostId 1,2 -Verbose 4>&1 | 
                    Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
                
                $verboseOutput | Should -Not -BeNullOrEmpty
                $verboseMessages = $verboseOutput | ForEach-Object { $_.ToString() }
                $verboseMessages -join ' ' | Should -BeLike "*Running saved query*"
                $verboseMessages -join ' ' | Should -BeLike "*2 host(s)*"
            }
        }
        
        It "Should note server-side timeout control" {
            InModuleScope FleetDM-PowerShell -Parameters @{ MockData = $script:MockQueryResult } {
                param($MockData)
                
                Mock Invoke-FleetDMRequest {
                    return [PSCustomObject]$MockData
                }
                
                $verboseOutput = Invoke-FleetSavedQuery -QueryId 5 -HostId 1 -Verbose 4>&1 | 
                    Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
                
                $verboseMessages = $verboseOutput | ForEach-Object { $_.ToString() }
                $verboseMessages -join ' ' | Should -BeLike "*server configuration*"
            }
        }
    }
    
    Context "Output Formatting" {
        It "Should display results summary when complete" {
            Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
                return [PSCustomObject]$script:MockQueryResult
            }
            
            Mock Write-Host { } -ModuleName FleetDM-PowerShell
            
            $result = Invoke-FleetSavedQuery -QueryId 5 -HostId 1,2
            
            Should -Invoke Write-Host -ModuleName FleetDM-PowerShell -ParameterFilter {
                $Object -like "*Query completed*" -and $Object -like "*2/2*"
            }
        }
        
        It "Should warn when hosts return errors" {
            Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
                return [PSCustomObject]$script:MockQueryResultWithErrors
            }
            
            Mock Write-Warning { } -ModuleName FleetDM-PowerShell
            
            $result = Invoke-FleetSavedQuery -QueryId 5 -HostId 1,2,3
            
            # Function warns about hosts that returned errors
            Should -Invoke Write-Warning -ModuleName FleetDM-PowerShell -ParameterFilter {
                $Message -like "*1 host(s) returned errors*"
            }
        }
    }
}