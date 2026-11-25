function Remove-FleetEula {
    <#
    .SYNOPSIS
        Deletes the setup EULA.

    .DESCRIPTION
        Sends DELETE /api/v1/fleet/setup_experience/eula/{token}.
        Without Token, the token is read from GET /api/v1/fleet/setup_experience/eula/metadata first.
        The lookup runs only after confirmation, so -WhatIf sends nothing.

    .PARAMETER Platform
        darwin or windows. Used to look up the token. Fleet defaults to darwin.

    .PARAMETER Token
        EULA token. Binds from the token property of Get-FleetEula output.

    .PARAMETER Force
        Skips the confirmation prompt. -WhatIf is still honored.

    .EXAMPLE
        Remove-FleetEula -Platform windows

    .EXAMPLE
        Get-FleetEula | Remove-FleetEula -Force

    .NOTES
        This cmdlet requires Fleet Premium and a global admin or GitOps role.
        https://fleetdm.com/docs/rest-api/rest-api#delete-eula

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#delete-eula
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Platform')]
    [OutputType('FleetDM.RemovedEula')]
    param(
        [Parameter(ParameterSetName = 'Platform')]
        [ValidateSet('darwin', 'windows')]
        [string]$Platform,

        [Parameter(Mandatory, ParameterSetName = 'Token', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Token,

        [switch]$Force
    )

    process {
        if ($Force -and -not $WhatIfPreference) {
            $ConfirmPreference = 'None'
        }

        $target = if ($Token) { "EULA $Token" } elseif ($Platform) { "$Platform EULA" } else { 'darwin EULA' }
        if ($PSCmdlet.ShouldProcess($target, 'Remove')) {
            $eulaToken = $Token
            if (-not $eulaToken) {
                $queryParams = @{}
                if ($Platform) { $queryParams['platform'] = $Platform }
                $metadata = Invoke-FleetDMRequest -Endpoint 'setup_experience/eula/metadata' -QueryParameters $queryParams
                $eulaToken = [string]$metadata.token
            }

            $null = Invoke-FleetDMRequest -Endpoint "setup_experience/eula/$([uri]::EscapeDataString($eulaToken))" -Method DELETE
            [PSCustomObject]@{
                PSTypeName = 'FleetDM.RemovedEula'
                Token = $eulaToken
                Status = 'Removed'
            }
        }
    }
}
