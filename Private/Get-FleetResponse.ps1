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

function Get-FleetListResult {
    <#
    .SYNOPSIS
        Returns the named collection from a list response and stamps each item.

    .DESCRIPTION
        FollowPagination already returns the items. A single page returns the envelope.
        A missing property keeps the response, which is the item list in the paginated case.
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

    $result = $Response
    if ($null -ne $Response.$Name) {
        $result = $Response.$Name
    }

    $items = @(foreach ($item in @($result)) {
        if ($item) { $item }
    })
    if ($items.Count -gt 0) {
        $null = Add-FleetTypeName -InputObject $items -TypeName $TypeName
    }
    return $items
}
