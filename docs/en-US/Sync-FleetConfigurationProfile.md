---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#batch-update-configuration-profiles
schema: 2.0.0
---

# Sync-FleetConfigurationProfile

## SYNOPSIS
Replaces every configuration profile on a fleet with a set of files.

## SYNTAX

### Unassigned (Default)
```
Sync-FleetConfigurationProfile [-Path] <String[]> [-DryRun] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### FleetId
```
Sync-FleetConfigurationProfile [-Path] <String[]> -FleetId <Int32> [-DryRun]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### FleetName
```
Sync-FleetConfigurationProfile [-Path] <String[]> -FleetName <String> [-DryRun]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/configuration_profiles/batch with each file base64 encoded.
The files become the complete profile set for the fleet.
Profiles not in the list are removed,
and Fleet sends a remove command to Apple hosts for them.

Windows .xml and DDM .json profiles are named after the file name without its extension.
A .mobileconfig profile takes its PayloadDisplayName.

-DryRun asks Fleet to validate the set without applying it.

## EXAMPLES

### EXAMPLE 1
```
Sync-FleetConfigurationProfile -Path ./profiles/*.mobileconfig -FleetId 2 -DryRun
```

### EXAMPLE 2
```
Sync-FleetConfigurationProfile -Path ./passcode.mobileconfig, ./firewall.xml -FleetName 'Workstations'
```

## PARAMETERS

### -Path
Profile files that make up the complete set.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FleetId
Fleet Premium.
Fleet that receives the set.
Omit FleetId and FleetName for "Unassigned" hosts.

```yaml
Type: Int32
Parameter Sets: FleetId
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -FleetName
Fleet Premium.
Fleet name instead of FleetId.

```yaml
Type: String
Parameter Sets: FleetName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DryRun
Validates the set and applies nothing.

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

### FleetDM.ConfigurationProfileSync
## NOTES
This replaces the whole set.
Profiles that are not listed are deleted.
FleetId and FleetName require Fleet Premium.
https://fleetdm.com/docs/rest-api/rest-api#batch-update-configuration-profiles

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#batch-update-configuration-profiles](https://fleetdm.com/docs/rest-api/rest-api#batch-update-configuration-profiles)

