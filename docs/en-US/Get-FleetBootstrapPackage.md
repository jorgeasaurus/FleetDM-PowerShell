---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#get-bootstrap-package-metadata
schema: 2.0.0
---

# Get-FleetBootstrapPackage

## SYNOPSIS
Gets a fleet's bootstrap package metadata.

## SYNTAX

```
Get-FleetBootstrapPackage [-FleetId] <Int32> [-ForUpdate] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/bootstrap/{fleet_id}/metadata.
The response has the package name, sha256, and download token.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetBootstrapPackage -FleetId 0
```

## PARAMETERS

### -FleetId
Fleet ID.
Use 0 for "Unassigned".

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: fleet_id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ForUpdate
Authorizes the read as a write, for the GitOps role that cannot read.

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

### FleetDM.BootstrapPackage
## NOTES
This cmdlet requires Fleet Premium and Apple MDM.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#get-bootstrap-package-metadata

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#get-bootstrap-package-metadata](https://fleetdm.com/docs/rest-api/rest-api#get-bootstrap-package-metadata)

