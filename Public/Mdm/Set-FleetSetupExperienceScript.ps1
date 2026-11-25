function Set-FleetSetupExperienceScript {
    <#
    .SYNOPSIS
        Uploads the script that runs during macOS setup.

    .DESCRIPTION
        Sends POST /api/v1/fleet/setup_experience/script as multipart/form-data with the script file.
        A fleet has one setup script. Remove the current one with Remove-FleetSetupExperienceScript before uploading a new one.

    .PARAMETER Path
        Local script file.

    .PARAMETER Contents
        Script text instead of a file. Requires Name.

    .PARAMETER Name
        Script file name used with Contents.

    .PARAMETER FleetId
        Fleet that runs the script. Omit it for "Unassigned".

    .EXAMPLE
        Set-FleetSetupExperienceScript -FleetId 3 -Path ./setup.sh

    .EXAMPLE
        Set-FleetSetupExperienceScript -Name 'setup.sh' -Contents 'echo setup'

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#create-setup-experience-script

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#create-setup-experience-script
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Path')]
    [OutputType('FleetDM.SetupExperienceScript')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Path', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory, ParameterSetName = 'Contents')]
        [ValidateNotNullOrEmpty()]
        [string]$Contents,

        [Parameter(Mandatory, ParameterSetName = 'Contents')]
        [ValidatePattern('^[^\\/]+$')]
        [string]$Name,

        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId
    )

    $file = if ($PSCmdlet.ParameterSetName -eq 'Path') { Get-FleetUploadFile -Path $Path } else { New-FleetTextFilePart -FileName $Name -Text $Contents }
    $form = [ordered]@{ script = $file }
    $scope = 'unassigned hosts'
    if ($PSBoundParameters.ContainsKey('FleetId')) {
        $form['fleet_id'] = $FleetId
        $scope = "fleet $FleetId"
    }

    if ($PSCmdlet.ShouldProcess("setup script '$($file.FileName)' for $scope", 'Upload')) {
        $null = Invoke-FleetDMRequest -Endpoint 'setup_experience/script' -Method POST -Form $form
        [PSCustomObject]@{
            PSTypeName = 'FleetDM.SetupExperienceScript'
            name = $file.FileName
            fleet_id = if ($PSBoundParameters.ContainsKey('FleetId')) { $FleetId } else { $null }
        }
    }
}
