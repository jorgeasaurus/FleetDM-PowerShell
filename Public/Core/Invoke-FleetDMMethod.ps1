function Invoke-FleetDMMethod {
    <#
    .SYNOPSIS
        Invokes a custom FleetDM API method
    
    .DESCRIPTION
        Provides direct access to any FleetDM API endpoint not covered by specific cmdlets.
        This is useful for accessing new or undocumented API endpoints.
    
    .PARAMETER Endpoint
        The API endpoint path (without /api/v1/fleet/ prefix)
    
    .PARAMETER Method
        The HTTP method to use (GET, POST, PUT, PATCH, DELETE)
    
    .PARAMETER Body
        The request body as a hashtable (will be converted to JSON)
    
    .PARAMETER QueryParameters
        Query parameters as a hashtable
    
    .PARAMETER FollowPagination
        Automatically follow pagination to retrieve all results (for GET requests)
    
    .PARAMETER Raw
        Return the raw response object without processing
    
    .EXAMPLE
        Invoke-FleetDMMethod -Endpoint "config" -Method GET
        
        Gets the FleetDM configuration
    
    .EXAMPLE
        Invoke-FleetDMMethod -Endpoint "users" -Method GET -QueryParameters @{query = "admin"}
        
        Searches for users with "admin" in their name
    
    .EXAMPLE
        $body = @{
            name = "New Team"
            description = "Created via API"
        }
        Invoke-FleetDMMethod -Endpoint "teams" -Method POST -Body $body
        
        Creates a new team
    
    .EXAMPLE
        Invoke-FleetDMMethod -Endpoint "hosts/123/refetch" -Method POST
        
        Triggers a refetch for host ID 123
    
    .EXAMPLE
        Invoke-FleetDMMethod -Endpoint "labels" -Method GET -FollowPagination
        
        Gets all labels, automatically following pagination
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Endpoint,
        
        [Parameter()]
        [ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')]
        [string]$Method = 'GET',
        
        [Parameter()]
        [hashtable]$Body,
        
        [Parameter()]
        [hashtable]$QueryParameters,
        
        [Parameter()]
        [switch]$FollowPagination,
        
        [Parameter()]
        [switch]$Raw
    )
    
    process {
        Write-Verbose "Invoking FleetDM method: $Method $Endpoint"
        
        # Validate that we can use FollowPagination
        if ($FollowPagination -and $Method -ne 'GET') {
            Write-Warning "FollowPagination is only supported for GET requests. Ignoring parameter."
            $FollowPagination = $false
        }
        
        # Build parameters for Invoke-FleetDMRequest
        $requestParams = @{
            Endpoint = $Endpoint
            Method = $Method
        }
        
        if ($Body) {
            $requestParams['Body'] = $Body
            Write-Verbose "Request body: $($Body | ConvertTo-Json -Compress)"
        }
        
        if ($QueryParameters) {
            $requestParams['QueryParameters'] = $QueryParameters
            Write-Verbose "Query parameters: $($QueryParameters | ConvertTo-Json -Compress)"
        }
        
        if ($FollowPagination) {
            $requestParams['FollowPagination'] = $true
        }
        
        try {
            $result = Invoke-FleetDMRequest @requestParams
            
            Write-Verbose "Request completed successfully"
            
            # Try to add type information if we can identify the object type
            if (-not $Raw -and $result) {
                # For collections, add type information to the nested data
                if ($result.PSObject.Properties.Name -contains 'hosts') {
                    $result.hosts | Add-FleetTypeName -TypeName 'FleetDM.Host'
                }
                elseif ($result.PSObject.Properties.Name -contains 'policies') {
                    $result.policies | Add-FleetTypeName -TypeName 'FleetDM.Policy'
                }
                elseif ($result.PSObject.Properties.Name -contains 'queries') {
                    $result.queries | Add-FleetTypeName -TypeName 'FleetDM.Query'
                }
                elseif ($result.PSObject.Properties.Name -contains 'software') {
                    $result.software | Add-FleetTypeName -TypeName 'FleetDM.Software'
                }
                elseif ($result.PSObject.Properties.Name -contains 'users') {
                    $result.users | Add-FleetTypeName -TypeName 'FleetDM.User'
                }
                elseif ($result.PSObject.Properties.Name -contains 'teams') {
                    $result.teams | Add-FleetTypeName -TypeName 'FleetDM.Team'
                }
                elseif ($result.PSObject.Properties.Name -contains 'labels') {
                    $result.labels | Add-FleetTypeName -TypeName 'FleetDM.Label'
                }
                # For single objects
                elseif ($result.PSObject.Properties.Name -contains 'host') {
                    $result.host | Add-FleetTypeName -TypeName 'FleetDM.Host'
                }
                elseif ($result.PSObject.Properties.Name -contains 'policy') {
                    $result.policy | Add-FleetTypeName -TypeName 'FleetDM.Policy'
                }
                elseif ($result.PSObject.Properties.Name -contains 'query') {
                    $result.query | Add-FleetTypeName -TypeName 'FleetDM.Query'
                }
                elseif ($result.PSObject.Properties.Name -contains 'user') {
                    $result.user | Add-FleetTypeName -TypeName 'FleetDM.User'
                }
                elseif ($result.PSObject.Properties.Name -contains 'team') {
                    $result.team | Add-FleetTypeName -TypeName 'FleetDM.Team'
                }
                elseif ($result.PSObject.Properties.Name -contains 'label') {
                    $result.label | Add-FleetTypeName -TypeName 'FleetDM.Label'
                }
            }
            
            return $result
        }
        catch {
            Write-Error "Failed to invoke FleetDM method: $_"
            throw
        }
    }
}