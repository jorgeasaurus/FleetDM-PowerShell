function New-FleetSelfServiceCategory {
    <#
    .SYNOPSIS
        Creates a self-service software category.

    .DESCRIPTION
        Sends POST /api/v1/fleet/software/self_service_categories.
        The name must be unique within the fleet and at most 255 characters.

    .PARAMETER FleetId
        Fleet ID. Use 0 for unassigned hosts.

    .PARAMETER Name
        Category name.

    .EXAMPLE
        New-FleetSelfServiceCategory -FleetId 3 -Name "Engineering"

    .NOTES
        This cmdlet requires Fleet Premium. The Fleet Free service returns HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#add-self-service-category
        https://fleetdm.com/guides/software-self-service

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#add-self-service-category
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 255)]
        [string]$Name
    )

    process {
        if ($PSCmdlet.ShouldProcess($Name, "Create self-service category on fleet $FleetId")) {
            $response = Invoke-FleetDMRequest -Endpoint 'software/self_service_categories' -Method POST -Body @{
                fleet_id = $FleetId
                name = $Name
            }
            return (Get-FleetResponseRecord -Response $response -Name 'self_service_category' -TypeName 'FleetDM.SelfServiceCategory')
        }
    }
}
