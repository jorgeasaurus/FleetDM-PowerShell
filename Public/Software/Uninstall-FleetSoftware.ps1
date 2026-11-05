function Uninstall-FleetSoftware {
    <#
    .SYNOPSIS
        Uninstalls a software title from a host.

    .DESCRIPTION
        Sends POST /api/v1/fleet/hosts/{id}/software/{software_title_id}/uninstall.

    .PARAMETER HostId
        Target host ID.

    .PARAMETER SoftwareTitleId
        Software title ID to uninstall.

    .EXAMPLE
        Uninstall-FleetSoftware -HostId 123 -SoftwareTitleId 3435

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#uninstall-software

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#uninstall-software
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
        if ($PSCmdlet.ShouldProcess($target, 'Uninstall')) {
            $response = Invoke-FleetDMRequest -Endpoint "hosts/$HostId/software/$SoftwareTitleId/uninstall" -Method POST
            if ($response -and $response.PSObject) {
                $response.PSObject.TypeNames.Insert(0, 'FleetDM.SoftwareUninstall')
            }
            return $response
        }
    }
}
