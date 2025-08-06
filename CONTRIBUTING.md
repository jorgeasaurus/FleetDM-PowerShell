# Contributing to FleetDM-PowerShell

Thank you for your interest in contributing to the FleetDM-PowerShell module! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct: be respectful, inclusive, and constructive in all interactions.

## How to Contribute

### Reporting Issues

1. Check existing issues to avoid duplicates
2. Use issue templates when available
3. Provide clear descriptions and steps to reproduce
4. Include error messages and system information

### Submitting Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following our coding standards
4. Write or update tests for your changes
5. Run the build and tests locally
6. Commit with clear messages (`git commit -m 'Add amazing feature'`)
7. Push to your fork (`git push origin feature/amazing-feature`)
8. Open a Pull Request with a clear description

## Development Setup

### Prerequisites

- PowerShell 5.1 or PowerShell Core 7+
- Git
- A FleetDM instance for testing (optional)

### Setting Up Your Development Environment

1. Clone the repository:
   ```powershell
   git clone https://github.com/Jorgeasaurus/FleetDM-PowerShell.git
   cd FleetDM-PowerShell
   ```

2. Install build dependencies:
   ```powershell
   ./build.ps1 -Bootstrap
   ```

3. Build the module:
   ```powershell
   ./build.ps1 -Task Build
   ```

4. Run tests:
   ```powershell
   ./build.ps1 -Task Test
   ```

## Coding Standards

### PowerShell Best Practices

- Use approved verbs for cmdlet names (Get-Verb)
- Follow [PowerShell Practice and Style Guide](https://poshcode.gitbook.io/powershell-practice-and-style/)
- Include comment-based help for all public functions
- Use PascalCase for cmdlet names and parameters
- Use camelCase for variables
- Avoid aliases in scripts

### Code Style

- Indentation: 4 spaces (no tabs)
- Opening braces on same line
- Use full cmdlet names (no aliases)
- Include parameter types
- Use ShouldProcess for destructive operations

Example:
```powershell
function Get-Example {
    <#
    .SYNOPSIS
        Gets an example object
    
    .DESCRIPTION
        Detailed description of what this function does
    
    .PARAMETER Name
        The name of the example
    
    .EXAMPLE
        Get-Example -Name "Test"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
    
    process {
        # Implementation here
    }
}
```

### Testing

- Write Pester tests for all new functionality
- Maintain or improve code coverage
- Mock external dependencies
- Test both success and failure scenarios
- Include edge cases

### Documentation

- Update README.md for new features
- Include comment-based help for cmdlets
- Update CHANGELOG.md following Keep a Changelog format
- Add examples for complex functionality

## Build System

This project uses PSStucco standards with psake for building:

- `./build.ps1 -Task Build` - Build the module
- `./build.ps1 -Task Test` - Run Pester tests
- `./build.ps1 -Task Analyze` - Run PSScriptAnalyzer
- `./build.ps1 -Task Deploy` - Deploy to local module path

## Release Process

1. Update version in module manifest
2. Update CHANGELOG.md
3. Create a git tag: `git tag v1.0.0`
4. Push tags: `git push origin --tags`
5. GitHub Actions will automatically publish to PowerShell Gallery

## Questions?

Feel free to open an issue for questions or discussions about potential changes.