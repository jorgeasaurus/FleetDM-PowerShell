function Invoke-FleetQuery {
    <#
    .SYNOPSIS
        Executes a live query on FleetDM hosts
    
    .DESCRIPTION
        Runs an osquery SQL statement on specified hosts and returns the results.
        For ad-hoc queries, automatically creates a temporary saved query, runs it,
        retrieves the results, and cleans up. This provides actual query results
        instead of just campaign information.
    
    .PARAMETER Query
        The SQL query to execute. This should be a valid osquery SQL statement.
    
    .PARAMETER QueryId
        The ID of a saved query to execute (alternative to providing Query text)
    
    .PARAMETER HostId
        Array of host IDs to run the query on. Accepts pipeline input.
    
    .PARAMETER Label
        Array of label names to run the query on all hosts with those labels
    
    .PARAMETER Wait
        For saved queries (QueryId), returns results directly instead of starting a campaign.
        This parameter is deprecated for ad-hoc queries as they now always return results.
    
    .PARAMETER MaxWaitTime
        Maximum time to wait for results in seconds (default: 25)
    
    .EXAMPLE
        $results = Invoke-FleetQuery -Query "SELECT * FROM system_info;" -HostId 1,2,3
        $results.Results | Format-Table
        
        Runs a system info query on specific hosts and returns the actual results
    
    .EXAMPLE
        $hosts = Get-FleetHost -Status online
        $results = $hosts | Invoke-FleetQuery -Query "SELECT * FROM users WHERE uid = '501';"
        
        Gets all online hosts and runs a query to find user with UID 501, returning results
    
    .EXAMPLE
        Invoke-FleetQuery -Query "SELECT * FROM processes WHERE name = 'chrome';" -Label "production"
        
        Runs a query on all hosts with the "production" label (returns campaign info only)
    
    .EXAMPLE
        Invoke-FleetQuery -QueryId 42 -HostId 100,101,102 -Wait
        
        Executes saved query #42 on specific hosts and waits for results
    
    .EXAMPLE
        @(1,2,3,4,5) | Invoke-FleetQuery -Query "SELECT * FROM os_version;"
        
        Pipes host IDs to run OS version query
    
    .LINK
        https://fleetdm.com/docs/using-fleet/rest-api#run-live-query
    #>
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param(
        [Parameter(ParameterSetName = 'Query', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'QueryId', Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$QueryId,
        
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [int[]]$HostId,
        
        [string[]]$Label,
        
        [switch]$Wait,
        
        [ValidateRange(1, 300)]
        [int]$MaxWaitTime = 25
    )
    
    begin {
        $hostIds = @()
        $hasTargets = $false
    }
    
    process {
        # Collect host IDs from pipeline
        if ($HostId) {
            $hostIds += $HostId
            $hasTargets = $true
        }
    }
    
    end {
        # Validate that we have at least one target
        if (-not $hasTargets -and -not $Label) {
            throw "You must specify at least one target: -HostId or -Label"
        }
        
        # For ad-hoc queries with specific host IDs, use the temporary query approach
        if ($PSCmdlet.ParameterSetName -eq 'Query' -and $hostIds.Count -gt 0 -and -not $Label) {
            Write-Verbose "Creating temporary query for direct results"
            
            $tempQueryName = "TempQuery_$(Get-Date -Format 'yyyyMMdd_HHmmss')_$(Get-Random -Maximum 9999)"
            $tempQuery = $null
            
            try {
                # Create temporary query
                Write-Verbose "Creating temporary query: $tempQueryName"
                $createBody = @{
                    name = $tempQueryName
                    query = $Query
                    description = "Temporary query created by Invoke-FleetQuery"
                    observer_can_run = $false
                }
                
                $tempQuery = Invoke-FleetDMRequest -Endpoint 'queries' -Method POST -Body $createBody
                
                if (-not $tempQuery.query -or -not $tempQuery.query.id) {
                    throw "Failed to create temporary query"
                }
                
                Write-Verbose "Temporary query created with ID: $($tempQuery.query.id)"
                
                # Run the query and get results
                $results = Invoke-FleetSavedQuery -QueryId $tempQuery.query.id -HostId $hostIds
                
                return $results
            }
            catch {
                Write-Error "Failed to execute query: $_"
                throw
            }
            finally {
                # Clean up temporary query
                if ($tempQuery -and $tempQuery.query.id) {
                    try {
                        Write-Verbose "Cleaning up temporary query ID: $($tempQuery.query.id)"
                        $null = Invoke-FleetDMRequest -Endpoint "queries/$($tempQuery.query.id)" -Method DELETE
                        Write-Verbose "Temporary query cleaned up successfully"
                    }
                    catch {
                        # Only warn if it's not a "not found" error (query might have been auto-deleted)
                        if ($_.Exception.Message -notlike "*not found*" -and $_.Exception.Message -notlike "*does not exist*") {
                            Write-Warning "Failed to clean up temporary query: $_"
                        }
                        else {
                            Write-Verbose "Temporary query already deleted (auto-cleanup)"
                        }
                    }
                }
            }
        }
        
        # For saved queries with host IDs and Wait, use the direct result endpoint
        if ($PSCmdlet.ParameterSetName -eq 'QueryId' -and $Wait -and $hostIds.Count -gt 0 -and -not $Label) {
            Write-Verbose "Using direct result endpoint for saved query $QueryId"
            
            # Redirect to Invoke-FleetSavedQuery for direct results
            return Invoke-FleetSavedQuery -QueryId $QueryId -HostId $hostIds
        }
        
        # For labels, we need to use the campaign approach
        # as the direct results endpoint only works with specific host IDs
        if ($Label) {
            Write-Warning "Direct results are not available when using -Label parameter. Campaign will be started instead."
        }
        
        # Build the request body
        $body = @{
            selected = @{
                hosts = $hostIds
                labels = if ($Label) { $Label } else { @() }
            }
        }
        
        # Add query or query_id
        if ($PSCmdlet.ParameterSetName -eq 'Query') {
            $body['query'] = $Query
            Write-Verbose "Executing ad-hoc query via campaign: $Query"
        }
        else {
            $body['query_id'] = $QueryId
            Write-Verbose "Executing saved query ID via campaign: $QueryId"
        }
        
        if ($body.selected) {
            Write-Verbose "Query targets: $($body.selected | ConvertTo-Json -Compress)"
        }
        
        try {
            # Execute the query
            $result = Invoke-FleetDMRequest -Endpoint 'queries/run' -Method POST -Body $body
            
            # Add custom type for formatting
            $result.PSObject.TypeNames.Insert(0, 'FleetDM.QueryExecution')
            
            # Get campaign ID from response
            $campaignId = $result.campaign.id
            
            if (-not $campaignId) {
                Write-Warning "No campaign ID returned. Query may not have been executed."
                return $result
            }
            
            Write-Verbose "Query campaign started with ID: $campaignId"
            
            if ($Wait) {
                Write-Host "Waiting for query results..." -NoNewline
                
                $startTime = Get-Date
                $dots = 0
                
                while ((Get-Date) -lt $startTime.AddSeconds($MaxWaitTime)) {
                    Start-Sleep -Seconds 2
                    
                    # Show progress dots
                    if ($dots -lt 10) {
                        Write-Host "." -NoNewline
                        $dots++
                    }
                    else {
                        Write-Host "`b`b`b`b`b`b`b`b`b`b          `b`b`b`b`b`b`b`b`b`b" -NoNewline
                        $dots = 0
                    }
                    
                    # Check campaign status
                    try {
                        $campaign = Invoke-FleetDMRequest -Endpoint "queries/results/$campaignId" -Method GET
                        
                        if ($campaign.campaign.status -eq 'finished') {
                            Write-Host " Done!" -ForegroundColor Green
                            
                            # Create result object with campaign results
                            $finalResult = [PSCustomObject]@{
                                PSTypeName = 'FleetDM.QueryResult'
                                Campaign = $campaign.campaign
                                Results = $campaign.results
                                Errors = $campaign.errors
                                Stats = @{
                                    TotalHosts = $campaign.campaign.totals.count
                                    OnlineHosts = $campaign.campaign.totals.online
                                    OfflineHosts = $campaign.campaign.totals.offline
                                    MissingInActionHosts = $campaign.campaign.totals.missing_in_action
                                    ResultsReceived = $campaign.results.Count
                                }
                            }
                            
                            return $finalResult
                        }
                    }
                    catch {
                        # Ignore errors while polling
                        Write-Verbose "Error checking campaign status: $_"
                    }
                }
                
                Write-Host " Timeout!" -ForegroundColor Yellow
                Write-Warning "Query execution timed out after $MaxWaitTime seconds. Campaign ID: $campaignId"
                
                # Try to get partial results
                try {
                    $campaign = Invoke-FleetDMRequest -Endpoint "queries/results/$campaignId" -Method GET
                    
                    $partialResult = [PSCustomObject]@{
                        PSTypeName = 'FleetDM.QueryResult'
                        Campaign = $campaign.campaign
                        Results = $campaign.results
                        Errors = $campaign.errors
                        Stats = @{
                            TotalHosts = $campaign.campaign.totals.count
                            OnlineHosts = $campaign.campaign.totals.online
                            OfflineHosts = $campaign.campaign.totals.offline
                            MissingInActionHosts = $campaign.campaign.totals.missing_in_action
                            ResultsReceived = $campaign.results.Count
                        }
                        Partial = $true
                    }
                    
                    Write-Warning "Returning partial results. Query may still be running."
                    return $partialResult
                }
                catch {
                    Write-Error "Failed to retrieve partial results: $_"
                }
            }
            else {
                # Return campaign info without waiting
                Write-Host "Query campaign started. Campaign ID: $campaignId" -ForegroundColor Green
                Write-Host "Query executed successfully. Check FleetDM UI for results." -ForegroundColor Cyan
                
                return $result
            }
        }
        catch {
            throw $_
        }
    }
}