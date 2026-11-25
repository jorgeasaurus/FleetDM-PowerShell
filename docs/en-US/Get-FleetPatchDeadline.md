---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#get-patch-deadline-settings
schema: 2.0.0
---

# Get-FleetPatchDeadline

## SYNOPSIS
Gets a fleet's patch deadline days and time.

## SYNTAX

```
Get-FleetPatchDeadline [-FleetId] <Int32> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/software/patch_deadline_settings?fleet_id={fleet_id}.
Fleet-maintained apps whose patch policy sets patch_deadline are patched at these deadlines.
Fleet returns Tuesday at 17:00 when the settings were never changed.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetPatchDeadline -FleetId 3
```

## PARAMETERS

### -FleetId
Fleet ID.
Use 0 for "Unassigned".
Binds from the id property of piped fleets.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
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

### FleetDM.PatchDeadline
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#get-patch-deadline-settings

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#get-patch-deadline-settings](https://fleetdm.com/docs/rest-api/rest-api#get-patch-deadline-settings)

