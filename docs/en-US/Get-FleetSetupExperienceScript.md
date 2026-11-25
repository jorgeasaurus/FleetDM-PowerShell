---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#get-or-download-setup-experience-script
schema: 2.0.0
---

# Get-FleetSetupExperienceScript

## SYNOPSIS
Gets the script that runs during macOS setup, or its contents.

## SYNTAX

```
Get-FleetSetupExperienceScript [[-FleetId] <Int32>] [-Contents] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/setup_experience/script.
-Contents adds alt=media and returns the script text decoded as UTF-8.
Fleet answers 404 when the fleet has no setup script.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetSetupExperienceScript -FleetId 3
```

### EXAMPLE 2
```
Get-FleetSetupExperienceScript -FleetId 3 -Contents
```

## PARAMETERS

### -FleetId
Fleet whose script is read.
Omit it for "Unassigned".

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

### -Contents
Returns the script text instead of the metadata.

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

### FleetDM.SetupExperienceScript
### string
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#get-or-download-setup-experience-script

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#get-or-download-setup-experience-script](https://fleetdm.com/docs/rest-api/rest-api#get-or-download-setup-experience-script)

