function Format-FleetErrorReason {
    <#
    .SYNOPSIS
        Joins the errors[].name and errors[].reason pairs from a Fleet error body.

    .DESCRIPTION
        Fleet puts the useful text of a 4xx response in errors[].reason. The
        top-level message is often only the status text, such as
        "Unprocessable Entity". A reason that repeats Message is skipped. The
        generic field name "base" is not printed.

    .PARAMETER Errors
        The errors value from the parsed response body. One object is accepted
        because Windows PowerShell 5.1 unwraps a one-element JSON array.

    .PARAMETER Message
        The top-level message. A reason equal to it is not repeated.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$Errors,

        [AllowNull()]
        [string]$Message
    )

    $parts = foreach ($item in @($Errors)) {
        if ($null -eq $item) { continue }
        $reason = [string]$item.reason
        if (-not $reason -or $reason -eq $Message) { continue }
        $name = [string]$item.name
        if ($name -and $name -ne 'base') { "${name}: $reason" } else { $reason }
    }

    return (@($parts) -join '; ')
}
