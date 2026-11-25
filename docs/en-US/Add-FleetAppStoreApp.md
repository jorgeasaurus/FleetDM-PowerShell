---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#add-app-store-app
schema: 2.0.0
---

# Add-FleetAppStoreApp

## SYNOPSIS
Adds an Apple App Store or Google Play app to a fleet.

## SYNTAX

```
Add-FleetAppStoreApp [-AppStoreId] <String> [-FleetId] <Int32> [[-Platform] <String>] [[-VppTokenId] <Int32>]
 [-SelfService] [-AutomaticInstall] [[-Categories] <String[]>] [[-LabelsIncludeAll] <String[]>]
 [[-LabelsIncludeAny] <String[]>] [[-LabelsExcludeAny] <String[]>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/software/app_store_apps with app_store_id and fleet_id.
Apple apps must be purchased in Apple Business first.
Only one of LabelsIncludeAll, LabelsIncludeAny, and LabelsExcludeAny can be used.

## EXAMPLES

### EXAMPLE 1
```
Add-FleetAppStoreApp -AppStoreId '497799835' -FleetId 2 -Platform ipados -SelfService
```

### EXAMPLE 2
```
Get-FleetAppStoreApp -FleetId 2 | Where-Object name -eq 'Xcode' | Add-FleetAppStoreApp -FleetId 2
```

## PARAMETERS

### -AppStoreId
App Store ID, or the Google Play package name.
Binds from the app_store_id property.

```yaml
Type: String
Parameter Sets: (All)
Aliases: app_store_id

Required: True
Position: 1
Default value: None
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

### -Platform
darwin, ios, ipados, or android.
Fleet defaults to darwin.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -VppTokenId
VPP token to add the app from.
Required when the fleet has more than one VPP token.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -SelfService
Lists the app in self-service.
Required for Android apps.

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
Creates a policy that installs the app on macOS hosts that lack it.

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

### -Categories
Self-service category names that already exist on the fleet.

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
https://fleetdm.com/docs/rest-api/rest-api#add-app-store-app

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#add-app-store-app](https://fleetdm.com/docs/rest-api/rest-api#add-app-store-app)

