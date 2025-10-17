# BikininjaPosters Mod Generator

**Automated Thunderstore mod generator for CustomPosters (Lethal Company).**

Create professional mod packs from media files with intelligent aspect ratio matching, automatic versioning, and direct Thunderstore publishing.

---

## 🚀 Quick Start

**3 steps to generate mods:**

1. **Place media** in `./input/` folder (.jpg, .png, .bmp, .mp4, or .webp)
2. **Run the generator** (Linux/Mac or Windows):
   ```bash
   # Linux/Mac
   bash generate_mods.sh
   
   # Windows PowerShell
   powershell -ExecutionPolicy Bypass -File generate_mods.ps1
   ```
3. **Get output** in `./build/` (mod archives) and `./mods/` (full structures)

For detailed beginner instructions, see **[QUICKSTART.md](QUICKSTART.md)**.

---

## 🤖 Automated CI/CD & Publishing

**Zero-touch workflow** from PR to Thunderstore publication:

1. **Create PR** with media changes or code updates
2. **CI checks** validate code quality & conventional commits
3. **Auto-merge** CI/CD-only PRs (with `ci-cd` label)
4. **Generate mods** automatically on merge to master
5. **Create releases** with auto-incremented versions (v1.0.0 → v1.0.1)
6. **Publish to Thunderstore** each mod independently

See **[CICD_GUIDE.md](CICD_GUIDE.md)** for complete setup and workflow details.

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
| **No media found** | Ensure files are in `./input/` with supported extensions |
| **"Not enough media"** | Need 6+ files for 1 mod. Add more to `./input/` |
| **Format not supported** | Supported: .jpg, .png, .bmp, .webp, .avif, .mp4 |
| **FFmpeg errors** | Install: `sudo apt install ffmpeg` (Linux) or `brew install ffmpeg` (Mac) |

---

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

### Media Processor API
```python
from src.media_processor import MediaProcessor

proc = MediaProcessor('./input', tolerance_percent=5)
media_list = proc.discover_media()

for media in media_list:
    print(f"{media.file_path}: {media.aspect_ratio:.2f}")
```

### Mod Generator API
```python
from src.mod_generator import ModGenerator, ModConfig

gen = ModGenerator('./mods')
config = ModConfig(mod_number=1, version='0.0.1')
gen.create_mod_structure(config, media_dict)
gen.create_mod_archive(config, './build')
```

### Adding Features
- **Media processing**: Modify `src/media_processor.py`
- **Mod creation**: Modify `src/mod_generator.py`
- **CLI options**: Modify `scripts/generate_mods.py`
- **Workflows**: Edit `.github/workflows/build-and-release.yml`

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
