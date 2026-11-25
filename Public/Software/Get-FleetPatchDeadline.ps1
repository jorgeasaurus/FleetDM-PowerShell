function Get-FleetPatchDeadline {
    <#
    .SYNOPSIS
        Gets a fleet's patch deadline days and time.

    .DESCRIPTION
        Sends GET /api/v1/fleet/software/patch_deadline_settings?fleet_id={fleet_id}.
        Fleet-maintained apps whose patch policy sets patch_deadline are patched at these deadlines.
        Fleet returns Tuesday at 17:00 when the settings were never changed.

    .PARAMETER FleetId
        Fleet ID. Use 0 for "Unassigned". Binds from the id property of piped fleets.

    .EXAMPLE
        Get-FleetPatchDeadline -FleetId 3

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#get-patch-deadline-settings

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#get-patch-deadline-settings
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.PatchDeadline')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId
    )

    process {
        $response = Invoke-FleetDMRequest -Endpoint 'software/patch_deadline_settings' -Method GET -QueryParameters @{ fleet_id = $FleetId }
        return (Get-FleetResponseRecord -Response $response -Name 'patch_deadline_settings' -TypeName 'FleetDM.PatchDeadline')
    }
}
