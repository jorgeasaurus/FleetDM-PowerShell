function Get-FleetPolicyAutomation {
    <#
    .SYNOPSIS
        Lists automation activity for a policy.

    .DESCRIPTION
        Sends GET /api/v1/fleet/policies/{id}/automation_activities.
        Webhook automation activity is available in Fleet Free.
        Calendar, script, and software automations require Fleet Premium.

    .PARAMETER PolicyId
        Policy ID.

    .PARAMETER Status
        Optional status filter: success or error.

    .PARAMETER Query
        Host name search.

    .PARAMETER Page
        Page number. When omitted, every page is retrieved.

    .PARAMETER PerPage
        Page size.

    .EXAMPLE
        Get-FleetPolicyAutomation -PolicyId 12

    .NOTES
        Calendar, script, and software policy automations require Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#list-policy-automation-activities
        https://fleetdm.com/docs/configuration/yaml-files

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-policy-automation-activities
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$PolicyId,

        [ValidateSet('success', 'error')]
        [string]$Status,

        [string]$Query,

        [ValidateRange(0, [int]::MaxValue)]
        [int]$Page,

        [ValidateRange(1, 10000)]
        [int]$PerPage = 100
    )

    process {
        $queryParams = @{ per_page = $PerPage }
        if ($Status) { $queryParams['status'] = $Status }
        if ($Query) { $queryParams['query'] = $Query }
        if ($PSBoundParameters.ContainsKey('Page')) { $queryParams['page'] = $Page }

        $followPagination = -not $PSBoundParameters.ContainsKey('Page')
        $endpoint = "policies/$PolicyId/automation_activities"
        if ($followPagination) {
            $response = Invoke-FleetDMRequest -Endpoint $endpoint -QueryParameters $queryParams -FollowPagination
        }
        else {
            $response = Invoke-FleetDMRequest -Endpoint $endpoint -QueryParameters $queryParams
        }

        return (Get-FleetListResult -Response $response -Name 'activities' -TypeName 'FleetDM.PolicyAutomationActivity')
    }
}
