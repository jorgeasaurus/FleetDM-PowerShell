function Get-FleetSoftwareTitle {
    <#
    .SYNOPSIS
        Lists software titles or gets one title.

    .DESCRIPTION
        Sends GET /api/v1/fleet/software/titles or GET /api/v1/fleet/software/titles/{id}.
        Title IDs are what the package, App Store, and install cmdlets take. Get-FleetSoftware -Id reads software versions, whose IDs differ.

    .PARAMETER Id
        Software title ID. Binds from the software_title_id property.

    .PARAMETER FleetId
        Fleet Premium. Limits the list or the title details to this fleet. Use 0 for "Unassigned".

    .PARAMETER Query
        Searches title names and CVEs.

    .PARAMETER AvailableForInstall
        Lists only titles with an installer, App Store app, or Fleet-maintained app added.

    .PARAMETER SelfService
        Lists only self-service titles.

    .PARAMETER PackagesOnly
        Fleet Premium. Lists only uploaded packages, without App Store apps.

    .PARAMETER Platform
        Lists titles available for install on these platforms. Requires FleetId.

    .PARAMETER Page
        Page number. When omitted, every page is retrieved.

    .PARAMETER PerPage
        Page size. The default is 100.

    .EXAMPLE
        Get-FleetSoftwareTitle -FleetId 2 -AvailableForInstall

    .EXAMPLE
        Get-FleetSoftwareTitle -Id 2792 -FleetId 2

    .EXAMPLE
        Get-FleetSoftwareTitle -FleetId 2 -PackagesOnly -Platform darwin, windows

    .NOTES
        FleetId and PackagesOnly require Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#list-software

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-software
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('FleetDM.SoftwareTitle')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('software_title_id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,

        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [switch]$AvailableForInstall,

        [Parameter(ParameterSetName = 'List')]
        [switch]$SelfService,

        [Parameter(ParameterSetName = 'List')]
        [switch]$PackagesOnly,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('macos', 'darwin', 'windows', 'linux', 'chrome', 'ios', 'ipados')]
        [string[]]$Platform,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Page,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 500)]
        [int]$PerPage = 100
    )

    process {
        $queryParams = @{}
        if ($PSBoundParameters.ContainsKey('FleetId')) { $queryParams['fleet_id'] = $FleetId }

        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $response = Invoke-FleetDMRequest -Endpoint "software/titles/$Id" -QueryParameters $queryParams
            return (Get-FleetResponseRecord -Response $response -Name 'software_title' -TypeName 'FleetDM.SoftwareTitle')
        }

        if ($Platform -and -not $PSBoundParameters.ContainsKey('FleetId')) {
            throw 'Platform requires FleetId. Fleet filters titles by platform only within a fleet.'
        }

        $queryParams['per_page'] = $PerPage
        if ($Query) { $queryParams['query'] = $Query }
        if ($AvailableForInstall) { $queryParams['available_for_install'] = $true }
        if ($SelfService) { $queryParams['self_service'] = $true }
        if ($PackagesOnly) { $queryParams['packages_only'] = $true }
        if ($Platform) { $queryParams['platform'] = @($Platform) }

        if ($PSBoundParameters.ContainsKey('Page')) {
            $queryParams['page'] = $Page
            $response = Invoke-FleetDMRequest -Endpoint 'software/titles' -QueryParameters $queryParams
        }
        else {
            $response = Invoke-FleetDMRequest -Endpoint 'software/titles' -QueryParameters $queryParams -FollowPagination
        }

        return (Get-FleetListResult -Response $response -Name 'software_titles' -TypeName 'FleetDM.SoftwareTitle')
    }
}
