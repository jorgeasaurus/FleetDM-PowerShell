---
layout: default
title: FleetDM-PowerShell
---

# FleetDM-PowerShell

<p class="lead">The module calls the Fleet REST API from Windows PowerShell 5.1 and PowerShell 7. Version 2.3.0 retries HTTP 429 and gateway errors, and connects an API-only token when GET /version returns 403. Version 2.2.0 adds Fleet Premium cmdlets, host wipe, and secret redaction in verbose logs.</p>

<div class="callouts">
<div class="callout" markdown="1">

**Fleet Free and Fleet Premium.** Free-tier cmdlets cover hosts, reports, policies, and software inventory. Premium cmdlets cover fleets, software installers, self-service, fleet-scoped scripts, MDM, OS updates, policy automations, calendar windows, and SSO just-in-time provisioning. A Premium cmdlet on Fleet Free fails with a Fleet Premium error. That is HTTP 402, or HTTP 403 when the response mentions a Premium license.

</div>
<div class="callout" markdown="1">

**Host wipe.** Company-owned Android wipe is available in Fleet Free. Wiping macOS, Windows, iOS, iPadOS, Linux, or personal Android requires Premium. `-WindowsWipeType` accepts `doWipe` or `doWipeProtected`. Read progress with `Get-FleetHostWipeStatus`.

</div>
<div class="callout" markdown="1">

**Verbose logs.** `-Verbose` redacts `password`, token fields, and `Authorization` bearer values at any nesting depth, including arrays, objects, and secret query parameters. `New-FleetUser` still sends the password to Fleet. Transcripts and CI logs receive the redacted text. Redaction does not change the request URI sent to Fleet. Do not put a secret in `Invoke-FleetDMMethod -Endpoint`: that cmdlet writes the endpoint string to the verbose log before redaction.

**Retries.** HTTP 429 is retried for every method. HTTP 502, 503, and 504 are retried for GET. The default is 3 extra attempts, with a 2, 4, then 8 second backoff. A 429, and a gateway response that sends one, waits for `Retry-After` (seconds or an HTTP-date) or `retry after: Ns` in the error. Each wait is capped at 120 seconds. `Invoke-FleetDMMethod -RetryNonIdempotent` opts in for POST, PUT, PATCH, and DELETE gateway retries. `-MaxRetries 0` disables retries for that call.

</div>
</div>

<ol class="path">
  <li><a href="#install">Install</a><span>PowerShell Gallery, or import the repository.</span></li>
  <li><a href="#connect">Connect</a><span>API token, credential, or email and password.</span></li>
  <li><a href="#tasks">Common tasks</a><span>Hosts, reports, policies, software, scripts, and wipe.</span></li>
  <li><a href="#reference">Cmdlet reference</a><span>Every exported command, grouped.</span></li>
</ol>

## Install {#install}

FleetDM 4.0 or newer. Premium cmdlets need a Premium license on that server. The module has no external module dependencies.

### PowerShell Gallery

```powershell
Install-Module -Name FleetDM-PowerShell -Scope CurrentUser
Import-Module FleetDM-PowerShell
```

### From the repository

```powershell
git clone https://github.com/Jorgeasaurus/FleetDM-PowerShell.git
Import-Module ./FleetDM-PowerShell/FleetDM-PowerShell.psd1
```

## Connect {#connect}

The connection is stored for the current PowerShell session. The module does not save the token to disk.

An API token is the login to use from scripts. In Fleet, open Account and get an API token. `New-FleetUser -ApiOnly` is the other way to mint one.

```powershell
$token = Read-Host -AsSecureString "Enter API Token"
Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $token

Get-FleetHost -Status online
```

An API-only user can be limited to specific endpoints. `Connect-FleetDM` still connects when that token can call `GET /api/v1/fleet/me` and `GET /api/v1/fleet/version` returns 403. The connection version is null. `-SkipVersionCheck` skips the version call and uses `/me` as the connection check. HTTP 401 remains an authentication failure.

