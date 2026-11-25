function Save-FleetSoftwarePackage {
    <#
    .SYNOPSIS
        Downloads a software installer to a local file.

    .DESCRIPTION
        Sends GET /api/v1/fleet/software/titles/{id}/package?alt=media and writes the response to OutFile.
        Invoke-RestMethod streams the body to disk. The saved file is returned.

    .PARAMETER SoftwareTitleId
        Software title ID. Binds from the software_title_id or id property.

    .PARAMETER FleetId
        Fleet that owns the installer. Use 0 for "Unassigned".

    .PARAMETER OutFile
        Local path for the installer. An existing file is overwritten.

    .EXAMPLE
        Save-FleetSoftwarePackage -SoftwareTitleId 123 -FleetId 2 -OutFile ./FalconSensor.pkg

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#download-software

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#download-software
    #>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('software_title_id', 'Id')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$SoftwareTitleId,

        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutFile
    )

    process {
        return (Save-FleetDownload -Endpoint "software/titles/$SoftwareTitleId/package" -QueryParameters @{ alt = 'media'; fleet_id = $FleetId } -OutFile $OutFile)
    }
}
