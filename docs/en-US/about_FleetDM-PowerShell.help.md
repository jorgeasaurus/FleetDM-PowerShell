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
