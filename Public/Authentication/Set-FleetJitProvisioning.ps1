function Set-FleetJitProvisioning {
    <#
    .SYNOPSIS
        Enables or disables SSO just-in-time user provisioning.

    .DESCRIPTION
        Reads GET /api/v1/fleet/config and sends PATCH /api/v1/fleet/config
        with the existing sso_settings plus enable_jit_provisioning.
        JIT provisioning is the Premium SSO control. Basic SSO configuration is available in Fleet Free.

    .PARAMETER Enabled
        When true, Fleet creates users the first time they sign in with SSO.

    .EXAMPLE
        Set-FleetJitProvisioning -Enabled $true

    .NOTES
        enable_jit_provisioning requires Fleet Premium and returns HTTP 402 on Fleet Free.
        https://fleetdm.com/docs/rest-api/rest-api#update-configuration
        https://fleetdm.com/docs/deploy/single-sign-on-sso

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#update-configuration
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [bool]$Enabled
    )

    process {
        $config = Invoke-FleetDMRequest -Endpoint 'config' -Method GET
        $sso = @{}
        if ($config.sso_settings) {
            foreach ($prop in $config.sso_settings.PSObject.Properties) {
                $sso[$prop.Name] = $prop.Value
            }
        }
        $sso['enable_jit_provisioning'] = [bool]$Enabled

        if ($PSCmdlet.ShouldProcess('Fleet SSO settings', "Set enable_jit_provisioning to $Enabled")) {
            $response = Invoke-FleetDMRequest -Endpoint 'config' -Method PATCH -Body @{ sso_settings = $sso }
            $updated = $response.sso_settings
            if (-not $updated) { $updated = [PSCustomObject]$sso }
            if ($updated.PSObject) {
                $updated.PSObject.TypeNames.Insert(0, 'FleetDM.SsoSettings')
            }
            return $updated
        }
    }
}
