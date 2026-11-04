#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build script for FleetDM-PowerShell module
.DESCRIPTION
    This script is used to build, test, and publish the FleetDM-PowerShell module
    following PSStucco standards.
.PARAMETER Task
    The build task to execute. Default is 'Default' which runs build and test.
.PARAMETER Bootstrap
    If specified, installs required modules for building.
.PARAMETER Configuration
    Build configuration: Debug or Release. Default is Release.
.EXAMPLE
    .\build.ps1 -Bootstrap
    .\build.ps1 -Task Build
    .\build.ps1 -Task Test
    .\build.ps1 -Task Deploy
#>
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Default', 'Init', 'Clean', 'Build', 'Test', 'Analyze', 'Deploy', 'Publish')]
    [string]$Task = 'Default',

    [Parameter()]
    [switch]$Bootstrap,

    [Parameter()]
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',

    [Parameter()]
    [hashtable]$Parameters = @{}
)

# Bootstrap dependencies
if ($Bootstrap.IsPresent) {
    Write-Host 'Installing build dependencies...' -ForegroundColor Green
    $modules = @(
        @{ Name = 'Pester'; MinimumVersion = '5.0.0' }
        # psake 5 defines its own parameterless Set-BuildEnvironment. Tasks run
        # inside that module, so an unpinned install hides BuildHelpers\Set-BuildEnvironment -Force.
        @{ Name = 'psake'; RequiredVersion = '4.9.1' }
        @{ Name = 'BuildHelpers'; RequiredVersion = '2.0.16' }
        @{ Name = 'PSScriptAnalyzer'; MinimumVersion = '1.19.0' }
        @{ Name = 'PowerShellGet'; MinimumVersion = '2.2.5' }
        @{ Name = 'platyPS'; MinimumVersion = '0.14.2' }
    )

    foreach ($module in $modules) {
        $available = @(Get-Module -Name $module.Name -ListAvailable)
        $satisfied = if ($module.ContainsKey('RequiredVersion')) {
            $available | Where-Object { $_.Version -eq [version]$module.RequiredVersion }
        }
        else {
            $available | Where-Object { $_.Version -ge [version]$module.MinimumVersion }
        }

        if (-not $satisfied) {
            $versionLabel = if ($module.ContainsKey('RequiredVersion')) { $module.RequiredVersion } else { $module.MinimumVersion }
            Write-Host "Installing $($module.Name) v$versionLabel..." -ForegroundColor Yellow
            $installParams = @{
                Name               = $module.Name
                Force              = $true
                AllowClobber       = $true
                SkipPublisherCheck = $true
                Scope              = 'CurrentUser'
            }
            if ($module.ContainsKey('RequiredVersion')) {
                $installParams.RequiredVersion = $module.RequiredVersion
            }
            else {
                $installParams.MinimumVersion = $module.MinimumVersion
            }
            Install-Module @installParams
        }
        else {
            Write-Host "$($module.Name) already installed" -ForegroundColor Cyan
        }
    }
}

# Set build variables
$projectRoot = $PSScriptRoot
$moduleName = 'FleetDM-PowerShell'
$outputDir = Join-Path $projectRoot 'Output'
$outputModuleDir = Join-Path $outputDir $moduleName

# Import required modules. psake must be 4.9.1 even when 5.x is also installed.
$requiredModules = @(
    @{ Name = 'psake'; RequiredVersion = '4.9.1' }
    @{ Name = 'BuildHelpers'; RequiredVersion = '2.0.16' }
)
foreach ($module in $requiredModules) {
    $available = @(Get-Module -Name $module.Name -ListAvailable | Where-Object { $_.Version -eq [version]$module.RequiredVersion })
    if (-not $available) {
        Write-Error "Required module '$($module.Name)' $($module.RequiredVersion) is not installed. Run './build.ps1 -Bootstrap' first."
        exit 1
    }
    Import-Module $module.Name -RequiredVersion $module.RequiredVersion -Force
}

# Set BuildHelpers variables. Qualify the command so psake's private function cannot bind -Force.
BuildHelpers\Set-BuildEnvironment -Force

# Set additional parameters for psake
$psakeParameters = @{
    buildFile  = Join-Path $PSScriptRoot 'psake.ps1'
    taskList   = $Task
    nologo     = $true
    properties = @{
        ProjectRoot      = $projectRoot
        ModuleName       = $moduleName
        OutputDir        = $outputDir
        OutputModuleDir  = $outputModuleDir
        Configuration    = $Configuration
        TestsDir         = Join-Path $projectRoot 'Tests'
        SourceDir        = $projectRoot
    }
    parameters = $Parameters
}

# Execute psake
Invoke-psake @psakeParameters
exit ([int](-not $psake.build_success))