function Get-FleetSetupExperienceSoftware {
    <#
    .SYNOPSIS
        Lists software that can install during setup, and whether it does.

    .DESCRIPTION
        Sends GET /api/v1/fleet/setup_experience/software and follows pagination.
        Titles with software_package.install_during_setup or app_store_app.install_during_setup set to true install during setup.
        Fleet 4.96 requires fleet_id. FleetId defaults to 0, which is "Unassigned".

    .PARAMETER FleetId
        Fleet to list. Use 0 for "Unassigned".

    .PARAMETER Platform
        macos, windows, linux, ios, ipados, or android. Fleet defaults to macos.

    .EXAMPLE
        Get-FleetSetupExperienceSoftware -FleetId 2 -Platform linux

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#list-setup-experience-software

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-setup-experience-software
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.SetupExperienceSoftware')]
    param(
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId = 0,

        [ValidateSet('macos', 'windows', 'linux', 'ios', 'ipados', 'android')]
        [string[]]$Platform
    )

    $queryParams = @{ fleet_id = $FleetId; per_page = 100 }
    if ($Platform) { $queryParams['platform'] = @($Platform) }
    $response = Invoke-FleetDMRequest -Endpoint 'setup_experience/software' -QueryParameters $queryParams -FollowPagination
    return (Get-FleetListResult -Response $response -Name 'software_titles' -TypeName 'FleetDM.SetupExperienceSoftware')
}
