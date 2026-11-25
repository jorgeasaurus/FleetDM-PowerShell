---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#delete-custom-mdm-setup-enrollment-profile
schema: 2.0.0
---

# Remove-FleetEnrollmentProfile

## SYNOPSIS
Deletes a fleet's custom automatic enrollment (ADE) profile.

## SYNTAX

```
Remove-FleetEnrollmentProfile [[-FleetId] <Int32>] [-Force] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends DELETE /api/v1/fleet/enrollment_profiles/automatic.
The fleet falls back to Fleet's default profile.

## EXAMPLES

### EXAMPLE 1
```
Remove-FleetEnrollmentProfile -FleetId 2
```

## PARAMETERS

### -FleetId
Fleet whose profile is deleted.
Omit it for "Unassigned".

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
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

### FleetDM.RemovedEnrollmentProfile
## NOTES
This cmdlet requires Fleet Premium and Apple MDM.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#delete-custom-mdm-setup-enrollment-profile

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#delete-custom-mdm-setup-enrollment-profile](https://fleetdm.com/docs/rest-api/rest-api#delete-custom-mdm-setup-enrollment-profile)

