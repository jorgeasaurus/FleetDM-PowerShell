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

function Test-FleetCurrentUser {
    <#
    .SYNOPSIS
        Returns true when a /me payload is the current Fleet user.

    .DESCRIPTION
        The payload must be an object whose user has both an id and an email.
        A string, such as an HTML proxy page, is not a user.

    .PARAMETER UserInfo
        The object returned by GET /api/v1/fleet/me.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [object]$UserInfo
    )

    if ($null -eq $UserInfo -or $UserInfo -is [string]) {
        return $false
    }

    $currentUser = $UserInfo.user
    if ($null -eq $currentUser -or $currentUser -is [string]) {
        return $false
    }

    $hasUserId = $null -ne $currentUser.id -and -not [string]::IsNullOrWhiteSpace([string]$currentUser.id)
    $hasUserEmail = -not [string]::IsNullOrWhiteSpace([string]$currentUser.email)
    return $hasUserId -and $hasUserEmail
}
