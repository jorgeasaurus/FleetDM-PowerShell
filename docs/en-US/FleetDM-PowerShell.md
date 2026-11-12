---
Module Name: FleetDM-PowerShell
Module Guid: a7c4b8f3-2d1e-4f5a-9c8b-1e3d5a7f9b2c
Download Help Link: https://github.com/Jorgeasaurus/FleetDM-PowerShell/wiki
Help Version: 2.3.0.0
Locale: en-US
---

# FleetDM-PowerShell Module

## Description

PowerShell module for the FleetDM REST API. Free-tier cmdlets cover hosts, reports, policies, and software inventory. Fleet Premium cmdlets cover fleets, software installers, self-service, scripts, MDM, host wipe for other platforms, OS updates, policy automations, calendar, and SSO just-in-time provisioning.

The documentation home has longer examples: [index.md](../../index.md).

## Sign in and create an API token

Log in with the same email and password as `fleetctl login`. Then create an API-only user. Fleet returns `Token` only when `-ApiOnly` is set. Connect later sessions with that token. Do not paste passwords into scripts.

```powershell
$password = Read-Host "Password" -AsSecureString
Connect-FleetDM -BaseUri "https://fleet.example.com" -Email "admin@example.com" -Password $password

$apiPassword = Read-Host "API user password" -AsSecureString
$apiUser = New-FleetUser -Name "module-test" -Email "api@example.com" -Password $apiPassword -ApiOnly -GlobalRole admin

$apiToken = ConvertTo-SecureString $apiUser.Token -AsPlainText -Force
Disconnect-FleetDM
Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $apiToken
```

You must already be connected as an admin before `New-FleetUser`. `-GlobalRole` accepts `admin`, `maintainer`, `observer`, `observer_plus`, and `gitops`. SSO users cannot use the password login.

## Examples for cmdlets added in 2.2.0

Premium commands fail with a Fleet Premium error on Fleet Free. Changing commands prompt before they run. Company-owned Android wipe is Fleet Free. Other host wipes require Premium.

```powershell
Get-FleetTeam
New-FleetTeam -Name "Workstations"
Set-FleetTeam -Id 1 -HostId 3, 6

Install-FleetSoftware -HostId 123 -SoftwareTitleId 3435
Get-FleetSoftwareInstall -InstallUuid "b15ce221-e22e-4c6a-afe7-5b3400a017da"
Uninstall-FleetSoftware -HostId 123 -SoftwareTitleId 3435
Remove-FleetSoftwarePackage -SoftwareTitleId 3435 -FleetId 2

Get-FleetSelfServiceCategory -FleetId 3
New-FleetSelfServiceCategory -FleetId 3 -Name "Engineering"

Get-FleetScript
Invoke-FleetScript -HostId 10 -ScriptId 4

Lock-FleetHost -Id 123 -ViewPin
Unlock-FleetHost -Id 123
Invoke-FleetHostWipe -Id 45 -WindowsWipeType doWipe
Get-FleetHostWipeStatus -Id 123

Set-FleetDiskEncryption -FleetId 1 -Enable $true
Set-FleetOsUpdate -FleetId 1 -MacOsMinimumVersion "15.4.1" -MacOsDeadline "2026-07-01"
Set-FleetCalendarEvent -FleetId 1 -Enable $true -WebhookUrl "https://automations.example/fleet"

New-FleetPolicy -Name "Gatekeeper" -Query "SELECT 1;" -FleetId 2 -CalendarEventsEnabled $true -SoftwareTitleId 9
Get-FleetPolicyAutomation -PolicyId 12
Reset-FleetPolicyAutomation -PolicyId 1, 2, 3
Set-FleetJitProvisioning -Enabled $true
```

`-MacOsMinimumVersion latest` requires `-MacOsDeadlineDays`. Calendar, script, and software policy automations require `-FleetId`.

## FleetDM-PowerShell Cmdlets

### [Connect-FleetDM](Connect-FleetDM.md)

Establishes a connection to the FleetDM API with an API token, a credential, or email and password.

### [Disconnect-FleetDM](Disconnect-FleetDM.md)

Disconnects from the FleetDM API.

### [New-FleetUser](New-FleetUser.md)

Creates a Fleet user. `-ApiOnly` returns `Token`.

### [Get-FleetHost](Get-FleetHost.md)

Retrieves information about FleetDM hosts.

### [Remove-FleetHost](Remove-FleetHost.md)

