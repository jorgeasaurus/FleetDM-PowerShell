function Get-FleetTeam {
    <#
    .SYNOPSIS
        Gets Fleet Premium fleets (formerly called teams).

    .DESCRIPTION
        Lists fleets or retrieves one fleet by ID from GET /api/v1/fleet/fleets.
        The REST resource is "fleets". Create and get responses still return the fleet under the "team" property.

    .PARAMETER Id
        Fleet ID. Use 0 for hosts that are not assigned to a fleet.

    .PARAMETER Name
        Case-insensitive partial name match applied after the fleet list is retrieved.

    .PARAMETER Page
        Page number. When omitted, every page is retrieved.

    .PARAMETER PerPage
        Page size. The default is 100.

    .EXAMPLE
        Get-FleetTeam

        Lists every fleet.

    .EXAMPLE
        Get-FleetTeam -Id 1

        Gets fleet 1.

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#list-fleets

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-fleets
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Id,

        [Parameter(ParameterSetName = 'List')]
        [string]$Name,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Page,

        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(1, 500)]
        [int]$PerPage = 100
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $response = Invoke-FleetDMRequest -Endpoint "fleets/$Id" -Method GET
            $fleet = Get-FleetRecord -Response $response
            if (-not $fleet) {
                Write-Warning "No fleet data returned for ID: $Id"
                return
            }
            return $fleet
        }

        $queryParams = @{ per_page = $PerPage }
        if ($PSBoundParameters.ContainsKey('Page')) {
            $queryParams['page'] = $Page
        }

        $followPagination = -not $PSBoundParameters.ContainsKey('Page')
        if ($followPagination) {
            $response = Invoke-FleetDMRequest -Endpoint 'fleets' -QueryParameters $queryParams -FollowPagination
        }
        else {
            $response = Invoke-FleetDMRequest -Endpoint 'fleets' -QueryParameters $queryParams
        }

        $result = Get-FleetListResult -Response $response -Name 'fleets' -TypeName 'FleetDM.Team'
        if ($Name) {
            $result = @($result | Where-Object { $_.name -like "*$Name*" })
        }

        return $result
    }
}
