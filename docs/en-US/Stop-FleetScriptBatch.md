---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#cancel-batch-script
schema: 2.0.0
---

# Stop-FleetScriptBatch

## SYNOPSIS
Cancels a batch script run.

## SYNTAX

```
Stop-FleetScriptBatch [-BatchExecutionId] <String> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/scripts/batch/{batch_execution_id}/cancel.
Hosts that already ran the script are not affected.

## EXAMPLES

### EXAMPLE 1
```
Stop-FleetScriptBatch -BatchExecutionId 'e797d6c6-3aae-11ee-be56-0242ac120002'
```

### EXAMPLE 2
```
Get-FleetScriptBatch -Status scheduled | Stop-FleetScriptBatch -Confirm:$false
```

## PARAMETERS

### -BatchExecutionId
Batch execution ID.
Binds from the batch_execution_id property.

```yaml
Type: String
Parameter Sets: (All)
Aliases: batch_execution_id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### FleetDM.CanceledScriptBatch
## NOTES
https://fleetdm.com/docs/rest-api/rest-api#cancel-batch-script

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#cancel-batch-script](https://fleetdm.com/docs/rest-api/rest-api#cancel-batch-script)

