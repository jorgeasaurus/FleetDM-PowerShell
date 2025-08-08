#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Generates documentation for the FleetDM-PowerShell module using PlatyPS
.DESCRIPTION
    This script uses PlatyPS to generate markdown documentation from the module's
    comment-based help and then compiles it into external MAML help files.
.EXAMPLE
    ./build-docs.ps1
    Generates all documentation files
.EXAMPLE
    ./build-docs.ps1 -UpdateExisting
    Updates existing markdown files without recreating them
#>

[CmdletBinding()]
param(
    [switch]$UpdateExisting,
    [switch]$SkipExternalHelp,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Module paths
$ModulePath = Join-Path $PSScriptRoot 'FleetDM-PowerShell.psd1'
$DocsPath = Join-Path $PSScriptRoot 'docs'
$LocalePath = Join-Path $DocsPath 'en-US'
$OutputPath = Join-Path $PSScriptRoot 'en-US'

Write-Host "FleetDM-PowerShell Documentation Generator" -ForegroundColor Cyan
Write-Host "==========================================`n" -ForegroundColor Cyan

# Check if PlatyPS is installed
Write-Host "Checking for PlatyPS module..." -ForegroundColor Yellow
if (!(Get-Module -ListAvailable -Name PlatyPS)) {
    Write-Host "PlatyPS not found. Installing..." -ForegroundColor Yellow
    Install-Module -Name PlatyPS -Scope CurrentUser -Force
}

# Import required modules
Write-Host "Importing modules..." -ForegroundColor Yellow
Import-Module PlatyPS -Force
Import-Module $ModulePath -Force

# Create documentation folder if it doesn't exist
if (!(Test-Path $LocalePath)) {
    Write-Host "Creating documentation folder structure..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $LocalePath -Force | Out-Null
}

# Get all exported commands
$Commands = Get-Command -Module FleetDM-PowerShell

Write-Host "`nFound $($Commands.Count) exported commands:" -ForegroundColor Green
$Commands | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }

# Generate or update markdown files
if ($UpdateExisting -and (Get-ChildItem -Path $LocalePath -Filter '*.md' -ErrorAction SilentlyContinue)) {
    Write-Host "`nUpdating existing markdown help files..." -ForegroundColor Yellow
    
    # Update existing markdown files
    Update-MarkdownHelp -Path $LocalePath -RefreshModulePage -Force:$Force
    
    Write-Host "Markdown files updated successfully!" -ForegroundColor Green
} else {
    Write-Host "`nGenerating new markdown help files..." -ForegroundColor Yellow
    
    # Clear existing markdown files if Force is specified
    if ($Force -and (Test-Path $LocalePath)) {
        Get-ChildItem -Path $LocalePath -Filter '*.md' | Remove-Item -Force
    }
    
    # Generate new markdown files for each command
    foreach ($Command in $Commands) {
        $MarkdownPath = Join-Path $LocalePath "$($Command.Name).md"
        
        if ((Test-Path $MarkdownPath) -and !$Force) {
            Write-Host "  Skipping $($Command.Name) (file exists)" -ForegroundColor Gray
        } else {
            Write-Host "  Generating help for $($Command.Name)" -ForegroundColor Gray
            New-MarkdownHelp -Command $Command.Name -OutputFolder $LocalePath -Force:$Force | Out-Null
        }
    }
    
    Write-Host "Markdown files generated successfully!" -ForegroundColor Green
}

# Generate module page
$ModulePage = Join-Path $LocalePath 'FleetDM-PowerShell.md'
if (!(Test-Path $ModulePage) -or $Force) {
    Write-Host "`nGenerating module page..." -ForegroundColor Yellow
    New-MarkdownHelp -Module FleetDM-PowerShell -OutputFolder $LocalePath -WithModulePage -Force:$Force | Out-Null
    Write-Host "Module page generated successfully!" -ForegroundColor Green
}

