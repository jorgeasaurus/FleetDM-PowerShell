---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-self-service-categories
schema: 2.0.0
---

# Get-FleetSelfServiceCategory

## SYNOPSIS
Lists self-service software categories for a fleet.

## SYNTAX

```
Get-FleetSelfServiceCategory [-FleetId] <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/software/self_service_categories.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetSelfServiceCategory -FleetId 3
```

## PARAMETERS

### -FleetId
Fleet ID.
Use 0 for hosts that are not assigned to a fleet.

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
The Fleet Free service returns HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#list-self-service-categories
https://fleetdm.com/guides/software-self-service

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-self-service-categories](https://fleetdm.com/docs/rest-api/rest-api#list-self-service-categories)

