function ConvertTo-FleetLogJson {
    <#
    .SYNOPSIS
        Serializes a verbose-log value without a depth cutoff.

    .DESCRIPTION
        ConvertTo-Json stops at a fixed depth and turns the next PSCustomObject
        into text such as @{password=secret}. Property redaction does not match
        that text. Dictionaries, lists, and note properties are walked for the
        log only. The HTTP body is serialized separately.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$InputObject,

        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Seen
    )

    if ($null -eq $InputObject) {
        return 'null'
    }

    # -InputObject avoids enumerating strings and hashtables into ConvertTo-Json.
    if ($InputObject -is [string] -or $InputObject -is [ValueType]) {
        return (ConvertTo-Json -InputObject $InputObject -Compress)
    }

    if ($null -eq $Seen) {
        $Seen = [System.Collections.Generic.List[object]]::new()
    }
    else {
        foreach ($item in @($Seen)) {
            if ([object]::ReferenceEquals($item, $InputObject)) {
                return '"[Circular]"'
            }
        }
    }

    $Seen.Add($InputObject) | Out-Null

    if ($InputObject -is [System.Collections.IDictionary]) {
        $pairs = foreach ($key in @($InputObject.Keys)) {
            '{0}:{1}' -f (ConvertTo-Json -InputObject $key -Compress), (ConvertTo-FleetLogJson -InputObject $InputObject[$key] -Seen $Seen)
        }
        return '{' + ($pairs -join ',') + '}'
    }

    if ($InputObject -is [System.Collections.IList]) {
        $items = foreach ($item in @($InputObject)) {
            ConvertTo-FleetLogJson -InputObject $item -Seen $Seen
        }
        return '[' + ($items -join ',') + ']'
    }

    $noteProperties = @($InputObject.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' })
    if ($noteProperties.Count -gt 0) {
        $pairs = foreach ($property in $noteProperties) {
            '{0}:{1}' -f (ConvertTo-Json -InputObject $property.Name -Compress), (ConvertTo-FleetLogJson -InputObject $property.Value -Seen $Seen)
        }
        return '{' + ($pairs -join ',') + '}'
    }

    try {
        return (ConvertTo-Json -InputObject $InputObject -Compress -Depth 0 -WarningAction SilentlyContinue)
    }
    catch {
        return (ConvertTo-Json -InputObject $InputObject.GetType().FullName -Compress)
    }
}

function Get-FleetRedactedLogText {
    <#
    .SYNOPSIS
        Redacts passwords, token fields, and bearer tokens in verbose text.

    .DESCRIPTION
        Transcripts and CI capture the verbose stream. Objects are serialized
        without a depth cutoff, then secret fields are replaced. The request
        itself still sends the original value.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Text
    )

    if ($null -eq $Text) {
        return $null
    }

    if ($Text -isnot [string]) {
        $Text = ConvertTo-FleetLogJson -InputObject $Text
    }

    if ([string]::IsNullOrEmpty($Text)) {
        return $Text
    }

    $redacted = [regex]::Replace(
        $Text,
        '(?i)("(?:current_password|new_password|api_token|authorization|password|token|secret)"\s*:\s*")((?:\\.|[^"\\])*)(")',
        '${1}[REDACTED]${3}'
    )
    # Windows PowerShell 5.1 enumerates a piped hashtable as Key/Value entries.
    $redacted = [regex]::Replace(
        $redacted,
        '(?i)("Key"\s*:\s*"(?:current_password|new_password|api_token|authorization|password|token|secret)"\s*,\s*"Value"\s*:\s*")((?:\\.|[^"\\])*)(")',
        '${1}[REDACTED]${3}'
    )
    # Depth-limited ConvertTo-Json leaves @{password=secret} fragments.
    $redacted = [regex]::Replace(
        $redacted,
        '(?i)(^|[{;,\s])((?:current_password|new_password|api_token|authorization|password|token|secret)\s*=\s*)([^;}\r\n]+)',
        '${1}${2}[REDACTED]'
    )
    return [regex]::Replace($redacted, '(?i)\bBearer\s+[^\s"\\}]+', 'Bearer [REDACTED]')
}

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
        
        [switch]$FollowPagination
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
        Write-Verbose "Using headers: $(Get-FleetRedactedLogText -Text $script:FleetDMConnection.Headers)"
        # Add query parameters if provided
        if ($QueryParameters -and $QueryParameters.Count -gt 0) {
            $queryString = ConvertTo-FleetQueryString -QueryParameters $QueryParameters
            if ($queryString) {
                $separator = if ($uri.Contains('?')) { '&' } else { '?' }
                $uri = "$uri$separator$queryString"
            }

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
        Write-Verbose "Request parameters: $(Get-FleetRedactedLogText -Text $requestParams)"
        # Add body if provided. The wire body stays depth-limited JSON.
        # The verbose line redacts a separate serialization of the original object.
        if ($Body -and $Body.Count -gt 0) {
            $jsonBody = ConvertTo-FleetJson -InputObject $Body -Depth 10
            $requestParams['Body'] = $jsonBody
            Write-Verbose "Request body: $(Get-FleetRedactedLogText -Text $Body)"
        }
        Write-Verbose "Sending request to FleetDM API"
        try {
            if ($FollowPagination -and $Method -eq 'GET') {
                Write-Verbose "Pagination enabled. Fetching all results."
                $allResults = New-Object System.Collections.Generic.List[object]
                $page = 0
                $maxPages = 1000
                $baseUri = Get-FleetUriWithoutPage -Uri $uri
                $pageSize = 0
                $pageSizeMatch = [regex]::Match($baseUri, '(?:^|[?&])per_page=(\d+)')
                if ($pageSizeMatch.Success) {
                    $pageSize = [int]$pageSizeMatch.Groups[1].Value
                }
                $previousFirstId = $null

                while ($page -lt $maxPages) {
                    $separator = if ($baseUri.Contains('?')) { '&' } else { '?' }
                    $requestParams['Uri'] = "$baseUri${separator}page=$page"

                    Write-Verbose "Fetching page $page"

                    $response = Invoke-RestMethod @requestParams
                    $pageData = Get-FleetPaginatedData -Response $response -ReturnMetadata
                    $pageItems = @($pageData.Data | Where-Object { $null -ne $_ })

                    # An empty page means the cursor is exhausted. Continuing
                    # when has_next_results stays true would loop forever.
                    if ($pageItems.Count -eq 0) {
                        break
                    }

                    $metadata = $pageData.Metadata
                    $knowsNextPage = $metadata -and (
                        ($metadata -is [System.Collections.IDictionary] -and $metadata.ContainsKey('has_next_results')) -or
                        ($metadata.PSObject.Properties.Name -contains 'has_next_results')
                    )

                    $firstId = $pageItems[0].id
                    if (-not $knowsNextPage -and $pageSize -gt 0 -and $pageItems.Count -ge $pageSize) {
                        # A repeated full page is the same cursor. Do not append it.
                        if ($null -ne $previousFirstId -and $null -ne $firstId -and $firstId -eq $previousFirstId) {
                            break
                        }
                    }

                    foreach ($item in $pageItems) {
                        $allResults.Add($item)
                    }

                    if ($knowsNextPage) {
                        if (-not $pageData.HasMore) {
                            break
                        }
                    }
                    else {
                        # List fleets and some other routes omit meta.has_next_results.
                        # Keep reading while a page is full.
                        if ($pageSize -le 0 -or $pageItems.Count -lt $pageSize) {
                            break
                        }
                        $previousFirstId = $firstId
                    }

                    $page++
                }

                if ($page -ge $maxPages) {
                    Write-Warning "Stopped pagination after $maxPages pages."
                }

                Write-Verbose "Retrieved $($allResults.Count) total items across $($page + 1) pages"

                # List[object] cannot be unwrapped with @() on PowerShell 7.
                return @($allResults.ToArray())
            }
            else {
                Write-Verbose "No pagination requested. Sending single request."
                # Single request without pagination
                $response = Invoke-RestMethod @requestParams
                
                Write-Verbose "Request completed successfully"
                
                return $response
            }
        }
        catch {
            # Handle errors
            Resolve-FleetDMApiError -ErrorRecord $_
        }
    }
}

