function Disconnect-FleetDM {
    <#
    .SYNOPSIS
        Disconnects from the FleetDM API
    
    .DESCRIPTION
        Closes the current FleetDM connection and clears stored authentication information.
        After disconnecting, you must run Connect-FleetDM before using other FleetDM cmdlets.
    
    .EXAMPLE
        Disconnect-FleetDM
        
        Disconnects from the current FleetDM instance
    
    .EXAMPLE
        Disconnect-FleetDM -Verbose
        
        Disconnects and shows verbose information about the disconnection process
    
    .LINK
        Connect-FleetDM
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    process {
        if (-not $script:FleetDMConnection) {
            Write-Warning "Not currently connected to FleetDM"
            return
        }
        
        if ($PSCmdlet.ShouldProcess("FleetDM connection to $($script:FleetDMConnection.BaseUri)", "Disconnect")) {
            try {
                # Store connection info for verbose output
                $baseUri = $script:FleetDMConnection.BaseUri
                $user = $script:FleetDMConnection.User
                
                Write-Verbose "Disconnecting from FleetDM at $baseUri"
                
                # Clear connection information
                $script:FleetDMConnection = $null
                $script:FleetDMWebSession = $null
                
                Write-Host "Successfully disconnected from FleetDM" -ForegroundColor Green
                
                if ($user) {
                    Write-Verbose "Cleared authentication for user: $($user.email)"
                }
                
                # Return disconnection info
                [PSCustomObject]@{
                    PSTypeName = 'FleetDM.Disconnection'
                    BaseUri = $baseUri
                    DisconnectedAt = Get-Date
                    Message = "Successfully disconnected from FleetDM"
                }
            }
            catch {
                Write-Error "Failed to disconnect from FleetDM: $_"
                throw
            }
        }
    }
}