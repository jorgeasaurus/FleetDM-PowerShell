function Get-FleetSelfServiceCategory {
    <#
    .SYNOPSIS
        Lists self-service software categories for a fleet.

    .DESCRIPTION
        Sends GET /api/v1/fleet/software/self_service_categories.

    .PARAMETER FleetId
        Fleet ID. Use 0 for hosts that are not assigned to a fleet.

    .EXAMPLE
        Get-FleetSelfServiceCategory -FleetId 3

    .NOTES
        This cmdlet requires Fleet Premium. The Fleet Free service returns HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#list-self-service-categories
        https://fleetdm.com/guides/software-self-service

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-self-service-categories
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId
    )

    process {
        $response = Invoke-FleetDMRequest -Endpoint 'software/self_service_categories' -QueryParameters @{ fleet_id = $FleetId }
        return (Get-FleetListResult -Response $response -Name 'self_service_categories' -TypeName 'FleetDM.SelfServiceCategory')
    }
}
