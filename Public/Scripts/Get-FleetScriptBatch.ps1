function Get-FleetScriptBatch {
    <#
    .SYNOPSIS
        Lists batch script runs, gets one, or lists its hosts.

    .DESCRIPTION
        Sends GET /api/v1/fleet/scripts/batch, GET /api/v1/fleet/scripts/batch/{batch_execution_id},
        or GET /api/v1/fleet/scripts/batch/{batch_execution_id}/host_results.
        Fleet 4.96 requires fleet_id on the list route. FleetId defaults to 0, which is "Unassigned".

    .PARAMETER FleetId
        Fleet whose batch runs are listed. Use 0 for "Unassigned". Values other than 0 require Fleet Premium.

    .PARAMETER Status
        Lists batch runs with this status: started, scheduled, or finished.

    .PARAMETER BatchExecutionId
        Batch execution ID from Start-FleetScriptBatch. Binds from the batch_execution_id property.

    .PARAMETER HostResults
        Lists the hosts targeted by the batch instead of the batch summary. Requires HostStatus.

    .PARAMETER HostStatus
        Host script status to list: ran, pending, errored, incompatible, or canceled. Fleet requires one.

    .EXAMPLE
        Get-FleetScriptBatch -FleetId 2 -Status finished

    .EXAMPLE
        Start-FleetScriptBatch -ScriptId 4 -HostId 10, 11 -Confirm:$false | Get-FleetScriptBatch

    .EXAMPLE
        Get-FleetScriptBatch -BatchExecutionId 'e797d6c6-3aae-11ee-be56-0242ac120002' -HostResults -HostStatus errored

    .NOTES
        FleetId other than 0 requires Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#list-batch-scripts

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-batch-scripts
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('FleetDM.ScriptBatch', 'FleetDM.ScriptBatchHost')]
    param(
        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId = 0,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('started', 'scheduled', 'finished')]
        [string]$Status,

        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'HostResults', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('batch_execution_id')]
        [ValidateNotNullOrEmpty()]
        [string]$BatchExecutionId,

        [Parameter(Mandatory, ParameterSetName = 'HostResults')]
        [switch]$HostResults,

        [Parameter(Mandatory, ParameterSetName = 'HostResults')]
        [ValidateSet('ran', 'pending', 'errored', 'incompatible', 'canceled')]
        [string]$HostStatus
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'List') {
            $query = @{ fleet_id = $FleetId; per_page = 100 }
            if ($Status) { $query['status'] = $Status }
            $response = Invoke-FleetDMRequest -Endpoint 'scripts/batch' -QueryParameters $query -FollowPagination
            return (Get-FleetListResult -Response $response -Name 'batch_executions' -TypeName 'FleetDM.ScriptBatch')
        }

        $endpoint = "scripts/batch/$([uri]::EscapeDataString($BatchExecutionId))"
        if ($HostResults) {
            $response = Invoke-FleetDMRequest -Endpoint "$endpoint/host_results" -QueryParameters @{ status = $HostStatus; per_page = 100 } -FollowPagination
            return (Get-FleetListResult -Response $response -Name 'hosts' -TypeName 'FleetDM.ScriptBatchHost')
        }

        $response = Invoke-FleetDMRequest -Endpoint $endpoint -Method GET
        $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.ScriptBatch'
        return $response
    }
}
