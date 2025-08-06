function Connect-FleetDM {
    <#
    .SYNOPSIS
        Establishes a connection to the FleetDM API
    
    .DESCRIPTION
        Connects to a FleetDM instance using either an API token or email/password credentials.
        The connection is stored at the module level and used by all other FleetDM cmdlets.
    
    .PARAMETER BaseUri
        The base URI of your FleetDM instance (e.g., https://fleet.example.com)
    
    .PARAMETER ApiToken
        A secure string containing the FleetDM API token.
        This is the preferred method for automation and API-only users.
    
    .PARAMETER Credential
        PSCredential object containing email and password for FleetDM authentication.
        Use this for interactive sessions or when token authentication is not available.
    
    .EXAMPLE
        $token = ConvertTo-SecureString "your-api-token" -AsPlainText -Force
        Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken $token
        
        Connects to FleetDM using an API token
    
    .EXAMPLE
        $cred = Get-Credential
        Connect-FleetDM -BaseUri "https://fleet.example.com" -Credential $cred
        
        Prompts for credentials and connects to FleetDM
    
    .EXAMPLE
        Connect-FleetDM -BaseUri "https://fleet.example.com" -ApiToken (Read-Host -AsSecureString "Enter API Token")
        
        Prompts for API token securely and connects to FleetDM
    
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
        [pscredential]$Credential
    )
    
    begin {
        # Remove trailing slash from BaseUri if present
        $BaseUri = $BaseUri.TrimEnd('/')
        
        # Initialize web session for connection pooling
        $script:FleetDMWebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    }
    
    process {
        try {
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
            
            # Test connection by getting version
            $versionUri = "$BaseUri/api/v1/fleet/version"
            
            Write-Verbose "Testing connection to: $versionUri"
            Write-Verbose "Headers: $($headers | ConvertTo-Json -Compress)"
            
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
                
                Write-Verbose "Successfully connected to FleetDM version $($versionResponse.version)"
            }
            catch {
                Write-Verbose "Error details: $($_.Exception.Message)"
                Write-Verbose "Error type: $($_.Exception.GetType().FullName)"
                
                if ($_.Exception.Response -and $_.Exception.Response.StatusCode -eq 'Unauthorized') {
                    throw "Authentication failed. Please check your credentials or API token."
                }
                else {
                    throw "Failed to connect to FleetDM: $($_.Exception.Message)"
                }
            }
            
            # Get current user information
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
                Write-Warning "Could not retrieve user information"
                $userInfo = $null
            }
            
            # Store connection information
            $script:FleetDMConnection = @{
                BaseUri = $BaseUri
                Headers = $headers
                Version = $versionResponse.version
                User = $userInfo.user
                ConnectedAt = Get-Date
            }
            
            # Create output object
            $connectionInfo = [PSCustomObject]@{
                PSTypeName = 'FleetDM.Connection'
                BaseUri = $BaseUri
                Version = $versionResponse.version
                User = if ($userInfo) { $userInfo.user.email } else { 'Unknown' }
                GlobalRole = if ($userInfo) { $userInfo.user.global_role } else { 'Unknown' }
                ConnectedAt = $script:FleetDMConnection.ConnectedAt
            }
            
            Write-Host "Successfully connected to FleetDM at $BaseUri" -ForegroundColor Green
            Write-Host "Version: $($versionResponse.version)" -ForegroundColor Cyan
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