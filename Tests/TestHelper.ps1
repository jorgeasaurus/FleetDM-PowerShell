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