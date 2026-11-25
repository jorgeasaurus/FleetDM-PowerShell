function Start-FleetScriptBatch {
    <#
    .SYNOPSIS
        Runs a saved script on many hosts.

    .DESCRIPTION
        Sends POST /api/v1/fleet/scripts/run/batch with script_id and either host_ids or filters.
        Host IDs piped in are collected and sent in one batch.
        A filter must name at least one of query, status, label_id, or fleet_id. An empty filter would match every host, so it is rejected.
        Piping no hosts throws and sends nothing. An empty host_ids list is not a way to target no one.

    .PARAMETER ScriptId
        Saved script ID.

    .PARAMETER HostId
        Host IDs to target. Binds from the id property of piped hosts.

    .PARAMETER Filter
        Host filter with any of query, status, label_id, and fleet_id.
        Fleet targets the hosts that match when the batch is created.

    .PARAMETER NotBefore
        Schedules the batch. Sent to Fleet as UTC.

    .EXAMPLE
        Start-FleetScriptBatch -ScriptId 4 -HostId 10, 11, 12

    .EXAMPLE
        Start-FleetScriptBatch -ScriptId 4 -Filter @{ label_id = 7; status = 'online' } -NotBefore (Get-Date).AddHours(2)

    .EXAMPLE
        Get-FleetHost -Status online | Where-Object platform -eq 'darwin' | Start-FleetScriptBatch -ScriptId 4 -Confirm:$false

    .NOTES
        Hosts without fleetd and scripts enabled count as errored or incompatible in the batch.
        https://fleetdm.com/docs/rest-api/rest-api#batch-run-script

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#batch-run-script
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'HostId')]
    [OutputType('FleetDM.ScriptBatch')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$ScriptId,

        [Parameter(Mandatory, ParameterSetName = 'HostId', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$HostId,

        [Parameter(Mandatory, ParameterSetName = 'Filter')]
        [hashtable]$Filter,

        [datetime]$NotBefore
    )

    begin {
        $hostIds = New-Object System.Collections.Generic.List[int]
    }

    process {
        foreach ($id in @($HostId)) {
            if ($id -and -not $hostIds.Contains($id)) {
                $hostIds.Add($id)
            }
        }
    }

    end {
        $body = @{ script_id = $ScriptId }
        if ($PSCmdlet.ParameterSetName -eq 'Filter') {
            $body['filters'] = ConvertTo-FleetFilterBody -Filter $Filter -AllowedKey 'query', 'status', 'label_id', 'fleet_id'
            $target = "hosts matching $(Get-FleetRedactedLogText -Text $body.filters)"
        }
        else {
            if ($hostIds.Count -eq 0) {
                throw 'No host IDs were given. Piping no hosts would send host_ids as an empty list.'
            }
            $body['host_ids'] = @($hostIds.ToArray())
            $target = "$($hostIds.Count) host(s): $($hostIds -join ', ')"
        }

        if ($PSBoundParameters.ContainsKey('NotBefore')) {
            $body['not_before'] = $NotBefore.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ', [System.Globalization.CultureInfo]::InvariantCulture)
        }

        if ($PSCmdlet.ShouldProcess($target, "Run script $ScriptId")) {
            $response = Invoke-FleetDMRequest -Endpoint 'scripts/run/batch' -Method POST -Body $body
            $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.ScriptBatch'
            return $response
        }
    }
}
