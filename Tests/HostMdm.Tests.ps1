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

Describe 'Host secrets' -Tag 'Unit' {
    It 'reads <Type> from <Path> and returns the <Field> value' -TestCases @(
        @{ Type = 'DiskEncryptionKey'; Path = 'encryption_key'; Field = 'key'; Value = '5ADZ-HTZ8-LJJ4-B2F8'; Pending = $true }
        @{ Type = 'RecoveryLockPassword'; Path = 'recovery_lock_password'; Field = 'password'; Value = 'rl-secret-123'; Pending = $false }
        @{ Type = 'ManagedAccountPassword'; Path = 'managed_account_password'; Field = 'password'; Value = 'ma-secret-456'; Pending = $false }
    ) {
        param($Type, $Path, $Field, $Value, $Pending)
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            $secret = [PSCustomObject]@{ updated_at = '2026-02-01T05:31:43Z' }
            $secret | Add-Member -NotePropertyName $Field -NotePropertyValue $Value
            if ($Pending) { $secret | Add-Member -NotePropertyName rotation_pending -NotePropertyValue $true }
            $response = [PSCustomObject]@{ host_id = 8 }
            $response | Add-Member -NotePropertyName $Path -NotePropertyValue $secret
            return $response
        }

        $output = [PSCustomObject]@{ id = 8 } | Get-FleetHostSecret -Type $Type -Verbose 4>&1
        $result = @($output | Where-Object { $_ -isnot [System.Management.Automation.VerboseRecord] })[0]
        $result.PSObject.TypeNames | Should -Contain 'FleetDM.HostSecret'
        $result.HostId | Should -Be 8
        $result.Type | Should -Be $Type
        $result.Secret | Should -Be $Value
        $result.UpdatedAt | Should -Be '2026-02-01T05:31:43Z'
        $result.RotationPending | Should -Be $Pending
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq "hosts/8/$Path" -and $Method -eq 'GET'
        }
        $logText = ($output | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }) -join "`n"
        $logText | Should -Not -Match ([regex]::Escape($Value))
    }

    It 'keeps a real response secret out of the verbose stream' {
        $hidden = -join ('never', '-log', '-me')
        InModuleScope FleetDM-PowerShell -ArgumentList $hidden {
            param($Hidden)
            $script:HostSecretProbe = $Hidden
            Mock Invoke-RestMethod {
                return [PSCustomObject]@{ host_id = 8; recovery_lock_password = [PSCustomObject]@{ password = $script:HostSecretProbe; updated_at = 'x' } }
            }
            $output = Get-FleetHostSecret -HostId 8 -Type RecoveryLockPassword -Verbose 4>&1
            $logText = ($output | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }) -join "`n"
            $logText | Should -Match 'recovery_lock_password'
            $logText | Should -Not -Match ([regex]::Escape($script:HostSecretProbe))
            @($output | Where-Object { $_ -isnot [System.Management.Automation.VerboseRecord] })[0].Secret | Should -Be $script:HostSecretProbe
        }
    }

    It 'rotates <Type> through <Path>/rotate' -TestCases @(
        @{ Type = 'DiskEncryptionKey'; Path = 'encryption_key' }
        @{ Type = 'RecoveryLockPassword'; Path = 'recovery_lock_password' }
        @{ Type = 'ManagedAccountPassword'; Path = 'managed_account_password' }
    ) {
        param($Type, $Path)
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell { return $null }
        $rotation = Reset-FleetHostSecret -HostId 8 -Type $Type -Force
        $rotation.Status | Should -Be 'RotationRequested'
        $rotation.Type | Should -Be $Type
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq "hosts/8/$Path/rotate" -and $Method -eq 'POST'
        }
    }

    It 'rotates a piped host with -Confirm:$false and sends nothing with -WhatIf' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell { return $null }
        Reset-FleetHostSecret -HostId 8 -Type DiskEncryptionKey -WhatIf
        Reset-FleetHostSecret -HostId 8 -Type DiskEncryptionKey -Force -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        [PSCustomObject]@{ id = 9 } | Reset-FleetHostSecret -Type RecoveryLockPassword -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'hosts/9/recovery_lock_password/rotate'
        }
    }

    It 'rejects an unknown secret type' {
        { Get-FleetHostSecret -HostId 8 -Type 'Password' } | Should -Throw '*Type*'
    }
}

