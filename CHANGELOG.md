# Changelog

## 2.4.0

### Fixed

- Errors include Fleet's `errors[].reason` text after `Reason:` on HTTP 400, 403, 404, 409, 422, and other statuses. HTTP 422 has its own message. Before, a script run on a host without fleetd reported only `Unprocessable Entity`. The Fleet Premium and access denied wording is unchanged. The 400 message no longer appends the raw errors JSON.
- List cmdlets return no records when Fleet sends an empty list as `null`, such as `"scripts": null`. Before, the response envelope came back as one record. An empty page body ends pagination instead of failing parameter binding.
- An empty `-Body` on POST, PUT, PATCH, or DELETE is sent as `{}`. Fleet rejects a JSON route with no body (`Expected JSON Body`). GET still sends no body.
- `Tests/RunAllTests.ps1 -CodeCoverage` measures `Private` as well as `Public`. The `Public/**/*.ps1` pattern matched no files under `Private`.
- `Set-FleetSetupExperienceSoftware` throws when the pipeline gives it no titles. An empty list is a clear, and only `-Clear` sends one.
- `Start-FleetScriptBatch` throws when the pipeline gives it no host IDs. An empty `host_ids` list is not sent.
- JSON bodies keep one-element arrays nested in an object. ADE profiles and agent options parsed on Windows PowerShell 5.1 stay arrays instead of becoming scalars.

### Added

- `Remove-FleetPolicy` deletes global or fleet policies with `POST global/policies/delete` or `POST fleets/{id}/policies/delete`. Piped ids are sent in one request per fleet, and a piped global policy goes to the global route.
- Multipart uploads and file downloads on Windows PowerShell 5.1 and PowerShell 7. The internal request function takes `-Form` and `-OutFile`. Installers and bootstrap packages stream from disk through a temporary file. The verbose log shows field names and byte counts only. Script text downloads are decoded as UTF-8.
- Scripts: `New-FleetScript`, `Set-FleetScript`, `Get-FleetScript -Contents`, `Get-FleetScriptResult` (with `-Wait`), `Start-FleetScriptBatch`, `Get-FleetScriptBatch`, and `Stop-FleetScriptBatch`.
- Configuration profiles: `Get-`, `New-`, `Set-`, `Remove-`, `Sync-`, `Send-`, `Install-`, and `Uninstall-FleetConfigurationProfile`. `Sync-FleetConfigurationProfile` replaces the whole set and supports `-DryRun`. `Set-FleetConfigurationProfile` re-sends the current labels unless a label parameter or `-ClearLabels` is passed, because Fleet resets targeting when a PATCH has no labels.
- Software: `Get-FleetSoftwareTitle`, `New-`, `Set-`, and `Save-FleetSoftwarePackage`, `Get-` and `Add-FleetMaintainedApp`, `Get-`, `Add-`, and `Set-FleetAppStoreApp`, and `Get-` and `Set-FleetPatchDeadline`. These take software title ids, not the version ids that `Get-FleetSoftware -Id` reads.
- Host MDM: `Get-` and `Reset-FleetHostSecret` for disk encryption keys, Recovery Lock passwords, and managed account passwords, plus `Clear-FleetHostPasscode`, `Get-FleetMdmCommand`, and `Stop-FleetHostMdmCommand`. Secret values are not written to the verbose log.
- Setup experience: `Get-` and `Set-FleetSetupExperienceSoftware`, `Get-`, `Set-`, and `Remove-FleetSetupExperienceScript`, `Get-`, `Set-`, and `Remove-FleetEula`, and `Get-`, `Set-`, and `Remove-FleetBootstrapPackage`.
- Enrollment and integrations: `Get-FleetAppleBusinessToken`, `Get-FleetVppToken`, `Add-FleetVppToken`, `Set-FleetVppTokenFleet` (`-FleetId`, `-AllFleets`, or `-NoFleet`), `Get-`, `Set-`, and `Remove-FleetEnrollmentProfile`, `Get-`, `Set-`, and `Remove-FleetGoogleConditionalAccess`, and `Get-` and `Set-FleetMicrosoftGraphCredential`.
- Fleet admin: `Add-FleetTeamUser`, `Set-FleetTeamAgentOption` (`-SkipValidation` sends `force`; `-DryRun` sends `dry_run`), `Move-FleetHost` for transfer by filter, and `Set-FleetHostNameTemplate`. An empty template clears it.
- `Start-FleetScriptBatch`, `Move-FleetHost`, and `Send-FleetConfigurationProfile -Filter` reject an empty filter, an unknown key, and an empty value. Fleet treats those as no filter and would act on every host.
- Verbose logs also redact `service_account_key`, `client_secret`, and `private_key`. One list of names drives every redaction pattern.
- `Tests/ModuleParity.Tests.ps1` checks that `Public` files, `FunctionsToExport`, and `docs/en-US` pages match, that every command has a synopsis and an example, and that it is listed in the nav, index, README, module page, and about topic.

