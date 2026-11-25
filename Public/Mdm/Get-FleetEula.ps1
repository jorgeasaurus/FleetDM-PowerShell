function Get-FleetEula {
    <#
    .SYNOPSIS
        Gets the setup EULA metadata, or downloads the EULA file.

    .DESCRIPTION
        Sends GET /api/v1/fleet/setup_experience/eula/metadata. With OutFile, it then sends
        GET /api/v1/fleet/setup_experience/eula/{token} and saves the file.
        Fleet answers 404 when no EULA was uploaded for the platform.

    .PARAMETER Platform
        darwin (a PDF shown in macOS Setup Assistant) or windows (Markdown terms). Fleet defaults to darwin.

    .PARAMETER OutFile
        Saves the EULA file to this path and returns the file.

    .EXAMPLE
        Get-FleetEula

    .EXAMPLE
        Get-FleetEula -Platform windows -OutFile ./terms.md

    .NOTES
        This cmdlet requires Fleet Premium. Fleet Free responds with HTTP 402.
        https://fleetdm.com/docs/rest-api/rest-api#get-eula-metadata

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#get-eula-metadata
    #>
    [CmdletBinding()]
    [OutputType('FleetDM.Eula', [System.IO.FileInfo])]
    param(
        [ValidateSet('darwin', 'windows')]
        [string]$Platform,

        [ValidateNotNullOrEmpty()]
        [string]$OutFile
    )

    $queryParams = @{}
    if ($Platform) { $queryParams['platform'] = $Platform }
    $metadata = Invoke-FleetDMRequest -Endpoint 'setup_experience/eula/metadata' -QueryParameters $queryParams

    if ($OutFile) {
        return (Save-FleetDownload -Endpoint "setup_experience/eula/$([uri]::EscapeDataString([string]$metadata.token))" -OutFile $OutFile)
    }

    $null = Add-FleetTypeName -InputObject $metadata -TypeName 'FleetDM.Eula'
    return $metadata
}
