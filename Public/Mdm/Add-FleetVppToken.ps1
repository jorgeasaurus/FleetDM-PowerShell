function Add-FleetVppToken {
    <#
    .SYNOPSIS
        Uploads a VPP content token from Apple Business.

    .DESCRIPTION
        Sends POST /api/v1/fleet/vpp_tokens as multipart/form-data with the .vpptoken file in the token field.
        A new token is not assigned to any fleet. Assign it with Set-FleetVppTokenFleet.
        The verbose log shows the field name and byte count, not the token.

    .PARAMETER Path
        Local .vpptoken file downloaded from Apple Business.

    .EXAMPLE
        Add-FleetVppToken -Path ./sToken_for_Acme.vpptoken | Set-FleetVppTokenFleet -FleetId 1, 2

    .NOTES
        This cmdlet requires Fleet Premium and a global admin role. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#add-volume-purchasing-program-vpp-token

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#add-volume-purchasing-program-vpp-token
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.VppToken')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    $file = Get-FleetUploadFile -Path $Path
    if ($PSCmdlet.ShouldProcess("VPP token '$($file.FileName)'", 'Upload')) {
        $response = Invoke-FleetDMRequest -Endpoint 'vpp_tokens' -Method POST -Form @{ token = $file }
        return (Get-FleetResponseRecord -Response $response -Name 'token' -TypeName 'FleetDM.VppToken')
    }
}
