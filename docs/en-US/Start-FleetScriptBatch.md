---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#batch-run-script
schema: 2.0.0
---

# Start-FleetScriptBatch

## SYNOPSIS
Runs a saved script on many hosts.

## SYNTAX

### HostId (Default)
```
Start-FleetScriptBatch -ScriptId <Int32> -HostId <Int32[]> [-NotBefore <DateTime>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Filter
```
Start-FleetScriptBatch -ScriptId <Int32> -Filter <Hashtable> [-NotBefore <DateTime>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/scripts/run/batch with script_id and either host_ids or filters.
Host IDs piped in are collected and sent in one batch.
A filter must name at least one of query, status, label_id, or fleet_id.
An empty filter would match every host, so it is rejected.
Piping no hosts throws and sends nothing.
An empty host_ids list is not a way to target no one.

## EXAMPLES

### EXAMPLE 1
```
Start-FleetScriptBatch -ScriptId 4 -HostId 10, 11, 12
```

### EXAMPLE 2
```
Start-FleetScriptBatch -ScriptId 4 -Filter @{ label_id = 7; status = 'online' } -NotBefore (Get-Date).AddHours(2)
```

### EXAMPLE 3
```
Get-FleetHost -Status online | Where-Object platform -eq 'darwin' | Start-FleetScriptBatch -ScriptId 4 -Confirm:$false
```

## PARAMETERS

### -ScriptId
Saved script ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostId
Host IDs to target.
Binds from the id property of piped hosts.

```yaml
Type: Int32[]
Parameter Sets: HostId
Aliases: Id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Filter
Host filter with any of query, status, label_id, and fleet_id.
Fleet targets the hosts that match when the batch is created.

```yaml
Type: Hashtable
Parameter Sets: Filter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NotBefore
Schedules the batch.
Sent to Fleet as UTC.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
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

### FleetDM.ScriptBatch
## NOTES
Hosts without fleetd and scripts enabled count as errored or incompatible in the batch.
https://fleetdm.com/docs/rest-api/rest-api#batch-run-script

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#batch-run-script](https://fleetdm.com/docs/rest-api/rest-api#batch-run-script)

