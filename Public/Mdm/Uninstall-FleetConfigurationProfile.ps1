function Uninstall-FleetConfigurationProfile {
    <#
    .SYNOPSIS
        Removes a self-service configuration profile from a host.

    .DESCRIPTION
        Sends POST /api/v1/fleet/hosts/{id}/configuration_profiles/{profile_uuid}/uninstall.
        Fleet queues the removal for the next profile run. The profile stays available for the host to install again.

    .PARAMETER HostId
        Host ID. Binds from the id property of piped hosts.

    .PARAMETER ProfileUuid
        Self-service profile UUID.

    .EXAMPLE
        Uninstall-FleetConfigurationProfile -HostId 233 -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24'

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        Fleet returns 404 when the host has not installed the profile.
        https://fleetdm.com/docs/rest-api/rest-api#uninstall-self-service-configuration-profile

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#uninstall-self-service-configuration-profile
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.ProfileInstall')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$HostId,

        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z]?[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$')]
        [string]$ProfileUuid
    )

    process {
        if ($PSCmdlet.ShouldProcess("host $HostId", "Uninstall profile $ProfileUuid")) {
            $null = Invoke-FleetDMRequest -Endpoint "hosts/$HostId/configuration_profiles/$ProfileUuid/uninstall" -Method POST
            [PSCustomObject]@{ PSTypeName = 'FleetDM.ProfileInstall'; HostId = $HostId; ProfileUuid = $ProfileUuid; Action = 'Uninstall'; Status = 'Queued' }
        }
    }
}
