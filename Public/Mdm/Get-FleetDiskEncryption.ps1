function Get-FleetDiskEncryption {
    <#
    .SYNOPSIS
        Gets aggregate disk encryption status.

    .DESCRIPTION
        Sends GET /api/v1/fleet/disk_encryption.

    .PARAMETER FleetId
        Optional fleet filter.

    .EXAMPLE
        Get-FleetDiskEncryption -FleetId 1

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#get-disk-encryption-status

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#get-disk-encryption-status
    #>
    [CmdletBinding()]
    param(
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId
    )

    process {
        $query = @{}
        if ($PSBoundParameters.ContainsKey('FleetId')) {
            $query['fleet_id'] = $FleetId
        }

        $params = @{ Endpoint = 'disk_encryption'; Method = 'GET' }
        if ($query.Count -gt 0) { $params['QueryParameters'] = $query }
        $result = Invoke-FleetDMRequest @params
        if ($result -and $result.PSObject) {
            $result.PSObject.TypeNames.Insert(0, 'FleetDM.DiskEncryptionSummary')
        }
        return $result
    }
}
