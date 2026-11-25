function New-FleetSoftwarePackage {
    <#
    .SYNOPSIS
        Uploads a software installer to a fleet.

    .DESCRIPTION
        Sends POST /api/v1/fleet/software/package as multipart/form-data.
        The installer is streamed from disk through a temporary multipart file, so it is not loaded into memory.
        Supported files are .pkg, .msi, .exe, .deb, .rpm, .tar.gz, .ipa, .sh, .py, and .ps1.
        Only one of LabelsIncludeAll, LabelsIncludeAny, and LabelsExcludeAny can be used.

    .PARAMETER Path
        Local installer or script file.

    .PARAMETER FleetId
        Fleet that receives the installer. Use 0 for "Unassigned" hosts.

    .PARAMETER InstallScript
        Install script. Required for .exe and .tar.gz.

    .PARAMETER UninstallScript
        Uninstall script. Required for .exe and .tar.gz.

    .PARAMETER PreInstallQuery
        osquery condition. Fleet installs only when the query returns a row.

    .PARAMETER PostInstallScript
        Script run after install. A non-zero exit rolls back the install.

    .PARAMETER SelfService
        Lets end users install the software from Fleet Desktop.

    .PARAMETER AutomaticInstall
        Creates a policy that installs the software on hosts that lack it.

    .PARAMETER LabelsIncludeAll
        Targets hosts that have all of these labels.

    .PARAMETER LabelsIncludeAny
        Targets hosts that have any of these labels.

    .PARAMETER LabelsExcludeAny
        Skips hosts that have any of these labels.

    .EXAMPLE
        New-FleetSoftwarePackage -Path ./FalconSensor.pkg -FleetId 2 -SelfService -LabelsExcludeAny 'Servers'

    .EXAMPLE
        New-FleetSoftwarePackage -Path ./tool.exe -FleetId 2 -InstallScript 'tool.exe /S' -UninstallScript 'tool.exe /uninstall /S'

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        The request body limit is 10 GB.
        https://fleetdm.com/docs/rest-api/rest-api#add-package

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#add-package
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.SoftwarePackage')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [string]$InstallScript,

        [string]$UninstallScript,

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

    $form = [ordered]@{
        fleet_id = $FleetId
        software = (Get-FleetUploadFile -Path $Path -Stream)
    }
    $fields = [ordered]@{
        InstallScript = 'install_script'
        UninstallScript = 'uninstall_script'
        PreInstallQuery = 'pre_install_query'
        PostInstallScript = 'post_install_script'
    }
    foreach ($name in $fields.Keys) {
        if ($PSBoundParameters.ContainsKey($name)) { $form[$fields[$name]] = $PSBoundParameters[$name] }
    }
    if ($SelfService) { $form['self_service'] = $true }
    if ($AutomaticInstall) { $form['automatic_install'] = $true }
    Add-FleetLabelTarget -Target $form -BoundParameters $PSBoundParameters -SingleMode

    if ($PSCmdlet.ShouldProcess("installer '$($form.software.FileName)' on fleet $FleetId", 'Upload')) {
        $response = Invoke-FleetDMRequest -Endpoint 'software/package' -Method POST -Form $form
        return (Get-FleetResponseRecord -Response $response -Name 'software_package' -TypeName 'FleetDM.SoftwarePackage')
    }
}
