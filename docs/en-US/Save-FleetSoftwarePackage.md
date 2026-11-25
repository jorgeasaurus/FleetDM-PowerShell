---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#download-software
schema: 2.0.0
---

# Save-FleetSoftwarePackage

## SYNOPSIS
Downloads a software installer to a local file.

## SYNTAX

```
Save-FleetSoftwarePackage [-SoftwareTitleId] <Int32> [-FleetId] <Int32> [-OutFile] <String>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/software/titles/{id}/package?alt=media and writes the response to OutFile.
Invoke-RestMethod streams the body to disk.
The saved file is returned.

## EXAMPLES

### EXAMPLE 1
```
Save-FleetSoftwarePackage -SoftwareTitleId 123 -FleetId 2 -OutFile ./FalconSensor.pkg
```

## PARAMETERS

### -SoftwareTitleId
Software title ID.
Binds from the software_title_id or id property.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: software_title_id, Id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FleetId
Fleet that owns the installer.
Use 0 for "Unassigned".

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile
Local path for the installer.
An existing file is overwritten.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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

### System.IO.FileInfo
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#download-software

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#download-software](https://fleetdm.com/docs/rest-api/rest-api#download-software)

