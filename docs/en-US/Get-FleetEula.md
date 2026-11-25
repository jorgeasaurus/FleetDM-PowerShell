---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#get-eula-metadata
schema: 2.0.0
---

# Get-FleetEula

## SYNOPSIS
Gets the setup EULA metadata, or downloads the EULA file.

## SYNTAX

```
Get-FleetEula [[-Platform] <String>] [[-OutFile] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/setup_experience/eula/metadata.
With OutFile, it then sends
GET /api/v1/fleet/setup_experience/eula/{token} and saves the file.
Fleet answers 404 when no EULA was uploaded for the platform.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetEula
```

### EXAMPLE 2
```
Get-FleetEula -Platform windows -OutFile ./terms.md
```

## PARAMETERS

### -Platform
darwin (a PDF shown in macOS Setup Assistant) or windows (Markdown terms).
Fleet defaults to darwin.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile
Saves the EULA file to this path and returns the file.

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

### FleetDM.Eula
### System.IO.FileInfo
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#get-eula-metadata

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#get-eula-metadata](https://fleetdm.com/docs/rest-api/rest-api#get-eula-metadata)

