---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-fleet
schema: 2.0.0
---

# Set-FleetCalendarEvent

## SYNOPSIS
Enables calendar maintenance windows for a fleet.

## SYNTAX

```
Set-FleetCalendarEvent [-FleetId] <Int32> [-Enable] <Boolean> [[-WebhookUrl] <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends PATCH /api/v1/fleet/fleets/{id} with integrations.google_calendar.
Calendar maintenance windows are a Fleet Premium feature.
The Google Calendar integration must already exist in the global configuration.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetCalendarEvent -FleetId 1 -Enable $true -WebhookUrl "https://automations.example/fleet"
```

## PARAMETERS

### -FleetId
Fleet ID.
This setting is not applied through fleet id 0.

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

### -Enable
Whether calendar events are enabled.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WebhookUrl
URL Fleet calls during the calendar event so automation can run.

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

## NOTES
This cmdlet requires Fleet Premium.
https://fleetdm.com/docs/rest-api/rest-api#update-fleet
https://fleetdm.com/pricing

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-fleet](https://fleetdm.com/docs/rest-api/rest-api#update-fleet)

