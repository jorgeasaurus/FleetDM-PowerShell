---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-configuration-profiles
schema: 2.0.0
---

# Get-FleetConfigurationProfile

## SYNOPSIS
Lists configuration profiles, gets one, or downloads one.

## SYNTAX

### List (Default)
```
Get-FleetConfigurationProfile [-FleetId <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ById
```
Get-FleetConfigurationProfile -ProfileUuid <String> [-OutFile <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/configuration_profiles or
GET /api/v1/fleet/configuration_profiles/{profile_uuid}.
-OutFile adds alt=media and saves the profile file.
Without FleetId the list holds only "Unassigned" profiles.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetConfigurationProfile -FleetId 2
```

### EXAMPLE 2
```
Get-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24' -OutFile ./passcode.mobileconfig
```

## PARAMETERS

### -FleetId
Fleet Premium.
Lists the profiles on this fleet.

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

### -ProfileUuid
Profile UUID.
Binds from the profile_uuid property.

```yaml
Type: String
Parameter Sets: ById
Aliases: profile_uuid

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -OutFile
Saves the profile file to this path and returns the file.

```yaml
Type: String
Parameter Sets: ById
Aliases:

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

### FleetDM.ConfigurationProfile
### System.IO.FileInfo
## NOTES
Requires MDM to be turned on in Fleet.
Otherwise Fleet responds with HTTP 400.
FleetId requires Fleet Premium.
https://fleetdm.com/docs/rest-api/rest-api#list-configuration-profiles

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-configuration-profiles](https://fleetdm.com/docs/rest-api/rest-api#list-configuration-profiles)

