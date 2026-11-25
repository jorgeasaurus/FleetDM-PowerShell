---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-fleet-maintained-apps
schema: 2.0.0
---

# Get-FleetMaintainedApp

## SYNOPSIS
Lists Fleet-maintained apps or gets one.

## SYNTAX

### List (Default)
```
Get-FleetMaintainedApp [-FleetId <Int32>] [-Query <String>] [-Platform <String>] [-Available]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ById
```
Get-FleetMaintainedApp -Id <Int32> [-FleetId <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/software/fleet_maintained_apps or GET /api/v1/fleet/software/fleet_maintained_apps/{id}.
With FleetId, each app carries software_title_id when it is already added to that fleet.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetMaintainedApp -Query 'Slack' -Platform darwin
```

### EXAMPLE 2
```
Get-FleetMaintainedApp -Id 1 -FleetId 2
```

## PARAMETERS

### -Id
Fleet-maintained app ID.

```yaml
Type: Int32
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FleetId
Fleet whose software_title_id values are filled in.

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

### -Query
Searches app names.

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Platform
Lists apps for darwin or windows.

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Available
Lists only apps not yet added to FleetId.

```yaml
Type: SwitchParameter
Parameter Sets: List
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

### FleetDM.MaintainedApp
## NOTES
Listing is available in Fleet Free.
Adding an app requires Fleet Premium.
https://fleetdm.com/docs/rest-api/rest-api#list-fleet-maintained-apps

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-fleet-maintained-apps](https://fleetdm.com/docs/rest-api/rest-api#list-fleet-maintained-apps)

