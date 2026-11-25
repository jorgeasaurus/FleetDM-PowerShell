---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#delete-configuration-profile
schema: 2.0.0
---

# Remove-FleetConfigurationProfile

## SYNOPSIS
Deletes a configuration profile.

## SYNTAX

```
Remove-FleetConfigurationProfile [-ProfileUuid] <String> [-Force] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends DELETE /api/v1/fleet/configuration_profiles/{profile_uuid}.
Fleet sends a remove command to Apple hosts.
Some Windows settings stay at their last value;
Fleet's warning text is written to the warning stream.

## EXAMPLES

### EXAMPLE 1
```
Remove-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24'
```

### EXAMPLE 2
```
Get-FleetConfigurationProfile -FleetId 2 | Where-Object name -like 'Test*' | Remove-FleetConfigurationProfile -Force
```

## PARAMETERS

### -ProfileUuid
Profile UUID.
Binds from the profile_uuid property.

```yaml
Type: String
Parameter Sets: (All)
Aliases: profile_uuid

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Force
Skips the confirmation prompt.
-WhatIf is still honored.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
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

### FleetDM.RemovedConfigurationProfile
## NOTES
Requires MDM to be turned on in Fleet.
https://fleetdm.com/docs/rest-api/rest-api#delete-configuration-profile

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#delete-configuration-profile](https://fleetdm.com/docs/rest-api/rest-api#delete-configuration-profile)

