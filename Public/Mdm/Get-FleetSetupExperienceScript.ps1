function Get-FleetSetupExperienceScript {
    <#
    .SYNOPSIS
        Gets the script that runs during macOS setup, or its contents.

    .DESCRIPTION
        Sends GET /api/v1/fleet/setup_experience/script. -Contents adds alt=media and returns the script text decoded as UTF-8.
        Fleet answers 404 when the fleet has no setup script.

    .PARAMETER FleetId
        Fleet whose script is read. Omit it for "Unassigned".

    .PARAMETER Contents
        Returns the script text instead of the metadata.

    .EXAMPLE
        Get-FleetSetupExperienceScript -FleetId 3

    .EXAMPLE
        Get-FleetSetupExperienceScript -FleetId 3 -Contents

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#get-or-download-setup-experience-script

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#get-or-download-setup-experience-script
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.SetupExperienceScript', [string])]
    param(
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [switch]$Contents
    )

    $queryParams = @{}
    if ($PSBoundParameters.ContainsKey('FleetId')) { $queryParams['fleet_id'] = $FleetId }

    if ($Contents) {
        $queryParams['alt'] = 'media'
        return (Get-FleetDownloadText -Endpoint 'setup_experience/script' -QueryParameters $queryParams)
    }

    $response = Invoke-FleetDMRequest -Endpoint 'setup_experience/script' -Method GET -QueryParameters $queryParams
    $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.SetupExperienceScript'
    return $response
}
