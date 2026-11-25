---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#get-custom-mdm-setup-enrollment-profile
schema: 2.0.0
---

# Get-FleetEnrollmentProfile

## SYNOPSIS
Gets the custom automatic enrollment (ADE) profile, or Fleet's default one.

## SYNTAX

### Custom (Default)
```
Get-FleetEnrollmentProfile [-FleetId <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Default
```
Get-FleetEnrollmentProfile [-Default] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/enrollment_profiles/automatic, or GET /api/v1/fleet/enrollment_profiles/automatic/default with -Default.
The default profile is shared by every fleet and Apple Business token.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetEnrollmentProfile -FleetId 2
```

### EXAMPLE 2
```
Get-FleetEnrollmentProfile -Default
```

## PARAMETERS

### -FleetId
Fleet whose custom profile is read.
Omit it for "Unassigned".

```yaml
Type: Int32
Parameter Sets: Custom
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Default
Reads Fleet's default enrollment profile.

```yaml
Type: SwitchParameter
Parameter Sets: Default
Aliases:

Required: True
Position: Named
Default value: False
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
https://fleetdm.com/docs/rest-api/rest-api#get-custom-mdm-setup-enrollment-profile

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#get-custom-mdm-setup-enrollment-profile](https://fleetdm.com/docs/rest-api/rest-api#get-custom-mdm-setup-enrollment-profile)

