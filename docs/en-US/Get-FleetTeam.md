---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-fleets
schema: 2.0.0
---

# Get-FleetTeam

## SYNOPSIS
Gets Fleet Premium fleets (formerly called teams).

## SYNTAX

### List (Default)
```
Get-FleetTeam [-Name <String>] [-Page <Int32>] [-PerPage <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### ById
```
Get-FleetTeam -Id <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Lists fleets or retrieves one fleet by ID from GET /api/v1/fleet/fleets.
The REST resource is "fleets".
Create and get responses still return the fleet under the "team" property.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetTeam
```

Lists every fleet.

### EXAMPLE 2
```
Get-FleetTeam -Id 1
```

Gets fleet 1.

## PARAMETERS

### -Id
Fleet ID.
Use 0 for hosts that are not assigned to a fleet.

```yaml
Type: Int32
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Name
Case-insensitive partial name match applied after the fleet list is retrieved.

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

### -Page
Page number.
When omitted, every page is retrieved.

```yaml
Type: Int32
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PerPage
Page size.
The default is 100.

```yaml
Type: Int32
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: 100
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
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#list-fleets

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-fleets](https://fleetdm.com/docs/rest-api/rest-api#list-fleets)

