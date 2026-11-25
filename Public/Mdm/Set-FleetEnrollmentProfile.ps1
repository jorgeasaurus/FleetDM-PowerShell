function Set-FleetEnrollmentProfile {
    <#
    .SYNOPSIS
        Sets the custom automatic enrollment (ADE) profile for a fleet.

    .DESCRIPTION
        Sends POST /api/v1/fleet/enrollment_profiles/automatic with fleet_id, name, and enrollment_profile.
        The file is Apple's enrollment profile JSON. Fleet fills in ConfigurationWebURL and URL.

    .PARAMETER Path
        Local enrollment profile JSON file.

    .PARAMETER FleetId
        Fleet that uses the profile. Omit it for "Unassigned".

    .PARAMETER Name
        Name stored with the profile. The default is the file name.

    .EXAMPLE
        Set-FleetEnrollmentProfile -FleetId 2 -Path ./dep_profile.json

    .NOTES
        This cmdlet requires Fleet Premium and Apple MDM. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#update-custom-mdm-setup-enrollment-profile

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-custom-mdm-setup-enrollment-profile
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.EnrollmentProfile')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $file = Get-FleetUploadFile -Path $Path
    try {
        # ConvertFrom-Json on Windows PowerShell 5.1 stores a one-element array as a scalar.
        $profileText = [System.Text.Encoding]::UTF8.GetString($file.Bytes).TrimStart([char]0xFEFF)
        $enrollmentProfile = ConvertFrom-FleetJson -Json $profileText
    }
    catch {
        throw "Enrollment profile '$Path' is not valid JSON: $($_.Exception.Message)"
    }
    if ($enrollmentProfile -isnot [System.Management.Automation.PSCustomObject]) {
        throw "Enrollment profile '$Path' must be a JSON object."
    }

    $body = @{
        name = if ($Name) { $Name } else { $file.FileName }
        enrollment_profile = $enrollmentProfile
    }
    $scope = 'unassigned hosts'
    if ($PSBoundParameters.ContainsKey('FleetId')) {
        $body['fleet_id'] = $FleetId
        $scope = "fleet $FleetId"
    }

    if ($PSCmdlet.ShouldProcess("enrollment profile for $scope", 'Set')) {
        $response = Invoke-FleetDMRequest -Endpoint 'enrollment_profiles/automatic' -Method POST -Body $body
        $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.EnrollmentProfile'
        return $response
    }
}
