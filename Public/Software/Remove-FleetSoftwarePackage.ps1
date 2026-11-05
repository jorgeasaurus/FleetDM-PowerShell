function Remove-FleetSoftwarePackage {
    <#
    .SYNOPSIS
        Removes software that is available for install.

    .DESCRIPTION
        Sends DELETE /api/v1/fleet/software/titles/{id}/available_for_install.
        The published contract says this removes the installer from Fleet and does not uninstall copies already on hosts.

    .PARAMETER SoftwareTitleId
        Software title ID.

    .PARAMETER FleetId
        Fleet that owns the installer. Use 0 for unassigned hosts.

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Remove-FleetSoftwarePackage -SoftwareTitleId 24 -FleetId 2

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#delete-software

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#delete-software
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$SoftwareTitleId,

        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [switch]$Force
    )

    process {
        if ($Force -and -not $WhatIfPreference) {
            $ConfirmPreference = 'None'
        }

        $target = "installable software title $SoftwareTitleId on fleet $FleetId"
        if ($PSCmdlet.ShouldProcess($target, 'Remove')) {
            $null = Invoke-FleetDMRequest -Endpoint "software/titles/$SoftwareTitleId/available_for_install" -Method DELETE -QueryParameters @{ fleet_id = $FleetId }
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.RemovedSoftwarePackage'
                SoftwareTitleId = $SoftwareTitleId
                FleetId = $FleetId
                Status = 'Removed'
            }
        }
    }
}
