---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-microsoft-graph-credentials
schema: 2.0.0
---

# Get-FleetMicrosoftGraphCredential

## SYNOPSIS
Lists the Microsoft Graph credentials used for Windows Autopilot sync.

## SYNTAX

```
Get-FleetMicrosoftGraphCredential [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/microsoft_graph_credentials.
Client secrets are write-only and never returned.
credential_invalid is true when Entra or Graph rejected the credential.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetMicrosoftGraphCredential | Select-Object tenant_id, client_id, credential_invalid, last_synced_at
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

### FleetDM.MicrosoftGraphCredential
## NOTES
This cmdlet requires Fleet Premium and a global admin or GitOps role.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#list-microsoft-graph-credentials

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-microsoft-graph-credentials](https://fleetdm.com/docs/rest-api/rest-api#list-microsoft-graph-credentials)

