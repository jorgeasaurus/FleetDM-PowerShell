function Send-FleetConfigurationProfile {
    <#
    .SYNOPSIS
        Resends a configuration profile to hosts.

    .DESCRIPTION
        With HostId, sends POST /api/v1/fleet/hosts/{id}/configuration_profiles/{profile_uuid}/resend for each host.
        With Filter, sends POST /api/v1/fleet/configuration_profiles/resend/batch with profile_uuid and filters.
        Fleet supports one batch filter, profile_status = 'failed'.

    .PARAMETER ProfileUuid
        Profile UUID.

    .PARAMETER HostId
        Hosts to resend to. Binds from the id property of piped hosts.

    .PARAMETER Filter
        Batch filter. Fleet accepts @{ profile_status = 'failed' }.

    .EXAMPLE
        Send-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24' -HostId 233

    .EXAMPLE
        Send-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24' -Filter @{ profile_status = 'failed' }

    .NOTES
        Requires an MDM-enrolled host. Supports Apple .mobileconfig and Windows .xml profiles.
        https://fleetdm.com/docs/rest-api/rest-api#resend-configuration-profile
        https://fleetdm.com/docs/rest-api/rest-api#batch-resend-configuration-profile

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#resend-configuration-profile
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'HostId')]
    [OutputType('FleetDM.ProfileResend')]
    param(
        [Parameter(Mandatory)]
        [Alias('profile_uuid')]
        [ValidatePattern('^[A-Za-z]?[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$')]
        [string]$ProfileUuid,

        [Parameter(Mandatory, ParameterSetName = 'HostId', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$HostId,

        [Parameter(Mandatory, ParameterSetName = 'Filter')]
        [hashtable]$Filter
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Filter') {
            $filters = ConvertTo-FleetFilterBody -Filter $Filter -AllowedKey 'profile_status'
            if ($PSCmdlet.ShouldProcess("hosts matching $(Get-FleetRedactedLogText -Text $filters)", "Resend profile $ProfileUuid")) {
                $null = Invoke-FleetDMRequest -Endpoint 'configuration_profiles/resend/batch' -Method POST -Body @{
                    profile_uuid = $ProfileUuid
                    filters = $filters
                }
                [PSCustomObject]@{ PSTypeName = 'FleetDM.ProfileResend'; ProfileUuid = $ProfileUuid; HostId = $null; Filter = $filters; Status = 'Queued' }
            }
            return
        }

        foreach ($id in $HostId) {
            if ($PSCmdlet.ShouldProcess("host $id", "Resend profile $ProfileUuid")) {
                $null = Invoke-FleetDMRequest -Endpoint "hosts/$id/configuration_profiles/$ProfileUuid/resend" -Method POST
                [PSCustomObject]@{ PSTypeName = 'FleetDM.ProfileResend'; ProfileUuid = $ProfileUuid; HostId = $id; Filter = $null; Status = 'Queued' }
            }
        }
    }
}
