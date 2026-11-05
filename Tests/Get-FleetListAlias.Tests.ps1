BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../FleetDM-PowerShell.psd1'
    Import-Module $modulePath -Force
    InModuleScope FleetDM-PowerShell {
        $script:FleetDMConnection = @{
            BaseUri = 'https://test.fleetdm.example.com'
            Headers = @{ Authorization = 'Bearer test-token' }
            Version = '4.93.0'
        }
        $script:FleetDMWebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    }
}

Describe 'Fleet list responses that include teams and fleets' -Tag 'Unit' {
    BeforeAll {
        $script:SixFleets = foreach ($id in 1..6) {
            [PSCustomObject]@{ id = $id; name = "fleet$id" }
        }
    }

    It 'reads fleets when the legacy teams array is empty' {
        InModuleScope FleetDM-PowerShell -Parameters @{ SixFleets = $script:SixFleets } {
            $response = [PSCustomObject]@{
                teams = @()
                fleets = $SixFleets
                meta = [PSCustomObject]@{ has_next_results = $false }
            }

            $items = @(Get-FleetPaginatedData -Response $response)
            $items.Count | Should -Be 6
            $items[0].name | Should -Be 'fleet1'
            $items[5].id | Should -Be 6

            $page = Get-FleetPaginatedData -Response $response -ReturnMetadata
            @($page.Data).Count | Should -Be 6
            $page.HasMore | Should -Be $false
        }
    }

    It 'reads teams when fleets is null' {
        InModuleScope FleetDM-PowerShell -Parameters @{ SixFleets = $script:SixFleets } {
            $response = [PSCustomObject]@{ teams = $SixFleets; fleets = $null }

            $paginated = @(Get-FleetPaginatedData -Response $response)
            $paginated.Count | Should -Be 6
            $paginated[0].id | Should -Be 1

            $listed = @(Get-FleetListResult -Response $response -Name 'fleets' -TypeName 'FleetDM.Team')
            $listed.Count | Should -Be 6
            $listed[0].name | Should -Be 'fleet1'
            $listed[0].PSObject.TypeNames | Should -Contain 'FleetDM.Team'
            $listed[0].PSObject.Properties.Name | Should -Not -Contain 'teams'
        }
    }

    It 'reads teams when fleets is an empty array' {
        InModuleScope FleetDM-PowerShell -Parameters @{ SixFleets = $script:SixFleets } {
            $response = [PSCustomObject]@{ fleets = @(); teams = $SixFleets }

            $paginated = @(Get-FleetPaginatedData -Response $response)
            $paginated.Count | Should -Be 6
            $paginated[2].name | Should -Be 'fleet3'

            $listed = @(Get-FleetListResult -Response $response -Name 'fleets' -TypeName 'FleetDM.Team')
            $listed.Count | Should -Be 6
            $listed[5].id | Should -Be 6
            $listed[0].PSObject.TypeNames | Should -Contain 'FleetDM.Team'
        }
    }

    It 'returns one copy when teams and fleets hold the same records' {
        InModuleScope FleetDM-PowerShell -Parameters @{ SixFleets = $script:SixFleets } {
            $teams = @(1..6 | ForEach-Object { [PSCustomObject]@{ id = $_; name = "fleet$_" } })
            $response = [PSCustomObject]@{ teams = $teams; fleets = $SixFleets }

            $paginated = @(Get-FleetPaginatedData -Response $response)
            $paginated.Count | Should -Be 6
            @($paginated.id | Select-Object -Unique).Count | Should -Be 6

            $listed = @(Get-FleetListResult -Response $response -Name 'fleets' -TypeName 'FleetDM.Team')
            $listed.Count | Should -Be 6
            @($listed.id | Select-Object -Unique).Count | Should -Be 6
            $listed[0].name | Should -Be 'fleet1'
        }
    }

    It 'prefers the named fleets collection when both keys are populated' {
        InModuleScope FleetDM-PowerShell {
            $response = [PSCustomObject]@{
                teams = @([PSCustomObject]@{ id = 2; name = 'from-teams' })
                fleets = @([PSCustomObject]@{ id = 1; name = 'from-fleets' })
            }

            $listed = @(Get-FleetListResult -Response $response -Name 'fleets' -TypeName 'FleetDM.Team')
            $listed.Count | Should -Be 1
            $listed[0].name | Should -Be 'from-fleets'

            $paginated = @(Get-FleetPaginatedData -Response $response)
            $paginated.Count | Should -Be 1
            $paginated[0].name | Should -Be 'from-fleets'
        }
    }

    It 'prefers fleets when both keys are one unwrapped record and teams is listed first' {
        # Windows PowerShell 5.1 ConvertFrom-Json turns a one-element JSON array into one object.
        InModuleScope FleetDM-PowerShell {
            $response = [PSCustomObject]@{
                teams = [PSCustomObject]@{ id = 2; name = 'from-teams' }
                fleets = [PSCustomObject]@{ id = 1; name = 'from-fleets' }
            }

            $paginated = @(Get-FleetPaginatedData -Response $response)
            $paginated.Count | Should -Be 1
            $paginated[0].name | Should -Be 'from-fleets'
            $paginated[0].id | Should -Be 1

            $listed = @(Get-FleetListResult -Response $response -Name 'fleets' -TypeName 'FleetDM.Team')
            $listed.Count | Should -Be 1
            $listed[0].name | Should -Be 'from-fleets'
            $listed[0].id | Should -Be $paginated[0].id
        }
    }

    It 'still reads a response that has only fleets' {
        InModuleScope FleetDM-PowerShell -Parameters @{ SixFleets = $script:SixFleets } {
            $response = [PSCustomObject]@{ fleets = $SixFleets }

            $paginated = @(Get-FleetPaginatedData -Response $response)
            $paginated.Count | Should -Be 6

            $listed = @(Get-FleetListResult -Response $response -Name 'fleets' -TypeName 'FleetDM.Team')
            $listed.Count | Should -Be 6
            $listed[0].PSObject.TypeNames | Should -Contain 'FleetDM.Team'
            $listed[0].name | Should -Be 'fleet1'
        }
    }

    It 'keeps an empty single-key list empty' {
        InModuleScope FleetDM-PowerShell {
            $hosts = [PSCustomObject]@{
                hosts = @()
                meta = [PSCustomObject]@{ has_next_results = $true }
            }
            @(Get-FleetPaginatedData -Response $hosts).Count | Should -Be 0

            $fleets = [PSCustomObject]@{ fleets = @() }
            $listed = @(Get-FleetListResult -Response $fleets -Name 'fleets' -TypeName 'FleetDM.Team')
            $listed.Count | Should -Be 0

            $policies = [PSCustomObject]@{ policies = @([PSCustomObject]@{ id = 4; name = 'Gatekeeper' }) }
            $policy = @(Get-FleetListResult -Response $policies -Name 'policies' -TypeName 'FleetDM.Policy')
            $policy.Count | Should -Be 1
            $policy[0].name | Should -Be 'Gatekeeper'
            $policy[0].PSObject.TypeNames | Should -Contain 'FleetDM.Policy'
        }
    }

    It 'keeps an already unwrapped item list' {
        InModuleScope FleetDM-PowerShell -Parameters @{ SixFleets = $script:SixFleets } {
            $listed = @(Get-FleetListResult -Response $SixFleets -Name 'fleets' -TypeName 'FleetDM.Team')
            $listed.Count | Should -Be 6
            $listed[0].name | Should -Be 'fleet1'
            $listed[0].PSObject.TypeNames | Should -Contain 'FleetDM.Team'
            $listed[0].PSObject.Properties.Name | Should -Not -Contain 'fleets'
        }
    }

    It 'reads a one-element legacy team that ConvertFrom-Json has unwrapped' {
        InModuleScope FleetDM-PowerShell {
            $response = [PSCustomObject]@{
                fleets = @()
                teams = [PSCustomObject]@{ id = 8; name = 'Only' }
            }

            $paginated = @(Get-FleetPaginatedData -Response $response)
            $paginated.Count | Should -Be 1
            $paginated[0].name | Should -Be 'Only'

            $listed = @(Get-FleetListResult -Response $response -Name 'fleets' -TypeName 'FleetDM.Team')
            $listed.Count | Should -Be 1
            $listed[0].id | Should -Be 8
            $listed[0].PSObject.TypeNames | Should -Contain 'FleetDM.Team'
        }
    }

    It 'lists fleets from Get-FleetTeam when teams is empty and fleets is populated' {
        InModuleScope FleetDM-PowerShell -Parameters @{ SixFleets = $script:SixFleets } {
            Mock Invoke-RestMethod {
                return [PSCustomObject]@{
                    teams = @()
                    fleets = $SixFleets
                }
            }

            $fleets = @(Get-FleetTeam)
            $fleets.Count | Should -Be 6
            $fleets[0].name | Should -Be 'fleet1'
            $fleets[0].PSObject.TypeNames | Should -Contain 'FleetDM.Team'
        }
    }

    It 'lists one page from Get-FleetTeam when fleets is null and teams is populated' {
        InModuleScope FleetDM-PowerShell -Parameters @{ SixFleets = $script:SixFleets } {
            Mock Invoke-RestMethod {
                return [PSCustomObject]@{
                    teams = $SixFleets
                    fleets = $null
                }
            }

            $fleets = @(Get-FleetTeam -Page 0)
            $fleets.Count | Should -Be 6
            $fleets[5].name | Should -Be 'fleet6'
            $fleets[0].PSObject.TypeNames | Should -Contain 'FleetDM.Team'
            $fleets[0].PSObject.Properties.Name | Should -Not -Contain 'teams'
        }
    }
}
