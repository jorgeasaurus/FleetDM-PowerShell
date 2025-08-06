function Invoke-FleetSavedQuery {
    <#
    .SYNOPSIS
        Executes a saved query and returns results immediately
    
    .DESCRIPTION
        Runs a saved FleetDM query against specified hosts and returns the results directly.
        Unlike Invoke-FleetQuery which starts a campaign, this function waits for and returns results.
        
        The query will stop if targeted hosts haven't responded within the configured timeout period.
    
    .PARAMETER QueryId
        The ID of the saved query to execute
    
    .PARAMETER HostId
        Array of host IDs to run the query on. Accepts pipeline input.
    
    .EXAMPLE
        Invoke-FleetSavedQuery -QueryId 42 -HostId 1,2,3
        
        Runs saved query 42 on hosts 1, 2, and 3
    
    .EXAMPLE
        Get-FleetHost -Status online | Select-Object -ExpandProperty id | Invoke-FleetSavedQuery -QueryId 15
        
        Runs saved query 15 on all online hosts
    
    .EXAMPLE
        $results = Invoke-FleetSavedQuery -QueryId 10 -HostId 5
        $results.results | ForEach-Object { 
            Write-Host "Host $($_.host_id):"
            $_.rows | Format-Table
        }
        
        Runs query and formats results
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api#run-live-query
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$QueryId,
        
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [int[]]$HostId
    )
    
    begin {
        $hostIds = @()
    }
    
    process {
        # Collect host IDs from pipeline
        if ($HostId) {
            $hostIds += $HostId
        }
    }
    
    end {
        if ($hostIds.Count -eq 0) {
            throw "No host IDs provided"
        }
        
        Write-Verbose "Running saved query $QueryId on $($hostIds.Count) host(s)"
        
        $body = @{
            host_ids = $hostIds
        }
        
        try {
            # Note: Timeout is handled by the server-side FLEET_LIVE_QUERY_REST_PERIOD setting
            Write-Verbose "Note: Query timeout is controlled by server configuration (FLEET_LIVE_QUERY_REST_PERIOD)"
            
            $result = Invoke-FleetDMRequest -Endpoint "queries/$QueryId/run" -Method POST -Body $body
            
            # Process and format results
            $formattedResult = [PSCustomObject]@{
                PSTypeName = 'FleetDM.QueryResult'
                QueryId = $result.query_id
                TargetedHostCount = $result.targeted_host_count
                RespondedHostCount = $result.responded_host_count
                ResponseRate = if ($result.targeted_host_count -gt 0) {
                    [Math]::Round(($result.responded_host_count / $result.targeted_host_count) * 100, 2)
                } else { 0 }
                Results = @()
                Errors = @()
            }
            
            # Separate successful results and errors
            foreach ($hostResult in $result.results) {
                if ($hostResult.error) {
                    $formattedResult.Errors += [PSCustomObject]@{
                        PSTypeName = 'FleetDM.QueryError'
                        HostId = $hostResult.host_id
                        Error = $hostResult.error
                    }
                } else {
                    $formattedResult.Results += [PSCustomObject]@{
                        PSTypeName = 'FleetDM.QueryHostResult'
                        HostId = $hostResult.host_id
                        Rows = $hostResult.rows
                        RowCount = $hostResult.rows.Count
                    }
                }
            }
            
            # Display summary
            Write-Host "Query completed: $($formattedResult.RespondedHostCount)/$($formattedResult.TargetedHostCount) hosts responded ($($formattedResult.ResponseRate)%)" -ForegroundColor Green
            if ($formattedResult.Errors.Count -gt 0) {
                Write-Warning "$($formattedResult.Errors.Count) host(s) returned errors"
            }
            
            return $formattedResult
        }
        catch {
            throw $_
        }
    }
}