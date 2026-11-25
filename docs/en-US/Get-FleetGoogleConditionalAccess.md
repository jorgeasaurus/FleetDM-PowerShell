---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#get-google
schema: 2.0.0
---

# Get-FleetGoogleConditionalAccess

## SYNOPSIS
Gets the Google conditional access settings and connection state.

## SYNTAX

```
Get-FleetGoogleConditionalAccess [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/conditional_access/google.
The service account key is never returned;
service_account_key_configured says whether one is stored.
An empty state means Google is not configured.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetGoogleConditionalAccess | Select-Object customer_id, admin_email, state
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

### FleetDM.GoogleConditionalAccess
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#get-google

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#get-google](https://fleetdm.com/docs/rest-api/rest-api#get-google)

