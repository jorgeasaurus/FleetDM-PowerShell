#Requires -Module Pester

BeforeAll {
    # Import the module if not already loaded
    if (-not (Get-Module FleetDM-PowerShell)) {
        $modulePath = (Resolve-Path "$PSScriptRoot/../FleetDM-PowerShell.psd1").Path
        Import-Module $modulePath -Force -ErrorAction Stop
    }
    
    # Mock connection - set in module scope
    InModuleScope FleetDM-PowerShell {
        $script:FleetDMConnection = @{
            BaseUri = "https://test.fleetdm.example.com"
            Headers = @{ 'Authorization' = 'Bearer test-token' }
            Version = "4.0.0"
        }
    }
    
    # Track created policies to detect duplicates
    $script:CreatedPolicyNames = @()
    
    # Mock Invoke-FleetDMRequest for all tests
    Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
        param($Endpoint, $Method, $Body, $QueryParameters)
        
        # Mock policy creation responses
        if ($Endpoint -eq "global/policies" -and $Method -eq "POST") {
            # Check for duplicate name
            if ($script:CreatedPolicyNames -contains $Body.name) {
                throw "Policy with name '$($Body.name)' already exists"
            }
            $script:CreatedPolicyNames += $Body.name
            $policyId = Get-Random -Minimum 100 -Maximum 999
            return @{
                policy = @{
                    id = $policyId
                    name = $Body.name
                    query = $Body.query
                    description = $Body.description
                    resolution = $Body.resolution
                    platform = $Body.platform
                    critical = if ($null -ne $Body.critical) { $Body.critical } else { $false }
                    passing_host_count = 0
                    failing_host_count = 0
                }
            }
        }
        elseif ($Endpoint -eq "global/policies") {
            # Mock for retrieving policies (used in WhatIf test)
            return @()
        }
        
        throw "Unexpected API call: $Method $Endpoint"
    }
}

