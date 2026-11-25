---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-script
schema: 2.0.0
---

# Set-FleetScript

## SYNOPSIS
Replaces the contents of a saved script.

## SYNTAX

### Path (Default)
```
Set-FleetScript -Id <Int32> -Path <String> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Contents
```
Set-FleetScript -Id <Int32> -Contents <String> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Sends PATCH /api/v1/fleet/scripts/{id} as multipart/form-data with the new script file.
Fleet keeps the script name and ignores the uploaded file name.
The result always has an id property, including when Fleet returns only script_id.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetScript -Id 12 -Path ./collect-logs.sh
```

### EXAMPLE 2
```
Get-FleetScript -Id 12 | Set-FleetScript -Contents 'echo updated'
```

## PARAMETERS

### -Id
Script ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Path
Local file with the new script contents.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Contents
New script text.

```yaml
Type: String
Parameter Sets: Contents
Aliases:

Required: True
Position: Named
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

### FleetDM.Script
## NOTES
Updating a script that belongs to a fleet requires Fleet Premium.
https://fleetdm.com/docs/rest-api/rest-api#update-script

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-script](https://fleetdm.com/docs/rest-api/rest-api#update-script)

