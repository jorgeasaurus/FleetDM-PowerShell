#Requires -Module Pester

BeforeAll {
    # Import the module
    $modulePath = (Resolve-Path "$PSScriptRoot/../FleetDM-PowerShell.psd1").Path
    Import-Module $modulePath -Force -ErrorAction Stop
    
    # Mock connection - set in module scope
    InModuleScope FleetDM-PowerShell {
        $script:FleetDMConnection = @{
            BaseUri = "https://test.fleetdm.example.com"
            Headers = @{ 'Authorization' = 'Bearer test-token' }
            Version = "4.0.0"
        }
    }
    
    # Mock test data
    $script:TestHosts = @(
        @{ id = 1; hostname = "test-host-1"; status = "online" },
        @{ id = 2; hostname = "test-host-2"; status = "offline" }
    )
}

Describe "Remove-FleetHost Tests" -Tags @('Unit', 'Hosts') {
    Context "Basic Functionality" {
        It "Should remove a single host by ID" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    param($Endpoint, $Method, $Body, $QueryParameters)
                    
                    if ($Endpoint -match "hosts/(\d+)" -and $Method -eq "DELETE") {
                        $hostId = [int]$matches[1]
                        if ($hostId -eq 1) {
                            return @{ message = "Host deleted successfully" }
                        }
                    }
                    throw "Host not found"
                }
                
                { Remove-FleetHost -Id 1 -Confirm:$false } | Should -Not -Throw
                
                Should -Invoke Invoke-FleetDMRequest -Times 1 -ParameterFilter {
                    $Endpoint -eq "hosts/1" -and $Method -eq "DELETE"
                }
            }
        }
        
        It "Should remove multiple hosts by ID" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    param($Endpoint, $Method)
                    
                    if ($Endpoint -match "hosts/(\d+)" -and $Method -eq "DELETE") {
                        return @{ message = "Host deleted successfully" }
                    }
                    throw "Host not found"
                }
                
                { Remove-FleetHost -Id 1,2,3 -Confirm:$false } | Should -Not -Throw
                
                Should -Invoke Invoke-FleetDMRequest -Times 3
            }
        }
        
        It "Should handle host not found errors" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    throw "Host not found"
                }
                
                { Remove-FleetHost -Id 999999 -Confirm:$false -ErrorAction Stop } | Should -Throw "*Host not found*"
            }
        }
        
        It "Should accept pipeline input of host IDs" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    param($Endpoint, $Method)
                    
                    if ($Endpoint -match "hosts/(\d+)" -and $Method -eq "DELETE") {
                        return @{ message = "Host deleted successfully" }
                    }
                    throw "Host not found"
                }
                
                @(1, 2, 3) | Remove-FleetHost -Confirm:$false
                
                Should -Invoke Invoke-FleetDMRequest -Times 3
            }
        }
        
        It "Should accept pipeline input of host objects" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    param($Endpoint, $Method)
                    
                    if ($Endpoint -match "hosts/(\d+)" -and $Method -eq "DELETE") {
                        return @{ message = "Host deleted successfully" }
                    }
                    throw "Host not found"
                }
                
                $hosts = @(
                    [PSCustomObject]@{ id = 1; hostname = "host1" },
                    [PSCustomObject]@{ id = 2; hostname = "host2" }
                )
                
                $hosts | Remove-FleetHost -Confirm:$false
                
                Should -Invoke Invoke-FleetDMRequest -Times 2
            }
        }
        
        It "Should support -WhatIf" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    param($Endpoint, $Method)
                    
                    if ($Method -eq 'GET') {
                        # Allow GET requests for retrieving host details
                        return @{
                            host = @{
                                id = 1
                                hostname = "test-host-1"
                                platform = "darwin"
                            }
                        }
                    } elseif ($Method -eq 'DELETE') {
                        # DELETE should not be called with -WhatIf
                        throw "DELETE should not be called with -WhatIf"
                    }
                }
                
                { Remove-FleetHost -Id 1 -WhatIf } | Should -Not -Throw
                
                # Should call GET once to retrieve host details but not DELETE
                Should -Invoke Invoke-FleetDMRequest -Times 1 -ParameterFilter { $Method -eq 'GET' }
                Should -Invoke Invoke-FleetDMRequest -Times 0 -ParameterFilter { $Method -eq 'DELETE' }
            }
        }
        
        It "Should skip confirmation when using -Force" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    param($Endpoint, $Method)
                    
                    if ($Endpoint -match "hosts/(\d+)" -and $Method -eq "DELETE") {
                        return @{ message = "Host deleted successfully" }
                    }
                    throw "Host not found"
                }
                
                { Remove-FleetHost -Id 1 -Force } | Should -Not -Throw
                
                Should -Invoke Invoke-FleetDMRequest -Times 1
            }
        }
    }
    
    Context "Error Handling" {
        It "Should handle authentication errors" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    throw "Authentication failed"
                }
                
                { Remove-FleetHost -Id 1 -Confirm:$false -ErrorAction Stop } | Should -Throw "*Authentication failed*"
            }
        }
        
        It "Should handle network errors" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    throw "Network connection failed"
                }
                
                { Remove-FleetHost -Id 1 -Confirm:$false -ErrorAction Stop } | Should -Throw "*Network connection failed*"
            }
        }
        
        It "Should handle permission errors" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    throw "Access denied"
                }
                
                { Remove-FleetHost -Id 1 -Confirm:$false -ErrorAction Stop } | Should -Throw "*Access denied*"
            }
        }
    }
    
    Context "Verbose Output" {
        It "Should provide verbose information when requested" {
            InModuleScope FleetDM-PowerShell {
                Mock Invoke-FleetDMRequest {
                    param($Endpoint, $Method)
                    
                    if ($Endpoint -match "hosts/(\d+)" -and $Method -eq "DELETE") {
                        return @{ message = "Host deleted successfully" }
                    }
                    throw "Host not found"
                }
                
                $verboseOutput = Remove-FleetHost -Id 1 -Confirm:$false -Verbose 4>&1 | 
                    Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
                
                $verboseOutput | Should -Not -BeNullOrEmpty
                $verboseMessages = $verboseOutput | ForEach-Object { $_.ToString() }
                $verboseMessages -join ' ' | Should -BeLike "*Removing host*"
            }
        }
    }
}