function Resolve-FleetDMApiError {
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
        $responseBody = Get-FleetHttpErrorBody -ErrorRecord $ErrorRecord

        if ($responseBody) {
            try {
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
            catch {
                Write-Verbose "Could not parse error response body"
                if (-not $errorMessage) {
                    $errorMessage = $responseBody
                }
            }
        }
        
        # Create error message based on status code
        $premiumText = "$errorMessage $($errorDetails | Out-String)"
        $isPremiumStatus = $statusCode -eq 402 -or (
            $statusCode -eq 403 -and $premiumText -match 'premium|license'
        )
        if ($isPremiumStatus) {
            $detail = if ($errorMessage) { $errorMessage } else { 'Requires Fleet Premium license' }
            throw "This feature requires Fleet Premium. $detail"
        }

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

function Get-FleetHttpErrorBody {
    <#
    .SYNOPSIS
        Reads the response body from a failed Fleet HTTP call.

    .DESCRIPTION
        PowerShell 7 exposes the body on ErrorRecord.ErrorDetails and the
        response as HttpResponseMessage. Windows PowerShell 5.1 exposes an
        HttpWebResponse stream. Both shapes are read here.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    if ($ErrorRecord.ErrorDetails -and $ErrorRecord.ErrorDetails.Message) {
        return [string]$ErrorRecord.ErrorDetails.Message
    }

    $response = $ErrorRecord.Exception.Response
    if (-not $response) {
        return $null
    }

    if ($response.PSObject.Methods.Name -contains 'GetResponseStream') {
        try {
            $stream = $response.GetResponseStream()
            if ($stream -and $stream.CanSeek) {
                $stream.Position = 0
            }
            $reader = New-Object System.IO.StreamReader($stream)
            $body = $reader.ReadToEnd()
            $reader.Dispose()
            return $body
        }
        catch {
            Write-Verbose "Could not read HTTP response stream: $_"
        }
    }

    if ($response.Content -and $response.Content.PSObject.Methods.Name -contains 'ReadAsStringAsync') {
        try {
            return $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        }
        catch {
            Write-Verbose "Could not read HTTP response content: $_"
        }
    }

    return $null
}

function Get-FleetUriWithoutPage {
    <#
    .SYNOPSIS
        Returns a URI with any existing page query parameter removed.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Uri
    )

    $question = $Uri.IndexOf('?')
    if ($question -lt 0) {
        return $Uri
    }

    $path = $Uri.Substring(0, $question)
    $kept = @($Uri.Substring($question + 1) -split '&' | Where-Object { $_ -and ($_ -split '=', 2)[0] -ne 'page' })
    if ($kept.Count -eq 0) {
        return $path
    }

    return ($path + '?' + ($kept -join '&'))
}