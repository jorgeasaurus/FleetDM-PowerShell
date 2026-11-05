---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#get-disk-encryption-status
schema: 2.0.0
---

# Get-FleetDiskEncryption

## SYNOPSIS
Gets aggregate disk encryption status.

## SYNTAX

```
Get-FleetDiskEncryption [[-FleetId] <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/disk_encryption.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetDiskEncryption -FleetId 1
```

## PARAMETERS

### -FleetId
Optional fleet filter.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
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
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#get-disk-encryption-status

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#get-disk-encryption-status](https://fleetdm.com/docs/rest-api/rest-api#get-disk-encryption-status)

