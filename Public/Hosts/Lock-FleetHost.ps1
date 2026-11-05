function Lock-FleetHost {
    <#
    .SYNOPSIS
        Locks a host.

    .DESCRIPTION
        Sends POST /api/v1/fleet/hosts/{id}/lock.
        macOS, iOS, and iPadOS require MDM. Windows and Linux require scripts.

    .PARAMETER Id
        Host ID.

    .PARAMETER ViewPin
        For macOS, return the unlock PIN.

    .EXAMPLE
        Lock-FleetHost -Id 123 -ViewPin

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#lock-host

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#lock-host
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,

        [switch]$ViewPin
    )

    process {
        if ($PSCmdlet.ShouldProcess("host $Id", 'Lock')) {
            $query = @{}
            if ($ViewPin) { $query['view_pin'] = 'true' }
            $params = @{
                Endpoint = "hosts/$Id/lock"
                Method = 'POST'
            }
            if ($query.Count -gt 0) { $params['QueryParameters'] = $query }
            $result = Invoke-FleetDMRequest @params
            if ($result -and $result.PSObject) {
                $result.PSObject.TypeNames.Insert(0, 'FleetDM.HostLock')
            }
            return $result
        }
    }
}
