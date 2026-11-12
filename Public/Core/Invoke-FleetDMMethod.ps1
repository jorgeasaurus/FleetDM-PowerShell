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

    .PARAMETER MaxRetries
        Maximum number of additional attempts after the first request. The default
        is 3 when this is omitted. HTTP 429 is retried for every method. HTTP 502,
        503, and 504 are retried for GET. Gateway retries wait 2, 4, then 8 seconds.
        A 429, and a gateway response that sends one, waits for Retry-After or for
        "retry after: Ns" in the error. Each wait is capped by -MaxRetryDelaySeconds.

    .PARAMETER MaxRetryDelaySeconds
        Longest wait before one retry, in seconds. The default is 120 when this
        is omitted. Retry-After and the backoff cannot sleep longer than this.

    .PARAMETER RetryNonIdempotent
        Also retry POST, PUT, PATCH, and DELETE after HTTP 502, 503, or 504.
        HTTP 429 is retried without this switch.
    
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

    .EXAMPLE
        Invoke-FleetDMMethod -Endpoint "hosts" -MaxRetries 0

        Sends one GET and does not retry HTTP 429 or a gateway error.

    .EXAMPLE
        Invoke-FleetDMMethod -Endpoint "hosts/123/refetch" -Method POST -RetryNonIdempotent

        Retries that POST after HTTP 502, 503, or 504. Leave the switch off when
        repeating the call could apply the change twice. HTTP 429 is retried either way.
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api
    #>
    [CmdletBinding(SupportsShouldProcess)]
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
        [ValidateRange(0, 100)]
        [int]$MaxRetries = 3,

        [Parameter()]
        [ValidateRange(1, 2147483)]
        [int]$MaxRetryDelaySeconds = 120,

        [Parameter()]
        [switch]$RetryNonIdempotent,
        
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
            Write-Verbose "Request body: $(Get-FleetRedactedLogText -Text $Body)"
        }
        
        if ($QueryParameters) {
            $requestParams['QueryParameters'] = $QueryParameters
            Write-Verbose "Query parameters: $(Get-FleetRedactedLogText -Text $QueryParameters)"
        }
        
        if ($FollowPagination) {
            $requestParams['FollowPagination'] = $true
        }

        # Pass these only when the caller set them. The request function owns the
        # defaults, and callers that mock it declare a fixed parameter list.
        if ($PSBoundParameters.ContainsKey('MaxRetries')) {
            $requestParams['MaxRetries'] = $MaxRetries
        }

        if ($PSBoundParameters.ContainsKey('MaxRetryDelaySeconds')) {
            $requestParams['MaxRetryDelaySeconds'] = $MaxRetryDelaySeconds
        }

        if ($RetryNonIdempotent) {
            $requestParams['RetryNonIdempotent'] = $true
        }
        
        if ($Method -ne 'GET' -and -not $PSCmdlet.ShouldProcess($Endpoint, $Method)) {
            return
        }

        try {
            $result = Invoke-FleetDMRequest @requestParams
            
            Write-Verbose "Request completed successfully"
            
            # Try to add type information if we can identify the object type.
            # Add-FleetTypeName mutates each object and also passes it through.
            # Discard that output so callers receive only the envelope below.
            if (-not $Raw -and $result) {
                # For collections, add type information to the nested data
                if ($result.PSObject.Properties.Name -contains 'hosts') {
                    $null = $result.hosts | Add-FleetTypeName -TypeName 'FleetDM.Host'
                }
                elseif ($result.PSObject.Properties.Name -contains 'policies') {
                    $null = $result.policies | Add-FleetTypeName -TypeName 'FleetDM.Policy'
                }
                elseif ($result.PSObject.Properties.Name -contains 'queries') {
                    $null = $result.queries | Add-FleetTypeName -TypeName 'FleetDM.Query'
                }
                elseif ($result.PSObject.Properties.Name -contains 'software') {
                    $null = $result.software | Add-FleetTypeName -TypeName 'FleetDM.Software'
                }
                elseif ($result.PSObject.Properties.Name -contains 'users') {
                    $null = $result.users | Add-FleetTypeName -TypeName 'FleetDM.User'
                }
                elseif ($result.PSObject.Properties.Name -contains 'teams') {
                    $null = $result.teams | Add-FleetTypeName -TypeName 'FleetDM.Team'
                }
                elseif ($result.PSObject.Properties.Name -contains 'labels') {
                    $null = $result.labels | Add-FleetTypeName -TypeName 'FleetDM.Label'
                }
                # For single objects
                elseif ($result.PSObject.Properties.Name -contains 'host') {
                    $null = $result.host | Add-FleetTypeName -TypeName 'FleetDM.Host'
                }
                elseif ($result.PSObject.Properties.Name -contains 'policy') {
                    $null = $result.policy | Add-FleetTypeName -TypeName 'FleetDM.Policy'
                }
                elseif ($result.PSObject.Properties.Name -contains 'query') {
                    $null = $result.query | Add-FleetTypeName -TypeName 'FleetDM.Query'
                }
                elseif ($result.PSObject.Properties.Name -contains 'user') {
                    $null = $result.user | Add-FleetTypeName -TypeName 'FleetDM.User'
                }
                elseif ($result.PSObject.Properties.Name -contains 'team') {
                    $null = $result.team | Add-FleetTypeName -TypeName 'FleetDM.Team'
                }
                elseif ($result.PSObject.Properties.Name -contains 'label') {
                    $null = $result.label | Add-FleetTypeName -TypeName 'FleetDM.Label'
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