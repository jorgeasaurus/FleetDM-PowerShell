function Set-FleetConfigurationProfile {
    <#
    .SYNOPSIS
        Updates a configuration profile's file, labels, activation, or self-service settings.

    .DESCRIPTION
        Sends PATCH /api/v1/fleet/configuration_profiles/{profile_uuid} as multipart/form-data.

        Fleet replaces label targeting on every PATCH and targets all hosts when no label is sent.
        To keep targeting, this cmdlet reads the profile and sends its current labels again when
        no label parameter is passed. Any label parameter replaces all label targeting.
        -ClearLabels sends no labels, so the profile targets all hosts.

        SelfService and Hidden keep their current values when omitted.

    .PARAMETER ProfileUuid
        Profile UUID. Binds from the profile_uuid property.

    .PARAMETER Path
        Replacement profile file. A .mobileconfig must keep the same PayloadIdentifier.

    .PARAMETER LabelsIncludeAll
        Targets hosts that have all of these labels.

    .PARAMETER LabelsIncludeAny
        Targets hosts that have any of these labels.

    .PARAMETER LabelsExcludeAny
        Skips hosts that have any of these labels.

    .PARAMETER ClearLabels
        Removes label targeting so the profile targets all hosts.

    .PARAMETER ActivationPath
        Replacement activation JSON for a declaration (DDM) profile.

    .PARAMETER RemoveActivation
        Removes the activation from a declaration (DDM) profile.

    .PARAMETER SelfService
        Sets whether a .mobileconfig profile is opt-in.

    .PARAMETER Hidden
        Sets whether the profile is hidden on My device > Controls.

    .EXAMPLE
        Set-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24' -LabelsIncludeAny 'Engineering'

    .EXAMPLE
        Set-FleetConfigurationProfile -ProfileUuid 'a954ec5ea-a334-4825-87b3-937e7e381f24' -Path ./passcode.mobileconfig

        Replaces the file and keeps the current labels.

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#update-configuration-profile

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-configuration-profile
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.ConfigurationProfile')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('profile_uuid')]
        [ValidatePattern('^[A-Za-z]?[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$')]
        [string]$ProfileUuid,

        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAll,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsIncludeAny,

        [ValidateNotNullOrEmpty()]
        [string[]]$LabelsExcludeAny,

        [switch]$ClearLabels,

        [ValidateNotNullOrEmpty()]
        [string]$ActivationPath,

        [switch]$RemoveActivation,

        [bool]$SelfService,

        [bool]$Hidden
    )

    process {
        $labelParameters = @('LabelsIncludeAll', 'LabelsIncludeAny', 'LabelsExcludeAny') | Where-Object { $PSBoundParameters.ContainsKey($_) }
        if ($ClearLabels -and $labelParameters) {
            throw 'ClearLabels cannot be combined with a label parameter.'
        }
        if ($RemoveActivation -and $PSBoundParameters.ContainsKey('ActivationPath')) {
            throw 'RemoveActivation cannot be combined with ActivationPath.'
        }

        $form = [ordered]@{}
        if ($PSBoundParameters.ContainsKey('Path')) { $form['profile'] = Get-FleetUploadFile -Path $Path }
        Add-FleetLabelTarget -Target $form -BoundParameters $PSBoundParameters
        if ($PSBoundParameters.ContainsKey('ActivationPath')) { $form['activation'] = Get-FleetUploadFile -Path $ActivationPath }
        if ($RemoveActivation) { $form['activation'] = '' }
        if ($PSBoundParameters.ContainsKey('SelfService')) { $form['self_service'] = $SelfService }
        if ($PSBoundParameters.ContainsKey('Hidden')) { $form['hidden'] = $Hidden }

        if ($form.Count -eq 0 -and -not $ClearLabels) {
            Write-Warning "No updates specified for configuration profile $ProfileUuid"
            return
        }

        if ($PSCmdlet.ShouldProcess("configuration profile $ProfileUuid", 'Update')) {
            if (-not $labelParameters -and -not $ClearLabels) {
                $current = Invoke-FleetDMRequest -Endpoint "configuration_profiles/$ProfileUuid" -Method GET
                foreach ($field in 'labels_include_all', 'labels_include_any', 'labels_exclude_any') {
                    $names = @($current.$field | Where-Object { $_ } | ForEach-Object { $_.name })
                    if ($names.Count -gt 0) { $form[$field] = $names }
                }
            }

            $response = Invoke-FleetDMRequest -Endpoint "configuration_profiles/$ProfileUuid" -Method PATCH -Form $form
            $null = Add-FleetTypeName -InputObject $response -TypeName 'FleetDM.ConfigurationProfile'
            return $response
        }
    }
}
