function Add-FleetMaintainedApp {
    <#
    .SYNOPSIS
        Adds a Fleet-maintained app to a fleet.

    .DESCRIPTION
        Sends POST /api/v1/fleet/software/fleet_maintained_apps with fleet_maintained_app_id and fleet_id.
        Fleet downloads the installer and returns the software_title_id.
        Only one of LabelsIncludeAll, LabelsIncludeAny, and LabelsExcludeAny can be used.

    .PARAMETER Id
        Fleet-maintained app ID. Binds from the id property of Get-FleetMaintainedApp output.

    .PARAMETER FleetId
        Fleet that receives the app. Use 0 for "Unassigned".

    .PARAMETER InstallScript
        Install script that replaces Fleet's default.

    .PARAMETER PreInstallQuery
        osquery pre-install condition.

    .PARAMETER PostInstallScript
        Post-install script.

    .PARAMETER SelfService
        Lets end users install the app from Fleet Desktop.

    .PARAMETER AutomaticInstall
        Creates a policy that installs the app on hosts that lack it.

    .PARAMETER LabelsIncludeAll
        Targets hosts that have all of these labels.

    .PARAMETER LabelsIncludeAny
        Targets hosts that have any of these labels.

    .PARAMETER LabelsExcludeAny
        Skips hosts that have any of these labels.

    .EXAMPLE
        Add-FleetMaintainedApp -Id 3 -FleetId 2 -AutomaticInstall

    .EXAMPLE
        Get-FleetMaintainedApp -Query '1Password' -Platform darwin | Add-FleetMaintainedApp -FleetId 2 -SelfService

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#add-fleet-maintained-app

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#add-fleet-maintained-app
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.SoftwareTitleReference')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('fleet_maintained_app_id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,

        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [string]$InstallScript,

        [string]$PreInstallQuery,

        [string]$PostInstallScript,

        [switch]$SelfService,

        [switch]$AutomaticInstall,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAll,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAny,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsExcludeAny
    )

    process {
        $body = @{ fleet_maintained_app_id = $Id; fleet_id = $FleetId }
        if ($PSBoundParameters.ContainsKey('InstallScript')) { $body['install_script'] = $InstallScript }
        if ($PSBoundParameters.ContainsKey('PreInstallQuery')) { $body['pre_install_query'] = $PreInstallQuery }
        if ($PSBoundParameters.ContainsKey('PostInstallScript')) { $body['post_install_script'] = $PostInstallScript }
        if ($SelfService) { $body['self_service'] = $true }
        if ($AutomaticInstall) { $body['automatic_install'] = $true }
        Add-FleetLabelTarget -Target $body -BoundParameters $PSBoundParameters -SingleMode

        if ($PSCmdlet.ShouldProcess("Fleet-maintained app $Id on fleet $FleetId", 'Add')) {
            $response = Invoke-FleetDMRequest -Endpoint 'software/fleet_maintained_apps' -Method POST -Body $body
            $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.SoftwareTitleReference'
            return $response
        }
    }
}
