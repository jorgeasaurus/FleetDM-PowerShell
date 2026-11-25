---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-software
schema: 2.0.0
---

# Get-FleetSoftwareTitle

## SYNOPSIS
Lists software titles or gets one title.

## SYNTAX

### List (Default)
```
Get-FleetSoftwareTitle [-FleetId <Int32>] [-Query <String>] [-AvailableForInstall] [-SelfService]
 [-PackagesOnly] [-Platform <String[]>] [-Page <Int32>] [-PerPage <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### ById
```
Get-FleetSoftwareTitle -Id <Int32> [-FleetId <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/software/titles or GET /api/v1/fleet/software/titles/{id}.
Title IDs are what the package, App Store, and install cmdlets take.
Get-FleetSoftware -Id reads software versions, whose IDs differ.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetSoftwareTitle -FleetId 2 -AvailableForInstall
```

### EXAMPLE 2
```
Get-FleetSoftwareTitle -Id 2792 -FleetId 2
```

### EXAMPLE 3
```
Get-FleetSoftwareTitle -FleetId 2 -PackagesOnly -Platform darwin, windows
```

## PARAMETERS

### -Id
Software title ID.
Binds from the software_title_id property.

```yaml
Type: Int32
Parameter Sets: ById
Aliases: software_title_id

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FleetId
Fleet Premium.
Limits the list or the title details to this fleet.
Use 0 for "Unassigned".

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
Searches title names and CVEs.

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

### -AvailableForInstall
Lists only titles with an installer, App Store app, or Fleet-maintained app added.

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

### -SelfService
Lists only self-service titles.

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

### -PackagesOnly
Fleet Premium.
Lists only uploaded packages, without App Store apps.

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

### -Platform
Lists titles available for install on these platforms.
Requires FleetId.

```yaml
Type: String[]
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Page
Page number.
When omitted, every page is retrieved.

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
Page size.
The default is 100.

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

### FleetDM.SoftwareTitle
## NOTES
FleetId and PackagesOnly require Fleet Premium.
https://fleetdm.com/docs/rest-api/rest-api#list-software

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-software](https://fleetdm.com/docs/rest-api/rest-api#list-software)