# Generate external help (MAML)
if (!$SkipExternalHelp) {
    Write-Host "`nGenerating external help XML (MAML)..." -ForegroundColor Yellow
    
    # Create output directory if it doesn't exist
    if (!(Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    
    # Generate external help
    New-ExternalHelp -Path $LocalePath -OutputPath $OutputPath -Force:$Force | Out-Null
    
    Write-Host "External help generated successfully!" -ForegroundColor Green
}

# Generate about topics
$AboutPath = Join-Path $LocalePath 'about_FleetDM-PowerShell.help.md'
if (!(Test-Path $AboutPath) -or $Force) {
    Write-Host "`nGenerating about topic..." -ForegroundColor Yellow
    
    $AboutContent = @'
# about_FleetDM-PowerShell

## SHORT DESCRIPTION
PowerShell module for interacting with the FleetDM API

## LONG DESCRIPTION
The FleetDM-PowerShell module provides a comprehensive set of cmdlets for managing and interacting 
with FleetDM instances through the REST API. This module simplifies fleet management tasks by 
providing PowerShell-native commands for common operations.

## Features

- **Authentication Management**: Connect to FleetDM instances using API tokens or credentials
- **Host Management**: Query, retrieve, and manage hosts in your fleet
- **Policy Management**: Create, update, and monitor compliance policies
- **Query Execution**: Run live queries and saved queries across your fleet
- **Software Inventory**: Track and manage software across all hosts

## Getting Started

### Installation

```powershell
Install-Module -Name FleetDM-PowerShell
```

### Basic Usage

1. Connect to your FleetDM instance:

```powershell
# Using API token
$token = Read-Host -AsSecureString "Enter API Token"
Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $token

# Using credentials
$cred = Get-Credential
Connect-FleetDM -BaseUri "https://fleet.example.com" -Credential $cred
```

2. Query hosts:

```powershell
# Get all online hosts
Get-FleetHost -Status online

# Get specific host with software inventory
Get-FleetHost -Id 123 -IncludeSoftware
```

3. Execute queries:

```powershell
# Run a live query
Invoke-FleetQuery -Query "SELECT * FROM system_info" -HostId 1,2,3

# Run a saved query
Invoke-FleetSavedQuery -QueryId 42 -HostId 1,2,3
```

## Authentication

The module supports multiple authentication methods:

1. **API Token**: Recommended for automation and scripting
2. **Username/Password**: Standard authentication with email and password
3. **API-Only Users**: Special users created for programmatic access

For SSO-enabled environments, obtain an API token through the FleetDM UI.

## Error Handling

The module provides comprehensive error handling with detailed messages for:
- Authentication failures
- Rate limiting
- Permission issues
- Network errors
- API validation errors

## Module Structure

The module organizes cmdlets into logical categories:

- **Authentication**: Connect-FleetDM, Disconnect-FleetDM
- **Hosts**: Get-FleetHost, Remove-FleetHost
- **Policies**: Get-FleetPolicy, New-FleetPolicy, Set-FleetPolicy
- **Queries**: Get-FleetQuery, Invoke-FleetQuery, Invoke-FleetSavedQuery
- **Software**: Get-FleetSoftware
- **Core**: Invoke-FleetDMMethod (for direct API access)

## Examples

### Example 1: Get all Windows hosts with failing policies

```powershell
Get-FleetHost -IncludePolicies | 
    Where-Object { $_.platform -eq 'windows' -and $_.issues.failing_policies_count -gt 0 }
```

### Example 2: Create a new policy

```powershell
New-FleetPolicy -Name "Firewall Enabled" `
    -Query "SELECT 1 FROM windows_firewall WHERE enabled = 1" `
    -Description "Ensures Windows Firewall is enabled" `
    -Platform "windows" `
    -Critical
```

### Example 3: Export software inventory

```powershell
Get-FleetSoftware | 
    Export-Csv -Path "software-inventory.csv" -NoTypeInformation
```

## NOTE

This module requires FleetDM version 4.0.0 or later. Some features may require specific
FleetDM configurations or permissions.

## TROUBLESHOOTING NOTE

If you encounter issues:
1. Verify your API token is valid
2. Check network connectivity to your FleetDM instance
3. Ensure you have appropriate permissions for the operations
4. Review the FleetDM server logs for additional details

## SEE ALSO

- FleetDM Documentation: https://fleetdm.com/docs
- FleetDM API Reference: https://fleetdm.com/docs/using-fleet/rest-api
- Module Repository: https://github.com/yourorg/FleetDM-PowerShell

## KEYWORDS
- FleetDM
- MDM
- Device Management
- Security
- Compliance
- osquery
'@

    $AboutContent | Set-Content -Path $AboutPath -Force
    Write-Host "About topic generated successfully!" -ForegroundColor Green
}

# Display summary
Write-Host "`n===========================================" -ForegroundColor Cyan
Write-Host "Documentation Generation Complete!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Cyan

Write-Host "`nGenerated files:" -ForegroundColor Yellow
Write-Host "  Markdown help files: $LocalePath" -ForegroundColor Gray

if (!$SkipExternalHelp) {
    Write-Host "  External help (MAML): $OutputPath" -ForegroundColor Gray
}

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Review and edit markdown files in $LocalePath" -ForegroundColor Gray
Write-Host "  2. Regenerate external help after edits: ./build-docs.ps1 -UpdateExisting" -ForegroundColor Gray
Write-Host "  3. Commit documentation to source control" -ForegroundColor Gray

# Validate help
Write-Host "`nValidating generated help..." -ForegroundColor Yellow
$ValidationErrors = @()

foreach ($Command in $Commands) {
    $Help = Get-Help $Command.Name -Full
    
    if (!$Help.Synopsis -or $Help.Synopsis -eq $Command.Name) {
        $ValidationErrors += "$($Command.Name): Missing synopsis"
    }
    
    if (!$Help.Description) {
        $ValidationErrors += "$($Command.Name): Missing description"
    }
    
    if (!$Help.Examples) {
        $ValidationErrors += "$($Command.Name): No examples provided"
    }
}

if ($ValidationErrors) {
    Write-Host "`nValidation warnings found:" -ForegroundColor Yellow
    $ValidationErrors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    Write-Host "`nConsider adding more detailed help to your functions" -ForegroundColor Gray
} else {
    Write-Host "All commands have complete help!" -ForegroundColor Green
}