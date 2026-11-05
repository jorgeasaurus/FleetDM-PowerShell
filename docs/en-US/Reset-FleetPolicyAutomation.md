---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#reset-policy-automations
schema: 2.0.0
---

# Reset-FleetPolicyAutomation

## SYNOPSIS
Resets failing-policy automation state.

## SYNTAX

```
Reset-FleetPolicyAutomation [-PolicyId] <Int32[]> [[-FleetId] <Int32[]>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/automations/reset with policy_ids only.
Hosts that are still failing are treated as newly failing on the next run.
Fleet's fleet_ids field adds every policy on those fleets to the reset, so this cmdlet does not send it.
When FleetId is set, each id is checked against that fleet's policies and only the matching policy_ids are sent.

## EXAMPLES

### EXAMPLE 1
```
Reset-FleetPolicyAutomation -PolicyId 1, 2, 3
```

### EXAMPLE 2
```
Reset-FleetPolicyAutomation -PolicyId 1 -FleetId 4
```

## PARAMETERS

### -PolicyId
Policy IDs to reset.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FleetId
Fleet Premium.
Policy IDs must belong to one of these fleets.
The request still sends only policy_ids.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
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

## NOTES
FleetId requires Fleet Premium.
The reset endpoint itself is available in Fleet Free for global policies.
https://fleetdm.com/docs/rest-api/rest-api#reset-policy-automations

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#reset-policy-automations](https://fleetdm.com/docs/rest-api/rest-api#reset-policy-automations)

