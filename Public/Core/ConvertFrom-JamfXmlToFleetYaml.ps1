function ConvertFrom-JamfXmlToFleetYaml {
    <#
    .SYNOPSIS
        Converts Jamf Pro exported XML files into FleetDM GitOps-compatible files.

    .DESCRIPTION
        Converts Jamf Pro exported XML files into FleetDM GitOps-compatible files. For scripts,
        extracts the script content to a .sh file and generates a YAML referencing it under
        controls.scripts. For configuration profiles, extracts the profile to a .mobileconfig
        file and generates a YAML referencing it under controls.macos_settings.custom_settings.

        Supports Jamf scripts (root element: script), macOS configuration profiles (root element:
        os_x_configuration_profile), mobile device profiles (root element: mobile_device_configuration_profile),
        and raw plist files (root element: plist).

    .PARAMETER Path
        One or more paths to Jamf Pro exported XML files. Supports wildcards and pipeline input.

    .PARAMETER OutputDirectory
        Directory where FleetDM files will be written. Scripts go to lib/scripts/, profiles go
        to lib/profiles/, and YAML files are written to the root. Defaults to the current location.

    .PARAMETER Force
        Overwrites existing files in the output directory.

    .PARAMETER PassThru
        Returns information about the generated files.

    .EXAMPLE
        ConvertFrom-JamfXmlToFleetYaml -Path .\Exports\*.xml -OutputDirectory .\Fleet

        Converts all Jamf XML exports in the Exports folder to FleetDM files in the Fleet folder.

    .EXAMPLE
        Get-ChildItem -Path .\Exports -Filter *.xml | ConvertFrom-JamfXmlToFleetYaml -PassThru

        Converts all Jamf XML exports in the Exports folder and returns the output file details.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$OutputDirectory = (Get-Location).Path,

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$PassThru
    )

    begin {
        function Get-SafeFileName {
            param([Parameter(Mandatory)][string]$Name)
            $pattern = '[{0}\s]+' -f [regex]::Escape([System.IO.Path]::GetInvalidFileNameChars() -join '')
            return $Name -replace $pattern, '_'
        }

        function Get-XmlNodeText {
            param([xml]$XmlDocument, [string]$XPath, [string]$FallbackValue)
            $node = $XmlDocument.SelectSingleNode($XPath)
            if ($null -ne $node -and -not [string]::IsNullOrWhiteSpace($node.InnerText)) {
                return $node.InnerText.Trim()
            }
            return $FallbackValue
        }

        function Get-PlistDisplayName {
            param([xml]$XmlDocument, [string]$FallbackName)
            $dictNode = $XmlDocument.SelectSingleNode('/plist/dict')
            if ($null -eq $dictNode) { return $FallbackName }

            foreach ($key in $dictNode.SelectNodes('key')) {
                if ($key.InnerText -eq 'PayloadDisplayName') {
                    $valueNode = $key.NextSibling
                    if ($valueNode.LocalName -eq 'string' -and -not [string]::IsNullOrWhiteSpace($valueNode.InnerText)) {
                        return $valueNode.InnerText.Trim()
                    }
                }
            }
            return $FallbackName
        }

        $outputItems = @()
        $scriptsDir = Join-Path -Path $OutputDirectory -ChildPath 'lib/scripts'
        $profilesDir = Join-Path -Path $OutputDirectory -ChildPath 'lib/profiles'

        foreach ($dir in @($OutputDirectory, $scriptsDir, $profilesDir)) {
            if (-not (Test-Path -Path $dir)) {
                $null = New-Item -Path $dir -ItemType Directory -Force
            }
        }
    }

    process {
        foreach ($item in $Path) {
            foreach ($file in Get-Item -Path $item -ErrorAction Stop) {
                Write-Verbose "Processing Jamf export: $($file.FullName)"

                $rawXml = Get-Content -LiteralPath $file.FullName -Raw
                if ([string]::IsNullOrWhiteSpace($rawXml)) {
                    Write-Warning "Skipping empty XML file: $($file.FullName)"
                    continue
                }

                try {
                    [xml]$xmlDocument = $rawXml
                }
                catch {
                    Write-Warning "Unable to parse XML file: $($file.FullName). Error: $($_.Exception.Message)"
                    continue
                }

                $rootName = $xmlDocument.DocumentElement.LocalName
                $yamlContent = $null
                $exportType = $null
                $assetPath = $null
                $assetContent = $null

                switch ($rootName) {
                    'script' {
                        $exportType = 'script'
                        $scriptName = Get-XmlNodeText -XmlDocument $xmlDocument -XPath '//script/name' -FallbackValue $file.BaseName
                        $assetContent = $xmlDocument.script.script_contents

                        if ([string]::IsNullOrWhiteSpace($assetContent)) {
                            Write-Warning "Jamf script '$scriptName' does not include script contents. Skipping."
                            continue
                        }

                        $assetFileName = "$(Get-SafeFileName -Name $scriptName).sh"
                        $assetPath = Join-Path -Path $scriptsDir -ChildPath $assetFileName

                        $yamlContent = @"
controls:
  scripts:
    - path: lib/scripts/$assetFileName
"@
                    }
                    { $_ -in 'os_x_configuration_profile', 'mobile_device_configuration_profile' } {
                        $exportType = 'configuration_profile'
                        $profileName = Get-XmlNodeText -XmlDocument $xmlDocument -XPath '//general/name' -FallbackValue $file.BaseName
                        $assetContent = Get-XmlNodeText -XmlDocument $xmlDocument -XPath '//general/payloads' -FallbackValue $null

                        if ($null -eq $assetContent) {
                            Write-Warning "Jamf profile '$profileName' does not include payloads. Skipping."
                            continue
                        }

                        $assetFileName = "$(Get-SafeFileName -Name $profileName).mobileconfig"
                        $assetPath = Join-Path -Path $profilesDir -ChildPath $assetFileName

                        $yamlContent = @"
controls:
  macos_settings:
    custom_settings:
      - path: lib/profiles/$assetFileName
"@
                    }
                    'plist' {
                        $exportType = 'configuration_profile'
                        $profileName = Get-PlistDisplayName -XmlDocument $xmlDocument -FallbackName $file.BaseName
                        $assetContent = $rawXml.Trim()

                        $assetFileName = "$(Get-SafeFileName -Name $profileName).mobileconfig"
                        $assetPath = Join-Path -Path $profilesDir -ChildPath $assetFileName

                        $yamlContent = @"
controls:
  macos_settings:
    custom_settings:
      - path: lib/profiles/$assetFileName
"@
                    }
                    default {
                        Write-Warning "Unsupported Jamf export type '$rootName' in file '$($file.FullName)'. Skipping."
                    }
                }

                if ($null -eq $yamlContent -or $null -eq $assetPath) {
                    continue
                }

                if ((Test-Path -LiteralPath $assetPath) -and -not $Force) {
                    Write-Warning "Asset file already exists: $assetPath. Use -Force to overwrite."
                    continue
                }

                $assetContent | Set-Content -LiteralPath $assetPath -Encoding UTF8 -NoNewline
                Write-Verbose "Wrote asset file to $assetPath"

                $outputFileName = "{0}.fleet.yml" -f $file.BaseName
                $outputPath = Join-Path -Path $OutputDirectory -ChildPath $outputFileName

                if ((Test-Path -LiteralPath $outputPath) -and -not $Force) {
                    Write-Warning "Output file already exists: $outputPath. Use -Force to overwrite."
                    continue
                }

                $yamlContent | Set-Content -LiteralPath $outputPath -Encoding UTF8
                Write-Verbose "Wrote FleetDM YAML to $outputPath"

                if ($PassThru) {
                    $outputItems += [PSCustomObject]@{
                        SourcePath = $file.FullName
                        OutputPath = $outputPath
                        AssetPath  = $assetPath
                        ExportType = $exportType
                    }
                }
            }
        }
    }

    end {
        if ($PassThru) {
            return $outputItems
        }
    }
}
