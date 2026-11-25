---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#add-fleet-maintained-app
schema: 2.0.0
---

# Add-FleetMaintainedApp

## SYNOPSIS
Adds a Fleet-maintained app to a fleet.

## SYNTAX

```
Add-FleetMaintainedApp [-Id] <Int32> [-FleetId] <Int32> [[-InstallScript] <String>]
 [[-PreInstallQuery] <String>] [[-PostInstallScript] <String>] [-SelfService] [-AutomaticInstall]
 [[-LabelsIncludeAll] <String[]>] [[-LabelsIncludeAny] <String[]>] [[-LabelsExcludeAny] <String[]>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/software/fleet_maintained_apps with fleet_maintained_app_id and fleet_id.
Fleet downloads the installer and returns the software_title_id.
Only one of LabelsIncludeAll, LabelsIncludeAny, and LabelsExcludeAny can be used.

## EXAMPLES

### EXAMPLE 1
```
Add-FleetMaintainedApp -Id 3 -FleetId 2 -AutomaticInstall
```

### EXAMPLE 2
```
Get-FleetMaintainedApp -Query '1Password' -Platform darwin | Add-FleetMaintainedApp -FleetId 2 -SelfService
```

## PARAMETERS

### -Id
Fleet-maintained app ID.
Binds from the id property of Get-FleetMaintainedApp output.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: fleet_maintained_app_id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FleetId
Fleet that receives the app.
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

### -InstallScript
Install script that replaces Fleet's default.

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

### -PreInstallQuery
osquery pre-install condition.

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

### -PostInstallScript
Post-install script.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SelfService
Lets end users install the app from Fleet Desktop.

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

### -AutomaticInstall
Creates a policy that installs the app on hosts that lack it.

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

### -LabelsIncludeAll
Targets hosts that have all of these labels.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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
Position: 7
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
Position: 8
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

### FleetDM.SoftwareTitleReference
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#add-fleet-maintained-app

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#add-fleet-maintained-app](https://fleetdm.com/docs/rest-api/rest-api#add-fleet-maintained-app)

