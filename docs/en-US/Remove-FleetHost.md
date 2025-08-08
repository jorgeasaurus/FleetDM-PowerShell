---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/using-fleet/rest-api#delete-host
schema: 2.0.0
---

# Remove-FleetHost

## SYNOPSIS
Removes hosts from FleetDM

## SYNTAX

```
Remove-FleetHost [-Id] <Int32[]> [-Force] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Removes one or more hosts from FleetDM.
Supports pipeline input for bulk operations.
Use with caution as this operation cannot be undone.

## EXAMPLES

### EXAMPLE 1
```
Remove-FleetHost -Id 123
```

Removes host with ID 123 after confirmation

### EXAMPLE 2
```
Remove-FleetHost -Id 123 -Force
```

Removes host with ID 123 without confirmation

### EXAMPLE 3
```
Get-FleetHost -Status offline | Remove-FleetHost -Force
```

Removes all offline hosts without confirmation

### EXAMPLE 4
```
@(123, 456, 789) | Remove-FleetHost -WhatIf
```

Shows what would happen if you removed hosts 123, 456, and 789

### EXAMPLE 5
```
Get-FleetHost -Hostname "old-*" | Remove-FleetHost
```

Removes all hosts with hostnames starting with "old-" after confirmation for each

## PARAMETERS

### -Id
The ID(s) of the host(s) to remove.
Accepts pipeline input.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases: HostId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Force
Skip confirmation prompts

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
{{ Fill ProgressAction Description }}

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

## RELATED LINKS

[https://fleetdm.com/docs/using-fleet/rest-api#delete-host](https://fleetdm.com/docs/using-fleet/rest-api#delete-host)

