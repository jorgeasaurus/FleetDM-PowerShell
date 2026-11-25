function New-FleetConfigurationProfile {
    <#
    .SYNOPSIS
        Uploads a configuration profile.

    .DESCRIPTION
        Sends POST /api/v1/fleet/configuration_profiles as multipart/form-data.
        Accepts a .mobileconfig or DDM .json profile for Apple hosts, an .xml profile for Windows, or a .json profile for Android.
        Label lists are sent as one form field per label name.
        LabelsIncludeAll and LabelsIncludeAny cannot be combined. LabelsExcludeAny can be combined with either.

    .PARAMETER Path
        Local profile file.

    .PARAMETER Name
        Display name. Fleet derives one from the file when omitted.

    .PARAMETER Description
        Optional description.

    .PARAMETER FleetId
        Fleet Premium. Applies the profile to hosts on this fleet. Omit it for "Unassigned" hosts.

    .PARAMETER LabelsIncludeAll
        Fleet Premium. Targets hosts that have all of these labels.

    .PARAMETER LabelsIncludeAny
        Fleet Premium. Targets hosts that have any of these labels.

    .PARAMETER LabelsExcludeAny
        Fleet Premium. Skips hosts that have any of these labels.

    .PARAMETER ActivationPath
        Fleet Premium. Activation JSON file for a declaration (DDM) profile.

    .PARAMETER SelfService
        Fleet Premium. Makes a .mobileconfig profile opt-in from My device > Controls.

    .PARAMETER Hidden
        Fleet Premium. Hides the profile on My device > Controls. Cannot be combined with SelfService.

    .EXAMPLE
        New-FleetConfigurationProfile -Path ./passcode.mobileconfig -FleetId 2 -LabelsIncludeAny 'Engineering', 'QA'

    .EXAMPLE
        New-FleetConfigurationProfile -Path ./firewall.xml -Name 'Windows firewall' -LabelsExcludeAny 'Servers'

    .NOTES
        Requires MDM for the profile's platform. Labels, activation, self-service, hidden, and FleetId require Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#create-configuration-profile

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#create-configuration-profile
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.ConfigurationProfile')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [string]$Description,

        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAll,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAny,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsExcludeAny,

        [ValidateNotNullOrEmpty()]
        [string]$ActivationPath,

        [switch]$SelfService,

        [switch]$Hidden
    )

    if ($SelfService -and $Hidden) {
        throw 'Hidden requires SelfService to be off.'
    }

    $form = [ordered]@{ profile = (Get-FleetUploadFile -Path $Path) }
    if ($PSBoundParameters.ContainsKey('Name')) { $form['name'] = $Name }
    if ($PSBoundParameters.ContainsKey('Description')) { $form['description'] = $Description }
    if ($PSBoundParameters.ContainsKey('FleetId')) { $form['fleet_id'] = $FleetId }
    Add-FleetLabelTarget -Target $form -BoundParameters $PSBoundParameters
    if ($PSBoundParameters.ContainsKey('ActivationPath')) { $form['activation'] = Get-FleetUploadFile -Path $ActivationPath }
    if ($SelfService) { $form['self_service'] = $true }
    if ($Hidden) { $form['hidden'] = $true }

    $scope = if ($PSBoundParameters.ContainsKey('FleetId')) { "fleet $FleetId" } else { 'unassigned hosts' }
    if ($PSCmdlet.ShouldProcess("profile '$($form.profile.FileName)' for $scope", 'Create')) {
        $response = Invoke-FleetDMRequest -Endpoint 'configuration_profiles' -Method POST -Form $form
        $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.ConfigurationProfile'
        return $response
    }
}
