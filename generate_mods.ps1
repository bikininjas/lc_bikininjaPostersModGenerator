# BikininjaPosters Mod Generator - Windows PowerShell Wrapper
# Usage: powershell -ExecutionPolicy Bypass -File generate_mods.ps1
# Or: .\generate_mods.ps1

param(
    [int]$Tolerance = 5,
    [string]$Input = "./input",
    [string]$Output = "./mods",
    [string]$Build = "./build"
)

# Color functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error-Custom { Write-Host $args -ForegroundColor Red }
function Write-Warning-Custom { Write-Host $args -ForegroundColor Yellow }
function Write-Info { Write-Host $args -ForegroundColor Blue }

# Header
Write-Info "╔════════════════════════════════════════════════════════════╗"
Write-Info "║   BikininjaPosters Mod Generator (Windows)                 ║"
Write-Info "╚════════════════════════════════════════════════════════════╝"
Write-Host ""

# Check Python
try {
    $pythonVersion = python --version 2>&1
    Write-Success "✓ Python found: $pythonVersion"
} catch {
    Write-Error-Custom "✗ Python not found. Please install Python 3.10+ from python.org"
    exit 1
}

# Check FFmpeg
try {
    $ffmpegVersion = ffmpeg -version 2>&1 | Select-Object -First 1
    Write-Success "✓ FFmpeg found: $ffmpegVersion"
} catch {
    Write-Warning-Custom "⚠ FFmpeg not found. Video processing will fail."
    Write-Warning-Custom "  Install: https://ffmpeg.org/download.html or choco install ffmpeg"
    Write-Host ""
}

# Check input directory
if (-not (Test-Path $Input -PathType Container)) {
    Write-Error-Custom "✗ Input directory not found: $Input"
    exit 1
}

$mediaFiles = @(Get-ChildItem -Path $Input -Recurse -File | Where-Object {
    $_.Extension -match '\.(png|jpg|jpeg|bmp|mp4|webp|avif)$'
})

if ($mediaFiles.Count -eq 0) {
    Write-Error-Custom "✗ No media files found in: $Input"
    Write-Warning-Custom "  Supported: .png, .jpg, .jpeg, .bmp, .mp4, .webp, .avif"
    exit 1
}

Write-Success "✓ Input directory: $Input ($($mediaFiles.Count) files)"

# Create output directories
New-Item -ItemType Directory -Path $Output -Force | Out-Null
New-Item -ItemType Directory -Path $Build -Force | Out-Null
Write-Success "✓ Output directories ready"
Write-Host ""

# Run generator
Write-Info "Generating mods..."
Write-Host ""

& python scripts/generate_mods.py `
    --input $Input `
    --output $Output `
    --build $Build `
    --tolerance $Tolerance

# Check results
$modArchives = @(Get-ChildItem -Path $Build -Filter "*.zip" -ErrorAction SilentlyContinue)

if ($modArchives.Count -gt 0) {
    Write-Host ""
    Write-Success "╔════════════════════════════════════════════════════════════╗"
    Write-Success "║ ✓ SUCCESS"
    Write-Success "║ Generated: $($modArchives.Count) mod(s)"
    Write-Success "║ Location: $Build\"
    Write-Success "╚════════════════════════════════════════════════════════════╝"
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Review mods in: $Output\"
    Write-Host "  2. Upload archives from: $Build\"
    Write-Host "  3. To Thunderstore: Set THUNDERSTORE_SVC_API_KEY and run GitHub Actions"
} else {
    Write-Host ""
    Write-Error-Custom "✗ No mods generated. Check output above for errors."
    exit 1
}
