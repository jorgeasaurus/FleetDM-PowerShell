function ConvertFrom-JamfXmlToFleetYaml {
    <#
    .SYNOPSIS
        Converts Jamf Pro exported XML files into FleetDM-compatible YAML files.

    .DESCRIPTION
        Converts Jamf Pro exported XML files into FleetDM-compatible YAML files. The conversion supports
        Jamf scripts and macOS configuration profiles, which align to FleetDM scripts and custom macOS
        settings. Unsupported Jamf export types are skipped with a warning.

    .PARAMETER Path
        One or more paths to Jamf Pro exported XML files. Supports wildcards and pipeline input.

    .PARAMETER OutputDirectory
        Directory where FleetDM YAML files will be written. Defaults to the current location.

    .PARAMETER Force
        Overwrites existing FleetDM YAML files in the output directory.

    .PARAMETER PassThru
        Returns information about the generated YAML files.

    .EXAMPLE
        ConvertFrom-JamfXmlToFleetYaml -Path .\Exports\*.xml -OutputDirectory .\Fleet

        Converts all Jamf XML exports in the Exports folder to FleetDM YAML files in the Fleet folder.

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
        function ConvertTo-YamlScalar {
            param(
                [Parameter(Mandatory)]
                [string]$Value
            )

            $escaped = $Value.Replace('\', '\\').Replace('"', '\"')
            return '"' + $escaped + '"'
        }

        function ConvertTo-YamlLiteralBlock {
            param(
                [Parameter(Mandatory)]
                [string]$Value,

                [Parameter(Mandatory)]
                [int]$Indent
            )

            $indentation = ' ' * $Indent
            $lines = $Value -split "`r?`n"
            return ($lines | ForEach-Object { "${indentation}$($_)" }) -join "`n"
        }

        function Get-JamfProfileName {
            param(
                [Parameter(Mandatory)]
                [xml]$XmlDocument,

                [Parameter(Mandatory)]
                [string]$FallbackName
            )

            $nameNode = $XmlDocument.SelectSingleNode('//general/name')
            if ($null -ne $nameNode -and -not [string]::IsNullOrWhiteSpace($nameNode.InnerText)) {
                return $nameNode.InnerText.Trim()
            }

            return $FallbackName
        }

        $outputItems = @()

        if (-not (Test-Path -Path $OutputDirectory)) {
            $null = New-Item -Path $OutputDirectory -ItemType Directory -Force
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

                $rootName = $xmlDocument.DocumentElement.Name
                $yamlContent = $null
                $exportType = $null

                switch ($rootName) {
                    'script' {
                        $exportType = 'script'
                        $scriptName = $xmlDocument.script.name
                        if ([string]::IsNullOrWhiteSpace($scriptName)) {
                            $scriptName = $file.BaseName
                        }

                        $scriptBody = $xmlDocument.script.script_contents
                        if ([string]::IsNullOrWhiteSpace($scriptBody)) {
                            Write-Warning "Jamf script '$scriptName' does not include script contents. Skipping."
                            continue
                        }

                        $scriptNotes = $xmlDocument.script.notes

                        $yamlLines = @('scripts:')
                        $yamlLines += "  - name: $(ConvertTo-YamlScalar -Value $scriptName)"

                        if (-not [string]::IsNullOrWhiteSpace($scriptNotes)) {
                            $yamlLines += "    description: $(ConvertTo-YamlScalar -Value $scriptNotes.Trim())"
                        }

                        $yamlLines += '    script: |-'
                        $yamlLines += ConvertTo-YamlLiteralBlock -Value $scriptBody -Indent 6
                        $yamlContent = $yamlLines -join "`n"
                    }
                    'os_x_configuration_profile' {
                        $exportType = 'configuration_profile'
                        $profileName = Get-JamfProfileName -XmlDocument $xmlDocument -FallbackName $file.BaseName
                        $profileValue = $rawXml.Trim()

                        $yamlLines = @(
                            'mdm:',
                            '  macos_settings:',
                            '    custom_settings:',
                            "      - name: $(ConvertTo-YamlScalar -Value $profileName)",
                            '        value: |-'
                        )

                        $yamlLines += ConvertTo-YamlLiteralBlock -Value $profileValue -Indent 10
                        $yamlContent = $yamlLines -join "`n"
                    }
                    'mobile_device_configuration_profile' {
                        $exportType = 'configuration_profile'
                        $profileName = Get-JamfProfileName -XmlDocument $xmlDocument -FallbackName $file.BaseName
                        $profileValue = $rawXml.Trim()

                        $yamlLines = @(
                            'mdm:',
                            '  macos_settings:',
                            '    custom_settings:',
                            "      - name: $(ConvertTo-YamlScalar -Value $profileName)",
                            '        value: |-'
                        )

                        $yamlLines += ConvertTo-YamlLiteralBlock -Value $profileValue -Indent 10
                        $yamlContent = $yamlLines -join "`n"
                    }
                    default {
                        Write-Warning "Unsupported Jamf export type '$rootName' in file '$($file.FullName)'. Skipping."
                    }
                }

                if ($null -eq $yamlContent) {
                    continue
                }

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
