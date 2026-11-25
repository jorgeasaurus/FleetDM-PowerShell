function Get-FleetScriptResult {
    <#
    .SYNOPSIS
        Gets the result of a script run.

    .DESCRIPTION
        Sends GET /api/v1/fleet/scripts/results/{execution_id}.
        exit_code is null until the host reports back. -Wait polls until
        exit_code is set and throws when TimeoutSeconds passes first.

    .PARAMETER ExecutionId
        Execution ID returned by Invoke-FleetScript. Binds from the execution_id property.

    .PARAMETER Wait
        Polls until the host reports an exit code.

    .PARAMETER TimeoutSeconds
        How long -Wait polls before it throws. The default is 300.

    .PARAMETER PollIntervalSeconds
        Seconds between polls with -Wait. The default is 5.

    .EXAMPLE
        Get-FleetScriptResult -ExecutionId 'e797d6c6-3aae-11ee-be56-0242ac120002'

    .EXAMPLE
        Invoke-FleetScript -HostId 10 -ScriptId 4 -Confirm:$false | Get-FleetScriptResult -Wait -TimeoutSeconds 120

    .NOTES
        A script runs only on a host with fleetd and scripts enabled. Otherwise Invoke-FleetScript returns HTTP 422.
        https://fleetdm.com/docs/rest-api/rest-api#get-script-result

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#get-script-result
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.ScriptResult')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('execution_id')]
        [ValidateNotNullOrEmpty()]
        [string]$ExecutionId,

        [switch]$Wait,

        [ValidateRange(0, 86400)]
        [int]$TimeoutSeconds = 300,

        [ValidateRange(1, 3600)]
        [int]$PollIntervalSeconds = 5
    )

    process {
        $endpoint = "scripts/results/$([uri]::EscapeDataString($ExecutionId))"
        $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)

        while ($true) {
            $result = Invoke-FleetDMRequest -Endpoint $endpoint -Method GET
            if (-not $Wait -or $null -ne $result.exit_code) {
                break
            }
            if ([DateTime]::UtcNow -ge $deadline) {
                throw "Timed out after $TimeoutSeconds seconds waiting for script execution $ExecutionId. The host has not reported an exit code."
            }
            Write-Verbose "Script execution $ExecutionId is pending. Polling again in $PollIntervalSeconds seconds."
            Start-Sleep -Seconds $PollIntervalSeconds
        }

        $null = Add-FleetTypeName -InputObject $result -TypeName 'FleetDM.ScriptResult'
        return $result
    }
}
