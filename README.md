# BikininjaPosters Mod Generator

**Automated Thunderstore mod generator for CustomPosters (Lethal Company).**

Create professional mod packs from media files with intelligent aspect ratio matching, automatic versioning, and direct Thunderstore publishing.

---

## � Documentation Guide

Choose your path:

| Path | For Whom | Time |
|------|----------|------|
| **[STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md)** | 🆕 Absolute beginners, step-by-step everything | 10 min read |
| **[QUICKSTART.md](QUICKSTART.md)** | ⚡ Just want to get started quickly | 3 min read |
| **[README.md](README.md)** | 🔧 Technical details & advanced usage | Reference |

---

## 🚀 Quick Start (3 Steps)

**Don't have time? Start here:**

1. **Add media** to `./input/` folder (.jpg, .png, .bmp, .mp4, .webp, or .avif)
2. **Run the generator** (pick one):
   ```bash
   # Linux/Mac
   bash generate_mods.sh
   
   # Windows PowerShell
   powershell -ExecutionPolicy Bypass -File generate_mods.ps1
   ```
3. **Get output** in `./build/` (ready-to-upload `.zip` files)

👉 **First time?** Read **[STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md)** instead!

---

## 📋 What Gets Generated

Each mod pack contains a BepInEx structure:
```
BikininjaPosters01/
  BepInEx/plugins/BikininjasPosters01/CustomPosters/
    posters/
      Poster1.png (639×488)
      Poster2.png (730×490)
      Poster3.png (749×1054)
      Poster4.png (729×999)
      Poster5.png (552×769)
    tips/
      CustomTips.png (860×1219)
```

Archive: `BikininjaPosters01-v0.0.1.zip` → Ready for Thunderstore

---

## 🤖 Automated CI/CD & Publishing

**Zero-touch workflow** from PR to Thunderstore publication:

1. **Create PR** with media changes or code updates
2. **CI checks** validate code quality
3. **Auto-merge** CI/CD-only PRs (with `ci-cd` label)
4. **Generate mods** automatically on merge to master
5. **Create releases** with auto-incremented versions (v1.0.0 → v1.0.1)
6. **Publish to Thunderstore** each mod independently

See **[QUICKSTART.md](QUICKSTART.md)** for complete setup and workflow details.

---

## ✨ Features

- **Smart Media Selection**: Analyzes aspect ratios, automatically assigns best-fit media to each poster
- **Crop-First Resizing**: No letterboxing—crops to ratio, then resizes precisely
- **Multiple Mods**: Creates as many packs as possible (6 unique media per mod: 5 posters + 1 tip)
- **Version Tracking**: Independent versioning per mod (auto-increments)
- **Media Uniqueness**: Guarantees no file used in multiple mods
- **Easy Publishing**: Generate → Archive → Ready for GitHub/Thunderstore
- **Format Support**: .jpg, .png, .bmp, .webp, .avif, .mp4

---

## 📋 What Gets Generated

Each mod pack contains a BepInEx structure:
```
BikininjaPosters01/
  BepInEx/plugins/BikininjasPosters01/CustomPosters/
    posters/
      Poster1.png (639×488)
      Poster2.png (730×490)
      Poster3.png (749×1054)
      Poster4.png (729×999)
      Poster5.png (552×769)
    tips/
      CustomTips.png (860×1219)
```

Archive: `BikininjaPosters01-v0.0.1.zip` → Ready for Thunderstore

---

## 🔧 Advanced Usage

### Command-Line Options
```bash
python scripts/generate_mods.py \
  --input ./input \
  --output ./mods \
  --build ./build \
  --tolerance 5
```

| Option | Default | Purpose |
|--------|---------|---------|
| `--input` | ./input | Source media folder |
| `--output` | ./mods | Generated mods folder |
| `--build` | ./build | Output archives folder |
| `--tolerance` | 5 | Aspect ratio tolerance (%) |

### Environment Variables
```bash
export POSTER_INPUT_DIR=./input
export POSTER_OUTPUT_DIR=./mods
export POSTER_BUILD_DIR=./build
python scripts/generate_mods.py
```

---

## 📁 Version Tracking

Versions auto-track in `mods/versions.json`:
```json
{
  "BikininjaPosters01": "0.0.2",
  "BikininjaPosters02": "0.0.1"
}
```

Each new generation increments patch version (0.0.1 → 0.0.2).

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| **No media found** | Ensure files are in `./input/` with supported extensions (.jpg, .png, .bmp, .webp, .avif, .mp4) |
| **"Not enough media"** | Need 6+ files for 1 mod. Add more to `./input/` |
| **Python not found** | Install from https://www.python.org/downloads/ and check "Add to PATH" |
| **FFmpeg errors** | Install: `apt install ffmpeg` (Linux), `brew install ffmpeg` (Mac), or `choco install ffmpeg` (Windows) |
| **"PIL import error"** | Run `pip install -r requirements.txt` |
| **Images look stretched** | Try increasing tolerance: `--tolerance 10` or crop source images to standard ratios |
| **"No suitable media found"** | Add more varied aspect ratios or increase tolerance |

