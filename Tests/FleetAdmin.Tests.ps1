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

Describe 'Fleet admin cmdlets' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Body, $QueryParameters)
            switch -Regex ($Endpoint) {
                '^fleets/\d+/users$' { return [PSCustomObject]@{ team = [PSCustomObject]@{ id = 1; name = 'Workstations'; user_count = 2 } } }
                '^fleets/\d+/agent_options$' { return [PSCustomObject]@{ team = [PSCustomObject]@{ id = 1; agent_options = $Body } } }
                '^software/patch_deadline_settings$' {
                    $days = if ($Body) { $Body.days } else { @('tuesday') }
                    return [PSCustomObject]@{ patch_deadline_settings = [PSCustomObject]@{ fleet_id = 3; days = $days; time = '17:00' } }
                }
                default { return $null }
            }
        }
    }

    Context 'Add-FleetTeamUser' {
        It 'adds users with one role in one request' {
            $fleet = Add-FleetTeamUser -FleetId 1 -UserId 17, 18 -Role observer -Confirm:$false
            $fleet.PSObject.TypeNames | Should -Contain 'FleetDM.Team'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'fleets/1/users' -and $Method -eq 'PATCH' -and $Body.users.Count -eq 2 -and
                $Body.users[0].id -eq 17 -and $Body.users[0].role -eq 'observer' -and $Body.users[1].id -eq 18
            }
        }

        It 'collects piped users and lowercases the role' {
            @([PSCustomObject]@{ id = 5 }, [PSCustomObject]@{ id = 6 }, [PSCustomObject]@{ id = 5 }) | Add-FleetTeamUser -FleetId 1 -Role Observer_Plus -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Body.users.Count -eq 2 -and $Body.users[1].role -eq 'observer_plus'
            }
        }

        It 'rejects an unknown role and sends nothing with -WhatIf' {
            { Add-FleetTeamUser -FleetId 1 -UserId 5 -Role owner -Confirm:$false } | Should -Throw '*Role*'
            Add-FleetTeamUser -FleetId 1 -UserId 5 -Role admin -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'Set-FleetTeamAgentOption' {
        It 'sends a hashtable as the body with force and dry_run query flags' {
            $fleet = Set-FleetTeamAgentOption -FleetId 1 -AgentOptions @{ config = @{ options = @{ distributed_interval = 30 } }; overrides = @{} } -SkipValidation -DryRun -Confirm:$false
            $fleet.PSObject.TypeNames | Should -Contain 'FleetDM.Team'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'fleets/1/agent_options' -and $Method -eq 'POST' -and
                $QueryParameters.force -eq $true -and $QueryParameters.dry_run -eq $true -and
                $Body.config.options.distributed_interval -eq 30 -and $Body.ContainsKey('overrides')
            }
        }

        It 'accepts an object or a JSON string and sends no flags by default' {
            $object = [PSCustomObject]@{ config = [PSCustomObject]@{ options = [PSCustomObject]@{ logger_tls_period = 10 } } }
            Set-FleetTeamAgentOption -FleetId 1 -AgentOptions $object -Confirm:$false | Out-Null
            Set-FleetTeamAgentOption -FleetId 1 -AgentOptions '{"command_line_flags":{"verbose":true}}' -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $QueryParameters.Count -eq 0 -and $Body.config.options.logger_tls_period -eq 10
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Body.command_line_flags.verbose -eq $true
            }
        }

        It 'keeps a one-element nested array from a JSON string' {
            Set-FleetTeamAgentOption -FleetId 1 -AgentOptions '{"config":{"decorators":{"load":["SELECT 1"]}}}' -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Body.config.decorators.load -is [System.Array] -and
                $Body.config.decorators.load.Count -eq 1 -and
                $Body.config.decorators.load[0] -eq 'SELECT 1'
            }
        }

        It 'does not reuse -Force for the force query flag' {
            (Get-Command Set-FleetTeamAgentOption).Parameters.Keys | Should -Not -Contain 'Force'
        }

        It 'rejects invalid JSON, an empty object, and a scalar' {
            { Set-FleetTeamAgentOption -FleetId 1 -AgentOptions '{ nope' -Confirm:$false } | Should -Throw '*not valid JSON*'
            { Set-FleetTeamAgentOption -FleetId 1 -AgentOptions @{} -Confirm:$false } | Should -Throw '*at least one key*'
            { Set-FleetTeamAgentOption -FleetId 1 -AgentOptions 5 -Confirm:$false } | Should -Throw '*at least one key*'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }

        It 'sends nothing with -WhatIf' {
            Set-FleetTeamAgentOption -FleetId 1 -AgentOptions @{ config = @{} } -WhatIf
            Set-FleetTeamAgentOption -FleetId 1 -AgentOptions @{ config = @{} } -DryRun -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'Move-FleetHost' {
        It 'moves hosts by filter, including unassigned hosts to a fleet' {
            $result = Move-FleetHost -FleetId 2 -Filter @{ Fleet_Id = 0; status = 'online' } -Confirm:$false
            $result.Status | Should -Be 'Transferred'
            $result.Filter.fleet_id | Should -Be 0
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'hosts/transfer/filter' -and $Method -eq 'POST' -and $Body.fleet_id -eq 2 -and
                $Body.filters.fleet_id -eq 0 -and $Body.filters.status -eq 'online' -and @($Body.filters.Keys) -ccontains 'fleet_id' -and @($Body.filters.Keys) -cnotcontains 'Fleet_Id'
            }
        }

        It 'rejects an empty or unknown filter' {
            { Move-FleetHost -FleetId 2 -Filter @{} -Confirm:$false } | Should -Throw '*at least one key*'
            { Move-FleetHost -FleetId 2 -Filter @{ team_id = 1 } -Confirm:$false } | Should -Throw "*Unsupported filter key 'team_id'*"
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }

        It 'sends nothing with -WhatIf' {
            Move-FleetHost -FleetId 2 -Filter @{ label_id = 7 } -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'Patch deadlines' {
        It 'reads the settings for a fleet, including a piped fleet' {
            $settings = Get-FleetPatchDeadline -FleetId 3
            $settings.PSObject.TypeNames | Should -Contain 'FleetDM.PatchDeadline'
            $settings.time | Should -Be '17:00'
            [PSCustomObject]@{ id = 0 } | Get-FleetPatchDeadline | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'software/patch_deadline_settings' -and $Method -eq 'GET' -and $QueryParameters.fleet_id -eq 3
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $QueryParameters.fleet_id -eq 0
            }
        }

        It 'sets lowercase unique days and the time' {
            $settings = Set-FleetPatchDeadline -FleetId 3 -Days Monday, wednesday, monday -Time '09:30' -Confirm:$false
            @($settings.days) | Should -Be @('monday', 'wednesday')
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'software/patch_deadline_settings' -and $Method -eq 'PATCH' -and $Body.fleet_id -eq 3 -and
                (@($Body.days) -join ',') -eq 'monday,wednesday' -and $Body.time -eq '09:30'
            }
        }

        It 'validates day names and HH:MM' {
            { Set-FleetPatchDeadline -FleetId 3 -Days 'funday' -Time '11:00' -Confirm:$false } | Should -Throw '*Days*'
            foreach ($bad in '24:00', '9:00', '11:60', '11:00:00', 'noon') {
                { Set-FleetPatchDeadline -FleetId 3 -Days monday -Time $bad -Confirm:$false } | Should -Throw '*Time*'
            }
            { Set-FleetPatchDeadline -FleetId 3 -Days monday -Time '23:59' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'Set-FleetHostNameTemplate' {
        It 'sets a template and clears it with an empty string' {
            $set = Set-FleetHostNameTemplate -FleetId 5 -Template 'iPad $FLEET_VAR_HOST_HARDWARE_SERIAL' -Confirm:$false
            $set.Status | Should -Be 'Set'
            $cleared = Set-FleetHostNameTemplate -FleetId 5 -Template '' -Confirm:$false
            $cleared.Status | Should -Be 'Cleared'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'host_name_template' -and $Method -eq 'POST' -and $Body.fleet_id -eq 5 -and
                $Body.name_template -eq 'iPad $FLEET_VAR_HOST_HARDWARE_SERIAL'
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Body.ContainsKey('name_template') -and $Body.name_template -eq ''
            }
        }

        It 'sends nothing with -WhatIf' {
            Set-FleetHostNameTemplate -FleetId 5 -Template '' -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }
}

Describe 'Fleet admin request bodies on the wire' -Tag 'Unit' {
    It 'sends an empty host name template as "" rather than dropping it' {
        InModuleScope FleetDM-PowerShell {
            $script:templateBody = $null
            Mock Invoke-RestMethod {
                $script:templateBody = $Body
                return $null
            }
            Set-FleetHostNameTemplate -FleetId 5 -Template '' -Confirm:$false | Out-Null
            $parsed = $script:templateBody | ConvertFrom-Json
            $parsed.PSObject.Properties.Name | Should -Contain 'name_template'
            $parsed.name_template | Should -BeExactly ''
            $parsed.fleet_id | Should -Be 5
        }
    }

    It 'sends a one-element agent-option array as a JSON array' {
        InModuleScope FleetDM-PowerShell {
            $script:agentOptionBody = $null
            Mock Invoke-RestMethod {
                $script:agentOptionBody = $Body
                return [PSCustomObject]@{ team = [PSCustomObject]@{ id = 1 } }
            }
            $object = [PSCustomObject]@{
                config = [PSCustomObject]@{
                    decorators = [PSCustomObject]@{ load = @('SELECT 1') }
                }
            }
            Set-FleetTeamAgentOption -FleetId 1 -AgentOptions $object -Confirm:$false | Out-Null
            $script:agentOptionBody | Should -Match '"load":\["SELECT 1"\]'
            $script:agentOptionBody | Should -Not -Match '"load":"SELECT 1"'
            Set-FleetTeamAgentOption -FleetId 1 -AgentOptions '{"config":{"decorators":{"load":["SELECT 1"]}}}' -Confirm:$false | Out-Null
            $script:agentOptionBody | Should -Match '"load":\["SELECT 1"\]'
            $script:agentOptionBody | Should -Not -Match '"load":"SELECT 1"'
        }
    }
}
