# Changelog

## 2.2.0

### Fixed

- Query strings are encoded without `System.Web`, null parameters are omitted, and collections are not serialized as `System.Object[]`.
- Request bodies keep one-element arrays as JSON arrays so Windows PowerShell 5.1 does not unwrap values such as `host_ids`.
- Pagination strips a caller-supplied `page` parameter, stops on an empty page, and recognizes current collection names including `software_titles`, `fleets`, and `scripts`.
- HTTP 402, and HTTP 403 responses that mention a Premium license, are reported as a Fleet Premium error. Error bodies are read on both Windows PowerShell 5.1 and PowerShell 7.
- `Get-FleetHost -OrderKey` no longer also sends the unmapped `orderkey` parameter.
- `Get-FleetHost -Label` loads `GET /labels/{id}/hosts`. The list-hosts API does not accept `label_name`.
- `Get-FleetHost -OSName` and `-OSVersion` must be supplied together, matching the list-hosts API.
- `Get-FleetHost -Id -IncludeSoftware` binds. `-IncludeSoftware:$false` sends `exclude_software=true`.
- `Get-FleetHost -After` is formatted as UTC. `-FleetId` and `-LowDiskSpace` are documented as Fleet Premium filters. Status `mia` is accepted. `MDMId` is an integer.
- `Remove-FleetHost -Force -WhatIf` does not delete the host.
- Saved and live reports use `/api/v1/fleet/reports`. Temporary report cleanup uses `DELETE /reports/id/{id}` so a numeric id is not treated as a report name.
- Campaign `-Wait` no longer polls the nonexistent `queries/results/{id}` route. Host-targeted runs use the synchronous report endpoint.
- Software reads use `GET /software/versions`. Sort keys match the current API.

### Added

Fleet Premium cmdlets. Each one documents the Premium requirement and turns HTTP 402 into a license error.

- Fleets: `Get-FleetTeam`, `New-FleetTeam`, `Set-FleetTeam`, `Remove-FleetTeam`
- Software install: `Install-FleetSoftware`, `Uninstall-FleetSoftware`, `Get-FleetSoftwareInstall`, `Remove-FleetSoftwarePackage`
- Self-service categories: `Get-FleetSelfServiceCategory`, `New-FleetSelfServiceCategory`, `Set-FleetSelfServiceCategory`, `Remove-FleetSelfServiceCategory`
- Scripts: `Get-FleetScript`, `Invoke-FleetScript`, `Remove-FleetScript` (`-FleetId` requires Premium; id and inline script runs are available in Fleet Free)
- MDM: `Lock-FleetHost`, `Unlock-FleetHost`, `Get-FleetDiskEncryption`, `Set-FleetDiskEncryption`, `Set-FleetOsUpdate`
- Calendar maintenance windows: `Set-FleetCalendarEvent`
- Policy automations: fleet policies via `-FleetId`, `-Critical`, `-CalendarEventsEnabled`, `-SoftwareTitleId`, and `-ScriptId` on `New-FleetPolicy` and `Set-FleetPolicy`; `Get-FleetPolicyAutomation`; `Reset-FleetPolicyAutomation`
- SSO JIT provisioning: `Set-FleetJitProvisioning`

## 2.1.0

- Added `ConvertFrom-JamfXmlToFleetYaml` for Jamf Pro exports.

## 1.0.0

- Initial host, query, policy, and software cmdlets.
