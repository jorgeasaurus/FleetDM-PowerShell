function Get-FleetSoftwareInstall {
    <#
    .SYNOPSIS
        Gets the result of a software package install.

    .DESCRIPTION
        Sends GET /api/v1/fleet/software/install/{install_uuid}/results.
        Apple App Store install results are retrieved from MDM command endpoints instead.

    .PARAMETER InstallUuid
        Install UUID returned when the install was queued.

    .EXAMPLE
        Get-FleetSoftwareInstall -InstallUuid "b15ce221-e22e-4c6a-afe7-5b3400a017da"

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#get-software-install-result

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#get-software-install-result
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('install_uuid')]
        [ValidateNotNullOrEmpty()]
        [string]$InstallUuid
    )

    process {
        $result = Invoke-FleetDMRequest -Endpoint "software/install/$InstallUuid/results" -Method GET
        if ($result -and $result.PSObject) {
            $result.PSObject.TypeNames.Insert(0, 'FleetDM.SoftwareInstallResult')
        }
        return $result
    }
}
