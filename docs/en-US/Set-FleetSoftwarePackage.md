---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-package
schema: 2.0.0
---

# Set-FleetSoftwarePackage

## SYNOPSIS
Updates a software installer, its scripts, or its targeting.

## SYNTAX

```
Set-FleetSoftwarePackage [-SoftwareTitleId] <Int32> [-FleetId] <Int32> [[-Path] <String>]
 [[-DisplayName] <String>] [[-Categories] <String[]>] [[-InstallScript] <String>] [[-UninstallScript] <String>]
 [[-PreInstallQuery] <String>] [[-PostInstallScript] <String>] [[-SelfService] <Boolean>]
 [[-LabelsIncludeAll] <String[]>] [[-LabelsIncludeAny] <String[]>] [[-LabelsExcludeAny] <String[]>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends PATCH /api/v1/fleet/software/titles/{id}/package as multipart/form-data.
Only supplied fields are sent; Fleet leaves the rest unchanged.
A new Path is streamed from disk.
Any label parameter replaces the installer's label targeting.
Only one label parameter can be used.
Changing anything other than SelfService cancels pending installs of the old package.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetSoftwarePackage -SoftwareTitleId 24 -FleetId 2 -SelfService $true -Categories 'Security'
```

### EXAMPLE 2
```
Set-FleetSoftwarePackage -SoftwareTitleId 24 -FleetId 2 -Path ./FalconSensor-7.1.pkg
```

## PARAMETERS

### -SoftwareTitleId
Software title ID.
Binds from the software_title_id or id property.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: software_title_id, Id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FleetId
Fleet that owns the installer.
Use 0 for "Unassigned".

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Replacement installer file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayName
Display name that overrides the title name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Categories
Self-service category names that already exist on the fleet.
Pass an empty array to remove every category.

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

### -InstallScript
Install script.

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

### -UninstallScript
Uninstall script.
An empty string restores Fleet's default.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreInstallQuery
osquery pre-install condition.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PostInstallScript
Post-install script.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SelfService
Sets whether end users can install the software from Fleet Desktop.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: False
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
Position: 11
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
Position: 12
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
Position: 13
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

### FleetDM.SoftwarePackage
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#update-package

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-package](https://fleetdm.com/docs/rest-api/rest-api#update-package)

