function Remove-FleetEnrollmentProfile {
    <#
    .SYNOPSIS
        Deletes a fleet's custom automatic enrollment (ADE) profile.

    .DESCRIPTION
        Sends DELETE /api/v1/fleet/enrollment_profiles/automatic. The fleet falls back to Fleet's default profile.

    .PARAMETER FleetId
        Fleet whose profile is deleted. Omit it for "Unassigned".

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Remove-FleetEnrollmentProfile -FleetId 2

    .NOTES
        This cmdlet requires Fleet Premium and Apple MDM. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#delete-custom-mdm-setup-enrollment-profile

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#delete-custom-mdm-setup-enrollment-profile
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('FleetDM.RemovedEnrollmentProfile')]
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

    if ($PSCmdlet.ShouldProcess("custom enrollment profile for $scope", 'Remove')) {
        $null = Invoke-FleetDMRequest -Endpoint 'enrollment_profiles/automatic' -Method DELETE -QueryParameters $queryParams
        [PSCustomObject]@{
            PSTypeName = 'FleetDM.RemovedEnrollmentProfile'
            FleetId = if ($PSBoundParameters.ContainsKey('FleetId')) { $FleetId } else { $null }
            Status = 'Removed'
        }
    }
}
