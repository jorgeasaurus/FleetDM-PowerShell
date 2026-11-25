---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#delete-eula
schema: 2.0.0
---

# Remove-FleetEula

## SYNOPSIS
Deletes the setup EULA.

## SYNTAX

### Platform (Default)
```
Remove-FleetEula [-Platform <String>] [-Force] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Token
```
Remove-FleetEula -Token <String> [-Force] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Sends DELETE /api/v1/fleet/setup_experience/eula/{token}.
Without Token, the token is read from GET /api/v1/fleet/setup_experience/eula/metadata first.
The lookup runs only after confirmation, so -WhatIf sends nothing.

## EXAMPLES

### EXAMPLE 1
```
Remove-FleetEula -Platform windows
```

### EXAMPLE 2
```
Get-FleetEula | Remove-FleetEula -Force
```

## PARAMETERS

### -Platform
darwin or windows.
Used to look up the token.
Fleet defaults to darwin.

```yaml
Type: String
Parameter Sets: Platform
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Token
EULA token.
Binds from the token property of Get-FleetEula output.

```yaml
Type: String
Parameter Sets: Token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### FleetDM.RemovedEula
## NOTES
This cmdlet requires Fleet Premium and a global admin or GitOps role.
https://fleetdm.com/docs/rest-api/rest-api#delete-eula

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#delete-eula](https://fleetdm.com/docs/rest-api/rest-api#delete-eula)

