---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/using-fleet/rest-api#create-policy
schema: 2.0.0
---

# New-FleetPolicy

## SYNOPSIS
Creates a new policy in FleetDM

## SYNTAX

```
New-FleetPolicy [-Name] <String> [-Query] <String> [[-Description] <String>] [[-Resolution] <String>]
 [[-Platform] <String>] [[-FleetId] <Int32>] [-Critical] [[-CalendarEventsEnabled] <Boolean>]
 [[-SoftwareTitleId] <Int32>] [[-ScriptId] <Int32>] [[-LabelIncludeAny] <String[]>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new policy in FleetDM.
Policies are compliance rules that are regularly checked on hosts.

## EXAMPLES

### EXAMPLE 1
```
New-FleetPolicy -Name "Firewall Enabled" -Query "SELECT 1 FROM windows_firewall WHERE enabled = 1;"
```

Creates a basic policy to check if Windows Firewall is enabled

### EXAMPLE 2
```
$params = @{
    Name = "FileVault Enabled"
    Query = "SELECT 1 FROM filevault_status WHERE status = 'on';"
    Description = "Ensures FileVault disk encryption is enabled"
    Resolution = "Enable FileVault in System Preferences > Security & Privacy"
    Platform = "darwin"
}
New-FleetPolicy @params
```

Creates a comprehensive macOS policy with all details

### EXAMPLE 3
```
Import-Csv policies.csv | ForEach-Object {
    New-FleetPolicy -Name $_.Name -Query $_.Query -Description $_.Description
}
```

Bulk creates policies from a CSV file

## PARAMETERS

### -Name
The name of the policy

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
The SQL query that defines the policy check.
Should return 1 row for compliant hosts.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
A description of what the policy checks

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Resolution
Steps to resolve the issue when the policy fails

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Platform
The platform this policy applies to (windows, linux, darwin, chrome, or all)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -FleetId
Fleet Premium. Creates the policy on this fleet instead of as a global policy.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Critical
Fleet Premium. Marks the policy as critical.

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

### -CalendarEventsEnabled
Fleet Premium. Enables calendar maintenance events when this fleet policy fails. Requires FleetId.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SoftwareTitleId
Fleet Premium. Installs this software title when the fleet policy fails. Requires FleetId.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptId
Fleet Premium. Runs this script when the fleet policy fails. Requires FleetId.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -LabelIncludeAny
Fleet Premium. Hosts must match one of these label names.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
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

## NOTES

## RELATED LINKS

[https://fleetdm.com/docs/using-fleet/rest-api#create-policy](https://fleetdm.com/docs/using-fleet/rest-api#create-policy)

