#Requires -Version 5.1

# Script-level variables for connection management
$script:FleetDMConnection = $null
$script:FleetDMWebSession = $null

# Get public and private function definition files
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue -Recurse)

# Dot source the files
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Export public functions
Export-ModuleMember -Function $Public.Basename

# Module cleanup
$ExecutionContext.SessionState.Module.OnRemove = {
    if ($script:FleetDMConnection) {
        Write-Warning "FleetDM connection will be closed. Use Connect-FleetDM to reconnect in future sessions."
        $script:FleetDMConnection = $null
        $script:FleetDMWebSession = $null
    }
}