BeforeAll {
    . (Join-Path $PSScriptRoot 'TestHelper.ps1')
    $modulePath = Join-Path $PSScriptRoot '../FleetDM-PowerShell.psd1'
    Import-Module $modulePath -Force
    InModuleScope FleetDM-PowerShell {
        $script:FleetDMConnection = @{
            BaseUri = 'https://test.fleetdm.example.com'
            Headers = @{ Authorization = 'Bearer test-token'; 'Content-Type' = 'application/json' }
            Version = '4.96.0'
        }
        $script:FleetDMWebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    }
    $script:TestRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("fleet-software-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TestRoot | Out-Null
    $script:Package = Join-Path $script:TestRoot 'Tool 1.0.pkg'
    [System.IO.File]::WriteAllBytes($script:Package, [byte[]](0..255))
}

AfterAll {
    Remove-Item -LiteralPath $script:TestRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Describe 'Software titles and packages' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Form, $Body, $QueryParameters, $OutFile)
            if ($OutFile) {
                [System.IO.File]::WriteAllBytes($OutFile, [byte[]](9, 8, 7))
                return
            }
            switch -Regex ($Endpoint) {
                '^software/titles$' { return @([PSCustomObject]@{ id = 24; name = 'Tool' }) }
                '^software/titles/\d+$' { return [PSCustomObject]@{ software_title = [PSCustomObject]@{ id = 24; name = 'Tool' } } }
                '^software/package$' { return [PSCustomObject]@{ software_package = [PSCustomObject]@{ title_id = 24; name = 'Tool 1.0.pkg' } } }
                '/package$' { return [PSCustomObject]@{ software_installer = [PSCustomObject]@{ title_id = 24; self_service = $true } } }
                default { return $null }
            }
        }
    }

    Context 'Get-FleetSoftwareTitle' {
        It 'lists every page with the requested filters' {
            $titles = @(Get-FleetSoftwareTitle -FleetId 2 -Query 'tool' -AvailableForInstall -SelfService -PackagesOnly -Platform darwin, windows)
            $titles[0].PSObject.TypeNames | Should -Contain 'FleetDM.SoftwareTitle'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'software/titles' -and $FollowPagination -and
                $QueryParameters.fleet_id -eq 2 -and $QueryParameters.query -eq 'tool' -and
                $QueryParameters.available_for_install -eq $true -and $QueryParameters.self_service -eq $true -and
                $QueryParameters.packages_only -eq $true -and (@($QueryParameters.platform) -join ',') -eq 'darwin,windows' -and
                $QueryParameters.per_page -eq 100
            }
        }

        It 'reads one page without filters' {
            Get-FleetSoftwareTitle -Page 2 -PerPage 5 | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                -not $FollowPagination -and $QueryParameters.page -eq 2 -and $QueryParameters.per_page -eq 5 -and
                -not $QueryParameters.ContainsKey('fleet_id') -and -not $QueryParameters.ContainsKey('available_for_install')
            }
        }

        It 'gets one title by id, including a piped software_title_id' {
            $title = [PSCustomObject]@{ software_title_id = 24 } | Get-FleetSoftwareTitle -FleetId 0
            $title.PSObject.TypeNames | Should -Contain 'FleetDM.SoftwareTitle'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
                $Endpoint -eq 'software/titles/24' -and $QueryParameters.fleet_id -eq 0
            }
        }

        It 'requires FleetId with Platform' {
            { Get-FleetSoftwareTitle -Platform linux } | Should -Throw '*Platform requires FleetId*'
        }
    }

    Context 'New-FleetSoftwarePackage' {
        It 'streams the installer and sends scripts, flags, and one label list' {
            $package = New-FleetSoftwarePackage -Path $script:Package -FleetId 2 -InstallScript 'install' -UninstallScript 'remove' `
                -PreInstallQuery 'SELECT 1;' -PostInstallScript 'post' -SelfService -AutomaticInstall -LabelsExcludeAny 'Servers', 'QA' -Confirm:$false
            $package.PSObject.TypeNames | Should -Contain 'FleetDM.SoftwarePackage'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'software/package' -and $Method -eq 'POST' -and
                $Form.fleet_id -eq 2 -and $Form.software.FileName -eq 'Tool 1.0.pkg' -and $Form.software.Path -eq $script:Package -and
                -not $Form.software.Contains('Bytes') -and
                $Form.install_script -eq 'install' -and $Form.uninstall_script -eq 'remove' -and
                $Form.pre_install_query -eq 'SELECT 1;' -and $Form.post_install_script -eq 'post' -and
                $Form.self_service -eq $true -and $Form.automatic_install -eq $true -and
                (@($Form.labels_exclude_any) -join ',') -eq 'Servers,QA'
            }
        }

        It 'sends only fleet_id and the file by default' {
            New-FleetSoftwarePackage -Path $script:Package -FleetId 0 -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
                ($Form.Keys -join ',') -eq 'fleet_id,software' -and $Form.fleet_id -eq 0
            }
        }

        It 'rejects more than one label list and sends nothing with -WhatIf' {
            { New-FleetSoftwarePackage -Path $script:Package -FleetId 2 -LabelsIncludeAny 'A' -LabelsExcludeAny 'B' -Confirm:$false } |
                Should -Throw '*only one of*'
            New-FleetSoftwarePackage -Path $script:Package -FleetId 2 -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'Set-FleetSoftwarePackage' {
        It 'sends only supplied fields, streams a new file, and returns the installer' {
            $result = [PSCustomObject]@{ software_title_id = 24 } | Set-FleetSoftwarePackage -FleetId 2 -Path $script:Package -DisplayName 'Tool' `
                -Categories 'Security', 'Tools' -InstallScript 'i' -UninstallScript '' -PreInstallQuery 'q' -PostInstallScript 'p' -SelfService $false -LabelsIncludeAll 'Macs' -Confirm:$false
            $result.PSObject.TypeNames | Should -Contain 'FleetDM.SoftwarePackage'
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
                $Endpoint -eq 'software/titles/24/package' -and $Method -eq 'PATCH' -and
                $Form.fleet_id -eq 2 -and $Form.software.Path -eq $script:Package -and $Form.display_name -eq 'Tool' -and
                (@($Form.categories) -join ',') -eq 'Security,Tools' -and $Form.install_script -eq 'i' -and
                $Form.Contains('uninstall_script') -and $Form.uninstall_script -eq '' -and
                $Form.pre_install_query -eq 'q' -and $Form.post_install_script -eq 'p' -and
                $Form.self_service -eq $false -and (@($Form.labels_include_all) -join ',') -eq 'Macs'
            }
        }

        It 'clears categories with an empty array by sending one empty field' {
            Set-FleetSoftwarePackage -SoftwareTitleId 24 -FleetId 2 -Categories @() -Confirm:$false | Out-Null
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
                $Form.categories -is [string] -and $Form.categories -eq '' -and ($Form.Keys -join ',') -eq 'fleet_id,categories'
            }
        }

        It 'warns and sends nothing when no field is supplied, and honors -WhatIf' {
            Set-FleetSoftwarePackage -SoftwareTitleId 24 -FleetId 2 -Confirm:$false -WarningVariable warned -WarningAction SilentlyContinue
            "$warned" | Should -Match 'No updates specified'
            Set-FleetSoftwarePackage -SoftwareTitleId 24 -FleetId 2 -SelfService $true -WhatIf
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        }
    }

    Context 'Save-FleetSoftwarePackage' {
        It 'downloads with alt=media and fleet_id and returns the saved file' {
            $target = Join-Path $script:TestRoot 'download.pkg'
            $file = Save-FleetSoftwarePackage -SoftwareTitleId 24 -FleetId 2 -OutFile $target
            $file.Length | Should -Be 3
            Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
                $Endpoint -eq 'software/titles/24/package' -and $QueryParameters.alt -eq 'media' -and $QueryParameters.fleet_id -eq 2 -and $OutFile -eq $target
            }
        }
    }
}

