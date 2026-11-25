---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#cancel-hosts-pending-mdm-command
schema: 2.0.0
---

# Stop-FleetHostMdmCommand

## SYNOPSIS
Cancels a pending lock, wipe, clear passcode, or lost mode command on an Apple host.

## SYNTAX

```
Stop-FleetHostMdmCommand [-HostId] <Int32> [-CommandUuid] <String> [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends DELETE /api/v1/fleet/hosts/{id}/commands/{command_uuid}.
Fleet cancels only DeviceLock, EraseDevice, ClearPasscode, and EnableLostMode commands
that have not been delivered.

## EXAMPLES

### EXAMPLE 1
```
Stop-FleetHostMdmCommand -HostId 12 -CommandUuid '81e10a70-730b-4c45-9b40-b14373e04757'
```

### EXAMPLE 2
```
Clear-FleetHostPasscode -HostId 12 -Force | Stop-FleetHostMdmCommand -HostId 12 -Confirm:$false
```

## PARAMETERS

### -HostId
Host ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommandUuid
Command UUID.
Binds from the command_uuid property of Get-FleetMdmCommand or Clear-FleetHostPasscode output.

```yaml
Type: String
Parameter Sets: (All)
Aliases: command_uuid

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### FleetDM.CanceledMdmCommand
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
Fleet returns 400 when the command was already delivered or is not a cancelable type.
https://fleetdm.com/docs/rest-api/rest-api#cancel-hosts-pending-mdm-command

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#cancel-hosts-pending-mdm-command](https://fleetdm.com/docs/rest-api/rest-api#cancel-hosts-pending-mdm-command)

