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
    # Fleet 4.93 list fleets sends that one collection as both teams and fleets.
    # An empty or null legacy key must not hide the populated name.
    if ($Response -is [System.Management.Automation.PSCustomObject]) {
        $collection = $null
        $collectionName = $null
        $unwrapped = $null
        $unwrappedName = $null
        foreach ($prop in $Response.PSObject.Properties) {
            if ($prop.Name -eq 'meta' -or $null -eq $prop.Value) { continue }
            $value = $prop.Value
            if ($value -is [string] -or $value -is [System.ValueType]) { continue }
            if ($value -is [System.Collections.IList]) {
                if ($null -eq $collection) {
                    $collection = $value
                    $collectionName = $prop.Name
                    $aliasName = Get-FleetListAliasName -Name $prop.Name
                    if ($value.Count -gt 0 -or [string]::IsNullOrEmpty($aliasName)) {
                        break
                    }
                    continue
                }

                $wanted = Get-FleetListAliasName -Name $collectionName
                if ($wanted -eq $prop.Name -and $value.Count -gt 0) {
                    $collection = $value
                    $collectionName = $prop.Name
                    break
                }
                continue
            }

            if ($null -eq $unwrapped) {
                $unwrapped = $value
                $unwrappedName = $prop.Name
                continue
            }

            if ($collectionName) {
                $wanted = Get-FleetListAliasName -Name $collectionName
                if ($wanted -eq $prop.Name) {
                    $unwrapped = $value
                    $unwrappedName = $prop.Name
                }
            }
        }
        if ($null -ne $collection -and $collection.Count -eq 0 -and $collectionName) {
            $wanted = Get-FleetListAliasName -Name $collectionName
            if ($wanted -eq $unwrappedName -and (Test-FleetCollectionPopulated -Value $unwrapped)) {
                $collection = @($unwrapped)
                $collectionName = $unwrappedName
            }
        }
        # Both keys populated: keep the current name, fleets, including when teams was listed first.
        if ($collectionName -eq 'teams') {
            $fleetProperty = Get-FleetEnvelopeProperty -Response $Response -Name 'fleets'
            if ($fleetProperty -and (Test-FleetCollectionPopulated -Value $fleetProperty.Value)) {
                $collection = $fleetProperty.Value
                if ($collection -isnot [System.Collections.IList]) {
                    $collection = @($collection)
                }
                $collectionName = 'fleets'
            }
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