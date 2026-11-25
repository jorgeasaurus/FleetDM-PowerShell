BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../FleetDM-PowerShell.psd1'
    Import-Module $modulePath -Force
    InModuleScope FleetDM-PowerShell {
        $script:FleetDMConnection = @{
            BaseUri = 'https://test.fleetdm.example.com'
            Headers = @{ Authorization = 'Bearer test-token' }
            Version = '4.96.0'
        }
        $script:FleetDMWebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    }
}

Describe 'Remove-FleetPolicy' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Body)
            # Fleet 4.96 returns the deleted ids, for example {"deleted":[6]}.
            return [PSCustomObject]@{ deleted = @($Body.ids) }
        }
    }

    It 'deletes global policies in one POST to global/policies/delete' {
        $result = Remove-FleetPolicy -Id 4, 5 -Confirm:$false
        $result.PSObject.TypeNames | Should -Contain 'FleetDM.RemovedPolicy'
        @($result.Id) | Should -Be @(4, 5)
        $result.FleetId | Should -BeNullOrEmpty
        @($result.Deleted) | Should -Be @(4, 5)
        $result.Status | Should -Be 'Removed'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'global/policies/delete' -and $Method -eq 'POST' -and
            (@($Body.ids) -join ',') -eq '4,5'
        }
    }

    It 'batches piped ids into one request and drops duplicates' {
        4, 5, 5 | Remove-FleetPolicy -Force | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            (@($Body.ids) -join ',') -eq '4,5'
        }
    }

    It 'deletes fleet policies from fleets/{id}/policies/delete' {
        $result = Remove-FleetPolicy -Id 7 -FleetId 3 -Force
        $result.FleetId | Should -Be 3
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'fleets/3/policies/delete' -and $Method -eq 'POST' -and @($Body.ids) -contains 7
        }
    }

    It 'sends FleetId 0 to fleets/0 rather than the global route' {
        Remove-FleetPolicy -Id 8 -FleetId 0 -Force | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'fleets/0/policies/delete'
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0 -ParameterFilter {
            $Endpoint -like 'global/*'
        }
    }

    It 'routes piped global and fleet policies by their fleet_id and team_id properties' {
        $policies = @(
            [PSCustomObject]@{ id = 1; name = 'global'; team_id = $null; fleet_id = $null }
            [PSCustomObject]@{ id = 2; name = 'fleet'; team_id = 2; fleet_id = 2 }
            [PSCustomObject]@{ id = 3; name = 'legacy'; team_id = 2 }
            [PSCustomObject]@{ id = 4; name = 'unassigned'; fleet_id = 0 }
        )
        $results = @($policies | Remove-FleetPolicy -Force)
        $results.Count | Should -Be 3
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'global/policies/delete' -and (@($Body.ids) -join ',') -eq '1'
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'fleets/2/policies/delete' -and (@($Body.ids) -join ',') -eq '2,3'
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'fleets/0/policies/delete' -and (@($Body.ids) -join ',') -eq '4'
        }
    }

    It 'sends nothing with -WhatIf, even with -Force' {
        Remove-FleetPolicy -Id 4 -WhatIf
        Remove-FleetPolicy -Id 4 -FleetId 2 -Force -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'never sends DELETE' {
        Remove-FleetPolicy -Id 4 -Force | Out-Null
        Remove-FleetPolicy -Id 5 -FleetId 1 -Force | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0 -ParameterFilter { $Method -eq 'DELETE' }
    }

    It 'rejects a negative FleetId' {
        { Remove-FleetPolicy -Id 4 -FleetId -1 -Force } | Should -Throw '*0 or greater*'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }
}
