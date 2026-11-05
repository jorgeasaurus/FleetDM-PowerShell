---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-scripts
schema: 2.0.0
---

# Get-FleetScript

## SYNOPSIS
Lists saved scripts or gets one script.

## SYNTAX

### List (Default)
```
Get-FleetScript [-FleetId <Int32>] [-Page <Int32>] [-PerPage <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### ById
```
Get-FleetScript -Id <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/scripts or GET /api/v1/fleet/scripts/{id}.
Listing scripts for unassigned hosts is available in Fleet Free.
Filtering with FleetId requires Fleet Premium.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetScript
```

### EXAMPLE 2
```
Get-FleetScript -Id 12
```

## PARAMETERS

### -Id
Script ID.

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

### -FleetId
Fleet Premium.
Lists scripts saved on this fleet.
Omit it to list scripts for unassigned hosts.

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
Passing FleetId requires Fleet Premium and returns HTTP 402 on Fleet Free.
https://fleetdm.com/docs/rest-api/rest-api#list-scripts

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-scripts](https://fleetdm.com/docs/rest-api/rest-api#list-scripts)

