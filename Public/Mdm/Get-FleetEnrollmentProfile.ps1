function Get-FleetEnrollmentProfile {
    <#
    .SYNOPSIS
        Gets the custom automatic enrollment (ADE) profile, or Fleet's default one.

    .DESCRIPTION
        Sends GET /api/v1/fleet/enrollment_profiles/automatic, or GET /api/v1/fleet/enrollment_profiles/automatic/default with -Default.
        The default profile is shared by every fleet and Apple Business token.

    .PARAMETER FleetId
        Fleet whose custom profile is read. Omit it for "Unassigned".

    .PARAMETER Default
        Reads Fleet's default enrollment profile.

    .EXAMPLE
        Get-FleetEnrollmentProfile -FleetId 2

    .EXAMPLE
        Get-FleetEnrollmentProfile -Default

    .NOTES
        This cmdlet requires Fleet Premium and Apple MDM. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#get-custom-mdm-setup-enrollment-profile

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#get-custom-mdm-setup-enrollment-profile
    #>
    [CmdletBinding(DefaultParameterSetName = 'Custom')]
    [OutputType('FleetDM.EnrollmentProfile')]
    param(
        [Parameter(ParameterSetName = 'Custom')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [switch]$Default
    )

    if ($Default) {
        $response = Invoke-FleetDMRequest -Endpoint 'enrollment_profiles/automatic/default' -Method GET
    }
    else {
        $queryParams = @{}
        if ($PSBoundParameters.ContainsKey('FleetId')) { $queryParams['fleet_id'] = $FleetId }
        $response = Invoke-FleetDMRequest -Endpoint 'enrollment_profiles/automatic' -Method GET -QueryParameters $queryParams
    }

    $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.EnrollmentProfile'
    return $response
}
