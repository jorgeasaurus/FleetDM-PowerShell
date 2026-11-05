---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-configuration
schema: 2.0.0
---

# Set-FleetJitProvisioning

## SYNOPSIS
Enables or disables SSO just-in-time user provisioning.

## SYNTAX

```
Set-FleetJitProvisioning [-Enabled] <Boolean> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Reads GET /api/v1/fleet/config and sends PATCH /api/v1/fleet/config
with the existing sso_settings plus enable_jit_provisioning.
JIT provisioning is the Premium SSO control.
Basic SSO configuration is available in Fleet Free.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetJitProvisioning -Enabled $true
```

## PARAMETERS

### -Enabled
When true, Fleet creates users the first time they sign in with SSO.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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
enable_jit_provisioning requires Fleet Premium and returns HTTP 402 on Fleet Free.
https://fleetdm.com/docs/rest-api/rest-api#update-configuration
https://fleetdm.com/docs/deploy/single-sign-on-sso

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-configuration](https://fleetdm.com/docs/rest-api/rest-api#update-configuration)

