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
    $script:TestRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("fleet-scripts-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TestRoot | Out-Null
    $script:ScriptFile = Join-Path $script:TestRoot 'collect.sh'
    [System.IO.File]::WriteAllText($script:ScriptFile, "echo collect`n")
}

AfterAll {
    Remove-Item -LiteralPath $script:TestRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Describe 'Script upload and download' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Form, $QueryParameters, $OutFile)
            if ($OutFile) {
                [System.IO.File]::WriteAllText($OutFile, "echo `"hé`"`n", [System.Text.UTF8Encoding]::new($false))
                return
            }
            switch -Regex ($Endpoint) {
                '^scripts$' {
                    if ($Method -eq 'POST') { return [PSCustomObject]@{ script_id = 31 } }
                    return [PSCustomObject]@{ scripts = @([PSCustomObject]@{ id = 31; name = 'collect.sh' }) }
                }
                '^scripts/\d+$' {
                    return [PSCustomObject]@{ id = 31; name = 'collect.sh'; team_id = 2; updated_at = '2026-11-24T00:00:00Z' }
                }
            }
        }
    }

    It 'uploads a file with fleet_id and returns the new script id' {
        $created = New-FleetScript -Path $script:ScriptFile -FleetId 2 -Confirm:$false
        $created.PSObject.TypeNames | Should -Contain 'FleetDM.Script'
        $created.id | Should -Be 31
        $created.name | Should -Be 'collect.sh'
        $created.fleet_id | Should -Be 2
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'scripts' -and $Method -eq 'POST' -and
            $Form.fleet_id -eq 2 -and $Form.script.FileName -eq 'collect.sh' -and
            [System.Text.Encoding]::UTF8.GetString($Form.script.Bytes) -eq "echo collect`n"
        }
    }

    It 'sends fleet_id 0 when it is bound and omits it when it is not' {
        New-FleetScript -Path $script:ScriptFile -FleetId 0 -Confirm:$false | Out-Null
        $unassigned = New-FleetScript -Path $script:ScriptFile -Confirm:$false
        $unassigned.fleet_id | Should -BeNullOrEmpty
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Form.Contains('fleet_id') -and $Form.fleet_id -eq 0
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            -not $Form.Contains('fleet_id')
        }
    }

    It 'uploads inline contents under the given name as UTF-8' {
        New-FleetScript -Name 'hello.ps1' -Contents 'Write-Output "é"' -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Form.script.FileName -eq 'hello.ps1' -and
            [System.Text.Encoding]::UTF8.GetString($Form.script.Bytes) -eq 'Write-Output "é"'
        }
    }

    It 'rejects a name with a path separator and a missing file' {
        { New-FleetScript -Name 'dir/hello.sh' -Contents 'x' -Confirm:$false } | Should -Throw '*Name*'
        { New-FleetScript -Path (Join-Path $script:TestRoot 'missing.sh') -Confirm:$false } | Should -Throw '*File not found*'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'sends nothing for New-FleetScript -WhatIf' {
        New-FleetScript -Path $script:ScriptFile -FleetId 2 -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'replaces a script from a file or from text and returns the script record' {
        $updated = Set-FleetScript -Id 31 -Path $script:ScriptFile -Confirm:$false
        $updated.PSObject.TypeNames | Should -Contain 'FleetDM.Script'
        [PSCustomObject]@{ id = 31 } | Set-FleetScript -Contents 'echo new' -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 2 -Exactly -ParameterFilter {
            $Endpoint -eq 'scripts/31' -and $Method -eq 'PATCH' -and $Form.script
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            [System.Text.Encoding]::UTF8.GetString($Form.script.Bytes) -eq 'echo new'
        }
    }

    It 'adds id when Fleet 4.96 answers a script update with only script_id' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter { $Method -eq 'PATCH' } {
            return [PSCustomObject]@{ script_id = 31 }
        }
        $updated = Set-FleetScript -Id 31 -Contents 'echo new' -Confirm:$false
        $updated.id | Should -Be 31
        $updated.script_id | Should -Be 31
        $updated.PSObject.TypeNames | Should -Contain 'FleetDM.Script'
        ($updated | Get-FleetScript).name | Should -Be 'collect.sh'
    }

    It 'sends nothing for Set-FleetScript -WhatIf' {
        Set-FleetScript -Id 31 -Contents 'echo new' -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'downloads script contents with alt=media as UTF-8 text' {
        $text = Get-FleetScript -Id 31 -Contents
        $text | Should -BeExactly "echo `"hé`"`n"
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'scripts/31' -and $QueryParameters.alt -eq 'media' -and $OutFile
        }
    }

    It 'gets script metadata by id, and lists one page by fleet' {
        $record = Get-FleetScript -Id 31
        $record.PSObject.TypeNames | Should -Contain 'FleetDM.Script'
        $page = @(Get-FleetScript -FleetId 2 -Page 1 -PerPage 10)
        $page[0].name | Should -Be 'collect.sh'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'scripts' -and $QueryParameters.fleet_id -eq 2 -and $QueryParameters.page -eq 1 -and -not $FollowPagination
        }
    }
}

