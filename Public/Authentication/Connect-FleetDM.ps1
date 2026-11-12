function Connect-FleetDM {
    <#
    .SYNOPSIS
        Establishes a connection to the FleetDM API
    
    .DESCRIPTION
        Connects to a FleetDM instance using either an API token or email/password credentials.
        The connection is stored at the module level and used by all other FleetDM cmdlets.

        The token is checked with GET /api/v1/fleet/version, then GET /api/v1/fleet/me.
        An API-only user can be limited to specific endpoints. If /version returns 403 and
        /me succeeds, the connection is stored with Version set to $null. HTTP 401 is an
        authentication failure. Other FleetDM cmdlets do not read the stored version.
        Use -SkipVersionCheck to skip /version and require a successful /me call.
    
    .PARAMETER BaseUri
        The base URI of your FleetDM instance (e.g., https://fleet.example.com)
    
    .PARAMETER ApiToken
        A secure string containing the FleetDM API token.
        This is the preferred method for automation and API-only users.
    
    .PARAMETER Credential
        PSCredential object containing email and password for FleetDM authentication.
        Use this for interactive sessions or when token authentication is not available.

    .PARAMETER Email
        Fleet user email. Same value as fleetctl login --email.

    .PARAMETER Password
        Fleet user password. Same value as fleetctl login --password.

    .PARAMETER SkipVersionCheck
        Do not call GET /api/v1/fleet/version. The token is checked with GET /api/v1/fleet/me,
        and the stored version is $null. Use this when an API-only user is not allowed to call
        the version endpoint.
    
    .EXAMPLE
        $token = ConvertTo-SecureString "your-api-token" -AsPlainText -Force
        Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $token
        
        Connects to FleetDM using an API token

    .EXAMPLE
        $password = Read-Host "Password" -AsSecureString
        Connect-FleetDM -BaseUri "https://fleet.example.com" -Email "admin@example.com" -Password $password

        Logs in with email and password, the same call as fleetctl login --email --password
    
    .EXAMPLE
        $cred = Get-Credential
        Connect-FleetDM -BaseUri "https://fleet.example.com" -Credential $cred
        
        Prompts for credentials and connects to FleetDM
    
    .EXAMPLE
        Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken (Read-Host -AsSecureString "Enter API Token")
        
        Prompts for API token securely and connects to FleetDM

    .EXAMPLE
        $token = ConvertTo-SecureString "your-api-token" -AsPlainText -Force
        Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $token -SkipVersionCheck

        Connects when the token can call /me but is not allowed to call /version.
        The connection version is $null.
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api#authentication
    #>
    [CmdletBinding(DefaultParameterSetName = 'Token')]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^https?://')]
        [string]$BaseUri,
        
        [Parameter(Mandatory, ParameterSetName = 'Token')]
        [securestring]$ApiToken,
        
        [Parameter(Mandatory, ParameterSetName = 'Credential')]
        [pscredential]$Credential,

        [Parameter(Mandatory, ParameterSetName = 'Email')]
        [ValidateNotNullOrEmpty()]
        [string]$Email,

        [Parameter(Mandatory, ParameterSetName = 'Email')]
        [securestring]$Password,

        [Parameter()]
        [switch]$SkipVersionCheck
    )
    
    begin {
        # Remove trailing slash from BaseUri if present
        $BaseUri = $BaseUri.TrimEnd('/')
        
        # Initialize web session for connection pooling
        $script:FleetDMWebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    }
    
    process {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'Email') {
                $Credential = [pscredential]::new($Email, $Password)
            }

            $headers = @{
                'Content-Type' = 'application/json'
            }
            
            if ($PSCmdlet.ParameterSetName -eq 'Token') {
                # Convert secure string to plain text - use PtrToStringBSTR for cross-platform compatibility
                $tokenBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ApiToken)
                $tokenPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenBstr)
                
                # Clean up the BSTR
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenBstr)
                
                $headers['Authorization'] = "Bearer $tokenPlain"
                
                Write-Verbose "Attempting token-based authentication to $BaseUri"
            }
            else {
                # Login with credentials
                Write-Verbose "Attempting credential-based authentication to $BaseUri"
                
                $loginBody = @{
                    email = $Credential.UserName
                    password = $Credential.GetNetworkCredential().Password
                } | ConvertTo-Json
                
                $loginUri = "$BaseUri/api/v1/fleet/login"
                
                try {
                    $loginResponse = Invoke-RestMethod -Uri $loginUri `
                        -Method POST `
                        -Body $loginBody `
                        -ContentType 'application/json' `
                        -WebSession $script:FleetDMWebSession `
                        -ErrorAction Stop
                    
                    if (-not $loginResponse.token) {
                        throw "No token received from FleetDM login endpoint"
                    }
                    
                    $headers['Authorization'] = "Bearer $($loginResponse.token)"
                    
                    Write-Verbose "Successfully authenticated as $($loginResponse.user.email)"
                }
                catch {
                    throw "Failed to authenticate with FleetDM: $($_.Exception.Message)"
                }
            }
            
            # Version is display metadata. No other cmdlet reads it, so $null is safe.
            $fleetVersion = $null
            $versionAccepted = $false

            if ($SkipVersionCheck) {
                Write-Verbose "Skipping GET /api/v1/fleet/version. The token will be checked with GET /api/v1/fleet/me."
            }
            else {
                # Test connection by getting version
                $versionUri = "$BaseUri/api/v1/fleet/version"
                
                Write-Verbose "Testing connection to: $versionUri"
                Write-Verbose "Headers: $(Get-FleetRedactedLogText -Text $headers)"
                
                try {
                    $webResponse = Invoke-WebRequest -Uri $versionUri `
                        -Headers $headers `
                        -WebSession $script:FleetDMWebSession `
                        -ErrorAction Stop
                    
                    # Parse response based on content type
                    if ($webResponse.Headers['Content-Type'] -like 'application/json*') {
                        $versionResponse = $webResponse.Content | ConvertFrom-Json
                    }
                    else {
                        # Try to parse as JSON anyway
                        try {
                            $versionResponse = $webResponse.Content | ConvertFrom-Json
                        }
                        catch {
                            throw "Unexpected response format from version endpoint"
                        }
                    }

                    $fleetVersion = $versionResponse.version
                    $versionAccepted = $true
                    
                    Write-Verbose "Successfully connected to FleetDM version $fleetVersion"
                }
                catch {
                    Write-Verbose "Error details: $($_.Exception.Message)"
                    Write-Verbose "Error type: $($_.Exception.GetType().FullName)"

                    $statusCode = Get-FleetConnectStatusCode -ErrorRecord $_
                    if ($statusCode -eq 401) {
                        throw "Authentication failed. Please check your credentials or API token."
                    }
                    if ($statusCode -eq 403) {
                        Write-Verbose "GET /api/v1/fleet/version returned 403. The token will be checked with GET /api/v1/fleet/me. Version will be stored as null."
                        $fleetVersion = $null
                    }
                    else {
                        throw "Failed to connect to FleetDM: $($_.Exception.Message)"
                    }
                }
            }
            
            # Get current user information. This is the connection check when version
            # was skipped or returned 403.
            $meUri = "$BaseUri/api/v1/fleet/me"
            
            try {
                $userInfo = Invoke-RestMethod -Uri $meUri `
                    -Headers $headers `
                    -WebSession $script:FleetDMWebSession `
                    -ErrorAction Stop
                
                Write-Verbose "Authenticated as: $($userInfo.user.name) ($($userInfo.user.email))"
                Write-Verbose "Global role: $($userInfo.user.global_role)"
            }
            catch {
                if ($versionAccepted) {
                    Write-Warning "Could not retrieve user information"
                    $userInfo = $null
                }
                else {
                    $statusCode = Get-FleetConnectStatusCode -ErrorRecord $_
                    if ($statusCode -eq 401) {
                        throw "Authentication failed. Please check your credentials or API token."
                    }

                    throw "Failed to connect to FleetDM: $($_.Exception.Message)"
                }
            }
            
            # Store connection information
            $script:FleetDMConnection = @{
                BaseUri = $BaseUri
                Headers = $headers
                Version = $fleetVersion
                User = $userInfo.user
                ConnectedAt = Get-Date
            }
            
            # Create output object
            $connectionInfo = [PSCustomObject]@{
                PSTypeName = 'FleetDM.Connection'
                BaseUri = $BaseUri
                Version = $fleetVersion
                User = if ($userInfo) { $userInfo.user.email } else { 'Unknown' }
                GlobalRole = if ($userInfo) { $userInfo.user.global_role } else { 'Unknown' }
                ConnectedAt = $script:FleetDMConnection.ConnectedAt
            }
            
            Write-Host "Successfully connected to FleetDM at $BaseUri" -ForegroundColor Green
            if (-not [string]::IsNullOrWhiteSpace([string]$fleetVersion)) {
                Write-Host "Version: $fleetVersion" -ForegroundColor Cyan
            }
            if ($userInfo) {
                Write-Host "Authenticated as: $($userInfo.user.email) [$($userInfo.user.global_role)]" -ForegroundColor Cyan
            }
            
            return $connectionInfo
        }
        catch {
            # Clear any partial connection data
            $script:FleetDMConnection = $null
            $script:FleetDMWebSession = $null
            
            throw $_
        }
    }
}