function Remove-FleetHost {
    <#
    .SYNOPSIS
        Removes hosts from FleetDM
    
    .DESCRIPTION
        Removes one or more hosts from FleetDM. Supports pipeline input for bulk operations.
        Use with caution as this operation cannot be undone.
    
    .PARAMETER Id
        The ID(s) of the host(s) to remove. Accepts pipeline input.
    
    .PARAMETER Force
        Skip confirmation prompts
    
    .EXAMPLE
        Remove-FleetHost -Id 123
        
        Removes host with ID 123 after confirmation
    
    .EXAMPLE
        Remove-FleetHost -Id 123 -Force
        
        Removes host with ID 123 without confirmation
    
    .EXAMPLE
        Get-FleetHost -Status offline | Remove-FleetHost -Force
        
        Removes all offline hosts without confirmation
    
    .EXAMPLE
        @(123, 456, 789) | Remove-FleetHost -WhatIf
        
        Shows what would happen if you removed hosts 123, 456, and 789
    
    .EXAMPLE
        Get-FleetHost -Hostname "old-*" | Remove-FleetHost
        
        Removes all hosts with hostnames starting with "old-" after confirmation for each
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api#delete-host
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('HostId')]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$Id,
        
        [switch]$Force
    )
    
    begin {
        $hostIds = @()
        $removedHosts = @()
        $failedHosts = @()
    }
    
    process {
        # Collect all host IDs from pipeline
        foreach ($hostId in $Id) {
            $hostIds += $hostId
        }
    }
    
    end {
        if ($hostIds.Count -eq 0) {
            Write-Warning "No host IDs provided"
            return
        }
        
        Write-Verbose "Preparing to remove $($hostIds.Count) host(s)"
        
        # Process each host
        foreach ($hostId in $hostIds) {
            try {
                # Get host details for confirmation message
                $hostDetails = $null
                try {
                    $hostResponse = Invoke-FleetDMRequest -Endpoint "hosts/$hostId" -Method GET
                    $hostDetails = $hostResponse.host
                }
                catch {
                    Write-Verbose "Could not retrieve details for host ID $hostId"
                }
                
                # Build confirmation message
                $targetDescription = if ($hostDetails) {
                    "Host '$($hostDetails.hostname)' (ID: $hostId)"
                } else {
                    "Host ID: $hostId"
                }
                
                # Confirm action
                if ($Force -or $PSCmdlet.ShouldProcess($targetDescription, "Remove from FleetDM")) {
                    Write-Verbose "Removing host ID: $hostId"
                    
                    # Call the API to remove the host
                    $null = Invoke-FleetDMRequest -Endpoint "hosts/$hostId" -Method DELETE
                    
                    # Create result object
                    $result = [PSCustomObject]@{
                        PSTypeName = 'FleetDM.RemovedHost'
                        HostId = $hostId
                        Hostname = if ($hostDetails) { $hostDetails.hostname } else { "Unknown" }
                        Status = "Removed"
                        RemovedAt = Get-Date
                    }
                    
                    $removedHosts += $result
                    
                    Write-Host "Successfully removed host ID: $hostId" -ForegroundColor Green
                    if ($hostDetails) {
                        Write-Verbose "Removed host: $($hostDetails.hostname) ($($hostDetails.platform))"
                    }
                }
                else {
                    Write-Verbose "Skipped removal of host ID: $hostId (user cancelled)"
                }
            }
            catch {
                $failedHost = [PSCustomObject]@{
                    PSTypeName = 'FleetDM.FailedHostRemoval'
                    HostId = $hostId
                    Error = $_.Exception.Message
                }
                
                $failedHosts += $failedHost
                
                Write-Error "Failed to remove host ID $hostId`: $_"
            }
        }
        
        # Return summary
        $summary = [PSCustomObject]@{
            PSTypeName = 'FleetDM.HostRemovalSummary'
            TotalRequested = $hostIds.Count
            SuccessfullyRemoved = $removedHosts.Count
            Failed = $failedHosts.Count
            RemovedHosts = $removedHosts
            FailedHosts = $failedHosts
        }
        
        # Display summary
        if ($removedHosts.Count -gt 0) {
            Write-Host "`nRemoval Summary:" -ForegroundColor Yellow
            Write-Host "  Successfully removed: $($removedHosts.Count)" -ForegroundColor Green
            if ($failedHosts.Count -gt 0) {
                Write-Host "  Failed: $($failedHosts.Count)" -ForegroundColor Red
            }
        }
        
        return $summary
    }
}