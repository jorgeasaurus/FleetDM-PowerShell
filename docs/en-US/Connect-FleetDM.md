---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/using-fleet/rest-api#authentication
schema: 2.0.0
---

# Connect-FleetDM

## SYNOPSIS
Establishes a connection to the FleetDM API

## SYNTAX

### Token (Default)
```
Connect-FleetDM -BaseUri <String> -ApiToken <SecureString> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Credential
```
Connect-FleetDM -BaseUri <String> -Credential <PSCredential> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Connects to a FleetDM instance using either an API token or email/password credentials.
The connection is stored at the module level and used by all other FleetDM cmdlets.

## EXAMPLES

### EXAMPLE 1
```
$token = ConvertTo-SecureString "your-api-token" -AsPlainText -Force
Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $token
```

Connects to FleetDM using an API token

### EXAMPLE 2
```
$cred = Get-Credential
Connect-FleetDM -BaseUri "https://fleet.example.com" -Credential $cred
```

Prompts for credentials and connects to FleetDM

### EXAMPLE 3
```
Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken (Read-Host -AsSecureString "Enter API Token")
```

Prompts for API token securely and connects to FleetDM

## PARAMETERS

### -BaseUri
The base URI of your FleetDM instance (e.g., https://fleet.example.com)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiToken
A secure string containing the FleetDM API token.
This is the preferred method for automation and API-only users.

```yaml
Type: SecureString
Parameter Sets: Token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
PSCredential object containing email and password for FleetDM authentication.
Use this for interactive sessions or when token authentication is not available.

```yaml
Type: PSCredential
Parameter Sets: Credential
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

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

## NOTES

## RELATED LINKS

[https://fleetdm.com/docs/using-fleet/rest-api#authentication](https://fleetdm.com/docs/using-fleet/rest-api#authentication)

