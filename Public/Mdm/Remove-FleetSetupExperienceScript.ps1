function Remove-FleetSetupExperienceScript {
    <#
    .SYNOPSIS
        Deletes the script that runs during macOS setup.

    .DESCRIPTION
        Sends DELETE /api/v1/fleet/setup_experience/script.

    .PARAMETER FleetId
        Fleet whose script is deleted. Omit it for "Unassigned".

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Remove-FleetSetupExperienceScript -FleetId 3

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#delete-setup-experience-script

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#delete-setup-experience-script
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('FleetDM.RemovedSetupExperienceScript')]
    param(
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [switch]$Force
    )

    if ($Force -and -not $WhatIfPreference) {
        $ConfirmPreference = 'None'
    }

    $queryParams = @{}
    $scope = 'unassigned hosts'
    if ($PSBoundParameters.ContainsKey('FleetId')) {
        $queryParams['fleet_id'] = $FleetId
        $scope = "fleet $FleetId"
    }

    if ($PSCmdlet.ShouldProcess("setup script for $scope", 'Remove')) {
        $null = Invoke-FleetDMRequest -Endpoint 'setup_experience/script' -Method DELETE -QueryParameters $queryParams
        [PSCustomObject]@{
            PSTypeName = 'FleetDM.RemovedSetupExperienceScript'
            FleetId = if ($PSBoundParameters.ContainsKey('FleetId')) { $FleetId } else { $null }
            Status = 'Removed'
        }
    }
}
