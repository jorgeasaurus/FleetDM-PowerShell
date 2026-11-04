function ConvertTo-FleetJson {
    <#
    .SYNOPSIS
        Serializes an object to JSON without unwrapping single-element arrays.

    .DESCRIPTION
        Windows PowerShell 5.1 ConvertTo-Json turns a one-element array into a
        scalar. Fleet rejects bodies such as host_ids when that happens.
        This serializer always emits JSON arrays for collections.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$InputObject,

        [int]$Depth = 10
    )

    return (ConvertTo-FleetJsonValue -Value $InputObject -Depth $Depth)
}

function ConvertTo-FleetJsonValue {
    <#
    .SYNOPSIS
        Recursively renders one value as a JSON literal.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Value,

        [int]$Depth
    )

    if ($Depth -lt 0) {
        throw "JSON serialization exceeded the maximum depth."
    }

    if ($null -eq $Value) {
        return 'null'
    }

    if ($Value -is [string]) {
        return ($Value | ConvertTo-Json -Compress)
    }

    if ($Value -is [bool]) {
        if ($Value) { return 'true' }
        return 'false'
    }

    if ($Value -is [datetime]) {
        $utc = $Value.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss'Z'")
        return ('"' + $utc + '"')
    }

    if ($Value -is [enum]) {
        return ($Value.ToString() | ConvertTo-Json -Compress)
    }

    $numericTypes = @(
        [byte], [int16], [int], [int64], [long],
        [uint16], [uint32], [uint64],
        [decimal], [double], [single]
    )
    foreach ($numericType in $numericTypes) {
        if ($Value -is $numericType) {
            # [string] follows the current culture, so 1.5 can become "1,5".
            return [System.Convert]::ToString($Value, [System.Globalization.CultureInfo]::InvariantCulture)
        }
    }

    if ($Value -is [System.Collections.IDictionary]) {
        $pairs = New-Object System.Collections.Generic.List[string]
        foreach ($key in @($Value.Keys)) {
            $name = ([string]$key | ConvertTo-Json -Compress)
            $rendered = ConvertTo-FleetJsonValue -Value $Value[$key] -Depth ($Depth - 1)
            $pairs.Add("${name}:${rendered}")
        }
        return '{' + ($pairs -join ',') + '}'
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        $items = New-Object System.Collections.Generic.List[string]
        # @() on List[object] throws "Argument types do not match" in PowerShell 7.
        foreach ($item in $Value) {
            $items.Add((ConvertTo-FleetJsonValue -Value $item -Depth ($Depth - 1)))
        }
        return '[' + ($items -join ',') + ']'
    }

    $pairs = New-Object System.Collections.Generic.List[string]
    foreach ($prop in $Value.PSObject.Properties) {
        $name = ($prop.Name | ConvertTo-Json -Compress)
        $rendered = ConvertTo-FleetJsonValue -Value $prop.Value -Depth ($Depth - 1)
        $pairs.Add("${name}:${rendered}")
    }
    return '{' + ($pairs -join ',') + '}'
}

function ConvertTo-FleetQueryString {
    <#
    .SYNOPSIS
        Builds an encoded query string from a hashtable.

    .DESCRIPTION
        Uses [uri]::EscapeDataString so the module does not depend on
        System.Web, which is not available on every PowerShell host.
        Null values are omitted. Collections are comma-separated instead of
        calling ToString() on the collection object.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [hashtable]$QueryParameters
    )

    if (-not $QueryParameters -or $QueryParameters.Count -eq 0) {
        return ''
    }

    $pairs = New-Object System.Collections.Generic.List[string]
    foreach ($param in $QueryParameters.GetEnumerator()) {
        if ($null -eq $param.Value) {
            continue
        }

        $key = [uri]::EscapeDataString([string]$param.Key)
        $rawValue = $param.Value

        if ($rawValue -is [bool]) {
            $text = $rawValue.ToString().ToLower()
            $pairs.Add("$key=$([uri]::EscapeDataString($text))")
            continue
        }

        if ($rawValue -is [System.Collections.IEnumerable] -and $rawValue -isnot [string]) {
            $encoded = New-Object System.Collections.Generic.List[string]
            foreach ($item in $rawValue) {
                if ($null -eq $item) { continue }
                $encoded.Add([uri]::EscapeDataString([string]$item))
            }
            $pairs.Add("$key=$($encoded -join ',')")
            continue
        }

        $pairs.Add("$key=$([uri]::EscapeDataString([string]$rawValue))")
    }

    return ($pairs -join '&')
}
