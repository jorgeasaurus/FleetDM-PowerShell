function Set-FleetSelfServiceCategory {
    <#
    .SYNOPSIS
        Renames a self-service software category.

    .DESCRIPTION
        Sends PATCH /api/v1/fleet/software/self_service_categories/{id}.

    .PARAMETER Id
        Category ID.

    .PARAMETER Name
        New category name.

    .EXAMPLE
        Set-FleetSelfServiceCategory -Id 42 -Name "Engineering tools"

    .NOTES
        This cmdlet requires Fleet Premium. The Fleet Free service returns HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#update-self-service-category

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-self-service-category
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 255)]
        [string]$Name
    )

    process {
        if ($PSCmdlet.ShouldProcess("self-service category $Id", "Rename to $Name")) {
            $response = Invoke-FleetDMRequest -Endpoint "software/self_service_categories/$Id" -Method PATCH -Body @{ name = $Name }
            return (Get-FleetResponseRecord -Response $response -Name 'self_service_category' -TypeName 'FleetDM.SelfServiceCategory')
        }
    }
}
