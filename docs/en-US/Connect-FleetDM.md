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
Connect-FleetDM -BaseUri <String> -ApiToken <SecureString> [-SkipVersionCheck] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Credential
```
Connect-FleetDM -BaseUri <String> -Credential <PSCredential> [-SkipVersionCheck] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Email
```
Connect-FleetDM -BaseUri <String> -Email <String> -Password <SecureString> [-SkipVersionCheck] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Connects to a FleetDM instance using either an API token or email/password credentials.
The connection is stored at the module level and used by all other FleetDM cmdlets.

The token is checked with GET /api/v1/fleet/version, then GET /api/v1/fleet/me.
An API-only user can be limited to specific endpoints. If /version returns 403 and
/me succeeds, the connection is stored with Version set to $null. HTTP 401 is an
authentication failure. Other FleetDM cmdlets do not read the stored version.
Use -SkipVersionCheck to skip /version and require a successful /me call.

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

### EXAMPLE 4
```
$password = Read-Host "Password" -AsSecureString
Connect-FleetDM -BaseUri "https://fleet.example.com" -Email "admin@example.com" -Password $password
```

Logs in with email and password, the same call as fleetctl login --email --password

### EXAMPLE 5
```
$token = ConvertTo-SecureString "your-api-token" -AsPlainText -Force
Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $token -SkipVersionCheck
```

Connects when the token can call /me but is not allowed to call /version.
The connection version is $null.

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

### -Email
Fleet user email. Same value as fleetctl login --email.

```yaml
Type: String
Parameter Sets: Email
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
Fleet user password. Same value as fleetctl login --password.

```yaml
Type: SecureString
Parameter Sets: Email
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipVersionCheck
Do not call GET /api/v1/fleet/version. The token is checked with GET /api/v1/fleet/me,
and the stored version is $null. Use this when an API-only user is not allowed to call
the version endpoint.

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

## NOTES

## RELATED LINKS

[https://fleetdm.com/docs/using-fleet/rest-api#authentication](https://fleetdm.com/docs/using-fleet/rest-api#authentication)

