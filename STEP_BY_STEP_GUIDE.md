# 📖 Complete Step-by-Step Guide for Beginners

Welcome! This guide walks you through **everything** from zero to publishing mods. No prior knowledge needed!

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Preparing Your Media](#preparing-your-media)
4. [Generating Mods (Local)](#generating-mods-local)
5. [Testing Your Mods](#testing-your-mods)
6. [Publishing to Thunderstore](#publishing-to-thunderstore)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

**What you need:**
- A computer (Windows, Mac, or Linux)
- About 30 minutes
- Some images or videos you want to share as posters
- Basic comfort with a terminal/command prompt

**That's it!** Everything else gets installed automatically.

---

## Installation

### Step 1: Get the Code

You need to get this project onto your computer. Choose one:

#### Option A: Clone with Git (Recommended)
If you have [Git](https://git-scm.com/downloads) installed:

```bash
git clone https://github.com/bikininjas/lc_bikininjaPostersModGenerator.git
cd lc_bikininjaPostersModGenerator
```

#### Option B: Download ZIP
1. Go to https://github.com/bikininjas/lc_bikininjaPostersModGenerator
2. Click **Code** → **Download ZIP**
3. Extract the ZIP file
4. Open the extracted folder in your terminal

### Step 2: Install Python

The tool needs **Python 3.10 or newer**. Check if you have it:

```bash
python --version
```

If it says `3.10` or higher, great! If not:

1. Go to https://www.python.org/downloads/
2. Download **Python 3.10+** (click the big download button)
3. **Important**: During installation, check the box that says **"Add Python to PATH"**
4. Run the installer and follow the prompts
5. Restart your terminal

### Step 3: Install FFmpeg (for videos)

If you **only have images**, you can skip this. But if you want to use **.mp4 videos**, install FFmpeg:

#### Windows:
```powershell
# If you have Chocolatey:
choco install ffmpeg

# If you have WinGet:
winget install ffmpeg

# Otherwise: Download from https://ffmpeg.org/download.html
```

#### Mac:
```bash
brew install ffmpeg
```

#### Linux:
```bash
sudo apt install ffmpeg
```

### Step 4: Verify Installation

```bash
python --version       # Should show 3.10+
ffmpeg -version       # Should show FFmpeg version
```

✅ **All set!**

---

## Preparing Your Media

### Where to Put Files

1. Open the project folder
2. Find (or create) a folder called `input/`
3. Copy your images and videos there

Example:
```
lc_bikininjaPostersModGenerator/
├── input/
│   ├── sunset.jpg          ✅ Allowed
│   ├── cat.png             ✅ Allowed
│   ├── video.mp4           ✅ Allowed
│   ├── background.webp     ✅ Allowed
│   ├── photo.avif          ✅ Allowed
│   └── document.pdf        ❌ Not allowed
└── (other files)
```

### Supported Formats

| Type | Formats |
|------|---------|
| **Images** | .jpg, .png, .bmp, .webp, .avif |
| **Videos** | .mp4 |

### How Many Files?

For **each mod pack**, you need:
- **At minimum: 6 files** (5 posters + 1 tip)
- **Recommended: 10+ files** (gives better variety)

**Examples:**
- 6 files = 1 mod pack
- 12 files = 2 mod packs
- 24 files = 4 mod packs

### Image Quality Tips

✅ **Good for posters:**
- Landscape photos (wider than tall)
- Clear, high-quality images
- Varied aspect ratios

❌ **Avoid:**
- Super tiny images (< 400 pixels wide)
- Heavily compressed/blurry images
- Text-only images (will look bad as posters)

---

## Generating Mods (Local)

### On Windows (PowerShell)

1. Open PowerShell in your project folder
2. Run:

```powershell
powershell -ExecutionPolicy Bypass -File generate_mods.ps1
```

You should see:
```
╔════════════════════════════════════════════════════════════╗
║   BikininjaPosters Mod Generator (Windows)                 ║
╚════════════════════════════════════════════════════════════╝

Checking dependencies...
✓ Python found: Python 3.11.5
✓ FFmpeg found: ffmpeg version...
✓ Input directory: ./input (12 files)
✓ Output directories ready

Generating mods...
✓ SUCCESS
...
```

### On Mac/Linux (Bash)

1. Open Terminal in your project folder
2. Run:

```bash
bash generate_mods.sh
```

### Using Python Directly (Any OS)

```bash
python scripts/generate_mods.py --input ./input --output ./mods --build ./build
```

### What Happens Next

The tool will:
1. ✅ Find all your images/videos
2. ✅ Analyze their aspect ratios
3. ✅ Group them intelligently (6 per mod)
4. ✅ Crop and resize them
5. ✅ Create mod folders in `./mods/`
6. ✅ Create .zip archives in `./build/`

**Takes 10-30 seconds** depending on file sizes.

### Check Your Output

After it finishes, check:

```
mods/
├── BikininjaPosters01/
│   └── BepInEx/plugins/BikininjasPosters01/CustomPosters/
│       ├── posters/
│       │   ├── Poster1.jpg
│       │   ├── Poster2.jpg
│       │   ├── Poster3.jpg
│       │   ├── Poster4.jpg
│       │   └── Poster5.jpg
│       └── tips/
│           └── CustomTips.jpg
├── BikininjaPosters02/
│   └── ... (same structure)
└── versions.json

build/
├── BikininjaPosters01-v0.0.1.zip   ✅ This is your mod!
├── BikininjaPosters02-v0.0.1.zip   ✅ This is your mod!
└── ...
```

---

## Testing Your Mods

### Before Uploading, Test Locally

1. **Download Lethal Company** if you haven't
2. **Install BepInEx**:
   - Follow: https://docs.bepinex.dev/articles/user_guide/installation/index.html
   - Or use a mod manager (Thunderstore Mod Manager is easiest)
3. **Install CustomPosters mod** (required for your posters to show)
4. **Extract your .zip** into your Lethal Company mods folder
5. **Launch Lethal Company** and check:
   - ✅ Mod appears in mod list
   - ✅ Posters appear in game
   - ✅ Images look good

### Problems?

See the [Troubleshooting](#troubleshooting) section below.

---

## Publishing to Thunderstore

Thunderstore is the main repository for Lethal Company mods.

### Step 1: Create Thunderstore Account

1. Go to https://thunderstore.io
2. Click **Sign Up** (top right)
3. Create an account
4. **Verify your email**

### Step 2: Create Team (Optional but Recommended)

1. In Thunderstore, go to **Teams** → **Create Team**
2. Name it something like "MyPosters"
3. This keeps all your mods organized

### Step 3: Upload Your First Mod

1. Go to https://thunderstore.io/c/lethal-company/create/package/
2. Fill in the form:

| Field | Example |
|-------|---------|
| **Namespace** | MyPosters |
| **Name** | BikininjaPosters01 |
| **Version** | 0.0.1 (from your .zip filename) |
| **Description** | "Beautiful posters for CustomPosters" |
| **Icon** | Upload a screenshot (optional) |
| **README** | Write something nice about your mod |

3. **Upload file**: Choose your `.zip` from `./build/`
4. Click **Create Package**

### Step 4: Share Your Link!

After uploading, you'll get a link like:
```
https://thunderstore.io/c/lethal-company/p/MyPosters/BikininjaPosters01/
```

Share this with friends! 🎉

### Publishing Multiple Mods

Repeat **Step 3** for each `.zip` file in your `build/` folder.

---

## Troubleshooting

### "No media files found"

**Problem:** Tool says there are no files.

**Solution:**
1. Check that `./input/` folder exists
2. Put images/videos **directly** in `./input/` (not in subfolders)
3. Make sure file extensions are lowercase (.jpg not .JPG)
4. Verify supported formats: .jpg, .png, .bmp, .webp, .avif, .mp4

### "Python not found"

**Problem:** Terminal says Python isn't installed or recognized.

**Solution:**
1. Download Python from https://www.python.org/downloads/
2. **During installation**, CHECK: "Add Python to PATH"
3. Restart your terminal completely
4. Run `python --version` to verify

### "FFmpeg not found" (but you only have images)

**Problem:** Warning about FFmpeg.

**Solution:**
- **If you only have images**: Ignore this warning, it's fine
- **If you have videos**: Install FFmpeg:
  - Windows: `choco install ffmpeg` or download from ffmpeg.org
  - Mac: `brew install ffmpeg`
  - Linux: `sudo apt install ffmpeg`

### "ImportError: No module named 'PIL'"

**Problem:** Python can't find image processing library.

**Solution:**
```bash
pip install -r requirements.txt
```

### "No suitable media found" / "Not enough media"

**Problem:** Tool can't find enough matching images for a full mod.

**Solution:**
1. Add more images to `./input/` (need at least 6)
2. Use varied aspect ratios (mix landscape and portrait)
3. Increase tolerance:
   ```bash
   python scripts/generate_mods.py --tolerance 10
   ```

### Images look weird in game

**Problem:** Posters appear stretched/squished.

**Solution:**
- This usually happens with very unusual aspect ratios
- Try increasing tolerance: `--tolerance 10`
- Crop your source images to standard ratios (16:9, 4:3, etc.)

### Need more help?

1. Check `README.md` for technical details
2. Check `QUICKSTART.md` for quick reference
3. Open an issue: https://github.com/bikininjas/lc_bikininjaPostersModGenerator/issues

---

## Advanced: Running in GitHub Actions

Once you're comfortable locally, you can **automate everything**:

1. Fork this repo to your GitHub account
2. Add your media to `input/` folder
3. Set up Thunderstore API key (optional, for auto-publishing)
4. Push to GitHub → **Workflow runs automatically** → **Mods published!**

See `.github/workflows/` for details.

---

## Cheat Sheet

### Quick Commands

```bash
# Generate mods (auto-detects your OS)
bash generate_mods.sh          # Mac/Linux
powershell -ExecutionPolicy Bypass -File generate_mods.ps1  # Windows

# Custom input/output paths
bash generate_mods.sh --input ~/Pictures --output ./my_mods

# Increase aspect ratio tolerance
bash generate_mods.sh --tolerance 10

# Use Python directly
python scripts/generate_mods.py --input ./input --output ./mods --build ./build

# Reset versions (start from v0.0.1)
rm mods/versions.json
bash generate_mods.sh
```

### Folder Structure

```
lc_bikininjaPostersModGenerator/
├── input/                          ← PUT YOUR FILES HERE
├── mods/                           ← Generated mod folders
├── build/                          ← Generated .zip files
├── scripts/
│   └── generate_mods.py           ← Main Python script
├── src/
│   ├── media_processor.py         ← Image/video handling
│   └── mod_generator.py           ← Mod creation
├── generate_mods.sh               ← Bash wrapper
├── generate_mods.ps1              ← PowerShell wrapper
├── README.md                       ← Full documentation
├── QUICKSTART.md                  ← Quick reference
└── STEP_BY_STEP_GUIDE.md         ← This file!
```

---

## Summary

You now know how to:
1. ✅ Set up the tool
2. ✅ Prepare your media
3. ✅ Generate mods locally
4. ✅ Test your mods
5. ✅ Upload to Thunderstore
6. ✅ Troubleshoot common issues

**Next:** Copy your images to `./input/` and run `bash generate_mods.sh`!

**Questions?** Read QUICKSTART.md or README.md for more details.

---

**Happy modding! 🎮📸🚀**
