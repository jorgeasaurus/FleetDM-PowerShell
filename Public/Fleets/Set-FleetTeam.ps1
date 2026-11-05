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
        Host IDs to assign to this fleet. Assignment uses POST /api/v1/fleet/hosts/transfer.

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

        $assignHosts = $PSBoundParameters.ContainsKey('HostId')
        if ($body.Count -eq 0 -and -not $assignHosts) {
            Write-Warning "No updates specified for fleet ID $Id"
            return
        }

        if ($PSCmdlet.ShouldProcess("fleet $Id", 'Update')) {
            $fleet = $null
            if ($body.Count -gt 0) {
                $response = Invoke-FleetDMRequest -Endpoint "fleets/$Id" -Method PATCH -Body $body
                $fleet = Get-FleetRecord -Response $response
            }

            if ($assignHosts) {
                $null = Invoke-FleetDMRequest -Endpoint 'hosts/transfer' -Method POST -Body @{
                    fleet_id = $Id
                    hosts = @($HostId)
                }
            }

            if (-not $fleet) {
                $response = Invoke-FleetDMRequest -Endpoint "fleets/$Id" -Method GET
                $fleet = Get-FleetRecord -Response $response
            }

            return $fleet
        }
    }
}
