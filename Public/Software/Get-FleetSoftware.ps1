function Get-FleetSoftware {
    <#
    .SYNOPSIS
        Retrieves software inventory from FleetDM
    
    .DESCRIPTION
        Gets software inventory information from FleetDM. Can retrieve all software or filter by various criteria.
        Software inventory includes installed applications, versions, and vulnerability information.
    
    .PARAMETER Id
        The specific software ID to retrieve
    
    .PARAMETER Name
        Filter software by name (partial match)
    
    .PARAMETER Version
        Filter software by version
    
    .PARAMETER Cve
        Filter software by CVE (Common Vulnerabilities and Exposures) ID
    
    .PARAMETER VulnerableOnly
        Only return software with known vulnerabilities
    
    .PARAMETER Page
        Page number for pagination (0-based)
    
    .PARAMETER PerPage
        Number of results per page (default: 100)
    
    .PARAMETER OrderKey
        Sort results by this field (name, hosts_count, cve_published, cve_resolved)
    
    .PARAMETER OrderDirection
        Sort direction (asc or desc)
    
    .EXAMPLE
        Get-FleetSoftware
        
        Gets all software inventory
    
    .EXAMPLE
        Get-FleetSoftware -Name "Chrome"
        
        Gets all software with "Chrome" in the name
    
    .EXAMPLE
        Get-FleetSoftware -VulnerableOnly
        
        Gets only software with known vulnerabilities
    
    .EXAMPLE
        Get-FleetSoftware -Cve "CVE-2023-1234"
        
        Gets software affected by specific CVE
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api#list-software
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,
        
        [Parameter(ParameterSetName = 'List')]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'List')]
        [string]$Version,
        
        [Parameter(ParameterSetName = 'List')]
        [string]$Cve,
        
        [Parameter(ParameterSetName = 'List')]
        [switch]$VulnerableOnly,
        
        [Parameter(ParameterSetName = 'List')]
        [int]$Page,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 500)]
        [int]$PerPage = 100,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('name', 'hosts_count', 'cve_published', 'cve_resolved')]
        [string]$OrderKey,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('asc', 'desc')]
        [string]$OrderDirection = 'asc'
    )
    
    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            # Get specific software
            $endpoint = "software/$Id"
            
            Write-Verbose "Retrieving software with ID: $Id"
            
            try {
                $result = Invoke-FleetDMRequest -Endpoint $endpoint -Method GET
                
                # Add custom type for formatting
                if ($result.software) {
                    $result.software.PSObject.TypeNames.Insert(0, 'FleetDM.Software')
                    return $result.software
                }
                else {
                    Write-Warning "No software data returned for ID: $Id"
                    return $null
                }
            }
            catch {
                if ($_.Exception.Message -like "*not found*") {
                    Write-Warning "Software with ID $Id not found"
                    return $null
                }
                throw
            }
        }
        else {
            # List software with filters
            $endpoint = "software"
            $queryParams = @{
                per_page = $PerPage
            }
            
            # Add optional parameters
            if ($PSBoundParameters.ContainsKey('Page')) {
                $queryParams['page'] = $Page
            }
            
            if ($VulnerableOnly) {
                $queryParams['vulnerable'] = 'true'
            }
            
            if ($OrderKey) {
                $queryParams['order_key'] = $OrderKey
                $queryParams['order_direction'] = $OrderDirection
            }
            
            # Server-side filtering parameters
            if ($Name) {
                $queryParams['query'] = $Name
            }
            
            if ($Version) {
                # Note: API might not support version filtering directly
                Write-Verbose "Version filtering will be applied client-side"
            }
            
            if ($Cve) {
                # Note: API might require different parameter name
                $queryParams['cve'] = $Cve
            }
            
            Write-Verbose "Query parameters: $($queryParams | ConvertTo-Json -Compress)"
            
            # Determine if we should follow pagination
            $followPagination = -not $PSBoundParameters.ContainsKey('Page')
            
            if ($followPagination) {
                $result = Invoke-FleetDMRequest -Endpoint $endpoint -QueryParameters $queryParams -FollowPagination
            }
            else {
                $response = Invoke-FleetDMRequest -Endpoint $endpoint -QueryParameters $queryParams
                # Handle response structure - API returns object with software array
                if ($response -and $response.PSObject.Properties.Name -contains 'software') {
                    $result = $response.software
                }
                else {
                    $result = @()
                }
            }
            
            # Apply client-side filtering if needed
            if ($Version -and $result) {
                $result = $result | Where-Object { $_.version -like "*$Version*" }
                Write-Verbose "Filtered to $($result.Count) software items matching version '*$Version*'"
            }
            
            # Add custom type for formatting
            if ($result) {
                for ($i = 0; $i -lt $result.Count; $i++) {
                    $result[$i].PSObject.TypeNames.Insert(0, 'FleetDM.Software')
                    
                    # Add calculated properties
                    if ($result[$i].vulnerabilities) {
                        $cveCount = @($result[$i].vulnerabilities).Count
                        Add-Member -InputObject $result[$i] -MemberType NoteProperty -Name 'cve_count' -Value $cveCount -Force
                        
                        # Find highest severity - handle cases where severity might be missing
                        $severities = @($result[$i].vulnerabilities | Where-Object { $_.severity } | ForEach-Object { $_.severity })
                        $highestSeverity = if ($severities.Count -eq 0 -and $result[$i].vulnerabilities.Count -gt 0) {
                                              # Has vulnerabilities but no severity info - default to 'medium'
                                              'medium'
                                          }
                                          elseif ($severities -contains 'critical') { 'critical' }
                                          elseif ($severities -contains 'high') { 'high' }
                                          elseif ($severities -contains 'medium') { 'medium' }
                                          elseif ($severities -contains 'low') { 'low' }
                                          else { 'none' }
                        
                        Add-Member -InputObject $result[$i] -MemberType NoteProperty -Name 'highest_severity' -Value $highestSeverity -Force
                    }
                    else {
                        Add-Member -InputObject $result[$i] -MemberType NoteProperty -Name 'cve_count' -Value 0 -Force
                        Add-Member -InputObject $result[$i] -MemberType NoteProperty -Name 'highest_severity' -Value 'none' -Force
                    }
                }
            }
            
            Write-Verbose "Retrieved $($result.Count) software items"
            
            return $result
        }
    }
}