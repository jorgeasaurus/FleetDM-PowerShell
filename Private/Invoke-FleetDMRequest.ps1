function Invoke-FleetDMRequest {
    <#
    .SYNOPSIS
        Internal function to make API requests to FleetDM
    
    .DESCRIPTION
        This is the core function that handles all API communication with FleetDM.
        It manages authentication, error handling, pagination, and response processing.
    
    .PARAMETER Endpoint
        The API endpoint path (without the base URI or /api/v1/fleet/ prefix)
    
    .PARAMETER Method
        The HTTP method to use (GET, POST, PUT, PATCH, DELETE)
    
    .PARAMETER Body
        Hashtable containing the request body data (will be converted to JSON)
    
    .PARAMETER QueryParameters
        Hashtable of query parameters to append to the URI
    
    .PARAMETER FollowPagination
        If specified, automatically follows pagination to retrieve all results
    
    .PARAMETER Raw
        If specified, returns the raw response without processing
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Endpoint,
        
        [ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')]
        [string]$Method = 'GET',
        
        [hashtable]$Body,
        
        [hashtable]$QueryParameters,
        
        [switch]$FollowPagination,
        
        [switch]$Raw
    )
    
    begin {
        # Check if connected
        if (-not $script:FleetDMConnection) {
            throw "Not connected to FleetDM. Please run Connect-FleetDM first."
        }
        
        # Remove leading slash from endpoint if present
        $Endpoint = $Endpoint.TrimStart('/')
        
        # Build the full URI
        $uri = "$($script:FleetDMConnection.BaseUri)/api/v1/fleet/$Endpoint"
        
        Write-Verbose "Preparing $Method request to: $uri"
    }
    
    process {
        Write-Verbose "Using headers: $($script:FleetDMConnection.Headers | ConvertTo-Json -Compress)"
        # Add query parameters if provided
        if ($QueryParameters -and $QueryParameters.Count -gt 0) {
            $queryString = @()
            
            foreach ($param in $QueryParameters.GetEnumerator()) {
                $encodedKey = [System.Web.HttpUtility]::UrlEncode($param.Key)
                $encodedValue = [System.Web.HttpUtility]::UrlEncode($param.Value.ToString())
                $queryString += "$encodedKey=$encodedValue"
            }
            
            $separator = if ($uri.Contains('?')) { '&' } else { '?' }
            $uri = "$uri$separator$($queryString -join '&')"
            
            Write-Verbose "Full URI with parameters: $uri"
        }
        Write-Verbose "HTTP Method: $Method"
        # Prepare the request parameters
        $requestParams = @{
            Uri = $uri
            Method = $Method
            Headers = $script:FleetDMConnection.Headers
            ContentType = 'application/json'
            WebSession = $script:FleetDMWebSession
            ErrorAction = 'Stop'
        }
        Write-Verbose "Request parameters: $($requestParams | ConvertTo-Json -Compress)"
        # Add body if provided
        if ($Body -and $Body.Count -gt 0) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10 -Compress
            $requestParams['Body'] = $jsonBody
            Write-Verbose "Request body: $jsonBody"
        }
        Write-Verbose "Sending request to FleetDM API"
        try {
            if ($FollowPagination -and $Method -eq 'GET') {
                Write-Verbose "Pagination enabled. Fetching all results."
                # Handle pagination
                $allResults = @()
                $page = 0
                $hasMore = $true
                
                while ($hasMore) {
                    # Add page parameter
                    $currentUri = if ($uri -match '\?') { "$uri&page=$page" } else { "$uri?page=$page" }
                    $requestParams['Uri'] = $currentUri
                    
                    Write-Verbose "Fetching page $page"
                    
                    $response = Invoke-RestMethod @requestParams
                    
                    # Add results to collection
                    if ($response -is [System.Management.Automation.PSCustomObject]) {
                        # Response is an object with data and metadata
                        if ($response.PSObject.Properties.Name -contains 'hosts') {
                            $allResults += $response.hosts
                        }
                        elseif ($response.PSObject.Properties.Name -contains 'policies') {
                            $allResults += $response.policies
                        }
                        elseif ($response.PSObject.Properties.Name -contains 'queries') {
                            $allResults += $response.queries
                        }
                        elseif ($response.PSObject.Properties.Name -contains 'software') {
                            $allResults += $response.software
                        }
                        elseif ($response.PSObject.Properties.Name -contains 'users') {
                            $allResults += $response.users
                        }
                        elseif ($response.PSObject.Properties.Name -contains 'teams') {
                            $allResults += $response.teams
                        }
                        else {
                            # If no recognized collection property, add the whole response
                            $allResults += $response
                        }
                        
                        # Check for more pages
                        if ($response.meta -and $response.meta.has_next_results) {
                            $page++
                        }
                        else {
                            $hasMore = $false
                        }
                    }
                    else {
                        # Response is likely an array or simple object
                        $allResults += $response
                        $hasMore = $false
                    }
                }
                
                Write-Verbose "Retrieved $($allResults.Count) total items across $($page + 1) pages"
                
                if ($Raw) {
                    return $allResults
                }
                else {
                    return $allResults
                }
            }
            else {
                Write-Verbose "No pagination requested. Sending single request."
                # Single request without pagination
                $response = Invoke-RestMethod @requestParams
                
                Write-Verbose "Request completed successfully"
                
                if ($Raw) {
                    return $response
                }
                else {
                    return $response
                }
            }
        }
        catch {
            # Handle errors
            Handle-FleetDMError -ErrorRecord $_
        }
    }
}

