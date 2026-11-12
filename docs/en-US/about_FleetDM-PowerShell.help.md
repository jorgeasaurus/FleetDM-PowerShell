# about_FleetDM-PowerShell

## SHORT DESCRIPTION
PowerShell module for interacting with the FleetDM API

## LONG DESCRIPTION
The FleetDM-PowerShell module provides a comprehensive set of cmdlets for managing and interacting 
with FleetDM instances through the REST API. This module simplifies fleet management tasks by 
providing PowerShell-native commands for common operations.

## Features

- **Authentication**: Connect with an API token, a credential, or email and password. Create an API-only user with `New-FleetUser`.
- **Hosts**: Query hosts, remove them, and on Fleet Premium lock, unlock, or wipe them.
- **Policies**: Create and update policies, including fleet policies and automation reset.
- **Queries**: Run live queries and saved queries.
- **Software**: Read inventory. Fleet Premium adds install, uninstall, and self-service categories.
- **Fleets, scripts, MDM, and SSO**: Fleet Premium cmdlets. Company-owned Android wipe is available in Fleet Free.

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

# Using email and password
$password = Read-Host "Password" -AsSecureString
Connect-FleetDM -BaseUri "https://fleet.example.com" -Email "admin@example.com" -Password $password

# Create an API-only user from that admin session, then use its token
$apiPassword = Read-Host "API user password" -AsSecureString
$apiUser = New-FleetUser -Name "module-test" -Email "api@example.com" -Password $apiPassword -ApiOnly -GlobalRole admin
$apiToken = ConvertTo-SecureString $apiUser.Token -AsPlainText -Force
Disconnect-FleetDM
Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $apiToken
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

1. **API Token**: Recommended for automation and scripting. API-only tokens do not expire.
2. **Email and password**: Same login as `fleetctl login --email --password`. SSO users cannot use a password.
3. **API-only users**: `New-FleetUser -ApiOnly` returns `Token`. That user cannot sign in to the Fleet UI. If the user is limited to specific endpoints, a token that can call `GET /api/v1/fleet/me` still connects when `GET /api/v1/fleet/version` returns 403. The connection version is null. `-SkipVersionCheck` skips the version call. HTTP 401 is an authentication failure.

For SSO-enabled environments, obtain an API token through the FleetDM UI.

Verbose request and connection logs redact `password`, token fields, and `Authorization` bearer values at any nesting depth, including arrays, objects, and secret query parameters. `New-FleetUser` still sends the password to Fleet. `-Verbose`, transcripts, and CI logs show the redacted text. Redaction does not change the request URI sent to Fleet. Do not put a secret in `Invoke-FleetDMMethod -Endpoint`: that cmdlet writes the endpoint string to the verbose log before redaction.

## Error Handling

The module provides comprehensive error handling with detailed messages for:
- Authentication failures
- Rate limiting
- Permission issues
- Network errors
- API validation errors

## Module Structure

The module organizes cmdlets into logical categories:

- **Authentication**: Connect-FleetDM, Disconnect-FleetDM, New-FleetUser, Set-FleetJitProvisioning
- **Hosts**: Get-FleetHost, Remove-FleetHost, Lock-FleetHost, Unlock-FleetHost, Invoke-FleetHostWipe, Get-FleetHostWipeStatus
- **Policies**: Get-FleetPolicy, New-FleetPolicy, Set-FleetPolicy, Get-FleetPolicyAutomation, Reset-FleetPolicyAutomation
- **Queries**: Get-FleetQuery, Invoke-FleetQuery, Invoke-FleetSavedQuery
- **Software**: Get-FleetSoftware, Install-FleetSoftware, Uninstall-FleetSoftware, Get-FleetSoftwareInstall, Remove-FleetSoftwarePackage, Get-FleetSelfServiceCategory, New-FleetSelfServiceCategory, Set-FleetSelfServiceCategory, Remove-FleetSelfServiceCategory
- **Fleets**: Get-FleetTeam, New-FleetTeam, Set-FleetTeam, Remove-FleetTeam
- **Scripts**: Get-FleetScript, Invoke-FleetScript, Remove-FleetScript
- **MDM**: Get-FleetDiskEncryption, Set-FleetDiskEncryption, Set-FleetOsUpdate, Set-FleetCalendarEvent
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
- Module Repository: https://github.com/Jorgeasaurus/FleetDM-PowerShell

## KEYWORDS
- FleetDM
- MDM
- Device Management
- Security
- Compliance
- osquery
