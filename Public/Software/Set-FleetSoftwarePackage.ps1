function Set-FleetSoftwarePackage {
    <#
    .SYNOPSIS
        Updates a software installer, its scripts, or its targeting.

    .DESCRIPTION
        Sends PATCH /api/v1/fleet/software/titles/{id}/package as multipart/form-data.
        Only supplied fields are sent; Fleet leaves the rest unchanged. A new Path is streamed from disk.
        Any label parameter replaces the installer's label targeting. Only one label parameter can be used.
        Changing anything other than SelfService cancels pending installs of the old package.

    .PARAMETER SoftwareTitleId
        Software title ID. Binds from the software_title_id or id property.

    .PARAMETER FleetId
        Fleet that owns the installer. Use 0 for "Unassigned".

    .PARAMETER Path
        Replacement installer file.

    .PARAMETER DisplayName
        Display name that overrides the title name.

    .PARAMETER Categories
        Self-service category names that already exist on the fleet. Pass an empty array to remove every category.

    .PARAMETER InstallScript
        Install script.

    .PARAMETER UninstallScript
        Uninstall script. An empty string restores Fleet's default.

    .PARAMETER PreInstallQuery
        osquery pre-install condition.

    .PARAMETER PostInstallScript
        Post-install script.

    .PARAMETER SelfService
        Sets whether end users can install the software from Fleet Desktop.

    .PARAMETER LabelsIncludeAll
        Targets hosts that have all of these labels.

    .PARAMETER LabelsIncludeAny
        Targets hosts that have any of these labels.

    .PARAMETER LabelsExcludeAny
        Skips hosts that have any of these labels.

    .EXAMPLE
        Set-FleetSoftwarePackage -SoftwareTitleId 24 -FleetId 2 -SelfService $true -Categories 'Security'

    .EXAMPLE
        Set-FleetSoftwarePackage -SoftwareTitleId 24 -FleetId 2 -Path ./FalconSensor-7.1.pkg

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#update-package

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-package
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.SoftwarePackage')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('software_title_id', 'Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$SoftwareTitleId,

        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [ValidateLength(0, 255)]
        [string]$DisplayName,

        [AllowEmptyCollection()]
        [string[]]$Categories,

        [string]$InstallScript,

        [string]$UninstallScript,

        [string]$PreInstallQuery,

        [string]$PostInstallScript,

        [bool]$SelfService,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAll,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAny,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsExcludeAny
    )

    process {
        $form = [ordered]@{ fleet_id = $FleetId }
        if ($PSBoundParameters.ContainsKey('Path')) { $form['software'] = Get-FleetUploadFile -Path $Path -Stream }

        $fields = [ordered]@{
            DisplayName = 'display_name'
            InstallScript = 'install_script'
            UninstallScript = 'uninstall_script'
            PreInstallQuery = 'pre_install_query'
            PostInstallScript = 'post_install_script'
            SelfService = 'self_service'
        }
        foreach ($name in $fields.Keys) {
            if ($PSBoundParameters.ContainsKey($name)) { $form[$fields[$name]] = $PSBoundParameters[$name] }
        }

        # Fleet clears categories when the field is sent once with an empty value.
        if ($PSBoundParameters.ContainsKey('Categories')) {
            $form['categories'] = if (@($Categories).Count -eq 0) { '' } else { @($Categories) }
        }
        Add-FleetLabelTarget -Target $form -BoundParameters $PSBoundParameters -SingleMode

        if ($form.Count -eq 1) {
            Write-Warning "No updates specified for software title $SoftwareTitleId"
            return
        }

        if ($PSCmdlet.ShouldProcess("installer for software title $SoftwareTitleId on fleet $FleetId", 'Update')) {
            $response = Invoke-FleetDMRequest -Endpoint "software/titles/$SoftwareTitleId/package" -Method PATCH -Form $form
            return (Get-FleetResponseRecord -Response $response -Name 'software_installer' -TypeName 'FleetDM.SoftwarePackage')
        }
    }
}
