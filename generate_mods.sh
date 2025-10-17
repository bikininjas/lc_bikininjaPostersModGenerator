#!/bin/bash
# BikininjaPosters Mod Generator - Linux/macOS Wrapper
# Usage: bash generate_mods.sh [--tolerance 5] [--input ./input] [--output ./mods] [--build ./build]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
TOLERANCE=5
INPUT_DIR="./input"
OUTPUT_DIR="./mods"
BUILD_DIR="./build"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --tolerance)
      TOLERANCE="$2"
      shift 2
      ;;
    --input)
      INPUT_DIR="$2"
      shift 2
      ;;
    --output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --build)
      BUILD_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: bash generate_mods.sh [--tolerance 5] [--input ./input] [--output ./mods] [--build ./build]"
      exit 1
      ;;
  esac
done

# Print header
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   BikininjaPosters Mod Generator${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Dependency checking and installation
echo -e "${BLUE}Checking dependencies...${NC}"
echo ""

# Function to check and install Python
check_python() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}✗ Python 3 not found${NC}"
        echo -e "${YELLOW}Install Python 3.10+:${NC}"
        echo "  Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y python3 python3-pip"
        echo "  macOS: brew install python3"
        echo "  Or download: https://www.python.org/downloads/"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo -e "${GREEN}✓ Python found:${NC} $PYTHON_VERSION"
}

# Function to check and install FFmpeg
check_ffmpeg() {
    if ! command -v ffmpeg &> /dev/null; then
        echo -e "${YELLOW}⚠ FFmpeg not found${NC}"
        
        # Detect OS and offer install command
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo -e "${YELLOW}Install FFmpeg:${NC}"
            echo "  sudo apt-get update && sudo apt-get install -y ffmpeg"
            read -p "Install FFmpeg now? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo apt-get update && sudo apt-get install -y ffmpeg
                echo -e "${GREEN}✓ FFmpeg installed${NC}"
            else
                echo -e "${YELLOW}⚠ Skipped. Video processing will fail.${NC}"
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "${YELLOW}Install FFmpeg:${NC}"
            if command -v brew &> /dev/null; then
                echo "  brew install ffmpeg"
                read -p "Install FFmpeg now? (y/n) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    brew install ffmpeg
                    echo -e "${GREEN}✓ FFmpeg installed${NC}"
                else
                    echo -e "${YELLOW}⚠ Skipped. Video processing will fail.${NC}"
                fi
            else
                echo "  Download: https://ffmpeg.org/download.html"
                echo "  Or install Homebrew first: https://brew.sh"
            fi
        else
            echo "  Download: https://ffmpeg.org/download.html"
        fi
        echo ""
    else
        echo -e "${GREEN}✓ FFmpeg found${NC}"
    fi
}

# Function to check and install Python dependencies
check_python_deps() {
    echo -e "${BLUE}Checking Python dependencies...${NC}"
    
    # Create requirements check script
    python3 << 'PYEOF'
import sys
import subprocess

required_packages = ['PIL', 'cv2', 'requests']
package_names = ['Pillow', 'opencv-python', 'requests']

missing = []
for pkg, pkg_name in zip(required_packages, package_names):
    try:
        __import__(pkg)
    except ImportError:
        missing.append(pkg_name)

if missing:
    print(f"Missing packages: {', '.join(missing)}")
    print("Installing...")
    for pkg in missing:
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', pkg])
    print("Done!")
else:
    print("All Python dependencies installed")
PYEOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Python dependencies checked${NC}"
    fi
    echo ""
}

# Run all checks
check_python
check_ffmpeg
check_python_deps

# Activate virtual environment if it exists
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

# Check input directory
if [ ! -d "$INPUT_DIR" ]; then
  echo -e "${RED}✗ Input directory not found: $INPUT_DIR${NC}"
  exit 1
fi

INPUT_COUNT=$(find "$INPUT_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.bmp" -o -iname "*.mp4" -o -iname "*.webp" -o -iname "*.avif" \) | wc -l)
if [ $INPUT_COUNT -eq 0 ]; then
  echo -e "${RED}✗ No media files found in: $INPUT_DIR${NC}"
  echo -e "${YELLOW}  Supported: .png, .jpg, .jpeg, .bmp, .mp4, .webp, .avif${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Input directory:${NC} $INPUT_DIR ($INPUT_COUNT files)"

# Create output directories
mkdir -p "$OUTPUT_DIR" "$BUILD_DIR"
echo -e "${GREEN}✓ Output directories ready${NC}"
echo ""

# Run generator
echo -e "${BLUE}Generating mods...${NC}"
echo ""

python3 scripts/generate_mods.py \
  --input "$INPUT_DIR" \
  --output "$OUTPUT_DIR" \
  --build "$BUILD_DIR" \
  --tolerance "$TOLERANCE"

# Check results
if [ -d "$BUILD_DIR" ] && [ "$(ls -A $BUILD_DIR)" ]; then
  MOD_COUNT=$(ls -1 "$BUILD_DIR"/*.zip 2>/dev/null | wc -l)
  echo ""
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║ ✓ SUCCESS${NC}"
  echo -e "${GREEN}║ Generated: $MOD_COUNT mod(s)${NC}"
  echo -e "${GREEN}║ Location: $BUILD_DIR/${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Review mods in: $OUTPUT_DIR/"
  echo "  2. Upload archives from: $BUILD_DIR/"
  echo "  3. To Thunderstore: Set THUNDERSTORE_SVC_API_KEY and run GitHub Actions"
else
  echo ""
  echo -e "${RED}✗ No mods generated. Check output above for errors.${NC}"
  exit 1
fi
