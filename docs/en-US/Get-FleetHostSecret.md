---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#get-hosts-disk-encryption-key
schema: 2.0.0
---

# Get-FleetHostSecret

## SYNOPSIS
Reads a host's disk encryption key, Recovery Lock password, or managed account password.

## SYNTAX

```
Get-FleetHostSecret [-HostId] <Int32> [-Type] <String> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/hosts/{id}/encryption_key, /recovery_lock_password, or /managed_account_password.
Returns the secret in plain text in the Secret property.
The value is never written to the verbose log.
Fleet returns a value only after the host escrowed it and Fleet verified it.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetHostSecret -HostId 8 -Type DiskEncryptionKey
```

### EXAMPLE 2
```
Get-FleetHost -Id 8 | Get-FleetHostSecret -Type RecoveryLockPassword | Select-Object HostId, UpdatedAt
```

## PARAMETERS

### -HostId
Host ID.
Binds from the id property of piped hosts.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Type
DiskEncryptionKey (FileVault or BitLocker), RecoveryLockPassword (Apple silicon Macs), or ManagedAccountPassword (macOS and Windows).

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

### FleetDM.HostSecret
## NOTES
Requires an MDM-enrolled host with an escrowed secret.
Fleet answers 404 or 422 otherwise.
Treat the output as a credential.
Transcripts record what the console shows.
https://fleetdm.com/docs/rest-api/rest-api#get-hosts-disk-encryption-key

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#get-hosts-disk-encryption-key](https://fleetdm.com/docs/rest-api/rest-api#get-hosts-disk-encryption-key)

