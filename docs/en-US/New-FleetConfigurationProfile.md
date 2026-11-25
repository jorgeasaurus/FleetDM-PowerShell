---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#create-configuration-profile
schema: 2.0.0
---

# New-FleetConfigurationProfile

## SYNOPSIS
Uploads a configuration profile.

## SYNTAX

```
New-FleetConfigurationProfile [-Path] <String> [-Name <String>] [-Description <String>] [-FleetId <Int32>]
 [-LabelsIncludeAll <String[]>] [-LabelsIncludeAny <String[]>] [-LabelsExcludeAny <String[]>]
 [-ActivationPath <String>] [-SelfService] [-Hidden] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/configuration_profiles as multipart/form-data.
Accepts a .mobileconfig or DDM .json profile for Apple hosts, an .xml profile for Windows, or a .json profile for Android.
Label lists are sent as one form field per label name.
LabelsIncludeAll and LabelsIncludeAny cannot be combined.
LabelsExcludeAny can be combined with either.

## EXAMPLES

### EXAMPLE 1
```
New-FleetConfigurationProfile -Path ./passcode.mobileconfig -FleetId 2 -LabelsIncludeAny 'Engineering', 'QA'
```

### EXAMPLE 2
```
New-FleetConfigurationProfile -Path ./firewall.xml -Name 'Windows firewall' -LabelsExcludeAny 'Servers'
```

## PARAMETERS

### -Path
Local profile file.

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

### -Name
Display name.
Fleet derives one from the file when omitted.

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

### -Description
Optional description.

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

### -FleetId
Fleet Premium.
Applies the profile to hosts on this fleet.
Omit it for "Unassigned" hosts.

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

### -LabelsIncludeAll
Fleet Premium.
Targets hosts that have all of these labels.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LabelsIncludeAny
Fleet Premium.
Targets hosts that have any of these labels.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LabelsExcludeAny
Fleet Premium.
Skips hosts that have any of these labels.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ActivationPath
Fleet Premium.
Activation JSON file for a declaration (DDM) profile.

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

### -SelfService
Fleet Premium.
Makes a .mobileconfig profile opt-in from My device \> Controls.

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

### -Hidden
Fleet Premium.
Hides the profile on My device \> Controls.
Cannot be combined with SelfService.

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

### FleetDM.ConfigurationProfile
## NOTES
Requires MDM for the profile's platform.
Labels, activation, self-service, hidden, and FleetId require Fleet Premium.
https://fleetdm.com/docs/rest-api/rest-api#create-configuration-profile

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#create-configuration-profile](https://fleetdm.com/docs/rest-api/rest-api#create-configuration-profile)

