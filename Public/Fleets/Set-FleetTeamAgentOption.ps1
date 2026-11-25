function Set-FleetTeamAgentOption {
    <#
    .SYNOPSIS
        Replaces a fleet's agent options.

    .DESCRIPTION
        Sends POST /api/v1/fleet/fleets/{id}/agent_options with the options as the body.
        The body replaces the fleet's agent options. Read the current value from Get-FleetTeam's agent_options.
        AgentOptions can be a hashtable, an object such as (Get-FleetTeam -Id 1).agent_options, or a JSON string.
        -SkipValidation sends force=true. -DryRun sends dry_run=true and applies nothing.

    .PARAMETER FleetId
        Fleet ID.

    .PARAMETER AgentOptions
        The complete agent options, usually with config, overrides, and command_line_flags.

    .PARAMETER SkipValidation
        Applies the options even when Fleet reports validation errors.

    .PARAMETER DryRun
        Validates the options and applies nothing.

    .EXAMPLE
        $options = (Get-FleetTeam -Id 1).agent_options
        $options.config.options.distributed_interval = 30
        Set-FleetTeamAgentOption -FleetId 1 -AgentOptions $options -DryRun

    .EXAMPLE
        Set-FleetTeamAgentOption -FleetId 1 -AgentOptions (Get-Content ./agent-options.json -Raw)

    .NOTES
        This cmdlet requires Fleet Premium and an admin or GitOps role. Fleet Free responds with HTTP 402.
        Invalid options stop osquery from loading its config, so test with -DryRun first.
        https://fleetdm.com/docs/rest-api/rest-api#update-fleet-level-agent-options

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-fleet-level-agent-options
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('FleetDM.Team')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$AgentOptions,

        [switch]$SkipValidation,

        [switch]$DryRun
    )

    $options = $AgentOptions
    if ($options -is [string]) {
        try {
            $options = $options | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            throw 'AgentOptions is not valid JSON.'
        }
    }

    $body = @{}
    if ($options -is [System.Collections.IDictionary]) {
        foreach ($key in @($options.Keys)) { $body[[string]$key] = $options[$key] }
    }
    elseif ($options -is [System.Management.Automation.PSCustomObject]) {
        foreach ($property in $options.PSObject.Properties) { $body[$property.Name] = $property.Value }
    }
    if ($body.Count -eq 0) {
        throw 'AgentOptions must be an object with at least one key, such as config.'
    }

    $queryParams = @{}
    if ($SkipValidation) { $queryParams['force'] = $true }
    if ($DryRun) { $queryParams['dry_run'] = $true }
    $action = if ($DryRun) { 'Validate agent options (dry run, nothing is applied)' } else { 'Replace agent options' }

    if ($PSCmdlet.ShouldProcess("fleet $FleetId", $action)) {
        $response = Invoke-FleetDMRequest -Endpoint "fleets/$FleetId/agent_options" -Method POST -Body $body -QueryParameters $queryParams
        return (Get-FleetRecord -Response $response)
    }
}
