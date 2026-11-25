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
    $script:TestRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("fleet-profiles-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TestRoot | Out-Null
    $script:Mobileconfig = Join-Path $script:TestRoot 'passcode.mobileconfig'
    $script:WindowsXml = Join-Path $script:TestRoot 'firewall.xml'
    $script:Activation = Join-Path $script:TestRoot 'activation.json'
    [System.IO.File]::WriteAllText($script:Mobileconfig, '<plist>é</plist>')
    [System.IO.File]::WriteAllText($script:WindowsXml, '<Replace/>')
    [System.IO.File]::WriteAllText($script:Activation, '{"Type":"com.apple.activation.simple"}')
    $script:Uuid = 'a954ec5ea-a334-4825-87b3-937e7e381f24'
}

AfterAll {
    Remove-Item -LiteralPath $script:TestRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Describe 'Configuration profile requests on the wire' -Tag 'Unit' {
    It 'sends an empty multipart form for -ClearLabels' {
        InModuleScope FleetDM-PowerShell {
            $script:clearBody = $null
            $script:clearType = $null
            Mock Invoke-RestMethod {
                $script:clearBody = $Body
                $script:clearType = $ContentType
                return [PSCustomObject]@{ profile_uuid = 'a954ec5ea-a334-4825-87b3-937e7e381f24' }
            }
            Set-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24' -ClearLabels -Confirm:$false | Out-Null
            $script:clearType -match 'boundary=(.+)$' | Should -BeTrue
            [System.Text.Encoding]::UTF8.GetString($script:clearBody) | Should -BeExactly "--$($Matches[1])--`r`n"
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter { $Method -eq 'PATCH' }
        }
    }
}

Describe 'Configuration profile cmdlets' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Form, $Body, $QueryParameters, $OutFile)
            if ($OutFile) {
                [System.IO.File]::WriteAllText($OutFile, '<plist/>')
                return
            }
            switch -Regex ($Endpoint) {
                '^configuration_profiles$' {
                    if ($Method -eq 'POST') { return [PSCustomObject]@{ profile_uuid = 'a954ec5ea-a334-4825-87b3-937e7e381f24' } }
                    return @([PSCustomObject]@{ profile_uuid = 'a954ec5ea-a334-4825-87b3-937e7e381f24'; name = 'Passcode' })
                }
                '^configuration_profiles/[^/]+$' {
                    if ($Method -eq 'DELETE') { return [PSCustomObject]@{ warning = 'Some Windows settings may not be cleanly removed' } }
                    if ($Method -eq 'PATCH') { return [PSCustomObject]@{ profile_uuid = 'a954ec5ea-a334-4825-87b3-937e7e381f24' } }
                    return [PSCustomObject]@{
                        profile_uuid = 'a954ec5ea-a334-4825-87b3-937e7e381f24'
                        name = 'Passcode'
                        labels_include_any = @([PSCustomObject]@{ name = 'Engineering'; id = 1 }, [PSCustomObject]@{ name = 'QA'; id = 2 })
                        labels_exclude_any = @([PSCustomObject]@{ name = 'Servers'; id = 3; broken = $true })
                    }
                }
                default { return $null }
            }
        }
    }

    Context 'Get-FleetConfigurationProfile' {
        It 'lists unassigned profiles without fleet_id and fleet profiles with it' {
            $profiles = @(Get-FleetConfigurationProfile)
            $profiles[0].PSObject.TypeNames | Should -Contain 'FleetDM.ConfigurationProfile'
            Get-FleetConfigurationProfile -FleetId 2 | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'configuration_profiles' -and -not $QueryParameters.ContainsKey('fleet_id') -and $FollowPagination
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $QueryParameters.fleet_id -eq 2
            }
        }

        It 'gets profile metadata by piped profile_uuid' {
            $record = [PSCustomObject]@{ profile_uuid = $script:Uuid } | Get-FleetConfigurationProfile
            $record.name | Should -Be 'Passcode'
            $record.PSObject.TypeNames | Should -Contain 'FleetDM.ConfigurationProfile'
        }

        It 'downloads the profile with alt=media to OutFile' {
            $target = Join-Path $script:TestRoot 'download.mobileconfig'
            $file = Get-FleetConfigurationProfile -ProfileUuid $script:Uuid -OutFile $target
            $file.FullName | Should -Be $target
            Get-Content -LiteralPath $target -Raw | Should -Be '<plist/>'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
                $Endpoint -eq "configuration_profiles/a954ec5ea-a334-4825-87b3-937e7e381f24" -and $QueryParameters.alt -eq 'media' -and $OutFile -eq $target
            }
        }

        It 'rejects a value that is not a profile UUID' {
            { Get-FleetConfigurationProfile -ProfileUuid '../config' } | Should -Throw '*ProfileUuid*'
            { Get-FleetConfigurationProfile -ProfileUuid '954ec5ea-a334-4825-87b3-937e7e381f2' } | Should -Throw '*ProfileUuid*'
            { Get-FleetConfigurationProfile -ProfileUuid 'w954ec5ea-a334-4825-87b3-937e7e381f24' } | Should -Not -Throw
            { Get-FleetConfigurationProfile -ProfileUuid '954ec5ea-a334-4825-87b3-937e7e381f24' } | Should -Not -Throw
        }
    }

    Context 'New-FleetConfigurationProfile' {
        It 'sends every form field, with one label field per name' {
            $created = New-FleetConfigurationProfile -Path $script:Mobileconfig -Name 'Passcode' -Description 'PIN rules' -FleetId 2 `
                -LabelsIncludeAny 'Engineering', 'QA' -LabelsExcludeAny 'Servers' -ActivationPath $script:Activation -SelfService -Confirm:$false
            $created.profile_uuid | Should -Be $script:Uuid
            $created.PSObject.TypeNames | Should -Contain 'FleetDM.ConfigurationProfile'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'configuration_profiles' -and $Method -eq 'POST' -and
                $Form.profile.FileName -eq 'passcode.mobileconfig' -and
                [System.Text.Encoding]::UTF8.GetString($Form.profile.Bytes) -eq '<plist>é</plist>' -and
                $Form.name -eq 'Passcode' -and $Form.description -eq 'PIN rules' -and $Form.fleet_id -eq 2 -and
                (@($Form.labels_include_any) -join ',') -eq 'Engineering,QA' -and
                (@($Form.labels_exclude_any) -join ',') -eq 'Servers' -and
                -not $Form.Contains('labels_include_all') -and
                $Form.activation.FileName -eq 'activation.json' -and
                $Form.self_service -eq $true -and -not $Form.Contains('hidden')
            }
        }

        It 'sends only the file for a minimal Windows profile and marks it hidden' {
            New-FleetConfigurationProfile -Path $script:WindowsXml -Hidden -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
                ($Form.Keys -join ',') -eq 'profile,hidden' -and $Form.hidden -eq $true
            }
        }

        It 'rejects LabelsIncludeAll with LabelsIncludeAny and SelfService with Hidden' {
            { New-FleetConfigurationProfile -Path $script:Mobileconfig -LabelsIncludeAll 'A' -LabelsIncludeAny 'B' -Confirm:$false } |
                Should -Throw '*cannot be used together*'
            { New-FleetConfigurationProfile -Path $script:Mobileconfig -SelfService -Hidden -Confirm:$false } |
                Should -Throw '*Hidden requires SelfService*'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }

        It 'sends nothing with -WhatIf' {
            New-FleetConfigurationProfile -Path $script:Mobileconfig -FleetId 2 -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'Set-FleetConfigurationProfile' {
        It 're-sends the current labels when no label parameter is passed' {
            Set-FleetConfigurationProfile -ProfileUuid $script:Uuid -Path $script:Mobileconfig -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq "configuration_profiles/a954ec5ea-a334-4825-87b3-937e7e381f24" -and $Method -eq 'GET'
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Method -eq 'PATCH' -and $Form.profile.FileName -eq 'passcode.mobileconfig' -and
                (@($Form.labels_include_any) -join ',') -eq 'Engineering,QA' -and
                (@($Form.labels_exclude_any) -join ',') -eq 'Servers' -and
                -not $Form.Contains('labels_include_all')
            }
        }

        It 'replaces labels when one is passed and does not read the profile first' {
            $result = Set-FleetConfigurationProfile -ProfileUuid $script:Uuid -LabelsIncludeAll 'Macs' -SelfService $false -Hidden $true -Confirm:$false
            $result.PSObject.TypeNames | Should -Contain 'FleetDM.ConfigurationProfile'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0 -ParameterFilter { $Method -eq 'GET' }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Method -eq 'PATCH' -and (@($Form.labels_include_all) -join ',') -eq 'Macs' -and
                $Form.self_service -eq $false -and $Form.hidden -eq $true -and
                -not $Form.Contains('labels_include_any') -and -not $Form.Contains('profile')
            }
        }

        It 'clears labels with -ClearLabels and sends no label fields' {
            Set-FleetConfigurationProfile -ProfileUuid $script:Uuid -ClearLabels -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0 -ParameterFilter { $Method -eq 'GET' }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Method -eq 'PATCH' -and $Form.Count -eq 0
            }
        }

        It 'replaces or removes the activation' {
            Set-FleetConfigurationProfile -ProfileUuid $script:Uuid -ActivationPath $script:Activation -LabelsExcludeAny 'Servers' -Confirm:$false | Out-Null
            Set-FleetConfigurationProfile -ProfileUuid $script:Uuid -RemoveActivation -ClearLabels -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Method -eq 'PATCH' -and $Form.activation.FileName -eq 'activation.json'
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Method -eq 'PATCH' -and $Form.activation -is [string] -and $Form.activation -eq ''
            }
        }

        It 'keeps a profile with no current labels untargeted' {
            Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter { $Method -eq 'GET' } {
                return [PSCustomObject]@{ profile_uuid = 'a954ec5ea-a334-4825-87b3-937e7e381f24'; labels_include_all = $null }
            }
            Set-FleetConfigurationProfile -ProfileUuid $script:Uuid -Hidden $false -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Method -eq 'PATCH' -and ($Form.Keys -join ',') -eq 'hidden'
            }
        }

        It 'rejects conflicting switches and warns when nothing changes' {
            { Set-FleetConfigurationProfile -ProfileUuid $script:Uuid -ClearLabels -LabelsIncludeAny 'A' -Confirm:$false } | Should -Throw '*ClearLabels*'
            { Set-FleetConfigurationProfile -ProfileUuid $script:Uuid -RemoveActivation -ActivationPath $script:Activation -Confirm:$false } | Should -Throw '*RemoveActivation*'
            Set-FleetConfigurationProfile -ProfileUuid $script:Uuid -Confirm:$false -WarningVariable warned -WarningAction SilentlyContinue
            "$warned" | Should -Match 'No updates specified'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }

        It 'sends nothing with -WhatIf, including the label read' {
            Set-FleetConfigurationProfile -ProfileUuid $script:Uuid -Path $script:Mobileconfig -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'Remove-FleetConfigurationProfile' {
        It 'deletes the profile and writes the Windows warning' {
            $removed = Remove-FleetConfigurationProfile -ProfileUuid $script:Uuid -Force -WarningVariable warned -WarningAction SilentlyContinue
            $removed.Status | Should -Be 'Removed'
            $removed.ProfileUuid | Should -Be $script:Uuid
            "$warned" | Should -Match 'cleanly removed'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq "configuration_profiles/a954ec5ea-a334-4825-87b3-937e7e381f24" -and $Method -eq 'DELETE'
            }
        }

        It 'writes no warning for an Apple profile' {
            Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell { return $null }
            [PSCustomObject]@{ profile_uuid = $script:Uuid } | Remove-FleetConfigurationProfile -Confirm:$false -WarningVariable warned | Out-Null
            $warned | Should -BeNullOrEmpty
        }

        It 'sends nothing with -WhatIf, even with -Force' {
            Remove-FleetConfigurationProfile -ProfileUuid $script:Uuid -Force -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'Sync-FleetConfigurationProfile' {
        It 'sends base64 profiles, names Windows profiles from the file, and passes dry_run' {
            $result = Sync-FleetConfigurationProfile -Path $script:Mobileconfig, $script:WindowsXml, $script:Mobileconfig -FleetId 2 -DryRun -Confirm:$false
            $result.ProfileCount | Should -Be 2
            $result.DryRun | Should -BeTrue
            $result.FleetId | Should -Be 2
            @($result.Files) | Should -Be @('passcode.mobileconfig', 'firewall.xml')
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $apple = $Body.configuration_profiles[0]
                $windows = $Body.configuration_profiles[1]
                $Endpoint -eq 'configuration_profiles/batch' -and $Method -eq 'POST' -and
                $QueryParameters.fleet_id -eq 2 -and $QueryParameters.dry_run -eq $true -and
                $Body.configuration_profiles.Count -eq 2 -and
                [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($apple.profile)) -eq '<plist>é</plist>' -and
                -not $apple.ContainsKey('name') -and
                $windows.name -eq 'firewall' -and
                [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($windows.profile)) -eq '<Replace/>'
            }
        }

        It 'targets a fleet by name, or unassigned hosts, without dry_run' {
            $named = Sync-FleetConfigurationProfile -Path $script:Mobileconfig -FleetName 'Workstations' -Confirm:$false
            $named.FleetName | Should -Be 'Workstations'
            $named.FleetId | Should -BeNullOrEmpty
            Sync-FleetConfigurationProfile -Path (Join-Path $script:TestRoot '*.xml') -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $QueryParameters.fleet_name -eq 'Workstations' -and -not $QueryParameters.ContainsKey('dry_run')
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $QueryParameters.Count -eq 0 -and $Body.configuration_profiles.Count -eq 1 -and $Body.configuration_profiles[0].name -eq 'firewall'
            }
        }

        It 'refuses a missing file before sending' {
            { Sync-FleetConfigurationProfile -Path (Join-Path $script:TestRoot 'gone.mobileconfig') -FleetId 2 -Confirm:$false } | Should -Throw '*File not found*'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }

        It 'sends nothing with -WhatIf and says unlisted profiles are removed' {
            Sync-FleetConfigurationProfile -Path $script:Mobileconfig -FleetId 2 -WhatIf
            Sync-FleetConfigurationProfile -Path $script:Mobileconfig -FleetId 2 -DryRun -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }

        It 'states in the confirmation text that unlisted profiles are removed' {
            $verbose = Sync-FleetConfigurationProfile -Path $script:Mobileconfig -FleetId 2 -Confirm:$false -Verbose 4>&1 |
                Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
            ($verbose -join "`n") | Should -Match 'Replace all configuration profiles with 1 file\(s\)\. Profiles not in the list are removed'
        }

        It 'does not accept FleetId and FleetName together' {
            { Sync-FleetConfigurationProfile -Path $script:Mobileconfig -FleetId 2 -FleetName 'x' -Confirm:$false } | Should -Throw '*Parameter set cannot be resolved*'
        }
    }

    Context 'Resend, install, and uninstall' {
        It 'resends to each host id, including piped hosts' {
            $sent = @([PSCustomObject]@{ id = 7 }, [PSCustomObject]@{ id = 8 } | Send-FleetConfigurationProfile -ProfileUuid $script:Uuid -Confirm:$false)
            $sent.Count | Should -Be 2
            $sent[1].HostId | Should -Be 8
            Send-FleetConfigurationProfile -ProfileUuid $script:Uuid -HostId 9, 10 -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 4 -Exactly -ParameterFilter {
                $Endpoint -match '^hosts/(7|8|9|10)/configuration_profiles/a954ec5ea-a334-4825-87b3-937e7e381f24/resend$' -and $Method -eq 'POST'
            }
        }

        It 'resends by filter on the resend/batch route' {
            $queued = Send-FleetConfigurationProfile -ProfileUuid $script:Uuid -Filter @{ profile_status = 'failed' } -Confirm:$false
            $queued.Filter.profile_status | Should -Be 'failed'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'configuration_profiles/resend/batch' -and $Method -eq 'POST' -and
                $Body.profile_uuid -eq 'a954ec5ea-a334-4825-87b3-937e7e381f24' -and $Body.filters.profile_status -eq 'failed'
            }
        }

        It 'rejects an unsupported resend filter' {
            { Send-FleetConfigurationProfile -ProfileUuid $script:Uuid -Filter @{ status = 'online' } -Confirm:$false } | Should -Throw '*Unsupported filter key*'
        }

        It 'installs and uninstalls a self-service profile' {
            $installed = Install-FleetConfigurationProfile -HostId 7 -ProfileUuid $script:Uuid -Confirm:$false
            $installed.Action | Should -Be 'Install'
            $removed = [PSCustomObject]@{ id = 7 } | Uninstall-FleetConfigurationProfile -ProfileUuid $script:Uuid -Confirm:$false
            $removed.Action | Should -Be 'Uninstall'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'hosts/7/configuration_profiles/a954ec5ea-a334-4825-87b3-937e7e381f24/install' -and $Method -eq 'POST'
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'hosts/7/configuration_profiles/a954ec5ea-a334-4825-87b3-937e7e381f24/uninstall' -and $Method -eq 'POST'
            }
        }

        It 'sends nothing with -WhatIf' {
            Send-FleetConfigurationProfile -ProfileUuid $script:Uuid -HostId 7 -WhatIf
            Send-FleetConfigurationProfile -ProfileUuid $script:Uuid -Filter @{ profile_status = 'failed' } -WhatIf
            Install-FleetConfigurationProfile -HostId 7 -ProfileUuid $script:Uuid -WhatIf
            Uninstall-FleetConfigurationProfile -HostId 7 -ProfileUuid $script:Uuid -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }
}
