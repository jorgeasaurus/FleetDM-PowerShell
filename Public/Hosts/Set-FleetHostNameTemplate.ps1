function Set-FleetHostNameTemplate {
    <#
    .SYNOPSIS
        Sets or clears the host name template for Apple hosts on a fleet.

    .DESCRIPTION
        Sends POST /api/v1/fleet/host_name_template with fleet_id and name_template.
        Fleet renames macOS, iOS, and iPadOS hosts with an MDM command. An empty Template clears the template
        and stops enforcement without renaming any host. The empty string is sent, not dropped.

    .PARAMETER FleetId
        Fleet ID. Use 0 for "Unassigned".

    .PARAMETER Template
        Name template, such as 'iPad $FLEET_VAR_HOST_HARDWARE_SERIAL'. Use an empty string to clear it.
        Use single quotes so PowerShell does not expand the variables.

    .EXAMPLE
        Set-FleetHostNameTemplate -FleetId 5 -Template 'iPad $FLEET_VAR_HOST_HARDWARE_SERIAL'

    .EXAMPLE
        Set-FleetHostNameTemplate -FleetId 5 -Template ''

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        Fleet returns 422 for certificate authority variables and undefined custom variables.
        https://fleetdm.com/docs/rest-api/rest-api#update-host-name-template

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-host-name-template
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType('FleetDM.HostNameTemplate')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Template
    )

    $action = if ($Template -eq '') { 'Clear host name template' } else { "Set host name template to '$Template'" }
    if ($PSCmdlet.ShouldProcess("fleet $FleetId", $action)) {
        $null = Invoke-FleetDMRequest -Endpoint 'host_name_template' -Method POST -Body @{ fleet_id = $FleetId; name_template = $Template }
        [PSCustomObject]@{
            PSTypeName = 'FleetDM.HostNameTemplate'
            FleetId = $FleetId
            Template = $Template
            Status = if ($Template -eq '') { 'Cleared' } else { 'Set' }
        }
    }
}
