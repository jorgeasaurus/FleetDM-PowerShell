#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick build script for FleetDM-PowerShell module that bypasses tests
.DESCRIPTION
    This script builds and deploys the module without running tests.
    Use this when you need to quickly build and deploy despite test failures.
.EXAMPLE
    ./build-quick.ps1
    Builds and deploys the module to the user's PowerShell modules directory
.EXAMPLE
    ./build-quick.ps1 -NoDeploy
    Only builds the module without deploying
#>
[CmdletBinding()]
param(
    [switch]$NoDeploy
)

$ErrorActionPreference = 'Stop'

Write-Host "FleetDM-PowerShell Quick Build Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Set paths
$ProjectRoot = $PSScriptRoot
$ModuleName = 'FleetDM-PowerShell'
$OutputDir = Join-Path $ProjectRoot 'Output'
$OutputModuleDir = Join-Path $OutputDir $ModuleName

# Clean output directory
Write-Host "`n[1/3] Cleaning output directory..." -ForegroundColor Yellow
if (Test-Path $OutputDir) {
    Remove-Item $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputModuleDir -Force | Out-Null

# Build module
Write-Host "[2/3] Building module..." -ForegroundColor Yellow

# Copy module manifest
Write-Host "  - Copying module manifest"
Copy-Item -Path (Join-Path $ProjectRoot "$ModuleName.psd1") -Destination $OutputModuleDir -Force

# Copy module script
Write-Host "  - Copying module script"
Copy-Item -Path (Join-Path $ProjectRoot "$ModuleName.psm1") -Destination $OutputModuleDir -Force

# Copy Public functions
Write-Host "  - Copying Public functions"
$publicPath = Join-Path $OutputModuleDir 'Public'
Copy-Item -Path (Join-Path $ProjectRoot 'Public') -Destination $OutputModuleDir -Recurse -Force

# Copy Private functions
Write-Host "  - Copying Private functions"
$privatePath = Join-Path $OutputModuleDir 'Private'
Copy-Item -Path (Join-Path $ProjectRoot 'Private') -Destination $OutputModuleDir -Recurse -Force

# Copy help files if they exist
if (Test-Path (Join-Path $ProjectRoot "en-US")) {
    Write-Host "  - Copying help files"
    Copy-Item -Path (Join-Path $ProjectRoot "en-US") -Destination $OutputModuleDir -Recurse -Force
}

Write-Host "✅ Module built successfully!" -ForegroundColor Green
Write-Host "   Output: $OutputModuleDir" -ForegroundColor Gray

# Deploy module if not skipped
if (-not $NoDeploy) {
    Write-Host "`n[3/3] Deploying module..." -ForegroundColor Yellow
    
    $deployPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell' 'Modules' $ModuleName
    
    if (Test-Path $deployPath) {
        Write-Host "  - Removing existing module"
        Remove-Item $deployPath -Recurse -Force
    }
    
    Write-Host "  - Copying module to: $deployPath"
    Copy-Item -Path $OutputModuleDir -Destination $deployPath -Recurse -Force
    
    Write-Host "✅ Module deployed successfully!" -ForegroundColor Green
    
    # Test import
    Write-Host "`nTesting module import..." -ForegroundColor Yellow
    try {
        Import-Module $deployPath -Force -ErrorAction Stop
        $commands = Get-Command -Module $ModuleName
        Write-Host "✅ Module imported successfully with $($commands.Count) commands" -ForegroundColor Green
        Write-Host "`nAvailable commands:" -ForegroundColor Cyan
        $commands | Select-Object -ExpandProperty Name | ForEach-Object { Write-Host "  - $_" }
    }
    catch {
        Write-Warning "Module import test failed: $_"
    }
} else {
    Write-Host "`n[3/3] Deployment skipped (use without -NoDeploy to deploy)" -ForegroundColor Gray
}

Write-Host "`n✨ Build complete!" -ForegroundColor Green
Write-Host "To use the module, run:" -ForegroundColor Cyan
Write-Host "  Import-Module FleetDM-PowerShell" -ForegroundColor White
Write-Host "  Connect-FleetDM -BaseUri 'https://your-fleet.com' -ApiToken (ConvertTo-SecureString 'token' -AsPlainText -Force)" -ForegroundColor White