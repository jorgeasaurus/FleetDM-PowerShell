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

Describe 'Empty Fleet lists sent as null' -Tag 'Unit' {
    It 'returns no records when a paginated list is null, as Fleet 4.96 sends it' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod {
                return [PSCustomObject]@{
                    software_titles = $null
                    count = 0
                    meta = [PSCustomObject]@{ has_next_results = $false; has_previous_results = $false }
                }
            }
            @(Get-FleetSetupExperienceSoftware -FleetId 0 -Platform linux).Count | Should -Be 0
        }
    }

    It 'returns no scripts when the scripts key is null' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod {
                return [PSCustomObject]@{ meta = [PSCustomObject]@{ has_next_results = $false }; scripts = $null }
            }
            @(Get-FleetScript).Count | Should -Be 0
        }
    }

    It 'returns no records for a single-page list whose key is null' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod { return [PSCustomObject]@{ vpp_tokens = $null } }
            @(Get-FleetVppToken).Count | Should -Be 0
        }
    }

    It 'treats an empty page body as the end of the list' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod { return $null }
            @(Invoke-FleetDMRequest -Endpoint 'scripts' -FollowPagination).Count | Should -Be 0
        }
    }
}

Describe 'Get-FleetPaginatedData shapes' -Tag 'Unit' {
    It 'handles a null response with and without metadata' {
        InModuleScope FleetDM-PowerShell {
            Get-FleetPaginatedData -Response $null | Should -BeNullOrEmpty
            $meta = Get-FleetPaginatedData -Response $null -ReturnMetadata
            $meta.Data | Should -BeNullOrEmpty
            $meta.HasMore | Should -BeFalse
        }
    }

    It 'returns an array response as the data' {
        InModuleScope FleetDM-PowerShell {
            $items = @([PSCustomObject]@{ id = 1 }, [PSCustomObject]@{ id = 2 })
            (Get-FleetPaginatedData -Response $items).Count | Should -Be 2
            (Get-FleetPaginatedData -Response $items -ReturnMetadata).Data.Count | Should -Be 2
        }
    }

    It 'returns an empty page for an envelope with meta and no collection' {
        InModuleScope FleetDM-PowerShell {
            $page = Get-FleetPaginatedData -Response ([PSCustomObject]@{ scripts = $null; meta = [PSCustomObject]@{ has_next_results = $false } }) -ReturnMetadata
            @($page.Data).Count | Should -Be 0
            $page.HasMore | Should -BeFalse
        }
    }

    It 'returns the response when there is no collection and no meta' {
        InModuleScope FleetDM-PowerShell {
            $response = [PSCustomObject]@{ count = 3 }
            (Get-FleetPaginatedData -Response $response).count | Should -Be 3
        }
    }

    It 'returns a dictionary response unchanged' {
        InModuleScope FleetDM-PowerShell {
            $response = @{ hosts = @(1) }
            (Get-FleetPaginatedData -Response $response).hosts | Should -Be 1
        }
    }

    It 'skips an unrelated second list after an empty aliased list' {
        InModuleScope FleetDM-PowerShell {
            $response = [PSCustomObject]@{ fleets = @(); labels = @([PSCustomObject]@{ id = 9 }) }
            @(Get-FleetPaginatedData -Response $response).Count | Should -Be 0
        }
    }

    It 'prefers an unwrapped aliased record over an earlier nested object' {
        InModuleScope FleetDM-PowerShell {
            $response = [PSCustomObject]@{
                fleets = @()
                counts = [PSCustomObject]@{ total = 1 }
                teams = [PSCustomObject]@{ id = 4; name = 'Labs' }
            }
            $data = @(Get-FleetPaginatedData -Response $response)
            $data.Count | Should -Be 1
            $data[0].name | Should -Be 'Labs'
        }
    }
}

Describe 'Fleet response record helpers' -Tag 'Unit' {
    It 'returns null records for a null response' {
        InModuleScope FleetDM-PowerShell {
            Get-FleetRecord -Response $null | Should -BeNullOrEmpty
            Get-FleetResponseRecord -Response $null -Name 'script' -TypeName 'FleetDM.Script' | Should -BeNullOrEmpty
            Get-FleetEnvelopeProperty -Response $null -Name 'fleets' | Should -BeNullOrEmpty
            Get-FleetEnvelopeProperty -Response 'text' -Name 'fleets' | Should -BeNullOrEmpty
        }
    }

    It 'reads a fleet record under fleet when team is absent' {
        InModuleScope FleetDM-PowerShell {
            $record = Get-FleetRecord -Response ([PSCustomObject]@{ fleet = [PSCustomObject]@{ id = 2; name = 'B' } })
            $record.name | Should -Be 'B'
            $record.PSObject.TypeNames | Should -Contain 'FleetDM.Team'
        }
    }

    It 'chooses an empty alias list when the named key is missing' {
        InModuleScope FleetDM-PowerShell {
            $selection = Resolve-FleetListValue -Response ([PSCustomObject]@{ teams = @() }) -Name 'fleets'
            $selection.Found | Should -BeTrue
            @($selection.Value).Count | Should -Be 0
        }
    }

    It 'treats a present null key as an empty list and a missing key as not found' {
        InModuleScope FleetDM-PowerShell {
            $present = Resolve-FleetListValue -Response ([PSCustomObject]@{ scripts = $null }) -Name 'scripts'
            $present.Found | Should -BeTrue
            $present.Value | Should -BeNullOrEmpty
            (Resolve-FleetListValue -Response ([PSCustomObject]@{ other = 1 }) -Name 'scripts').Found | Should -BeFalse
        }
    }
}
