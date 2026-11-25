function Set-FleetSetupExperienceSoftware {
    <#
    .SYNOPSIS
        Sets the software that installs during setup for one platform.

    .DESCRIPTION
        Sends PUT /api/v1/fleet/setup_experience/software with fleet_id, platform, and software_title_ids.
        The list replaces the current one for that fleet and platform. Titles not in the list stop installing during setup.
        -Clear sends an empty list. Piping no titles throws and sends nothing. An empty list would clear setup software for that fleet and platform.

    .PARAMETER SoftwareTitleId
        Software title IDs to install during setup. Binds from the id or software_title_id property of piped titles.

    .PARAMETER Clear
        Removes every title from setup for this fleet and platform.

    .PARAMETER FleetId
        Fleet to update. Use 0 for "Unassigned". The default is 0.

    .PARAMETER Platform
        macos, windows, linux, ios, ipados, or android. Fleet defaults to macos.

    .EXAMPLE
        Set-FleetSetupExperienceSoftware -FleetId 2 -Platform linux -SoftwareTitleId 3000, 3001

    .EXAMPLE
        Set-FleetSetupExperienceSoftware -FleetId 2 -Platform windows -Clear

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#update-setup-experience-software

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-setup-experience-software
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Set')]
    [OutputType('FleetDM.SetupExperienceSoftwareUpdate')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Set', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id', 'software_title_id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$SoftwareTitleId,

        [Parameter(Mandatory, ParameterSetName = 'Clear')]
        [switch]$Clear,

        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId = 0,

        [ValidateSet('macos', 'windows', 'linux', 'ios', 'ipados', 'android')]
        [string]$Platform
    )

    begin {
        $ids = New-Object System.Collections.Generic.List[int]
    }

    process {
        foreach ($id in @($SoftwareTitleId)) {
            if ($id -and -not $ids.Contains($id)) { $ids.Add($id) }
        }
    }

    end {
        if (-not $Clear -and $ids.Count -eq 0) {
            throw 'No software titles were given. An empty list clears setup software for this fleet and platform. Pass -Clear to remove them on purpose.'
        }

        $body = @{ fleet_id = $FleetId; software_title_ids = @($ids.ToArray()) }
        if ($Platform) { $body['platform'] = $Platform }
        $platformText = if ($Platform) { $Platform } else { 'macos' }
        $action = if ($Clear) { 'Remove all setup software' } else { "Replace setup software with titles $($ids -join ', ')" }

        if ($PSCmdlet.ShouldProcess("fleet $FleetId ($platformText)", $action)) {
            $null = Invoke-FleetDMRequest -Endpoint 'setup_experience/software' -Method PUT -Body $body
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.SetupExperienceSoftwareUpdate'
                FleetId = $FleetId
                Platform = $platformText
                SoftwareTitleId = @($ids.ToArray())
            }
        }
    }
}
