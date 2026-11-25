---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#get-script-result
schema: 2.0.0
---

# Get-FleetScriptResult

## SYNOPSIS
Gets the result of a script run.

## SYNTAX

```
Get-FleetScriptResult [-ExecutionId] <String> [-Wait] [[-TimeoutSeconds] <Int32>]
 [[-PollIntervalSeconds] <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/scripts/results/{execution_id}.
exit_code is null until the host reports back.
-Wait polls until
exit_code is set and throws when TimeoutSeconds passes first.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetScriptResult -ExecutionId 'e797d6c6-3aae-11ee-be56-0242ac120002'
```

### EXAMPLE 2
```
Invoke-FleetScript -HostId 10 -ScriptId 4 -Confirm:$false | Get-FleetScriptResult -Wait -TimeoutSeconds 120
```

## PARAMETERS

### -ExecutionId
Execution ID returned by Invoke-FleetScript.
Binds from the execution_id property.

```yaml
Type: String
Parameter Sets: (All)
Aliases: execution_id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Wait
Polls until the host reports an exit code.

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

### -TimeoutSeconds
How long -Wait polls before it throws.
The default is 300.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 300
Accept pipeline input: False
Accept wildcard characters: False
```

### -PollIntervalSeconds
Seconds between polls with -Wait.
The default is 5.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 5
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

### FleetDM.ScriptResult
## NOTES
A script runs only on a host with fleetd and scripts enabled.
Otherwise Invoke-FleetScript returns HTTP 422.
https://fleetdm.com/docs/rest-api/rest-api#get-script-result

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#get-script-result](https://fleetdm.com/docs/rest-api/rest-api#get-script-result)

