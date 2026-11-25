function New-FleetScript {
    <#
    .SYNOPSIS
        Uploads a saved script.

    .DESCRIPTION
        Sends POST /api/v1/fleet/scripts as multipart/form-data with the script file.
        Fleet names the script after the file name and converts CRLF line endings to LF.
        The request body limit is 1.5 MiB.

    .PARAMETER Path
        Local script file to upload. The file name becomes the script name.

    .PARAMETER Contents
        Script text to upload instead of a file. Requires Name.

    .PARAMETER Name
        Script file name used with Contents, for example collect.sh or Fix-Thing.ps1.
        The extension tells Fleet which hosts can run it.

    .PARAMETER FleetId
        Fleet Premium. Saves the script on this fleet. Omit it, or use 0, for "Unassigned" hosts.

    .EXAMPLE
        New-FleetScript -Path ./collect-logs.sh -FleetId 2

    .EXAMPLE
        New-FleetScript -Name 'hello.sh' -Contents 'echo hello'

    .NOTES
        Saving a script on a fleet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#create-script

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#create-script
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Path')]
    [OutputType('FleetDM.Script')]
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

    $file = if ($PSCmdlet.ParameterSetName -eq 'Path') {
        Get-FleetUploadFile -Path $Path
    }
    else {
        New-FleetTextFilePart -FileName $Name -Text $Contents
    }

    $form = [ordered]@{ script = $file }
    $target = "script '$($file.FileName)' for unassigned hosts"
    if ($PSBoundParameters.ContainsKey('FleetId')) {
        $form['fleet_id'] = $FleetId
        $target = "script '$($file.FileName)' on fleet $FleetId"
    }

    if ($PSCmdlet.ShouldProcess($target, 'Create')) {
        $response = Invoke-FleetDMRequest -Endpoint 'scripts' -Method POST -Form $form
        [PSCustomObject]@{
            PSTypeName = 'FleetDM.Script'
            id = $response.script_id
            name = $file.FileName
            fleet_id = if ($PSBoundParameters.ContainsKey('FleetId')) { $FleetId } else { $null }
        }
    }
}
