function Get-FleetAppStoreApp {
    <#
    .SYNOPSIS
        Lists App Store apps that can be added to a fleet.

    .DESCRIPTION
        Sends GET /api/v1/fleet/software/app_store_apps?fleet_id={fleet_id}.
        Apps already added to the fleet for a platform are left out.

    .PARAMETER FleetId
        Fleet to list apps for. Use 0 for "Unassigned".

    .PARAMETER VppTokenId
        VPP token to list apps from. Required when the fleet has more than one VPP token.

    .EXAMPLE
        Get-FleetAppStoreApp -FleetId 2

    .NOTES
        Requires Apple MDM and a VPP token assigned to the fleet.
        https://fleetdm.com/docs/rest-api/rest-api#list-apple-app-store-apps

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-apple-app-store-apps
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.AppStoreApp')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$VppTokenId
    )

    $query = @{ fleet_id = $FleetId }
    if ($PSBoundParameters.ContainsKey('VppTokenId')) { $query['vpp_token_id'] = $VppTokenId }
    $response = Invoke-FleetDMRequest -Endpoint 'software/app_store_apps' -QueryParameters $query
    return (Get-FleetListResult -Response $response -Name 'app_store_apps' -TypeName 'FleetDM.AppStoreApp')
}
