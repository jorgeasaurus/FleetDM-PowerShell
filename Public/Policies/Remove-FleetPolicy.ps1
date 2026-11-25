function Remove-FleetPolicy {
    <#
    .SYNOPSIS
        Deletes global or fleet policies.

    .DESCRIPTION
        Sends POST /api/v1/fleet/global/policies/delete, or
        POST /api/v1/fleet/fleets/{fleet_id}/policies/delete when FleetId is set.
        Fleet deletes policies with a POST that carries the ids. There is no DELETE route.

        Ids are collected from the pipeline and sent in one request per fleet.
        A piped global policy has a null fleet_id and is deleted from the global list.
        Deleted holds Fleet's deleted value. Fleet 4.96 returns the deleted ids; the API reference shows a count.

    .PARAMETER Id
        Policy IDs to delete.

    .PARAMETER FleetId
        Fleet Premium. Fleet that owns the policies. Use 0 for "Unassigned" policies.
        Omit it, or pass $null, for global policies. Binds from the fleet_id or team_id property of piped policies.

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Remove-FleetPolicy -Id 12, 13

        Deletes two global policies in one request.

    .EXAMPLE
        Remove-FleetPolicy -Id 7 -FleetId 2

        Deletes a policy that belongs to fleet 2.

    .EXAMPLE
        Get-FleetPolicy -FleetId 2 -Name "Legacy" | Remove-FleetPolicy -Force

        Deletes every fleet 2 policy whose name contains Legacy.

    .NOTES
        Deleting fleet policies requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#delete-policies
        https://fleetdm.com/docs/rest-api/rest-api#delete-fleet-level-policies

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#delete-policies
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('FleetDM.RemovedPolicy')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$Id,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('fleet_id', 'team_id')]
        [AllowNull()]
        [Nullable[int]]$FleetId,

        [switch]$Force
    )

    begin {
        $batches = [ordered]@{}
    }

    process {
        # Validation attributes reject $null, which means a global policy here.
        if ($null -ne $FleetId -and $FleetId -lt 0) {
            throw "FleetId must be 0 or greater. Use `$null for global policies."
        }

        $key = if ($null -eq $FleetId) { 'global' } else { [string]$FleetId }
        if (-not $batches.Contains($key)) {
            $batches[$key] = New-Object System.Collections.Generic.List[int]
        }
        foreach ($policyId in $Id) {
            if (-not $batches[$key].Contains($policyId)) {
                $batches[$key].Add($policyId)
            }
        }
    }

    end {
        if ($Force -and -not $WhatIfPreference) {
            $ConfirmPreference = 'None'
        }

        foreach ($key in @($batches.Keys)) {
            $ids = $batches[$key].ToArray()
            if ($key -eq 'global') {
                $endpoint = 'global/policies/delete'
                $target = "global policies $($ids -join ', ')"
                $fleet = $null
            }
            else {
                $endpoint = "fleets/$key/policies/delete"
                $target = "policies $($ids -join ', ') on fleet $key"
                $fleet = [int]$key
            }

            if ($PSCmdlet.ShouldProcess($target, 'Remove')) {
                $response = Invoke-FleetDMRequest -Endpoint $endpoint -Method POST -Body @{ ids = @($ids) }
                [PSCustomObject]@{
                    PSTypeName = 'FleetDM.RemovedPolicy'
                    Id = $ids
                    FleetId = $fleet
                    Deleted = $response.deleted
                    Status = 'Removed'
                }
            }
        }
    }
}
