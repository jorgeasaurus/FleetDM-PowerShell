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
    
    # Mock Invoke-FleetDMRequest for all tests
    Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
        param($Endpoint, $Method, $Body, $QueryParameters)
        
        # Mock getting a specific policy
        if ($Endpoint -match "^global/policies/(\d+)$" -and $Method -eq "GET") {
            $policyId = [int]$matches[1]
            if ($policyId -eq 999999) {
                throw "Policy not found"
            }
            return @{
                id = $policyId
                name = "Test Policy"
                query = "SELECT 1;"
                description = "Test description"
                resolution = "Test resolution"
                platform = ""
                critical = $false
                passing_host_count = 5
                failing_host_count = 2
            }
        }
        # Mock policy update responses
        elseif ($Endpoint -like "global/policies/*" -and $Method -eq "PATCH") {
            return @{
                policy = @{
                    id = 1
                    name = if ($Body.name) { $Body.name } else { "Updated Policy" }
                    query = if ($Body.query) { $Body.query } else { "SELECT 1;" }
                    description = if ($Body.description) { $Body.description } else { "Updated description" }
                    resolution = if ($Body.resolution) { $Body.resolution } else { "Updated resolution" }
                    platform = if ($Body.platform) { $Body.platform } else { "" }
                    critical = if ($null -ne $Body.critical) { $Body.critical } else { $false }
                    passing_host_count = 5
                    failing_host_count = 2
                }
            }
        }
        
        throw "Unexpected API call: $Method $Endpoint"
    }
}

