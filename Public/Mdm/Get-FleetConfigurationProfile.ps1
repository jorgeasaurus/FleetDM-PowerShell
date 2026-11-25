function Get-FleetConfigurationProfile {
    <#
    .SYNOPSIS
        Lists configuration profiles, gets one, or downloads one.

    .DESCRIPTION
        Sends GET /api/v1/fleet/configuration_profiles or
        GET /api/v1/fleet/configuration_profiles/{profile_uuid}.
        -OutFile adds alt=media and saves the profile file.
        Without FleetId the list holds only "Unassigned" profiles.

    .PARAMETER FleetId
        Fleet Premium. Lists the profiles on this fleet.

    .PARAMETER ProfileUuid
        Profile UUID. Binds from the profile_uuid property.

    .PARAMETER OutFile
        Saves the profile file to this path and returns the file.

    .EXAMPLE
        Get-FleetConfigurationProfile -FleetId 2

    .EXAMPLE
        Get-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24' -OutFile ./passcode.mobileconfig

    .NOTES
        Requires MDM to be turned on in Fleet. Otherwise Fleet responds with HTTP 400.
        FleetId requires Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#list-configuration-profiles

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-configuration-profiles
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('FleetDM.ConfigurationProfile', [System.IO.FileInfo])]
    param(
        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('profile_uuid')]
        [ValidatePattern('^[A-Za-z]?[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$')]
        [string]$ProfileUuid,

        [Parameter(ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$OutFile
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'List') {
            $query = @{ per_page = 100 }
            if ($PSBoundParameters.ContainsKey('FleetId')) { $query['fleet_id'] = $FleetId }
            $response = Invoke-FleetDMRequest -Endpoint 'configuration_profiles' -QueryParameters $query -FollowPagination
            return (Get-FleetListResult -Response $response -Name 'profiles' -TypeName 'FleetDM.ConfigurationProfile')
        }

        $endpoint = "configuration_profiles/$ProfileUuid"
        if ($OutFile) {
            return (Save-FleetDownload -Endpoint $endpoint -QueryParameters @{ alt = 'media' } -OutFile $OutFile)
        }

        $response = Invoke-FleetDMRequest -Endpoint $endpoint -Method GET
        $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.ConfigurationProfile'
        return $response
    }
}
