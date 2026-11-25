---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#connect-google
schema: 2.0.0
---

# Set-FleetGoogleConditionalAccess

## SYNOPSIS
Connects Fleet to Google for conditional access, or updates the connection.

## SYNTAX

### Update (Default)
```
Set-FleetGoogleConditionalAccess [-CustomerId <String>] [-AdminEmail <String>]
 [-ServiceAccountKeyPath <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Connect
```
Set-FleetGoogleConditionalAccess [-Connect] -CustomerId <String> -AdminEmail <String>
 -ServiceAccountKeyPath <String> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
With -Connect, sends POST /api/v1/fleet/conditional_access/google with customer_id, admin_email,
and service_account_key.
That replaces any stored settings and key.
Without -Connect, sends PATCH /api/v1/fleet/conditional_access/google with only the supplied fields.
A PATCH with no fields retries a connection that did not complete.

The key file is read as JSON.
service_account_key, private_key, and client_secret are redacted in the verbose log.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetGoogleConditionalAccess -Connect -CustomerId 'C01234abc' -AdminEmail 'fleet-admin@example.com' -ServiceAccountKeyPath ./key.json
```

### EXAMPLE 2
```
Set-FleetGoogleConditionalAccess -AdminEmail 'new-admin@example.com'
```

### EXAMPLE 3
```
Set-FleetGoogleConditionalAccess
```

Retries a connection that did not complete.

## PARAMETERS

### -Connect
Sends a full connect request.
CustomerId, AdminEmail, and ServiceAccountKeyPath are required.

```yaml
Type: SwitchParameter
Parameter Sets: Connect
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomerId
Google customer ID with its leading C, for example C01234abc.

```yaml
Type: String
Parameter Sets: Update
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: Connect
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdminEmail
Google Workspace admin that Fleet acts as.

```yaml
Type: String
Parameter Sets: Update
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: Connect
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceAccountKeyPath
Service account JSON key file with domain-wide delegation for the cloud-identity.devices scope.

```yaml
Type: String
Parameter Sets: Update
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: Connect
Aliases:

Required: True
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

### FleetDM.GoogleConditionalAccess
## NOTES
This cmdlet requires Fleet Premium and a global admin or GitOps role.
Fleet Free responds with HTTP 402.
Fleet returns 422 with Google's reason when Google refuses the service account.
https://fleetdm.com/docs/rest-api/rest-api#connect-google

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#connect-google](https://fleetdm.com/docs/rest-api/rest-api#connect-google)

