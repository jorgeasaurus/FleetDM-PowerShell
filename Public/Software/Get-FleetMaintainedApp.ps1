function Get-FleetMaintainedApp {
    <#
    .SYNOPSIS
        Lists Fleet-maintained apps or gets one.

    .DESCRIPTION
        Sends GET /api/v1/fleet/software/fleet_maintained_apps or GET /api/v1/fleet/software/fleet_maintained_apps/{id}.
        With FleetId, each app carries software_title_id when it is already added to that fleet.

    .PARAMETER Id
        Fleet-maintained app ID.

    .PARAMETER FleetId
        Fleet whose software_title_id values are filled in.

    .PARAMETER Query
        Searches app names.

    .PARAMETER Platform
        Lists apps for darwin or windows.

    .PARAMETER Available
        Lists only apps not yet added to FleetId.

    .EXAMPLE
        Get-FleetMaintainedApp -Query 'Slack' -Platform darwin

    .EXAMPLE
        Get-FleetMaintainedApp -Id 1 -FleetId 2

    .NOTES
        Listing is available in Fleet Free. Adding an app requires Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#list-fleet-maintained-apps

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-fleet-maintained-apps
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('FleetDM.MaintainedApp')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,

        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('darwin', 'windows')]
        [string]$Platform,

        [Parameter(ParameterSetName = 'List')]
        [switch]$Available
    )

    process {
        $queryParams = @{}
        if ($PSBoundParameters.ContainsKey('FleetId')) { $queryParams['fleet_id'] = $FleetId }

        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $response = Invoke-FleetDMRequest -Endpoint "software/fleet_maintained_apps/$Id" -QueryParameters $queryParams
            return (Get-FleetResponseRecord -Response $response -Name 'fleet_maintained_app' -TypeName 'FleetDM.MaintainedApp')
        }

        if ($Available -and -not $PSBoundParameters.ContainsKey('FleetId')) {
            throw 'Available requires FleetId.'
        }

        $queryParams['per_page'] = 100
        if ($Query) { $queryParams['query'] = $Query }
        if ($Platform) { $queryParams['platform'] = $Platform }
        if ($Available) { $queryParams['available'] = $true }

        $response = Invoke-FleetDMRequest -Endpoint 'software/fleet_maintained_apps' -QueryParameters $queryParams -FollowPagination
        return (Get-FleetListResult -Response $response -Name 'fleet_maintained_apps' -TypeName 'FleetDM.MaintainedApp')
    }
}
