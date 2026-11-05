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

    if ($null -eq $InputObject) {
        return 'null'
    }

    # ConvertTo-Json unwraps a one-element array on Windows PowerShell 5.1.
    # Dictionaries and lists are written here. Leaves go to ConvertTo-Json.
    if ($InputObject -is [System.Collections.IDictionary]) {
        $pairs = foreach ($key in @($InputObject.Keys)) {
            '{0}:{1}' -f ($key | ConvertTo-Json -Compress), (ConvertTo-FleetJson -InputObject $InputObject[$key] -Depth $Depth)
        }
        return '{' + ($pairs -join ',') + '}'
    }

    if ($InputObject -is [System.Collections.IList]) {
        $items = foreach ($item in $InputObject) {
            ConvertTo-FleetJson -InputObject $item -Depth $Depth
        }
        return '[' + (@($items) -join ',') + ']'
    }

    return ($InputObject | ConvertTo-Json -Compress -Depth $Depth)
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
