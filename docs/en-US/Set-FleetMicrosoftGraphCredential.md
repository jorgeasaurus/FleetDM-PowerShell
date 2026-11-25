---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#modify-microsoft-graph-credentials
schema: 2.0.0
---

# Set-FleetMicrosoftGraphCredential

## SYNOPSIS
Replaces the Microsoft Graph credential used for Windows Autopilot sync.

## SYNTAX

### Set (Default)
```
Set-FleetMicrosoftGraphCredential -TenantId <String> -ClientId <String> [-ClientSecret <SecureString>]
 [-DryRun] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Clear
```
Set-FleetMicrosoftGraphCredential [-DryRun] [-Clear] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Sends PUT /api/v1/fleet/microsoft_graph_credentials.
The request is declarative: the list sent
becomes the stored list, and a stored tenant that is not in it is deleted.
Fleet supports one credential.
Fleet checks a new or changed credential against Microsoft Graph before saving it.
-Clear sends an empty list, which deletes every stored credential.
client_secret is redacted in the verbose log.

## EXAMPLES

### EXAMPLE 1
```
$secret = Read-Host 'Client secret' -AsSecureString
Set-FleetMicrosoftGraphCredential -TenantId 'fec37e96-3615-4e37-8fac-445d5328af3c' -ClientId '8c8e3fd4-9b2c-4d3e-8f10-2233445566aa' -ClientSecret $secret -DryRun
```

### EXAMPLE 2
```
Set-FleetMicrosoftGraphCredential -Clear
```

## PARAMETERS

### -TenantId
Microsoft Entra tenant ID.

```yaml
Type: String
Parameter Sets: Set
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
Application (client) ID of the app registration.

```yaml
Type: String
Parameter Sets: Set
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
Client secret.
Required for a new credential or a changed tenant or client ID.
Omit it to keep the stored secret.

```yaml
Type: SecureString
Parameter Sets: Set
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DryRun
Validates the credential against Microsoft Graph without saving it.

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

### -Clear
Deletes every stored credential.

```yaml
Type: SwitchParameter
Parameter Sets: Clear
Aliases:

Required: True
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

### FleetDM.MicrosoftGraphCredentialUpdate
## NOTES
This cmdlet requires Fleet Premium and a global admin or GitOps role.
Fleet Free responds with HTTP 402.
Fleet returns 422 when an ID is not a GUID, a new credential has no secret, or Graph rejects it.
https://fleetdm.com/docs/rest-api/rest-api#modify-microsoft-graph-credentials

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#modify-microsoft-graph-credentials](https://fleetdm.com/docs/rest-api/rest-api#modify-microsoft-graph-credentials)

