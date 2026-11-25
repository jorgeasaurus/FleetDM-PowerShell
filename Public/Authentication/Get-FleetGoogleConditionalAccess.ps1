function Get-FleetGoogleConditionalAccess {
    <#
    .SYNOPSIS
        Gets the Google conditional access settings and connection state.

    .DESCRIPTION
        Sends GET /api/v1/fleet/conditional_access/google. The service account key is never returned;
        service_account_key_configured says whether one is stored. An empty state means Google is not configured.

    .EXAMPLE
        Get-FleetGoogleConditionalAccess | Select-Object customer_id, admin_email, state

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#get-google

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#get-google
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.GoogleConditionalAccess')]
    param()

    $response = Invoke-FleetDMRequest -Endpoint 'conditional_access/google' -Method GET
    $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.GoogleConditionalAccess'
    return $response
}
