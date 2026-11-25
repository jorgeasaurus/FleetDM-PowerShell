---
Module Name: FleetDM-PowerShell
Module Guid: a7c4b8f3-2d1e-4f5a-9c8b-1e3d5a7f9b2c
Download Help Link: https://github.com/Jorgeasaurus/FleetDM-PowerShell/wiki
Help Version: 2.3.0.0
Locale: en-US
---

# FleetDM-PowerShell Module

## Description

PowerShell module for the FleetDM REST API. Free-tier cmdlets cover hosts, reports, policies, scripts, configuration profiles, and software inventory. Fleet Premium cmdlets cover fleets, software installers and App Store apps, self-service, MDM, host secrets, setup experience, enrollment tokens, conditional access, host wipe for other platforms, OS updates, policy automations, calendar, and SSO just-in-time provisioning.

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

## Examples for cmdlets added in 2.3.0

Uploads are sent as `multipart/form-data` on both Windows PowerShell 5.1 and PowerShell 7. Installers and bootstrap packages stream from disk. Error messages now include Fleet's `errors[].reason`.

```powershell
Get-FleetPolicy -FleetId 2 -Name "Legacy" | Remove-FleetPolicy

$script = New-FleetScript -Path ./collect-logs.sh -FleetId 2
Get-FleetScript -Id $script.id -Contents
Start-FleetScriptBatch -ScriptId $script.id -HostId 10, 11 | Get-FleetScriptBatch
Invoke-FleetScript -HostId 10 -ScriptId $script.id | Get-FleetScriptResult -Wait

New-FleetConfigurationProfile -Path ./passcode.mobileconfig -FleetId 2 -LabelsIncludeAny "Engineering"
Sync-FleetConfigurationProfile -Path ./profiles/*.mobileconfig -FleetId 2 -DryRun

$package = New-FleetSoftwarePackage -Path ./FalconSensor.pkg -FleetId 2 -SelfService
Save-FleetSoftwarePackage -SoftwareTitleId $package.title_id -FleetId 2 -OutFile ./FalconSensor.pkg
Get-FleetMaintainedApp -Query "1Password" -Platform darwin | Add-FleetMaintainedApp -FleetId 2

Get-FleetHostSecret -HostId 8 -Type DiskEncryptionKey
Reset-FleetHostSecret -HostId 8 -Type RecoveryLockPassword

Set-FleetSetupExperienceSoftware -FleetId 2 -Platform linux -SoftwareTitleId 3000, 3001
Set-FleetVppTokenFleet -Id 1 -AllFleets
Set-FleetPatchDeadline -FleetId 3 -Days monday, friday -Time "11:00"
Set-FleetHostNameTemplate -FleetId 5 -Template 'iPad $FLEET_VAR_HOST_HARDWARE_SERIAL'
Move-FleetHost -FleetId 2 -Filter @{ label_id = 7 } -WhatIf
```

`Sync-FleetConfigurationProfile` replaces the whole profile set. `Set-FleetConfigurationProfile` re-sends the current labels unless you pass a label parameter or `-ClearLabels`. Batch scripts, host transfers, and batch resends reject an empty or unknown filter key, because an empty filter matches every host.

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

### [Move-FleetHost](Move-FleetHost.md)

Moves every host that matches a filter to a fleet. Premium. An empty filter is rejected.

### [Get-FleetHostSecret](Get-FleetHostSecret.md)

Reads a disk encryption key, Recovery Lock password, or managed account password. The value is not logged.

### [Reset-FleetHostSecret](Reset-FleetHostSecret.md)

Rotates one of those secrets. Premium.

### [Clear-FleetHostPasscode](Clear-FleetHostPasscode.md)

Clears an iOS or iPadOS passcode. Premium.

### [Get-FleetMdmCommand](Get-FleetMdmCommand.md)

Lists MDM commands, usually for one host.

### [Stop-FleetHostMdmCommand](Stop-FleetHostMdmCommand.md)

Cancels a pending lock, wipe, clear passcode, or lost mode command. Premium.

### [Set-FleetHostNameTemplate](Set-FleetHostNameTemplate.md)

