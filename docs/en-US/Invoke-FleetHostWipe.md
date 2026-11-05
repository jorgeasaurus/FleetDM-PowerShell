---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#wipe-host
schema: 2.0.0
---

# Invoke-FleetHostWipe

## SYNOPSIS
Wipes a Fleet host.

## SYNTAX

```
Invoke-FleetHostWipe [-Id] <Int32> [[-WindowsWipeType] <String>] [-Force] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/hosts/{id}/wipe.
The host is wiped when it next
comes online.

macOS, iOS, iPadOS, and Windows hosts must have MDM turned on.
Linux hosts
must have scripts enabled.
Android hosts must be enrolled as a fully
managed device.

For Windows, -WindowsWipeType selects the remote wipe.
Omit it to let Fleet
apply its server default, which is doWipeProtected.

## EXAMPLES

### EXAMPLE 1
```
Invoke-FleetHostWipe -Id 123
```

Queues a wipe for host 123.

### EXAMPLE 2
```
Invoke-FleetHostWipe -Id 45 -WindowsWipeType doWipe -Force
```

Queues a Windows doWipe without a confirmation prompt.

## PARAMETERS

### -Id
Host ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: HostId

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -WindowsWipeType
Windows wipe type.
Allowed values are doWipe and doWipeProtected.
Sent as { "windows": { "wipe_type": "\<value\>" } }.

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

## NOTES
Company-owned (fully managed) Android wipe is available in Fleet Free and Fleet Premium.
Wiping macOS, Windows, iOS, iPadOS, Linux, or a personal (BYOD) Android host requires Fleet Premium.
Fleet Free responds with HTTP 402, or HTTP 403 when the body mentions a Premium license.
Both are reported as a Fleet Premium error.
https://fleetdm.com/docs/rest-api/rest-api#wipe-host

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#wipe-host](https://fleetdm.com/docs/rest-api/rest-api#wipe-host)

