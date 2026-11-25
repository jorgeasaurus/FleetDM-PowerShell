---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#add-users-to-fleet
schema: 2.0.0
---

# Add-FleetTeamUser

## SYNOPSIS
Adds users to a fleet with a fleet role.

## SYNTAX

```
Add-FleetTeamUser [-FleetId] <Int32> [-UserId] <Int32[]> [-Role] <String> [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends PATCH /api/v1/fleet/fleets/{id}/users with a users list of id and role.
User IDs piped in are collected and sent in one request.
Every user gets the same Role.
A user who is already on the fleet gets the new role.

## EXAMPLES

### EXAMPLE 1
```
Add-FleetTeamUser -FleetId 1 -UserId 17, 18 -Role observer
```

## PARAMETERS

### -FleetId
Fleet ID.

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

### -UserId
User IDs to add.
Binds from the id property of piped users.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Role
Fleet role: admin, maintainer, observer, observer_plus, or gitops.

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

### FleetDM.Team
## NOTES
This cmdlet requires Fleet Premium and the admin role.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#add-users-to-fleet

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#add-users-to-fleet](https://fleetdm.com/docs/rest-api/rest-api#add-users-to-fleet)

