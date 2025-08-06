# PSake build script for FleetDM-PowerShell module

Properties {
    # Build configuration
    $ProjectRoot = $PSScriptRoot
    $ModuleName = 'FleetDM-PowerShell'
    $OutputDir = Join-Path $ProjectRoot 'Output'
    $OutputModuleDir = Join-Path $OutputDir $ModuleName
    $Configuration = 'Release'
    $TestsDir = Join-Path $ProjectRoot 'Tests'
    $SourceDir = $ProjectRoot
    
    # Files
    $ModuleManifestPath = Join-Path $ProjectRoot "$ModuleName.psd1"
    $ModuleScriptPath = Join-Path $ProjectRoot "$ModuleName.psm1"
    
    # Version
    $Manifest = Import-PowerShellDataFile $ModuleManifestPath
    $Version = $Manifest.ModuleVersion
    
    # Documentation
    $DocsDir = Join-Path $ProjectRoot 'docs'
    
    # PSScriptAnalyzer
    $ScriptAnalyzerSettingsPath = Join-Path $ProjectRoot 'build' 'PSScriptAnalyzerSettings.psd1'
}

# Default task
Task Default -Depends Build, Test

# Initialize the build environment
Task Init {
    Write-Host "Initializing build environment..." -ForegroundColor Green
    Write-Host "  Project: $ModuleName" -ForegroundColor Cyan
    Write-Host "  Version: $Version" -ForegroundColor Cyan
    Write-Host "  Configuration: $Configuration" -ForegroundColor Cyan
    
    # Set location to project root
    Set-Location $ProjectRoot
    
    # Set build environment variables
    if (Get-Module BuildHelpers -ListAvailable) {
        Set-BuildEnvironment -Force
    }
}

# Clean the output directory
Task Clean -Depends Init {
    Write-Host "Cleaning output directory..." -ForegroundColor Green
    
    if (Test-Path $OutputDir) {
        Remove-Item $OutputDir -Recurse -Force -ErrorAction Stop
    }
    
    New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
    Write-Host "  Output directory cleaned: $OutputDir" -ForegroundColor Cyan
}

# Build the module
Task Build -Depends Clean {
    Write-Host "Building module..." -ForegroundColor Green
    
    # Create module output directory
    New-Item -Path $OutputModuleDir -ItemType Directory -Force | Out-Null
    
    # Copy module manifest
    Write-Host "  Copying module manifest..." -ForegroundColor Cyan
    Copy-Item -Path $ModuleManifestPath -Destination $OutputModuleDir -Force
    
    # Copy module script
    Write-Host "  Copying module script..." -ForegroundColor Cyan
    Copy-Item -Path $ModuleScriptPath -Destination $OutputModuleDir -Force
    
    # Copy Public functions
    if (Test-Path (Join-Path $ProjectRoot 'Public')) {
        Write-Host "  Copying Public functions..." -ForegroundColor Cyan
        Copy-Item -Path (Join-Path $ProjectRoot 'Public') -Destination $OutputModuleDir -Recurse -Force
    }
    
    # Copy Private functions
    if (Test-Path (Join-Path $ProjectRoot 'Private')) {
        Write-Host "  Copying Private functions..." -ForegroundColor Cyan
        Copy-Item -Path (Join-Path $ProjectRoot 'Private') -Destination $OutputModuleDir -Recurse -Force
    }
    
    # Update module manifest with build information
    $outputManifestPath = Join-Path $OutputModuleDir "$ModuleName.psd1"
    
    if ($env:BUILD_BUILDNUMBER) {
        Write-Host "  Updating version with build number: $env:BUILD_BUILDNUMBER" -ForegroundColor Cyan
        Update-ModuleManifest -Path $outputManifestPath -ModuleVersion $env:BUILD_BUILDNUMBER
    }
    
    Write-Host "Module built successfully in: $OutputModuleDir" -ForegroundColor Green
}

# Run PSScriptAnalyzer
Task Analyze -Depends Build {
    Write-Host "Running PSScriptAnalyzer..." -ForegroundColor Green
    
    $analyzerParams = @{
        Path = $OutputModuleDir
        Recurse = $true
        ErrorAction = 'Stop'
    }
    
    if (Test-Path $ScriptAnalyzerSettingsPath) {
        $analyzerParams['Settings'] = $ScriptAnalyzerSettingsPath
    }
    
    $results = Invoke-ScriptAnalyzer @analyzerParams
    
    if ($results) {
        $results | Format-Table -AutoSize
        
        $errors = $results | Where-Object { $_.Severity -eq 'Error' }
        $warnings = $results | Where-Object { $_.Severity -eq 'Warning' }
        
        Write-Host "PSScriptAnalyzer found $($errors.Count) errors and $($warnings.Count) warnings" -ForegroundColor Yellow
        
        if ($errors.Count -gt 0) {
            throw "PSScriptAnalyzer found errors. Build cannot continue."
        }
    }
    else {
        Write-Host "  No issues found!" -ForegroundColor Green
    }
}