Describe 'Get-FleetScriptResult' -Tag 'Unit' {
    It 'reads one result without polling' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            return [PSCustomObject]@{ execution_id = 'abc'; exit_code = $null; output = '' }
        }
        Mock Start-Sleep -ModuleName FleetDM-PowerShell { }
        $result = Get-FleetScriptResult -ExecutionId 'abc'
        $result.PSObject.TypeNames | Should -Contain 'FleetDM.ScriptResult'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'scripts/results/abc' -and $Method -eq 'GET'
        }
        Should -Invoke Start-Sleep -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'polls with -Wait until exit_code is set and accepts piped Invoke-FleetScript output' {
        InModuleScope FleetDM-PowerShell { $script:polls = 0 }
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            $script:polls++
            if ($script:polls -lt 3) { return [PSCustomObject]@{ execution_id = 'e 1'; exit_code = $null } }
            return [PSCustomObject]@{ execution_id = 'e 1'; exit_code = 0; output = 'done' }
        }
        Mock Start-Sleep -ModuleName FleetDM-PowerShell { }
        $result = [PSCustomObject]@{ host_id = 2; execution_id = 'e 1' } | Get-FleetScriptResult -Wait -PollIntervalSeconds 1
        $result.exit_code | Should -Be 0
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 3 -Exactly -ParameterFilter {
            $Endpoint -eq 'scripts/results/e%201'
        }
        Should -Invoke Start-Sleep -ModuleName FleetDM-PowerShell -Times 2 -Exactly -ParameterFilter { $Seconds -eq 1 }
    }

    It 'throws when -Wait reaches the timeout' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            return [PSCustomObject]@{ execution_id = 'abc'; exit_code = $null }
        }
        Mock Start-Sleep -ModuleName FleetDM-PowerShell { }
        { Get-FleetScriptResult -ExecutionId 'abc' -Wait -TimeoutSeconds 0 } | Should -Throw '*Timed out after 0 seconds*'
        Should -Invoke Start-Sleep -ModuleName FleetDM-PowerShell -Times 0
    }
}