Removes a host from FleetDM.

### [Lock-FleetHost](Lock-FleetHost.md)

Locks a host. Premium. `-ViewPin` returns the macOS unlock PIN.

### [Unlock-FleetHost](Unlock-FleetHost.md)

Unlocks a host. Premium.

### [Invoke-FleetHostWipe](Invoke-FleetHostWipe.md)

Queues a host wipe. `-WindowsWipeType` accepts `doWipe` or `doWipeProtected`.

### [Get-FleetHostWipeStatus](Get-FleetHostWipeStatus.md)

Reads `mdm.device_status` and `mdm.pending_action`.

### [Get-FleetPolicy](Get-FleetPolicy.md)

Retrieves FleetDM policies.

### [New-FleetPolicy](New-FleetPolicy.md)

Creates a FleetDM policy. `-FleetId` creates a fleet policy.

### [Set-FleetPolicy](Set-FleetPolicy.md)

Updates an existing FleetDM policy.

### [Get-FleetPolicyAutomation](Get-FleetPolicyAutomation.md)

Lists automation activity for a policy.

### [Reset-FleetPolicyAutomation](Reset-FleetPolicyAutomation.md)

Resets failing-policy automation state. Sends `policy_ids` only.

### [Get-FleetQuery](Get-FleetQuery.md)

Retrieves saved queries from FleetDM.

### [Invoke-FleetQuery](Invoke-FleetQuery.md)

Executes a live query on FleetDM hosts.

### [Invoke-FleetSavedQuery](Invoke-FleetSavedQuery.md)

Executes a saved query on FleetDM hosts.

### [Get-FleetSoftware](Get-FleetSoftware.md)

Retrieves software inventory from FleetDM.

### [Install-FleetSoftware](Install-FleetSoftware.md)

Installs a software title on a host. Premium.

### [Uninstall-FleetSoftware](Uninstall-FleetSoftware.md)

Uninstalls a software title from a host. Premium.

### [Get-FleetSoftwareInstall](Get-FleetSoftwareInstall.md)

Reads a package install result by install UUID. Premium.

### [Remove-FleetSoftwarePackage](Remove-FleetSoftwarePackage.md)

Removes an installer from a fleet. Premium. Does not uninstall copies already on hosts.

### [Get-FleetSelfServiceCategory](Get-FleetSelfServiceCategory.md)

Lists self-service categories for a fleet. Premium.

### [New-FleetSelfServiceCategory](New-FleetSelfServiceCategory.md)

Creates a self-service category. Premium.

### [Set-FleetSelfServiceCategory](Set-FleetSelfServiceCategory.md)

Renames a self-service category. Premium.

### [Remove-FleetSelfServiceCategory](Remove-FleetSelfServiceCategory.md)

Deletes a self-service category. Premium.

### [Get-FleetTeam](Get-FleetTeam.md)

Lists fleets or gets one fleet. Premium. The REST resource is `/fleets`.

### [New-FleetTeam](New-FleetTeam.md)

Creates a fleet. Premium.

### [Set-FleetTeam](Set-FleetTeam.md)

Renames a fleet or assigns hosts. Premium.

### [Remove-FleetTeam](Remove-FleetTeam.md)

Deletes a fleet. Premium.

### [Get-FleetScript](Get-FleetScript.md)

Lists saved scripts or gets one script. `-FleetId` requires Premium.

### [Invoke-FleetScript](Invoke-FleetScript.md)

Runs a script on a host. `-FleetId` and `-ScriptName` require Premium.

### [Remove-FleetScript](Remove-FleetScript.md)

Deletes a saved script.

### [Get-FleetDiskEncryption](Get-FleetDiskEncryption.md)

Reads the disk encryption summary. Premium.

### [Set-FleetDiskEncryption](Set-FleetDiskEncryption.md)

Enforces disk encryption. Premium.

### [Set-FleetOsUpdate](Set-FleetOsUpdate.md)

Sets enforced OS update deadlines for a fleet. Premium.

### [Set-FleetCalendarEvent](Set-FleetCalendarEvent.md)

Enables calendar maintenance windows for a fleet. Premium.

### [Set-FleetJitProvisioning](Set-FleetJitProvisioning.md)

Enables or disables SSO just-in-time user provisioning. Premium.

### [Invoke-FleetDMMethod](Invoke-FleetDMMethod.md)

Invokes a generic FleetDM API method.