Describe "New-FleetPolicy Tests" {
    Context "Parameter Validation" {
        It "Should require Name parameter" {
            # Test that function has mandatory parameter
            $command = Get-Command New-FleetPolicy
            $parameter = $command.Parameters['Name']
            $parameter.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | 
                ForEach-Object { $_.Mandatory } | Should -Contain $true
        }
        
        It "Should require Query parameter" {
            # Test that function has mandatory parameter
            $command = Get-Command New-FleetPolicy
            $parameter = $command.Parameters['Query']
            $parameter.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | 
                ForEach-Object { $_.Mandatory } | Should -Contain $true
        }
        
        It "Should validate platform values" {
            { New-FleetPolicy -Name "Test" -Query "SELECT 1;" -Platform "invalid" -WhatIf } | Should -Throw "*ValidateSet*"
        }
    }
    
    Context "Basic Policy Creation" {
        It "Should create a simple global policy" {
            $policyName = "Test Policy $(Get-Random)"
            $policy = New-FleetPolicy -Name $policyName -Query "SELECT 1;" -Description "Test policy for Pester"
            
            $policy | Should -Not -BeNullOrEmpty
            $policy.PSObject.TypeNames | Should -Contain 'FleetDM.Policy'
            $policy.name | Should -Be $policyName
            $policy.query | Should -Be "SELECT 1;"
            $policy.description | Should -Be "Test policy for Pester"
            $policy.platform | Should -BeNullOrEmpty  # API returns empty string for all platforms
            $policy.critical | Should -Be $false
            
            # Track for cleanup
            $script:CreatedPolicies += $policy.id
        }
        
        It "Should create a policy with all optional parameters" {
            $policyName = "Test Policy All Params $(Get-Random)"
            
            $policy = New-FleetPolicy -Name $policyName `
                -Query "SELECT 1 FROM system_info WHERE version >= '10.15';" `
                -Description "Ensures minimum OS version" `
                -Resolution "Update to macOS 10.15 or higher" `
                -Platform "darwin"
                
            $policy | Should -Not -BeNullOrEmpty
            $policy.name | Should -Be $policyName
            $policy.description | Should -Be "Ensures minimum OS version"
            $policy.resolution | Should -Be "Update to macOS 10.15 or higher"
            $policy.platform | Should -Be "darwin"
            $policy.critical | Should -Be $false
            
            # Track for cleanup
            $script:CreatedPolicies += $policy.id
        }
    }
    
    Context "Platform-specific Policies" {
        It "Should create Windows-specific policy" {
            $policyName = "Windows Policy $(Get-Random)"
            $policy = New-FleetPolicy -Name $policyName `
                -Query "SELECT 1 FROM windows_security_center WHERE antivirus_enabled = 1;" `
                -Platform "windows"
            
            $policy | Should -Not -BeNullOrEmpty
            $policy.platform | Should -Be "windows"
            
            # Track for cleanup
            $script:CreatedPolicies += $policy.id
        }
        
        It "Should create Linux-specific policy" {
            $policyName = "Linux Policy $(Get-Random)"
            $policy = New-FleetPolicy -Name $policyName `
                -Query "SELECT 1 FROM kernel_info WHERE version > '4.0';" `
                -Platform "linux"
            
            $policy | Should -Not -BeNullOrEmpty
            $policy.platform | Should -Be "linux"
            
            # Track for cleanup
            $script:CreatedPolicies += $policy.id
        }
    }
    
    
    Context "Calculated Properties" {
        It "Should add calculated properties to new policies" {
            $policyName = "Calculated Props Policy $(Get-Random)"
            $policy = New-FleetPolicy -Name $policyName -Query "SELECT 1;"
            
            if ($policy.passing_host_count -ne $null -and $policy.failing_host_count -ne $null) {
                $policy.PSObject.Properties.Name | Should -Contain 'compliance_percentage'
                $policy.PSObject.Properties.Name | Should -Contain 'total_host_count'
                
                # Verify calculation
                $expectedTotal = $policy.passing_host_count + $policy.failing_host_count
                $policy.total_host_count | Should -Be $expectedTotal
            }
            
            # Track for cleanup
            $script:CreatedPolicies += $policy.id
        }
    }
    
    Context "WhatIf Support" {
        It "Should support -WhatIf without creating policy" {
            $policyName = "WhatIf Test Policy $(Get-Random)"
            $result = New-FleetPolicy -Name $policyName -Query "SELECT 1;" -WhatIf
            
            # Verify policy was not created
            $allPolicies = Get-FleetPolicy
            $created = $allPolicies | Where-Object { $_.name -eq $policyName }
            $created | Should -BeNullOrEmpty
        }
    }
    
    Context "Complex Queries" {
        It "Should handle multi-line queries" {
            $policyName = "Complex Query Policy $(Get-Random)"
            $complexQuery = @"
SELECT 1 WHERE 
NOT EXISTS (
    SELECT 1 FROM users 
    WHERE username = 'root' 
    AND shell != '/usr/bin/false'
);
"@
            
            $policy = New-FleetPolicy -Name $policyName -Query $complexQuery
            
            $policy | Should -Not -BeNullOrEmpty
            $policy.query | Should -Be $complexQuery
            
            # Track for cleanup
            $script:CreatedPolicies += $policy.id
        }
        
        It "Should handle queries with special characters" {
            $policyName = "Special Chars Policy $(Get-Random)"
            $query = "SELECT 1 FROM programs WHERE name LIKE '%Microsoft%' AND version >= '16.0';"
            
            $policy = New-FleetPolicy -Name $policyName -Query $query
            
            $policy | Should -Not -BeNullOrEmpty
            $policy.query | Should -Be $query
            
            # Track for cleanup
            $script:CreatedPolicies += $policy.id
        }
    }
    
    Context "Error Handling" {
        It "Should handle invalid SQL gracefully" {
            $policyName = "Invalid SQL Policy $(Get-Random)"
            
            # This should still create the policy - FleetDM validates SQL when running, not on creation
            $policy = New-FleetPolicy -Name $policyName -Query "INVALID SQL STATEMENT"
            
            # Policy should be created even with invalid SQL
            $policy | Should -Not -BeNullOrEmpty
            
            # Track for cleanup
            $script:CreatedPolicies += $policy.id
        }
        
        It "Should handle duplicate policy names" {
            $policyName = "Duplicate Policy $(Get-Random)"
            
            # Create first policy
            $policy1 = New-FleetPolicy -Name $policyName -Query "SELECT 1;"
            $script:CreatedPolicies += $policy1.id
            
            # Try to create duplicate
            { New-FleetPolicy -Name $policyName -Query "SELECT 1;" -ErrorAction Stop } | Should -Throw
        }
    }
    
    Context "Verbose Output" {
        It "Should provide verbose information when requested" {
            $policyName = "Verbose Test Policy $(Get-Random)"
            
            # Capture both verbose output and the policy object in one call
            $allOutput = New-FleetPolicy -Name $policyName -Query "SELECT 1;" -Verbose 4>&1
            
            $verboseOutput = $allOutput | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
            $policy = $allOutput | Where-Object { $_ -isnot [System.Management.Automation.VerboseRecord] }
            
            $verboseOutput | Should -Not -BeNullOrEmpty
            $verboseMessages = $verboseOutput | ForEach-Object { $_.ToString() }
            $verboseMessages -join ' ' | Should -BeLike "*Creating new policy*"
            
            # Track for cleanup if policy was created
            if ($policy.id) {
                $script:CreatedPolicies += $policy.id
            }
        }
    }
}