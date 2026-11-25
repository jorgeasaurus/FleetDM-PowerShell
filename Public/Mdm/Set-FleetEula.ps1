function Set-FleetEula {
    <#
    .SYNOPSIS
        Uploads the EULA shown during setup.

    .DESCRIPTION
        Sends POST /api/v1/fleet/setup_experience/eula as multipart/form-data with eula and platform.
        darwin takes a PDF up to 25 MiB. windows takes a Markdown file up to 512 KB.

    .PARAMETER Path
        Local EULA file.

    .PARAMETER Platform
        darwin or windows. Fleet defaults to darwin.

    .EXAMPLE
        Set-FleetEula -Path ./eula.pdf

    .EXAMPLE
        Set-FleetEula -Path ./terms.md -Platform windows

    .NOTES
        This cmdlet requires Fleet Premium and a global admin or GitOps role.
        https://fleetdm.com/docs/rest-api/rest-api#create-eula

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#create-eula
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.Eula')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [ValidateSet('darwin', 'windows')]
        [string]$Platform
    )

    $form = [ordered]@{ eula = (Get-FleetUploadFile -Path $Path) }
    if ($Platform) { $form['platform'] = $Platform }
    $platformText = if ($Platform) { $Platform } else { 'darwin' }

    if ($PSCmdlet.ShouldProcess("$platformText EULA '$($form.eula.FileName)'", 'Upload')) {
        $null = Invoke-FleetDMRequest -Endpoint 'setup_experience/eula' -Method POST -Form $form
        [PSCustomObject]@{
            PSTypeName = 'FleetDM.Eula'
            name = $form.eula.FileName
            platform = $platformText
        }
    }
}
