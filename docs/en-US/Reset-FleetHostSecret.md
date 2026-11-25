---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#rotate-hosts-disk-encryption-key
schema: 2.0.0
---

# Reset-FleetHostSecret

## SYNOPSIS
Rotates a host's disk encryption key, Recovery Lock password, or managed account password.

## SYNTAX

```
Reset-FleetHostSecret [-HostId] <Int32> [-Type] <String> [-Force] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/hosts/{id}/encryption_key/rotate, /recovery_lock_password/rotate,
or /managed_account_password/rotate.
Fleet sends an MDM command and escrows the new value
when the host acknowledges it.
Read the new value later with Get-FleetHostSecret.

## EXAMPLES

### EXAMPLE 1
```
Reset-FleetHostSecret -HostId 8 -Type RecoveryLockPassword
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
DiskEncryptionKey (macOS FileVault), RecoveryLockPassword, or ManagedAccountPassword.

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

### FleetDM.HostSecretRotation
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
Fleet returns 409 while a disk encryption key rotation is already pending.
https://fleetdm.com/docs/rest-api/rest-api#rotate-hosts-disk-encryption-key

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#rotate-hosts-disk-encryption-key](https://fleetdm.com/docs/rest-api/rest-api#rotate-hosts-disk-encryption-key)

