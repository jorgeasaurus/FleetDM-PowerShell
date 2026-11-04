function Install-FleetSoftware {
    <#
    .SYNOPSIS
        Installs a software title on a host.

    .DESCRIPTION
        Sends POST /api/v1/fleet/hosts/{id}/software/{software_title_id}/install.
        The software title must already have a package or app store app.

    .PARAMETER HostId
        Target host ID.

    .PARAMETER SoftwareTitleId
        Software title ID to install.

    .EXAMPLE
        Install-FleetSoftware -HostId 123 -SoftwareTitleId 3435

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#install-software

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#install-software
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$HostId,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$SoftwareTitleId
    )

    process {
        $target = "software title $SoftwareTitleId on host $HostId"
        if ($PSCmdlet.ShouldProcess($target, 'Install')) {
            $response = Invoke-FleetDMRequest -Endpoint "hosts/$HostId/software/$SoftwareTitleId/install" -Method POST
            if ($response) {
                if ($response.PSObject) {
                    $response.PSObject.TypeNames.Insert(0, 'FleetDM.SoftwareInstall')
                }
                return $response
            }

            [PSCustomObject]@{
                PSTypeName = 'FleetDM.SoftwareInstall'
                HostId = $HostId
                SoftwareTitleId = $SoftwareTitleId
                Status = 'accepted'
            }
        }
    }
}
