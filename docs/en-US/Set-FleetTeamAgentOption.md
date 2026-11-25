---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-fleet-level-agent-options
schema: 2.0.0
---

# Set-FleetTeamAgentOption

## SYNOPSIS
Replaces a fleet's agent options.

## SYNTAX

```
Set-FleetTeamAgentOption [-FleetId] <Int32> [-AgentOptions] <Object> [-SkipValidation] [-DryRun]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/fleets/{id}/agent_options with the options as the body.
The body replaces the fleet's agent options.
Read the current value from Get-FleetTeam's agent_options.
AgentOptions can be a hashtable, an object such as (Get-FleetTeam -Id 1).agent_options, or a JSON string.
-SkipValidation sends force=true.
-DryRun sends dry_run=true and applies nothing.

## EXAMPLES

### EXAMPLE 1
```
$options = (Get-FleetTeam -Id 1).agent_options
$options.config.options.distributed_interval = 30
Set-FleetTeamAgentOption -FleetId 1 -AgentOptions $options -DryRun
```

### EXAMPLE 2
```
Set-FleetTeamAgentOption -FleetId 1 -AgentOptions (Get-Content ./agent-options.json -Raw)
```

## PARAMETERS

### -FleetId
Fleet ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -AgentOptions
The complete agent options, usually with config, overrides, and command_line_flags.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipValidation
Applies the options even when Fleet reports validation errors.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DryRun
Validates the options and applies nothing.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
ProgressAction is a PowerShell common parameter.

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### FleetDM.Team
## NOTES
This cmdlet requires Fleet Premium and an admin or GitOps role.
Fleet Free responds with HTTP 402.
Invalid options stop osquery from loading its config, so test with -DryRun first.
https://fleetdm.com/docs/rest-api/rest-api#update-fleet-level-agent-options

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-fleet-level-agent-options](https://fleetdm.com/docs/rest-api/rest-api#update-fleet-level-agent-options)

