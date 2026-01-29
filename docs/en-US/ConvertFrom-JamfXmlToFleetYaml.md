---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/configuration/yaml-files
schema: 2.0.0
---

# ConvertFrom-JamfXmlToFleetYaml

## SYNOPSIS
Converts Jamf Pro exported XML files into FleetDM GitOps-compatible files.

## SYNTAX

```
ConvertFrom-JamfXmlToFleetYaml [-Path] <String[]> [-OutputDirectory <String>] [-Force] [-PassThru]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Converts Jamf Pro exported XML files into FleetDM GitOps-compatible files. For scripts, extracts the script content to a .sh file and generates a YAML referencing it under controls.scripts. For configuration profiles, extracts the profile to a .mobileconfig file and generates a YAML referencing it under controls.macos_settings.custom_settings.

Supports:
- Jamf scripts (root element: script)
- macOS configuration profiles (root element: os_x_configuration_profile)
- Mobile device profiles (root element: mobile_device_configuration_profile)
- Raw plist files (root element: plist)

## EXAMPLES

### EXAMPLE 1
```
ConvertFrom-JamfXmlToFleetYaml -Path .\Exports\*.xml -OutputDirectory .\Fleet
```

Converts all Jamf XML exports in the Exports folder to FleetDM files in the Fleet folder.

### EXAMPLE 2
```
Get-ChildItem -Path .\JamfExport\scripts\*.plist | ConvertFrom-JamfXmlToFleetYaml -OutputDirectory .\Fleet -PassThru
```

Converts all Jamf script exports and returns information about each converted file.

### EXAMPLE 3
```
ConvertFrom-JamfXmlToFleetYaml -Path .\profile.xml -OutputDirectory .\Fleet -Force
```

Converts a single profile, overwriting existing files if present.

## PARAMETERS

### -Path
One or more paths to Jamf Pro exported XML files. Supports wildcards and pipeline input.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### -OutputDirectory
Directory where FleetDM files will be written. Scripts go to lib/scripts/, profiles go to lib/profiles/, and YAML files are written to the root. Defaults to the current location.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Current directory
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Overwrites existing files in the output directory.

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

### -PassThru
Returns information about the generated files including SourcePath, OutputPath, AssetPath, and ExportType.

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

### System.String[]
File paths to Jamf XML exports.

## OUTPUTS

### System.Management.Automation.PSCustomObject
When -PassThru is specified, returns objects with SourcePath, OutputPath, AssetPath, and ExportType properties.

## NOTES
The generated YAML files contain only the controls section. To import into Fleet, create a team file that includes the required fields (name, team_settings, agent_options, controls, policies, queries, software) and use `fleetctl gitops -f team.yml`.

Output structure:
```
OutputDirectory/
  lib/
    scripts/
      script_name.sh
    profiles/
      profile_name.mobileconfig
  source_file.fleet.yml
```

## RELATED LINKS

[https://fleetdm.com/docs/configuration/yaml-files](https://fleetdm.com/docs/configuration/yaml-files)

[https://github.com/fleetdm/fleet-gitops](https://github.com/fleetdm/fleet-gitops)
