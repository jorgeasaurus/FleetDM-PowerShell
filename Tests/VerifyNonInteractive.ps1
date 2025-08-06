#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Verifies that all test files are non-interactive
.DESCRIPTION
    This script scans all test files to ensure they don't contain patterns
    that would require user interaction during test execution.
#>

param(
    [Parameter()]
    [string]$TestPath = $PSScriptRoot
)

Write-Host "Verifying Non-Interactive Test Execution" -ForegroundColor Green
Write-Host "Scanning: $TestPath" -ForegroundColor Cyan

# Define patterns that indicate interactive elements
$interactivePatterns = @{
    'Read-Host' = 'Direct user input prompts'
    'Get-Credential' = 'Credential prompts'
    '\$Host\.UI\.' = 'Host UI interactions'
    'Write-Host.*-NoNewline.*Read-Host' = 'Inline input prompts'
    'pause' = 'Pause commands'
    'choice' = 'Choice prompts'
    'ConfirmPreference.*High' = 'High impact confirmation'
    'ShouldContinue' = 'Continue prompts'
    'PromptForChoice' = 'Choice prompts'
}

# Define patterns that should be avoided without proper mocking
$riskyPatterns = @{
    'Invoke-RestMethod(?!.*Mock)' = 'Unmocked REST API calls'
    'Invoke-WebRequest(?!.*Mock)' = 'Unmocked web requests'
    'Connect-FleetDM.*localhost' = 'Connections to localhost'
    'Connect-FleetDM.*127\.0\.0\.1' = 'Connections to localhost IP'
}

# Define safe patterns (these are OK)
$safePatterns = @(
    'Mock',
    '-WhatIf',
    '-Force',
    'Confirm:\s*\$false',
    'WarningAction\s+(SilentlyContinue|Ignore)',
    'ErrorAction\s+(SilentlyContinue|Ignore)'
)

$issues = @()
$warnings = @()

# Get all test files
$testFiles = Get-ChildItem -Path $TestPath -Filter "*.Tests.ps1" -Recurse

Write-Host "`nScanning $($testFiles.Count) test files..." -ForegroundColor Yellow

foreach ($file in $testFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $relativePath = $file.FullName.Replace($TestPath, '').TrimStart('\', '/')
    
    Write-Host "  Checking: $relativePath" -ForegroundColor Gray
    
    # Check for interactive patterns
    foreach ($pattern in $interactivePatterns.Keys) {
        if ($content -match $pattern) {
            $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            foreach ($match in $matches) {
                # Get line number
                $lines = $content.Substring(0, $match.Index).Split("`n")
                $lineNumber = $lines.Count
                
                # Check if it's in a safe context (e.g., inside a Mock block or comment)
                $context = ""
                if ($lineNumber -gt 1) {
                    $contextLines = ($content -split "`n")[(($lineNumber - 3)..(($lineNumber + 2)) | Where-Object { $_ -ge 0 -and $_ -lt ($content -split "`n").Count })]
                    $context = $contextLines -join "`n"
                }
                
                $isSafe = $false
                foreach ($safePattern in $safePatterns) {
                    if ($context -match $safePattern) {
                        $isSafe = $true
                        break
                    }
                }
                
                if (-not $isSafe) {
                    $issues += [PSCustomObject]@{
                        File = $relativePath
                        Line = $lineNumber
                        Pattern = $pattern
                        Description = $interactivePatterns[$pattern]
                        Match = $match.Value
                        Severity = 'Error'
                    }
                }
            }
        }
    }
    
    # Check for risky patterns  
    foreach ($pattern in $riskyPatterns.Keys) {
        if ($content -match $pattern) {
            $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            foreach ($match in $matches) {
                $lines = $content.Substring(0, $match.Index).Split("`n")
                $lineNumber = $lines.Count
                
                $warnings += [PSCustomObject]@{
                    File = $relativePath
                    Line = $lineNumber
                    Pattern = $pattern
                    Description = $riskyPatterns[$pattern]
                    Match = $match.Value
                    Severity = 'Warning'
                }
            }
        }
    }
}

# Report results
Write-Host "`n" + "="*60 -ForegroundColor Blue
Write-Host "NON-INTERACTIVE VERIFICATION RESULTS" -ForegroundColor Blue
Write-Host "="*60 -ForegroundColor Blue

if ($issues.Count -eq 0) {
    Write-Host "✅ No interactive elements found!" -ForegroundColor Green
} else {
    Write-Host "❌ Found $($issues.Count) potential interactive elements:" -ForegroundColor Red
    
    foreach ($issue in $issues) {
        Write-Host "`n📁 $($issue.File):$($issue.Line)" -ForegroundColor Yellow
        Write-Host "   Pattern: $($issue.Pattern)" -ForegroundColor Red
        Write-Host "   Issue: $($issue.Description)" -ForegroundColor Red
        Write-Host "   Match: $($issue.Match)" -ForegroundColor Gray
    }
}

if ($warnings.Count -gt 0) {
    Write-Host "`n⚠️  Found $($warnings.Count) warnings:" -ForegroundColor Yellow
    
    foreach ($warning in $warnings) {
        Write-Host "`n📁 $($warning.File):$($warning.Line)" -ForegroundColor Cyan
        Write-Host "   Pattern: $($warning.Pattern)" -ForegroundColor Yellow
        Write-Host "   Warning: $($warning.Description)" -ForegroundColor Yellow
        Write-Host "   Match: $($warning.Match)" -ForegroundColor Gray
    }
}

# Check for proper test structure
Write-Host "`n📋 Test Structure Analysis:" -ForegroundColor Cyan

$testStructure = @{
    'BeforeAll blocks' = ($testFiles | ForEach-Object { (Get-Content $_.FullName -Raw) -split 'BeforeAll' }).Count - $testFiles.Count
    'Mock statements' = ($testFiles | ForEach-Object { [regex]::Matches((Get-Content $_.FullName -Raw), 'Mock ', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) }).Count
    'WhatIf usage' = ($testFiles | ForEach-Object { [regex]::Matches((Get-Content $_.FullName -Raw), '-WhatIf', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) }).Count
    'Force usage' = ($testFiles | ForEach-Object { [regex]::Matches((Get-Content $_.FullName -Raw), '-Force', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) }).Count
}

foreach ($key in $testStructure.Keys) {
    Write-Host "   $key`: $($testStructure[$key])" -ForegroundColor Gray
}

Write-Host "`n📊 Summary:" -ForegroundColor Cyan
Write-Host "   Test Files: $($testFiles.Count)" -ForegroundColor Gray
Write-Host "   Interactive Issues: $($issues.Count)" -ForegroundColor $(if ($issues.Count -eq 0) { 'Green' } else { 'Red' })
Write-Host "   Warnings: $($warnings.Count)" -ForegroundColor $(if ($warnings.Count -eq 0) { 'Green' } else { 'Yellow' })

Write-Host "="*60 -ForegroundColor Blue

# Exit with appropriate code
if ($issues.Count -gt 0) {
    Write-Host "❌ Tests may require user interaction!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ All tests appear to be non-interactive!" -ForegroundColor Green
    exit 0
}