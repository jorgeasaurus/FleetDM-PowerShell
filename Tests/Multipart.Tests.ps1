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
    $script:TestRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("fleet-multipart-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TestRoot | Out-Null
}

AfterAll {
    Remove-Item -LiteralPath $script:TestRoot -Recurse -Force -ErrorAction SilentlyContinue
    InModuleScope FleetDM-PowerShell {
        $script:FleetDMConnection = @{
            BaseUri = 'https://test.fleetdm.example.com'
            Headers = @{ Authorization = 'Bearer test-token' }
            Version = '4.96.0'
        }
    }
}

Describe 'Multipart body builder' -Tag 'Unit' {
    It 'writes CRLF parts, lowercase booleans, repeated list fields, and no null fields' {
        InModuleScope FleetDM-PowerShell {
            $form = [ordered]@{
                fleet_id = 2
                self_service = $true
                hidden = [switch]$false
                labels_include_any = @('Engineering', $null, 'QA')
                skipped = $null
                script = @{ FileName = 'run.sh'; Bytes = [System.Text.Encoding]::UTF8.GetBytes('echo hi') }
            }
            $content = New-FleetMultipartContent -Form $form -Boundary 'XyZ'
            $text = [System.Text.Encoding]::UTF8.GetString($content.Bytes)
            $expected = (
                "--XyZ`r`nContent-Disposition: form-data; name=`"fleet_id`"`r`n`r`n2`r`n" +
                "--XyZ`r`nContent-Disposition: form-data; name=`"self_service`"`r`n`r`ntrue`r`n" +
                "--XyZ`r`nContent-Disposition: form-data; name=`"hidden`"`r`n`r`nfalse`r`n" +
                "--XyZ`r`nContent-Disposition: form-data; name=`"labels_include_any`"`r`n`r`nEngineering`r`n" +
                "--XyZ`r`nContent-Disposition: form-data; name=`"labels_include_any`"`r`n`r`nQA`r`n" +
                "--XyZ`r`nContent-Disposition: form-data; name=`"script`"; filename=`"run.sh`"`r`nContent-Type: application/octet-stream`r`n`r`necho hi`r`n" +
                "--XyZ--`r`n"
            )
            $text | Should -BeExactly $expected
            $content.ContentType | Should -Be 'multipart/form-data; boundary=XyZ'
            $content.Path | Should -BeNullOrEmpty
            $content.Summary | Should -Contain 'script=<file 7 bytes>'
            $content.Summary | Should -Contain 'fleet_id=<1 bytes>'
        }
    }

    It 'still emits a field whose value is an empty string' {
        InModuleScope FleetDM-PowerShell {
            $content = New-FleetMultipartContent -Form ([ordered]@{ categories = ''; activation = '' }) -Boundary 'E'
            [System.Text.Encoding]::UTF8.GetString($content.Bytes) | Should -BeExactly (
                "--E`r`nContent-Disposition: form-data; name=`"categories`"`r`n`r`n`r`n" +
                "--E`r`nContent-Disposition: form-data; name=`"activation`"`r`n`r`n`r`n" +
                "--E--`r`n"
            )
            New-FleetMultipartContent -Form @{ categories = @() } -Boundary 'E' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString($_.Bytes) } | Should -BeExactly "--E--`r`n"
        }
    }

    It 'encodes UTF-8, strips quotes from names, and keeps a custom part content type' {
        InModuleScope FleetDM-PowerShell {
            $form = @{
                'na"me' = 'hé'
                profile = @{ FileName = "caf`"é.mobileconfig"; Bytes = [byte[]](1, 2); ContentType = 'application/x-apple-aspen-config' }
            }
            $content = New-FleetMultipartContent -Form $form
            $text = [System.Text.Encoding]::UTF8.GetString($content.Bytes)
            $text | Should -Match 'name="name"\r\n\r\nhé\r\n'
            $text | Should -Match 'filename="café\.mobileconfig"\r\nContent-Type: application/x-apple-aspen-config'
            $content.Boundary | Should -Match '^FleetDMPowerShell[0-9a-f]{32}$'
        }
    }

    It 'keeps every byte value of a binary file part intact' {
        InModuleScope FleetDM-PowerShell {
            [byte[]]$binary = 0..255
            $content = New-FleetMultipartContent -Form @{ software = @{ FileName = 'a.bin'; Bytes = $binary } } -Boundary 'B'
            $head = [System.Text.Encoding]::UTF8.GetBytes("--B`r`nContent-Disposition: form-data; name=`"software`"; filename=`"a.bin`"`r`nContent-Type: application/octet-stream`r`n`r`n")
            $slice = $content.Bytes[$head.Length..($head.Length + 255)]
            [System.Linq.Enumerable]::SequenceEqual([byte[]]$slice, $binary) | Should -BeTrue
        }
    }

    It 'streams a Path part through a temporary file' {
        $source = Join-Path $script:TestRoot 'package.pkg'
        [System.IO.File]::WriteAllBytes($source, [byte[]](0..255))
        InModuleScope FleetDM-PowerShell -Parameters @{ Source = $source } {
            param($Source)
            $content = New-FleetMultipartContent -Form @{ software = @{ FileName = 'package.pkg'; Path = $Source } } -Boundary 'S'
            try {
                $content.Bytes | Should -BeNullOrEmpty
                Test-Path -LiteralPath $content.Path | Should -BeTrue
                $written = [System.IO.File]::ReadAllBytes($content.Path)
                $head = [System.Text.Encoding]::UTF8.GetBytes("--S`r`nContent-Disposition: form-data; name=`"software`"; filename=`"package.pkg`"`r`nContent-Type: application/octet-stream`r`n`r`n")
                $written.Length | Should -Be ($head.Length + 256 + "`r`n--S--`r`n".Length)
                [System.Linq.Enumerable]::SequenceEqual([byte[]]$written[$head.Length..($head.Length + 255)], [byte[]](0..255)) | Should -BeTrue
                $content.Summary | Should -Be 'software=<file 256 bytes>'
            }
            finally {
                Remove-Item -LiteralPath $content.Path -Force
            }
        }
    }

    It 'removes the temporary file when a Path part cannot be read' {
        InModuleScope FleetDM-PowerShell {
            $script:removedPath = $null
            Mock Remove-Item { $script:removedPath = $LiteralPath }
            $missing = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString('N'))
            { New-FleetMultipartContent -Form @{ software = @{ FileName = 'x.pkg'; Path = $missing } } } | Should -Throw
            Should -Invoke Remove-Item -Times 1
            $script:removedPath | Should -BeLike ([System.IO.Path]::GetTempPath() + '*')
            [System.IO.File]::Delete($script:removedPath)
        }
    }

    It 'treats only dictionaries with FileName and Bytes or Path as files' {
        InModuleScope FleetDM-PowerShell {
            Test-FleetFormFile -Value @{ FileName = 'a'; Bytes = [byte[]]@() } | Should -BeTrue
            Test-FleetFormFile -Value @{ FileName = 'a'; Path = '/tmp/a' } | Should -BeTrue
            Test-FleetFormFile -Value @{ FileName = 'a' } | Should -BeFalse
            Test-FleetFormFile -Value 'a' | Should -BeFalse
            Test-FleetFormFile -Value $null | Should -BeFalse
        }
    }

    It 'formats numbers with the invariant culture' {
        InModuleScope FleetDM-PowerShell {
            $previous = [System.Globalization.CultureInfo]::CurrentCulture
            [System.Globalization.CultureInfo]::CurrentCulture = [System.Globalization.CultureInfo]::GetCultureInfo('de-DE')
            try {
                ConvertTo-FleetFormText -Value ([double]1.5) | Should -Be '1.5'
            }
            finally {
                [System.Globalization.CultureInfo]::CurrentCulture = $previous
            }
        }
    }

    It 'copies headers without Content-Type' {
        InModuleScope FleetDM-PowerShell {
            $copy = Copy-FleetHeaderWithoutContentType -Headers @{ Authorization = 'Bearer x'; 'Content-Type' = 'application/json' }
            $copy.Keys | Should -Not -Contain 'Content-Type'
            $copy.Authorization | Should -Be 'Bearer x'
            (Copy-FleetHeaderWithoutContentType -Headers $null).Count | Should -Be 0
        }
    }
}

Describe 'Invoke-FleetDMRequest multipart and download transport' -Tag 'Unit' {
    It 'sends a byte body with a boundary content type and headers without application/json' {
        InModuleScope FleetDM-PowerShell {
            $script:sent = $null
            Mock Invoke-RestMethod {
                $script:sent = @{ Body = $Body; ContentType = $ContentType; Headers = $Headers; InFile = $InFile; Method = $Method }
                return [PSCustomObject]@{ script_id = 5 }
            }
            $verbose = Invoke-FleetDMRequest -Endpoint 'scripts' -Method POST -Form @{
                fleet_id = 3
                script = @{ FileName = 'a.sh'; Bytes = [System.Text.Encoding]::UTF8.GetBytes('secret-script-text') }
            } -Verbose 4>&1
            $result = @($verbose | Where-Object { $_ -isnot [System.Management.Automation.VerboseRecord] })
            $result[0].script_id | Should -Be 5
            $script:sent.Body | Should -BeOfType [byte]
            $script:sent.ContentType | Should -Match '^multipart/form-data; boundary=FleetDMPowerShell'
            $script:sent.Headers.Keys | Should -Not -Contain 'Content-Type'
            $script:sent.Headers.Authorization | Should -Be 'Bearer test-token'
            $script:sent.InFile | Should -BeNullOrEmpty
            $logText = ($verbose | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }) -join "`n"
            $logText | Should -Match 'Multipart form: .*fleet_id=<1 bytes>'
            $logText | Should -Match 'Multipart form: .*script=<file 18 bytes>'
            $logText | Should -Not -Match 'secret-script-text'
        }
    }

    It 'streams a Path part with -InFile and deletes the temporary file afterwards' {
        $source = Join-Path $script:TestRoot 'stream.pkg'
        [System.IO.File]::WriteAllBytes($source, [byte[]](1..64))
        InModuleScope FleetDM-PowerShell -Parameters @{ Source = $source } {
            param($Source)
            $script:inFile = $null
            $script:inFileLength = 0
            Mock Invoke-RestMethod {
                $script:inFile = $InFile
                $script:inFileLength = (Get-Item -LiteralPath $InFile).Length
                return $null
            }
            Invoke-FleetDMRequest -Endpoint 'software/package' -Method POST -Form @{ software = @{ FileName = 'stream.pkg'; Path = $Source } } | Out-Null
            $script:inFile | Should -Not -BeNullOrEmpty
            $script:inFileLength | Should -BeGreaterThan 64
            Test-Path -LiteralPath $script:inFile | Should -BeFalse
        }
    }

    It 'deletes the temporary file when the upload fails' {
        $source = Join-Path $script:TestRoot 'fail.pkg'
        [System.IO.File]::WriteAllBytes($source, [byte[]](1..8))
        InModuleScope FleetDM-PowerShell -Parameters @{ Source = $source } {
            param($Source)
            $script:inFile = $null
            Mock Invoke-RestMethod {
                $script:inFile = $InFile
                throw 'network down'
            }
            { Invoke-FleetDMRequest -Endpoint 'software/package' -Method POST -Form @{ software = @{ FileName = 'fail.pkg'; Path = $Source } } } |
                Should -Throw '*Failed to communicate with FleetDM*'
            Test-Path -LiteralPath $script:inFile | Should -BeFalse
        }
    }

    It 'passes OutFile to Invoke-RestMethod' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod { return $null }
            Invoke-FleetDMRequest -Endpoint 'scripts/1' -QueryParameters @{ alt = 'media' } -OutFile '/tmp/out.sh' | Out-Null
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                $OutFile -eq '/tmp/out.sh' -and $Uri -like '*scripts/1?alt=media'
            }
        }
    }

    It 'delivers the exact multipart bytes to an HTTP server from memory and from disk' {
        $source = Join-Path $script:TestRoot 'wire.bin'
        [byte[]]$binary = 0..255
        [System.IO.File]::WriteAllBytes($source, $binary)

        foreach ($mode in 'Bytes', 'Path') {
            $server = Start-FleetTestListener -ResponseBody '{"script_id":9}'
            try {
                InModuleScope FleetDM-PowerShell -Parameters @{ Base = $server.BaseUri; Source = $source; Mode = $mode; Binary = $binary } {
                    param($Base, $Source, $Mode, $Binary)
                    $script:FleetDMConnection.BaseUri = $Base
                    $file = if ($Mode -eq 'Path') { @{ FileName = 'wire.bin'; Path = $Source } } else { @{ FileName = 'wire.bin'; Bytes = $Binary } }
                    $result = Invoke-FleetDMRequest -Endpoint 'scripts' -Method POST -Form @{ script = $file }
                    $result.script_id | Should -Be 9
                }
                $server.State.Method | Should -Be 'POST'
                $server.State.Url | Should -Be '/api/v1/fleet/scripts'
                $server.State.Authorization | Should -Be 'Bearer test-token'
                $server.State.ContentType -match '^multipart/form-data; boundary=(.+)$' | Should -BeTrue
                $boundary = $Matches[1]
                $head = [System.Text.Encoding]::UTF8.GetBytes("--$boundary`r`nContent-Disposition: form-data; name=`"script`"; filename=`"wire.bin`"`r`nContent-Type: application/octet-stream`r`n`r`n")
                $tail = [System.Text.Encoding]::UTF8.GetBytes("`r`n--$boundary--`r`n")
                $server.State.Body.Length | Should -Be ($head.Length + 256 + $tail.Length)
                $payload = [byte[]]$server.State.Body[$head.Length..($head.Length + 255)]
                [System.Linq.Enumerable]::SequenceEqual($payload, $binary) | Should -BeTrue
            }
            finally {
                Stop-FleetTestListener -Server $server
                InModuleScope FleetDM-PowerShell { $script:FleetDMConnection.BaseUri = 'https://test.fleetdm.example.com' }
            }
        }
    }

    It 'downloads UTF-8 text through OutFile without Latin-1 decoding' {
        $server = Start-FleetTestListener -ResponseBytes ([System.Text.Encoding]::UTF8.GetBytes("echo `"hé`"`n")) -ResponseContentType 'application/octet-stream'
        try {
            $text = InModuleScope FleetDM-PowerShell -Parameters @{ Base = $server.BaseUri } {
                param($Base)
                $script:FleetDMConnection.BaseUri = $Base
                Get-FleetDownloadText -Endpoint 'scripts/4' -QueryParameters @{ alt = 'media' }
            }
            $text | Should -BeExactly "echo `"hé`"`n"
            $server.State.Url | Should -Be '/api/v1/fleet/scripts/4?alt=media'
        }
        finally {
            Stop-FleetTestListener -Server $server
            InModuleScope FleetDM-PowerShell { $script:FleetDMConnection.BaseUri = 'https://test.fleetdm.example.com' }
        }
    }
}

Describe 'Upload and download helpers' -Tag 'Unit' {
    It 'reads a file as bytes or as a streamed path relative to the current location' {
        $file = Join-Path $script:TestRoot 'rel.sh'
        Set-Content -LiteralPath $file -Value 'echo rel' -NoNewline
        Push-Location $script:TestRoot
        try {
            InModuleScope FleetDM-PowerShell {
                $part = Get-FleetUploadFile -Path './rel.sh'
                $part.FileName | Should -Be 'rel.sh'
                [System.Text.Encoding]::UTF8.GetString($part.Bytes) | Should -Be 'echo rel'
                $streamed = Get-FleetUploadFile -Path 'rel.sh' -Stream
                $streamed.Path | Should -BeLike '*rel.sh'
                $streamed.Contains('Bytes') | Should -BeFalse
            }
        }
        finally {
            Pop-Location
        }
    }

    It 'rejects a missing file and a directory' {
        InModuleScope FleetDM-PowerShell -Parameters @{ Root = $script:TestRoot } {
            param($Root)
            { Get-FleetUploadFile -Path (Join-Path $Root 'nope.sh') } | Should -Throw '*File not found*'
            { Get-FleetUploadFile -Path $Root } | Should -Throw '*File not found*'
        }
    }

    It 'builds a UTF-8 text part without a byte order mark' {
        InModuleScope FleetDM-PowerShell {
            $part = New-FleetTextFilePart -FileName 'x.sh' -Text 'é'
            $part.FileName | Should -Be 'x.sh'
            @($part.Bytes) | Should -Be @(0xC3, 0xA9)
            (New-FleetTextFilePart -FileName 'e.sh' -Text '').Bytes.Length | Should -Be 0
        }
    }

    It 'saves a download to a path and returns the file' {
        $target = Join-Path $script:TestRoot 'saved.bin'
        InModuleScope FleetDM-PowerShell -Parameters @{ Target = $target } {
            param($Target)
            Mock Invoke-FleetDMRequest { [System.IO.File]::WriteAllBytes($OutFile, [byte[]](7, 8)) }
            $item = Save-FleetDownload -Endpoint 'bootstrap/1' -QueryParameters @{ a = 1 } -OutFile $Target
            $item.FullName | Should -Be $Target
            $item.Length | Should -Be 2
        }
    }

    It 'deletes the temporary download file when the request fails' {
        InModuleScope FleetDM-PowerShell {
            $script:downloadPath = $null
            Mock Invoke-FleetDMRequest {
                $script:downloadPath = $OutFile
                throw 'Resource not found.'
            }
            { Get-FleetDownloadText -Endpoint 'scripts/9' } | Should -Throw '*not found*'
            Test-Path -LiteralPath $script:downloadPath | Should -BeFalse
        }
    }

    It 'copies label targets and enforces the include rules' {
        InModuleScope FleetDM-PowerShell {
            $target = @{}
            Add-FleetLabelTarget -Target $target -BoundParameters @{ LabelsIncludeAny = 'A'; LabelsExcludeAny = @('B', 'C') }
            $target.labels_include_any -is [System.Array] | Should -BeTrue
            $target.labels_include_any.Count | Should -Be 1
            $target.labels_include_any[0] | Should -Be 'A'
            @($target.labels_exclude_any) | Should -Be @('B', 'C')
            $target.Contains('labels_include_all') | Should -BeFalse

            { Add-FleetLabelTarget -Target @{} -BoundParameters @{ LabelsIncludeAll = 'A'; LabelsIncludeAny = 'B' } } |
                Should -Throw '*cannot be used together*'
            { Add-FleetLabelTarget -Target @{} -BoundParameters @{ LabelsIncludeAll = 'A'; LabelsExcludeAny = 'B' } -SingleMode } |
                Should -Throw '*only one of*'
            $single = @{}
            Add-FleetLabelTarget -Target $single -BoundParameters @{ LabelsIncludeAll = 'A' } -SingleMode
            @($single.labels_include_all) | Should -Be @('A')
        }
    }
}

Describe 'Fleet error reasons' -Tag 'Unit' {
    BeforeAll {
        $script:NewFleetHttpError = {
            param([int]$Status, [string]$Description, [string]$Body)
            $exception = New-Object System.Exception $Description
            $exception | Add-Member -NotePropertyName Response -NotePropertyValue ([PSCustomObject]@{ StatusCode = $Status; StatusDescription = $Description }) -Force
            $record = New-Object System.Management.Automation.ErrorRecord($exception, 'FleetTest', 'InvalidOperation', $null)
            if ($Body) {
                $record.ErrorDetails = New-Object System.Management.Automation.ErrorDetails($Body)
            }
            return $record
        }
    }

    It 'joins name and reason pairs, drops base, and skips a repeated message' {
        InModuleScope FleetDM-PowerShell {
            $errors = @(
                [PSCustomObject]@{ name = 'base'; reason = 'Scripts are disabled.' }
                [PSCustomObject]@{ name = 'host_id'; reason = 'not Apple' }
                [PSCustomObject]@{ name = 'x'; reason = '' }
                $null
                [PSCustomObject]@{ name = 'base'; reason = 'Same as message' }
            )
            Format-FleetErrorReason -Errors $errors -Message 'Same as message' | Should -Be 'Scripts are disabled.; host_id: not Apple'
            Format-FleetErrorReason -Errors ([PSCustomObject]@{ reason = 'one' }) | Should -Be 'one'
            Format-FleetErrorReason -Errors $null | Should -Be ''
        }
    }

    It 'adds the reason to 400, 403, 404, 409, 422, and other errors' {
        $cases = @(
            @{ Status = 400; Text = 'Bad Request: Bad request Reason: Param team_id is required' }
            @{ Status = 403; Text = "Access denied. You don't have permission to perform this operation. Error: Bad request Reason: Param team_id is required" }
            @{ Status = 404; Text = 'Resource not found. The requested item does not exist. Error: Bad request Reason: Param team_id is required' }
            @{ Status = 409; Text = 'FleetDM API error (HTTP 409): Bad request Reason: Param team_id is required' }
            @{ Status = 422; Text = 'Fleet could not process the request (HTTP 422). Error: Bad request Reason: Param team_id is required' }
            @{ Status = 418; Text = 'FleetDM API error (HTTP 418): Bad request Reason: Param team_id is required' }
        )
        foreach ($case in $cases) {
            $record = & $script:NewFleetHttpError $case.Status 'Status' '{"message":"Bad request","errors":[{"name":"base","reason":"Param team_id is required"}]}'
            $message = InModuleScope FleetDM-PowerShell -Parameters @{ Record = $record } {
                param($Record)
                try { Resolve-FleetDMApiError -ErrorRecord $Record } catch { $_.Exception.Message }
            }
            $message | Should -BeExactly $case.Text
        }
    }

    It 'leaves the message alone when the only reason repeats it' {
        $record = & $script:NewFleetHttpError 400 'Bad Request' '{"message":"MDM features are off","errors":[{"name":"base","reason":"MDM features are off"}]}'
        $message = InModuleScope FleetDM-PowerShell -Parameters @{ Record = $record } {
            param($Record)
            try { Resolve-FleetDMApiError -ErrorRecord $Record } catch { $_.Exception.Message }
        }
        $message | Should -BeExactly 'Bad Request: MDM features are off'
    }

    It 'keeps the Fleet Premium and access denied wording' {
        $premium = & $script:NewFleetHttpError 402 'Payment Required' '{"message":"Requires Fleet Premium license","errors":[{"name":"base","reason":"Requires Fleet Premium license"}]}'
        $licence403 = & $script:NewFleetHttpError 403 'Forbidden' '{"message":"forbidden","errors":[{"name":"base","reason":"missing premium license"}]}'
        $denied = & $script:NewFleetHttpError 403 'Forbidden' '{"message":"forbidden"}'
        $messages = InModuleScope FleetDM-PowerShell -Parameters @{ Records = @($premium, $licence403, $denied) } {
            param($Records)
            foreach ($record in $Records) {
                try { Resolve-FleetDMApiError -ErrorRecord $record } catch { $_.Exception.Message }
            }
        }
        $messages[0] | Should -BeExactly 'This feature requires Fleet Premium. Requires Fleet Premium license'
        $messages[1] | Should -BeExactly 'This feature requires Fleet Premium. forbidden'
        $messages[2] | Should -BeExactly "Access denied. You don't have permission to perform this operation. Error: forbidden"
    }
}
