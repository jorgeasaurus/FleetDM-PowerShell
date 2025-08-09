function New-FleetPolicy {
    <#
    .SYNOPSIS
        Creates a new policy in FleetDM
    
    .DESCRIPTION
        Creates a new policy in FleetDM. Policies are compliance rules that are regularly checked on hosts.
    
    .PARAMETER Name
        The name of the policy
    
    .PARAMETER Query
        The SQL query that defines the policy check. Should return 1 row for compliant hosts.
    
    .PARAMETER Description
        A description of what the policy checks
    
    .PARAMETER Resolution
        Steps to resolve the issue when the policy fails
    
    .PARAMETER Platform
        The platform this policy applies to (windows, linux, darwin, chrome, or all)
    
    .EXAMPLE
        New-FleetPolicy -Name "Firewall Enabled" -Query "SELECT 1 FROM windows_firewall WHERE enabled = 1;"
        
        Creates a basic policy to check if Windows Firewall is enabled
    
    .EXAMPLE
        $params = @{
            Name = "FileVault Enabled"
            Query = "SELECT 1 FROM filevault_status WHERE status = 'on';"
            Description = "Ensures FileVault disk encryption is enabled"
            Resolution = "Enable FileVault in System Preferences > Security & Privacy"
            Platform = "darwin"
        }
        New-FleetPolicy @params
        
        Creates a comprehensive macOS policy with all details
    
    .EXAMPLE
        Import-Csv policies.csv | ForEach-Object {
            New-FleetPolicy -Name $_.Name -Query $_.Query -Description $_.Description
        }
        
        Bulk creates policies from a CSV file
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api#create-policy
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,
        
        [Parameter()]
        [string]$Description,
        
        [Parameter()]
        [string]$Resolution,
        
        [Parameter()]
        [ValidateSet('windows', 'linux', 'darwin', 'chrome', 'all')]
        [string]$Platform = 'all'
    )
    
    process {
        # Build the request body
        $body = @{
            name = $Name
            query = $Query
        }
        
        # Add optional parameters if provided
        if ($PSBoundParameters.ContainsKey('Description')) {
            $body['description'] = $Description
        }
        
        if ($PSBoundParameters.ContainsKey('Resolution')) {
            $body['resolution'] = $Resolution
        }
        
        # Handle platform parameter - API expects empty string for 'all'
        if ($Platform -eq 'all') {
            $body['platform'] = ''
        }
        else {
            $body['platform'] = $Platform
        }
        
        $endpoint = "global/policies"
        $targetDescription = "global policy '$Name'"
        
        Write-Verbose "Creating new policy: $Name"
        Write-Verbose "Platform: $Platform"
        Write-Verbose "Query: $Query"
        
        if ($PSCmdlet.ShouldProcess($targetDescription, 'Create')) {
            try {
                $result = Invoke-FleetDMRequest -Endpoint $endpoint -Method POST -Body $body
                
                if ($result.policy) {
                    # Add custom type for formatting
                    $result.policy.PSObject.TypeNames.Insert(0, 'FleetDM.Policy')
                    
                    # Add calculated properties if host counts are available
                    $result.policy = Add-FleetPolicyCalculatedProperties -Policy $result.policy
                    
                    Write-Verbose "Successfully created policy '$Name' (ID: $($result.policy.id))"
                    
                    return $result.policy
                }
                else {
                    Write-Warning "Policy creation succeeded but no policy data was returned"
                }
            }
            catch {
                if ($_.Exception.Message -like "*already exists*") {
                    Write-Error "A policy with the name '$Name' already exists"
                }
                else {
                    throw $_
                }
            }
        }
    }
}