---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#uninstall-self-service-configuration-profile
schema: 2.0.0
---

# Uninstall-FleetConfigurationProfile

## SYNOPSIS
Removes a self-service configuration profile from a host.

## SYNTAX

```
Uninstall-FleetConfigurationProfile [-HostId] <Int32> [-ProfileUuid] <String>
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/hosts/{id}/configuration_profiles/{profile_uuid}/uninstall.
Fleet queues the removal for the next profile run.
The profile stays available for the host to install again.

## EXAMPLES

### EXAMPLE 1
```
Uninstall-FleetConfigurationProfile -HostId 233 -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24'
```

## PARAMETERS

### -HostId
Host ID.
Binds from the id property of piped hosts.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ProfileUuid
Self-service profile UUID.

```yaml
Type: String
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

### FleetDM.ProfileInstall
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
Fleet returns 404 when the host has not installed the profile.
https://fleetdm.com/docs/rest-api/rest-api#uninstall-self-service-configuration-profile

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#uninstall-self-service-configuration-profile](https://fleetdm.com/docs/rest-api/rest-api#uninstall-self-service-configuration-profile)

