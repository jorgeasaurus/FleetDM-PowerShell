function Get-FleetScript {
    <#
    .SYNOPSIS
        Lists saved scripts or gets one script.

    .DESCRIPTION
        Sends GET /api/v1/fleet/scripts or GET /api/v1/fleet/scripts/{id}.
        Listing scripts for unassigned hosts is available in Fleet Free.
        Filtering with FleetId requires Fleet Premium.

    .PARAMETER Id
        Script ID.

    .PARAMETER FleetId
        Fleet Premium. Lists scripts saved on this fleet. Omit it to list scripts for unassigned hosts.

    .PARAMETER Page
        Page number. When omitted, every page is retrieved.

    .PARAMETER PerPage
        Page size. The default is 100.

    .EXAMPLE
        Get-FleetScript

    .EXAMPLE
        Get-FleetScript -Id 12

    .NOTES
        Passing FleetId requires Fleet Premium and returns HTTP 402 on Fleet Free.
        https://fleetdm.com/docs/rest-api/rest-api#list-scripts

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-scripts
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Page,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 500)]
        [int]$PerPage = 100
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $response = Invoke-FleetDMRequest -Endpoint "scripts/$Id" -Method GET
            $script = $response.script
            if (-not $script) { $script = $response }
            if ($script -and $script.PSObject) {
                $script.PSObject.TypeNames.Insert(0, 'FleetDM.Script')
            }
            return $script
        }

        $queryParams = @{ per_page = $PerPage }
        if ($PSBoundParameters.ContainsKey('FleetId')) { $queryParams['fleet_id'] = $FleetId }
        if ($PSBoundParameters.ContainsKey('Page')) { $queryParams['page'] = $Page }

        $followPagination = -not $PSBoundParameters.ContainsKey('Page')
        if ($followPagination) {
            $response = Invoke-FleetDMRequest -Endpoint 'scripts' -QueryParameters $queryParams -FollowPagination
        }
        else {
            $response = Invoke-FleetDMRequest -Endpoint 'scripts' -QueryParameters $queryParams
        }

        $result = $response
        if ($null -ne $response.scripts) {
            $result = $response.scripts
        }
        $result = @($result | Where-Object { $_ })
        foreach ($script in $result) {
            if ($script.PSObject) {
                $script.PSObject.TypeNames.Insert(0, 'FleetDM.Script')
            }
        }
        return $result
    }
}
