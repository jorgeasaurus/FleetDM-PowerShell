function Set-FleetPatchDeadline {
    <#
    .SYNOPSIS
        Sets the days and time Fleet patches Fleet-maintained apps on a fleet.

    .DESCRIPTION
        Sends PATCH /api/v1/fleet/software/patch_deadline_settings with fleet_id, days, and time.
        Time is HH:MM in each host's local time. Fleet notifies end users one hour before the deadline.

    .PARAMETER FleetId
        Fleet ID. Use 0 for "Unassigned".

    .PARAMETER Days
        One or more of monday, tuesday, wednesday, thursday, friday, saturday, and sunday.

    .PARAMETER Time
        Deadline in 24-hour HH:MM, for example 11:00.

    .EXAMPLE
        Set-FleetPatchDeadline -FleetId 3 -Days monday, wednesday, friday -Time '11:00'

    .NOTES
        This cmdlet requires Fleet Premium and an admin or maintainer role. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#update-patch-deadline-settings

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-patch-deadline-settings
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.PatchDeadline')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory)]
        [ValidateSet('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday')]
        [string[]]$Days,

        [Parameter(Mandatory)]
        [ValidatePattern('^([01][0-9]|2[0-3]):[0-5][0-9]$')]
        [string]$Time
    )

    $dayList = @($Days | ForEach-Object { $_.ToLowerInvariant() } | Select-Object -Unique)
    if ($PSCmdlet.ShouldProcess("fleet $FleetId", "Set patch deadline to $($dayList -join ', ') at $Time")) {
        $response = Invoke-FleetDMRequest -Endpoint 'software/patch_deadline_settings' -Method PATCH -Body @{
            fleet_id = $FleetId
            days = $dayList
            time = $Time
        }
        return (Get-FleetResponseRecord -Response $response -Name 'patch_deadline_settings' -TypeName 'FleetDM.PatchDeadline')
    }
}
