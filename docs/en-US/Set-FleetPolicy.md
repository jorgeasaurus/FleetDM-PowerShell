---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/using-fleet/rest-api#modify-policy
schema: 2.0.0
---

# Set-FleetPolicy

## SYNOPSIS
Updates an existing policy in FleetDM

## SYNTAX

```
Set-FleetPolicy [-Id] <Int32> [[-Name] <String>] [[-Query] <String>] [[-Description] <String>]
 [[-Resolution] <String>] [[-Platform] <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Updates an existing policy in FleetDM.
You can update the name, query, description, resolution, and platform.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetPolicy -Id 123 -Name "Updated Policy Name"
```

Updates just the name of policy ID 123

### EXAMPLE 2
```
Set-FleetPolicy -Id 456 -Query "SELECT 1 FROM users WHERE username != 'root';" -Description "Ensures root account is disabled"
```

Updates the query and description for policy ID 456

### EXAMPLE 3
```
Get-FleetPolicy -Name "Old Name" | Set-FleetPolicy -Name "New Name"
```

Gets a policy by name and updates it to have a new name

### EXAMPLE 4
```
$updateParams = @{
    Id = 789
    Name = "Comprehensive Update"
    Query = "SELECT 1 FROM system_info WHERE version >= '11.0';"
    Description = "Ensures minimum OS version"
    Resolution = "Update to macOS 11.0 or higher"
    Platform = "darwin"
}
Set-FleetPolicy @updateParams
```

Updates multiple properties of a policy using splatting

## PARAMETERS

### -Id
The ID of the policy to update

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Name
The new name for the policy

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
The new SQL query that defines the policy

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

### -Description
The new description of what the policy checks

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

### -Resolution
The new resolution steps for when the policy fails

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Platform
The new platform filter for the policy (windows, linux, darwin, chrome, all)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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

[https://fleetdm.com/docs/using-fleet/rest-api#modify-policy](https://fleetdm.com/docs/using-fleet/rest-api#modify-policy)

