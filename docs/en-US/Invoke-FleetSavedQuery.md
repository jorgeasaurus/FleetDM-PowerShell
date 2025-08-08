---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/using-fleet/rest-api#run-live-query
schema: 2.0.0
---

# Invoke-FleetSavedQuery

## SYNOPSIS
Executes a saved query and returns results immediately

## SYNTAX

```
Invoke-FleetSavedQuery [-QueryId] <Int32> [-HostId] <Int32[]> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Runs a saved FleetDM query against specified hosts and returns the results directly.
Unlike Invoke-FleetQuery which starts a campaign, this function waits for and returns results.

The query will stop if targeted hosts haven't responded within the configured timeout period.

## EXAMPLES

### EXAMPLE 1
```
Invoke-FleetSavedQuery -QueryId 42 -HostId 1,2,3
```

Runs saved query 42 on hosts 1, 2, and 3

### EXAMPLE 2
```
Get-FleetHost -Status online | Select-Object -ExpandProperty id | Invoke-FleetSavedQuery -QueryId 15
```

Runs saved query 15 on all online hosts

### EXAMPLE 3
```
$results = Invoke-FleetSavedQuery -QueryId 10 -HostId 5
$results.results | ForEach-Object { 
    Write-Host "Host $($_.host_id):"
    $_.rows | Format-Table
}
```

Runs query and formats results

## PARAMETERS

### -QueryId
The ID of the saved query to execute

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

### -HostId
Array of host IDs to run the query on.
Accepts pipeline input.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 2
Default value: None
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

## RELATED LINKS

[https://fleetdm.com/docs/using-fleet/rest-api#run-live-query](https://fleetdm.com/docs/using-fleet/rest-api#run-live-query)

