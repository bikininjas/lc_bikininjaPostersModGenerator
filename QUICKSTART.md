# Quick Start Guide

Get up and running with the BikininjaPosters Mod Generator in **3 simple steps**.

**⏱️ Time needed:** 5 minutes (assuming Python & FFmpeg are installed)

## What Does This Do?

This tool automatically creates multiple **Thunderstore mod packs** for CustomPosters (Lethal Company). It:
- 📷 Finds images and videos in your `input/` folder
- 🎯 Assigns them intelligently to 6 poster slots per mod (5 posters + 1 tip)
- 📦 Generates ready-to-upload mod archives
- 🚀 Publishes to Thunderstore via GitHub Actions (optional)

**👉 First time?** Read [STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md) for complete setup instructions including Python & FFmpeg installation.

---

## 3-Step Quick Start

### Step 1: Add Your Media

Copy your **images and videos** into the `input/` folder:

```bash
cp /path/to/images/*.jpg input/
cp /path/to/videos/*.mp4 input/
```

**Supported formats:**
- Images: `.png`, `.jpg`, `.jpeg`, `.bmp`, `.webp`, `.avif`
- Videos: `.mp4`

### Step 2: Run the Generator

**Linux/Mac:**
```bash
./generate_mods.sh
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File generate_mods.ps1
```

**Python (any OS):**
```bash
python scripts/generate_mods.py --input ./input --output ./mods --build ./build
```

### Step 3: Upload Archives

Your mod archives are ready in the `build/` folder:

```bash
ls build/
# BikininjaPosters01-v0.0.1.zip
# BikininjaPosters02-v0.0.1.zip
# ...
```

Upload these `.zip` files to [Thunderstore.io](https://thunderstore.io).

---

## Understanding the Output

After running the generator, you'll have:

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
│   └── BepInEx/plugins/BikininjasPosters02/CustomPosters/ ...
└── versions.json              # Version tracking (auto-managed)

build/
├── BikininjaPosters01-v0.0.1.zip
├── BikininjaPosters02-v0.0.1.zip
└── ...
```

The `versions.json` file tracks:
- **Version numbers** for each mod (auto-incremented on changes)
- **Media usage** (ensures no images used in 2+ mods)

---

## Common Questions

### Q: How many images do I need?
**A:** At least **6 images per mod pack** you want to create. The tool creates as many packs as it can from your media.

Example:
- 12 images → 2 mods
- 24 images → 4 mods
- 30 images → 5 mods

### Q: Can I mix images and videos?
**A:** Yes! Videos are preferred (1 per mod recommended), but image-only packs work too. The generator intelligently selects the best-fit media for each poster based on **aspect ratio**.

### Q: What if it fails?
**A:** Check these common issues:

| Error | Solution |
|-------|----------|
| `No media files found` | Add images/videos to `input/` folder |
| `Python not found` | Install [Python 3.10+](https://www.python.org/downloads/) |
| `FFmpeg not found` | Install [FFmpeg](https://ffmpeg.org/download.html) (video processing) |
| `PIL import error` | Run `pip install -r requirements.txt` |
| `No suitable media found` | Increase tolerance: `--tolerance 10` (default: 5%) |

### Q: How do I change the tolerance?
The generator matches images to poster dimensions with a **5% aspect ratio tolerance** by default.

Increase it if you get "no suitable media" errors:

**Linux/Mac:**
```bash
./generate_mods.sh --tolerance 10
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File generate_mods.ps1 -Tolerance 10
```

**Python:**
```bash
python scripts/generate_mods.py --tolerance 10
```

### Q: Can I run this in GitHub Actions?
**A:** Yes! Push this repo to GitHub and set up the workflow:

1. Create org secret: `THUNDERSTORE_SVC_API_KEY` (get from Thunderstore)
2. Add media to `input/` folder
3. Push to main branch → GitHub Actions auto-publishes to Thunderstore

See `.github/workflows/build-and-release.yml` for details.

### Q: Can I manually edit generated mods?
**A:** Sure! The mod structure in `mods/BikininjaPostersXY/` is a standard Lethal Company BepInEx plugin directory. Edit files freely, but next time you run the generator, it will **regenerate** based on your input media.

### Q: How do I reset and start fresh?
**A:** Delete the tracking file and regenerate:

```bash
rm mods/versions.json
./generate_mods.sh  # or your shell wrapper
```

⚠️ This will reset version numbers (back to 0.0.1) and allow media reuse.

---

## Advanced: Custom Directories

Run with custom input/output paths:

**Linux/Mac:**
```bash
./generate_mods.sh --input /path/to/images --output ./my_mods --build ./my_build
```

**Windows:**
```powershell
./generate_mods.ps1 -Input "C:\images" -Output ".\my_mods" -Build ".\my_build"
```

**Python:**
```bash
python scripts/generate_mods.py \
  --input /path/to/images \
  --output ./my_mods \
  --build ./my_build
```

---

## Need Help?

- 📖 Full documentation: See `README.md`
- 🛠️ Technical details: See `.github/copilot-instructions.md`
- 🐛 Bug report: Open an issue on GitHub
- 💬 Questions: Check the FAQ section above

---

**Happy modding! 🚀**