### Verified against Fleet 4.96 Premium

Completed on a live Fleet 4.96 Premium server: `Remove-FleetPolicy` for global and fleet policies, the HTTP 422 reason, script upload, update, UTF-8 `-Contents` download, and delete, batch script start, read, host results, and cancel, the setup experience script upload, download, and delete, clearing setup software, patch deadlines, setting and clearing a host name template, `Add-FleetTeamUser`, `Set-FleetTeamAgentOption -DryRun`, `Move-FleetHost` with a filter that matched no host, and `Set-FleetMicrosoftGraphCredential -Clear`. Fleet 4.96 answers a script update with only `script_id` and a policy delete with the deleted ids.

These routes reached Fleet's handler and returned Fleet's own 4xx reason. That proves the route and the request shape, not the full flow: configuration profiles (MDM is off), the EULA, bootstrap packages, ADE profiles, App Store apps, MDM commands, host secrets and rotation, clear passcode, VPP token upload and fleet assignment, Google conditional access connect and update, the Graph credential dry run, package update and download for an unknown title, and setup software with an unknown title. Package upload and Fleet-maintained app add reached the server, which then could not reach its private-network installer storage (HTTP 500).

Covered only by mocked and HTTP listener tests: a successful package upload, update, and byte-identical download, the EULA file download, `Get-FleetScriptResult -Wait` reaching an exit code, setup software with a real title, and what VPP `-AllFleets` and `-NoFleet` do to fleet access. Windows PowerShell 5.1 was not run. The new files pass PSScriptAnalyzer's 5.1 syntax check.

The plan's remaining items stay on `Invoke-FleetDMMethod`: SCIM, the MCP endpoint, certificate authorities, raw MDM commands, and the other routes listed in the README roadmap.

## 2.3.1

### Fixed

- `Invoke-FleetDMMethod` returns the response envelope once. Nested hosts, policies, queries, software, users, teams, and labels still receive their `FleetDM.*` type names, and those objects are no longer written to the pipeline ahead of the envelope. Responses with no matching key, `-Raw`, and `-FollowPagination` are unchanged.

## 2.3.0

### Added

- Requests retry HTTP 429 for every method and HTTP 502, 503, and 504 for GET. `-MaxRetries` defaults to 3 extra attempts. A 429, and a gateway response that includes one, waits for the `Retry-After` header (an integer or an HTTP-date) or `retry after: Ns` in the error. Gateway retries otherwise wait 2, 4, then 8 seconds. `-MaxRetryDelaySeconds` defaults to 120 and caps every wait, including a huge `Retry-After`. A wait below 1 second uses the backoff. `-RetryNonIdempotent` also retries POST, PUT, PATCH, and DELETE after a gateway error. `Invoke-FleetDMMethod` forwards these parameters when the caller sets them. Each retry writes a verbose line, and the last error is thrown when the attempts are used up.

