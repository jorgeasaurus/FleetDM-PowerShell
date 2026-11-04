function Unlock-FleetHost {
    <#
    .SYNOPSIS
        Unlocks a host or returns the macOS unlock PIN.

    .DESCRIPTION
        Sends POST /api/v1/fleet/hosts/{id}/unlock.

    .PARAMETER Id
        Host ID.

    .EXAMPLE
        Unlock-FleetHost -Id 8

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#unlock-host

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#unlock-host
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id
    )

    process {
        if ($PSCmdlet.ShouldProcess("host $Id", 'Unlock')) {
            $result = Invoke-FleetDMRequest -Endpoint "hosts/$Id/unlock" -Method POST
            if ($result -and $result.PSObject) {
                $result.PSObject.TypeNames.Insert(0, 'FleetDM.HostUnlock')
            }
            return $result
        }
    }
}
