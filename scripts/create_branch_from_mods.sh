#!/bin/bash
# Create a new branch ONLY if mod packs have been generated
# Usage: bash scripts/create_branch_from_mods.sh [branch_prefix]
# Example: bash scripts/create_branch_from_mods.sh "feature/new-posters"
#
# This script:
#   1. Checks if mod packs exist in ./build/ and ./mods/
#   2. If YES: Creates a new branch with the given name
#   3. If NO: Warns and exits (prevents accidental commits on master)
#
# Safety feature: Never creates a branch or modifies master without mods!

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Defaults
BUILD_DIR="./build"
MODS_DIR="./mods"
BRANCH_PREFIX="${1:-feature/new-mods}"

# Header
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Mod Pack Branch Creator${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to count mod archives
count_mods() {
    if [ -d "$BUILD_DIR" ]; then
        find "$BUILD_DIR" -maxdepth 1 -name "*.zip" -type f | wc -l
    else
        echo 0
    fi
}

# Function to count generated mod folders
count_mod_folders() {
    if [ -d "$MODS_DIR" ]; then
        find "$MODS_DIR" -maxdepth 1 -name "BikininjaPosters*" -type d | wc -l
    else
        echo 0
    fi
}

# Check for existing mods
echo "Checking for generated mod packs..."
MOD_COUNT=$(count_mods)
MOD_FOLDERS=$(count_mod_folders)

echo "  Archives in $BUILD_DIR: $MOD_COUNT"
echo "  Folders in $MODS_DIR: $MOD_FOLDERS"
echo ""

# Validate: At least one mod pack should exist
if [ "$MOD_COUNT" -eq 0 ] && [ "$MOD_FOLDERS" -eq 0 ]; then
    echo -e "${RED}✗ No mod packs found!${NC}"
    echo ""
    echo -e "${YELLOW}Before creating a branch, you need to:${NC}"
    echo "  1. Add media files to ./input/"
    echo "  2. Run the generator: bash generate_mods.sh"
    echo "  3. Check that .zip files appear in ./build/"
    echo "  4. Then run this script again"
    echo ""
    echo -e "${YELLOW}Why? This prevents accidentally committing on master without mods!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found mod packs!${NC}"
echo "  - $MOD_COUNT archive(s)"
echo "  - $MOD_FOLDERS folder(s)"
echo ""

# Check current branch (should be master)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "master" ]; then
    echo -e "${YELLOW}⚠ Warning: Currently on branch '$CURRENT_BRANCH'${NC}"
    read -p "Continue creating branch '$BRANCH_PREFIX'? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

# Check if branch already exists
if git rev-parse --verify "$BRANCH_PREFIX" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Branch '$BRANCH_PREFIX' already exists!${NC}"
    read -p "Switch to existing branch? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout "$BRANCH_PREFIX"
        echo -e "${GREEN}✓ Switched to branch: $BRANCH_PREFIX${NC}"
    else
        echo "Cancelled."
        exit 0
    fi
else
    # Create new branch
    echo "Creating new branch: $BRANCH_PREFIX"
    git checkout -b "$BRANCH_PREFIX"
    echo -e "${GREEN}✓ Created and switched to branch: $BRANCH_PREFIX${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║ ✓ SUCCESS${NC}"
echo -e "${GREEN}║ You are now on branch: $BRANCH_PREFIX${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "  1. Review your mods in: $MODS_DIR/"
echo "  2. Test the .zip files from: $BUILD_DIR/"
echo "  3. Commit: git add . && git commit -m 'feat: add new poster packs'"
echo "  4. Push: git push origin $BRANCH_PREFIX"
echo "  5. Create PR on GitHub for review"
echo ""
echo -e "${YELLOW}Tip: The auto-PR workflow will create a PR automatically!${NC}"
