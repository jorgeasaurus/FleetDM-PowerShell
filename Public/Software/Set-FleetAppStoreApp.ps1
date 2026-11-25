function Set-FleetAppStoreApp {
    <#
    .SYNOPSIS
        Updates an App Store app's self-service, category, and targeting settings.

    .DESCRIPTION
        Sends PATCH /api/v1/fleet/software/titles/{title_id}/app_store_app.
        Only supplied fields are sent. Settings apply to one version of the app; use VersionId when the title has more than one.
        Only one of LabelsIncludeAll, LabelsIncludeAny, and LabelsExcludeAny can be used.

    .PARAMETER SoftwareTitleId
        Software title ID. Binds from the software_title_id property.

    .PARAMETER FleetId
        Fleet that owns the app. Use 0 for "Unassigned".

    .PARAMETER VersionId
        App version ID. Required when the title has more than one version on the fleet.

    .PARAMETER DisplayName
        Display name that overrides the title name.

    .PARAMETER SelfService
        Sets whether the app is listed in self-service.

    .PARAMETER Categories
        Self-service category names. Pass an empty array to remove every category.

    .PARAMETER LabelsIncludeAll
        Targets hosts that have all of these labels.

    .PARAMETER LabelsIncludeAny
        Targets hosts that have any of these labels.

    .PARAMETER LabelsExcludeAny
        Skips hosts that have any of these labels.

    .EXAMPLE
        Set-FleetAppStoreApp -SoftwareTitleId 3467 -FleetId 2 -SelfService $true -Categories 'Browser'

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#update-app-store-app

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-app-store-app
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.AppStoreApp')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('software_title_id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$SoftwareTitleId,

        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('version_id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$VersionId,

        [ValidateLength(0, 255)]
        [string]$DisplayName,

        [bool]$SelfService,

        [AllowEmptyCollection()]
        [string[]]$Categories,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAll,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAny,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsExcludeAny
    )

    process {
        $body = @{ fleet_id = $FleetId }
        if ($PSBoundParameters.ContainsKey('VersionId')) { $body['version_id'] = $VersionId }
        if ($PSBoundParameters.ContainsKey('DisplayName')) { $body['display_name'] = $DisplayName }
        if ($PSBoundParameters.ContainsKey('SelfService')) { $body['self_service'] = $SelfService }
        if ($PSBoundParameters.ContainsKey('Categories')) { $body['categories'] = @($Categories) }
        Add-FleetLabelTarget -Target $body -BoundParameters $PSBoundParameters -SingleMode

        if (@($body.Keys | Where-Object { $_ -notin 'fleet_id', 'version_id' }).Count -eq 0) {
            Write-Warning "No updates specified for software title $SoftwareTitleId"
            return
        }

        if ($PSCmdlet.ShouldProcess("App Store app for software title $SoftwareTitleId on fleet $FleetId", 'Update')) {
            $response = Invoke-FleetDMRequest -Endpoint "software/titles/$SoftwareTitleId/app_store_app" -Method PATCH -Body $body
            return (Get-FleetResponseRecord -Response $response -Name 'app_store_app' -TypeName 'FleetDM.AppStoreApp')
        }
    }
}
