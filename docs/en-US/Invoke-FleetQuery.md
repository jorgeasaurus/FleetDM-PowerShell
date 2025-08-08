---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/using-fleet/rest-api#run-live-query
schema: 2.0.0
---

# Invoke-FleetQuery

## SYNOPSIS
Executes a live query on FleetDM hosts

## SYNTAX

### Query (Default)
```
Invoke-FleetQuery -Query <String> [-HostId <Int32[]>] [-Label <String[]>] [-All] [-Wait] [-MaxWaitTime <Int32>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### QueryId
```
Invoke-FleetQuery -QueryId <Int32> [-HostId <Int32[]>] [-Label <String[]>] [-All] [-Wait]
 [-MaxWaitTime <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Runs an osquery SQL statement on specified hosts and returns the results.
For ad-hoc queries, automatically creates a temporary saved query, runs it,
retrieves the results, and cleans up.
This provides actual query results
instead of just campaign information.

## EXAMPLES

### EXAMPLE 1
```
$results = Invoke-FleetQuery -Query "SELECT * FROM system_info;" -HostId 1,2,3
$results.Results | Format-Table
```

Runs a system info query on specific hosts and returns the actual results

### EXAMPLE 2
```
$hosts = Get-FleetHost -Status online
$results = $hosts | Invoke-FleetQuery -Query "SELECT * FROM users WHERE uid = '501';"
```

Gets all online hosts and runs a query to find user with UID 501, returning results

### EXAMPLE 3
```
Invoke-FleetQuery -Query "SELECT * FROM processes WHERE name = 'chrome';" -Label "production"
```

Runs a query on all hosts with the "production" label (returns campaign info only)

### EXAMPLE 4
```
Invoke-FleetQuery -QueryId 42 -HostId 100,101,102 -Wait
```

Executes saved query #42 on specific hosts and waits for results

### EXAMPLE 5
```
@(1,2,3,4,5) | Invoke-FleetQuery -Query "SELECT * FROM os_version;"
```

Pipes host IDs to run OS version query

## PARAMETERS

### -Query
The SQL query to execute.
This should be a valid osquery SQL statement.

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -QueryId
The ID of a saved query to execute (alternative to providing Query text)

```yaml
Type: Int32
Parameter Sets: QueryId
Aliases:

Required: True
Position: Named
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

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Label
Array of label names to run the query on all hosts with those labels

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
Run the query on all hosts in the fleet (not supported by FleetDM API for ad-hoc queries)

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

### -Wait
For saved queries (QueryId), returns results directly instead of starting a campaign.
This parameter is deprecated for ad-hoc queries as they now always return results.

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

### -MaxWaitTime
Maximum time to wait for results in seconds (default: 25)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 25
Accept pipeline input: False
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