function Handle-FleetDMError {
    <#
    .SYNOPSIS
        Internal function to handle FleetDM API errors
    
    .DESCRIPTION
        Processes error responses from the FleetDM API and throws appropriate exceptions
    
    .PARAMETER ErrorRecord
        The error record from the failed API call
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )
    
    $exception = $ErrorRecord.Exception
    $response = $exception.Response
    
    if ($response) {
        $statusCode = [int]$response.StatusCode
        $statusDescription = $response.StatusDescription
        
        # Try to parse the error response body
        $errorMessage = $statusDescription
        $errorDetails = $null
        
        try {
            $stream = $response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $reader.BaseStream.Position = 0
            $responseBody = $reader.ReadToEnd()
            $reader.Close()
            
            if ($responseBody) {
                $errorContent = $responseBody | ConvertFrom-Json
                
                if ($errorContent.message) {
                    $errorMessage = $errorContent.message
                }
                
                if ($errorContent.errors) {
                    $errorDetails = $errorContent.errors
                }
                
                if ($errorContent.uuid) {
                    Write-Verbose "Error UUID: $($errorContent.uuid)"
                }
            }
        }
        catch {
            Write-Verbose "Could not parse error response body"
        }
        
        # Create error message based on status code
        switch ($statusCode) {
            400 {
                # Check for specific error reasons in the details
                $isPremiumError = $false
                if ($errorDetails) {
                    foreach ($detail in $errorDetails) {
                        if ($detail.reason -like "*premium license*") {
                            $isPremiumError = $true
                            break
                        }
                    }
                }
                
                if ($isPremiumError) {
                    throw "This feature requires a Fleet Premium license"
                }
                else {
                    $fullMessage = "Bad Request: $errorMessage"
                    if ($errorDetails) {
                        $fullMessage += "`nDetails: $($errorDetails | ConvertTo-Json -Compress)"
                    }
                    throw $fullMessage
                }
            }
            401 {
                throw "Authentication failed. Your session may have expired. Please run Connect-FleetDM again."
            }
            403 {
                throw "Access denied. You don't have permission to perform this operation. Error: $errorMessage"
            }
            404 {
                throw "Resource not found. The requested item does not exist. Error: $errorMessage"
            }
            408 {
                throw "Request timeout. The operation took too long to complete. Error: $errorMessage"
            }
            429 {
                # Rate limiting
                $retryAfter = $null
                
                if ($errorMessage -match 'retry after:\s*(\d+)s') {
                    $retryAfter = $matches[1]
                }
                
                if ($retryAfter) {
                    Write-Warning "Rate limit exceeded. Please wait $retryAfter seconds before retrying."
                    throw "Rate limit exceeded. Retry after $retryAfter seconds."
                }
                else {
                    throw "Rate limit exceeded. Please wait before retrying."
                }
            }
            500 {
                throw "Internal server error. FleetDM encountered an error. Error: $errorMessage"
            }
            502 {
                throw "Bad gateway. FleetDM service may be temporarily unavailable."
            }
            503 {
                throw "Service unavailable. FleetDM service is temporarily unavailable."
            }
            default {
                throw "FleetDM API error (HTTP $statusCode): $errorMessage"
            }
        }
    }
    else {
        # Non-HTTP error (network, timeout, etc.)
        throw "Failed to communicate with FleetDM: $($exception.Message)"
    }
}