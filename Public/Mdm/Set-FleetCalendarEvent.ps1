function Set-FleetCalendarEvent {
    <#
    .SYNOPSIS
        Enables calendar maintenance windows for a fleet.

    .DESCRIPTION
        Sends PATCH /api/v1/fleet/fleets/{id} with integrations.google_calendar.
        Calendar maintenance windows are a Fleet Premium feature. The Google Calendar integration must already exist in the global configuration.

    .PARAMETER FleetId
        Fleet ID. This setting is not applied through fleet id 0.

    .PARAMETER Enable
        Whether calendar events are enabled.

    .PARAMETER WebhookUrl
        URL Fleet calls during the calendar event so automation can run.

    .EXAMPLE
        Set-FleetCalendarEvent -FleetId 1 -Enable $true -WebhookUrl "https://automations.example/fleet"

    .NOTES
        This cmdlet requires Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#update-fleet
        https://fleetdm.com/pricing

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-fleet
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory)]
        [bool]$Enable,

        [ValidateNotNullOrEmpty()]
        [string]$WebhookUrl
    )

    process {
        $calendar = @{ enable_calendar_events = [bool]$Enable }
        if ($PSBoundParameters.ContainsKey('WebhookUrl')) {
            $calendar['webhook_url'] = $WebhookUrl
        }

        if ($PSCmdlet.ShouldProcess("fleet $FleetId", "Set calendar events enabled=$Enable")) {
            $body = @{
                integrations = @{
                    google_calendar = @($calendar)
                }
            }
            $response = Invoke-FleetDMRequest -Endpoint "fleets/$FleetId" -Method PATCH -Body $body
            $fleet = $response.team
            if (-not $fleet) { $fleet = $response.fleet }
            if ($fleet -and $fleet.PSObject) {
                $fleet.PSObject.TypeNames.Insert(0, 'FleetDM.Team')
            }
            return $fleet
        }
    }
}
