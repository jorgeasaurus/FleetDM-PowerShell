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
        Deadline date (yyyy-MM-dd) after which macOS updates are forced.

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
        $mdm = @{}
        if ($PSBoundParameters.ContainsKey('MacOsMinimumVersion') -or $PSBoundParameters.ContainsKey('MacOsDeadline') -or $PSBoundParameters.ContainsKey('MacOsUpdateNewHosts')) {
            $macos = @{}
            if ($PSBoundParameters.ContainsKey('MacOsMinimumVersion')) { $macos['minimum_version'] = $MacOsMinimumVersion }
            if ($PSBoundParameters.ContainsKey('MacOsDeadline')) { $macos['deadline'] = $MacOsDeadline }
            if ($PSBoundParameters.ContainsKey('MacOsUpdateNewHosts')) { $macos['update_new_hosts'] = [bool]$MacOsUpdateNewHosts }
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
            $fleet = $response.team
            if (-not $fleet) { $fleet = $response.fleet }
            if ($fleet -and $fleet.PSObject) {
                $fleet.PSObject.TypeNames.Insert(0, 'FleetDM.Team')
            }
            return $fleet
        }
    }
}
