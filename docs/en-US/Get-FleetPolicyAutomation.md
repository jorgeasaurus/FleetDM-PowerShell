---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/rest-api/rest-api#list-policy-automation-activities
schema: 2.0.0
---

# Get-FleetPolicyAutomation

## SYNOPSIS
Lists automation activity for a policy.

## SYNTAX

```
Get-FleetPolicyAutomation [-PolicyId] <Int32> [[-Status] <String>] [[-Query] <String>] [[-Page] <Int32>]
 [[-PerPage] <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Sends GET /api/v1/fleet/policies/{id}/automation_activities.
Webhook automation activity is available in Fleet Free.
Calendar, script, and software automations require Fleet Premium.

## EXAMPLES

### EXAMPLE 1
```
Get-FleetPolicyAutomation -PolicyId 12
```

## PARAMETERS

### -PolicyId
Policy ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Status
Optional status filter: success or error.

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

### -Query
Host name search.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Page
Page number.
When omitted, every page is retrieved.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PerPage
Page size.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 100
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

## NOTES
Calendar, script, and software policy automations require Fleet Premium.
https://fleetdm.com/docs/rest-api/rest-api#list-policy-automation-activities
https://fleetdm.com/docs/configuration/yaml-files

## RELATED LINKS

[https://fleetdm.com/docs/rest-api/rest-api#list-policy-automation-activities](https://fleetdm.com/docs/rest-api/rest-api#list-policy-automation-activities)

