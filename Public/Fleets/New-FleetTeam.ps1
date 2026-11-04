function New-FleetTeam {
    <#
    .SYNOPSIS
        Creates a Fleet Premium fleet.

    .DESCRIPTION
        Creates a fleet with POST /api/v1/fleet/fleets. Fleet names must differ by more than letter case.

    .PARAMETER Name
        Fleet name.

    .EXAMPLE
        New-FleetTeam -Name "Workstations"

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#create-fleet

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#create-fleet
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    process {
        if ($PSCmdlet.ShouldProcess($Name, 'Create Fleet')) {
            $response = Invoke-FleetDMRequest -Endpoint 'fleets' -Method POST -Body @{ name = $Name }
            $fleet = $response.team
            if (-not $fleet) { $fleet = $response.fleet }
            if ($fleet -and $fleet.PSObject) {
                $fleet.PSObject.TypeNames.Insert(0, 'FleetDM.Team')
            }
            return $fleet
        }
    }
}
