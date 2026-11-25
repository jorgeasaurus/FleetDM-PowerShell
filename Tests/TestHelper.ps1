# Test Helper for FleetDM-PowerShell module tests
# This file provides common setup for all tests

# Function to import the module properly for testing
function Import-TestModule {
    [CmdletBinding()]
    param()
    
    # Check if we're running in the build system
    if ($env:FLEETDM_TEST_MODULE_PATH) {
        # Use the built module from the Output directory
        $modulePath = $env:FLEETDM_TEST_MODULE_PATH
        Write-Verbose "Using built module from: $modulePath"
    }
    else {
        # Development mode - use the module manifest from the root
        $modulePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'FleetDM-PowerShell.psd1'
        Write-Verbose "Using development module from: $modulePath"
    }
    
    # Remove any existing instances of the module
    Get-Module FleetDM-PowerShell | Remove-Module -Force -ErrorAction SilentlyContinue
    
    # Import the module
    Import-Module $modulePath -Force -Global
    
    # Return the module info
    return Get-Module FleetDM-PowerShell
}
# Starts a one-request HTTP server on 127.0.0.1. The request method, path,
# headers, and raw body bytes are recorded in the returned State table.
function Start-FleetTestListener {
    [CmdletBinding()]
    param(
        [int]$StatusCode = 200,
        [string]$ResponseBody = '{}',
        [string]$ResponseContentType = 'application/json',
        [byte[]]$ResponseBytes
    )

    $listener = $null
    $port = 0
    for ($attempt = 0; $attempt -lt 5 -and -not $listener; $attempt++) {
        $port = Get-Random -Minimum 20000 -Maximum 45000
        $candidate = [System.Net.HttpListener]::new()
        $candidate.Prefixes.Add("http://127.0.0.1:$port/")
        try {
            $candidate.Start()
            $listener = $candidate
        }
        catch {
            $candidate.Close()
        }
    }

    $state = [hashtable]::Synchronized(@{})
    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.Open()
    $worker = [powershell]::Create()
    $worker.Runspace = $runspace
    $null = $worker.AddScript({
        param($HttpListener, $State, $StatusCode, $ResponseBody, $ResponseContentType, $ResponseBytes)
        $context = $HttpListener.GetContext()
        $request = $context.Request
        $memory = [System.IO.MemoryStream]::new()
        $request.InputStream.CopyTo($memory)
        $State.Method = $request.HttpMethod
        $State.Url = $request.Url.PathAndQuery
        $State.ContentType = $request.ContentType
        $State.Authorization = $request.Headers['Authorization']
        $State.Body = $memory.ToArray()
        $bytes = if ($ResponseBytes) { $ResponseBytes } else { [System.Text.Encoding]::UTF8.GetBytes($ResponseBody) }
        $context.Response.StatusCode = $StatusCode
        $context.Response.ContentType = $ResponseContentType
        $context.Response.ContentLength64 = $bytes.Length
        $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        $context.Response.OutputStream.Close()
    }).AddArgument($listener).AddArgument($state).AddArgument($StatusCode).AddArgument($ResponseBody).AddArgument($ResponseContentType).AddArgument($ResponseBytes)

    return @{
        BaseUri = "http://127.0.0.1:$port"
        Listener = $listener
        Worker = $worker
        Runspace = $runspace
        Handle = $worker.BeginInvoke()
        State = $state
    }
}

function Stop-FleetTestListener {
    [CmdletBinding()]
    param([Parameter(Mandatory)][hashtable]$Server)

    $Server.Listener.Stop()
    $Server.Listener.Close()
    try { $null = $Server.Worker.EndInvoke($Server.Handle) } catch { Write-Verbose "Listener stopped before a request: $_" }
    $Server.Worker.Dispose()
    $Server.Runspace.Close()
}
