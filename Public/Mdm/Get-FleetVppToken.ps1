function Get-FleetVppToken {
    <#
    .SYNOPSIS
        Lists Volume Purchasing Program (VPP) tokens.

    .DESCRIPTION
        Sends GET /api/v1/fleet/vpp_tokens.

    .EXAMPLE
        Get-FleetVppToken | Select-Object id, org_name, renew_date, fleets

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#list-volume-purchasing-program-vpp-tokens

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-volume-purchasing-program-vpp-tokens
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.VppToken')]
    param()

    $response = Invoke-FleetDMRequest -Endpoint 'vpp_tokens' -Method GET
    return (Get-FleetListResult -Response $response -Name 'vpp_tokens' -TypeName 'FleetDM.VppToken')
}
