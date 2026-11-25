function Get-FleetMdmCommand {
    <#
    .SYNOPSIS
        Lists MDM commands, usually for one host.

    .DESCRIPTION
        Sends GET /api/v1/fleet/commands and follows pagination.
        Each result carries the command_uuid that Stop-FleetHostMdmCommand takes.
        Fleet deprecates listing without host_identifier; that form may time out on large fleets.

    .PARAMETER HostIdentifier
        Host hostname, UUID, or hardware serial. Binds from the hardware_serial property of piped hosts.

    .PARAMETER RequestType
        MDM request type, such as DeviceLock or InstallProfile.

    .PARAMETER CommandStatus
        ran, pending, or failed. Fleet applies it only with HostIdentifier on Apple and Android hosts.

    .EXAMPLE
        Get-FleetMdmCommand -HostIdentifier 'C02ABC123XYZ' -CommandStatus pending

    .EXAMPLE
        Get-FleetHost -Id 12 | Get-FleetMdmCommand -RequestType DeviceLock

    .NOTES
        Requires MDM to be turned on in Fleet.
        https://fleetdm.com/docs/rest-api/rest-api#list-mdm-commands

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#list-mdm-commands
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.MdmCommand')]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('hardware_serial')]
        [ValidateNotNullOrEmpty()]
        [string]$HostIdentifier,

        [ValidateNotNullOrEmpty()]
        [string]$RequestType,

        [ValidateSet('ran', 'pending', 'failed')]
        [string[]]$CommandStatus
    )

    process {
        $queryParams = @{ per_page = 1000 }
        if ($HostIdentifier) { $queryParams['host_identifier'] = $HostIdentifier }
        if ($RequestType) { $queryParams['request_type'] = $RequestType }
        if ($CommandStatus) { $queryParams['command_status'] = @($CommandStatus) }

        $response = Invoke-FleetDMRequest -Endpoint 'commands' -QueryParameters $queryParams -FollowPagination
        return (Get-FleetListResult -Response $response -Name 'results' -TypeName 'FleetDM.MdmCommand')
    }
}
