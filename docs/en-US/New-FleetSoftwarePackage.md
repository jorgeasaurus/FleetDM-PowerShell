---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#add-package
schema: 2.0.0
---

# New-FleetSoftwarePackage

## SYNOPSIS
Uploads a software installer to a fleet.

## SYNTAX

```
New-FleetSoftwarePackage [-Path] <String> -FleetId <Int32> [-InstallScript <String>]
 [-UninstallScript <String>] [-PreInstallQuery <String>] [-PostInstallScript <String>] [-SelfService]
 [-AutomaticInstall] [-LabelsIncludeAll <String[]>] [-LabelsIncludeAny <String[]>]
 [-LabelsExcludeAny <String[]>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/software/package as multipart/form-data.
The installer is streamed from disk through a temporary multipart file, so it is not loaded into memory.
Supported files are .pkg, .msi, .exe, .deb, .rpm, .tar.gz, .ipa, .sh, .py, and .ps1.
Only one of LabelsIncludeAll, LabelsIncludeAny, and LabelsExcludeAny can be used.

## EXAMPLES

### EXAMPLE 1
```
New-FleetSoftwarePackage -Path ./FalconSensor.pkg -FleetId 2 -SelfService -LabelsExcludeAny 'Servers'
```

### EXAMPLE 2
```
New-FleetSoftwarePackage -Path ./tool.exe -FleetId 2 -InstallScript 'tool.exe /S' -UninstallScript 'tool.exe /uninstall /S'
```

## PARAMETERS

### -Path
Local installer or script file.

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

### -FleetId
Fleet that receives the installer.
Use 0 for "Unassigned" hosts.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -InstallScript
Install script.
Required for .exe and .tar.gz.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UninstallScript
Uninstall script.
Required for .exe and .tar.gz.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreInstallQuery
osquery condition.
Fleet installs only when the query returns a row.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PostInstallScript
Script run after install.
A non-zero exit rolls back the install.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SelfService
Lets end users install the software from Fleet Desktop.

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

### -AutomaticInstall
Creates a policy that installs the software on hosts that lack it.

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

### -LabelsIncludeAll
Targets hosts that have all of these labels.

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

### -LabelsIncludeAny
Targets hosts that have any of these labels.

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

### -LabelsExcludeAny
Skips hosts that have any of these labels.

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

### FleetDM.SoftwarePackage
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
The request body limit is 10 GB.
https://fleetdm.com/docs/rest-api/rest-api#add-package

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#add-package](https://fleetdm.com/docs/rest-api/rest-api#add-package)

