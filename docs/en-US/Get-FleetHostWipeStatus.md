---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#wipe-host
schema: 2.0.0
---

# Get-FleetHostWipeStatus

## SYNOPSIS
Gets a host's lock and wipe status.

## SYNTAX

```
Get-FleetHostWipeStatus [-Id] <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads GET /api/v1/fleet/hosts/{id} and returns mdm.device_status and
mdm.pending_action.
Fleet documents this as the way to confirm a wipe.

device_status is unlocked, locked, locking, unlocking, wiped, or wiping.
pending_action is lock, unlock, wipe, or an empty string when nothing is pending.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetHostWipeStatus -Id 123
```

Shows whether host 123 is wiping, wiped, or has a wipe pending.

### EXAMPLE 2
```
Invoke-FleetHostWipe -Id 123 -Force
Get-FleetHostWipeStatus -Id 123
```

Queues a wipe and then reads the pending action.

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

### -ProgressAction
{{ Fill ProgressAction Description }}

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
The status fields are on the host MDM object.
https://fleetdm.com/docs/rest-api/rest-api#get-host
https://fleetdm.com/docs/rest-api/rest-api#wipe-host

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#wipe-host](https://fleetdm.com/docs/rest-api/rest-api#wipe-host)

