---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/using-fleet/rest-api#list-policies
schema: 2.0.0
---

# Get-FleetPolicy

## SYNOPSIS
Retrieves policies from FleetDM

## SYNTAX

### List (Default)
```
Get-FleetPolicy [-Name <String>] [-Page <Int32>] [-PerPage <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### ById
```
Get-FleetPolicy -Id <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Gets one or more policies from FleetDM.
Policies define compliance rules that are regularly checked on hosts.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetPolicy
```

Gets all global policies

### EXAMPLE 2
```
Get-FleetPolicy -Id 42
```

Gets the policy with ID 42

### EXAMPLE 3
```
Get-FleetPolicy -Name "encryption"
```

Gets all policies with "encryption" in the name

## PARAMETERS

### -Id
The specific policy ID to retrieve

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
Filter policies by name (partial match)

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

[https://fleetdm.com/docs/using-fleet/rest-api#list-policies](https://fleetdm.com/docs/using-fleet/rest-api#list-policies)

