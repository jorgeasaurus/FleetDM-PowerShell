---
layout: default
title: Home
---

# FleetDM-PowerShell Documentation

Welcome to the FleetDM-PowerShell module documentation. This module provides comprehensive PowerShell cmdlets for managing and interacting with FleetDM instances through the REST API.

## Quick Start

```powershell
# Install the module from PowerShell Gallery
Install-Module -Name FleetDM-PowerShell

# Import the module
Import-Module FleetDM-PowerShell

# Connect to FleetDM
$token = Read-Host -AsSecureString "Enter API Token"
Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $token

# Get all online hosts
Get-FleetHost -Status online
```

## Available Documentation

### Cmdlet Reference

#### Authentication
- [Connect-FleetDM](docs/en-US/Connect-FleetDM.md) - Connect to a FleetDM instance
- [Disconnect-FleetDM](docs/en-US/Disconnect-FleetDM.md) - Disconnect from FleetDM

#### Host Management
- [Get-FleetHost](docs/en-US/Get-FleetHost.md) - Retrieve host information
- [Remove-FleetHost](docs/en-US/Remove-FleetHost.md) - Remove a host from Fleet

#### Policies
- [Get-FleetPolicy](docs/en-US/Get-FleetPolicy.md) - Get policy information
- [New-FleetPolicy](docs/en-US/New-FleetPolicy.md) - Create a new policy
- [Set-FleetPolicy](docs/en-US/Set-FleetPolicy.md) - Update an existing policy

#### Queries
- [Get-FleetQuery](docs/en-US/Get-FleetQuery.md) - Get saved queries
- [Invoke-FleetQuery](docs/en-US/Invoke-FleetQuery.md) - Execute a live query
- [Invoke-FleetSavedQuery](docs/en-US/Invoke-FleetSavedQuery.md) - Execute a saved query

#### Software
- [Get-FleetSoftware](docs/en-US/Get-FleetSoftware.md) - Get software inventory

#### Core
- [Invoke-FleetDMMethod](docs/en-US/Invoke-FleetDMMethod.md) - Direct API access

### Additional Resources

- [About FleetDM-PowerShell](docs/en-US/about_FleetDM-PowerShell.help.md)
- [Module Overview](README.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [License](LICENSE)

## Installation

### From PowerShell Gallery

```powershell
Install-Module -Name FleetDM-PowerShell -Scope CurrentUser
```

### From GitHub

```powershell
git clone https://github.com/Jorgeasaurus/FleetDM-PowerShell.git
Import-Module ./FleetDM-PowerShell/FleetDM-PowerShell.psd1
```

## Getting Help

For detailed help on any cmdlet, use PowerShell's built-in help system:

```powershell
Get-Help Connect-FleetDM -Full
Get-Help Get-FleetHost -Examples
```

## Links

- [GitHub Repository](https://github.com/Jorgeasaurus/FleetDM-PowerShell)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/FleetDM-PowerShell)
- [FleetDM Official Documentation](https://fleetdm.com/docs)