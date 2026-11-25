---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-patch-deadline-settings
schema: 2.0.0
---

# Set-FleetPatchDeadline

## SYNOPSIS
Sets the days and time Fleet patches Fleet-maintained apps on a fleet.

## SYNTAX

```
Set-FleetPatchDeadline [-FleetId] <Int32> [-Days] <String[]> [-Time] <String>
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends PATCH /api/v1/fleet/software/patch_deadline_settings with fleet_id, days, and time.
Time is HH:MM in each host's local time.
Fleet notifies end users one hour before the deadline.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetPatchDeadline -FleetId 3 -Days monday, wednesday, friday -Time '11:00'
```

## PARAMETERS

### -FleetId
Fleet ID.
Use 0 for "Unassigned".

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Days
One or more of monday, tuesday, wednesday, thursday, friday, saturday, and sunday.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Time
Deadline in 24-hour HH:MM, for example 11:00.

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

### FleetDM.PatchDeadline
## NOTES
This cmdlet requires Fleet Premium and an admin or maintainer role.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#update-patch-deadline-settings

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-patch-deadline-settings](https://fleetdm.com/docs/rest-api/rest-api#update-patch-deadline-settings)

