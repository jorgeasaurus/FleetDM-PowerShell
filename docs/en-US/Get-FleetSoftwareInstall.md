---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#get-software-install-result
schema: 2.0.0
---

# Get-FleetSoftwareInstall

## SYNOPSIS
Gets the result of a software package install.

## SYNTAX

```
Get-FleetSoftwareInstall [-InstallUuid] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/software/install/{install_uuid}/results.
Apple App Store install results are retrieved from MDM command endpoints instead.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetSoftwareInstall -InstallUuid "b15ce221-e22e-4c6a-afe7-5b3400a017da"
```

## PARAMETERS

### -InstallUuid
Install UUID returned when the install was queued.

```yaml
Type: String
Parameter Sets: (All)
Aliases: install_uuid

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#get-software-install-result

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#get-software-install-result](https://fleetdm.com/docs/rest-api/rest-api#get-software-install-result)

