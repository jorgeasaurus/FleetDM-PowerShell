function Get-FleetQuery {
    <#
    .SYNOPSIS
        Retrieves saved queries from FleetDM
    
    .DESCRIPTION
        Gets one or more saved queries from FleetDM with optional filtering.
        Use this to find query IDs for use with Invoke-FleetQuery or Invoke-FleetSavedQuery.
    
    .PARAMETER Id
        The specific query ID to retrieve
    
    .PARAMETER Name
        Filter queries by name (partial match)
    
    .PARAMETER Page
        Page number for pagination (0-based)
    
    .PARAMETER PerPage
        Number of results per page (default: 100)
    
    .EXAMPLE
        Get-FleetQuery
        
        Gets all saved queries
    
    .EXAMPLE
        Get-FleetQuery -Name "users"
        
        Gets all queries with "users" in the name
    
    .EXAMPLE
        Get-FleetQuery -Id 42
        
        Gets details for query ID 42
    
    .EXAMPLE
        Get-FleetQuery | Where-Object { $_.query -like "*chrome*" } | Format-Table id, name, query -Wrap
        
        Lists all queries that reference Chrome
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api#list-queries
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,
        
        [Parameter(ParameterSetName = 'List')]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'List')]
        [int]$Page,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 500)]
        [int]$PerPage = 100
    )
    
    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            # Get specific query
            $endpoint = "queries/$Id"
            
            Write-Verbose "Retrieving query with ID: $Id"
            
            $result = Invoke-FleetDMRequest -Endpoint $endpoint -Method GET
            
            # Add custom type for formatting
            if ($result.query) {
                $result.query.PSObject.TypeNames.Insert(0, 'FleetDM.Query')
                return $result.query
            }
            else {
                Write-Warning "No query data returned for ID: $Id"
                return $null
            }
        }
        else {
            # List queries with filters
            $queryParams = @{
                per_page = $PerPage
            }
            
            # Add optional parameters
            if ($PSBoundParameters.ContainsKey('Page')) {
                $queryParams['page'] = $Page
            }
            
            Write-Verbose "Retrieving queries with filters: $($queryParams | ConvertTo-Json -Compress)"
            
            # Determine if we should follow pagination
            $followPagination = -not $PSBoundParameters.ContainsKey('Page')
            
            if ($followPagination) {
                $result = Invoke-FleetDMRequest -Endpoint 'queries' -QueryParameters $queryParams -FollowPagination
            }
            else {
                $response = Invoke-FleetDMRequest -Endpoint 'queries' -QueryParameters $queryParams
                $result = $response.queries
            }
            
            # Filter by name if specified (client-side filtering)
            if ($Name) {
                $result = $result | Where-Object { $_.name -like "*$Name*" }
            }
            
            # Add custom type for formatting
            foreach ($query in $result) {
                $query.PSObject.TypeNames.Insert(0, 'FleetDM.Query')
            }
            
            Write-Verbose "Retrieved $($result.Count) queries"
            
            return $result
        }
    }
}