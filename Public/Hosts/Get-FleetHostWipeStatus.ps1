function Get-FleetHostWipeStatus {
    <#
    .SYNOPSIS
        Gets a host's lock and wipe status.

    .DESCRIPTION
        Reads GET /api/v1/fleet/hosts/{id} and returns mdm.device_status and
        mdm.pending_action. Fleet documents this as the way to confirm a wipe.

        device_status is unlocked, locked, locking, unlocking, wiped, or wiping.
        pending_action is lock, unlock, wipe, or an empty string when nothing is pending.

    .PARAMETER Id
        Host ID.

    .EXAMPLE
        Get-FleetHostWipeStatus -Id 123

        Shows whether host 123 is wiping, wiped, or has a wipe pending.

    .EXAMPLE
        Invoke-FleetHostWipe -Id 123 -Force
        Get-FleetHostWipeStatus -Id 123

        Queues a wipe and then reads the pending action.

    .NOTES
        The status fields are on the host MDM object.
        https://fleetdm.com/docs/rest-api/rest-api#get-host
        https://fleetdm.com/docs/rest-api/rest-api#wipe-host

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#wipe-host
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('HostId')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id
    )

    process {
        $response = Invoke-FleetDMRequest -Endpoint "hosts/$Id" -Method GET
        $hostRecord = $response.host
        if (-not $hostRecord) {
            $hostRecord = $response
        }
        $mdm = $hostRecord.mdm

        $status = [PSCustomObject]@{
            PSTypeName = 'FleetDM.HostWipeStatus'
            HostId = $Id
            Hostname = $hostRecord.hostname
            DeviceStatus = $mdm.device_status
            PendingAction = $mdm.pending_action
        }
        return $status
    }
}
