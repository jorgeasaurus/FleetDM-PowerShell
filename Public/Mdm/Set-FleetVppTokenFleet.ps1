function Set-FleetVppTokenFleet {
    <#
    .SYNOPSIS
        Sets which fleets can use a VPP token's App Store apps.

    .DESCRIPTION
        Sends PATCH /api/v1/fleet/vpp_tokens/{id}/fleets.
        -FleetId sends those fleet IDs. -AllFleets sends an empty list, which Fleet reads as every fleet,
        including fleets created later. -NoFleet sends null, which removes the token from every fleet.
        App Store apps added from this token are deleted from any fleet the token is removed from.

    .PARAMETER Id
        VPP token ID. Binds from the id property of Get-FleetVppToken or Add-FleetVppToken output.

    .PARAMETER FleetId
        Fleet IDs that can use the token. Use 0 for "Unassigned".

    .PARAMETER AllFleets
        Assigns the token to every fleet.

    .PARAMETER NoFleet
        Removes the token from every fleet.

    .EXAMPLE
        Set-FleetVppTokenFleet -Id 1 -FleetId 1, 2

    .EXAMPLE
        Set-FleetVppTokenFleet -Id 1 -AllFleets

    .NOTES
        This cmdlet requires Fleet Premium and a global admin role. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#update-volume-purchasing-program-vpp-tokens-fleets

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-volume-purchasing-program-vpp-tokens-fleets
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'FleetId')]
    [OutputType('FleetDM.VppToken')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,

        [Parameter(Mandatory, ParameterSetName = 'FleetId')]
        [ValidateRange(0, [int]::MaxValue)]
        [int[]]$FleetId,

        [Parameter(Mandatory, ParameterSetName = 'AllFleets')]
        [switch]$AllFleets,

        [Parameter(Mandatory, ParameterSetName = 'NoFleet')]
        [switch]$NoFleet
    )

    process {
        if ($AllFleets) {
            $fleets = @()
            $description = 'Assign to all fleets'
        }
        elseif ($NoFleet) {
            $fleets = $null
            $description = 'Remove from every fleet. Its App Store apps are deleted from those fleets'
        }
        else {
            $fleets = @($FleetId | Select-Object -Unique)
            $description = "Assign to fleets $($fleets -join ', '). App Store apps from this token are deleted from other fleets"
        }

        if ($PSCmdlet.ShouldProcess("VPP token $Id", $description)) {
            $response = Invoke-FleetDMRequest -Endpoint "vpp_tokens/$Id/fleets" -Method PATCH -Body @{ fleets = $fleets }
            return (Get-FleetResponseRecord -Response $response -Name 'token' -TypeName 'FleetDM.VppToken')
        }
    }
}
