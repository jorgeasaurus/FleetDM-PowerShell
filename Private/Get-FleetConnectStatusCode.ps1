function Get-FleetConnectStatusCode {
    <#
    .SYNOPSIS
        Reads an HTTP status code from a Fleet connection error.

    .DESCRIPTION
        Accepts an HttpStatusCode value, an integer, or the names Unauthorized and Forbidden.
        Returns $null when the error has no HTTP response.

    .PARAMETER ErrorRecord
        The error record thrown by Invoke-WebRequest or Invoke-RestMethod.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    $exceptions = @()
    if ($ErrorRecord.Exception) {
        $exceptions += $ErrorRecord.Exception
        if ($ErrorRecord.Exception.InnerException) {
            $exceptions += $ErrorRecord.Exception.InnerException
        }
    }

    foreach ($exception in $exceptions) {
        $response = $null
        try {
            $response = $exception.Response
        }
        catch {
            continue
        }

        if ($null -eq $response) {
            continue
        }

        $statusCode = $null
        try {
            $statusCode = $response.StatusCode
        }
        catch {
            continue
        }

        if ($null -eq $statusCode) {
            continue
        }

        if ($statusCode -is [System.Net.HttpStatusCode] -or $statusCode -is [int]) {
            return [int]$statusCode
        }

        $statusText = [string]$statusCode
        switch ($statusText) {
            'Unauthorized' { return 401 }
            'Forbidden' { return 403 }
            default {
                $parsedStatus = 0
                if ([int]::TryParse($statusText, [ref]$parsedStatus)) {
                    return $parsedStatus
                }
            }
        }
    }

    return $null
}
