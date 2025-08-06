#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Runs all Pester tests for FleetDM-PowerShell module without user interaction
.DESCRIPTION
    This script runs all tests in the Tests directory with settings that ensure
    no user interaction is required. It's designed for CI/CD environments.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$TestPath = $PSScriptRoot,
    
    [Parameter()]
    [switch]$CodeCoverage,
    
    [Parameter()]
    [string]$OutputFormat = 'NUnitXml',
    
    [Parameter()]
    [string]$OutputFile
)

# Ensure we're in non-interactive mode
$env:CI = 'true'
$ConfirmPreference = 'None'
$ProgressPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'

Write-Host "Running FleetDM-PowerShell Tests" -ForegroundColor Green
Write-Host "Test Path: $TestPath" -ForegroundColor Cyan
Write-Host "Interactive Mode: Disabled" -ForegroundColor Yellow

# Import Pester
try {
    Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop
    Write-Host "Pester Version: $((Get-Module Pester).Version)" -ForegroundColor Cyan
}
catch {
    Write-Error "Pester 5.0+ is required. Install it with: Install-Module Pester -Force"
    exit 1
}

# Configure Pester settings for non-interactive execution
$pesterConfiguration = [PesterConfiguration]::Default

# Discovery settings
$pesterConfiguration.Run.Path = $TestPath
$pesterConfiguration.Run.PassThru = $true

# Output settings
$pesterConfiguration.Output.Verbosity = 'Detailed'
$pesterConfiguration.Output.StackTraceVerbosity = 'Filtered'
$pesterConfiguration.Output.CIFormat = 'Auto'

# Test selection - exclude integration tests that might be problematic
$pesterConfiguration.Filter.ExcludeTag = @('Integration', 'Manual')

# Code coverage settings
if ($CodeCoverage) {
    $pesterConfiguration.CodeCoverage.Enabled = $true
    $pesterConfiguration.CodeCoverage.Path = Join-Path (Split-Path $TestPath -Parent) "Public" "**" "*.ps1"
    $pesterConfiguration.CodeCoverage.OutputFormat = 'JaCoCo'
    $pesterConfiguration.CodeCoverage.OutputPath = Join-Path $TestPath 'CodeCoverage.xml'
}

# Test result settings
if ($OutputFile) {
    $pesterConfiguration.TestResult.Enabled = $true
    $pesterConfiguration.TestResult.OutputFormat = $OutputFormat
    $pesterConfiguration.TestResult.OutputPath = $OutputFile
}

# Execution settings for non-interactive mode
$pesterConfiguration.Run.Exit = $false
$pesterConfiguration.Run.Throw = $false

try {
    Write-Host "`nStarting test execution..." -ForegroundColor Yellow
    
    # Run tests
    $testResults = Invoke-Pester -Configuration $pesterConfiguration
    
    # Display summary
    Write-Host "`n" + "="*50 -ForegroundColor Blue
    Write-Host "TEST EXECUTION SUMMARY" -ForegroundColor Blue
    Write-Host "="*50 -ForegroundColor Blue
    Write-Host "Total Tests: $($testResults.TotalCount)" -ForegroundColor White
    Write-Host "Passed: $($testResults.PassedCount)" -ForegroundColor Green
    Write-Host "Failed: $($testResults.FailedCount)" -ForegroundColor $(if ($testResults.FailedCount -gt 0) { 'Red' } else { 'Green' })
    Write-Host "Skipped: $($testResults.SkippedCount)" -ForegroundColor Yellow
    Write-Host "Inconclusive: $($testResults.NotRunCount)" -ForegroundColor Gray
    Write-Host "Duration: $($testResults.Duration)" -ForegroundColor Cyan
    
    if ($CodeCoverage -and $testResults.CodeCoverage) {
        Write-Host "Code Coverage: $([math]::Round($testResults.CodeCoverage.CoveragePercent, 2))%" -ForegroundColor Cyan
    }
    
    Write-Host "="*50 -ForegroundColor Blue
    
    # Exit with appropriate code
    if ($testResults.FailedCount -gt 0) {
        Write-Host "Some tests failed!" -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host "All tests passed!" -ForegroundColor Green
        exit 0
    }
}
catch {
    Write-Error "Test execution failed: $($_.Exception.Message)"
    Write-Error $_.ScriptStackTrace
    exit 1
}