### Fixed

- `Connect-FleetDM` connects when a token can call `GET /api/v1/fleet/me` but `GET /api/v1/fleet/version` returns 403. The stored version is `$null`. `-SkipVersionCheck` skips the version call. HTTP 401 is still `Authentication failed`. Other cmdlets do not read the stored version.
- When `/me` is the connection check, the response must be the current user (id and email). An HTML body or a user without those fields does not connect. HTTP 403 from `/me` says the token needs `GET /api/v1/fleet/me` allowed.

## 2.2.1

### Fixed

- `Get-FleetTeam` returns fleets when Fleet sends the same list under both `teams` and `fleets`. An empty or null legacy key no longer hides the records, and the two keys are not concatenated.

## 2.2.0

### Fixed

- Verbose request and connection logs redact `password`, token fields, and `Authorization` bearer values at any nesting depth, including array and object values and secret query parameters. `New-FleetUser` still sends the password to Fleet. `-Verbose`, transcripts, and CI logs do not receive it. The HTTP URI is unchanged.
- Software title searches that set both `-Name` and `-Cve` still filter `versions[].vulnerabilities`. Those values are CVE id strings. The title `query` parameter stays the name.
- The build pins psake 4.9.1 and BuildHelpers 2.0.16. psake 5, published after the last green `main` run, defines a parameterless `Set-BuildEnvironment` that rejected `-Force` inside the build tasks.
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

- `Connect-FleetDM -Email` and `-Password` log in with the same values as `fleetctl login --email --password`.
- `New-FleetUser` creates a user with `POST /users/admin`, including `-ApiOnly` and `-GlobalRole`. An API-only response includes `Token`.
- Fleets: `Get-FleetTeam`, `New-FleetTeam`, `Set-FleetTeam`, `Remove-FleetTeam`
- Software install: `Install-FleetSoftware`, `Uninstall-FleetSoftware`, `Get-FleetSoftwareInstall`, `Remove-FleetSoftwarePackage`
- Self-service categories: `Get-FleetSelfServiceCategory`, `New-FleetSelfServiceCategory`, `Set-FleetSelfServiceCategory`, `Remove-FleetSelfServiceCategory`
- Scripts: `Get-FleetScript`, `Invoke-FleetScript`, `Remove-FleetScript` (`-FleetId` requires Premium; id and inline script runs are available in Fleet Free)
- MDM: `Lock-FleetHost`, `Unlock-FleetHost`, `Invoke-FleetHostWipe`, `Get-FleetHostWipeStatus`, `Get-FleetDiskEncryption`, `Set-FleetDiskEncryption`, `Set-FleetOsUpdate`
- Host wipe follows [Wipe host](https://fleetdm.com/docs/rest-api/rest-api#wipe-host). Company-owned Android is Fleet Free. macOS, Windows, iOS, iPadOS, Linux, and personal Android require Premium. Windows accepts `-WindowsWipeType` `doWipe` or `doWipeProtected`. Wipe progress is read from the host `mdm.device_status` and `mdm.pending_action` fields.
- List routes that omit `meta.has_next_results` keep paging until a short page. macOS update changes keep the current fleet settings. `-MacOsMinimumVersion latest` requires `-MacOsDeadlineDays`. Policy automation reset sends only `policy_ids`. CVSS filters stay fractional. Title-only software filters use `/software/titles`. Automation ids of 0 clear a script or software automation.
- Calendar maintenance windows: `Set-FleetCalendarEvent`
- Policy automations: fleet policies via `-FleetId`, `-Critical`, `-CalendarEventsEnabled`, `-SoftwareTitleId`, and `-ScriptId` on `New-FleetPolicy` and `Set-FleetPolicy`; `Get-FleetPolicyAutomation`; `Reset-FleetPolicyAutomation`
- SSO JIT provisioning: `Set-FleetJitProvisioning`

## 1.0.0

- Initial host, query, policy, and software cmdlets.
