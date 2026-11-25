function Get-FleetAppleBusinessToken {
    <#
    .SYNOPSIS
        Lists Apple Business (AB) tokens.

    .DESCRIPTION
        Sends GET /api/v1/fleet/ab_tokens. Fleet 4.96 returns the list as ab_tokens and the older abm_tokens shape.
        ab_tokens is read when present. Older servers only send abm_tokens.

    .EXAMPLE
        Get-FleetAppleBusinessToken | Select-Object org_name, renew_date, terms_expired

    .NOTES
        This cmdlet requires Fleet Premium and a global admin or GitOps role. Fleet Free responds with HTTP 402.
        Fleet documents no route to add, renew, or delete an AB token.
        https://fleetdm.com/docs/rest-api/rest-api#list-apple-business-ab-tokens

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-apple-business-ab-tokens
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.AppleBusinessToken')]
    param()

    $response = Invoke-FleetDMRequest -Endpoint 'ab_tokens' -Method GET
    $name = if ($response -and $response.PSObject.Properties['ab_tokens']) { 'ab_tokens' } else { 'abm_tokens' }
    return (Get-FleetListResult -Response $response -Name $name -TypeName 'FleetDM.AppleBusinessToken')
}
