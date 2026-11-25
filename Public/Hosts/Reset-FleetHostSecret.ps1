function Reset-FleetHostSecret {
    <#
    .SYNOPSIS
        Rotates a host's disk encryption key, Recovery Lock password, or managed account password.

    .DESCRIPTION
        Sends POST /api/v1/fleet/hosts/{id}/encryption_key/rotate, /recovery_lock_password/rotate,
        or /managed_account_password/rotate. Fleet sends an MDM command and escrows the new value
        when the host acknowledges it. Read the new value later with Get-FleetHostSecret.

    .PARAMETER HostId
        Host ID. Binds from the id property of piped hosts.

    .PARAMETER Type
        DiskEncryptionKey (macOS FileVault), RecoveryLockPassword, or ManagedAccountPassword.

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Reset-FleetHostSecret -HostId 8 -Type RecoveryLockPassword

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        Fleet returns 409 while a disk encryption key rotation is already pending.
        https://fleetdm.com/docs/rest-api/rest-api#rotate-hosts-disk-encryption-key

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#rotate-hosts-disk-encryption-key
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('FleetDM.HostSecretRotation')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$HostId,

        [Parameter(Mandatory)]
        [ValidateSet('DiskEncryptionKey', 'RecoveryLockPassword', 'ManagedAccountPassword')]
        [string]$Type,

        [switch]$Force
    )

    process {
        if ($Force -and -not $WhatIfPreference) {
            $ConfirmPreference = 'None'
        }

        $route = Get-FleetHostSecretRoute -Type $Type
        if ($PSCmdlet.ShouldProcess("host $HostId", "Rotate $Type")) {
            $null = Invoke-FleetDMRequest -Endpoint "hosts/$HostId/$($route.Path)/rotate" -Method POST
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.HostSecretRotation'
                HostId = $HostId
                Type = $Type
                Status = 'RotationRequested'
            }
        }
    }
}
