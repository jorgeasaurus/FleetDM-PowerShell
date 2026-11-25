---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#add-volume-purchasing-program-vpp-token
schema: 2.0.0
---

# Add-FleetVppToken

## SYNOPSIS
Uploads a VPP content token from Apple Business.

## SYNTAX

```
Add-FleetVppToken [-Path] <String> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/vpp_tokens as multipart/form-data with the .vpptoken file in the token field.
A new token is not assigned to any fleet.
Assign it with Set-FleetVppTokenFleet.
The verbose log shows the field name and byte count, not the token.

## EXAMPLES

### EXAMPLE 1
```
Add-FleetVppToken -Path ./sToken_for_Acme.vpptoken | Set-FleetVppTokenFleet -FleetId 1, 2
```

## PARAMETERS

### -Path
Local .vpptoken file downloaded from Apple Business.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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

### FleetDM.VppToken
## NOTES
This cmdlet requires Fleet Premium and a global admin role.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#add-volume-purchasing-program-vpp-token

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#add-volume-purchasing-program-vpp-token](https://fleetdm.com/docs/rest-api/rest-api#add-volume-purchasing-program-vpp-token)

