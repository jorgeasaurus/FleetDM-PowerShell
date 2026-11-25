---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-configuration-profile
schema: 2.0.0
---

# Set-FleetConfigurationProfile

## SYNOPSIS
Updates a configuration profile's file, labels, activation, or self-service settings.

## SYNTAX

```
Set-FleetConfigurationProfile [-ProfileUuid] <String> [[-Path] <String>] [[-LabelsIncludeAll] <String[]>]
 [[-LabelsIncludeAny] <String[]>] [[-LabelsExcludeAny] <String[]>] [-ClearLabels] [[-ActivationPath] <String>]
 [-RemoveActivation] [[-SelfService] <Boolean>] [[-Hidden] <Boolean>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends PATCH /api/v1/fleet/configuration_profiles/{profile_uuid} as multipart/form-data.

Fleet replaces label targeting on every PATCH and targets all hosts when no label is sent.
To keep targeting, this cmdlet reads the profile and sends its current labels again when
no label parameter is passed.
Any label parameter replaces all label targeting.
-ClearLabels sends no labels, so the profile targets all hosts.

SelfService and Hidden keep their current values when omitted.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24' -LabelsIncludeAny 'Engineering'
```

### EXAMPLE 2
```
Set-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24' -Path ./passcode.mobileconfig
```

Replaces the file and keeps the current labels.

## PARAMETERS

### -ProfileUuid
Profile UUID.
Binds from the profile_uuid property.

```yaml
Type: String
Parameter Sets: (All)
Aliases: profile_uuid

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Path
Replacement profile file.
A .mobileconfig must keep the same PayloadIdentifier.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LabelsIncludeAll
Targets hosts that have all of these labels.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LabelsIncludeAny
Targets hosts that have any of these labels.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LabelsExcludeAny
Skips hosts that have any of these labels.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClearLabels
Removes label targeting so the profile targets all hosts.

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

### -ActivationPath
Replacement activation JSON for a declaration (DDM) profile.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveActivation
Removes the activation from a declaration (DDM) profile.

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

### -SelfService
Sets whether a .mobileconfig profile is opt-in.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hidden
Sets whether the profile is hidden on My device \> Controls.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
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

### FleetDM.ConfigurationProfile
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#update-configuration-profile

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-configuration-profile](https://fleetdm.com/docs/rest-api/rest-api#update-configuration-profile)

