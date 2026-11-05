function Get-FleetPaginatedData {
    <#
    .SYNOPSIS
        Extracts data from FleetDM paginated responses
    
    .DESCRIPTION
        Internal helper function that extracts the actual data collection from FleetDM API responses,
        handling various response formats and reducing repetitive pagination code.
    
    .PARAMETER Response
        The response object from the FleetDM API
    
    .PARAMETER ReturnMetadata
        If specified, returns an object with both data and metadata
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Response,
        
        [switch]$ReturnMetadata
    )
    
    $result = @{
        Data = $null
        HasMore = $false
        Metadata = $null
    }
    
    if ($null -eq $Response) {
        if ($ReturnMetadata) {
            return $result
        }
        return $null
    }
    
    # If response is already an array, return it directly
    if ($Response -is [array]) {
        $result.Data = $Response
        if ($ReturnMetadata) {
            return $result
        }
        return $Response
    }
    
    # A list envelope has one collection, plus meta and scalar counts.
    # Windows PowerShell 5.1 ConvertFrom-Json unwraps a one-element JSON
    # array into a scalar, so that collection is not always an IList.
    # An actual list wins over a nested object. An empty list stays empty.
    if ($Response -is [System.Management.Automation.PSCustomObject]) {
        $collection = $null
        $unwrapped = $null
        foreach ($prop in $Response.PSObject.Properties) {
            if ($prop.Name -eq 'meta' -or $null -eq $prop.Value) { continue }
            $value = $prop.Value
            if ($value -is [string] -or $value -is [System.ValueType]) { continue }
            if ($value -is [System.Collections.IList]) {
                $collection = $value
                break
            }
            if ($null -eq $unwrapped) { $unwrapped = $value }
        }
        if ($null -eq $collection -and $null -ne $unwrapped) {
            $collection = @($unwrapped)
        }
        if ($null -ne $collection) {
            $result.Data = $collection
        }
        
        # If no collection found, return the whole response as data
        if ($null -eq $result.Data) {
            $result.Data = $Response
        }
        
        # Check for pagination metadata
        if ($Response.PSObject.Properties.Name -contains 'meta') {
            $result.Metadata = $Response.meta
            if ($Response.meta.PSObject.Properties.Name -contains 'has_next_results') {
                $result.HasMore = $Response.meta.has_next_results
            }
        }
    }
    else {
        # For other types, return as-is
        $result.Data = $Response
    }
    
    if ($ReturnMetadata) {
        return $result
    }
    
    return $result.Data
}