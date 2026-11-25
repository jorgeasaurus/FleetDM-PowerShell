function Stop-FleetScriptBatch {
    <#
    .SYNOPSIS
        Cancels a batch script run.

    .DESCRIPTION
        Sends POST /api/v1/fleet/scripts/batch/{batch_execution_id}/cancel.
        Hosts that already ran the script are not affected.

    .PARAMETER BatchExecutionId
        Batch execution ID. Binds from the batch_execution_id property.

    .EXAMPLE
        Stop-FleetScriptBatch -BatchExecutionId 'e797d6c6-3aae-11ee-be56-0242ac120002'

    .EXAMPLE
        Get-FleetScriptBatch -Status scheduled | Stop-FleetScriptBatch -Confirm:$false

    .NOTES
        https://fleetdm.com/docs/rest-api/rest-api#cancel-batch-script

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#cancel-batch-script
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.CanceledScriptBatch')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('batch_execution_id')]
        [ValidateNotNullOrEmpty()]
        [string]$BatchExecutionId
    )

    process {
        if ($PSCmdlet.ShouldProcess("batch script $BatchExecutionId", 'Cancel')) {
            $null = Invoke-FleetDMRequest -Endpoint "scripts/batch/$([uri]::EscapeDataString($BatchExecutionId))/cancel" -Method POST
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.CanceledScriptBatch'
                BatchExecutionId = $BatchExecutionId
                Status = 'Canceled'
            }
        }
    }
}
