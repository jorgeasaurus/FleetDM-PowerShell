function Set-FleetTeam {
    <#
    .SYNOPSIS
        Updates a Fleet Premium fleet.

    .DESCRIPTION
        Sends PATCH /api/v1/fleet/fleets/{id}. Only supplied properties are included in the body.

    .PARAMETER Id
        Fleet ID.

    .PARAMETER Name
        New fleet name.

    .PARAMETER HostId
        Host IDs that should belong to the fleet.

    .EXAMPLE
        Set-FleetTeam -Id 1 -Name "Engineering"

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#update-fleet

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-fleet
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Id,

        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [int[]]$HostId
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Name')) { $body['name'] = $Name }
        if ($PSBoundParameters.ContainsKey('HostId')) { $body['host_ids'] = @($HostId) }

        if ($body.Count -eq 0) {
            Write-Warning "No updates specified for fleet ID $Id"
            return
        }

        if ($PSCmdlet.ShouldProcess("fleet $Id", 'Update')) {
            $response = Invoke-FleetDMRequest -Endpoint "fleets/$Id" -Method PATCH -Body $body
            $fleet = $response.team
            if (-not $fleet) { $fleet = $response.fleet }
            if ($fleet -and $fleet.PSObject) {
                $fleet.PSObject.TypeNames.Insert(0, 'FleetDM.Team')
            }
            return $fleet
        }
    }
}
