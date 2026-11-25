function Remove-FleetBootstrapPackage {
    <#
    .SYNOPSIS
        Deletes a fleet's bootstrap package.

    .DESCRIPTION
        Sends DELETE /api/v1/fleet/bootstrap/{fleet_id}.

    .PARAMETER FleetId
        Fleet ID. Use 0 for "Unassigned".

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Remove-FleetBootstrapPackage -FleetId 1

    .NOTES
        This cmdlet requires Fleet Premium and Apple MDM. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#delete-bootstrap-package

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#delete-bootstrap-package
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('FleetDM.RemovedBootstrapPackage')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('fleet_id')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [switch]$Force
    )

    process {
        if ($Force -and -not $WhatIfPreference) {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ShouldProcess("bootstrap package for fleet $FleetId", 'Remove')) {
            $null = Invoke-FleetDMRequest -Endpoint "bootstrap/$FleetId" -Method DELETE
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.RemovedBootstrapPackage'
                FleetId = $FleetId
                Status = 'Removed'
            }
        }
    }
}
