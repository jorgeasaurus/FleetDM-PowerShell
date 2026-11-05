function Set-FleetOsUpdate {
    <#
    .SYNOPSIS
        Sets enforced OS update deadlines for a fleet.

    .DESCRIPTION
        Sends PATCH /api/v1/fleet/fleets/{id} with the mdm.macos_updates, ios_updates, ipados_updates, or windows_updates object.
        macOS, iOS, iPadOS, and Windows update enforcement is a Fleet Premium control.

    .PARAMETER FleetId
        Fleet to update. Unassigned hosts (id 0) do not accept MDM update settings on this endpoint.

    .PARAMETER MacOsMinimumVersion
        Minimum macOS version, or "latest".

    .PARAMETER MacOsDeadline
        Fixed deadline date (yyyy-MM-dd) after which macOS updates are forced. Cannot be combined with MacOsDeadlineDays.

    .PARAMETER MacOsDeadlineDays
        Number of days before macOS updates are forced. Required when MacOsMinimumVersion is latest. Cannot be combined with MacOsDeadline.

    .PARAMETER MacOsUpdateNewHosts
        Update newly enrolled ADE Macs during Setup Assistant.

    .PARAMETER IosMinimumVersion
        Minimum iOS version.

    .PARAMETER IosDeadline
        iOS deadline date (yyyy-MM-dd).

    .PARAMETER IpadOsMinimumVersion
        Minimum iPadOS version.

    .PARAMETER IpadOsDeadline
        iPadOS deadline date (yyyy-MM-dd).

    .PARAMETER WindowsDeadlineDays
        Days before Windows updates are installed.

    .PARAMETER WindowsGracePeriodDays
        Days before Windows restarts to finish updates.

    .EXAMPLE
        Set-FleetOsUpdate -FleetId 1 -MacOsMinimumVersion "15.4.1" -MacOsDeadline "2026-07-01"

    .NOTES
        This cmdlet requires Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#update-fleet
        https://fleetdm.com/docs/configuration/yaml-files

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-fleet
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$FleetId,

        [string]$MacOsMinimumVersion,
        [string]$MacOsDeadline,
        [ValidateRange(0, 365)]
        [int]$MacOsDeadlineDays,
        [bool]$MacOsUpdateNewHosts,
        [string]$IosMinimumVersion,
        [string]$IosDeadline,
        [string]$IpadOsMinimumVersion,
        [string]$IpadOsDeadline,
        [ValidateRange(0, 365)]
        [int]$WindowsDeadlineDays,
        [ValidateRange(0, 365)]
        [int]$WindowsGracePeriodDays
    )

    process {
        $hasMacDeadline = $PSBoundParameters.ContainsKey('MacOsDeadline')
        $hasMacDeadlineDays = $PSBoundParameters.ContainsKey('MacOsDeadlineDays')
        if ($hasMacDeadline -and $hasMacDeadlineDays) {
            throw "MacOsDeadline and MacOsDeadlineDays cannot be used together."
        }
        if ($MacOsMinimumVersion -eq 'latest' -and -not $hasMacDeadlineDays) {
            throw "MacOsMinimumVersion latest requires -MacOsDeadlineDays. Fleet does not accept a fixed deadline for latest."
        }

        $current = Invoke-FleetDMRequest -Endpoint "fleets/$FleetId" -Method GET
        $fleetRecord = Get-FleetRecord -Response $current
        $currentMdm = $null
        if ($fleetRecord) {
            $currentMdm = $fleetRecord.mdm
        }

        $mdm = @{}
        if ($PSBoundParameters.ContainsKey('MacOsMinimumVersion') -or $hasMacDeadline -or $hasMacDeadlineDays -or $PSBoundParameters.ContainsKey('MacOsUpdateNewHosts')) {
            $macos = @{}
            if ($currentMdm -and $currentMdm.macos_updates) {
                foreach ($prop in $currentMdm.macos_updates.PSObject.Properties) {
                    $macos[$prop.Name] = $prop.Value
                }
            }
            if ($PSBoundParameters.ContainsKey('MacOsMinimumVersion')) { $macos['minimum_version'] = $MacOsMinimumVersion }
            if ($hasMacDeadline) {
                $macos['deadline'] = $MacOsDeadline
                $macos.Remove('deadline_days')
            }
            if ($hasMacDeadlineDays) {
                $macos['deadline_days'] = $MacOsDeadlineDays
                $macos.Remove('deadline')
            }
            if ($PSBoundParameters.ContainsKey('MacOsUpdateNewHosts')) { $macos['update_new_hosts'] = [bool]$MacOsUpdateNewHosts }

            $effectiveMinimum = [string]$macos['minimum_version']
            $effectiveDeadline = [string]$macos['deadline']
            $effectiveDeadlineDays = $macos['deadline_days']
            $hasEffectiveDays = $null -ne $effectiveDeadlineDays -and "$effectiveDeadlineDays" -ne ''
            if ($effectiveMinimum -eq 'latest') {
                if ($effectiveDeadline -and -not $hasMacDeadlineDays) {
                    throw "The fleet minimum macOS version is latest, which requires deadline_days rather than a fixed deadline. Pass -MacOsDeadlineDays."
                }
                if (-not $hasEffectiveDays) {
                    throw "minimum_version latest requires deadline_days. Pass -MacOsDeadlineDays."
                }
                $macos.Remove('deadline')
            }
            elseif ($hasEffectiveDays) {
                throw "deadline_days is only valid when the macOS minimum version is latest. Pass -MacOsMinimumVersion latest, or pass -MacOsDeadline for a pinned version."
            }

            $mdm['macos_updates'] = $macos
        }
        if ($PSBoundParameters.ContainsKey('IosMinimumVersion') -or $PSBoundParameters.ContainsKey('IosDeadline')) {
            $ios = @{}
            if ($PSBoundParameters.ContainsKey('IosMinimumVersion')) { $ios['minimum_version'] = $IosMinimumVersion }
            if ($PSBoundParameters.ContainsKey('IosDeadline')) { $ios['deadline'] = $IosDeadline }
            $mdm['ios_updates'] = $ios
        }
        if ($PSBoundParameters.ContainsKey('IpadOsMinimumVersion') -or $PSBoundParameters.ContainsKey('IpadOsDeadline')) {
            $ipados = @{}
            if ($PSBoundParameters.ContainsKey('IpadOsMinimumVersion')) { $ipados['minimum_version'] = $IpadOsMinimumVersion }
            if ($PSBoundParameters.ContainsKey('IpadOsDeadline')) { $ipados['deadline'] = $IpadOsDeadline }
            $mdm['ipados_updates'] = $ipados
        }
        if ($PSBoundParameters.ContainsKey('WindowsDeadlineDays') -or $PSBoundParameters.ContainsKey('WindowsGracePeriodDays')) {
            $windows = @{}
            if ($PSBoundParameters.ContainsKey('WindowsDeadlineDays')) { $windows['deadline_days'] = $WindowsDeadlineDays }
            if ($PSBoundParameters.ContainsKey('WindowsGracePeriodDays')) { $windows['grace_period_days'] = $WindowsGracePeriodDays }
            $mdm['windows_updates'] = $windows
        }

        if ($mdm.Count -eq 0) {
            throw "Specify at least one OS update setting."
        }

        if ($PSCmdlet.ShouldProcess("fleet $FleetId", 'Set OS update enforcement')) {
            $response = Invoke-FleetDMRequest -Endpoint "fleets/$FleetId" -Method PATCH -Body @{ mdm = $mdm }
            return (Get-FleetRecord -Response $response)
        }
    }
}
