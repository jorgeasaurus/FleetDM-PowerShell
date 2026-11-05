function New-FleetUser {
    <#
    .SYNOPSIS
        Creates a Fleet user.

    .DESCRIPTION
        Sends POST /api/v1/fleet/users/admin.
        This is the REST call behind fleetctl user create.
        An API-only user response includes a token. Fleet returns that token only when api_only is true.

    .PARAMETER Name
        User name.

    .PARAMETER Email
        User email.

    .PARAMETER Password
        User password.

    .PARAMETER ApiOnly
        Creates an API-only user. The user cannot sign in to the Fleet UI.

    .PARAMETER GlobalRole
        Global role. Allowed values are admin, maintainer, observer, observer_plus, and gitops.
        Omit it to let Fleet assign observer.

    .EXAMPLE
        $password = Read-Host "Password" -AsSecureString
        New-FleetUser -Name "module-test" -Email "api@example.com" -Password $password -ApiOnly -GlobalRole admin

        Creates a global admin API-only user and returns the user, including Token.

    .LINK
        https://fleetdm.com/docs/rest-api/rest-api#create-user
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Email,

        [Parameter(Mandatory)]
        [securestring]$Password,

        [switch]$ApiOnly,

        [ValidateSet('admin', 'maintainer', 'observer', 'observer_plus', 'gitops')]
        [string]$GlobalRole
    )

    process {
        $passwordBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        try {
            $passwordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordBstr)
        }
        finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordBstr)
        }

        $body = @{
            name = $Name
            email = $Email
            password = $passwordPlain
        }
        if ($ApiOnly) {
            $body['api_only'] = $true
            # A forced reset blocks an API-only user from using the password Fleet just stored.
            $body['admin_forced_password_reset'] = $false
        }
        if ($PSBoundParameters.ContainsKey('GlobalRole')) {
            $body['global_role'] = $GlobalRole
        }

        if ($PSCmdlet.ShouldProcess($Email, 'Create Fleet user')) {
            $response = Invoke-FleetDMRequest -Endpoint 'users/admin' -Method POST -Body $body
            $user = Get-FleetResponseRecord -Response $response -Name 'user' -TypeName 'FleetDM.User'
            if ($user -and $response.token) {
                $user | Add-Member -NotePropertyName Token -NotePropertyValue $response.token -Force
            }
            return $user
        }
    }
}
