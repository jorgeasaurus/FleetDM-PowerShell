function Remove-FleetSelfServiceCategory {
    <#
    .SYNOPSIS
        Deletes a self-service software category.

    .DESCRIPTION
        Sends DELETE /api/v1/fleet/software/self_service_categories/{id}.
        Software assigned to the category remains installed.

    .PARAMETER Id
        Category ID.

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Remove-FleetSelfServiceCategory -Id 42

    .NOTES
        This cmdlet requires Fleet Premium. The Fleet Free service returns HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#delete-self-service-category

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#delete-self-service-category
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

        if ($PSCmdlet.ShouldProcess("self-service category $Id", 'Remove')) {
            $null = Invoke-FleetDMRequest -Endpoint "software/self_service_categories/$Id" -Method DELETE
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.RemovedSelfServiceCategory'
                Id = $Id
                Status = 'Removed'
            }
        }
    }
}
