@{
    RootModule = 'FleetDM-PowerShell.psm1'
    ModuleVersion = '2.0.0'
    GUID = 'a7c4b8f3-2d1e-4f5a-9c8b-1e3d5a7f9b2c'
    Author = 'Jorge Suarez'
    CompanyName = 'Jorgeasaurus'
    Copyright = '(c) 2025 Jorgeasaurus. All rights reserved.'
    Description = 'Lightweight PowerShell module for FleetDM API integration. Provides cmdlets for managing hosts, queries, policies, and software inventory without requiring Premium licenses or external dependencies.'
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')

    # Functions to export from this module
    FunctionsToExport = @(
        'Connect-FleetDM',
        'Disconnect-FleetDM',
        'Get-FleetHost',
        'Remove-FleetHost',
        'Get-FleetQuery',
        'Invoke-FleetQuery',
        'Invoke-FleetSavedQuery',
        'Get-FleetPolicy',
        'New-FleetPolicy',
        'Set-FleetPolicy',
        'Get-FleetSoftware',
        'Invoke-FleetDMMethod'
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
            ReleaseNotes = 'Version 2.0.0 - Major release focusing exclusively on FleetDM Free Tier functionality.'
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