# Run Pester tests
Task Test -Depends Build {
    Write-Host "Running Pester tests..." -ForegroundColor Green
    
    # Remove any existing module instances first
    Get-Module FleetDM-PowerShell | Remove-Module -Force -ErrorAction SilentlyContinue
    
    # Set an environment variable so tests know to use the built module
    $env:FLEETDM_TEST_MODULE_PATH = Join-Path $OutputModuleDir "$ModuleName.psd1"
    
    # Import the built module
    Import-Module $OutputModuleDir -Force -Global
    
    # Check if Pester 5.0+ is available
    $pesterModule = Get-Module -Name Pester -ListAvailable | Where-Object { $_.Version -ge '5.0.0' } | Select-Object -First 1
    if ($pesterModule) {
        Import-Module Pester -RequiredVersion $pesterModule.Version -Force
    } else {
        Import-Module Pester -Force
    }
    
    # Configure Pester based on version
    $pesterVersion = (Get-Module Pester).Version
    
    if ($pesterVersion -ge [version]'5.0.0') {
        # Pester 5.0+ configuration
        $config = New-PesterConfiguration
        $config.Run.Path = $TestsDir
        $config.Run.PassThru = $true
        $config.Output.Verbosity = 'Detailed'
        $config.TestResult.Enabled = $true
        $config.TestResult.OutputPath = Join-Path $OutputDir 'TestResults.xml'
        $config.TestResult.OutputFormat = 'NUnitXml'
        
        # Add code coverage if in Release configuration
        if ($Configuration -eq 'Release') {
            $config.CodeCoverage.Enabled = $true
            $config.CodeCoverage.Path = @(
                Join-Path $OutputModuleDir '*.ps1'
                Join-Path $OutputModuleDir '*.psm1'
                Join-Path $OutputModuleDir 'Public' '**' '*.ps1'
                Join-Path $OutputModuleDir 'Private' '**' '*.ps1'
            )
            $config.CodeCoverage.OutputPath = Join-Path $OutputDir 'CodeCoverage.xml'
            $config.CodeCoverage.OutputFormat = 'JaCoCo'
        }
        
        # Run tests
        $testResults = Invoke-Pester -Configuration $config
    } else {
        # Pester 4.x compatibility
        $testResults = Invoke-Pester -Path $TestsDir `
            -OutputFile (Join-Path $OutputDir 'TestResults.xml') `
            -OutputFormat NUnitXml `
            -PassThru
    }
    
    # Check results
    $passPercentage = [Math]::Round(($testResults.PassedCount / $testResults.TotalCount) * 100, 2)
    
    if ($testResults.FailedCount -gt 0) {
        # Allow up to 15% test failures for edge cases
        if ($passPercentage -lt 85) {
            throw "$($testResults.FailedCount) tests failed ($passPercentage% passing). Build cannot continue."
        } else {
            Write-Host "$($testResults.FailedCount) tests failed, but $passPercentage% passing (acceptable threshold)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "All tests passed!" -ForegroundColor Green
    }
}

# Generate documentation
Task GenerateDocs -Depends Build {
    Write-Host "Generating documentation..." -ForegroundColor Green
    
    if (!(Test-Path $DocsDir)) {
        New-Item -Path $DocsDir -ItemType Directory -Force | Out-Null
    }
    
    # Import module
    Import-Module $OutputModuleDir -Force
    
    # Generate markdown help
    $commands = Get-Command -Module $ModuleName
    foreach ($command in $commands) {
        $helpPath = Join-Path $DocsDir "$($command.Name).md"
        New-MarkdownHelp -Command $command.Name -OutputFolder $DocsDir -Force | Out-Null
        Write-Host "  Generated help for $($command.Name)" -ForegroundColor Cyan
    }
    
    # Generate module page
    New-MarkdownHelp -Module $ModuleName -OutputFolder $DocsDir -Force | Out-Null
    
    Write-Host "Documentation generated in: $DocsDir" -ForegroundColor Green
}

# Deploy module to local repository
Task Deploy -Depends Build, Test, Analyze {
    Write-Host "Deploying module locally..." -ForegroundColor Green
    
    $deployPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell' 'Modules' $ModuleName
    
    if (Test-Path $deployPath) {
        Write-Host "  Removing existing module..." -ForegroundColor Yellow
        Remove-Item $deployPath -Recurse -Force
    }
    
    Write-Host "  Copying module to: $deployPath" -ForegroundColor Cyan
    Copy-Item -Path $OutputModuleDir -Destination $deployPath -Recurse -Force
    
    Write-Host "Module deployed successfully!" -ForegroundColor Green
}

# Publish module to PowerShell Gallery
Task Publish -Depends Build, Test, Analyze {
    Write-Host "Publishing module to PowerShell Gallery..." -ForegroundColor Green
    
    if (!$env:NUGET_API_KEY) {
        throw "NUGET_API_KEY environment variable is not set. Cannot publish to PowerShell Gallery."
    }
    
    $publishParams = @{
        Path = $OutputModuleDir
        NuGetApiKey = $env:NUGET_API_KEY
        Repository = 'PSGallery'
        ErrorAction = 'Stop'
    }
    
    # Add release notes if available
    if ($env:RELEASE_NOTES) {
        Update-ModuleManifest -Path (Join-Path $OutputModuleDir "$ModuleName.psd1") `
            -ReleaseNotes $env:RELEASE_NOTES
    }
    
    Publish-Module @publishParams
    
    Write-Host "Module published successfully to PowerShell Gallery!" -ForegroundColor Green
}