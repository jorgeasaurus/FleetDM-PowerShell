function Set-FleetPolicy {
    <#
    .SYNOPSIS
        Updates an existing policy in FleetDM
    
    .DESCRIPTION
        Updates an existing policy in FleetDM. You can update the name, query, description, resolution, and platform.
    
    .PARAMETER Id
        The ID of the policy to update
    
    .PARAMETER Name
        The new name for the policy
    
    .PARAMETER Query
        The new SQL query that defines the policy
    
    .PARAMETER Description
        The new description of what the policy checks
    
    .PARAMETER Resolution
        The new resolution steps for when the policy fails
    
    .PARAMETER Platform
        The new platform filter for the policy (windows, linux, darwin, chrome, all)
    
    .EXAMPLE
        Set-FleetPolicy -Id 123 -Name "Updated Policy Name"
        
        Updates just the name of policy ID 123
    
    .EXAMPLE
        Set-FleetPolicy -Id 456 -Query "SELECT 1 FROM users WHERE username != 'root';" -Description "Ensures root account is disabled"
        
        Updates the query and description for policy ID 456
    
    .EXAMPLE
        Get-FleetPolicy -Name "Old Name" | Set-FleetPolicy -Name "New Name"
        
        Gets a policy by name and updates it to have a new name
    
    .EXAMPLE
        $updateParams = @{
            Id = 789
            Name = "Comprehensive Update"
            Query = "SELECT 1 FROM system_info WHERE version >= '11.0';"
            Description = "Ensures minimum OS version"
            Resolution = "Update to macOS 11.0 or higher"
            Platform = "darwin"
        }
        Set-FleetPolicy @updateParams
        
        Updates multiple properties of a policy using splatting
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api#modify-policy
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Id,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Query,
        
        [Parameter()]
        [string]$Description,
        
        [Parameter()]
        [string]$Resolution,
        
        [Parameter()]
        [ValidateSet('windows', 'linux', 'darwin', 'chrome', 'all')]
        [string]$Platform
    )
    
    process {
        # First, get the existing policy to see current values
        Write-Verbose "Retrieving existing policy ID: $Id"
        
        try {
            $getEndpoint = "global/policies/$Id"
            $updateEndpoint = "global/policies/$Id"
            $targetDescription = "global policy $Id"
            
            # Get current policy
            $currentPolicyResponse = Invoke-FleetDMRequest -Endpoint $getEndpoint -Method GET
            $currentPolicy = $currentPolicyResponse.policy
            
            if (-not $currentPolicy) {
                Write-Error "Policy ID $Id not found"
                return
            }
            
            # Build the update body with only the fields that were specified
            $body = @{}
            
            # Check each parameter and add to body if specified
            if ($PSBoundParameters.ContainsKey('Name')) {
                $body['name'] = $Name
            }
            
            if ($PSBoundParameters.ContainsKey('Query')) {
                $body['query'] = $Query
            }
            
            if ($PSBoundParameters.ContainsKey('Description')) {
                $body['description'] = $Description
            }
            
            if ($PSBoundParameters.ContainsKey('Resolution')) {
                $body['resolution'] = $Resolution
            }
            
            if ($PSBoundParameters.ContainsKey('Platform')) {
                # Handle platform parameter - API expects empty string for 'all'
                if ($Platform -eq 'all') {
                    $body['platform'] = ''
                }
                else {
                    $body['platform'] = $Platform
                }
            }
            
            # Check if any updates were specified
            if ($body.Count -eq 0) {
                Write-Warning "No updates specified for policy ID $Id"
                return $currentPolicy
            }
            
            # Create a description of what's being changed for ShouldProcess
            $changes = @()
            foreach ($key in $body.Keys) {
                $oldValue = $currentPolicy.$key
                $newValue = $body[$key]
                
                if ($oldValue -ne $newValue) {
                    $changes += "${key}: '$oldValue' → '$newValue'"
                }
            }
            
            $changeDescription = if ($changes.Count -gt 0) {
                "Update $($changes -join ', ')"
            }
            else {
                "No changes detected"
            }
            
            Write-Verbose "Updating policy ID: $Id"
            Write-Verbose "Changes: $changeDescription"
            
            if ($PSCmdlet.ShouldProcess($targetDescription, $changeDescription)) {
                $result = Invoke-FleetDMRequest -Endpoint $updateEndpoint -Method PATCH -Body $body
                
                if ($result.policy) {
                    # Add custom type for formatting
                    $result.policy.PSObject.TypeNames.Insert(0, 'FleetDM.Policy')
                    
                    # Add calculated properties
                    $result.policy = Add-FleetPolicyCalculatedProperties -Policy $result.policy
                    
                    Write-Host "✅ Successfully updated policy '$($result.policy.name)' (ID: $Id)" -ForegroundColor Green
                    
                    return $result.policy
                }
                else {
                    Write-Warning "Policy update succeeded but no policy data was returned"
                }
            }
        }
        catch {
            if ($_.Exception.Message -like "*not found*") {
                Write-Error "Policy ID $Id not found"
            }
            else {
                throw $_
            }
        }
    }
}