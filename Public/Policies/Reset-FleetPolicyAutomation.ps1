function Reset-FleetPolicyAutomation {
    <#
    .SYNOPSIS
        Resets failing-policy automation state.

    .DESCRIPTION
        Sends POST /api/v1/fleet/automations/reset with policy_ids only.
        Hosts that are still failing are treated as newly failing on the next run.
        Fleet's fleet_ids field adds every policy on those fleets to the reset, so this cmdlet does not send it.
        When FleetId is set, each id is checked against that fleet's policies and only the matching policy_ids are sent.

    .PARAMETER PolicyId
        Policy IDs to reset.

    .PARAMETER FleetId
        Fleet Premium. Policy IDs must belong to one of these fleets. The request still sends only policy_ids.

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
        $selectedIds = @($PolicyId)
        if ($PSBoundParameters.ContainsKey('FleetId')) {
            $fleetPolicyIds = New-Object System.Collections.Generic.List[int]
            foreach ($fleet in $FleetId) {
                $listed = Invoke-FleetDMRequest -Endpoint "fleets/$fleet/policies" -QueryParameters @{ per_page = 100 } -FollowPagination
                foreach ($policy in @(Get-FleetListResult -Response $listed -Name 'policies' -TypeName 'FleetDM.Policy')) {
                    if ($null -ne $policy.id) {
                        $fleetPolicyIds.Add([int]$policy.id)
                    }
                }
            }

            $missing = @($PolicyId | Where-Object { -not $fleetPolicyIds.Contains($_) })
            if ($missing.Count -gt 0) {
                throw "Policy IDs $($missing -join ', ') are not on the specified fleets. fleet_ids is not sent, because Fleet would also reset every other policy on those fleets."
            }
        }

        $body = @{ policy_ids = $selectedIds }

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
