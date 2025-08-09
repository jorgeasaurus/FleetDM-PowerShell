function Add-FleetTypeName {
    <#
    .SYNOPSIS
        Adds FleetDM type names to objects for proper formatting
    
    .DESCRIPTION
        Internal helper function that adds appropriate PSObject.TypeNames to FleetDM objects
        based on the endpoint or object type, reducing repetitive type tagging code.
    
    .PARAMETER InputObject
        The object(s) to add type information to
    
    .PARAMETER TypeName
        The type name to add (e.g., 'FleetDM.Host')
    
    .PARAMETER Endpoint
        The API endpoint to derive the type from (alternative to TypeName)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,
        
        [Parameter(Mandatory, ParameterSetName = 'TypeName')]
        [string]$TypeName,
        
        [Parameter(Mandatory, ParameterSetName = 'Endpoint')]
        [string]$Endpoint
    )
    
    begin {
        # Endpoint to type mapping
        $endpointTypeMap = @{
            'hosts'     = 'FleetDM.Host'
            'host'      = 'FleetDM.Host'
            'policies'  = 'FleetDM.Policy'
            'policy'    = 'FleetDM.Policy'
            'queries'   = 'FleetDM.Query'
            'query'     = 'FleetDM.Query'
            'software'  = 'FleetDM.Software'
            'users'     = 'FleetDM.User'
            'user'      = 'FleetDM.User'
            'teams'     = 'FleetDM.Team'
            'team'      = 'FleetDM.Team'
            'labels'    = 'FleetDM.Label'
            'label'     = 'FleetDM.Label'
        }
        
        # Determine type name from endpoint if needed
        if ($PSCmdlet.ParameterSetName -eq 'Endpoint') {
            # Extract the base endpoint name
            $baseEndpoint = $Endpoint.TrimStart('/').Split('/')[0].ToLower()
            
            if ($endpointTypeMap.ContainsKey($baseEndpoint)) {
                $TypeName = $endpointTypeMap[$baseEndpoint]
            }
            else {
                # Default type for unknown endpoints
                $TypeName = 'FleetDM.Object'
            }
        }
    }
    
    process {
        if ($null -eq $InputObject) {
            return
        }
        
        # Handle arrays/collections
        if ($InputObject -is [array]) {
            foreach ($item in $InputObject) {
                if ($item -and $item.PSObject) {
                    $item.PSObject.TypeNames.Insert(0, $TypeName)
                }
            }
        }
        # Handle single objects
        elseif ($InputObject.PSObject) {
            $InputObject.PSObject.TypeNames.Insert(0, $TypeName)
        }
        
        # Return the object with type information added
        $InputObject
    }
}