Describe 'Batch scripts' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Body, $QueryParameters)
            switch -Regex ($Endpoint) {
                '^scripts/run/batch$' { return [PSCustomObject]@{ batch_execution_id = 'b-1' } }
                '^scripts/batch$' { return @([PSCustomObject]@{ batch_execution_id = 'b-1'; status = 'finished' }) }
                '/host_results$' { return @([PSCustomObject]@{ id = 2; script_status = 'errored' }) }
                '/cancel$' { return $null }
                default { return [PSCustomObject]@{ batch_execution_id = 'b-1'; status = 'started'; targeted_host_count = 2 } }
            }
        }
    }

    It 'starts a batch for host ids' {
        $batch = Start-FleetScriptBatch -ScriptId 4 -HostId 2, 3 -Confirm:$false
        $batch.PSObject.TypeNames | Should -Contain 'FleetDM.ScriptBatch'
        $batch.batch_execution_id | Should -Be 'b-1'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'scripts/run/batch' -and $Method -eq 'POST' -and $Body.script_id -eq 4 -and
            (@($Body.host_ids) -join ',') -eq '2,3' -and -not $Body.ContainsKey('filters') -and -not $Body.ContainsKey('not_before')
        }
    }

    It 'collects piped hosts into one batch and drops duplicates' {
        @([PSCustomObject]@{ id = 5 }, [PSCustomObject]@{ id = 6 }, [PSCustomObject]@{ id = 5 }) |
            Start-FleetScriptBatch -ScriptId 4 -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            (@($Body.host_ids) -join ',') -eq '5,6'
        }
    }

    It 'starts a filtered batch with lowercase keys and a UTC not_before' {
        $when = [datetime]::new(2026, 7, 1, 15, 0, 0, [DateTimeKind]::Utc)
        Start-FleetScriptBatch -ScriptId 4 -Filter @{ Label_Id = 7; status = 'online' } -NotBefore $when -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Body.filters.label_id -eq 7 -and $Body.filters.status -eq 'online' -and
            $Body.not_before -eq '2026-07-01T15:00:00Z' -and -not $Body.ContainsKey('host_ids')
        }
    }

    It 'throws when the pipeline gives it no hosts and sends nothing' {
        { @() | Start-FleetScriptBatch -ScriptId 4 -Confirm:$false } | Should -Throw '*No host IDs*'
        { [PSCustomObject]@{ id = 1 }, [PSCustomObject]@{ id = 2 } | Where-Object { $_.id -gt 5 } | Start-FleetScriptBatch -ScriptId 4 -Confirm:$false } | Should -Throw '*empty list*'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'rejects empty, unknown, and blank filters before sending' {
        { Start-FleetScriptBatch -ScriptId 4 -Filter @{} -Confirm:$false } | Should -Throw '*at least one key*'
        { Start-FleetScriptBatch -ScriptId 4 -Filter @{ team = 2 } -Confirm:$false } | Should -Throw "*Unsupported filter key 'team'*"
        { Start-FleetScriptBatch -ScriptId 4 -Filter @{ status = $null } -Confirm:$false } | Should -Throw '*has no value*'
        { Start-FleetScriptBatch -ScriptId 4 -Filter @{ query = ' ' } -Confirm:$false } | Should -Throw '*has no value*'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'does not accept HostId and Filter together' {
        { Start-FleetScriptBatch -ScriptId 4 -HostId 2 -Filter @{ status = 'online' } -Confirm:$false } | Should -Throw '*Parameter set cannot be resolved*'
    }

    It 'sends nothing for Start-FleetScriptBatch -WhatIf' {
        Start-FleetScriptBatch -ScriptId 4 -HostId 2 -WhatIf
        Start-FleetScriptBatch -ScriptId 4 -Filter @{ status = 'online' } -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'lists batches with fleet_id 0 by default and filters by status' {
        $list = @(Get-FleetScriptBatch)
        $list[0].PSObject.TypeNames | Should -Contain 'FleetDM.ScriptBatch'
        Get-FleetScriptBatch -FleetId 2 -Status finished | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'scripts/batch' -and $QueryParameters.fleet_id -eq 0 -and -not $QueryParameters.ContainsKey('status') -and $FollowPagination
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $QueryParameters.fleet_id -eq 2 -and $QueryParameters.status -eq 'finished'
        }
    }

    It 'gets one batch from piped Start-FleetScriptBatch output' {
        $summary = [PSCustomObject]@{ batch_execution_id = 'b-1' } | Get-FleetScriptBatch
        $summary.targeted_host_count | Should -Be 2
        $summary.PSObject.TypeNames | Should -Contain 'FleetDM.ScriptBatch'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'scripts/batch/b-1' -and $Method -eq 'GET'
        }
    }

    It 'lists hosts for a batch with the required status' {
        $hosts = @(Get-FleetScriptBatch -BatchExecutionId 'b-1' -HostResults -HostStatus errored)
        $hosts[0].PSObject.TypeNames | Should -Contain 'FleetDM.ScriptBatchHost'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'scripts/batch/b-1/host_results' -and $QueryParameters.status -eq 'errored' -and $FollowPagination
        }
    }

    It 'cancels a batch and sends nothing with -WhatIf' {
        Stop-FleetScriptBatch -BatchExecutionId 'b-1' -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
        $canceled = [PSCustomObject]@{ batch_execution_id = 'b-1' } | Stop-FleetScriptBatch -Confirm:$false
        $canceled.Status | Should -Be 'Canceled'
        $canceled.BatchExecutionId | Should -Be 'b-1'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'scripts/batch/b-1/cancel' -and $Method -eq 'POST'
        }
    }
}
