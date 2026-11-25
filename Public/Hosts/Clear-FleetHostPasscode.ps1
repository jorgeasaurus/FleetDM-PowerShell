function Clear-FleetHostPasscode {
    <#
    .SYNOPSIS
        Clears the passcode on an iOS or iPadOS host.

    .DESCRIPTION
        Sends POST /api/v1/fleet/hosts/{id}/clear_passcode. Fleet queues a ClearPasscode MDM command
        and returns its command_uuid. Cancel it before delivery with Stop-FleetHostMdmCommand.

    .PARAMETER HostId
        Host ID. Binds from the id property of piped hosts.

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Clear-FleetHostPasscode -HostId 123

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        The host must be ADE-enrolled and have sent its unlock token.
        https://fleetdm.com/docs/rest-api/rest-api#clear-host-passcode

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#clear-host-passcode
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('FleetDM.MdmCommand')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$HostId,

        [switch]$Force
    )

    process {
        if ($Force -and -not $WhatIfPreference) {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ShouldProcess("host $HostId", 'Clear passcode')) {
            $response = Invoke-FleetDMRequest -Endpoint "hosts/$HostId/clear_passcode" -Method POST
            $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.MdmCommand'
            return $response
        }
    }
}
