---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-volume-purchasing-program-vpp-tokens
schema: 2.0.0
---

# Get-FleetVppToken

## SYNOPSIS
Lists Volume Purchasing Program (VPP) tokens.

## SYNTAX

```
Get-FleetVppToken [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/vpp_tokens.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetVppToken | Select-Object id, org_name, renew_date, fleets
```

## PARAMETERS

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
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#list-volume-purchasing-program-vpp-tokens

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-volume-purchasing-program-vpp-tokens](https://fleetdm.com/docs/rest-api/rest-api#list-volume-purchasing-program-vpp-tokens)

