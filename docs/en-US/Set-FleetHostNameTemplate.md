---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#update-host-name-template
schema: 2.0.0
---

# Set-FleetHostNameTemplate

## SYNOPSIS
Sets or clears the host name template for Apple hosts on a fleet.

## SYNTAX

```
Set-FleetHostNameTemplate [-FleetId] <Int32> [-Template] <String> [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/host_name_template with fleet_id and name_template.
Fleet renames macOS, iOS, and iPadOS hosts with an MDM command.
An empty Template clears the template
and stops enforcement without renaming any host.
The empty string is sent, not dropped.

## EXAMPLES

### EXAMPLE 1
```
Set-FleetHostNameTemplate -FleetId 5 -Template 'iPad $FLEET_VAR_HOST_HARDWARE_SERIAL'
```

### EXAMPLE 2
```
Set-FleetHostNameTemplate -FleetId 5 -Template ''
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

### -Template
Name template, such as 'iPad $FLEET_VAR_HOST_HARDWARE_SERIAL'.
Use an empty string to clear it.
Use single quotes so PowerShell does not expand the variables.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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

### FleetDM.HostNameTemplate
## NOTES
This cmdlet requires Fleet Premium.
Fleet Free responds with HTTP 402.
Fleet returns 422 for certificate authority variables and undefined custom variables.
https://fleetdm.com/docs/rest-api/rest-api#update-host-name-template

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#update-host-name-template](https://fleetdm.com/docs/rest-api/rest-api#update-host-name-template)