`Connect-FleetDM -Email` and `-Password` send the same login as `fleetctl login --email --password`. The account must be a local Fleet user. SSO users cannot sign in with a password.

Creating a user requires an existing admin connection. `New-FleetUser -ApiOnly` sends `POST /users/admin`. Fleet includes `Token` on that response only. An API-only user cannot sign in to the Fleet UI, and that token does not expire. A normal login session does.

```powershell
$password = Read-Host "Password" -AsSecureString
Connect-FleetDM -BaseUri "https://fleet.example.com" -Email "admin@example.com" -Password $password

$apiPassword = Read-Host "API user password" -AsSecureString
$apiUser = New-FleetUser -Name "module-test" -Email "api@example.com" -Password $apiPassword -ApiOnly -GlobalRole admin

# Use the returned token for later sessions. Do not paste passwords into scripts.
$apiToken = ConvertTo-SecureString $apiUser.Token -AsPlainText -Force
Disconnect-FleetDM
Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $apiToken
```

`-GlobalRole` accepts `admin`, `maintainer`, `observer`, `observer_plus`, and `gitops`. Omit it and Fleet assigns `observer`.

`Get-Credential` is the other password login:

```powershell
$cred = Get-Credential
Connect-FleetDM -BaseUri "https://fleet.example.com" -Credential $cred
```

### Verbose logs {#redaction}

`-Verbose` on `Connect-FleetDM` and later API calls writes request details. Those lines redact `password`, token fields, and `Authorization` bearer values at any nesting depth, including array and object values and secret query parameters. `New-FleetUser` still sends the password to Fleet. `-Verbose`, transcripts, and CI logs do not receive it. Redaction does not change the request URI sent to Fleet. Do not put a secret in `Invoke-FleetDMMethod -Endpoint`: that cmdlet writes the endpoint string to the verbose log before redaction.

```powershell
Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $token -Verbose
```

## Common tasks {#tasks}

Commands that change Fleet prompt before they run. Add `-WhatIf` to preview one. For the same text in the shell, run `Get-Help <name> -Full`.

### Hosts

```powershell
Get-FleetHost
Get-FleetHost -Id 123
Get-FleetHost -Status online

Get-FleetHost -Status offline |
  Where-Object { $_.seen_time -lt (Get-Date).AddDays(-30) }
```

### Reports

Live campaign rows are not available over REST. Pass host ids when you need rows back in the session.

```powershell
$results = Invoke-FleetQuery -Query "SELECT * FROM system_info;" -HostId 1,2,3
$results.Results | Format-Table

Invoke-FleetSavedQuery -QueryId 123 -HostId 1,2,3
```

### Policies and software inventory

```powershell
Get-FleetPolicy |
  Where-Object { $_.compliance_percentage -lt 80 } |
  Format-Table name, compliance_percentage, failing_host_count

Get-FleetSoftware -VulnerableOnly |
  Where-Object { $_.highest_severity -eq 'critical' } |
  Select-Object name, version, hosts_count, cve_count
```

### Scripts

Running a saved script by id, or sending inline script text, works in Fleet Free. `-FleetId` and `-ScriptName` require Premium.

```powershell
Get-FleetScript
Get-FleetScript -Id 12
Invoke-FleetScript -HostId 10 -ScriptId 4
Invoke-FleetScript -HostId 10 -ScriptContents "echo hello"
Remove-FleetScript -Id 4
```

### Host wipe

Company-owned Android wipe is Fleet Free. Wiping macOS, Windows, iOS, iPadOS, Linux, or personal Android requires Premium.

```powershell
Lock-FleetHost -Id 123 -ViewPin
Unlock-FleetHost -Id 123
Get-FleetHostWipeStatus -Id 123
Invoke-FleetHostWipe -Id 123
Invoke-FleetHostWipe -Id 45 -WindowsWipeType doWipe
```

### Fleets, installers, and automations (Premium)

