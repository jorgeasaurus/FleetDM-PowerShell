---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-fleet
schema: 2.0.0
---

# Set-FleetOsUpdate

## SYNOPSIS
Sets enforced OS update deadlines for a fleet.

## SYNTAX

```
Set-FleetOsUpdate [-FleetId] <Int32> [[-MacOsMinimumVersion] <String>] [[-MacOsDeadline] <String>]
 [[-MacOsDeadlineDays] <Int32>] [[-MacOsUpdateNewHosts] <Boolean>] [[-IosMinimumVersion] <String>]
 [[-IosDeadline] <String>] [[-IpadOsMinimumVersion] <String>] [[-IpadOsDeadline] <String>]
 [[-WindowsDeadlineDays] <Int32>] [[-WindowsGracePeriodDays] <Int32>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends PATCH /api/v1/fleet/fleets/{id} with the mdm.macos_updates, ios_updates, ipados_updates, or windows_updates object.
macOS, iOS, iPadOS, and Windows update enforcement is a Fleet Premium control.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetOsUpdate -FleetId 1 -MacOsMinimumVersion "15.4.1" -MacOsDeadline "2026-07-01"
```

## PARAMETERS

### -FleetId
Fleet to update.
Unassigned hosts (id 0) do not accept MDM update settings on this endpoint.

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

### -MacOsMinimumVersion
Minimum macOS version, or "latest".

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

### -MacOsDeadline
Fixed deadline date (yyyy-MM-dd) after which macOS updates are forced.
Cannot be combined with MacOsDeadlineDays.

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

### -MacOsDeadlineDays
Number of days before macOS updates are forced.
Required when MacOsMinimumVersion is latest.
Cannot be combined with MacOsDeadline.

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

### -MacOsUpdateNewHosts
Update newly enrolled ADE Macs during Setup Assistant.

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

### -IosMinimumVersion
Minimum iOS version.

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

### -IosDeadline
iOS deadline date (yyyy-MM-dd).

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

### -IpadOsMinimumVersion
Minimum iPadOS version.

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

### -IpadOsDeadline
iPadOS deadline date (yyyy-MM-dd).

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

### -WindowsDeadlineDays
Days before Windows updates are installed.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -WindowsGracePeriodDays
Days before Windows restarts to finish updates.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
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
https://fleetdm.com/docs/rest-api/rest-api#update-fleet
https://fleetdm.com/docs/configuration/yaml-files

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-fleet](https://fleetdm.com/docs/rest-api/rest-api#update-fleet)

