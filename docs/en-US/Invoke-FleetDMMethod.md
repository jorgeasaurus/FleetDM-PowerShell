---
external help file: FleetDM-PowerShell-help.xml
Module Name: FleetDM-PowerShell
online version: https://fleetdm.com/docs/using-fleet/rest-api
schema: 2.0.0
---

# Invoke-FleetDMMethod

## SYNOPSIS
Invokes a custom FleetDM API method

## SYNTAX

```
Invoke-FleetDMMethod [-Endpoint] <String> [[-Method] <String>] [[-Body] <Hashtable>]
 [[-QueryParameters] <Hashtable>] [-FollowPagination] [-MaxRetries <Int32>] [-RetryNonIdempotent]
 [-Raw] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Provides direct access to any FleetDM API endpoint not covered by specific cmdlets.
This is useful for accessing new or undocumented API endpoints.

## EXAMPLES

### EXAMPLE 1
```
Invoke-FleetDMMethod -Endpoint "config" -Method GET
```

Gets the FleetDM configuration

### EXAMPLE 2
```
Invoke-FleetDMMethod -Endpoint "users" -Method GET -QueryParameters @{query = "admin"}
```

Searches for users with "admin" in their name

### EXAMPLE 3
```
$body = @{
    name = "New Team"
    description = "Created via API"
}
Invoke-FleetDMMethod -Endpoint "teams" -Method POST -Body $body
```

Creates a new team

### EXAMPLE 4
```
Invoke-FleetDMMethod -Endpoint "hosts/123/refetch" -Method POST
```

Triggers a refetch for host ID 123

### EXAMPLE 5
```
Invoke-FleetDMMethod -Endpoint "labels" -Method GET -FollowPagination
```

Gets all labels, automatically following pagination

### EXAMPLE 6
```
Invoke-FleetDMMethod -Endpoint "hosts" -MaxRetries 0
```

Sends one GET and does not retry HTTP 429 or a gateway error.

### EXAMPLE 7
```
Invoke-FleetDMMethod -Endpoint "hosts/123/refetch" -Method POST -RetryNonIdempotent
```

Retries that POST after HTTP 502, 503, or 504. Leave the switch off when repeating the call could apply the change twice. HTTP 429 is retried either way.

## PARAMETERS

### -Endpoint
The API endpoint path (without /api/v1/fleet/ prefix)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
The HTTP method to use (GET, POST, PUT, PATCH, DELETE)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: GET
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body
The request body as a hashtable (will be converted to JSON)

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -QueryParameters
Query parameters as a hashtable

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FollowPagination
Automatically follow pagination to retrieve all results (for GET requests)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxRetries
Maximum number of additional attempts after the first request. The default is 3 when this is omitted. HTTP 429 is retried for every method. HTTP 502, 503, and 504 are retried for GET. Gateway retries wait 2, 4, then 8 seconds. A 429 waits for Retry-After or for "retry after: Ns" in the error.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 3
Accept pipeline input: False
Accept wildcard characters: False
```

### -RetryNonIdempotent
Also retry POST, PUT, PATCH, and DELETE after HTTP 502, 503, or 504. HTTP 429 is retried without this switch.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Raw
Return the raw response object without processing

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

## RELATED LINKS

[https://fleetdm.com/docs/using-fleet/rest-api](https://fleetdm.com/docs/using-fleet/rest-api)

