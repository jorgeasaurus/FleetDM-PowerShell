---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/using-fleet/rest-api#list-software
schema: 2.0.0
---

# Get-FleetSoftware

## SYNOPSIS
Retrieves software inventory from FleetDM

## SYNTAX

### List (Default)
```
Get-FleetSoftware [-Name <String>] [-Version <String>] [-Cve <String>] [-VulnerableOnly] [-Page <Int32>]
 [-PerPage <Int32>] [-OrderKey <String>] [-OrderDirection <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### ById
```
Get-FleetSoftware -Id <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Gets software inventory information from FleetDM.
Can retrieve all software or filter by various criteria.
Software inventory includes installed applications, versions, and vulnerability information.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetSoftware
```

Gets all software inventory

### EXAMPLE 2
```
Get-FleetSoftware -Name "Chrome"
```

Gets all software with "Chrome" in the name

### EXAMPLE 3
```
Get-FleetSoftware -VulnerableOnly
```

Gets only software with known vulnerabilities

### EXAMPLE 4
```
Get-FleetSoftware -Cve "CVE-2023-1234"
```

Gets software affected by specific CVE

## PARAMETERS

### -Id
The specific software ID to retrieve

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
Filter software by name (partial match)

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

### -Version
Filter software by version

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

### -Cve
Filter software by CVE (Common Vulnerabilities and Exposures) ID

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

### -VulnerableOnly
Only return software with known vulnerabilities

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: False
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

### -OrderKey
Sort results by this field (name, hosts_count, cve_published, cve_resolved)

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

### -OrderDirection
Sort direction (asc or desc)

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: Asc
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

[https://fleetdm.com/docs/using-fleet/rest-api#list-software](https://fleetdm.com/docs/using-fleet/rest-api#list-software)

