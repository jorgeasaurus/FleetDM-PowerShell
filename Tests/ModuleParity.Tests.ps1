BeforeDiscovery {
    $root = Split-Path $PSScriptRoot -Parent
    $script:PublicNames = @(Get-ChildItem -Path (Join-Path $root 'Public') -Recurse -Filter '*.ps1' | ForEach-Object BaseName | Sort-Object)
}

BeforeAll {
    $script:Root = Split-Path $PSScriptRoot -Parent
    $manifestPath = Join-Path $script:Root 'FleetDM-PowerShell.psd1'
    Import-Module $manifestPath -Force
    $script:Manifest = Import-PowerShellDataFile $manifestPath
    $script:Exports = @($script:Manifest.FunctionsToExport | Sort-Object)
    $script:Public = @(Get-ChildItem -Path (Join-Path $script:Root 'Public') -Recurse -Filter '*.ps1' | ForEach-Object BaseName | Sort-Object)
    $docs = Join-Path $script:Root 'docs/en-US'
    $script:DocPages = @(Get-ChildItem -Path $docs -Filter '*.md' |
        Where-Object { $_.BaseName -ne 'FleetDM-PowerShell' -and $_.Name -notlike 'about_*' } |
        ForEach-Object BaseName | Sort-Object)
    $script:Texts = @{
        Nav = Get-Content -Raw (Join-Path $script:Root '_data/nav.yml')
        Index = Get-Content -Raw (Join-Path $script:Root 'index.md')
        Readme = Get-Content -Raw (Join-Path $script:Root 'README.md')
        ModulePage = Get-Content -Raw (Join-Path $docs 'FleetDM-PowerShell.md')
        About = Get-Content -Raw (Join-Path $docs 'about_FleetDM-PowerShell.help.md')
    }
}

Describe 'Module parity' -Tag 'Unit' {
    It 'exports exactly the Public functions' {
        Compare-Object $script:Public $script:Exports | Should -BeNullOrEmpty
        $loaded = @((Get-Module FleetDM-PowerShell).ExportedFunctions.Keys | Sort-Object)
        Compare-Object $script:Exports $loaded | Should -BeNullOrEmpty
    }

    It 'has one docs/en-US page per export' {
        Compare-Object $script:Exports $script:DocPages | Should -BeNullOrEmpty
    }

    It 'has no unresolved PlatyPS placeholders in the help pages' {
        $pages = Get-ChildItem -Path (Join-Path $script:Root 'docs/en-US') -Filter '*.md'
        $placeholders = @($pages | Select-String -Pattern '\{\{' | ForEach-Object { "$($_.Filename):$($_.LineNumber)" })
        $placeholders | Should -BeNullOrEmpty
    }

    It 'records the manifest version in the module page, site config, and changelog' {
        $version = $script:Manifest.ModuleVersion
        $script:Texts.ModulePage | Should -Match ("Help Version: " + [regex]::Escape("$version.0"))
        Get-Content -Raw (Join-Path $script:Root '_config.yml') | Should -Match ('version: "' + [regex]::Escape($version) + '"')
        Get-Content -Raw (Join-Path $script:Root 'CHANGELOG.md') | Should -Match ('(?m)^## ' + [regex]::Escape($version) + '\s*$')
        $script:Manifest.PrivateData.PSData.ReleaseNotes | Should -Match ('^Version ' + [regex]::Escape($version))
    }
}

Describe 'Help and listings for <_>' -Tag 'Unit' -ForEach $script:PublicNames {
    BeforeAll {
        $script:Name = $_
        $script:Help = Get-Help $script:Name -Full
    }

    It 'has a synopsis and an example' {
        $script:Help.Synopsis | Should -Not -BeNullOrEmpty
        $script:Help.Synopsis | Should -Not -BeLike "*$($script:Name) *[[]*"
        @($script:Help.Examples.Example).Count | Should -BeGreaterThan 0
    }

    It 'is listed in nav.yml, index.md, README.md, the module page, and the about topic' {
        $script:Texts.Nav | Should -Match ("title: " + [regex]::Escape($script:Name) + '\s')
        $script:Texts.Index | Should -Match ('\[' + [regex]::Escape($script:Name) + '\]\(docs/en-US/' + [regex]::Escape($script:Name) + '\.md\)')
        $script:Texts.Readme | Should -Match ('`' + [regex]::Escape($script:Name) + '`')
        $script:Texts.ModulePage | Should -Match ('### \[' + [regex]::Escape($script:Name) + '\]\(' + [regex]::Escape($script:Name) + '\.md\)')
        $script:Texts.About | Should -Match ('\b' + [regex]::Escape($script:Name) + '\b')
    }
}
