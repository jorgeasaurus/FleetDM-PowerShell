function Remove-FleetTeam {
    <#
    .SYNOPSIS
        Deletes a Fleet Premium fleet.

    .DESCRIPTION
        Sends DELETE /api/v1/fleet/fleets/{id}.

    .PARAMETER Id
        Fleet ID.

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Remove-FleetTeam -Id 4

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#delete-fleet

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#delete-fleet
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,

        [switch]$Force
    )

    process {
        if ($Force -and -not $WhatIfPreference) {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ShouldProcess("fleet $Id", 'Remove')) {
            $null = Invoke-FleetDMRequest -Endpoint "fleets/$Id" -Method DELETE
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.RemovedTeam'
                Id = $Id
                Status = 'Removed'
                RemovedAt = Get-Date
            }
        }
    }
}
