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

Describe 'Invoke-FleetHostWipe' -Tag 'Unit' {
    It 'sends no request when WhatIf is set' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            throw 'request should not be sent'
        }

        { Invoke-FleetHostWipe -Id 5 -WhatIf } | Should -Not -Throw
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'sends no request when Force is combined with WhatIf' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            throw 'request should not be sent'
        }

        { Invoke-FleetHostWipe -Id 5 -Force -WhatIf } | Should -Not -Throw
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'posts a wipe with no body when WindowsWipeType is omitted' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            return [PSCustomObject]@{
                device_status = 'unlocked'
                pending_action = 'wipe'
            }
        }

        $result = Invoke-FleetHostWipe -Id 9 -Force
        $result.pending_action | Should -Be 'wipe'
        $result.PSObject.TypeNames | Should -Contain 'FleetDM.HostWipe'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -ParameterFilter {
            $Endpoint -eq 'hosts/9/wipe' -and $Method -eq 'POST' -and $null -eq $Body
        }
    }

    It 'sends the Windows doWipeProtected body' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            return [PSCustomObject]@{ device_status = 'unlocked'; pending_action = 'wipe' }
        }

        Invoke-FleetHostWipe -Id 45 -WindowsWipeType doWipeProtected -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'hosts/45/wipe' -and
            $Method -eq 'POST' -and
            $Body.windows.wipe_type -eq 'doWipeProtected'
        }
    }

    It 'sends the Windows doWipe body' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            return [PSCustomObject]@{ device_status = 'unlocked'; pending_action = 'wipe' }
        }

        Invoke-FleetHostWipe -Id 45 -WindowsWipeType doWipe -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Body.windows.wipe_type -eq 'doWipe'
        }
    }

    It 'rejects a Windows wipe type outside the API set' {
        { Invoke-FleetHostWipe -Id 1 -WindowsWipeType factoryReset -Confirm:$false } |
            Should -Throw '*doWipe*'
    }

    It 'surfaces HTTP 402 as a Fleet Premium error' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod {
                $response = [PSCustomObject]@{
                    StatusCode = 402
                    StatusDescription = 'Payment Required'
                }
                $ex = New-Object System.Exception 'Payment Required'
                $ex | Add-Member -NotePropertyName Response -NotePropertyValue $response -Force
                throw $ex
            }

            { Invoke-FleetHostWipe -Id 1 -Force } | Should -Throw '*Fleet Premium*'
        }
    }

    It 'surfaces an HTTP 403 license response as a Fleet Premium error' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod {
                $response = [PSCustomObject]@{
                    StatusCode = 403
                    StatusDescription = 'Missing or invalid license. Wipe command is available in Fleet Premium only.'
                }
                $ex = New-Object System.Exception 'Missing or invalid license. Wipe command is available in Fleet Premium only.'
                $ex | Add-Member -NotePropertyName Response -NotePropertyValue $response -Force
                throw $ex
            }

            { Invoke-FleetHostWipe -Id 1 -Force } | Should -Throw '*Fleet Premium*'
        }
    }
}

Describe 'Get-FleetHostWipeStatus' -Tag 'Unit' {
    It 'reads device_status and pending_action from the host MDM object' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            return @{
                host = [PSCustomObject]@{
                    id = 123
                    hostname = 'anna-mac'
                    mdm = [PSCustomObject]@{
                        device_status = 'wiping'
                        pending_action = 'wipe'
                    }
                }
            }
        }

        $status = 123 | Get-FleetHostWipeStatus
        $status.HostId | Should -Be 123
        $status.Hostname | Should -Be 'anna-mac'
        $status.DeviceStatus | Should -Be 'wiping'
        $status.PendingAction | Should -Be 'wipe'
        $status.PSObject.TypeNames | Should -Contain 'FleetDM.HostWipeStatus'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'hosts/123' -and $Method -eq 'GET'
        }
    }
}
