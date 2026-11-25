---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#create-script
schema: 2.0.0
---

# New-FleetScript

## SYNOPSIS
Uploads a saved script.

## SYNTAX

### Path (Default)
```
New-FleetScript [-Path] <String> [-FleetId <Int32>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Contents
```
New-FleetScript -Contents <String> -Name <String> [-FleetId <Int32>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/scripts as multipart/form-data with the script file.
Fleet names the script after the file name and converts CRLF line endings to LF.
The request body limit is 1.5 MiB.

## EXAMPLES

### EXAMPLE 1
```
New-FleetScript -Path ./collect-logs.sh -FleetId 2
```

### EXAMPLE 2
```
New-FleetScript -Name 'hello.sh' -Contents 'echo hello'
```

## PARAMETERS

### -Path
Local script file to upload.
The file name becomes the script name.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Contents
Script text to upload instead of a file.
Requires Name.

```yaml
Type: String
Parameter Sets: Contents
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Script file name used with Contents, for example collect.sh or Fix-Thing.ps1.
The extension tells Fleet which hosts can run it.

```yaml
Type: String
Parameter Sets: Contents
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FleetId
Fleet Premium.
Saves the script on this fleet.
Omit it, or use 0, for "Unassigned" hosts.

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

### FleetDM.Script
## NOTES
Saving a script on a fleet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#create-script

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#create-script](https://fleetdm.com/docs/rest-api/rest-api#create-script)