Describe 'Host passcode and MDM commands' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $QueryParameters)
            switch -Regex ($Endpoint) {
                '/clear_passcode$' { return [PSCustomObject]@{ command_uuid = '84F7F777-803E-40BB-8B47-2C0DC8B0118A'; request_type = 'ClearPasscode'; platform = 'ios' } }
                '^commands$' { return @([PSCustomObject]@{ command_uuid = '97ceaa39-eadc-4953-98a8-2ffe72ab120d'; status = 'Pending'; request_type = 'DeviceLock' }) }
                default { return $null }
            }
        }
    }

    It 'clears a passcode and returns the command' {
        $command = Clear-FleetHostPasscode -HostId 123 -Force
        $command.PSObject.TypeNames | Should -Contain 'FleetDM.MdmCommand'
        $command.request_type | Should -Be 'ClearPasscode'
        [PSCustomObject]@{ id = 124 } | Clear-FleetHostPasscode -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'hosts/123/clear_passcode' -and $Method -eq 'POST'
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'hosts/124/clear_passcode'
        }
    }

    It 'sends nothing for Clear-FleetHostPasscode -WhatIf, even with -Force' {
        Clear-FleetHostPasscode -HostId 123 -WhatIf
        Clear-FleetHostPasscode -HostId 123 -Force -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'lists commands for a host with filters and follows pagination' {
        $commands = @(Get-FleetMdmCommand -HostIdentifier 'C02ABC' -RequestType DeviceLock -CommandStatus pending, failed)
        $commands[0].PSObject.TypeNames | Should -Contain 'FleetDM.MdmCommand'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'commands' -and $FollowPagination -and $QueryParameters.host_identifier -eq 'C02ABC' -and
            $QueryParameters.request_type -eq 'DeviceLock' -and (@($QueryParameters.command_status) -join ',') -eq 'pending,failed' -and
            $QueryParameters.per_page -eq 1000
        }
    }

    It 'lists commands for a piped host by hardware serial, or with no host' {
        [PSCustomObject]@{ id = 12; hardware_serial = 'SERIAL1' } | Get-FleetMdmCommand | Out-Null
        Get-FleetMdmCommand | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $QueryParameters.host_identifier -eq 'SERIAL1'
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $QueryParameters.Count -eq 1 -and -not $QueryParameters.ContainsKey('host_identifier')
        }
    }

    It 'cancels a pending command, including one piped from Clear-FleetHostPasscode' {
        $canceled = Stop-FleetHostMdmCommand -HostId 12 -CommandUuid '81e10a70-730b-4c45-9b40-b14373e04757' -Confirm:$false
        $canceled.Status | Should -Be 'Canceled'
        Clear-FleetHostPasscode -HostId 12 -Force | Stop-FleetHostMdmCommand -HostId 12 -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'hosts/12/commands/81e10a70-730b-4c45-9b40-b14373e04757' -and $Method -eq 'DELETE'
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'hosts/12/commands/84F7F777-803E-40BB-8B47-2C0DC8B0118A' -and $Method -eq 'DELETE'
        }
    }

    It 'rejects a malformed command uuid and sends nothing with -WhatIf' {
        { Stop-FleetHostMdmCommand -HostId 12 -CommandUuid '../x' -Confirm:$false } | Should -Throw '*CommandUuid*'
        Stop-FleetHostMdmCommand -HostId 12 -CommandUuid '81e10a70-730b-4c45-9b40-b14373e04757' -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }
}
