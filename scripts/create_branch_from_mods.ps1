# Create a new branch ONLY if mod packs have been generated
# Usage: powershell -ExecutionPolicy Bypass -File scripts/create_branch_from_mods.ps1 [branch_prefix]
# Example: powershell -ExecutionPolicy Bypass -File scripts/create_branch_from_mods.ps1 "feature/new-posters"
#
# This script:
#   1. Checks if mod packs exist in .\build\ and .\mods\
#   2. If YES: Creates a new branch with the given name
#   3. If NO: Warns and exits (prevents accidental commits on master)
#
# Safety feature: Never creates a branch or modifies master without mods!

param(
    [string]$BranchPrefix = "feature/new-mods"
)

# Color functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error-Custom { Write-Host $args -ForegroundColor Red }
function Write-Warning-Custom { Write-Host $args -ForegroundColor Yellow }
function Write-Info { Write-Host $args -ForegroundColor Blue }

# Directories
$BuildDir = ".\build"
$ModsDir = ".\mods"

# Header
Write-Info "╔════════════════════════════════════════════════════════════╗"
Write-Info "║   Mod Pack Branch Creator (Windows)                        ║"
Write-Info "╚════════════════════════════════════════════════════════════╝"
Write-Host ""

# Function to get mod archive count
function Get-ModCount {
    if (Test-Path $BuildDir -PathType Container) {
        @(Get-ChildItem -Path $BuildDir -Filter "*.zip" -ErrorAction SilentlyContinue).Count
    } else {
        0
    }
}

# Function to get generated mod folder count
function Get-ModFolderCount {
    if (Test-Path $ModsDir -PathType Container) {
        @(Get-ChildItem -Path $ModsDir -Filter "BikininjaPosters*" -Directory -ErrorAction SilentlyContinue).Count
    } else {
        0
    }
}

# Check for existing mods
Write-Host "Checking for generated mod packs..."
$ModCount = Get-ModCount
$ModFolders = Get-ModFolderCount

Write-Host "  Archives in $BuildDir`: $ModCount"
Write-Host "  Folders in $ModsDir`: $ModFolders"
Write-Host ""

# Validate: At least one mod pack should exist
if ($ModCount -eq 0 -and $ModFolders -eq 0) {
    Write-Error-Custom "✗ No mod packs found!"
    Write-Host ""
    Write-Warning-Custom "Before creating a branch, you need to:"
    Write-Host "  1. Add media files to .\input\"
    Write-Host "  2. Run the generator: powershell -ExecutionPolicy Bypass -File generate_mods.ps1"
    Write-Host "  3. Check that .zip files appear in .\build\"
    Write-Host "  4. Then run this script again"
    Write-Host ""
    Write-Warning-Custom "Why? This prevents accidentally committing on master without mods!"
    exit 1
}

Write-Success "✓ Found mod packs!"
Write-Host "  - $ModCount archive(s)"
Write-Host "  - $ModFolders folder(s)"
Write-Host ""

# Check current branch (should be master)
$CurrentBranch = & git rev-parse --abbrev-ref HEAD 2>$null
if ($CurrentBranch -ne "master") {
    Write-Warning-Custom "⚠ Warning: Currently on branch '$CurrentBranch'"
    $response = Read-Host "Continue creating branch '$BranchPrefix'? (y/n)"
    if ($response -ne 'y') {
        Write-Host "Cancelled."
        exit 0
    }
}

# Check if branch already exists
& git rev-parse --verify $BranchPrefix 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Warning-Custom "⚠ Branch '$BranchPrefix' already exists!"
    $response = Read-Host "Switch to existing branch? (y/n)"
    if ($response -eq 'y') {
        & git checkout $BranchPrefix
        Write-Success "✓ Switched to branch: $BranchPrefix"
    } else {
        Write-Host "Cancelled."
        exit 0
    }
} else {
    # Create new branch
    Write-Host "Creating new branch: $BranchPrefix"
    & git checkout -b $BranchPrefix
    Write-Success "✓ Created and switched to branch: $BranchPrefix"
}

Write-Host ""
Write-Success "╔════════════════════════════════════════════════════════════╗"
Write-Success "║ ✓ SUCCESS"
Write-Success "║ You are now on branch: $BranchPrefix"
Write-Success "╚════════════════════════════════════════════════════════════╝"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Review your mods in: $ModsDir\"
Write-Host "  2. Test the .zip files from: $BuildDir\"
Write-Host "  3. Commit: git add . && git commit -m 'feat: add new poster packs'"
Write-Host "  4. Push: git push origin $BranchPrefix"
Write-Host "  5. Create PR on GitHub for review"
Write-Host ""
Write-Warning-Custom "Tip: The auto-PR workflow will create a PR automatically!"
