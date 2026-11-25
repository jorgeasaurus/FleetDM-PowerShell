function Get-FleetBootstrapPackage {
    <#
    .SYNOPSIS
        Gets a fleet's bootstrap package metadata.

    .DESCRIPTION
        Sends GET /api/v1/fleet/bootstrap/{fleet_id}/metadata. The response has the package name, sha256, and download token.

    .PARAMETER FleetId
        Fleet ID. Use 0 for "Unassigned".

    .PARAMETER ForUpdate
        Authorizes the read as a write, for the GitOps role that cannot read.

    .EXAMPLE
        Get-FleetBootstrapPackage -FleetId 0

    .NOTES
        This cmdlet requires Fleet Premium and Apple MDM. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#get-bootstrap-package-metadata

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#get-bootstrap-package-metadata
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.BootstrapPackage')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('fleet_id')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [switch]$ForUpdate
    )

    process {
        $queryParams = @{}
        if ($ForUpdate) { $queryParams['for_update'] = $true }
        $response = Invoke-FleetDMRequest -Endpoint "bootstrap/$FleetId/metadata" -QueryParameters $queryParams
        $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.BootstrapPackage'
        return $response
    }
}
