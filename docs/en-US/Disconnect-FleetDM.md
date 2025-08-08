---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version:
schema: 2.0.0
---

# Disconnect-FleetDM

## SYNOPSIS
Disconnects from the FleetDM API

## SYNTAX

```
Disconnect-FleetDM [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Closes the current FleetDM connection and clears stored authentication information.
After disconnecting, you must run Connect-FleetDM before using other FleetDM cmdlets.

## EXAMPLES

### EXAMPLE 1
```
Disconnect-FleetDM
```

Disconnects from the current FleetDM instance

### EXAMPLE 2
```
Disconnect-FleetDM -Verbose
```

Disconnects and shows verbose information about the disconnection process

## PARAMETERS

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

[Connect-FleetDM]()