Describe "Set-FleetPolicy Tests" {
    Context "Parameter Validation" {
        It "Should require Id parameter" {
            # Test that function has mandatory parameter
            $command = Get-Command Set-FleetPolicy
            $parameter = $command.Parameters['Id']
            $parameter.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | 
                ForEach-Object { $_.Mandatory } | Should -Contain $true
        }
        
        It "Should validate positive policy IDs" {
            { Set-FleetPolicy -Id 0 -Name "Test" -WhatIf } | Should -Throw "*less than the minimum allowed range*"
            { Set-FleetPolicy -Id -1 -Name "Test" -WhatIf } | Should -Throw "*less than the minimum allowed range*"
        }
        
        It "Should validate platform values" {
            { Set-FleetPolicy -Id 1 -Platform "invalid" -WhatIf } | Should -Throw "*ValidateSet*"
        }
        
        It "Should warn when no update parameters provided" {
            if ($script:TestPolicy) {
                $warningVar = $null
                $result = Set-FleetPolicy -Id $script:TestPolicy.id -WarningVariable warningVar -WarningAction SilentlyContinue
                
                $warningVar | Should -Not -BeNullOrEmpty
                $warningVar[0].ToString() | Should -BeLike "*No updates specified*"
            }
        }
    }
    
    Context "Basic Updates" {
        It "Should update policy name" {
            if ($script:TestPolicy) {
                $newName = "Updated Policy Name $(Get-Random)"
                $updated = Set-FleetPolicy -Id $script:TestPolicy.id -Name $newName
                
                $updated | Should -Not -BeNullOrEmpty
                $updated.PSObject.TypeNames | Should -Contain 'FleetDM.Policy'
                $updated.name | Should -Be $newName
                $updated.id | Should -Be $script:TestPolicy.id
            }
        }
        
        It "Should update policy query" {
            if ($script:TestPolicy) {
                $newQuery = "SELECT 1 FROM system_info;"
                $updated = Set-FleetPolicy -Id $script:TestPolicy.id -Query $newQuery
                
                $updated | Should -Not -BeNullOrEmpty
                $updated.query | Should -Be $newQuery
            }
        }
        
        It "Should update policy description" {
            if ($script:TestPolicy) {
                $newDescription = "Updated description $(Get-Random)"
                $updated = Set-FleetPolicy -Id $script:TestPolicy.id -Description $newDescription
                
                $updated | Should -Not -BeNullOrEmpty
                $updated.description | Should -Be $newDescription
            }
        }
        
        It "Should update policy resolution" {
            if ($script:TestPolicy) {
                $newResolution = "Updated resolution steps"
                $updated = Set-FleetPolicy -Id $script:TestPolicy.id -Resolution $newResolution
                
                $updated | Should -Not -BeNullOrEmpty
                $updated.resolution | Should -Be $newResolution
            }
        }
    }
    
    Context "Platform Updates" {
        It "Should update platform to specific OS" {
            if ($script:TestPolicy) {
                $updated = Set-FleetPolicy -Id $script:TestPolicy.id -Platform "darwin"
                
                $updated | Should -Not -BeNullOrEmpty
                $updated.platform | Should -Be "darwin"
            }
        }
        
        It "Should handle 'all' platform (empty string)" {
            if ($script:TestPolicy) {
                $updated = Set-FleetPolicy -Id $script:TestPolicy.id -Platform "all"
                
                $updated | Should -Not -BeNullOrEmpty
                $updated.platform | Should -BeNullOrEmpty  # API returns empty string for all platforms
            }
        }
    }
    
    Context "Multiple Updates" {
        It "Should update multiple properties at once" {
            if ($script:TestPolicy) {
                $newName = "Multi-update Policy $(Get-Random)"
                $newQuery = "SELECT 1 FROM osquery_info;"
                $newDescription = "Multiple updates test"
                
                $updated = Set-FleetPolicy -Id $script:TestPolicy.id `
                    -Name $newName `
                    -Query $newQuery `
                    -Description $newDescription
                
                $updated | Should -Not -BeNullOrEmpty
                $updated.name | Should -Be $newName
                $updated.query | Should -Be $newQuery
                $updated.description | Should -Be $newDescription
            }
        }
        
        It "Should support splatting for updates" {
            if ($script:TestPolicy) {
                $updateParams = @{
                    Id = $script:TestPolicy.id
                    Name = "Splatted Update $(Get-Random)"
                    Description = "Updated via splatting"
                }
                
                $updated = Set-FleetPolicy @updateParams
                
                $updated | Should -Not -BeNullOrEmpty
                $updated.name | Should -Be $updateParams.Name
                $updated.description | Should -Be $updateParams.Description
            }
        }
    }
    
    
    Context "Pipeline Support" {
        It "Should accept policy from pipeline" {
            if ($script:TestPolicy) {
                $newName = "Pipeline Update $(Get-Random)"
                $updated = $script:TestPolicy | Set-FleetPolicy -Name $newName
                
                $updated | Should -Not -BeNullOrEmpty
                $updated.name | Should -Be $newName
                $updated.id | Should -Be $script:TestPolicy.id
            }
        }
        
        It "Should process multiple policies from pipeline" {
            if ($script:TestPolicy) {
                # Get multiple policies
                $policies = Get-FleetPolicy | Select-Object -First 2
                
                if ($policies.Count -ge 2) {
                    $newDescription = "Bulk update $(Get-Random)"
                    $updated = $policies | Set-FleetPolicy -Description $newDescription -WhatIf
                    
                    # With WhatIf, policies shouldn't actually be updated
                    $checkPolicies = $policies | ForEach-Object { Get-FleetPolicy -Id $_.id }
                    $checkPolicies | Where-Object { $_.description -eq $newDescription } | Should -BeNullOrEmpty
                }
            }
        }
    }
    
    
    Context "Error Handling" {
        It "Should handle non-existent policy ID" {
            { Set-FleetPolicy -Id 999999 -Name "Won't work" -ErrorAction Stop } | Should -Throw "*not found*"
        }
        
        It "Should preserve other properties when updating one" {
            if ($script:TestPolicy) {
                # Get current state
                $before = Get-FleetPolicy -Id $script:TestPolicy.id
                
                # Update just the name
                $newName = "Preserve Test $(Get-Random)"
                $after = Set-FleetPolicy -Id $script:TestPolicy.id -Name $newName
                
                # Verify only name changed
                $after.name | Should -Be $newName
                $after.query | Should -Be $before.query
                $after.description | Should -Be $before.description
                $after.platform | Should -Be $before.platform
            }
        }
    }
    
    Context "WhatIf Support" {
        It "Should support -WhatIf without making changes" {
            if ($script:TestPolicy) {
                # Get current name
                $currentName = $script:TestPolicy.name
                
                # Try to update with WhatIf
                $result = Set-FleetPolicy -Id $script:TestPolicy.id -Name "WhatIf Test" -WhatIf
                
                # Verify policy wasn't actually updated
                $checkPolicy = Get-FleetPolicy -Id $script:TestPolicy.id
                $checkPolicy.name | Should -Not -Be "WhatIf Test"
            }
        }
    }
    
    Context "Calculated Properties" {
        It "Should add calculated properties to updated policies" {
            if ($script:TestPolicy) {
                $updated = Set-FleetPolicy -Id $script:TestPolicy.id -Name "Calc Props Test $(Get-Random)"
                
                if ($updated.passing_host_count -ne $null -and $updated.failing_host_count -ne $null) {
                    $updated.PSObject.Properties.Name | Should -Contain 'compliance_percentage'
                    $updated.PSObject.Properties.Name | Should -Contain 'total_host_count'
                }
            }
        }
    }
    
    Context "Verbose Output" {
        It "Should provide verbose information when requested" {
            if ($script:TestPolicy) {
                $verboseOutput = Set-FleetPolicy -Id $script:TestPolicy.id -Name "Verbose Test $(Get-Random)" -Verbose 4>&1 | 
                    Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
                
                $verboseOutput | Should -Not -BeNullOrEmpty
                $verboseMessages = $verboseOutput | ForEach-Object { $_.ToString() }
                $verboseMessages -join ' ' | Should -BeLike "*Updating policy*"
            }
        }
    }
}