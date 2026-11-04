BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../FleetDM-PowerShell.psd1'
    Import-Module $modulePath -Force
    InModuleScope FleetDM-PowerShell {
        $script:FleetDMConnection = @{
            BaseUri = 'https://test.fleetdm.example.com'
            Headers = @{ Authorization = 'Bearer test-token' }
            Version = '4.67.0'
        }
        $script:FleetDMWebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    }
}

Describe 'Fleet Premium cmdlets' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Body, $QueryParameters)
            switch -Regex ($Endpoint) {
                '^fleets$' {
                    if ($Method -eq 'POST') { return @{ team = [PSCustomObject]@{ id = 9; name = $Body.name } } }
                    return @{ fleets = @([PSCustomObject]@{ id = 1; name = 'Workstations' }) }
                }
                '^fleets/(\d+)$' {
                    if ($Method -eq 'DELETE') { return $null }
                    if ($Method -eq 'PATCH') { return @{ team = [PSCustomObject]@{ id = 1; name = $Body.name; mdm = $Body.mdm } } }
                    return @{ team = [PSCustomObject]@{ id = 1; name = 'Workstations' } }
                }
                'software/.*/install$' { return $null }
                'software/.*/uninstall$' { return $null }
                '^software/install/' { return [PSCustomObject]@{ install_uuid = 'abc'; status = 'installed' } }
                'available_for_install' { return $null }
                'self_service_categories$' {
                    if ($Method -eq 'POST') {
                        return @{ self_service_category = [PSCustomObject]@{ id = 4; name = $Body.name; fleet_id = $Body.fleet_id } }
                    }
                    return @{ self_service_categories = @([PSCustomObject]@{ id = 4; name = 'Browsers'; fleet_id = 3 }) }
                }
                'self_service_categories/' {
                    if ($Method -eq 'DELETE') { return $null }
                    return @{ self_service_category = [PSCustomObject]@{ id = 4; name = $Body.name } }
                }
                '/lock$' { return [PSCustomObject]@{ device_status = 'unlocked'; pending_action = 'lock' } }
                '/unlock$' { return [PSCustomObject]@{ host_id = 8; pending_action = 'unlock' } }
                '^disk_encryption$' {
                    if ($Method -eq 'POST') { return $null }
                    return [PSCustomObject]@{ verified = @{ macos = 1 } }
                }
                '^scripts$' { return @{ scripts = @([PSCustomObject]@{ id = 2; name = 'collect.sh' }) } }
                '^scripts/\d+$' {
                    if ($Method -eq 'DELETE') { return $null }
                    return @{ script = [PSCustomObject]@{ id = 2; name = 'collect.sh' } }
                }
                '^scripts/run$' { return [PSCustomObject]@{ execution_id = 'exec-1'; host_id = $Body.host_id } }
                'automation_activities' { return @{ activities = @([PSCustomObject]@{ id = 7; activity_type = 'ran_script' }) } }
                '^fleets/\d+/policies$' { return @([PSCustomObject]@{ id = 12; name = 'Gatekeeper' }) }
                '^automations/reset$' { return @{} }
                '^config$' {
                    if ($Method -eq 'PATCH') { return @{ sso_settings = [PSCustomObject]$Body.sso_settings } }
                    return @{ sso_settings = [PSCustomObject]@{ enable_sso = $true; enable_jit_provisioning = $false; entity_id = 'fleet' } }
                }
                default { return @{ ok = $true } }
            }
        }
    }

    It 'lists fleets and tags the team object' {
        $fleets = Get-FleetTeam
        $fleets[0].name | Should -Be 'Workstations'
        $fleets[0].PSObject.TypeNames | Should -Contain 'FleetDM.Team'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'fleets'
        }
    }

    It 'creates, updates, and removes a fleet' {
        $created = New-FleetTeam -Name 'Workstations' -Confirm:$false
        $created.id | Should -Be 9
        Set-FleetTeam -Id 1 -Name 'Engineering' -Confirm:$false | Out-Null
        Remove-FleetTeam -Id 1 -Confirm:$false | Out-Null
        $assigned = Set-FleetTeam -Id 1 -HostId 3, 6 -Confirm:$false
        $assigned.name | Should -Be 'Workstations'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'fleets/1' -and $Method -eq 'DELETE'
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'hosts/transfer' -and $Method -eq 'POST' -and
            $Body.fleet_id -eq 1 -and $Body.hosts -contains 3 -and $Body.hosts -contains 6
        }
    }

    It 'installs software and reads the install result' {
        $queued = Install-FleetSoftware -HostId 5 -SoftwareTitleId 9 -Confirm:$false
        $queued.Status | Should -Be 'accepted'
        $result = Get-FleetSoftwareInstall -InstallUuid 'abc'
        $result.status | Should -Be 'installed'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'hosts/5/software/9/install' -and $Method -eq 'POST'
        }
    }

    It 'uninstalls software and removes an installer package' {
        Uninstall-FleetSoftware -HostId 5 -SoftwareTitleId 9 -Confirm:$false | Out-Null
        Remove-FleetSoftwarePackage -SoftwareTitleId 9 -FleetId 2 -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'software/titles/9/available_for_install' -and $QueryParameters.fleet_id -eq 2
        }
    }

    It 'manages self-service categories' {
        $categories = Get-FleetSelfServiceCategory -FleetId 3
        $categories[0].name | Should -Be 'Browsers'
        $created = New-FleetSelfServiceCategory -FleetId 3 -Name 'Engineering' -Confirm:$false
        $created.fleet_id | Should -Be 3
        Set-FleetSelfServiceCategory -Id 4 -Name 'Tools' -Confirm:$false | Out-Null
        Remove-FleetSelfServiceCategory -Id 4 -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'software/self_service_categories' -and $QueryParameters.fleet_id -eq 3
        }
    }

    It 'locks and unlocks a host' {
        $locked = Lock-FleetHost -Id 8 -ViewPin -Confirm:$false
        $locked.pending_action | Should -Be 'lock'
        Unlock-FleetHost -Id 8 -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'hosts/8/lock' -and $QueryParameters.view_pin -eq 'true'
        }
    }

    It 'reads and sets disk encryption' {
        $summary = Get-FleetDiskEncryption -FleetId 1
        $summary.verified.macos | Should -Be 1
        Set-FleetDiskEncryption -FleetId 1 -Enable $true -RequireBitLockerPin $false -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'disk_encryption' -and $Method -eq 'POST' -and $Body.enable_disk_encryption -eq $true
        }
    }

    It 'patches fleet OS update settings' {
        Set-FleetOsUpdate -FleetId 1 -MacOsMinimumVersion '15.4.1' -MacOsDeadline '2026-07-01' -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'fleets/1' -and $Body.mdm.macos_updates.minimum_version -eq '15.4.1'
        }
    }

    It 'enables calendar events on a fleet' {
        Set-FleetCalendarEvent -FleetId 1 -Enable $true -WebhookUrl 'https://hooks.example/fleet' -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Body.integrations.google_calendar.enable_calendar_events -eq $true -and
            $Body.integrations.google_calendar.webhook_url -eq 'https://hooks.example/fleet' -and
            $Body.integrations.google_calendar -isnot [System.Collections.IList]
        }
    }

    It 'lists scripts and runs one by id' {
        $scripts = Get-FleetScript
        $scripts[0].name | Should -Be 'collect.sh'
        $run = Invoke-FleetScript -HostId 10 -ScriptId 2 -Confirm:$false
        $run.execution_id | Should -Be 'exec-1'
        Remove-FleetScript -Id 2 -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'scripts/run' -and $Body.script_id -eq 2 -and $Body.host_id -eq 10
        }
    }

    It 'refuses fleet script names without recording a free-tier body mistake' {
        { Invoke-FleetScript -HostId 10 -ScriptName 'collect.sh' -FleetId 3 -Confirm:$false } | Should -Not -Throw
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Body.script_name -eq 'collect.sh' -and $Body.fleet_id -eq 3
        }
    }

    It 'lists and resets policy automations' {
        $activity = Get-FleetPolicyAutomation -PolicyId 12
        $activity[0].activity_type | Should -Be 'ran_script'
        Reset-FleetPolicyAutomation -PolicyId 12 -FleetId 3 -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'automations/reset' -and $Body.policy_ids -contains 12 -and $null -eq $Body.fleet_ids
        }
    }

    It 'creates a fleet policy with calendar and software automation' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            return @{ policy = [PSCustomObject]@{ id = 5; name = 'Gatekeeper'; passing_host_count = 0; failing_host_count = 0 } }
        }
        New-FleetPolicy -Name 'Gatekeeper' -Query 'SELECT 1;' -FleetId 2 -CalendarEventsEnabled $true -SoftwareTitleId 9 -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'fleets/2/policies' -and
            $Body.calendar_events_enabled -eq $true -and
            $Body.software_title_id -eq 9
        }
    }

    It 'rejects calendar automation on a global policy' {
        { New-FleetPolicy -Name 'Gatekeeper' -Query 'SELECT 1;' -CalendarEventsEnabled $true -Confirm:$false } |
            Should -Throw '*FleetId*'
    }

    It 'merges JIT provisioning into the current SSO settings' {
        $sso = Set-FleetJitProvisioning -Enabled $true -Confirm:$false
        $sso.enable_jit_provisioning | Should -BeTrue
        $sso.entity_id | Should -Be 'fleet'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'config' -and $Method -eq 'PATCH' -and $Body.sso_settings.enable_jit_provisioning -eq $true
        }
    }
}
