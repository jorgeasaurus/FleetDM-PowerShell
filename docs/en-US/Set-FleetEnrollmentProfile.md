---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-custom-mdm-setup-enrollment-profile
schema: 2.0.0
---

# Set-FleetEnrollmentProfile

## SYNOPSIS
Sets the custom automatic enrollment (ADE) profile for a fleet.

## SYNTAX

```
Set-FleetEnrollmentProfile [-Path] <String> [-FleetId <Int32>] [-Name <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/enrollment_profiles/automatic with fleet_id, name, and enrollment_profile.
The file is Apple's enrollment profile JSON.
Fleet fills in ConfigurationWebURL and URL.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetEnrollmentProfile -FleetId 2 -Path ./dep_profile.json
```

## PARAMETERS

### -Path
Local enrollment profile JSON file.

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

### -FleetId
Fleet that uses the profile.
Omit it for "Unassigned".

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name stored with the profile.
The default is the file name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

### FleetDM.EnrollmentProfile
## NOTES
This cmdlet requires Fleet Premium and Apple MDM.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#update-custom-mdm-setup-enrollment-profile

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-custom-mdm-setup-enrollment-profile](https://fleetdm.com/docs/rest-api/rest-api#update-custom-mdm-setup-enrollment-profile)

