function Remove-FleetConfigurationProfile {
    <#
    .SYNOPSIS
        Deletes a configuration profile.

    .DESCRIPTION
        Sends DELETE /api/v1/fleet/configuration_profiles/{profile_uuid}.
        Fleet sends a remove command to Apple hosts. Some Windows settings stay at their last value;
        Fleet's warning text is written to the warning stream.

    .PARAMETER ProfileUuid
        Profile UUID. Binds from the profile_uuid property.

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Remove-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24'

    .EXAMPLE
        Get-FleetConfigurationProfile -FleetId 2 | Where-Object name -like 'Test*' | Remove-FleetConfigurationProfile -Force

    .NOTES
        Requires MDM to be turned on in Fleet.
        https://fleetdm.com/docs/rest-api/rest-api#delete-configuration-profile

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#delete-configuration-profile
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('FleetDM.RemovedConfigurationProfile')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('profile_uuid')]
        [ValidatePattern('^[A-Za-z]?[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$')]
        [string]$ProfileUuid,

        [switch]$Force
    )

    process {
        if ($Force -and -not $WhatIfPreference) {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ShouldProcess("configuration profile $ProfileUuid", 'Remove')) {
            $response = Invoke-FleetDMRequest -Endpoint "configuration_profiles/$ProfileUuid" -Method DELETE
            if ($response -and $response.warning) {
                Write-Warning $response.warning
            }
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.RemovedConfigurationProfile'
                ProfileUuid = $ProfileUuid
                Status = 'Removed'
            }
        }
    }
}
