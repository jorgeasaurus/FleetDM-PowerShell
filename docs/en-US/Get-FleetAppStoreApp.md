---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-apple-app-store-apps
schema: 2.0.0
---

# Get-FleetAppStoreApp

## SYNOPSIS
Lists App Store apps that can be added to a fleet.

## SYNTAX

```
Get-FleetAppStoreApp [-FleetId] <Int32> [[-VppTokenId] <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/software/app_store_apps?fleet_id={fleet_id}.
Apps already added to the fleet for a platform are left out.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetAppStoreApp -FleetId 2
```

## PARAMETERS

### -FleetId
Fleet to list apps for.
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

### -VppTokenId
VPP token to list apps from.
Required when the fleet has more than one VPP token.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
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

### FleetDM.AppStoreApp
## NOTES
Requires Apple MDM and a VPP token assigned to the fleet.
https://fleetdm.com/docs/rest-api/rest-api#list-apple-app-store-apps

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-apple-app-store-apps](https://fleetdm.com/docs/rest-api/rest-api#list-apple-app-store-apps)

