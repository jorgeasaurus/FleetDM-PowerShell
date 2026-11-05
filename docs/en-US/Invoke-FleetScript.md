---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#run-script
schema: 2.0.0
---

# Invoke-FleetScript

## SYNOPSIS
Runs a script on a host.

## SYNTAX

### ById (Default)
```
Invoke-FleetScript -HostId <Int32> -ScriptId <Int32> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ByContents
```
Invoke-FleetScript -HostId <Int32> -ScriptContents <String> [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### ByName
```
Invoke-FleetScript -HostId <Int32> -ScriptName <String> -FleetId <Int32> [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sends POST /api/v1/fleet/scripts/run.
Supply ScriptId, ScriptContents, or ScriptName.
ScriptName requires FleetId.
Running by script ID or inline contents against a host is available in Fleet Free.
FleetId requires Fleet Premium.

## EXAMPLES

### EXAMPLE 1
```
Invoke-FleetScript -HostId 10 -ScriptId 4
```

### EXAMPLE 2
```
Invoke-FleetScript -HostId 10 -ScriptContents "echo hello"
```

## PARAMETERS

### -HostId
Target host ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Id

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ScriptId
Saved script ID.

```yaml
Type: Int32
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptContents
Inline script text, up to 10,000 characters.

```yaml
Type: String
Parameter Sets: ByContents
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptName
Saved script name.
Requires FleetId.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FleetId
Fleet Premium.
Fleet that owns the named script.

```yaml
Type: Int32
Parameter Sets: ByName
Aliases:

Required: True
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

## OUTPUTS

## NOTES
FleetId and ScriptName require Fleet Premium.
Fleet Free responds with HTTP 402.
https://fleetdm.com/docs/rest-api/rest-api#run-script

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#run-script](https://fleetdm.com/docs/rest-api/rest-api#run-script)

