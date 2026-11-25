function Get-FleetHostSecretRoute {
    <#
    .SYNOPSIS
        Maps a host secret type to its Fleet route, response property, and value field.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('DiskEncryptionKey', 'RecoveryLockPassword', 'ManagedAccountPassword')]
        [string]$Type
    )

    switch ($Type) {
        'DiskEncryptionKey' { return @{ Path = 'encryption_key'; Field = 'key' } }
        'RecoveryLockPassword' { return @{ Path = 'recovery_lock_password'; Field = 'password' } }
        'ManagedAccountPassword' { return @{ Path = 'managed_account_password'; Field = 'password' } }
    }
}
