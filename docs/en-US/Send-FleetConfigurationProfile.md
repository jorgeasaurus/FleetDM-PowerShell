---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#resend-configuration-profile
schema: 2.0.0
---

# Send-FleetConfigurationProfile

## SYNOPSIS
Resends a configuration profile to hosts.

## SYNTAX

### HostId (Default)
```
Send-FleetConfigurationProfile -ProfileUuid <String> -HostId <Int32[]> [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Filter
```
Send-FleetConfigurationProfile -ProfileUuid <String> -Filter <Hashtable> [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
With HostId, sends POST /api/v1/fleet/hosts/{id}/configuration_profiles/{profile_uuid}/resend for each host.
With Filter, sends POST /api/v1/fleet/configuration_profiles/resend/batch with profile_uuid and filters.
Fleet supports one batch filter, profile_status = 'failed'.

## EXAMPLES

### EXAMPLE 1
```
Send-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24' -HostId 233
```

### EXAMPLE 2
```
Send-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24' -Filter @{ profile_status = 'failed' }
```

## PARAMETERS

### -ProfileUuid
Profile UUID.

```yaml
Type: String
Parameter Sets: (All)
Aliases: profile_uuid

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostId
Hosts to resend to.
Binds from the id property of piped hosts.

```yaml
Type: Int32[]
Parameter Sets: HostId
Aliases: Id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Filter
Batch filter.
Fleet accepts @{ profile_status = 'failed' }.

```yaml
Type: Hashtable
Parameter Sets: Filter
Aliases:

Required: True
Position: Named
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

### FleetDM.ProfileResend
## NOTES
Requires an MDM-enrolled host.
Supports Apple .mobileconfig and Windows .xml profiles.
https://fleetdm.com/docs/rest-api/rest-api#resend-configuration-profile
https://fleetdm.com/docs/rest-api/rest-api#batch-resend-configuration-profile

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#resend-configuration-profile](https://fleetdm.com/docs/rest-api/rest-api#resend-configuration-profile)

