function Test-FleetFormFile {
    <#
    .SYNOPSIS
        Tests whether a form value is a file part.

    .DESCRIPTION
        A file part is a dictionary with FileName and either Bytes or Path.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Value
    )

    return [bool]($Value -is [System.Collections.IDictionary] -and $Value.Contains('FileName') -and ($Value.Contains('Bytes') -or $Value.Contains('Path')))
}

function ConvertTo-FleetFormText {
    <#
    .SYNOPSIS
        Converts one form value to the text Fleet parses.

    .DESCRIPTION
        Fleet reads multipart booleans with strconv.ParseBool. PowerShell
        writes True and False, so booleans are lowercased here.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Value
    )

    if ($Value -is [bool] -or $Value -is [switch]) {
        return ([bool]$Value).ToString().ToLowerInvariant()
    }

    return [System.Convert]::ToString($Value, [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-FleetFormPart {
    <#
    .SYNOPSIS
        Expands a form dictionary into ordered parts.

    .DESCRIPTION
        Null values are dropped. A collection becomes one field per element,
        the way Fleet reads label lists. A file part keeps its dictionary.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Form
    )

    foreach ($key in @($Form.Keys)) {
        $value = $Form[$key]
        if ($null -eq $value) { continue }

        if (Test-FleetFormFile -Value $value) {
            [PSCustomObject]@{ Name = [string]$key; File = $value; Text = $null }
            continue
        }

        foreach ($item in @($value)) {
            if ($null -eq $item) { continue }
            [PSCustomObject]@{ Name = [string]$key; File = $null; Text = (ConvertTo-FleetFormText -Value $item) }
        }
    }
}

function Write-FleetMultipartBody {
    <#
    .SYNOPSIS
        Writes a multipart/form-data body to a stream.

    .DESCRIPTION
        Lines end in CRLF. Headers and text values are UTF-8. File parts are
        copied as bytes. A Path part is streamed from disk so a large
        installer is never held in memory. Returns one summary line per part
        with the field name and byte count, which is all the verbose log shows.
        With no parts, only the closing boundary is written.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.IO.Stream]$Stream,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Part,

        [Parameter(Mandatory)]
        [string]$Boundary
    )

    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $write = {
        param([string]$Text)
        $bytes = $utf8.GetBytes($Text)
        $Stream.Write($bytes, 0, $bytes.Length)
    }

    foreach ($item in $Part) {
        $name = $item.Name -replace '[\r\n"]', ''
        & $write "--$Boundary`r`n"
        if ($item.File) {
            $fileName = ([string]$item.File.FileName) -replace '[\r\n"]', ''
            $contentType = if ($item.File.Contains('ContentType') -and $item.File.ContentType) { $item.File.ContentType } else { 'application/octet-stream' }
            & $write "Content-Disposition: form-data; name=`"$name`"; filename=`"$fileName`"`r`nContent-Type: $contentType`r`n`r`n"
            if ($item.File.Contains('Path')) {
                $source = [System.IO.File]::OpenRead([string]$item.File.Path)
                try {
                    $source.CopyTo($Stream)
                    $length = $source.Length
                }
                finally {
                    $source.Dispose()
                }
            }
            else {
                [byte[]]$data = $item.File.Bytes
                $Stream.Write($data, 0, $data.Length)
                $length = $data.Length
            }
            "$name=<file $length bytes>"
        }
        else {
            & $write "Content-Disposition: form-data; name=`"$name`"`r`n`r`n"
            $data = $utf8.GetBytes($item.Text)
            $Stream.Write($data, 0, $data.Length)
            "$name=<$($data.Length) bytes>"
        }
        & $write "`r`n"
    }

    & $write "--$Boundary--`r`n"
}

function New-FleetMultipartContent {
    <#
    .SYNOPSIS
        Builds a multipart/form-data request body from a form dictionary.

    .DESCRIPTION
        Windows PowerShell 5.1 has no Invoke-RestMethod -Form, so the body is
        built here and sent through the normal request path.

        Values are strings, numbers, booleans, or collections of those. A file
        part is a dictionary with FileName and Bytes, or FileName and Path.
        When any part has Path, the body is written to a temporary file and
        returned as Path so Invoke-RestMethod -InFile streams it. The caller
        deletes that file. Otherwise the body is returned as Bytes.

    .PARAMETER Form
        Field names and values.

    .PARAMETER Boundary
        The multipart boundary. A random value is used by default.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Builds a request body in memory or in a temporary file. It changes no Fleet state.')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Form,

        [ValidateNotNullOrEmpty()]
        [string]$Boundary = ('FleetDMPowerShell' + [guid]::NewGuid().ToString('N'))
    )

    $parts = @(Get-FleetFormPart -Form $Form)
    $streamFromDisk = @($parts | Where-Object { $_.File -and $_.File.Contains('Path') }).Count -gt 0
    $result = @{
        ContentType = "multipart/form-data; boundary=$Boundary"
        Boundary = $Boundary
        Bytes = $null
        Path = $null
        Summary = $null
    }

    if ($streamFromDisk) {
        $path = [System.IO.Path]::GetTempFileName()
        $stream = [System.IO.File]::Open($path, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
        try {
            $result.Summary = @(Write-FleetMultipartBody -Stream $stream -Part $parts -Boundary $Boundary)
        }
        catch {
            $stream.Dispose()
            Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
            throw
        }
        $stream.Dispose()
        $result.Path = $path
        return $result
    }

    $stream = New-Object System.IO.MemoryStream
    $result.Summary = @(Write-FleetMultipartBody -Stream $stream -Part $parts -Boundary $Boundary)
    $result.Bytes = $stream.ToArray()
    $stream.Dispose()
    return $result
}

function Copy-FleetHeaderWithoutContentType {
    <#
    .SYNOPSIS
        Copies request headers without Content-Type.

    .DESCRIPTION
        Connect-FleetDM stores Content-Type: application/json with the
        connection headers. A multipart body needs its own boundary value.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [System.Collections.IDictionary]$Headers
    )

    $copy = @{}
    if ($Headers) {
        foreach ($key in @($Headers.Keys)) {
            if ([string]$key -ne 'Content-Type') {
                $copy[$key] = $Headers[$key]
            }
        }
    }
    return $copy
}
