@{
    RootModule = 'FleetDM-PowerShell.psm1'
    ModuleVersion = '2.3.0'
    GUID = 'a7c4b8f3-2d1e-4f5a-9c8b-1e3d5a7f9b2c'
    Author = 'Jorge Suarez'
    CompanyName = 'Jorgeasaurus'
    Copyright = '(c) 2025 Jorgeasaurus. All rights reserved.'
    Description = 'PowerShell module for the FleetDM REST API. Free-tier cmdlets cover hosts, reports, policies, software inventory, and company-owned Android wipe. Fleet Premium cmdlets cover fleets, software installers, self-service, scripts, MDM, host wipe for other platforms, OS updates, policy automations, calendar, and SSO JIT provisioning.'
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
        'Get-FleetSoftware',
        'Invoke-FleetDMMethod',
        'Get-FleetTeam',
        'New-FleetTeam',
        'Set-FleetTeam',
        'Remove-FleetTeam',
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
        'Get-FleetDiskEncryption',
        'Set-FleetDiskEncryption',
        'Set-FleetOsUpdate',
        'Set-FleetCalendarEvent',
        'Get-FleetPolicyAutomation',
        'Reset-FleetPolicyAutomation',
        'Get-FleetScript',
        'Invoke-FleetScript',
        'Remove-FleetScript',
        'Set-FleetJitProvisioning'
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
            ReleaseNotes = 'Version 2.3.0 - Connect-FleetDM accepts an API-only token when GET /version returns 403, and requests retry HTTP 429 and gateway errors. Fixes #7 and #8.'
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