Describe 'Fleet-maintained and App Store apps' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Body, $QueryParameters)
            switch -Regex ($Endpoint) {
                '^software/fleet_maintained_apps$' {
                    if ($Method -eq 'POST') { return [PSCustomObject]@{ software_title_id = 234 } }
                    return @([PSCustomObject]@{ id = 3; name = '1Password'; platform = 'darwin' })
                }
                '^software/fleet_maintained_apps/\d+$' { return [PSCustomObject]@{ fleet_maintained_app = [PSCustomObject]@{ id = 3; slug = '1password/darwin' } } }
                '^software/app_store_apps$' {
                    if ($Method -eq 'POST') { return [PSCustomObject]@{ software_title_id = 123; name = 'Xcode'; version_id = 41 } }
                    return [PSCustomObject]@{ app_store_apps = @([PSCustomObject]@{ app_store_id = '497799835'; platform = 'ipados'; name = 'Xcode' }) }
                }
                '/app_store_app$' { return [PSCustomObject]@{ app_store_app = [PSCustomObject]@{ id = 41; self_service = $true } } }
            }
        }
    }

    It 'lists Fleet-maintained apps with filters and gets one by id' {
        $apps = @(Get-FleetMaintainedApp -FleetId 2 -Query '1Pass' -Platform darwin -Available)
        $apps[0].PSObject.TypeNames | Should -Contain 'FleetDM.MaintainedApp'
        $one = Get-FleetMaintainedApp -Id 3 -FleetId 2
        $one.slug | Should -Be '1password/darwin'
        Get-FleetMaintainedApp | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'software/fleet_maintained_apps' -and $FollowPagination -and $QueryParameters.fleet_id -eq 2 -and
            $QueryParameters.query -eq '1Pass' -and $QueryParameters.platform -eq 'darwin' -and $QueryParameters.available -eq $true
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'software/fleet_maintained_apps/3' -and $QueryParameters.fleet_id -eq 2
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'software/fleet_maintained_apps' -and $QueryParameters.Count -eq 1
        }
    }

    It 'requires FleetId with Available' {
        { Get-FleetMaintainedApp -Available } | Should -Throw '*Available requires FleetId*'
    }

    It 'adds a piped Fleet-maintained app with scripts and labels' {
        $added = [PSCustomObject]@{ id = 3; name = '1Password' } | Add-FleetMaintainedApp -FleetId 2 -InstallScript 'i' -PreInstallQuery 'q' -PostInstallScript 'p' `
            -SelfService -AutomaticInstall -LabelsIncludeAny 'Eng' -Confirm:$false
        $added.software_title_id | Should -Be 234
        $added.PSObject.TypeNames | Should -Contain 'FleetDM.SoftwareTitleReference'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'software/fleet_maintained_apps' -and $Method -eq 'POST' -and
            $Body.fleet_maintained_app_id -eq 3 -and $Body.fleet_id -eq 2 -and $Body.install_script -eq 'i' -and
            $Body.pre_install_query -eq 'q' -and $Body.post_install_script -eq 'p' -and $Body.self_service -eq $true -and
            $Body.automatic_install -eq $true -and (@($Body.labels_include_any) -join ',') -eq 'Eng'
        }
    }

    It 'adds a Fleet-maintained app with only the required fields and honors -WhatIf' {
        Add-FleetMaintainedApp -Id 3 -FleetId 0 -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        Add-FleetMaintainedApp -Id 3 -FleetId 0 -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter { $Body.Count -eq 2 -and $Body.fleet_id -eq 0 }
    }

    It 'lists App Store apps for a fleet and VPP token' {
        $apps = @(Get-FleetAppStoreApp -FleetId 2 -VppTokenId 1)
        $apps[0].PSObject.TypeNames | Should -Contain 'FleetDM.AppStoreApp'
        Get-FleetAppStoreApp -FleetId 0 | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'software/app_store_apps' -and $QueryParameters.fleet_id -eq 2 -and $QueryParameters.vpp_token_id -eq 1
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $QueryParameters.fleet_id -eq 0 -and -not $QueryParameters.ContainsKey('vpp_token_id')
        }
    }

    It 'adds an App Store app from the pipeline with its platform' {
        $added = Get-FleetAppStoreApp -FleetId 2 | Add-FleetAppStoreApp -FleetId 2 -VppTokenId 1 -SelfService -AutomaticInstall -Categories 'Dev' -LabelsIncludeAll 'Macs' -Confirm:$false
        $added.version_id | Should -Be 41
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'software/app_store_apps' -and $Method -eq 'POST' -and
            $Body.app_store_id -eq '497799835' -and $Body.platform -eq 'ipados' -and $Body.vpp_token_id -eq 1 -and
            $Body.self_service -eq $true -and $Body.automatic_install -eq $true -and (@($Body.categories) -join ',') -eq 'Dev' -and
            (@($Body.labels_include_all) -join ',') -eq 'Macs'
        }
    }

    It 'adds an App Store app with only the required fields and honors -WhatIf' {
        Add-FleetAppStoreApp -AppStoreId '1' -FleetId 2 -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        Add-FleetAppStoreApp -AppStoreId '1' -FleetId 2 -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter { $Method -eq 'POST' -and $Body.Count -eq 2 }
    }

    It 'updates an App Store app version and clears categories with an empty array' {
        $app = Set-FleetAppStoreApp -SoftwareTitleId 3467 -FleetId 2 -VersionId 42 -DisplayName 'Xcode' -SelfService $true -Categories @() -LabelsExcludeAny 'Servers' -Confirm:$false
        $app.PSObject.TypeNames | Should -Contain 'FleetDM.AppStoreApp'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'software/titles/3467/app_store_app' -and $Method -eq 'PATCH' -and
            $Body.fleet_id -eq 2 -and $Body.version_id -eq 42 -and $Body.display_name -eq 'Xcode' -and
            $Body.self_service -eq $true -and $Body.categories.Count -eq 0 -and $Body.categories -is [array] -and
            (@($Body.labels_exclude_any) -join ',') -eq 'Servers'
        }
    }

    It 'warns when only the version is supplied and honors -WhatIf' {
        Set-FleetAppStoreApp -SoftwareTitleId 3467 -FleetId 2 -VersionId 42 -Confirm:$false -WarningVariable warned -WarningAction SilentlyContinue
        "$warned" | Should -Match 'No updates specified'
        Set-FleetAppStoreApp -SoftwareTitleId 3467 -FleetId 2 -SelfService $true -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }
}

Describe 'Software package upload over HTTP' -Tag 'Unit' {
    It 'streams the installer bytes and fields to the server unchanged' {
        $server = Start-FleetTestListener -ResponseBody '{"software_package":{"title_id":77,"name":"Tool 1.0.pkg"}}'
        try {
            $package = InModuleScope FleetDM-PowerShell -Parameters @{ Base = $server.BaseUri; Package = $script:Package } {
                param($Base, $Package)
                $script:FleetDMConnection.BaseUri = $Base
                New-FleetSoftwarePackage -Path $Package -FleetId 3 -SelfService -LabelsIncludeAny 'A', 'B' -Confirm:$false
            }
            $package.title_id | Should -Be 77
            $server.State.Url | Should -Be '/api/v1/fleet/software/package'
            $server.State.ContentType -match 'boundary=(.+)$' | Should -BeTrue
            $boundary = $Matches[1]
            $text = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($server.State.Body)
            $text | Should -Match ([regex]::Escape("name=`"fleet_id`"`r`n`r`n3`r`n"))
            $text | Should -Match ([regex]::Escape("name=`"self_service`"`r`n`r`ntrue`r`n"))
            ([regex]::Matches($text, 'name="labels_include_any"')).Count | Should -Be 2
            $marker = "filename=`"Tool 1.0.pkg`"`r`nContent-Type: application/octet-stream`r`n`r`n"
            $start = $text.IndexOf($marker) + $marker.Length
            $payload = [byte[]]$server.State.Body[$start..($start + 255)]
            [System.Linq.Enumerable]::SequenceEqual($payload, [byte[]](0..255)) | Should -BeTrue
            $text.EndsWith("--$boundary--`r`n") | Should -BeTrue
        }
        finally {
            Stop-FleetTestListener -Server $server
            InModuleScope FleetDM-PowerShell { $script:FleetDMConnection.BaseUri = 'https://test.fleetdm.example.com' }
        }
    }
}
