<!-- Copilot instructions for lc_bikininjaPostersModGenerator -->
# Repository summary
This repository generates and publishes multiple Thunderstore mods for CustomPosters (Lethal Company).
The generator intelligently processes media files (images and videos), assigns them to 6 poster slots per mod (5 posters + 1 tip), 
and automates publishing via GitHub Actions + Thunderstore API.

# Your role
You are an AI coding assistant expert in Python, image/video processing (Pillow, OpenCV, FFmpeg), and GitHub Actions CI/CD.
You maintain and extend the codebase following the project's specific patterns for media processing and mod generation.

# Core components (key files to understand)
- `src/media_processor.py`: Analyzes aspect ratios, selects best-fit media, crops then resizes (crop-first strategy)
- `src/mod_generator.py`: Manages mod structure, version tracking per mod, media uniqueness enforcement
- `scripts/generate_mods.py`: CLI orchestrator—runs media discovery, assigns 6 media per mod (with ≥1 video), creates archives
- `.github/workflows/build-and-release.yml`: Triggers generator, creates releases, publishes each mod to Thunderstore (one per job via matrix strategy)
- `mods/versions.json`: Tracks semantic version per mod (e.g., BikininjaPosters01 = "0.0.5")

# Critical workflows & patterns
1. **Media assignment**: Smart selection based on aspect ratio fit (tolerance ±5% default); ensures 1 video + 5 others per mod
2. **Crop-first resizing**: Crop media to match target ratio → resize to exact dimensions (no letterboxing)
3. **Version management**: Each mod increments independently; stored in `mods/versions.json`
4. **Uniqueness**: All media used across all mods are tracked; no duplication across packs
5. **Folder structure**: Generated mod at `mods/BikininjaPostersXY/BepInEx/plugins/BikininjasPostersXY/CustomPosters/{posters,tips}/`
6. **Publishing**: Thunderstore upload via `GreenTF/upload-thunderstore-package@v4.3` action with org secret `THUNDERSTORE_SVC_API_KEY`

# Code patterns & conventions
- Input media in `./input/` (supported: `.png`, `.jpg`, `.jpeg`, `.bmp`, `.mp4`)
- Generated mods in `./mods/` (one folder per BikininjaPostersXY)
- Zip archives in `./build/` (named `BikininjaPostersXY-vA.B.C.zip`)
- Poster dimensions stored in `POSTER_SPECS` dict in media_processor.py
- Use `MediaInfo` class for file analysis; `ModConfig` for mod metadata
- CLI accepts `--tolerance`, `--input`, `--output`, `--build` flags; reads env vars `POSTER_*_DIR`

# Testing & validation
- Run locally: `python scripts/generate_mods.py --input ./input --output ./mods --build ./build`
- Validate media discovery: Check media aspect ratios match targets (±tolerance)
- Check uniqueness: Verify no file appears in 2+ mods by inspecting `mods/*/BepInEx/.../posters/*.* and tips/*.*`
- Test workflows: Use `gh workflow run` to trigger manually before committing

# Integration points & secrets
- **Thunderstore API**: Uses org secret `THUNDERSTORE_SVC_API_KEY` (set in org secrets, not repo)
- **FFmpeg**: Must be installed on CI runner; GitHub Actions Ubuntu runner includes it
- **Releases**: GitHub Releases created automatically with zip archives attached
- **Matrix strategy**: `.github/workflows/build-and-release.yml` publishes mods in sequence (max-parallel: 1) to avoid rate limits

# When adding features
- Keep media processing logic in `src/media_processor.py` (aspect ratio, cropping, format conversion)
- Keep mod structure logic in `src/mod_generator.py` (versioning, directory creation)
- Update CLI in `scripts/generate_mods.py` to expose new options
- Update `pyproject.toml` and `requirements.txt` if adding dependencies
- Document new flags/env vars in `README.md` Quick Start section
- Update `.github/copilot-instructions.md` if patterns change

# Safety & scope
- Never hardcode API tokens; always use secrets (org or repo)
- Don't commit `mods/`, `build/`, or `input/` folders (add to `.gitignore` if not present)
- Version increments happen automatically; don't manually edit `mods/versions.json` in PRs
- Test FFmpeg calls locally before merging (video processing is CPU-intensive)

-- End of instructions --
