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

    .PARAMETER FleetId
        Fleet Premium. Limits software to hosts in this fleet. Use 0 for unassigned hosts.

    .PARAMETER AvailableForInstall
        Only return software that has an installer. Installers require Fleet Premium.

    .PARAMETER SelfService
        Fleet Premium. Only return self-service software.

    .PARAMETER MinCvssScore
        Fleet Premium. Minimum CVSS v3 score, exclusive of scores below this value.

    .PARAMETER MaxCvssScore
        Fleet Premium. Maximum CVSS v3 score.

    .PARAMETER Exploit
        Fleet Premium. Only return software with a CISA known exploited vulnerability.

    .NOTES
        FleetId, SelfService, MinCvssScore, MaxCvssScore, and Exploit require Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#list-software-versions
    
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
        [Parameter(ParameterSetName = 'ById')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(ParameterSetName = 'List')]
        [switch]$AvailableForInstall,

        [Parameter(ParameterSetName = 'List')]
        [switch]$SelfService,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, 10)]
        [double]$MinCvssScore,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, 10)]
        [double]$MaxCvssScore,

        [Parameter(ParameterSetName = 'List')]
        [switch]$Exploit,
        
        [Parameter(ParameterSetName = 'List')]
        [int]$Page,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 500)]
        [int]$PerPage = 100,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('name', 'hosts_count', 'cve_published', 'cvss_score', 'epss_probability', 'cisa_known_exploit')]
        [string]$OrderKey,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('asc', 'desc')]
        [string]$OrderDirection = 'asc'
    )
    
    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            # Get specific software
            $endpoint = "software/versions/$Id"
            
            Write-Verbose "Retrieving software with ID: $Id"
            
            try {
                $versionQuery = @{}
                if ($PSBoundParameters.ContainsKey('FleetId')) {
                    $versionQuery['fleet_id'] = $FleetId
                }
                if ($versionQuery.Count -gt 0) {
                    $result = Invoke-FleetDMRequest -Endpoint $endpoint -Method GET -QueryParameters $versionQuery
                }
                else {
                    $result = Invoke-FleetDMRequest -Endpoint $endpoint -Method GET
                }
                
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
            # available_for_install and self_service are software title filters.
            $useTitles = $AvailableForInstall -or $SelfService
            $endpoint = if ($useTitles) { 'software/titles' } else { 'software/versions' }
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
                Write-Verbose "Version filtering will be applied client-side"
            }
            
            if ($Cve) {
                $queryParams['cve'] = $Cve
                if (-not $Name) {
                    # List software versions searches CVE text through query.
                    $queryParams['query'] = $Cve
                }
            }

            if ($PSBoundParameters.ContainsKey('FleetId')) {
                $queryParams['fleet_id'] = $FleetId
            }

            if ($AvailableForInstall) {
                $queryParams['available_for_install'] = 'true'
            }

            if ($SelfService) {
                $queryParams['self_service'] = 'true'
            }

            if ($PSBoundParameters.ContainsKey('MinCvssScore')) {
                $queryParams['min_cvss_score'] = $MinCvssScore
            }

            if ($PSBoundParameters.ContainsKey('MaxCvssScore')) {
                $queryParams['max_cvss_score'] = $MaxCvssScore
            }

            if ($Exploit) {
                $queryParams['exploit'] = 'true'
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
                if ($useTitles -and $response -and $null -ne $response.software_titles) {
                    $result = $response.software_titles
                }
                elseif ($response -and $null -ne $response.software) {
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
            
            # Add custom type for formatting. Wrap a single object so Windows
            # PowerShell 5.1 still applies calculated properties.
            if ($result) {
                if ($result -isnot [System.Collections.IList]) {
                    $result = @($result)
                }
                for ($i = 0; $i -lt $result.Count; $i++) {
                    $result[$i].PSObject.TypeNames.Insert(0, 'FleetDM.Software')
                    
                    # Add calculated properties
                    if ($result[$i].vulnerabilities) {
                        $cveCount = @($result[$i].vulnerabilities).Count
                        Add-Member -InputObject $result[$i] -MemberType NoteProperty -Name 'cve_count' -Value $cveCount -Force
                        
                        # Find highest severity - handle cases where severity might be missing
                        $severities = @($result[$i].vulnerabilities | Where-Object { $_.severity } | ForEach-Object { $_.severity })
                        $highestSeverity = 'none'
                        if ($severities.Count -eq 0 -and @($result[$i].vulnerabilities).Count -gt 0) {
                            # Has vulnerabilities but no severity info
                            $highestSeverity = 'medium'
                        }
                        elseif ($severities -contains 'critical') { $highestSeverity = 'critical' }
                        elseif ($severities -contains 'high') { $highestSeverity = 'high' }
                        elseif ($severities -contains 'medium') { $highestSeverity = 'medium' }
                        elseif ($severities -contains 'low') { $highestSeverity = 'low' }
                        
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