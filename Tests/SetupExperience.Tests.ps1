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
    $script:TestRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("fleet-setup-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TestRoot | Out-Null
    $script:SetupScript = Join-Path $script:TestRoot 'setup.sh'
    $script:EulaPdf = Join-Path $script:TestRoot 'eula.pdf'
    $script:Bootstrap = Join-Path $script:TestRoot 'bootstrap.pkg'
    [System.IO.File]::WriteAllText($script:SetupScript, 'echo setup')
    [System.IO.File]::WriteAllBytes($script:EulaPdf, [byte[]](37, 80, 68, 70))
    [System.IO.File]::WriteAllBytes($script:Bootstrap, [byte[]](1, 2, 3))
}

AfterAll {
    Remove-Item -LiteralPath $script:TestRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Describe 'Setup experience cmdlets' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Form, $Body, $QueryParameters, $OutFile)
            if ($OutFile) {
                [System.IO.File]::WriteAllText($OutFile, 'downloaded')
                return
            }
            switch -Regex ($Endpoint) {
                '^setup_experience/software$' {
                    if ($Method -eq 'PUT') { return [PSCustomObject]@{} }
                    return @([PSCustomObject]@{ id = 12; name = 'Firefox.app'; software_package = [PSCustomObject]@{ install_during_setup = $true } })
                }
                '^setup_experience/script$' {
                    if ($Method -eq 'GET') { return [PSCustomObject]@{ id = 1; name = 'setup.sh'; fleet_id = 3 } }
                    return $null
                }
                '^setup_experience/eula/metadata$' { return [PSCustomObject]@{ name = 'eula.pdf'; token = 'AA598E2A-7952'; platform = 'darwin' } }
                '^bootstrap/\d+/metadata$' { return [PSCustomObject]@{ name = 'bootstrap.pkg'; fleet_id = 0; sha256 = 'abc'; token = 'T' } }
                default { return $null }
            }
        }
    }

    Context 'Setup software' {
        It 'lists setup software with fleet_id 0 by default and passes platforms' {
            $titles = @(Get-FleetSetupExperienceSoftware)
            $titles[0].PSObject.TypeNames | Should -Contain 'FleetDM.SetupExperienceSoftware'
            Get-FleetSetupExperienceSoftware -FleetId 2 -Platform linux, windows | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/software' -and $QueryParameters.fleet_id -eq 0 -and -not $QueryParameters.ContainsKey('platform') -and $FollowPagination
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $QueryParameters.fleet_id -eq 2 -and (@($QueryParameters.platform) -join ',') -eq 'linux,windows'
            }
        }

        It 'replaces setup software with the given titles' {
            $result = Set-FleetSetupExperienceSoftware -FleetId 1 -Platform linux -SoftwareTitleId 3000, 3001 -Confirm:$false
            $result.Platform | Should -Be 'linux'
            @($result.SoftwareTitleId) | Should -Be @(3000, 3001)
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/software' -and $Method -eq 'PUT' -and $Body.fleet_id -eq 1 -and
                $Body.platform -eq 'linux' -and (@($Body.software_title_ids) -join ',') -eq '3000,3001'
            }
        }

        It 'collects piped titles into one request' {
            @([PSCustomObject]@{ id = 5 }, [PSCustomObject]@{ software_title_id = 6 }, [PSCustomObject]@{ id = 5 }) |
                Set-FleetSetupExperienceSoftware -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Body.fleet_id -eq 0 -and -not $Body.ContainsKey('platform') -and (@($Body.software_title_ids) -join ',') -eq '5,6'
            }
        }

        It 'throws when the pipeline gives it no titles and does not clear' {
            { @() | Set-FleetSetupExperienceSoftware -FleetId 2 -Platform linux -Confirm:$false } | Should -Throw '*Pass -Clear*'
            { 1, 2 | Where-Object { $_ -gt 5 } | ForEach-Object { [PSCustomObject]@{ id = $_ } } | Set-FleetSetupExperienceSoftware -Confirm:$false } | Should -Throw '*No software titles*'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }

        It 'sends an empty list with -Clear' {
            $result = Set-FleetSetupExperienceSoftware -FleetId 2 -Platform windows -Clear -Confirm:$false
            @($result.SoftwareTitleId).Count | Should -Be 0
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Body.software_title_ids -is [array] -and $Body.software_title_ids.Count -eq 0 -and $Body.platform -eq 'windows'
            }
        }

        It 'sends nothing with -WhatIf' {
            Set-FleetSetupExperienceSoftware -SoftwareTitleId 1 -WhatIf
            Set-FleetSetupExperienceSoftware -Clear -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'Setup script' {
        It 'gets the script metadata for a fleet and for unassigned hosts' {
            $script = Get-FleetSetupExperienceScript -FleetId 3
            $script.PSObject.TypeNames | Should -Contain 'FleetDM.SetupExperienceScript'
            Get-FleetSetupExperienceScript | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/script' -and $QueryParameters.fleet_id -eq 3
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/script' -and $QueryParameters.Count -eq 0
            }
        }

        It 'downloads the script contents with alt=media' {
            Get-FleetSetupExperienceScript -FleetId 3 -Contents | Should -Be 'downloaded'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
                $QueryParameters.alt -eq 'media' -and $QueryParameters.fleet_id -eq 3 -and $OutFile
            }
        }

        It 'uploads a script file or inline contents' {
            $uploaded = Set-FleetSetupExperienceScript -FleetId 3 -Path $script:SetupScript -Confirm:$false
            $uploaded.name | Should -Be 'setup.sh'
            $uploaded.fleet_id | Should -Be 3
            $inline = Set-FleetSetupExperienceScript -Name 'inline.sh' -Contents 'echo inline' -Confirm:$false
            $inline.fleet_id | Should -BeNullOrEmpty
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/script' -and $Method -eq 'POST' -and $Form.fleet_id -eq 3 -and $Form.script.FileName -eq 'setup.sh'
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Method -eq 'POST' -and -not $Form.Contains('fleet_id') -and [System.Text.Encoding]::UTF8.GetString($Form.script.Bytes) -eq 'echo inline'
            }
        }

        It 'deletes the script for a fleet and for unassigned hosts' {
            $removed = Remove-FleetSetupExperienceScript -FleetId 3 -Force
            $removed.FleetId | Should -Be 3
            (Remove-FleetSetupExperienceScript -Confirm:$false).FleetId | Should -BeNullOrEmpty
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/script' -and $Method -eq 'DELETE' -and $QueryParameters.fleet_id -eq 3
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Method -eq 'DELETE' -and $QueryParameters.Count -eq 0
            }
        }

        It 'sends nothing with -WhatIf' {
            Set-FleetSetupExperienceScript -Path $script:SetupScript -WhatIf
            Remove-FleetSetupExperienceScript -FleetId 3 -Force -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'EULA' {
        It 'gets EULA metadata for a platform' {
            $eula = Get-FleetEula -Platform windows
            $eula.PSObject.TypeNames | Should -Contain 'FleetDM.Eula'
            Get-FleetEula | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/eula/metadata' -and $QueryParameters.platform -eq 'windows'
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/eula/metadata' -and $QueryParameters.Count -eq 0
            }
        }

        It 'downloads the EULA by the token from its metadata' {
            $target = Join-Path $script:TestRoot 'eula-download.pdf'
            $file = Get-FleetEula -OutFile $target
            $file.FullName | Should -Be $target
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/eula/AA598E2A-7952' -and $OutFile -eq $target
            }
        }

        It 'uploads a EULA with and without a platform' {
            $set = Set-FleetEula -Path $script:EulaPdf -Confirm:$false
            $set.platform | Should -Be 'darwin'
            (Set-FleetEula -Path $script:EulaPdf -Platform windows -Confirm:$false).platform | Should -Be 'windows'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/eula' -and $Method -eq 'POST' -and $Form.eula.FileName -eq 'eula.pdf' -and -not $Form.Contains('platform')
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Method -eq 'POST' -and $Form.platform -eq 'windows'
            }
        }

        It 'resolves the token from metadata before deleting' {
            $removed = Remove-FleetEula -Platform windows -Force
            $removed.Token | Should -Be 'AA598E2A-7952'
            Remove-FleetEula -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/eula/metadata' -and $QueryParameters.platform -eq 'windows'
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 2 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/eula/AA598E2A-7952' -and $Method -eq 'DELETE'
            }
        }

        It 'deletes a piped EULA by token without a metadata lookup' {
            [PSCustomObject]@{ token = 'TOKEN-2' } | Remove-FleetEula -Force | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0 -ParameterFilter { $Endpoint -like '*metadata' }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'setup_experience/eula/TOKEN-2' -and $Method -eq 'DELETE'
            }
        }

        It 'sends nothing with -WhatIf, including the token lookup' {
            Set-FleetEula -Path $script:EulaPdf -WhatIf
            Remove-FleetEula -WhatIf
            Remove-FleetEula -Token 'T' -Force -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'Bootstrap package' {
        It 'reads metadata on bootstrap/0/metadata and passes for_update' {
            $package = Get-FleetBootstrapPackage -FleetId 0
            $package.PSObject.TypeNames | Should -Contain 'FleetDM.BootstrapPackage'
            Get-FleetBootstrapPackage -FleetId 4 -ForUpdate | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'bootstrap/0/metadata' -and $QueryParameters.Count -eq 0
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'bootstrap/4/metadata' -and $QueryParameters.for_update -eq $true
            }
        }

        It 'streams the package with fleet_id and manual_agent_install' {
            $uploaded = Set-FleetBootstrapPackage -FleetId 0 -Path $script:Bootstrap -ManualAgentInstall -Confirm:$false
            $uploaded.name | Should -Be 'bootstrap.pkg'
            Set-FleetBootstrapPackage -FleetId 1 -Path $script:Bootstrap -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'bootstrap' -and $Method -eq 'POST' -and $Form.fleet_id -eq 0 -and
                $Form.package.Path -eq $script:Bootstrap -and $Form.manual_agent_install -eq $true
            }
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Form.fleet_id -eq 1 -and -not $Form.Contains('manual_agent_install')
            }
        }

        It 'deletes bootstrap/0 for unassigned hosts, including from piped metadata' {
            $removed = Remove-FleetBootstrapPackage -FleetId 0 -Force
            $removed.FleetId | Should -Be 0
            Get-FleetBootstrapPackage -FleetId 0 | Remove-FleetBootstrapPackage -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 2 -Exactly -ParameterFilter {
                $Endpoint -eq 'bootstrap/0' -and $Method -eq 'DELETE'
            }
        }

        It 'sends nothing with -WhatIf' {
            Set-FleetBootstrapPackage -FleetId 0 -Path $script:Bootstrap -WhatIf
            Remove-FleetBootstrapPackage -FleetId 0 -Force -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }
}