```powershell
Get-FleetTeam
Get-FleetTeam -Id 1
New-FleetTeam -Name "Workstations"
Set-FleetTeam -Id 1 -Name "Engineering"
Set-FleetTeam -Id 1 -HostId 3, 6
Remove-FleetTeam -Id 4

Install-FleetSoftware -HostId 123 -SoftwareTitleId 3435
Get-FleetSoftwareInstall -InstallUuid "b15ce221-e22e-4c6a-afe7-5b3400a017da"
Uninstall-FleetSoftware -HostId 123 -SoftwareTitleId 3435
Remove-FleetSoftwarePackage -SoftwareTitleId 3435 -FleetId 2

Get-FleetSelfServiceCategory -FleetId 3
New-FleetSelfServiceCategory -FleetId 3 -Name "Engineering"
Set-FleetSelfServiceCategory -Id 4 -Name "Tools"
Remove-FleetSelfServiceCategory -Id 4

Get-FleetDiskEncryption -FleetId 1
Set-FleetDiskEncryption -FleetId 1 -Enable $true
Set-FleetOsUpdate -FleetId 1 -MacOsMinimumVersion "15.4.1" -MacOsDeadline "2026-07-01"
Set-FleetCalendarEvent -FleetId 1 -Enable $true -WebhookUrl "https://automations.example/fleet"

New-FleetPolicy -Name "Gatekeeper" -Query "SELECT 1;" -FleetId 2 -CalendarEventsEnabled $true -SoftwareTitleId 9
Get-FleetPolicyAutomation -PolicyId 12
Reset-FleetPolicyAutomation -PolicyId 1, 2, 3
Set-FleetJitProvisioning -Enabled $true
```

`Get-FleetSoftwareInstall` reads a package install result. Pass the install UUID Fleet returned when the install was queued.

`-MacOsMinimumVersion latest` requires `-MacOsDeadlineDays`. A pinned macOS version uses `-MacOsDeadline`.

Calendar, script, and software automations on a policy require `-FleetId` and Fleet Premium. `Reset-FleetPolicyAutomation` sends `policy_ids` only. `-FleetId` on that command checks that the policies belong to those fleets. It does not ask Fleet to reset every policy on the fleet.

## Cmdlet reference {#reference}

Premium is marked on the command that needs a Fleet Premium license. The same pages are linked from the sidebar.

<div class="reference" markdown="1">

### Authentication

- [Connect-FleetDM](docs/en-US/Connect-FleetDM.md) — API token, credential, or email and password
- [Disconnect-FleetDM](docs/en-US/Disconnect-FleetDM.md) — Disconnect from Fleet
- [New-FleetUser](docs/en-US/New-FleetUser.md) — Create a user. `-ApiOnly` returns `Token`

### Hosts

- [Get-FleetHost](docs/en-US/Get-FleetHost.md) — Retrieve host information
- [Remove-FleetHost](docs/en-US/Remove-FleetHost.md) — Remove a host from Fleet
- [Lock-FleetHost](docs/en-US/Lock-FleetHost.md) — Lock a host (Premium)
- [Unlock-FleetHost](docs/en-US/Unlock-FleetHost.md) — Unlock a host (Premium)
- [Invoke-FleetHostWipe](docs/en-US/Invoke-FleetHostWipe.md) — Queue a wipe
- [Get-FleetHostWipeStatus](docs/en-US/Get-FleetHostWipeStatus.md) — Read wipe progress from the host MDM fields

### Policies

- [Get-FleetPolicy](docs/en-US/Get-FleetPolicy.md) — Get policy information
- [New-FleetPolicy](docs/en-US/New-FleetPolicy.md) — Create a new policy
- [Set-FleetPolicy](docs/en-US/Set-FleetPolicy.md) — Update an existing policy
- [Get-FleetPolicyAutomation](docs/en-US/Get-FleetPolicyAutomation.md) — List automation activity for a policy
- [Reset-FleetPolicyAutomation](docs/en-US/Reset-FleetPolicyAutomation.md) — Reset failing-policy automation state

