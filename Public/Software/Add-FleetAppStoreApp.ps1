function Add-FleetAppStoreApp {
    <#
    .SYNOPSIS
        Adds an Apple App Store or Google Play app to a fleet.

    .DESCRIPTION
        Sends POST /api/v1/fleet/software/app_store_apps with app_store_id and fleet_id.
        Apple apps must be purchased in Apple Business first.
        Only one of LabelsIncludeAll, LabelsIncludeAny, and LabelsExcludeAny can be used.

    .PARAMETER AppStoreId
        App Store ID, or the Google Play package name. Binds from the app_store_id property.

    .PARAMETER FleetId
        Fleet that receives the app. Use 0 for "Unassigned".

    .PARAMETER Platform
        darwin, ios, ipados, or android. Fleet defaults to darwin.

    .PARAMETER VppTokenId
        VPP token to add the app from. Required when the fleet has more than one VPP token.

    .PARAMETER SelfService
        Lists the app in self-service. Required for Android apps.

    .PARAMETER AutomaticInstall
        Creates a policy that installs the app on macOS hosts that lack it.

    .PARAMETER Categories
        Self-service category names that already exist on the fleet.

    .PARAMETER LabelsIncludeAll
        Targets hosts that have all of these labels.

    .PARAMETER LabelsIncludeAny
        Targets hosts that have any of these labels.

    .PARAMETER LabelsExcludeAny
        Skips hosts that have any of these labels.

    .EXAMPLE
        Add-FleetAppStoreApp -AppStoreId '497799835' -FleetId 2 -Platform ipados -SelfService

    .EXAMPLE
        Get-FleetAppStoreApp -FleetId 2 | Where-Object name -eq 'Xcode' | Add-FleetAppStoreApp -FleetId 2

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#add-app-store-app

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#add-app-store-app
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.SoftwareTitleReference')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('app_store_id')]
        [ValidateNotNullOrEmpty()]
        [string]$AppStoreId,

        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('darwin', 'ios', 'ipados', 'android')]
        [string]$Platform,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$VppTokenId,

        [switch]$SelfService,

        [switch]$AutomaticInstall,

        [ValidateNotNullOrEmpty()]
        [string[]]$Categories,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAll,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAny,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsExcludeAny
    )

    process {
        $body = @{ app_store_id = $AppStoreId; fleet_id = $FleetId }
        if ($Platform) { $body['platform'] = $Platform }
        if ($PSBoundParameters.ContainsKey('VppTokenId')) { $body['vpp_token_id'] = $VppTokenId }
        if ($SelfService) { $body['self_service'] = $true }
        if ($AutomaticInstall) { $body['automatic_install'] = $true }
        if ($Categories) { $body['categories'] = @($Categories) }
        Add-FleetLabelTarget -Target $body -BoundParameters $PSBoundParameters -SingleMode

        if ($PSCmdlet.ShouldProcess("App Store app $AppStoreId on fleet $FleetId", 'Add')) {
            $response = Invoke-FleetDMRequest -Endpoint 'software/app_store_apps' -Method POST -Body $body
            $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.SoftwareTitleReference'
            return $response
        }
    }
}
