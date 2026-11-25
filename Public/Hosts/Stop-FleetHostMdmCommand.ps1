function Stop-FleetHostMdmCommand {
    <#
    .SYNOPSIS
        Cancels a pending lock, wipe, clear passcode, or lost mode command on an Apple host.

    .DESCRIPTION
        Sends DELETE /api/v1/fleet/hosts/{id}/commands/{command_uuid}.
        Fleet cancels only DeviceLock, EraseDevice, ClearPasscode, and EnableLostMode commands
        that have not been delivered.

    .PARAMETER HostId
        Host ID.

    .PARAMETER CommandUuid
        Command UUID. Binds from the command_uuid property of Get-FleetMdmCommand or Clear-FleetHostPasscode output.

    .EXAMPLE
        Stop-FleetHostMdmCommand -HostId 12 -CommandUuid '81e10a70-730b-4c45-9b40-b14373e04757'

    .EXAMPLE
        Clear-FleetHostPasscode -HostId 12 -Force | Stop-FleetHostMdmCommand -HostId 12 -Confirm:$false

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        Fleet returns 400 when the command was already delivered or is not a cancelable type.
        https://fleetdm.com/docs/rest-api/rest-api#cancel-hosts-pending-mdm-command

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#cancel-hosts-pending-mdm-command
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.CanceledMdmCommand')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$HostId,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('command_uuid')]
        [ValidatePattern('^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$')]
        [string]$CommandUuid
    )

    process {
        if ($PSCmdlet.ShouldProcess("host $HostId", "Cancel MDM command $CommandUuid")) {
            $null = Invoke-FleetDMRequest -Endpoint "hosts/$HostId/commands/$CommandUuid" -Method DELETE
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.CanceledMdmCommand'
                HostId = $HostId
                CommandUuid = $CommandUuid
                Status = 'Canceled'
            }
        }
    }
}
