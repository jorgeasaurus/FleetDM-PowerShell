---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#create-bootstrap-package
schema: 2.0.0
---

# Set-FleetBootstrapPackage

## SYNOPSIS
Uploads a fleet's bootstrap package.

## SYNTAX

```
Set-FleetBootstrapPackage -FleetId <Int32> [-Path] <String> [-ManualAgentInstall]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/bootstrap as multipart/form-data with package, fleet_id, and manual_agent_install.
The package must be a signed .pkg.
It is streamed from disk through a temporary multipart file.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetBootstrapPackage -FleetId 1 -Path ./bootstrap.pkg
```

## PARAMETERS

### -FleetId
Fleet ID.
Use 0 for "Unassigned".

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Local signed .pkg file.

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

### -ManualAgentInstall
Skips installing fleetd during automatic enrollment.
The bootstrap package must install it.

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

### FleetDM.BootstrapPackage
## NOTES
This cmdlet requires Fleet Premium and Apple MDM.
Fleet Free responds with HTTP 402.
The request body limit is 10 GB.
https://fleetdm.com/docs/rest-api/rest-api#create-bootstrap-package

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#create-bootstrap-package](https://fleetdm.com/docs/rest-api/rest-api#create-bootstrap-package)

