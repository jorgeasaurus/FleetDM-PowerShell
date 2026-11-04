function Invoke-FleetHostWipe {
    <#
    .SYNOPSIS
        Wipes a Fleet host.

    .DESCRIPTION
        Sends POST /api/v1/fleet/hosts/{id}/wipe. The host is wiped when it next
        comes online.

        macOS, iOS, iPadOS, and Windows hosts must have MDM turned on. Linux hosts
        must have scripts enabled. Android hosts must be enrolled as a fully
        managed device.

        For Windows, -WindowsWipeType selects the remote wipe. Omit it to let Fleet
        apply its server default, which is doWipeProtected.

    .PARAMETER Id
        Host ID.

    .PARAMETER WindowsWipeType
        Windows wipe type. Allowed values are doWipe and doWipeProtected.
        Sent as { "windows": { "wipe_type": "<value>" } }.

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Invoke-FleetHostWipe -Id 123

        Queues a wipe for host 123.

    .EXAMPLE
        Invoke-FleetHostWipe -Id 45 -WindowsWipeType doWipe -Force

        Queues a Windows doWipe without a confirmation prompt.

    .NOTES
        Company-owned (fully managed) Android wipe is available in Fleet Free and Fleet Premium.
        Wiping macOS, Windows, iOS, iPadOS, Linux, or a personal (BYOD) Android host requires Fleet Premium.
        Fleet Free responds with HTTP 402, or HTTP 403 when the body mentions a Premium license.
        Both are reported as a Fleet Premium error.
        https://fleetdm.com/docs/rest-api/rest-api#wipe-host

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#wipe-host
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('HostId')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,

        [ValidateSet('doWipe', 'doWipeProtected')]
        [string]$WindowsWipeType,

        [switch]$Force
    )

    process {
        if ($Force -and -not $WhatIfPreference) {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ShouldProcess("host $Id", 'Wipe')) {
            $params = @{
                Endpoint = "hosts/$Id/wipe"
                Method = 'POST'
            }
            if ($PSBoundParameters.ContainsKey('WindowsWipeType')) {
                $params['Body'] = @{
                    windows = @{
                        wipe_type = $WindowsWipeType
                    }
                }
            }

            $result = Invoke-FleetDMRequest @params
            if ($result -and $result.PSObject) {
                $result.PSObject.TypeNames.Insert(0, 'FleetDM.HostWipe')
            }
            return $result
        }
    }
}
