---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-hosts-fleet-by-filter
schema: 2.0.0
---

# Move-FleetHost

## SYNOPSIS
Moves every host that matches a filter to a fleet.

## SYNTAX

```
Move-FleetHost [-FleetId] <Int32> [-Filter] <Hashtable> [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/hosts/transfer/filter with fleet_id and filters.
The filter must name at least one of query, status, label_id, or fleet_id.
An empty filter would match every host, so it is rejected.
To move hosts by ID, use Set-FleetTeam -HostId.

## EXAMPLES

### EXAMPLE 1
```
Move-FleetHost -FleetId 2 -Filter @{ label_id = 7 }
```

### EXAMPLE 2
```
Move-FleetHost -FleetId 2 -Filter @{ fleet_id = 0; status = 'online' } -WhatIf
```

## PARAMETERS

### -FleetId
Destination fleet ID.
Use 0 for "Unassigned".

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

### -Filter
Host filter with any of query, status, label_id, and fleet_id (use 0 for "Unassigned").

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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

### FleetDM.HostTransfer
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#update-hosts-fleet-by-filter

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-hosts-fleet-by-filter](https://fleetdm.com/docs/rest-api/rest-api#update-hosts-fleet-by-filter)