Sets or clears the Apple host name template for a fleet. Premium.

### [Get-FleetPolicy](Get-FleetPolicy.md)

Retrieves FleetDM policies.

### [New-FleetPolicy](New-FleetPolicy.md)

Creates a FleetDM policy. `-FleetId` creates a fleet policy.

### [Set-FleetPolicy](Set-FleetPolicy.md)

Updates an existing FleetDM policy.

### [Remove-FleetPolicy](Remove-FleetPolicy.md)

Deletes global or fleet policies with one POST per fleet. Fleet policies require Premium.

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

### [Get-FleetSoftwareTitle](Get-FleetSoftwareTitle.md)

Lists software titles or gets one by title ID.

### [Install-FleetSoftware](Install-FleetSoftware.md)

Installs a software title on a host. Premium.

### [Uninstall-FleetSoftware](Uninstall-FleetSoftware.md)

Uninstalls a software title from a host. Premium.

### [Get-FleetSoftwareInstall](Get-FleetSoftwareInstall.md)

Reads a package install result by install UUID. Premium.

### [Remove-FleetSoftwarePackage](Remove-FleetSoftwarePackage.md)

Removes an installer from a fleet. Premium. Does not uninstall copies already on hosts.

### [New-FleetSoftwarePackage](New-FleetSoftwarePackage.md)

Uploads an installer. Premium. Streams the file from disk.

### [Set-FleetSoftwarePackage](Set-FleetSoftwarePackage.md)

Updates an installer, its scripts, or its targeting. Premium.

### [Save-FleetSoftwarePackage](Save-FleetSoftwarePackage.md)

Downloads an installer. Premium.

### [Get-FleetMaintainedApp](Get-FleetMaintainedApp.md)

Lists Fleet-maintained apps or gets one.

### [Add-FleetMaintainedApp](Add-FleetMaintainedApp.md)

Adds a Fleet-maintained app to a fleet. Premium.

### [Get-FleetAppStoreApp](Get-FleetAppStoreApp.md)

Lists App Store apps that can be added to a fleet.

### [Add-FleetAppStoreApp](Add-FleetAppStoreApp.md)

Adds an App Store or Google Play app. Premium.

### [Set-FleetAppStoreApp](Set-FleetAppStoreApp.md)

Updates an App Store app. Premium.

### [Get-FleetPatchDeadline](Get-FleetPatchDeadline.md)

Reads a fleet's patch deadline. Premium.

### [Set-FleetPatchDeadline](Set-FleetPatchDeadline.md)

Sets a fleet's patch deadline days and time. Premium.

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

### [Add-FleetTeamUser](Add-FleetTeamUser.md)

Adds users to a fleet with a role. Premium.

### [Set-FleetTeamAgentOption](Set-FleetTeamAgentOption.md)

Replaces a fleet's agent options. Premium. `-DryRun` validates only.

### [Get-FleetScript](Get-FleetScript.md)

Lists saved scripts or gets one script. `-FleetId` requires Premium.

### [New-FleetScript](New-FleetScript.md)

Uploads a saved script. `-FleetId` requires Premium.

### [Set-FleetScript](Set-FleetScript.md)

Replaces a saved script's contents.

### [Invoke-FleetScript](Invoke-FleetScript.md)

Runs a script on a host. `-FleetId` and `-ScriptName` require Premium.

### [Get-FleetScriptResult](Get-FleetScriptResult.md)

Reads a script result. `-Wait` polls until the host reports an exit code.

### [Start-FleetScriptBatch](Start-FleetScriptBatch.md)

Runs a saved script on many hosts by ID or filter.

### [Get-FleetScriptBatch](Get-FleetScriptBatch.md)

Lists batch runs, gets one, or lists its hosts.

### [Stop-FleetScriptBatch](Stop-FleetScriptBatch.md)

Cancels a batch run.

### [Remove-FleetScript](Remove-FleetScript.md)

Deletes a saved script.

### [Get-FleetConfigurationProfile](Get-FleetConfigurationProfile.md)

Lists, gets, or downloads configuration profiles.

### [New-FleetConfigurationProfile](New-FleetConfigurationProfile.md)

