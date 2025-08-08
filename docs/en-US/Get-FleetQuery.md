---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/using-fleet/rest-api#list-queries
schema: 2.0.0
---

# Get-FleetQuery

## SYNOPSIS
Retrieves saved queries from FleetDM

## SYNTAX

### List (Default)
```
Get-FleetQuery [-Name <String>] [-Page <Int32>] [-PerPage <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### ById
```
Get-FleetQuery -Id <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Gets one or more saved queries from FleetDM with optional filtering.
Use this to find query IDs for use with Invoke-FleetQuery or Invoke-FleetSavedQuery.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetQuery
```

Gets all saved queries

### EXAMPLE 2
```
Get-FleetQuery -Name "users"
```

Gets all queries with "users" in the name

### EXAMPLE 3
```
Get-FleetQuery -Id 42
```

Gets details for query ID 42

### EXAMPLE 4
```
Get-FleetQuery | Where-Object { $_.query -like "*chrome*" } | Format-Table id, name, query -Wrap
```

Lists all queries that reference Chrome

## PARAMETERS

### -Id
The specific query ID to retrieve

```yaml
Type: Int32
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Name
Filter queries by name (partial match)

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

### -Page
Page number for pagination (0-based)

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

### -PerPage
Number of results per page (default: 100)

```yaml
Type: Int32
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: 100
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

[https://fleetdm.com/docs/using-fleet/rest-api#list-queries](https://fleetdm.com/docs/using-fleet/rest-api#list-queries)

