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
        
        if ($Raw) {
            $requestParams['Raw'] = $true
        }
        
        try {
            $result = Invoke-FleetDMRequest @requestParams
            
            Write-Verbose "Request completed successfully"
            
            # Try to add type information if we can identify the object type
            if (-not $Raw -and $result) {
                # Attempt to identify and tag common object types
                switch -Regex ($Endpoint) {
                    '^hosts?(/|$)' {
                        if ($result.host) {
                            $result.host.PSObject.TypeNames.Insert(0, 'FleetDM.Host')
                        }
                        elseif ($result.hosts) {
                            $result.hosts | ForEach-Object {
                                $_.PSObject.TypeNames.Insert(0, 'FleetDM.Host')
                            }
                        }
                    }
                    '^policies?(/|$)' {
                        if ($result.policy) {
                            $result.policy.PSObject.TypeNames.Insert(0, 'FleetDM.Policy')
                        }
                        elseif ($result.policies) {
                            $result.policies | ForEach-Object {
                                $_.PSObject.TypeNames.Insert(0, 'FleetDM.Policy')
                            }
                        }
                    }
                    '^queries?(/|$)' {
                        if ($result.query) {
                            $result.query.PSObject.TypeNames.Insert(0, 'FleetDM.Query')
                        }
                        elseif ($result.queries) {
                            $result.queries | ForEach-Object {
                                $_.PSObject.TypeNames.Insert(0, 'FleetDM.Query')
                            }
                        }
                    }
                    '^software?(/|$)' {
                        if ($result.software -and $result.software -is [array]) {
                            $result.software | ForEach-Object {
                                $_.PSObject.TypeNames.Insert(0, 'FleetDM.Software')
                            }
                        }
                    }
                    '^users?(/|$)' {
                        if ($result.user) {
                            $result.user.PSObject.TypeNames.Insert(0, 'FleetDM.User')
                        }
                        elseif ($result.users) {
                            $result.users | ForEach-Object {
                                $_.PSObject.TypeNames.Insert(0, 'FleetDM.User')
                            }
                        }
                    }
                    '^teams?(/|$)' {
                        if ($result.team) {
                            $result.team.PSObject.TypeNames.Insert(0, 'FleetDM.Team')
                        }
                        elseif ($result.teams) {
                            $result.teams | ForEach-Object {
                                $_.PSObject.TypeNames.Insert(0, 'FleetDM.Team')
                            }
                        }
                    }
                    '^labels?(/|$)' {
                        if ($result.label) {
                            $result.label.PSObject.TypeNames.Insert(0, 'FleetDM.Label')
                        }
                        elseif ($result.labels) {
                            $result.labels | ForEach-Object {
                                $_.PSObject.TypeNames.Insert(0, 'FleetDM.Label')
                            }
                        }
                    }
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