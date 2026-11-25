function Set-FleetGoogleConditionalAccess {
    <#
    .SYNOPSIS
        Connects Fleet to Google for conditional access, or updates the connection.

    .DESCRIPTION
        With -Connect, sends POST /api/v1/fleet/conditional_access/google with customer_id, admin_email,
        and service_account_key. That replaces any stored settings and key.
        Without -Connect, sends PATCH /api/v1/fleet/conditional_access/google with only the supplied fields.
        A PATCH with no fields retries a connection that did not complete.

        The key file is read as JSON. service_account_key, private_key, and client_secret are redacted in the verbose log.

    .PARAMETER Connect
        Sends a full connect request. CustomerId, AdminEmail, and ServiceAccountKeyPath are required.

    .PARAMETER CustomerId
        Google customer ID with its leading C, for example C01234abc.

    .PARAMETER AdminEmail
        Google Workspace admin that Fleet acts as.

    .PARAMETER ServiceAccountKeyPath
        Service account JSON key file with domain-wide delegation for the cloud-identity.devices scope.

    .EXAMPLE
        Set-FleetGoogleConditionalAccess -Connect -CustomerId 'C01234abc' -AdminEmail 'fleet-admin@example.com' -ServiceAccountKeyPath ./key.json

    .EXAMPLE
        Set-FleetGoogleConditionalAccess -AdminEmail 'new-admin@example.com'

    .EXAMPLE
        Set-FleetGoogleConditionalAccess

        Retries a connection that did not complete.

    .NOTES
        This cmdlet requires Fleet Premium and a global admin or GitOps role. Fleet Free responds with HTTP 402.
        Fleet returns 422 with Google's reason when Google refuses the service account.
        https://fleetdm.com/docs/rest-api/rest-api#connect-google

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#connect-google
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Update')]
    [OutputType('FleetDM.GoogleConditionalAccess')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Connect')]
        [switch]$Connect,

        [Parameter(Mandatory, ParameterSetName = 'Connect')]
        [Parameter(ParameterSetName = 'Update')]
        [ValidatePattern('^C[0-9A-Za-z]+$')]
        [string]$CustomerId,

        [Parameter(Mandatory, ParameterSetName = 'Connect')]
        [Parameter(ParameterSetName = 'Update')]
        [ValidateNotNullOrEmpty()]
        [string]$AdminEmail,

        [Parameter(Mandatory, ParameterSetName = 'Connect')]
        [Parameter(ParameterSetName = 'Update')]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceAccountKeyPath
    )

    $body = @{}
    if ($PSBoundParameters.ContainsKey('CustomerId')) { $body['customer_id'] = $CustomerId }
    if ($PSBoundParameters.ContainsKey('AdminEmail')) { $body['admin_email'] = $AdminEmail }
    if ($PSBoundParameters.ContainsKey('ServiceAccountKeyPath')) {
        $file = Get-FleetUploadFile -Path $ServiceAccountKeyPath
        try {
            $key = [System.Text.Encoding]::UTF8.GetString($file.Bytes).TrimStart([char]0xFEFF) | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            throw "Service account key '$ServiceAccountKeyPath' is not valid JSON."
        }
        $body['service_account_key'] = $key
    }

    $method = if ($Connect) { 'POST' } else { 'PATCH' }
    $action = if ($Connect) { 'Connect and replace settings and key' } elseif ($body.Count -eq 0) { 'Retry connection' } else { "Update $(@($body.Keys | Sort-Object) -join ', ')" }

    if ($PSCmdlet.ShouldProcess('Google conditional access', $action)) {
        $response = Invoke-FleetDMRequest -Endpoint 'conditional_access/google' -Method $method -Body $body
        $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.GoogleConditionalAccess'
        return $response
    }
}
