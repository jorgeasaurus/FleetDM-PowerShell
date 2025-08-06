function Add-FleetPolicyCalculatedProperties {
    <#
    .SYNOPSIS
        Adds calculated properties to a FleetDM policy object
    
    .DESCRIPTION
        Internal helper function that adds compliance_percentage and total_host_count
        properties to policy objects based on passing and failing host counts.
    
    .PARAMETER Policy
        The policy object to enhance with calculated properties
    
    .EXAMPLE
        Add-FleetPolicyCalculatedProperties -Policy $policyObject
        
        Adds calculated properties to the policy object
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSObject]$Policy
    )
    
    process {
        if ($null -ne $Policy.passing_host_count -and $null -ne $Policy.failing_host_count) {
            $totalHosts = $Policy.passing_host_count + $Policy.failing_host_count
            Add-Member -InputObject $Policy -MemberType NoteProperty -Name 'total_host_count' -Value $totalHosts -Force
            
            if ($totalHosts -gt 0) {
                $complianceRate = [Math]::Round(($Policy.passing_host_count / $totalHosts) * 100, 2)
                Add-Member -InputObject $Policy -MemberType NoteProperty -Name 'compliance_percentage' -Value $complianceRate -Force
            }
            else {
                Add-Member -InputObject $Policy -MemberType NoteProperty -Name 'compliance_percentage' -Value 0 -Force
            }
        }
        
        return $Policy
    }
}