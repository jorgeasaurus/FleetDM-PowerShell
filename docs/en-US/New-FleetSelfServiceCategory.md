---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#add-self-service-category
schema: 2.0.0
---

# New-FleetSelfServiceCategory

## SYNOPSIS
Creates a self-service software category.

## SYNTAX

```
New-FleetSelfServiceCategory [-FleetId] <Int32> [-Name] <String> [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/software/self_service_categories.
The name must be unique within the fleet and at most 255 characters.

## EXAMPLES

### EXAMPLE 1
```
New-FleetSelfServiceCategory -FleetId 3 -Name "Engineering"
```

## PARAMETERS

### -FleetId
Fleet ID.
Use 0 for unassigned hosts.

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

### -Name
Category name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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
https://fleetdm.com/docs/rest-api/rest-api#add-self-service-category
https://fleetdm.com/guides/software-self-service

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#add-self-service-category](https://fleetdm.com/docs/rest-api/rest-api#add-self-service-category)

