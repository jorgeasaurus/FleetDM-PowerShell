function Install-FleetConfigurationProfile {
    <#
    .SYNOPSIS
        Installs a self-service configuration profile on a host.

    .DESCRIPTION
        Sends POST /api/v1/fleet/hosts/{id}/configuration_profiles/{profile_uuid}/install.
        Fleet queues the install for the next profile run. Only .mobileconfig profiles with self_service set can be installed this way.

    .PARAMETER HostId
        Host ID. Binds from the id property of piped hosts.

    .PARAMETER ProfileUuid
        Self-service profile UUID.

    .EXAMPLE
        Install-FleetConfigurationProfile -HostId 233 -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24'

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        Fleet returns 400 when the profile is not self-service and 409 when it is already installed.
        https://fleetdm.com/docs/rest-api/rest-api#install-self-service-configuration-profile

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#install-self-service-configuration-profile
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
        if ($PSCmdlet.ShouldProcess("host $HostId", "Install profile $ProfileUuid")) {
            $null = Invoke-FleetDMRequest -Endpoint "hosts/$HostId/configuration_profiles/$ProfileUuid/install" -Method POST
            [PSCustomObject]@{ PSTypeName = 'FleetDM.ProfileInstall'; HostId = $HostId; ProfileUuid = $ProfileUuid; Action = 'Install'; Status = 'Queued' }
        }
    }
}
