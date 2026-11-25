function Resolve-FleetLocalPath {
    <#
    .SYNOPSIS
        Resolves a path against the current PowerShell location.

    .DESCRIPTION
        .NET file APIs resolve relative paths against the process directory,
        which Set-Location does not change. The path does not need to exist.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}

function Get-FleetUploadFile {
    <#
    .SYNOPSIS
        Returns a multipart file part for a local file.

    .DESCRIPTION
        The default part carries the file bytes. -Stream returns the path
        instead, so the multipart body streams the file from disk.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [switch]$Stream
    )

    $resolved = Resolve-FleetLocalPath -Path $Path
    if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        throw "File not found: $Path"
    }

    $part = @{ FileName = [System.IO.Path]::GetFileName($resolved) }
    if ($Stream) {
        $part['Path'] = $resolved
    }
    else {
        $part['Bytes'] = [System.IO.File]::ReadAllBytes($resolved)
    }
    return $part
}

function New-FleetTextFilePart {
    <#
    .SYNOPSIS
        Returns a multipart file part for text held in memory.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Returns a value. It changes no state.')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FileName,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text
    )

    return @{
        FileName = $FileName
        Bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($Text)
    }
}

function Get-FleetDownloadText {
    <#
    .SYNOPSIS
        Downloads a Fleet file route and returns its text.

    .DESCRIPTION
        Invoke-RestMethod decodes application/octet-stream without a charset
        as ISO-8859-1, which garbles UTF-8 scripts. The bytes are saved to a
        temporary file and decoded as UTF-8 instead.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Endpoint,

        [hashtable]$QueryParameters
    )

    $path = [System.IO.Path]::GetTempFileName()
    try {
        $null = Invoke-FleetDMRequest -Endpoint $Endpoint -QueryParameters $QueryParameters -OutFile $path
        return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    }
    finally {
        Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
    }
}

function Save-FleetDownload {
    <#
    .SYNOPSIS
        Downloads a Fleet file route to a local path and returns the file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Endpoint,

        [hashtable]$QueryParameters,

        [Parameter(Mandatory)]
        [string]$OutFile
    )

    $resolved = Resolve-FleetLocalPath -Path $OutFile
    $null = Invoke-FleetDMRequest -Endpoint $Endpoint -QueryParameters $QueryParameters -OutFile $resolved
    return (Get-Item -LiteralPath $resolved)
}

function Add-FleetLabelTarget {
    <#
    .SYNOPSIS
        Copies label targeting parameters into a request body or form.

    .DESCRIPTION
        Fleet never accepts labels_include_all together with labels_include_any.
        Some routes also reject labels_exclude_any next to an include list;
        -SingleMode enforces that rule.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Target,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$BoundParameters,

        [switch]$SingleMode
    )

    $map = [ordered]@{
        LabelsIncludeAll = 'labels_include_all'
        LabelsIncludeAny = 'labels_include_any'
        LabelsExcludeAny = 'labels_exclude_any'
    }
    $present = @($map.Keys | Where-Object { $BoundParameters.ContainsKey($_) })

    if ($present -contains 'LabelsIncludeAll' -and $present -contains 'LabelsIncludeAny') {
        throw 'LabelsIncludeAll and LabelsIncludeAny cannot be used together.'
    }
    if ($SingleMode -and $present.Count -gt 1) {
        throw 'Use only one of LabelsIncludeAll, LabelsIncludeAny, or LabelsExcludeAny.'
    }

    foreach ($name in $present) {
        $Target[$map[$name]] = @($BoundParameters[$name])
    }
}
