function Set-FleetDiskEncryption {
    <#
    .SYNOPSIS
        Enforces disk encryption for a fleet.

    .DESCRIPTION
        Sends POST /api/v1/fleet/disk_encryption.
        When FleetId is omitted, the setting applies to unassigned hosts.

    .PARAMETER FleetId
        Fleet to update. Omit it for unassigned hosts.

    .PARAMETER Enable
        Whether disk encryption is enforced.

    .PARAMETER RequireBitLockerPin
        Requires a BitLocker PIN. Enable must also be true.

    .EXAMPLE
        Set-FleetDiskEncryption -FleetId 1 -Enable $true

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#update-disk-encryption

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-disk-encryption
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory)]
        [bool]$Enable,

        [bool]$RequireBitLockerPin
    )

    process {
        if ($RequireBitLockerPin -and -not $Enable) {
            throw "RequireBitLockerPin requires -Enable `$true."
        }

        $body = @{ enable_disk_encryption = [bool]$Enable }
        if ($PSBoundParameters.ContainsKey('FleetId')) {
            $body['fleet_id'] = $FleetId
        }
        if ($PSBoundParameters.ContainsKey('RequireBitLockerPin')) {
            $body['windows_require_bitlocker_pin'] = [bool]$RequireBitLockerPin
        }

        $target = if ($PSBoundParameters.ContainsKey('FleetId')) { "fleet $FleetId" } else { 'unassigned hosts' }
        if ($PSCmdlet.ShouldProcess($target, "Set disk encryption enabled=$Enable")) {
            $null = Invoke-FleetDMRequest -Endpoint 'disk_encryption' -Method POST -Body $body
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.DiskEncryptionSetting'
                FleetId = $(if ($PSBoundParameters.ContainsKey('FleetId')) { $FleetId } else { $null })
                EnableDiskEncryption = [bool]$Enable
                WindowsRequireBitLockerPin = [bool]$RequireBitLockerPin
            }
        }
    }
}
