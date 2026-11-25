---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#clear-host-passcode
schema: 2.0.0
---

# Clear-FleetHostPasscode

## SYNOPSIS
Clears the passcode on an iOS or iPadOS host.

## SYNTAX

```
Clear-FleetHostPasscode [-HostId] <Int32> [-Force] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/hosts/{id}/clear_passcode.
Fleet queues a ClearPasscode MDM command
and returns its command_uuid.
Cancel it before delivery with Stop-FleetHostMdmCommand.

## EXAMPLES

### EXAMPLE 1
```
Clear-FleetHostPasscode -HostId 123
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

### FleetDM.MdmCommand
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
The host must be ADE-enrolled and have sent its unlock token.
https://fleetdm.com/docs/rest-api/rest-api#clear-host-passcode

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#clear-host-passcode](https://fleetdm.com/docs/rest-api/rest-api#clear-host-passcode)

