function ConvertTo-FleetFilterBody {
    <#
    .SYNOPSIS
        Validates a host filter and returns the filters object for a request body.

    .DESCRIPTION
        Batch script runs, host transfers, and profile resends act on every
        host that matches the filter. Fleet ignores unknown keys and treats a
        missing or null value as no filter, which would match every host.
        An empty filter, an unknown key, or an empty value is rejected here.
        Keys are sent in lowercase.

    .PARAMETER Filter
        The caller's filter dictionary.

    .PARAMETER AllowedKey
        The filter keys the route accepts.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.Collections.IDictionary]$Filter,

        [Parameter(Mandatory)]
        [string[]]$AllowedKey
    )

    if ($Filter.Count -eq 0) {
        throw 'Filter must contain at least one key. An empty filter matches every host.'
    }

    $body = @{}
    foreach ($key in @($Filter.Keys)) {
        $name = ([string]$key).ToLowerInvariant()
        if ($AllowedKey -notcontains $name) {
            throw "Unsupported filter key '$key'. Use one of: $($AllowedKey -join ', ')."
        }

        $value = $Filter[$key]
        $emptyList = $value -is [System.Collections.IList] -and $value.Count -eq 0
        if ($null -eq $value -or $emptyList -or ($value -is [string] -and [string]::IsNullOrWhiteSpace($value))) {
            throw "Filter key '$key' has no value. An empty filter value matches every host."
        }
        $body[$name] = $value
    }

    return $body
}
