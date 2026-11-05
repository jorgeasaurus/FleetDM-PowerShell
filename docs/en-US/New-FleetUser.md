---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#create-user
schema: 2.0.0
---

# New-FleetUser

## SYNOPSIS
Creates a Fleet user.

## SYNTAX

```
New-FleetUser [-Name] <String> [-Email] <String> [-Password] <SecureString> [-ApiOnly] [[-GlobalRole] <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/users/admin.
This is the REST call behind fleetctl user create.
An API-only user response includes a token.
Fleet returns that token only when api_only is true.

## EXAMPLES

### EXAMPLE 1
```
$password = Read-Host "Password" -AsSecureString
New-FleetUser -Name "module-test" -Email "api@example.com" -Password $password -ApiOnly -GlobalRole admin
```

Creates a global admin API-only user and returns the user, including Token.

## PARAMETERS

### -Name
User name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Email
User email.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
User password.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiOnly
Creates an API-only user.
The user cannot sign in to the Fleet UI.

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

### -GlobalRole
Global role.
Allowed values are admin, maintainer, observer, observer_plus, and gitops.
Omit it to let Fleet assign observer.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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

[https://fleetdm.com/docs/rest-api/rest-api#create-user](https://fleetdm.com/docs/rest-api/rest-api#create-user)