Uploads a configuration profile. Labels, activation, and fleets require Premium.

### [Set-FleetConfigurationProfile](Set-FleetConfigurationProfile.md)

Updates a profile's file, labels, activation, or self-service settings. Premium.

### [Remove-FleetConfigurationProfile](Remove-FleetConfigurationProfile.md)

Deletes a configuration profile.

### [Sync-FleetConfigurationProfile](Sync-FleetConfigurationProfile.md)

Replaces every profile on a fleet with a set of files. `-DryRun` validates only.

### [Send-FleetConfigurationProfile](Send-FleetConfigurationProfile.md)

Resends a profile to hosts by ID or by failed status.

### [Install-FleetConfigurationProfile](Install-FleetConfigurationProfile.md)

Installs a self-service profile on a host. Premium.

### [Uninstall-FleetConfigurationProfile](Uninstall-FleetConfigurationProfile.md)

Removes a self-service profile from a host. Premium.

### [Get-FleetSetupExperienceSoftware](Get-FleetSetupExperienceSoftware.md)

Lists software that can install during setup. Premium.

### [Set-FleetSetupExperienceSoftware](Set-FleetSetupExperienceSoftware.md)

Sets or clears setup software for a platform. Premium.

### [Get-FleetSetupExperienceScript](Get-FleetSetupExperienceScript.md)

Gets the macOS setup script or its contents. Premium.

### [Set-FleetSetupExperienceScript](Set-FleetSetupExperienceScript.md)

Uploads the macOS setup script. Premium.

### [Remove-FleetSetupExperienceScript](Remove-FleetSetupExperienceScript.md)

Deletes the macOS setup script. Premium.

### [Get-FleetEula](Get-FleetEula.md)

Gets the setup EULA metadata or downloads the file. Premium.

### [Set-FleetEula](Set-FleetEula.md)

Uploads the setup EULA. Premium.

### [Remove-FleetEula](Remove-FleetEula.md)

Deletes the setup EULA. Premium.

### [Get-FleetBootstrapPackage](Get-FleetBootstrapPackage.md)

Gets bootstrap package metadata. Premium.

### [Set-FleetBootstrapPackage](Set-FleetBootstrapPackage.md)

Uploads a bootstrap package. Premium.

### [Remove-FleetBootstrapPackage](Remove-FleetBootstrapPackage.md)

Deletes a bootstrap package. Premium.

### [Get-FleetAppleBusinessToken](Get-FleetAppleBusinessToken.md)

Lists Apple Business tokens. Premium.

### [Get-FleetVppToken](Get-FleetVppToken.md)

Lists VPP tokens. Premium.

### [Add-FleetVppToken](Add-FleetVppToken.md)

Uploads a VPP content token. Premium.

### [Set-FleetVppTokenFleet](Set-FleetVppTokenFleet.md)

Sets which fleets use a VPP token. Premium.

### [Get-FleetEnrollmentProfile](Get-FleetEnrollmentProfile.md)

Gets the custom or default automatic enrollment profile. Premium.

### [Set-FleetEnrollmentProfile](Set-FleetEnrollmentProfile.md)

Sets a fleet's custom automatic enrollment profile. Premium.

### [Remove-FleetEnrollmentProfile](Remove-FleetEnrollmentProfile.md)

Deletes a fleet's custom automatic enrollment profile. Premium.

### [Get-FleetGoogleConditionalAccess](Get-FleetGoogleConditionalAccess.md)

Reads the Google conditional access settings. Premium.

### [Set-FleetGoogleConditionalAccess](Set-FleetGoogleConditionalAccess.md)

Connects or updates Google conditional access. Premium.

### [Remove-FleetGoogleConditionalAccess](Remove-FleetGoogleConditionalAccess.md)

Disconnects Google conditional access. Premium.

### [Get-FleetMicrosoftGraphCredential](Get-FleetMicrosoftGraphCredential.md)

Lists the Autopilot Microsoft Graph credentials. Premium.

### [Set-FleetMicrosoftGraphCredential](Set-FleetMicrosoftGraphCredential.md)

Replaces or clears the Autopilot Microsoft Graph credential. Premium.

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
