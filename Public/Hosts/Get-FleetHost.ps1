function Get-FleetHost {
    <#
    .SYNOPSIS
        Retrieves host information from FleetDM
    
    .DESCRIPTION
        Gets one or more hosts from FleetDM with optional filtering by status, team, or hostname.
        Supports retrieving a specific host by ID or searching for hosts based on various criteria.
    
    .PARAMETER Id
        The specific host ID to retrieve. When specified, returns detailed information for a single host.
    
    .PARAMETER Status
        Filter hosts by status: online, offline, or missing
    
    .PARAMETER Hostname
        Search for hosts by hostname (partial match supported)
    
    .PARAMETER PolicyId
        Filter hosts by policy ID
    
    .PARAMETER SoftwareId
        Filter hosts by software ID
    
    .PARAMETER OSName
        Filter hosts by operating system name
    
    .PARAMETER OSVersion
        Filter hosts by operating system version
    
    .PARAMETER IncludeSoftware
        Include software inventory in the response. This significantly increases response size.
    
    .PARAMETER IncludePolicies
        Include policy compliance information in the response
    
    .PARAMETER DisableFailingPolicies
        Filter to only show hosts with failing policies disabled
    
    .PARAMETER DeviceMapping
        Include device mapping information
    
    .PARAMETER MDMId
        Filter by MDM ID
    
    .PARAMETER MDMEnrollmentStatus
        Filter by MDM enrollment status
    
    .PARAMETER MunkiIssueId
        Filter by Munki issue ID
    
    .PARAMETER LowDiskSpace
        Filter hosts with low disk space (less than specified GB)
    
    .PARAMETER Label
        Filter by label name or ID
    
    .PARAMETER Page
        Page number for pagination (0-based)
    
    .PARAMETER PerPage
        Number of results per page (default: 100)
    
    .PARAMETER OrderKey
        Field to sort by (hostname, created_at, updated_at)
    
    .PARAMETER OrderDirection
        Sort direction (asc or desc)
    
    .PARAMETER After
        Return hosts added after this date
    
    .EXAMPLE
        Get-FleetHost
        
        Gets all hosts in FleetDM
    
    .EXAMPLE
        Get-FleetHost -Status online
        
        Gets all online hosts
    
    .EXAMPLE
        Get-FleetHost -Id 123 -IncludeSoftware -IncludePolicies
        
        Gets detailed information for host ID 123 including software and policies
    
    .EXAMPLE
        Get-FleetHost -OSName "macOS" -Status online | Select-Object id, hostname, primary_ip
        
        Gets all online macOS hosts and displays their ID, hostname, and IP
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api#list-hosts
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('online', 'offline', 'missing', 'new')]
        [string]$Status,
        
        [Parameter(ParameterSetName = 'List')]
        [Alias('Query')]
        [string]$Hostname,
        
        [Parameter(ParameterSetName = 'List')]
        [int]$PolicyId,
        
        [Parameter(ParameterSetName = 'List')]
        [int]$SoftwareId,
        
        [Parameter(ParameterSetName = 'List')]
        [string]$OSName,
        
        [Parameter(ParameterSetName = 'List')]
        [string]$OSVersion,
        
        [Parameter(ParameterSetName = 'List')]
        [Alias('PopulateSoftware')]
        [switch]$IncludeSoftware,
        
        [Parameter(ParameterSetName = 'List')]
        [Parameter(ParameterSetName = 'ById')]
        [Alias('PopulatePolicies')]
        [switch]$IncludePolicies,
        
        [Parameter(ParameterSetName = 'List')]
        [switch]$DisableFailingPolicies,
        
        [Parameter(ParameterSetName = 'List')]
        [switch]$DeviceMapping,
        
        [Parameter(ParameterSetName = 'List')]
        [string]$MDMId,
        
        [Parameter(ParameterSetName = 'List')]
        [string]$MDMEnrollmentStatus,
        
        [Parameter(ParameterSetName = 'List')]
        [int]$MunkiIssueId,
        
        [Parameter(ParameterSetName = 'List')]
        [int]$LowDiskSpace,
        
        [Parameter(ParameterSetName = 'List')]
        [string]$Label,
        
        [Parameter(ParameterSetName = 'List')]
        [int]$Page,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 500)]
        [int]$PerPage = 100,
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('hostname', 'created_at', 'updated_at')]
        [string]$OrderKey = 'hostname',
        
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('asc', 'desc')]
        [string]$OrderDirection = 'asc',
        
        [Parameter(ParameterSetName = 'List')]
        [datetime]$After
    )
    
    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            # Get specific host
            $endpoint = "hosts/$Id"
            
            Write-Verbose "Retrieving host with ID: $Id"
            
            $result = Invoke-FleetDMRequest -Endpoint $endpoint -Method GET
            
            # Add custom type for formatting
            if ($result.host) {
                $result.host.PSObject.TypeNames.Insert(0, 'FleetDM.Host')
                return $result.host
            }
            else {
                Write-Warning "No host data returned for ID: $Id"
                return $null
            }
        }
        else {
            # List hosts with filters
            $queryParams = @{
                order_key = $OrderKey
                order_direction = $OrderDirection
                per_page = $PerPage
            }
            
            # Build query parameters using helper
            $paramMapping = @{
                'Page' = 'page'
                'Status' = 'status'
                'Hostname' = 'query'
                'PolicyId' = 'policy_id'
                'SoftwareId' = 'software_id'
                'OSName' = 'os_name'
                'OSVersion' = 'os_version'
                'IncludeSoftware' = 'populate_software'
                'IncludePolicies' = 'populate_policies'
                'DisableFailingPolicies' = 'disable_failing_policies'
                'DeviceMapping' = 'device_mapping'
                'MDMId' = 'mdm_id'
                'MDMEnrollmentStatus' = 'mdm_enrollment_status'
                'MunkiIssueId' = 'munki_issue_id'
                'LowDiskSpace' = 'low_disk_space'
                'Label' = 'label_name'
                'Id' = $null  # Exclude from query params
                'PerPage' = $null  # Already handled above
            }
            
            $additionalParams = ConvertTo-FleetQueryParameters -BoundParameters $PSBoundParameters -ParameterMapping $paramMapping
            
            # Merge with existing queryParams
            foreach ($key in $additionalParams.Keys) {
                $queryParams[$key] = $additionalParams[$key]
            }
            
            # Handle special cases
            if ($After) {
                $queryParams['after'] = $After.ToString('yyyy-MM-ddTHH:mm:ssZ')
            }
            
            Write-Verbose "Retrieving hosts with filters: $($queryParams | ConvertTo-Json -Compress)"
            
            # Determine if we should follow pagination
            $followPagination = -not $PSBoundParameters.ContainsKey('Page')
            
            if ($followPagination) {
                $result = Invoke-FleetDMRequest -Endpoint 'hosts' -QueryParameters $queryParams -FollowPagination
            }
            else {
                $response = Invoke-FleetDMRequest -Endpoint 'hosts' -QueryParameters $queryParams
                $result = $response.hosts
            }
            
            # Add custom type for formatting
            foreach ($fleetHost in $result) {
                $fleetHost.PSObject.TypeNames.Insert(0, 'FleetDM.Host')
            }
            
            Write-Verbose "Retrieved $($result.Count) hosts"
            
            return $result
        }
    }
}