param(
    [Parameter(Mandatory = $true)]
    [string]$ModuleName = "FleetDM-PowerShell",
    
    [Parameter(Mandatory = $false)]
    [string]$DataFile = "download-stats.json"
)

# Fetch current download count from PowerShell Gallery
function Get-PSGalleryDownloadCount {
    param([string]$ModuleName)
    
    try {
        $module = Find-Module -Name $ModuleName -Repository PSGallery -ErrorAction Stop
        return @{
            Downloads = $module.AdditionalMetadata.downloadCount
            Version = $module.Version.ToString()
        }
    }
    catch {
        Write-Error "Failed to fetch module data: $_"
        exit 1
    }
}

# Load existing data or create new structure
if (Test-Path $DataFile) {
    $stats = Get-Content $DataFile | ConvertFrom-Json
    # Convert to ArrayList for easier manipulation
    $stats.history = [System.Collections.ArrayList]@($stats.history)
} else {
    $stats = @{
        moduleName = $ModuleName
        history = [System.Collections.ArrayList]@()
    }
}

# Get current stats
$currentStats = Get-PSGalleryDownloadCount -ModuleName $ModuleName
$timestamp = (Get-Date).ToString("yyyy-MM-dd")

# Check if we already have data for today
$todayEntry = $stats.history | Where-Object { $_.date -eq $timestamp } | Select-Object -First 1

if ($todayEntry) {
    # Update existing entry
    $todayEntry.downloads = $currentStats.Downloads
    $todayEntry.version = $currentStats.Version
    Write-Host "Updated existing entry for $timestamp"
} else {
    # Add new entry
    $null = $stats.history.Add(@{
        date = $timestamp
        downloads = $currentStats.Downloads
        version = $currentStats.Version
    })
    Write-Host "Added new entry for $timestamp"
}

# Sort by date
$stats.history = $stats.history | Sort-Object { [datetime]$_.date }

# Save updated data
$stats | ConvertTo-Json -Depth 10 | Set-Content $DataFile

Write-Host "Current download count: $($currentStats.Downloads)"
Write-Host "Data saved to $DataFile"

# Generate chart data for README
$chartData = @{
    labels = @($stats.history | ForEach-Object { $_.date })
    data = @($stats.history | ForEach-Object { $_.downloads })
}

# Create a simple SVG chart
function New-SVGChart {
    param($Data, $Labels, $ModuleName)
    
    $width = 800
    $height = 400
    $padding = 50
    $chartWidth = $width - (2 * $padding)
    $chartHeight = $height - (2 * $padding)
    
    # Find min/max for scaling
    $maxValue = ($Data | Measure-Object -Maximum).Maximum
    $minValue = ($Data | Measure-Object -Minimum).Minimum
    $range = $maxValue - $minValue
    if ($range -eq 0) { $range = 1 }
    
    # Create SVG
    $svg = @"
<svg width="$width" height="$height" xmlns="http://www.w3.org/2000/svg">
  <rect width="$width" height="$height" fill="#f6f8fa"/>
  <g transform="translate($padding,$padding)">
    <!-- Title -->
    <text x="$($chartWidth/2)" y="-20" text-anchor="middle" font-size="18" font-weight="bold" fill="#24292e">
      $ModuleName - PowerShell Gallery Downloads
    </text>
    
    <!-- Grid lines -->
"@
    
    # Add horizontal grid lines
    for ($i = 0; $i -le 5; $i++) {
        $y = $chartHeight * ($i / 5)
        $value = [math]::Round($maxValue - ($range * ($i / 5)))
        $svg += "    <line x1='0' y1='$y' x2='$chartWidth' y2='$y' stroke='#e1e4e8' stroke-width='1'/>`n"
        $svg += "    <text x='-10' y='$($y + 5)' text-anchor='end' font-size='12' fill='#586069'>$value</text>`n"
    }
    
    # Create path for line chart
    $pathData = "M"
    $points = @()
    
    for ($i = 0; $i -lt $Data.Count; $i++) {
        $x = if ($Data.Count -eq 1) { $chartWidth / 2 } else { ($i / ($Data.Count - 1)) * $chartWidth }
        $y = $chartHeight - ((($Data[$i] - $minValue) / $range) * $chartHeight)
        $points += @{X = $x; Y = $y; Value = $Data[$i]; Label = $Labels[$i]}
        
        if ($i -eq 0) {
            $pathData += " $x,$y"
        } else {
            $pathData += " L$x,$y"
        }
    }
    
    # Add the line
    $svg += "    <!-- Line chart -->`n"
    $svg += "    <path d='$pathData' fill='none' stroke='#0366d6' stroke-width='2'/>`n"
    
    # Add dots and labels
    foreach ($point in $points) {
        $svg += "    <circle cx='$($point.X)' cy='$($point.Y)' r='4' fill='#0366d6'/>`n"
        # Add hover title
        $svg += "    <title>$($point.Label): $($point.Value) downloads</title>`n"
    }
    
    # Add x-axis labels (show every nth label to avoid crowding)
    $labelInterval = [Math]::Max(1, [Math]::Floor($Labels.Count / 10))
    for ($i = 0; $i -lt $Labels.Count; $i += $labelInterval) {
        $x = if ($Labels.Count -eq 1) { $chartWidth / 2 } else { ($i / ($Labels.Count - 1)) * $chartWidth }
        $svg += "    <text x='$x' y='$($chartHeight + 20)' text-anchor='middle' font-size='10' fill='#586069' transform='rotate(-45 $x $($chartHeight + 20))'>$($Labels[$i])</text>`n"
    }
    
    # Add current stats
    $currentDownloads = $Data[-1]
    $svg += "    <text x='$chartWidth' y='$($chartHeight + 40)' text-anchor='end' font-size='14' fill='#28a745' font-weight='bold'>Current: $currentDownloads downloads</text>`n"
    
    $svg += @"
  </g>
</svg>
"@
    
    return $svg
}

# Generate SVG chart
$svg = New-SVGChart -Data $chartData.data -Labels $chartData.labels -ModuleName $ModuleName
$svg | Set-Content "download-chart.svg"

Write-Host "Chart saved to download-chart.svg"

# Also create a Markdown stats file
$mdStats = @"
## 📊 Download Statistics

**Module:** ``$ModuleName``  
**Current Downloads:** **$($currentStats.Downloads)**  
**Latest Version:** ``$($currentStats.Version)``  
**Last Updated:** $timestamp

### Recent History

| Date | Downloads | Version |
|------|-----------|---------|
"@

# Add last 10 entries to table
$recentEntries = $stats.history | Select-Object -Last 10 | Sort-Object { [datetime]$_.date } -Descending
foreach ($entry in $recentEntries) {
    $mdStats += "`n| $($entry.date) | $($entry.downloads) | $($entry.version) |"
}

$mdStats | Set-Content "download-stats.md"
Write-Host "Markdown stats saved to download-stats.md"