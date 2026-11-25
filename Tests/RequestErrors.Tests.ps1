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

    $script:NewFleetHttpError = {
        param([int]$Status, [AllowNull()][string]$Description, [string]$Body)
        $exception = New-Object System.Exception 'HTTP failure'
        $exception | Add-Member -NotePropertyName Response -NotePropertyValue ([PSCustomObject]@{ StatusCode = $Status; StatusDescription = $Description }) -Force
        $record = New-Object System.Management.Automation.ErrorRecord($exception, 'FleetTest', 'InvalidOperation', $null)
        if ($Body) {
            $record.ErrorDetails = New-Object System.Management.Automation.ErrorDetails($Body)
        }
        return $record
    }

    $script:ResolveMessage = {
        param([System.Management.Automation.ErrorRecord]$Record)
        InModuleScope FleetDM-PowerShell -Parameters @{ Record = $Record } {
            param($Record)
            try { Resolve-FleetDMApiError -ErrorRecord $Record -WarningAction SilentlyContinue } catch { $_.Exception.Message }
        }
    }
}

Describe 'Resolve-FleetDMApiError status branches' -Tag 'Unit' {
    It 'maps <Status> to its message' -TestCases @(
        @{ Status = 401; Body = '{"message":"expired"}'; Text = 'Authentication failed. Your session may have expired. Please run Connect-FleetDM again.' }
        @{ Status = 408; Body = '{"message":"slow"}'; Text = 'Request timeout. The operation took too long to complete. Error: slow' }
        @{ Status = 429; Body = '{"message":"limit, retry after: 30s"}'; Text = 'Rate limit exceeded. Retry after 30 seconds.' }
        @{ Status = 429; Body = '{"message":"limit"}'; Text = 'Rate limit exceeded. Please wait before retrying.' }
        @{ Status = 500; Body = '{"message":"boom"}'; Text = 'Internal server error. FleetDM encountered an error. Error: boom' }
        @{ Status = 502; Body = '{"message":"gw"}'; Text = 'Bad gateway. FleetDM service may be temporarily unavailable.' }
        @{ Status = 503; Body = '{"message":"down"}'; Text = 'Service unavailable. FleetDM service is temporarily unavailable.' }
        @{ Status = 400; Body = '{"message":"Bad request","errors":[{"name":"base","reason":"requires a premium license"}]}'; Text = 'This feature requires a Fleet Premium license' }
    ) {
        param($Status, $Body, $Text)
        $record = & $script:NewFleetHttpError $Status 'Status' $Body
        & $script:ResolveMessage $record | Should -BeExactly $Text
    }

    It 'uses the raw body when it is not JSON and there is no status text' {
        $record = & $script:NewFleetHttpError 418 $null 'plain text failure'
        & $script:ResolveMessage $record | Should -BeExactly 'FleetDM API error (HTTP 418): plain text failure'
    }

    It 'falls back to the license text for a 402 with no message' {
        $record = & $script:NewFleetHttpError 402 $null $null
        & $script:ResolveMessage $record | Should -BeExactly 'This feature requires Fleet Premium. Requires Fleet Premium license'
    }
}

Describe 'Get-FleetHttpErrorBody response shapes' -Tag 'Unit' {
    It 'returns null when there is no response' {
        InModuleScope FleetDM-PowerShell {
            $record = New-Object System.Management.Automation.ErrorRecord((New-Object System.Exception 'offline'), 'x', 'InvalidOperation', $null)
            Get-FleetHttpErrorBody -ErrorRecord $record | Should -BeNullOrEmpty
        }
    }

    It 'reads a Windows PowerShell 5.1 response stream from the start' {
        InModuleScope FleetDM-PowerShell {
            $response = [PSCustomObject]@{ StatusCode = 422 }
            $response | Add-Member -MemberType ScriptMethod -Name GetResponseStream -Value {
                $stream = New-Object System.IO.MemoryStream(, [System.Text.Encoding]::UTF8.GetBytes('{"message":"from stream"}'))
                $stream.Position = 5
                return $stream
            }
            $exception = New-Object System.Exception 'x'
            $exception | Add-Member -NotePropertyName Response -NotePropertyValue $response -Force
            $record = New-Object System.Management.Automation.ErrorRecord($exception, 'x', 'InvalidOperation', $null)
            Get-FleetHttpErrorBody -ErrorRecord $record | Should -BeExactly '{"message":"from stream"}'
        }
    }

    It 'returns null when the response stream cannot be read' {
        InModuleScope FleetDM-PowerShell {
            $response = [PSCustomObject]@{ StatusCode = 500 }
            $response | Add-Member -MemberType ScriptMethod -Name GetResponseStream -Value { throw 'closed' }
            $exception = New-Object System.Exception 'x'
            $exception | Add-Member -NotePropertyName Response -NotePropertyValue $response -Force
            $record = New-Object System.Management.Automation.ErrorRecord($exception, 'x', 'InvalidOperation', $null)
            Get-FleetHttpErrorBody -ErrorRecord $record | Should -BeNullOrEmpty
        }
    }

    It 'reads HttpResponseMessage content and survives a content read failure' {
        InModuleScope FleetDM-PowerShell {
            $message = New-Object System.Net.Http.HttpResponseMessage([System.Net.HttpStatusCode]::Conflict)
            $message.Content = New-Object System.Net.Http.StringContent('{"message":"from content"}')
            $exception = New-Object System.Exception 'x'
            $exception | Add-Member -NotePropertyName Response -NotePropertyValue $message -Force
            $record = New-Object System.Management.Automation.ErrorRecord($exception, 'x', 'InvalidOperation', $null)
            Get-FleetHttpErrorBody -ErrorRecord $record | Should -BeExactly '{"message":"from content"}'

            $content = [PSCustomObject]@{ Name = 'broken' }
            $content | Add-Member -MemberType ScriptMethod -Name ReadAsStringAsync -Value { throw 'disposed' }
            $broken = New-Object System.Exception 'x'
            $broken | Add-Member -NotePropertyName Response -NotePropertyValue ([PSCustomObject]@{ StatusCode = 500; Content = $content }) -Force
            $brokenRecord = New-Object System.Management.Automation.ErrorRecord($broken, 'x', 'InvalidOperation', $null)
            Get-FleetHttpErrorBody -ErrorRecord $brokenRecord | Should -BeNullOrEmpty
        }
    }
}

