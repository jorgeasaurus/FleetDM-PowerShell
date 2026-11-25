function Move-FleetHost {
    <#
    .SYNOPSIS
        Moves every host that matches a filter to a fleet.

    .DESCRIPTION
        Sends POST /api/v1/fleet/hosts/transfer/filter with fleet_id and filters.
        The filter must name at least one of query, status, label_id, or fleet_id. An empty filter would match every host, so it is rejected.
        To move hosts by ID, use Set-FleetTeam -HostId.

    .PARAMETER FleetId
        Destination fleet ID. Use 0 for "Unassigned".

    .PARAMETER Filter
        Host filter with any of query, status, label_id, and fleet_id (use 0 for "Unassigned").

    .EXAMPLE
        Move-FleetHost -FleetId 2 -Filter @{ label_id = 7 }

    .EXAMPLE
        Move-FleetHost -FleetId 2 -Filter @{ fleet_id = 0; status = 'online' } -WhatIf

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#update-hosts-fleet-by-filter

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-hosts-fleet-by-filter
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('FleetDM.HostTransfer')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory)]
        [hashtable]$Filter
    )

    $filters = ConvertTo-FleetFilterBody -Filter $Filter -AllowedKey 'query', 'status', 'label_id', 'fleet_id'
    $filterText = Get-FleetRedactedLogText -Text $filters

    if ($PSCmdlet.ShouldProcess("hosts matching $filterText", "Move to fleet $FleetId")) {
        $null = Invoke-FleetDMRequest -Endpoint 'hosts/transfer/filter' -Method POST -Body @{ fleet_id = $FleetId; filters = $filters }
        [PSCustomObject]@{
            PSTypeName = 'FleetDM.HostTransfer'
            FleetId = $FleetId
            Filter = $filters
            Status = 'Transferred'
        }
    }
}
