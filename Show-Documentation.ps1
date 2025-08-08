#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Displays FleetDM-PowerShell module documentation
.DESCRIPTION
    This script provides an interactive way to view the module documentation
    either in the console or by opening the markdown files in the default editor.
.PARAMETER Command
    The specific command to show help for
.PARAMETER Online
    Opens the documentation in the default web browser (if GitHub Pages is set up)
.PARAMETER Editor
    Opens the markdown file in the default editor
.EXAMPLE
    ./Show-Documentation.ps1
    Shows interactive menu of available documentation
.EXAMPLE
    ./Show-Documentation.ps1 -Command Get-FleetHost
    Shows documentation for Get-FleetHost
.EXAMPLE
    ./Show-Documentation.ps1 -Command Get-FleetHost -Editor
    Opens Get-FleetHost.md in the default editor
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$Command,
    
    [Parameter()]
    [switch]$Online,
    
    [Parameter()]
    [switch]$Editor
)

$ErrorActionPreference = 'Stop'

# Configuration
$ModuleName = 'FleetDM-PowerShell'
$DocsPath = Join-Path $PSScriptRoot 'docs' 'en-US'
$GitHubPagesUrl = 'https://jorgeasaurus.github.io/FleetDM-PowerShell'

# Check if documentation exists
if (!(Test-Path $DocsPath)) {
    Write-Host "Documentation not found. Generating..." -ForegroundColor Yellow
    & "$PSScriptRoot/build-docs.ps1"
}

# Import module to get command list
Import-Module "$PSScriptRoot/$ModuleName.psd1" -Force

if ($Online) {
    # Open online documentation
    if ($Command) {
        $url = "$GitHubPagesUrl/docs/en-US/$Command.html"
    } else {
        $url = $GitHubPagesUrl
    }
    
    Write-Host "Opening documentation in browser: $url" -ForegroundColor Green
    Start-Process $url
    return
}

if ($Command) {
    # Show specific command documentation
    $docFile = Join-Path $DocsPath "$Command.md"
    
    if (!(Test-Path $docFile)) {
        # Try to find command with wildcard
        $matches = Get-ChildItem $DocsPath -Filter "*$Command*.md"
        
        if ($matches.Count -eq 0) {
            Write-Host "No documentation found for '$Command'" -ForegroundColor Red
            Write-Host "Available commands:" -ForegroundColor Yellow
            Get-Command -Module $ModuleName | ForEach-Object { Write-Host "  - $($_.Name)" }
            return
        } elseif ($matches.Count -eq 1) {
            $docFile = $matches[0].FullName
            $Command = $matches[0].BaseName
        } else {
            Write-Host "Multiple matches found for '$Command':" -ForegroundColor Yellow
            $matches | ForEach-Object { Write-Host "  - $($_.BaseName)" }
            return
        }
    }
    
    if ($Editor) {
        # Open in default editor
        Write-Host "Opening $Command documentation in editor..." -ForegroundColor Green
        Invoke-Item $docFile
    } else {
        # Display in console with formatting
        Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
        Write-Host " $Command Documentation" -ForegroundColor Cyan
        Write-Host "$('=' * 60)`n" -ForegroundColor Cyan
        
        # Read and display markdown with basic formatting
        $content = Get-Content $docFile -Raw
        
        # Convert markdown to readable console output
        $formatted = $content -split "`n" | ForEach-Object {
            if ($_ -match '^#{1,6}\s+(.+)') {
                # Headers
                $level = ($_ -split ' ')[0].Length
                $text = $matches[1]
                
                switch ($level) {
                    1 { Write-Host "`n$text" -ForegroundColor Green; Write-Host "$('=' * $text.Length)" -ForegroundColor Green }
                    2 { Write-Host "`n$text" -ForegroundColor Yellow; Write-Host "$('-' * $text.Length)" -ForegroundColor Yellow }
                    default { Write-Host "`n$text" -ForegroundColor Cyan }
                }
            }
            elseif ($_ -match '^\s*```') {
                # Code blocks
                ''  # Skip code fence markers
            }
            elseif ($_ -match '^\s*-\s+(.+)') {
                # Bullet points
                Write-Host "  • $($matches[1])"
            }
            elseif ($_.Trim()) {
                # Regular text
                Write-Host $_
            }
            else {
                # Empty lines
                ''
            }
        }
        
        Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
    }
} else {
    # Show interactive menu
    Clear-Host
    Write-Host @"
╔════════════════════════════════════════════════════════════╗
║           FleetDM-PowerShell Documentation Viewer          ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    $commands = Get-Command -Module $ModuleName | Sort-Object Name
    $topics = @(
        @{ Name = 'About Module'; File = 'about_FleetDM-PowerShell.help.md' }
        @{ Name = 'Module Overview'; File = 'FleetDM-PowerShell.md' }
    )
    
    Write-Host "`nAvailable Documentation:" -ForegroundColor Yellow
    Write-Host "`nCmdlets:" -ForegroundColor Green
    for ($i = 0; $i -lt $commands.Count; $i++) {
        Write-Host ("  [{0,2}] {1}" -f ($i + 1), $commands[$i].Name)
    }
    
    Write-Host "`nTopics:" -ForegroundColor Green
    for ($i = 0; $i -lt $topics.Count; $i++) {
        $index = $commands.Count + $i + 1
        Write-Host ("  [{0,2}] {1}" -f $index, $topics[$i].Name)
    }
    
    Write-Host "`nOptions:" -ForegroundColor Green
    Write-Host "  [R]  Regenerate Documentation"
    Write-Host "  [O]  Open Online Documentation"
    Write-Host "  [Q]  Quit"
    
    Write-Host "`nEnter selection: " -ForegroundColor Yellow -NoNewline
    $selection = Read-Host
    
    switch ($selection) {
        'Q' { return }
        'R' {
            Write-Host "`nRegenerating documentation..." -ForegroundColor Yellow
            & "$PSScriptRoot/build-docs.ps1"
            Write-Host "`nPress any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            & $PSCommandPath
        }
        'O' {
            Write-Host "Opening online documentation..." -ForegroundColor Green
            Start-Process $GitHubPagesUrl
        }
        default {
            if ($selection -match '^\d+$') {
                $index = [int]$selection - 1
                
                if ($index -ge 0 -and $index -lt $commands.Count) {
                    # Show cmdlet documentation
                    & $PSCommandPath -Command $commands[$index].Name
                }
                elseif ($index -ge $commands.Count -and $index -lt ($commands.Count + $topics.Count)) {
                    # Show topic documentation
                    $topicIndex = $index - $commands.Count
                    $docFile = Join-Path $DocsPath $topics[$topicIndex].File
                    
                    if (Test-Path $docFile) {
                        Clear-Host
                        Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
                        Write-Host " $($topics[$topicIndex].Name)" -ForegroundColor Cyan
                        Write-Host "$('=' * 60)`n" -ForegroundColor Cyan
                        
                        Get-Content $docFile | ForEach-Object {
                            if ($_ -match '^#{1,6}\s+(.+)') {
                                Write-Host "`n$($matches[1])" -ForegroundColor Yellow
                            } else {
                                Write-Host $_
                            }
                        }
                        
                        Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
                    }
                }
                else {
                    Write-Host "Invalid selection" -ForegroundColor Red
                }
                
                Write-Host "`nPress any key to return to menu..." -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                & $PSCommandPath
            }
            else {
                Write-Host "Invalid selection" -ForegroundColor Red
                Start-Sleep -Seconds 2
                & $PSCommandPath
            }
        }
    }
}