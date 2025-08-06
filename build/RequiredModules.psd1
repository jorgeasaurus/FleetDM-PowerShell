@{
    # Required modules for building, testing, and developing FleetDM-PowerShell
    
    # Build and test requirements
    'Pester' = @{
        Version = '5.0.0'
        Parameters = @{
            AllowClobber = $true
            SkipPublisherCheck = $true
        }
    }
    
    'psake' = @{
        Version = '4.9.0'
    }
    
    'BuildHelpers' = @{
        Version = '2.0.0'
    }
    
    'PSScriptAnalyzer' = @{
        Version = '1.19.0'
    }
    
    'platyPS' = @{
        Version = '0.14.2'
        Parameters = @{
            AllowClobber = $true
        }
    }
    
    'PowerShellGet' = @{
        Version = '2.2.5'
        Parameters = @{
            AllowClobber = $true
            Force = $true
        }
    }
    
    # Module dependencies (none currently, but structure is here for future)
    # 'ModuleName' = @{
    #     Version = '1.0.0'
    #     Parameters = @{
    #         AllowClobber = $true
    #     }
    # }
}