👉 **Full troubleshooting guide**: See [STEP_BY_STEP_GUIDE.md#troubleshooting](STEP_BY_STEP_GUIDE.md#troubleshooting)

---

## 📦 Requirements

- Python 3.10+
- Pillow, opencv-python (auto-installed or run `pip install -r requirements.txt`)
- FFmpeg (optional, required only for video processing)

---

## 🔐 GitHub Actions & Thunderstore

1. **Set org secret**: `THUNDERSTORE_SVC_API_KEY` in GitHub organization settings
2. **Trigger workflow**: Push to repo or manually run workflows
3. **Automatic publishing**: Mods are published to Thunderstore on release

See `.github/workflows/` for implementation details.

---

## 📄 License & Attribution

Built for CustomPosters mod (Lethal Company). See repository for license details.


## 🏗️ Architecture

| Component | Purpose |
|-----------|---------|
| `src/media_processor.py` | Aspect ratio analysis, crop/resize logic |
| `src/mod_generator.py` | Mod structure creation, versioning |
| `scripts/generate_mods.py` | CLI entry point |
| `generate_mods.sh` | Linux/Mac wrapper |
| `generate_mods.ps1` | Windows PowerShell wrapper |
| `.github/workflows/` | GitHub Actions for Thunderstore publishing |

---

## 📚 For Developers

### Architecture & Components

| Component | Purpose |
|-----------|---------|
| `src/media_processor.py` | Aspect ratio analysis, crop/resize logic (Pillow, OpenCV) |
| `src/mod_generator.py` | Mod structure creation, versioning, archive generation |
| `scripts/generate_mods.py` | CLI entry point with argument parsing |
| `generate_mods.sh` | Linux/Mac bash wrapper (auto-detects Python/dependencies) |
| `generate_mods.ps1` | Windows PowerShell wrapper (auto-detects dependencies) |
| `.github/workflows/` | GitHub Actions for CI/CD and Thunderstore publishing |
| `mods/versions.json` | Automatic version tracking per mod (semantic versioning) |

### Media Processing Pipeline

1. **Discovery**: Scan `input/` for supported formats (.jpg, .png, .bmp, .webp, .avif, .mp4)
2. **Analysis**: Calculate aspect ratio for each file
3. **Grouping**: Organize files into sets of 6 (ensuring 1+ video per set)
4. **Matching**: Assign files to poster slots based on aspect ratio (±5% tolerance by default)
5. **Processing**: Crop to target ratio → Resize to exact dimensions (no letterboxing)
6. **Archiving**: Package mods into `.zip` with BepInEx structure

### API Examples

#### Using MediaProcessor

```python
from src.media_processor import MediaProcessor

# Create processor
proc = MediaProcessor(
    input_dir='./input',
    tolerance_percent=5
)

# Discover and analyze media
media_list = proc.discover_media()
for media in media_list:
    print(f"{media.file_path}: {media.aspect_ratio:.2f}")

# Select best-fit media for a specific ratio
best_match = proc.select_best_media(
    target_ratio=1.3,
    exclude_files=[...],
    allow_video=False
)
```

#### Using ModGenerator

```python
from src.mod_generator import ModGenerator, ModConfig

# Create generator
gen = ModGenerator(output_dir='./mods')

# Create mod structure
config = ModConfig(
    mod_number=1,
    version='0.0.1',
    mod_name='BikininjaPosters01'
)
gen.create_mod_structure(
    config=config,
    media_dict={
        'Poster1': 'input/image1.jpg',
        'Poster2': 'input/image2.jpg',
        # ...
        'CustomTips': 'input/tip.jpg'
    }
)

# Create archive
gen.create_mod_archive(config, archive_dir='./build')
```

### Extending the Project

#### Adding a New Media Format

1. Update `src/media_processor.py`:
   ```python
   SUPPORTED_FORMATS = {'.jpg', '.png', '.bmp', '.webp', '.avif', '.mp4', '.your_format'}
   ```

2. Add format handling in `_process_file()` method

#### Adding Version Management Features

Edit `src/mod_generator.py`:
- Modify `_load_versions()` to read from custom format
- Modify `_save_versions()` to persist changes

#### Adding CI/CD Steps

Edit `.github/workflows/build-and-release.yml`:
- Add jobs before/after mod generation
- Update action versions as needed
- Test locally with `gh workflow run` before pushing

### Best Practices

- **Media Processing**: Keep crop-first strategy; avoid letterboxing
- **Versioning**: Always use semantic versioning (MAJOR.MINOR.PATCH)
- **Uniqueness**: Never allow same file in multiple mods
- **Error Handling**: Provide clear messages for missing dependencies
- **Logging**: Use descriptive output for debugging

### Testing Locally

```bash
# Install dev dependencies
pip install -r requirements.txt

# Run with sample media
python scripts/generate_mods.py --input ./input --output ./mods --build ./build

# Run with custom tolerance
python scripts/generate_mods.py --tolerance 10

# Run with custom paths
python scripts/generate_mods.py \
  --input /path/to/images \
  --output ./my_mods \
  --build ./my_build
```

### GitHub Actions Workflow

All workflows are defined in `.github/workflows/`:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Every push | Code quality checks (flake8, pytest) |
| `auto-merge-ci-cd.yml` | PR with `ci-cd` label | Auto-merge CI/CD-only changes |
| `auto-pr-with-copilot-review.yml` | Push to feature/*, fix/*, docs/*, chore/* | Auto-create PRs with Copilot review |
| `generate-and-release.yml` | Merge to master | Generate mods & create GitHub Releases |
| `publish-thunderstore.yml` | New Release created | Publish each mod to Thunderstore |

---

## 🔐 GitHub Actions & Thunderstore

1. **Set org secret**: `THUNDERSTORE_SVC_API_KEY` in GitHub organization settings
2. **Trigger workflow**: Push to repo or manually run `build-and-release.yml`
3. **Workflow steps**:
   - Generate mods
   - Create GitHub Releases
   - Publish each to Thunderstore (one at a time)

See `.github/workflows/build-and-release.yml` for details.

---

## 📦 Requirements

- Python 3.10+
- Pillow, opencv-python (in `requirements.txt`)
- FFmpeg (install: `apt install ffmpeg` or `brew install ffmpeg`)

---

## 📄 License & Attribution

See repository for license details. Built for CustomPosters mod by SE3YA.
