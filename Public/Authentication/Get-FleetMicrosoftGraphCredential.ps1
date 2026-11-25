function Get-FleetMicrosoftGraphCredential {
    <#
    .SYNOPSIS
        Lists the Microsoft Graph credentials used for Windows Autopilot sync.

    .DESCRIPTION
        Sends GET /api/v1/fleet/microsoft_graph_credentials. Client secrets are write-only and never returned.
        credential_invalid is true when Entra or Graph rejected the credential.

    .EXAMPLE
        Get-FleetMicrosoftGraphCredential | Select-Object tenant_id, client_id, credential_invalid, last_synced_at

    .NOTES
        This cmdlet requires Fleet Premium and a global admin or GitOps role. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#list-microsoft-graph-credentials

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-microsoft-graph-credentials
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.MicrosoftGraphCredential')]
    param()

    $response = Invoke-FleetDMRequest -Endpoint 'microsoft_graph_credentials' -Method GET
    return (Get-FleetListResult -Response $response -Name 'microsoft_graph_credentials' -TypeName 'FleetDM.MicrosoftGraphCredential')
}
