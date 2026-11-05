---
name: publish-gallery-release
description: >
  Ship FleetDM-PowerShell to the PowerShell Gallery. Use when the user says
  publish, release, ship, or deploy this module to the PowerShell Gallery or
  PSGallery, cut a version, push a version tag, or runs /publish-gallery-release.
---

# Publish a Gallery release

The PowerShell Gallery copy is whatever `Publish-Module` uploaded. A changelog heading, a manifest version, and a merged pull request are not a release.

The publish path is `.github/workflows/ci.yml`. Read the `publish` and `create-release` jobs before acting. Pushing a tag that matches `v*` runs that workflow. `workflow_dispatch` and a push to `main` do not publish.

## Before the tag

1. Ask the user to confirm the version and the commit. Do this before creating or pushing a tag. A Gallery version cannot be replaced.
2. Read the live Gallery version with `Find-Module -Name FleetDM-PowerShell -Repository PSGallery`. Read tags with `git tag -l 'v*' --sort=-v:refname`. If a manifest or changelog version has no matching tag, it was not released.
3. The version to ship must be greater than the Gallery version and must not already have a tag. On the commit you will tag, these must all be that version:
   - `ModuleVersion` in `FleetDM-PowerShell.psd1`
   - `PrivateData.PSData.ReleaseNotes` in that manifest
   - the newest heading in `CHANGELOG.md`
   - the newest heading under Version History in `README.md`
4. Release notes describe only the files in that commit. Leave `Prerelease` empty for a stable release. Every new public function must be listed in `FunctionsToExport`.
5. Tag the commit the user wants people to install. A `v*` tag publishes that commit even when it is not on `main`. Prefer the merge commit on `main`.

Do not set `BUILD_BUILDNUMBER`. The build copies `ModuleVersion` unless that variable is set, and the Gallery then receives the variable instead of the manifest. Do not change the psake 4.9.1 pin as part of the release.

## Publish

1. Create the tag on the confirmed commit: `git tag vX.Y.Z <commit>`. The tag is `v` plus `ModuleVersion`, for example `v2.2.0`.
2. Push only that tag: `git push origin vX.Y.Z`. Do not use `--tags`. Do not force-push or move an existing tag.
3. Watch the CI run for that tag. The build matrix must pass on Ubuntu, Windows, and macOS. Publish and Create GitHub Release are separate jobs. The uploaded module is the `windows-latest` artifact from that run, not a local `Output/` folder.
4. Confirm `Find-Module -Name FleetDM-PowerShell -Repository PSGallery` shows the new version, and `gh release view vX.Y.Z` exists. The Gallery listing can take a few minutes.

If the publish job says `NUGET_API_KEY` is not set, the GitHub Actions secret is missing. Stop. Tell the user to add the `NUGET_API_KEY` repository secret. Do not ask them to paste the key, and do not print it.

If the Gallery rejects the version because it already exists, bump `ModuleVersion` and ship a new tag. Do not retry the same version.

## Not the Gallery

- `./build.ps1 -Task Deploy` copies the module into the user Documents folder.
- `./build.ps1 -Task Publish` uploads from this machine and does not create the GitHub release. Use it only when the user explicitly asks for a publish from this machine. It still requires `NUGET_API_KEY` in the environment.
