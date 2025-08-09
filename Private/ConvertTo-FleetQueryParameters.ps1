function ConvertTo-FleetQueryParameters {
    <#
    .SYNOPSIS
        Converts PSBoundParameters to FleetDM API query parameters
    
    .DESCRIPTION
        Internal helper function that maps PowerShell parameter names to FleetDM API query parameter names,
        reducing repetitive query building code across cmdlets.
    
    .PARAMETER BoundParameters
        The PSBoundParameters from the calling function
    
    .PARAMETER ParameterMapping
        Hashtable mapping PowerShell parameter names to API parameter names.
        If not provided, uses the parameter name as-is (converted to lowercase).
    
    .PARAMETER ExcludeParameters
        Array of parameter names to exclude from the query parameters
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$BoundParameters,
        
        [hashtable]$ParameterMapping = @{},
        
        [string[]]$ExcludeParameters = @('Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 
                                         'ErrorVariable', 'WarningVariable', 'InformationVariable', 
                                         'OutVariable', 'OutBuffer', 'PipelineVariable')
    )
    
    $queryParams = @{}
    
    foreach ($param in $BoundParameters.GetEnumerator()) {
        # Skip excluded parameters
        if ($param.Key -in $ExcludeParameters) {
            continue
        }
        
        # Get the API parameter name
        if ($ParameterMapping.ContainsKey($param.Key)) {
            $apiParamName = $ParameterMapping[$param.Key]
            
            # Skip if mapped to null (parameter should be excluded)
            if ($null -eq $apiParamName) {
                continue
            }
        }
        else {
            # Convert to lowercase by default for API consistency
            $apiParamName = $param.Key.ToLower()
        }
        
        # Handle special value conversions
        $value = $param.Value
        
        # Convert switch parameters to lowercase strings
        if ($value -is [switch]) {
            $value = $value.IsPresent.ToString().ToLower()
        }
        # Convert boolean to lowercase strings
        elseif ($value -is [bool]) {
            $value = $value.ToString().ToLower()
        }
        # Keep other values as-is
        
        $queryParams[$apiParamName] = $value
    }
    
    return $queryParams
}