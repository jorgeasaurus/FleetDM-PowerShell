---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#delete-self-service-category
schema: 2.0.0
---

# Remove-FleetSelfServiceCategory

## SYNOPSIS
Deletes a self-service software category.

## SYNTAX

```
Remove-FleetSelfServiceCategory [-Id] <Int32> [-Force] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends DELETE /api/v1/fleet/software/self_service_categories/{id}.
Software assigned to the category remains installed.

## EXAMPLES

### EXAMPLE 1
```
Remove-FleetSelfServiceCategory -Id 42
```

## PARAMETERS

### -Id
Category ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
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
This cmdlet requires Fleet Premium.
The Fleet Free service returns HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#delete-self-service-category

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#delete-self-service-category](https://fleetdm.com/docs/rest-api/rest-api#delete-self-service-category)

