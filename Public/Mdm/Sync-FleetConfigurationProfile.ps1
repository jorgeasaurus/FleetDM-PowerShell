function Sync-FleetConfigurationProfile {
    <#
    .SYNOPSIS
        Replaces every configuration profile on a fleet with a set of files.

    .DESCRIPTION
        Sends POST /api/v1/fleet/configuration_profiles/batch with each file base64 encoded.
        The files become the complete profile set for the fleet. Profiles not in the list are removed,
        and Fleet sends a remove command to Apple hosts for them.

        Windows .xml and DDM .json profiles are named after the file name without its extension.
        A .mobileconfig profile takes its PayloadDisplayName.

        -DryRun asks Fleet to validate the set without applying it.

    .PARAMETER Path
        Profile files that make up the complete set.

    .PARAMETER FleetId
        Fleet Premium. Fleet that receives the set. Omit FleetId and FleetName for "Unassigned" hosts.

    .PARAMETER FleetName
        Fleet Premium. Fleet name instead of FleetId.

    .PARAMETER DryRun
        Validates the set and applies nothing.

    .EXAMPLE
        Sync-FleetConfigurationProfile -Path ./profiles/*.mobileconfig -FleetId 2 -DryRun

    .EXAMPLE
        Sync-FleetConfigurationProfile -Path ./passcode.mobileconfig, ./firewall.xml -FleetName 'Workstations'

    .NOTES
        This replaces the whole set. Profiles that are not listed are deleted.
        FleetId and FleetName require Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#batch-update-configuration-profiles

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#batch-update-configuration-profiles
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Unassigned')]
    [OutputType('FleetDM.ConfigurationProfileSync')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory, ParameterSetName = 'FleetId')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory, ParameterSetName = 'FleetName')]
        [ValidateNotNullOrEmpty()]
        [string]$FleetName,

        [switch]$DryRun
    )

    $files = foreach ($entry in $Path) {
        $resolved = @(Resolve-Path -Path $entry -ErrorAction SilentlyContinue | Where-Object { Test-Path -LiteralPath $_.ProviderPath -PathType Leaf })
        if ($resolved.Count -eq 0) {
            throw "File not found: $entry"
        }
        $resolved | ForEach-Object { $_.ProviderPath }
    }

    $profiles = foreach ($file in @($files | Select-Object -Unique)) {
        $item = @{ profile = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($file)) }
        if ([System.IO.Path]::GetExtension($file) -ne '.mobileconfig') {
            $item['name'] = [System.IO.Path]::GetFileNameWithoutExtension($file)
        }
        $item
    }
    $profiles = @($profiles)

    $query = @{}
    $scope = 'unassigned hosts'
    switch ($PSCmdlet.ParameterSetName) {
        'FleetId' { $query['fleet_id'] = $FleetId; $scope = "fleet $FleetId" }
        'FleetName' { $query['fleet_name'] = $FleetName; $scope = "fleet '$FleetName'" }
    }
    if ($DryRun) { $query['dry_run'] = $true }

    $action = if ($DryRun) {
        'Validate profile set (dry run, nothing is applied)'
    }
    else {
        "Replace all configuration profiles with $($profiles.Count) file(s). Profiles not in the list are removed"
    }

    if ($PSCmdlet.ShouldProcess($scope, $action)) {
        $null = Invoke-FleetDMRequest -Endpoint 'configuration_profiles/batch' -Method POST -QueryParameters $query -Body @{ configuration_profiles = $profiles }
        [PSCustomObject]@{
            PSTypeName = 'FleetDM.ConfigurationProfileSync'
            FleetId = if ($PSCmdlet.ParameterSetName -eq 'FleetId') { $FleetId } else { $null }
            FleetName = if ($PSCmdlet.ParameterSetName -eq 'FleetName') { $FleetName } else { $null }
            ProfileCount = $profiles.Count
            Files = @($files | Select-Object -Unique | ForEach-Object { [System.IO.Path]::GetFileName($_) })
            DryRun = [bool]$DryRun
        }
    }
}
