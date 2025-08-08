---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/using-fleet/rest-api#list-hosts
schema: 2.0.0
---

# Get-FleetHost

## SYNOPSIS
Retrieves host information from FleetDM

## SYNTAX

### List (Default)
```
Get-FleetHost [-Status <String>] [-Hostname <String>] [-PolicyId <Int32>] [-SoftwareId <Int32>]
 [-OSName <String>] [-OSVersion <String>] [-IncludeSoftware] [-IncludePolicies] [-DisableFailingPolicies]
 [-DeviceMapping] [-MDMId <String>] [-MDMEnrollmentStatus <String>] [-MunkiIssueId <Int32>]
 [-LowDiskSpace <Int32>] [-Label <String>] [-Page <Int32>] [-PerPage <Int32>] [-OrderKey <String>]
 [-OrderDirection <String>] [-After <DateTime>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ById
```
Get-FleetHost -Id <Int32> [-IncludePolicies] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Gets one or more hosts from FleetDM with optional filtering by status, team, or hostname.
Supports retrieving a specific host by ID or searching for hosts based on various criteria.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetHost
```

Gets all hosts in FleetDM

### EXAMPLE 2
```
Get-FleetHost -Status online
```

Gets all online hosts

### EXAMPLE 3
```
Get-FleetHost -Id 123 -IncludeSoftware -IncludePolicies
```

Gets detailed information for host ID 123 including software and policies

### EXAMPLE 4
```
Get-FleetHost -OSName "macOS" -Status online | Select-Object id, hostname, primary_ip
```

Gets all online macOS hosts and displays their ID, hostname, and IP

## PARAMETERS

### -Id
The specific host ID to retrieve.
When specified, returns detailed information for a single host.

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

### -Status
Filter hosts by status: online, offline, or missing

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

### -Hostname
Search for hosts by hostname (partial match supported)

```yaml
Type: String
Parameter Sets: List
Aliases: Query

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PolicyId
Filter hosts by policy ID

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

### -SoftwareId
Filter hosts by software ID

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

### -OSName
Filter hosts by operating system name

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

### -OSVersion
Filter hosts by operating system version

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

### -IncludeSoftware
Include software inventory in the response.
This significantly increases response size.

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases: PopulateSoftware

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludePolicies
Include policy compliance information in the response

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: PopulatePolicies

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisableFailingPolicies
Filter to only show hosts with failing policies disabled

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

### -DeviceMapping
Include device mapping information

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

### -MDMId
Filter by MDM ID

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

### -MDMEnrollmentStatus
Filter by MDM enrollment status

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

### -MunkiIssueId
Filter by Munki issue ID

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

### -LowDiskSpace
Filter hosts with low disk space (less than specified GB)

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

### -Label
Filter by label name or ID

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

### -OrderKey
Field to sort by (hostname, created_at, updated_at)

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: Hostname
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

### -After
Return hosts added after this date

```yaml
Type: DateTime
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
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

[https://fleetdm.com/docs/using-fleet/rest-api#list-hosts](https://fleetdm.com/docs/using-fleet/rest-api#list-hosts)

