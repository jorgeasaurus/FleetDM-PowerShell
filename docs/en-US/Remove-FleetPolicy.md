---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#delete-policies
schema: 2.0.0
---

# Remove-FleetPolicy

## SYNOPSIS
Deletes global or fleet policies.

## SYNTAX

```
Remove-FleetPolicy [-Id] <Int32[]> [[-FleetId] <Int32>] [-Force] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/global/policies/delete, or
POST /api/v1/fleet/fleets/{fleet_id}/policies/delete when FleetId is set.
Fleet deletes policies with a POST that carries the ids.
There is no DELETE route.

Ids are collected from the pipeline and sent in one request per fleet.
A piped global policy has a null fleet_id and is deleted from the global list.
Deleted holds Fleet's deleted value.
Fleet 4.96 returns the deleted ids; the API reference shows a count.

## EXAMPLES

### EXAMPLE 1
```
Remove-FleetPolicy -Id 12, 13
```

Deletes two global policies in one request.

### EXAMPLE 2
```
Remove-FleetPolicy -Id 7 -FleetId 2
```

Deletes a policy that belongs to fleet 2.

### EXAMPLE 3
```
Get-FleetPolicy -FleetId 2 -Name "Legacy" | Remove-FleetPolicy -Force
```

Deletes every fleet 2 policy whose name contains Legacy.

## PARAMETERS

### -Id
Policy IDs to delete.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -FleetId
Fleet Premium.
Fleet that owns the policies.
Use 0 for "Unassigned" policies.
Omit it, or pass $null, for global policies.
Binds from the fleet_id or team_id property of piped policies.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: fleet_id, team_id

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Force
Skips the confirmation prompt.
-WhatIf is still honored.

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

### FleetDM.RemovedPolicy
## NOTES
Deleting fleet policies requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#delete-policies
https://fleetdm.com/docs/rest-api/rest-api#delete-fleet-level-policies

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#delete-policies](https://fleetdm.com/docs/rest-api/rest-api#delete-policies)

