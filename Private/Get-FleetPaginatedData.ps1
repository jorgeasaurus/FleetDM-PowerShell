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
    
    # Known collection property names in FleetDM responses
    $collectionProperties = @(
        'hosts',
        'policies', 
        'queries',
        'software',
        'users',
        'teams',
        'labels',
        'targets',
        'results',
        'vulnerabilities'
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
    
    # If response is an object, look for known collection properties
    if ($Response -is [System.Management.Automation.PSCustomObject]) {
        # Check for collection properties
        foreach ($prop in $collectionProperties) {
            if ($Response.PSObject.Properties.Name -contains $prop) {
                $result.Data = $Response.$prop
                break
            }
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