Describe 'Request helper edge cases' -Tag 'Unit' {
    It 'handles empty and null log text' {
        InModuleScope FleetDM-PowerShell {
            Test-FleetSecretLogName -Name '' | Should -BeFalse
            Get-FleetRedactedUriText -Text '' | Should -Be ''
            Format-FleetUnsafeSecretLiteral -Text '' | Should -Be ''
            Get-FleetRedactedLogText -Text $null | Should -BeNullOrEmpty
            Get-FleetRedactedLogText -Text '' | Should -Be ''
            ConvertTo-FleetLogJson -InputObject $null | Should -Be 'null'
        }
    }

    It 'cuts an unparsable secret assignment that is not inside @{}' {
        InModuleScope FleetDM-PowerShell {
            Format-FleetUnsafeSecretLiteral -Text 'user=ada password=hunter2;tail' | Should -Be 'user=ada [REDACTED]'
        }
    }

    It 'redacts text that only looks like JSON' {
        InModuleScope FleetDM-PowerShell {
            Get-FleetRedactedLogText -Text '{not json, password=hunter2' | Should -Not -Match 'hunter2'
        }
    }

    It 'marks a circular reference and falls back to the type name when serialization fails' {
        InModuleScope FleetDM-PowerShell {
            $loop = @{ name = 'a' }
            $loop['self'] = $loop
            ConvertTo-FleetLogJson -InputObject $loop | Should -Match '"\[Circular\]"'

            Mock ConvertTo-Json { '"' + [string]$InputObject + '"' }
            Mock ConvertTo-Json -ParameterFilter { $InputObject -is [System.Text.StringBuilder] } { throw 'cannot serialize' }
            ConvertTo-FleetLogJson -InputObject ([System.Text.StringBuilder]::new()) | Should -Be '"System.Text.StringBuilder"'
        }
    }

    It 'appends query parameters to an endpoint that already has a query' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod { return @{} }
            Invoke-FleetDMRequest -Endpoint 'hosts?order_key=id' -QueryParameters @{ per_page = 5 } | Out-Null
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Uri -like '*hosts?order_key=id&per_page=5' }
        }
    }

    It 'derives a type name from an endpoint and passes null through' {
        InModuleScope FleetDM-PowerShell {
            $hostRecord = [PSCustomObject]@{ id = 1 }
            $other = [PSCustomObject]@{ id = 2 }
            (Add-FleetTypeName -InputObject $hostRecord -Endpoint '/hosts/1').PSObject.TypeNames[0] | Should -Be 'FleetDM.Host'
            (Add-FleetTypeName -InputObject $other -Endpoint 'setup_experience/script').PSObject.TypeNames[0] | Should -Be 'FleetDM.Object'
            Add-FleetTypeName -InputObject $null -TypeName 'FleetDM.Script' | Should -BeNullOrEmpty
        }
    }

    It 'sends an empty body as {} on a change and no body on GET' {
        InModuleScope FleetDM-PowerShell {
            $script:emptyBodies = @{}
            Mock Invoke-RestMethod {
                $script:emptyBodies[[string]$Method] = if ($null -ne $Body) { [string]$Body } else { '<none>' }
                return $null
            }
            Invoke-FleetDMRequest -Endpoint 'conditional_access/google' -Method PATCH -Body @{} | Out-Null
            Invoke-FleetDMRequest -Endpoint 'hosts' -Method GET -Body @{} | Out-Null
            $script:emptyBodies['PATCH'] | Should -BeExactly '{}'
            $script:emptyBodies['GET'] | Should -BeExactly '<none>'
        }
    }

    It 'returns the path when the only query parameter was page' {
        InModuleScope FleetDM-PowerShell {
            Get-FleetUriWithoutPage -Uri 'https://f/api/v1/fleet/hosts?page=3' | Should -Be 'https://f/api/v1/fleet/hosts'
        }
    }

    It 'stops and warns after 1000 pages' {
        InModuleScope FleetDM-PowerShell {
            $script:pageCounter = 0
            Mock Invoke-RestMethod {
                $script:pageCounter++
                return [PSCustomObject]@{
                    hosts = @([PSCustomObject]@{ id = $script:pageCounter })
                    meta = [PSCustomObject]@{ has_next_results = $true }
                }
            }
            $warnings = $null
            $result = Invoke-FleetDMRequest -Endpoint 'hosts' -FollowPagination -WarningVariable warnings -WarningAction SilentlyContinue
            @($result).Count | Should -Be 1000
            "$warnings" | Should -Match 'Stopped pagination after 1000 pages'
        }
    }
}
