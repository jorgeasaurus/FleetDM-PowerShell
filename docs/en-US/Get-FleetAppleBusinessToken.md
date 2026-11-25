---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-apple-business-ab-tokens
schema: 2.0.0
---

# Get-FleetAppleBusinessToken

## SYNOPSIS
Lists Apple Business (AB) tokens.

## SYNTAX

```
Get-FleetAppleBusinessToken [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/ab_tokens.
Fleet 4.96 returns the list as ab_tokens and the older abm_tokens shape.
ab_tokens is read when present.
Older servers only send abm_tokens.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetAppleBusinessToken | Select-Object org_name, renew_date, terms_expired
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

### FleetDM.AppleBusinessToken
## NOTES
This cmdlet requires Fleet Premium and a global admin or GitOps role.
Fleet Free responds with HTTP 402.
Fleet documents no route to add, renew, or delete an AB token.
https://fleetdm.com/docs/rest-api/rest-api#list-apple-business-ab-tokens

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-apple-business-ab-tokens](https://fleetdm.com/docs/rest-api/rest-api#list-apple-business-ab-tokens)

