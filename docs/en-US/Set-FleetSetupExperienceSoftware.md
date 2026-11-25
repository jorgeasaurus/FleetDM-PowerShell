---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-setup-experience-software
schema: 2.0.0
---

# Set-FleetSetupExperienceSoftware

## SYNOPSIS
Sets the software that installs during setup for one platform.

## SYNTAX

### Set (Default)
```
Set-FleetSetupExperienceSoftware -SoftwareTitleId <Int32[]> [-FleetId <Int32>] [-Platform <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Clear
```
Set-FleetSetupExperienceSoftware [-Clear] [-FleetId <Int32>] [-Platform <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends PUT /api/v1/fleet/setup_experience/software with fleet_id, platform, and software_title_ids.
The list replaces the current one for that fleet and platform.
Titles not in the list stop installing during setup.
-Clear sends an empty list.
Piping no titles throws and sends nothing.
An empty list would clear setup software for that fleet and platform.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetSetupExperienceSoftware -FleetId 2 -Platform linux -SoftwareTitleId 3000, 3001
```

### EXAMPLE 2
```
Set-FleetSetupExperienceSoftware -FleetId 2 -Platform windows -Clear
```

## PARAMETERS

### -SoftwareTitleId
Software title IDs to install during setup.
Binds from the id or software_title_id property of piped titles.

```yaml
Type: Int32[]
Parameter Sets: Set
Aliases: Id, software_title_id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Clear
Removes every title from setup for this fleet and platform.

```yaml
Type: SwitchParameter
Parameter Sets: Clear
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FleetId
Fleet to update.
Use 0 for "Unassigned".
The default is 0.

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

### -Platform
macos, windows, linux, ios, ipados, or android.
Fleet defaults to macos.

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

### FleetDM.SetupExperienceSoftwareUpdate
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#update-setup-experience-software

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-setup-experience-software](https://fleetdm.com/docs/rest-api/rest-api#update-setup-experience-software)

