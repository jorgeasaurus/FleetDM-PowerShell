function Add-FleetTeamUser {
    <#
    .SYNOPSIS
        Adds users to a fleet with a fleet role.

    .DESCRIPTION
        Sends PATCH /api/v1/fleet/fleets/{id}/users with a users list of id and role.
        User IDs piped in are collected and sent in one request. Every user gets the same Role.
        A user who is already on the fleet gets the new role.

    .PARAMETER FleetId
        Fleet ID.

    .PARAMETER UserId
        User IDs to add. Binds from the id property of piped users.

    .PARAMETER Role
        Fleet role: admin, maintainer, observer, observer_plus, or gitops.

    .EXAMPLE
        Add-FleetTeamUser -FleetId 1 -UserId 17, 18 -Role observer

    .NOTES
        This cmdlet requires Fleet Premium and the admin role. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#add-users-to-fleet

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#add-users-to-fleet
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.Team')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$UserId,

        [Parameter(Mandatory)]
        [ValidateSet('admin', 'maintainer', 'observer', 'observer_plus', 'gitops')]
        [string]$Role
    )

    begin {
        $ids = New-Object System.Collections.Generic.List[int]
    }

    process {
        foreach ($id in $UserId) {
            if (-not $ids.Contains($id)) { $ids.Add($id) }
        }
    }

    end {
        $users = @($ids | ForEach-Object { @{ id = $_; role = $Role.ToLowerInvariant() } })
        if ($PSCmdlet.ShouldProcess("fleet $FleetId", "Add users $($ids -join ', ') as $Role")) {
            $response = Invoke-FleetDMRequest -Endpoint "fleets/$FleetId/users" -Method PATCH -Body @{ users = $users }
            return (Get-FleetRecord -Response $response)
        }
    }
}
