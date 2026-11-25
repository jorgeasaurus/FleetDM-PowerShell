---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-app-store-app
schema: 2.0.0
---

# Set-FleetAppStoreApp

## SYNOPSIS
Updates an App Store app's self-service, category, and targeting settings.

## SYNTAX

```
Set-FleetAppStoreApp [-SoftwareTitleId] <Int32> [-FleetId] <Int32> [[-VersionId] <Int32>]
 [[-DisplayName] <String>] [[-SelfService] <Boolean>] [[-Categories] <String[]>]
 [[-LabelsIncludeAll] <String[]>] [[-LabelsIncludeAny] <String[]>] [[-LabelsExcludeAny] <String[]>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends PATCH /api/v1/fleet/software/titles/{title_id}/app_store_app.
Only supplied fields are sent.
Settings apply to one version of the app; use VersionId when the title has more than one.
Only one of LabelsIncludeAll, LabelsIncludeAny, and LabelsExcludeAny can be used.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetAppStoreApp -SoftwareTitleId 3467 -FleetId 2 -SelfService $true -Categories 'Browser'
```

## PARAMETERS

### -SoftwareTitleId
Software title ID.
Binds from the software_title_id property.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: software_title_id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FleetId
Fleet that owns the app.
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

### -VersionId
App version ID.
Required when the title has more than one version on the fleet.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: version_id

Required: False
Position: 3
Default value: 0
Accept pipeline input: True (ByPropertyName)
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

### -SelfService
Sets whether the app is listed in self-service.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Categories
Self-service category names.
Pass an empty array to remove every category.

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

### -LabelsIncludeAll
Targets hosts that have all of these labels.

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

### -LabelsIncludeAny
Targets hosts that have any of these labels.

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

### -LabelsExcludeAny
Skips hosts that have any of these labels.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
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

### FleetDM.AppStoreApp
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#update-app-store-app

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-app-store-app](https://fleetdm.com/docs/rest-api/rest-api#update-app-store-app)

