---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-batch-scripts
schema: 2.0.0
---

# Get-FleetScriptBatch

## SYNOPSIS
Lists batch script runs, gets one, or lists its hosts.

## SYNTAX

### List (Default)
```
Get-FleetScriptBatch [-FleetId <Int32>] [-Status <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### HostResults
```
Get-FleetScriptBatch -BatchExecutionId <String> [-HostResults] -HostStatus <String>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ById
```
Get-FleetScriptBatch -BatchExecutionId <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/scripts/batch, GET /api/v1/fleet/scripts/batch/{batch_execution_id},
or GET /api/v1/fleet/scripts/batch/{batch_execution_id}/host_results.
Fleet 4.96 requires fleet_id on the list route.
FleetId defaults to 0, which is "Unassigned".

## EXAMPLES

### EXAMPLE 1
```
Get-FleetScriptBatch -FleetId 2 -Status finished
```

### EXAMPLE 2
```
Start-FleetScriptBatch -ScriptId 4 -HostId 10, 11 -Confirm:$false | Get-FleetScriptBatch
```

### EXAMPLE 3
```
Get-FleetScriptBatch -BatchExecutionId 'e797d6c6-3aae-11ee-be56-0242ac120002' -HostResults -HostStatus errored
```

## PARAMETERS

### -FleetId
Fleet whose batch runs are listed.
Use 0 for "Unassigned".
Values other than 0 require Fleet Premium.

```yaml
Type: Int32
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status
Lists batch runs with this status: started, scheduled, or finished.

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BatchExecutionId
Batch execution ID from Start-FleetScriptBatch.
Binds from the batch_execution_id property.

```yaml
Type: String
Parameter Sets: HostResults, ById
Aliases: batch_execution_id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -HostResults
Lists the hosts targeted by the batch instead of the batch summary.
Requires HostStatus.

```yaml
Type: SwitchParameter
Parameter Sets: HostResults
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostStatus
Host script status to list: ran, pending, errored, incompatible, or canceled.
Fleet requires one.

```yaml
Type: String
Parameter Sets: HostResults
Aliases:

Required: True
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
### FleetDM.ScriptBatchHost
## NOTES
FleetId other than 0 requires Fleet Premium.
https://fleetdm.com/docs/rest-api/rest-api#list-batch-scripts

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-batch-scripts](https://fleetdm.com/docs/rest-api/rest-api#list-batch-scripts)

