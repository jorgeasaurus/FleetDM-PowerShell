---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-volume-purchasing-program-vpp-tokens-fleets
schema: 2.0.0
---

# Set-FleetVppTokenFleet

## SYNOPSIS
Sets which fleets can use a VPP token's App Store apps.

## SYNTAX

### FleetId (Default)
```
Set-FleetVppTokenFleet -Id <Int32> -FleetId <Int32[]> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### AllFleets
```
Set-FleetVppTokenFleet -Id <Int32> [-AllFleets] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### NoFleet
```
Set-FleetVppTokenFleet -Id <Int32> [-NoFleet] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Sends PATCH /api/v1/fleet/vpp_tokens/{id}/fleets.
-FleetId sends those fleet IDs.
-AllFleets sends an empty list, which Fleet reads as every fleet,
including fleets created later.
-NoFleet sends null, which removes the token from every fleet.
App Store apps added from this token are deleted from any fleet the token is removed from.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetVppTokenFleet -Id 1 -FleetId 1, 2
```

### EXAMPLE 2
```
Set-FleetVppTokenFleet -Id 1 -AllFleets
```

## PARAMETERS

### -Id
VPP token ID.
Binds from the id property of Get-FleetVppToken or Add-FleetVppToken output.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FleetId
Fleet IDs that can use the token.
Use 0 for "Unassigned".

```yaml
Type: Int32[]
Parameter Sets: FleetId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllFleets
Assigns the token to every fleet.

```yaml
Type: SwitchParameter
Parameter Sets: AllFleets
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoFleet
Removes the token from every fleet.

```yaml
Type: SwitchParameter
Parameter Sets: NoFleet
Aliases:

Required: True
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

### FleetDM.VppToken
## NOTES
This cmdlet requires Fleet Premium and a global admin role.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#update-volume-purchasing-program-vpp-tokens-fleets

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-volume-purchasing-program-vpp-tokens-fleets](https://fleetdm.com/docs/rest-api/rest-api#update-volume-purchasing-program-vpp-tokens-fleets)

