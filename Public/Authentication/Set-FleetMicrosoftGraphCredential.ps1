function Set-FleetMicrosoftGraphCredential {
    <#
    .SYNOPSIS
        Replaces the Microsoft Graph credential used for Windows Autopilot sync.

    .DESCRIPTION
        Sends PUT /api/v1/fleet/microsoft_graph_credentials. The request is declarative: the list sent
        becomes the stored list, and a stored tenant that is not in it is deleted. Fleet supports one credential.
        Fleet checks a new or changed credential against Microsoft Graph before saving it.
        -Clear sends an empty list, which deletes every stored credential.
        client_secret is redacted in the verbose log.

    .PARAMETER TenantId
        Microsoft Entra tenant ID.

    .PARAMETER ClientId
        Application (client) ID of the app registration.

    .PARAMETER ClientSecret
        Client secret. Required for a new credential or a changed tenant or client ID. Omit it to keep the stored secret.

    .PARAMETER DryRun
        Validates the credential against Microsoft Graph without saving it.

    .PARAMETER Clear
        Deletes every stored credential.

    .EXAMPLE
        $secret = Read-Host 'Client secret' -AsSecureString
        Set-FleetMicrosoftGraphCredential -TenantId 'fec37e96-3615-4e37-8fac-445d5328af3c' -ClientId '8c8e3fd4-9b2c-4d3e-8f10-2233445566aa' -ClientSecret $secret -DryRun

    .EXAMPLE
        Set-FleetMicrosoftGraphCredential -Clear

    .NOTES
        This cmdlet requires Fleet Premium and a global admin or GitOps role. Fleet Free responds with HTTP 402.
        Fleet returns 422 when an ID is not a GUID, a new credential has no secret, or Graph rejects it.
        https://fleetdm.com/docs/rest-api/rest-api#modify-microsoft-graph-credentials

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#modify-microsoft-graph-credentials
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Set')]
    [OutputType('FleetDM.MicrosoftGraphCredentialUpdate')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Set')]
        [ValidatePattern('^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$')]
        [string]$TenantId,

        [Parameter(Mandatory, ParameterSetName = 'Set')]
        [ValidatePattern('^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$')]
        [string]$ClientId,

        [Parameter(ParameterSetName = 'Set')]
        [securestring]$ClientSecret,

        [switch]$DryRun,

        [Parameter(Mandatory, ParameterSetName = 'Clear')]
        [switch]$Clear
    )

    $credentials = @()
    $action = 'Delete every Microsoft Graph credential'
    if (-not $Clear) {
        $credential = @{ tenant_id = $TenantId; client_id = $ClientId }
        if ($ClientSecret) {
            $credential['client_secret'] = [System.Net.NetworkCredential]::new('', $ClientSecret).Password
        }
        $credentials = @($credential)
        $action = "Replace the stored credentials with tenant $TenantId"
    }
    if ($DryRun) { $action = "$action (dry run, nothing is saved)" }

    $body = @{ microsoft_graph_credentials = $credentials }
    if ($DryRun) { $body['dry_run'] = $true }

    if ($PSCmdlet.ShouldProcess('Microsoft Graph credentials', $action)) {
        $null = Invoke-FleetDMRequest -Endpoint 'microsoft_graph_credentials' -Method PUT -Body $body
        [PSCustomObject]@{
            PSTypeName = 'FleetDM.MicrosoftGraphCredentialUpdate'
            TenantId = if ($Clear) { $null } else { $TenantId }
            ClientId = if ($Clear) { $null } else { $ClientId }
            SecretSent = [bool]$ClientSecret
            DryRun = [bool]$DryRun
            Status = if ($DryRun) { 'Validated' } elseif ($Clear) { 'Cleared' } else { 'Saved' }
        }
    }
}
