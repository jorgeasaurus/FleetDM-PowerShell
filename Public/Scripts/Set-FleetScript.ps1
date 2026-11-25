function Set-FleetScript {
    <#
    .SYNOPSIS
        Replaces the contents of a saved script.

    .DESCRIPTION
        Sends PATCH /api/v1/fleet/scripts/{id} as multipart/form-data with the new script file.
        Fleet keeps the script name and ignores the uploaded file name.
        The result always has an id property, including when Fleet returns only script_id.

    .PARAMETER Id
        Script ID.

    .PARAMETER Path
        Local file with the new script contents.

    .PARAMETER Contents
        New script text.

    .EXAMPLE
        Set-FleetScript -Id 12 -Path ./collect-logs.sh

    .EXAMPLE
        Get-FleetScript -Id 12 | Set-FleetScript -Contents 'echo updated'

    .NOTES
        Updating a script that belongs to a fleet requires Fleet Premium.
        https://fleetdm.com/docs/rest-api/rest-api#update-script

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-script
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Path')]
    [OutputType('FleetDM.Script')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,

        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory, ParameterSetName = 'Contents')]
        [ValidateNotNullOrEmpty()]
        [string]$Contents
    )

    process {
        $file = if ($PSCmdlet.ParameterSetName -eq 'Path') {
            Get-FleetUploadFile -Path $Path
        }
        else {
            New-FleetTextFilePart -FileName 'script' -Text $Contents
        }

        if ($PSCmdlet.ShouldProcess("script $Id", 'Replace contents')) {
            $response = Invoke-FleetDMRequest -Endpoint "scripts/$Id" -Method PATCH -Form @{ script = $file }
            # Fleet 4.96 answers with only script_id. The docs show the whole script.
            # Either way the result carries id, so it pipes back into Get-FleetScript.
            $record = Get-FleetResponseRecord -Response $response -Name 'script' -TypeName 'FleetDM.Script'
            if ($record.PSObject.Properties.Name -notcontains 'id') {
                $record | Add-Member -NotePropertyName id -NotePropertyValue $Id
            }
            return $record
        }
    }
}
