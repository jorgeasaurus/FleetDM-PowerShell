function Invoke-FleetScript {
    <#
    .SYNOPSIS
        Runs a script on a host.

    .DESCRIPTION
        Sends POST /api/v1/fleet/scripts/run.
        Supply ScriptId, ScriptContents, or ScriptName. ScriptName requires FleetId.
        Running by script ID or inline contents against a host is available in Fleet Free.
        FleetId requires Fleet Premium.

    .PARAMETER HostId
        Target host ID.

    .PARAMETER ScriptId
        Saved script ID.

    .PARAMETER ScriptContents
        Inline script text, up to 10,000 characters.

    .PARAMETER ScriptName
        Saved script name. Requires FleetId.

    .PARAMETER FleetId
        Fleet Premium. Fleet that owns the named script.

    .EXAMPLE
        Invoke-FleetScript -HostId 10 -ScriptId 4

    .EXAMPLE
        Invoke-FleetScript -HostId 10 -ScriptContents "echo hello"

    .NOTES
        FleetId and ScriptName require Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#run-script

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#run-script
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'ById')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$HostId,

        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$ScriptId,

        [Parameter(Mandatory, ParameterSetName = 'ByContents')]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 10000)]
        [string]$ScriptContents,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptName,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId
    )

    process {
        $body = @{ host_id = $HostId }
        switch ($PSCmdlet.ParameterSetName) {
            'ById' { $body['script_id'] = $ScriptId }
            'ByContents' { $body['script_contents'] = $ScriptContents }
            'ByName' {
                $body['script_name'] = $ScriptName
                $body['fleet_id'] = $FleetId
            }
        }

        if ($PSCmdlet.ShouldProcess("host $HostId", 'Run script')) {
            $result = Invoke-FleetDMRequest -Endpoint 'scripts/run' -Method POST -Body $body
            if ($result -and $result.PSObject) {
                $result.PSObject.TypeNames.Insert(0, 'FleetDM.ScriptExecution')
            }
            return $result
        }
    }
}
