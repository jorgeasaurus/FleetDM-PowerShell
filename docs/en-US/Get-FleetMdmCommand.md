---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-mdm-commands
schema: 2.0.0
---

# Get-FleetMdmCommand

## SYNOPSIS
Lists MDM commands, usually for one host.

## SYNTAX

```
Get-FleetMdmCommand [[-HostIdentifier] <String>] [[-RequestType] <String>] [[-CommandStatus] <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/commands and follows pagination.
Each result carries the command_uuid that Stop-FleetHostMdmCommand takes.
Fleet deprecates listing without host_identifier; that form may time out on large fleets.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetMdmCommand -HostIdentifier 'C02ABC123XYZ' -CommandStatus pending
```

### EXAMPLE 2
```
Get-FleetHost -Id 12 | Get-FleetMdmCommand -RequestType DeviceLock
```

## PARAMETERS

### -HostIdentifier
Host hostname, UUID, or hardware serial.
Binds from the hardware_serial property of piped hosts.

```yaml
Type: String
Parameter Sets: (All)
Aliases: hardware_serial

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -RequestType
MDM request type, such as DeviceLock or InstallProfile.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommandStatus
ran, pending, or failed.
Fleet applies it only with HostIdentifier on Apple and Android hosts.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
Requires MDM to be turned on in Fleet.
https://fleetdm.com/docs/rest-api/rest-api#list-mdm-commands

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-mdm-commands](https://fleetdm.com/docs/rest-api/rest-api#list-mdm-commands)

