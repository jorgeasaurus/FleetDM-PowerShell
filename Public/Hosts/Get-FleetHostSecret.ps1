function Get-FleetHostSecret {
    <#
    .SYNOPSIS
        Reads a host's disk encryption key, Recovery Lock password, or managed account password.

    .DESCRIPTION
        Sends GET /api/v1/fleet/hosts/{id}/encryption_key, /recovery_lock_password, or /managed_account_password.
        Returns the secret in plain text in the Secret property. The value is never written to the verbose log.
        Fleet returns a value only after the host escrowed it and Fleet verified it.

    .PARAMETER HostId
        Host ID. Binds from the id property of piped hosts.

    .PARAMETER Type
        DiskEncryptionKey (FileVault or BitLocker), RecoveryLockPassword (Apple silicon Macs), or ManagedAccountPassword (macOS and Windows).

    .EXAMPLE
        Get-FleetHostSecret -HostId 8 -Type DiskEncryptionKey

    .EXAMPLE
        Get-FleetHost -Id 8 | Get-FleetHostSecret -Type RecoveryLockPassword | Select-Object HostId, UpdatedAt

    .NOTES
        Requires an MDM-enrolled host with an escrowed secret. Fleet answers 404 or 422 otherwise.
        Treat the output as a credential. Transcripts record what the console shows.
        https://fleetdm.com/docs/rest-api/rest-api#get-hosts-disk-encryption-key

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#get-hosts-disk-encryption-key
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.HostSecret')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$HostId,

        [Parameter(Mandatory)]
        [ValidateSet('DiskEncryptionKey', 'RecoveryLockPassword', 'ManagedAccountPassword')]
        [string]$Type
    )

    process {
        $route = Get-FleetHostSecretRoute -Type $Type
        $response = Invoke-FleetDMRequest -Endpoint "hosts/$HostId/$($route.Path)" -Method GET
        $secret = $response.($route.Path)

        [PSCustomObject]@{
            PSTypeName = 'FleetDM.HostSecret'
            HostId = $HostId
            Type = $Type
            Secret = $secret.($route.Field)
            UpdatedAt = $secret.updated_at
            RotationPending = [bool]$secret.rotation_pending
        }
    }
}
