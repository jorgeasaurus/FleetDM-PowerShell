---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#delete-google
schema: 2.0.0
---

# Remove-FleetGoogleConditionalAccess

## SYNOPSIS
Disconnects Fleet from Google and deletes the stored service account key.

## SYNTAX

```
Remove-FleetGoogleConditionalAccess [-Force] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Sends DELETE /api/v1/fleet/conditional_access/google.
Hosts already marked as managed in Google stay marked.

## EXAMPLES

### EXAMPLE 1
```
Remove-FleetGoogleConditionalAccess
```

## PARAMETERS

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

### FleetDM.RemovedGoogleConditionalAccess
## NOTES
This cmdlet requires Fleet Premium and a global admin or GitOps role.
Fleet Free responds with HTTP 402.
Fleet returns 502 and deletes nothing when fleetdm.com is unreachable.
https://fleetdm.com/docs/rest-api/rest-api#delete-google

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#delete-google](https://fleetdm.com/docs/rest-api/rest-api#delete-google)

