---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#create-setup-experience-script
schema: 2.0.0
---

# Set-FleetSetupExperienceScript

## SYNOPSIS
Uploads the script that runs during macOS setup.

## SYNTAX

### Path (Default)
```
Set-FleetSetupExperienceScript [-Path] <String> [-FleetId <Int32>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Contents
```
Set-FleetSetupExperienceScript -Contents <String> -Name <String> [-FleetId <Int32>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/setup_experience/script as multipart/form-data with the script file.
A fleet has one setup script.
Remove the current one with Remove-FleetSetupExperienceScript before uploading a new one.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetSetupExperienceScript -FleetId 3 -Path ./setup.sh
```

### EXAMPLE 2
```
Set-FleetSetupExperienceScript -Name 'setup.sh' -Contents 'echo setup'
```

## PARAMETERS

### -Path
Local script file.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Contents
Script text instead of a file.
Requires Name.

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

### -Name
Script file name used with Contents.

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

### -FleetId
Fleet that runs the script.
Omit it for "Unassigned".

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
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

### FleetDM.SetupExperienceScript
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#create-setup-experience-script

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#create-setup-experience-script](https://fleetdm.com/docs/rest-api/rest-api#create-setup-experience-script)

