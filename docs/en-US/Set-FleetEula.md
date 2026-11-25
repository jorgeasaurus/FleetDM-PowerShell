---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#create-eula
schema: 2.0.0
---

# Set-FleetEula

## SYNOPSIS
Uploads the EULA shown during setup.

## SYNTAX

```
Set-FleetEula [-Path] <String> [-Platform <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/setup_experience/eula as multipart/form-data with eula and platform.
darwin takes a PDF up to 25 MiB.
windows takes a Markdown file up to 512 KB.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetEula -Path ./eula.pdf
```

### EXAMPLE 2
```
Set-FleetEula -Path ./terms.md -Platform windows
```

## PARAMETERS

### -Path
Local EULA file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Platform
darwin or windows.
Fleet defaults to darwin.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

### FleetDM.Eula
## NOTES
This cmdlet requires Fleet Premium and a global admin or GitOps role.
https://fleetdm.com/docs/rest-api/rest-api#create-eula

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#create-eula](https://fleetdm.com/docs/rest-api/rest-api#create-eula)

