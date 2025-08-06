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
        @{ Name = 'psake'; MinimumVersion = '4.9.0' }
        @{ Name = 'BuildHelpers'; MinimumVersion = '2.0.0' }
        @{ Name = 'PSScriptAnalyzer'; MinimumVersion = '1.19.0' }
        @{ Name = 'PowerShellGet'; MinimumVersion = '2.2.5' }
        @{ Name = 'platyPS'; MinimumVersion = '0.14.2' }
    )

    foreach ($module in $modules) {
        if (!(Get-Module -Name $module.Name -ListAvailable | Where-Object { $_.Version -ge $module.MinimumVersion })) {
            Write-Host "Installing $($module.Name) v$($module.MinimumVersion)..." -ForegroundColor Yellow
            Install-Module @module -Force -AllowClobber -SkipPublisherCheck -Scope CurrentUser
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

# Import required modules
$requiredModules = @('psake', 'BuildHelpers')
foreach ($module in $requiredModules) {
    if (!(Get-Module -Name $module -ListAvailable)) {
        Write-Error "Required module '$module' is not installed. Run './build.ps1 -Bootstrap' first."
        exit 1
    }
    Import-Module $module -Force
}

# Set BuildHelpers variables
Set-BuildEnvironment -Force

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