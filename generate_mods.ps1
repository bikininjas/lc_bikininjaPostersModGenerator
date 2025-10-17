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

# Dependency checking and installation
Write-Info "Checking dependencies..."
Write-Host ""

# Function to check Python
function Test-Python {
    try {
        $pythonVersion = python --version 2>&1
        Write-Success "✓ Python found: $pythonVersion"
        return $true
    } catch {
        Write-Error-Custom "✗ Python not found"
        Write-Warning-Custom "Install Python 3.10+:"
        Write-Warning-Custom "  1. Download from: https://www.python.org/downloads/"
        Write-Warning-Custom "  2. Run installer (check 'Add Python to PATH')"
        Write-Warning-Custom "  3. Restart PowerShell and try again"
        return $false
    }
}

# Function to check FFmpeg
function Test-FFmpeg {
    try {
        $ffmpegVersion = ffmpeg -version 2>&1 | Select-Object -First 1
        Write-Success "✓ FFmpeg found: $ffmpegVersion"
        return $true
    } catch {
        Write-Warning-Custom "⚠ FFmpeg not found"
        Write-Warning-Custom "Install FFmpeg:"
        Write-Warning-Custom "  Option 1 (Chocolatey): choco install ffmpeg"
        Write-Warning-Custom "  Option 2 (WinGet): winget install ffmpeg"
        Write-Warning-Custom "  Option 3 (Manual): https://ffmpeg.org/download.html"
        
        # Check if Chocolatey is available
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            $response = Read-Host "Install FFmpeg via Chocolatey? (y/n)"
            if ($response -eq 'y') {
                try {
                    choco install ffmpeg -y
                    Write-Success "✓ FFmpeg installed"
                    return $true
                } catch {
                    Write-Error-Custom "Failed to install FFmpeg via Chocolatey"
                    return $false
                }
            }
        }
        # Check if WinGet is available
        elseif (Get-Command winget -ErrorAction SilentlyContinue) {
            $response = Read-Host "Install FFmpeg via WinGet? (y/n)"
            if ($response -eq 'y') {
                try {
                    winget install ffmpeg
                    Write-Success "✓ FFmpeg installed"
                    return $true
                } catch {
                    Write-Error-Custom "Failed to install FFmpeg via WinGet"
                    return $false
                }
            }
        }
        
        Write-Warning-Custom "⚠ Skipped. Video processing will fail."
        return $false
    }
}

# Function to check Python dependencies
function Test-PythonDeps {
    Write-Info "Checking Python dependencies..."
    
    $pythonScript = @'
import sys
import subprocess

required_packages = {
    'PIL': 'Pillow',
    'cv2': 'opencv-python',
    'requests': 'requests'
}

missing = []
for pkg, pkg_name in required_packages.items():
    try:
        __import__(pkg)
    except ImportError:
        missing.append(pkg_name)

if missing:
    print(f"Missing: {', '.join(missing)}")
    print("Installing...")
    for pkg in missing:
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', pkg])
    print("✓ Dependencies installed")
else:
    print("✓ All dependencies present")
'@
    
    $pythonScript | python -
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Python dependencies ready"
    } else {
        Write-Error-Custom "Failed to install Python dependencies"
        return $false
    }
    return $true
}

# Run all checks
if (-not (Test-Python)) {
    exit 1
}

Test-FFmpeg | Out-Null
Test-PythonDeps

Write-Host ""

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
