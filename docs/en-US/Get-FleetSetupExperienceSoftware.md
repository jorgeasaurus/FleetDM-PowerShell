---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-setup-experience-software
schema: 2.0.0
---

# Get-FleetSetupExperienceSoftware

## SYNOPSIS
Lists software that can install during setup, and whether it does.

## SYNTAX

```
Get-FleetSetupExperienceSoftware [[-FleetId] <Int32>] [[-Platform] <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/setup_experience/software and follows pagination.
Titles with software_package.install_during_setup or app_store_app.install_during_setup set to true install during setup.
Fleet 4.96 requires fleet_id.
FleetId defaults to 0, which is "Unassigned".

## EXAMPLES

### EXAMPLE 1
```
Get-FleetSetupExperienceSoftware -FleetId 2 -Platform linux
```

## PARAMETERS

### -FleetId
Fleet to list.
Use 0 for "Unassigned".

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Platform
macos, windows, linux, ios, ipados, or android.
Fleet defaults to macos.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

### FleetDM.SetupExperienceSoftware
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#list-setup-experience-software

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-setup-experience-software](https://fleetdm.com/docs/rest-api/rest-api#list-setup-experience-software)

