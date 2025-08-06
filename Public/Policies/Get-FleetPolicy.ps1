function Get-FleetPolicy {
    <#
    .SYNOPSIS
        Retrieves policies from FleetDM
    
    .DESCRIPTION
        Gets one or more policies from FleetDM. Policies define compliance rules that are regularly checked on hosts.
    
    .PARAMETER Id
        The specific policy ID to retrieve
    
    .PARAMETER Name
        Filter policies by name (partial match)
    
    .PARAMETER Page
        Page number for pagination (0-based)
    
    .PARAMETER PerPage
        Number of results per page (default: 100)
    
    .EXAMPLE
        Get-FleetPolicy
        
        Gets all global policies
    
    .EXAMPLE
        Get-FleetPolicy -Id 42
        
        Gets the policy with ID 42
    
    .EXAMPLE
        Get-FleetPolicy -Name "encryption"
        
        Gets all policies with "encryption" in the name
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api#list-policies
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,
        
        [Parameter(ParameterSetName = 'List')]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Page = 0,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 1000)]
        [int]$PerPage = 100
    )
    
    process {
        # Get specific policy by ID
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Write-Verbose "Retrieving policy ID: $Id"
            
            try {
                $endpoint = "global/policies/$Id"
                $response = Invoke-FleetDMRequest -Endpoint $endpoint -Method GET
                
                if ($response.policy) {
                    # Add custom type for formatting
                    $response.policy.PSObject.TypeNames.Insert(0, 'FleetDM.Policy')
                    
                    # Add calculated properties
                    $response.policy = Add-FleetPolicyCalculatedProperties -Policy $response.policy
                    
                    return $response.policy
                }
            }
            catch {
                if ($_.Exception.Message -like "*not found*") {
                    Write-Warning "Policy with ID $Id not found"
                    return $null
                }
                throw
            }
        }
        else {
            # List policies with filters
            $queryParams = @{
                per_page = $PerPage
            }
            
            # Add optional parameters
            if ($PSBoundParameters.ContainsKey('Page')) {
                $queryParams['page'] = $Page
            }
            
            $endpoint = "global/policies"
            Write-Verbose "Retrieving global policies"
            
            Write-Verbose "Query parameters: $($queryParams | ConvertTo-Json -Compress)"
            
            # Determine if we should follow pagination
            $followPagination = -not $PSBoundParameters.ContainsKey('Page')
            
            if ($followPagination) {
                $result = Invoke-FleetDMRequest -Endpoint $endpoint -QueryParameters $queryParams -FollowPagination
            }
            else {
                $response = Invoke-FleetDMRequest -Endpoint $endpoint -QueryParameters $queryParams
                $result = $response.policies
            }
            
            # Filter by name if specified (client-side filtering)
            if ($Name) {
                $result = $result | Where-Object { $_.name -like "*$Name*" }
                Write-Verbose "Filtered to $($result.Count) policies matching name '*$Name*'"
            }
            
            # Add custom type for formatting
            if ($result) {
                for ($i = 0; $i -lt $result.Count; $i++) {
                    $result[$i].PSObject.TypeNames.Insert(0, 'FleetDM.Policy')
                    
                    # Add calculated properties
                    $result[$i] = Add-FleetPolicyCalculatedProperties -Policy $result[$i]
                }
            }
            
            Write-Verbose "Retrieved $(if ($result) { $result.Count } else { 0 }) policies"
            
            return $result
        }
    }
}