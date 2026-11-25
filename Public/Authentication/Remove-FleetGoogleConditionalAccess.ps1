function Remove-FleetGoogleConditionalAccess {
    <#
    .SYNOPSIS
        Disconnects Fleet from Google and deletes the stored service account key.

    .DESCRIPTION
        Sends DELETE /api/v1/fleet/conditional_access/google. Hosts already marked as managed in Google stay marked.

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Remove-FleetGoogleConditionalAccess

    .NOTES
        This cmdlet requires Fleet Premium and a global admin or GitOps role. Fleet Free responds with HTTP 402.
        Fleet returns 502 and deletes nothing when fleetdm.com is unreachable.
        https://fleetdm.com/docs/rest-api/rest-api#delete-google

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#delete-google
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('FleetDM.RemovedGoogleConditionalAccess')]
    param(
        [switch]$Force
    )

    if ($Force -and -not $WhatIfPreference) {
        $ConfirmPreference = 'None'
    }

    if ($PSCmdlet.ShouldProcess('Google conditional access', 'Disconnect and delete the service account key')) {
        $null = Invoke-FleetDMRequest -Endpoint 'conditional_access/google' -Method DELETE
        [PSCustomObject]@{
            PSTypeName = 'FleetDM.RemovedGoogleConditionalAccess'
            Status = 'Removed'
        }
    }
}
