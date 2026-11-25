@{
    RootModule = 'FleetDM-PowerShell.psm1'
    ModuleVersion = '2.3.0'
    GUID = 'a7c4b8f3-2d1e-4f5a-9c8b-1e3d5a7f9b2c'
    Author = 'Jorge Suarez'
    CompanyName = 'Jorgeasaurus'
    Copyright = '(c) 2025 Jorgeasaurus. All rights reserved.'
    Description = 'PowerShell module for the FleetDM REST API. Free-tier cmdlets cover hosts, reports, policies, scripts, configuration profiles, software inventory, and company-owned Android wipe. Fleet Premium cmdlets cover fleets, software installers and App Store apps, self-service, MDM, host secrets, setup experience, enrollment tokens, conditional access, host wipe for other platforms, OS updates, policy automations, calendar, and SSO JIT provisioning.'
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')

    # Functions to export from this module
    FunctionsToExport = @(
        'Connect-FleetDM',
        'Disconnect-FleetDM',
        'New-FleetUser',
        'Get-FleetHost',
        'Remove-FleetHost',
        'Get-FleetQuery',
        'Invoke-FleetQuery',
        'Invoke-FleetSavedQuery',
        'Get-FleetPolicy',
        'New-FleetPolicy',
        'Set-FleetPolicy',
        'Remove-FleetPolicy',
        'Get-FleetSoftware',
        'Get-FleetSoftwareTitle',
        'New-FleetSoftwarePackage',
        'Set-FleetSoftwarePackage',
        'Save-FleetSoftwarePackage',
        'Get-FleetMaintainedApp',
        'Add-FleetMaintainedApp',
        'Get-FleetAppStoreApp',
        'Add-FleetAppStoreApp',
        'Set-FleetAppStoreApp',
        'Get-FleetPatchDeadline',
        'Set-FleetPatchDeadline',
        'Invoke-FleetDMMethod',
        'Get-FleetTeam',
        'New-FleetTeam',
        'Set-FleetTeam',
        'Remove-FleetTeam',
        'Add-FleetTeamUser',
        'Set-FleetTeamAgentOption',
        'Install-FleetSoftware',
        'Uninstall-FleetSoftware',
        'Get-FleetSoftwareInstall',
        'Remove-FleetSoftwarePackage',
        'Get-FleetSelfServiceCategory',
        'New-FleetSelfServiceCategory',
        'Set-FleetSelfServiceCategory',
        'Remove-FleetSelfServiceCategory',
        'Lock-FleetHost',
        'Unlock-FleetHost',
        'Invoke-FleetHostWipe',
        'Get-FleetHostWipeStatus',
        'Get-FleetHostSecret',
        'Reset-FleetHostSecret',
        'Clear-FleetHostPasscode',
        'Get-FleetMdmCommand',
        'Stop-FleetHostMdmCommand',
        'Move-FleetHost',
        'Set-FleetHostNameTemplate',
        'Get-FleetDiskEncryption',
        'Set-FleetDiskEncryption',
        'Set-FleetOsUpdate',
        'Set-FleetCalendarEvent',
        'Get-FleetConfigurationProfile',
        'New-FleetConfigurationProfile',
        'Set-FleetConfigurationProfile',
        'Remove-FleetConfigurationProfile',
        'Sync-FleetConfigurationProfile',
        'Send-FleetConfigurationProfile',
        'Install-FleetConfigurationProfile',
        'Uninstall-FleetConfigurationProfile',
        'Get-FleetSetupExperienceSoftware',
        'Set-FleetSetupExperienceSoftware',
        'Get-FleetSetupExperienceScript',
        'Set-FleetSetupExperienceScript',
        'Remove-FleetSetupExperienceScript',
        'Get-FleetEula',
        'Set-FleetEula',
        'Remove-FleetEula',
        'Get-FleetBootstrapPackage',
        'Set-FleetBootstrapPackage',
        'Remove-FleetBootstrapPackage',
        'Get-FleetPolicyAutomation',
        'Reset-FleetPolicyAutomation',
        'Get-FleetScript',
        'Invoke-FleetScript',
        'Remove-FleetScript',
        'New-FleetScript',
        'Set-FleetScript',
        'Get-FleetScriptResult',
        'Start-FleetScriptBatch',
        'Get-FleetScriptBatch',
        'Stop-FleetScriptBatch',
        'Set-FleetJitProvisioning',
        'Get-FleetGoogleConditionalAccess',
        'Set-FleetGoogleConditionalAccess',
        'Remove-FleetGoogleConditionalAccess',
        'Get-FleetMicrosoftGraphCredential',
        'Set-FleetMicrosoftGraphCredential',
        'Get-FleetAppleBusinessToken',
        'Get-FleetVppToken',
        'Add-FleetVppToken',
        'Set-FleetVppTokenFleet',
        'Get-FleetEnrollmentProfile',
        'Set-FleetEnrollmentProfile',
        'Remove-FleetEnrollmentProfile'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            Tags = @('FleetDM', 'MDM', 'Security', 'API', 'DeviceManagement', 'Osquery', 'PSEdition_Desktop', 'PSEdition_Core', 'Windows', 'Linux', 'MacOS')
            LicenseUri = 'https://github.com/Jorgeasaurus/FleetDM-PowerShell/blob/main/LICENSE'
            ProjectUri = 'https://github.com/Jorgeasaurus/FleetDM-PowerShell'
            IconUri = ''
            ReleaseNotes = 'Version 2.3.0 - Adds 58 cmdlets, Fleet error reasons in messages, and multipart uploads and downloads for Windows PowerShell 5.1 and PowerShell 7. New cmdlets cover policy deletion, scripts and batch runs, configuration profiles, software packages and App Store apps, host secrets and MDM commands, setup experience, enrollment tokens, conditional access, Graph credentials, and fleet admin settings. Empty lists sent as null no longer come back as a record. See CHANGELOG.md.'
            Prerelease = ''
            RequireLicenseAcceptance = $false
            ExternalModuleDependencies = @()
        }
    }

    # HelpInfo URI of this module
    HelpInfoURI = 'https://github.com/Jorgeasaurus/FleetDM-PowerShell/wiki'

    # Default prefix for commands exported from this module
    DefaultCommandPrefix = ''
}
