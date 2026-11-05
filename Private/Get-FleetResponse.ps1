function Get-FleetRecord {
    <#
    .SYNOPSIS
        Returns the fleet object from a create, get, or update response.

    .DESCRIPTION
        Fleet still returns the record under "team" on some responses and under "fleet" on others.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Response
    )

    if ($null -eq $Response) {
        return $null
    }

    $fleet = $Response.team
    if (-not $fleet) { $fleet = $Response.fleet }
    if ($fleet -and $fleet.PSObject) {
        $null = Add-FleetTypeName -InputObject $fleet -TypeName 'FleetDM.Team'
    }
    return $fleet
}

function Get-FleetResponseRecord {
    <#
    .SYNOPSIS
        Returns one named record from a Fleet response and stamps its type.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Response,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$TypeName
    )

    if ($null -eq $Response) {
        return $null
    }

    $record = $Response.$Name
    if (-not $record) { $record = $Response }
    if ($record -and $record.PSObject) {
        $null = Add-FleetTypeName -InputObject $record -TypeName $TypeName
    }
    return $record
}

function Get-FleetListAliasName {
    <#
    .SYNOPSIS
        Returns the other list name for a Fleet resource that changed names.

    .DESCRIPTION
        List fleets is the only renamed collection this module reads. Fleet 4.93
        sends that collection under both fleets and teams.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    switch ($Name) {
        'fleets' { return 'teams' }
        'teams' { return 'fleets' }
        default { return $null }
    }
}

function Test-FleetCollectionPopulated {
    <#
    .SYNOPSIS
        Returns whether a list value contains at least one record.

    .DESCRIPTION
        A null, empty list, string, or scalar is empty. One PSCustomObject counts
        as a record because Windows PowerShell 5.1 unwraps a one-element JSON array.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -is [System.ValueType]) {
        return $false
    }

    if ($Value -is [System.Collections.IList]) {
        return $Value.Count -gt 0
    }

    return $true
}

function Get-FleetEnvelopeProperty {
    <#
    .SYNOPSIS
        Reads one property from a list envelope without enumerating an item list.

    .DESCRIPTION
        Dot-access on an Object[] member-enumerates. A missing fleets property then
        becomes one null per record, and the records are discarded. An item list has
        no envelope property. A present property is returned even when its value is null.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Response,

        [Parameter(Mandatory)]
        [string]$Name
    )

    if ($null -eq $Response -or $Response -is [string]) {
        return $null
    }

    if ($Response -is [System.Collections.IList]) {
        return $null
    }

    if ($Response -is [System.Collections.IDictionary]) {
        foreach ($key in @($Response.Keys)) {
            if ([string]$key -eq $Name) {
                return @{
                    Value = $Response[$key]
                }
            }
        }
        return $null
    }

    if ($null -eq $Response.PSObject) {
        return $null
    }

    $property = $Response.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }

    return @{
        Value = $property.Value
    }
}

function Resolve-FleetListValue {
    <#
    .SYNOPSIS
        Chooses one collection from a named list property and its legacy alias.

    .DESCRIPTION
        The named key wins when it has records. A null or empty named key falls
        back to the alias when that alias has records. When both are populated,
        the named key is returned once. When neither key exists, Found is false
        and the caller keeps the original response.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Response,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $primary = Get-FleetEnvelopeProperty -Response $Response -Name $Name
    $alias = $null
    $aliasName = Get-FleetListAliasName -Name $Name
    if ($aliasName) {
        $alias = Get-FleetEnvelopeProperty -Response $Response -Name $aliasName
    }

    $chosen = $null
    $found = $false
    if ($primary -and (Test-FleetCollectionPopulated -Value $primary.Value)) {
        $chosen = $primary.Value
        $found = $true
    }
    elseif ($alias -and (Test-FleetCollectionPopulated -Value $alias.Value)) {
        $chosen = $alias.Value
        $found = $true
    }
    elseif ($primary -and $null -ne $primary.Value) {
        $chosen = $primary.Value
        $found = $true
    }
    elseif ($alias -and $null -ne $alias.Value) {
        $chosen = $alias.Value
        $found = $true
    }

    return @{
        Found = $found
        Value = $chosen
    }
}

function Get-FleetListResult {
    <#
    .SYNOPSIS
        Returns the named collection from a list response and stamps each item.

    .DESCRIPTION
        FollowPagination already returns the items. A single page returns the envelope.
        A missing property keeps the response, which is the item list in the paginated case.
        A null or empty fleets or teams key falls back to the other name. When both are
        populated, the requested name is used once.
        Windows PowerShell 5.1 may unwrap a one-element collection into one object.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Response,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$TypeName
    )

    $selection = Resolve-FleetListValue -Response $Response -Name $Name
    $result = if ($selection.Found) { $selection.Value } else { $Response }

    $items = @(foreach ($item in @($result)) {
        if ($item) { $item }
    })
    if ($items.Count -gt 0) {
        $null = Add-FleetTypeName -InputObject $items -TypeName $TypeName
    }
    return $items
}
