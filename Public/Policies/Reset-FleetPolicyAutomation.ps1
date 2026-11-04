function Reset-FleetPolicyAutomation {
    <#
    .SYNOPSIS
        Resets failing-policy automation state.

    .DESCRIPTION
        Sends POST /api/v1/fleet/automations/reset.
        Hosts that are still failing are treated as newly failing on the next run.
        FleetIds limits the reset to those fleets and requires Fleet Premium.

    .PARAMETER PolicyId
        Policy IDs to reset.

    .PARAMETER FleetId
        Fleet Premium. Limits the reset to these fleets.

    .EXAMPLE
        Reset-FleetPolicyAutomation -PolicyId 1, 2, 3

    .EXAMPLE
        Reset-FleetPolicyAutomation -PolicyId 1 -FleetId 4

    .NOTES
        FleetId requires Fleet Premium. The reset endpoint itself is available in Fleet Free for global policies.
        https://fleetdm.com/docs/rest-api/rest-api#reset-policy-automations

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#reset-policy-automations
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$PolicyId,

        [ValidateRange(0, [int]::MaxValue)]
        [int[]]$FleetId
    )

    process {
        $body = @{ policy_ids = @($PolicyId) }
        if ($PSBoundParameters.ContainsKey('FleetId')) {
            $body['fleet_ids'] = @($FleetId)
        }

        $target = "policies $($PolicyId -join ', ')"
        if ($PSCmdlet.ShouldProcess($target, 'Reset policy automations')) {
            $null = Invoke-FleetDMRequest -Endpoint 'automations/reset' -Method POST -Body $body
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.PolicyAutomationReset'
                PolicyId = @($PolicyId)
                FleetId = $(if ($PSBoundParameters.ContainsKey('FleetId')) { @($FleetId) } else { @() })
                Status = 'Reset'
            }
        }
    }
}
