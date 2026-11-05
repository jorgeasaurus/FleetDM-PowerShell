function Remove-FleetScript {
    <#
    .SYNOPSIS
        Deletes a saved script.

    .DESCRIPTION
        Sends DELETE /api/v1/fleet/scripts/{id}.

    .PARAMETER Id
        Script ID.

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Remove-FleetScript -Id 4

    .NOTES
        Deleting a script that belongs to a fleet requires Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#delete-script

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#delete-script
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

        if ($PSCmdlet.ShouldProcess("script $Id", 'Remove')) {
            $null = Invoke-FleetDMRequest -Endpoint "scripts/$Id" -Method DELETE
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.RemovedScript'
                Id = $Id
                Status = 'Removed'
            }
        }
    }
}