### Queries

- [Get-FleetQuery](docs/en-US/Get-FleetQuery.md) — Get saved queries
- [Invoke-FleetQuery](docs/en-US/Invoke-FleetQuery.md) — Execute a live query
- [Invoke-FleetSavedQuery](docs/en-US/Invoke-FleetSavedQuery.md) — Execute a saved query

### Software

- [Get-FleetSoftware](docs/en-US/Get-FleetSoftware.md) — Get software inventory
- [Install-FleetSoftware](docs/en-US/Install-FleetSoftware.md) — Install a software title on a host (Premium)
- [Uninstall-FleetSoftware](docs/en-US/Uninstall-FleetSoftware.md) — Uninstall a software title from a host (Premium)
- [Get-FleetSoftwareInstall](docs/en-US/Get-FleetSoftwareInstall.md) — Read a package install result (Premium)
- [Remove-FleetSoftwarePackage](docs/en-US/Remove-FleetSoftwarePackage.md) — Remove an installer from a fleet (Premium)
- [Get-FleetSelfServiceCategory](docs/en-US/Get-FleetSelfServiceCategory.md) — List self-service categories (Premium)
- [New-FleetSelfServiceCategory](docs/en-US/New-FleetSelfServiceCategory.md) — Create a self-service category (Premium)
- [Set-FleetSelfServiceCategory](docs/en-US/Set-FleetSelfServiceCategory.md) — Rename a self-service category (Premium)
- [Remove-FleetSelfServiceCategory](docs/en-US/Remove-FleetSelfServiceCategory.md) — Delete a self-service category (Premium)

### Fleets (Premium)

- [Get-FleetTeam](docs/en-US/Get-FleetTeam.md) — List fleets or get one fleet
- [New-FleetTeam](docs/en-US/New-FleetTeam.md) — Create a fleet
- [Set-FleetTeam](docs/en-US/Set-FleetTeam.md) — Rename a fleet or assign hosts
- [Remove-FleetTeam](docs/en-US/Remove-FleetTeam.md) — Delete a fleet

### Scripts

- [Get-FleetScript](docs/en-US/Get-FleetScript.md) — List saved scripts or get one script
- [Invoke-FleetScript](docs/en-US/Invoke-FleetScript.md) — Run a script on a host
- [Remove-FleetScript](docs/en-US/Remove-FleetScript.md) — Delete a saved script

### MDM and SSO (Premium)

- [Get-FleetDiskEncryption](docs/en-US/Get-FleetDiskEncryption.md) — Disk encryption summary
- [Set-FleetDiskEncryption](docs/en-US/Set-FleetDiskEncryption.md) — Enforce disk encryption
- [Set-FleetOsUpdate](docs/en-US/Set-FleetOsUpdate.md) — Enforce macOS, iOS, iPadOS, or Windows updates
- [Set-FleetCalendarEvent](docs/en-US/Set-FleetCalendarEvent.md) — Enable calendar maintenance windows for a fleet
- [Set-FleetJitProvisioning](docs/en-US/Set-FleetJitProvisioning.md) — Enable SSO just-in-time user provisioning

### Core

- [Invoke-FleetDMMethod](docs/en-US/Invoke-FleetDMMethod.md) — Direct API access

</div>

Shell help for any of those commands:

```powershell
Get-Help Connect-FleetDM -Full
Get-Help New-FleetUser -Examples
Get-Help Get-FleetHost -Examples
```

More context lives in the [about topic](docs/en-US/about_FleetDM-PowerShell.help.md), the [module page](docs/en-US/FleetDM-PowerShell.md), the [README](README.md), and the [contributing guide](CONTRIBUTING.md).

- [GitHub repository](https://github.com/Jorgeasaurus/FleetDM-PowerShell)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/FleetDM-PowerShell)
- [Fleet REST API](https://fleetdm.com/docs/rest-api/rest-api)
