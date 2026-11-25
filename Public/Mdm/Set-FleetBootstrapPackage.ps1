function Set-FleetBootstrapPackage {
    <#
    .SYNOPSIS
        Uploads a fleet's bootstrap package.

    .DESCRIPTION
        Sends POST /api/v1/fleet/bootstrap as multipart/form-data with package, fleet_id, and manual_agent_install.
        The package must be a signed .pkg. It is streamed from disk through a temporary multipart file.

    .PARAMETER Path
        Local signed .pkg file.

    .PARAMETER FleetId
        Fleet ID. Use 0 for "Unassigned".

    .PARAMETER ManualAgentInstall
        Skips installing fleetd during automatic enrollment. The bootstrap package must install it.

    .EXAMPLE
        Set-FleetBootstrapPackage -FleetId 1 -Path ./bootstrap.pkg

    .NOTES
        This cmdlet requires Fleet Premium and Apple MDM. Fleet Free responds with HTTP 402.
        The request body limit is 10 GB.
        https://fleetdm.com/docs/rest-api/rest-api#create-bootstrap-package

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#create-bootstrap-package
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType('FleetDM.BootstrapPackage')]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FleetId,

        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [switch]$ManualAgentInstall
    )

    $form = [ordered]@{
        fleet_id = $FleetId
        package = (Get-FleetUploadFile -Path $Path -Stream)
    }
    if ($PSBoundParameters.ContainsKey('ManualAgentInstall')) { $form['manual_agent_install'] = [bool]$ManualAgentInstall }

    if ($PSCmdlet.ShouldProcess("bootstrap package '$($form.package.FileName)' for fleet $FleetId", 'Upload')) {
        $null = Invoke-FleetDMRequest -Endpoint 'bootstrap' -Method POST -Form $form
        [PSCustomObject]@{
            PSTypeName = 'FleetDM.BootstrapPackage'
            name = $form.package.FileName
            fleet_id = $FleetId
        }
    }
}
