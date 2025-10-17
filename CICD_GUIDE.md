# CI/CD & Automated Release System

Complete automated workflow for generating mods, creating releases, and publishing to Thunderstore **without human intervention**.

---

## 📋 System Overview

```
┌─────────────────┐
│  PR Submitted   │
└────────┬────────┘
         │
         ▼
┌──────────────────────────┐
│  CI Checks (lint, test)  │
└────────┬─────────────────┘
         │
    ┌────┴────┐
    │          │
    ▼          ▼
 ✅ Pass   ❌ Fail
    │          │
    │         (Blocked)
    ▼
┌──────────────────────────────┐
│  Check for 'ci-cd' label     │
└────────┬─────────────────────┘
         │
    ┌────┴────────────────────┐
    │                         │
    ▼                         ▼
Has 'ci-cd'              No 'ci-cd'
    │                         │
    ▼                         ▼
Auto-Merge          Manual Merge Required
(Squash)            (Create Release)
    │                         │
    └────────┬────────────────┘
             │
             ▼
    ┌────────────────────┐
    │  Merged to Master  │
    └────────┬───────────┘
             │
             ▼
    ┌──────────────────────────────────┐
    │  Generate Mods & Create Release  │
    │  (Auto-increment version v1.0.0) │
    └────────┬─────────────────────────┘
             │
             ▼
    ┌──────────────────────────────────┐
    │  Create Git Tags (per mod)       │
    │  BikininjaPostersXX-vX.X.X       │
    └────────┬─────────────────────────┘
             │
             ▼
    ┌──────────────────────────────────┐
    │  Create GitHub Releases (per mod)│
    │  Attach .zip artifacts           │
    └────────┬─────────────────────────┘
             │
             ▼
    ┌──────────────────────────────────┐
    │  Publish to Thunderstore (per mod)
    │  Uses THUNDERSTORE_SVC_API_KEY   │
    └────────┬─────────────────────────┘
             │
             ▼
    ┌──────────────────────────────────┐
    │  ✅ Mod Live on Thunderstore     │
    └──────────────────────────────────┘
```

---

## 🔄 Workflows

### 1. **CI (`.github/workflows/ci.yml`)**
Runs on every PR and push to master.

**Checks:**
- ✅ Python syntax validation
- ✅ Lint with flake8
- ✅ Type checking
- ✅ Shell script syntax
- ✅ Conventional commit format (PRs only)

**Blocks merge if:** Any check fails

---

### 2. **Auto-Merge CI/CD PRs (`.github/workflows/auto-merge-ci-cd.yml`)**
Automatically merges workflow-only PRs.

**Triggers on:** PR with `.github/workflows/**` changes

**Requirements:**
- Must have `ci-cd` label
- Must pass all CI checks
- Only `.github/workflows/` files changed

**Action:** Squash-merge + delete branch (no release created)

**Example:**
```
PR: "ci(workflows): Update Thunderstore publish action"
Labels: ci-cd
→ Auto-merged to master (no release)
```

---

### 3. **Generate & Release (`.github/workflows/generate-and-release.yml`)**
Generates mods and creates GitHub releases.

**Triggers on:**
- `push` to `master` (after PR merge)
- Manual dispatch (`workflow_dispatch`)

**Steps:**
1. Detect changed mods (via git diff)
2. Generate mod archives (`python scripts/generate_mods.py`)
3. Upload artifacts (available 30 days)
4. **For each changed mod (in sequence):**
   - Read current version from `mods/versions.json`
   - Increment patch (v1.0.0 → v1.0.1)
   - Create git tag: `BikininjaPostersXX-vX.X.X`
   - Create GitHub Release (with ZIP attached)
   - Commit version update

**Output:**
- Git tags: `BikininjaPosters01-v1.0.0`, `BikininjaPosters02-v1.0.1`, etc.
- GitHub Releases (one per mod)
- Updated `mods/versions.json`

---

### 4. **Publish to Thunderstore (`.github/workflows/publish-thunderstore.yml`)**
Publishes each mod to Thunderstore automatically.

**Triggers on:** GitHub Release `published`

**Steps:**
1. Extract mod name & version from tag (e.g., `BikininjaPosters01-v1.0.0`)
2. Download ZIP from release assets
3. Validate mod structure
4. Upload to Thunderstore API
   - Uses `THUNDERSTORE_SVC_API_KEY` secret
   - Namespace: `Bikininjas`
   - Mod name: extracted from tag
5. Verify upload on Thunderstore

**Output:** Mod live on Thunderstore

---

## 🏷️ Labels

### `ci-cd`
Use this label for workflow-only PRs.

**Effect:** PR will auto-merge without creating a release.

**Example use cases:**
- Update GitHub Actions
- Fix CI/CD configuration
- Update workflow secrets

**Apply label:** When creating PR or use `/label ci-cd` comment

---

## 📝 Version Management

### Starting Version
First release of each mod: **`v1.0.0`**

### Auto-Increment
Each time a mod changes:
- Patch version increments: `v1.0.0` → `v1.0.1` → `v1.0.2`
- Manual version bumps coming soon (minor/major)

### Storage
Versions stored in `mods/versions.json`:
```json
{
  "versions": {
    "BikininjaPosters01": "v1.0.2",
    "BikininjaPosters02": "v1.0.0",
    "BikininjaPosters03": "v1.0.1"
  },
  "used_media": [...]
}
```

---

## 🔑 Required Secrets

### Organization Secrets (set once)

**`THUNDERSTORE_SVC_API_KEY`**
- Get from: https://thunderstore.io/api-keys/
- Scope: Must have write access to `Bikininjas` namespace
- Used by: `publish-thunderstore.yml`

**Setup:**
1. Go to GitHub org settings → Secrets and variables → Actions
2. Create new org secret `THUNDERSTORE_SVC_API_KEY`
3. Paste API key value

---

## 📊 Workflow Triggers

| Workflow | Trigger | Condition |
|----------|---------|-----------|
| **ci.yml** | PR + push to master | Always runs |
| **auto-merge-ci-cd.yml** | PR with `.github/workflows/**` changes | Must have `ci-cd` label |
| **generate-and-release.yml** | Push to master + manual | After PR merge or manual trigger |
| **publish-thunderstore.yml** | Release published | Automatically after release creation |

---

## 🚀 Usage Examples

### Example 1: Add New Media to Mod
```bash
# 1. Create feature branch
git checkout -b feature/add-new-posters

# 2. Add images to input/
cp new-posters/*.jpg input/

# 3. Commit with conventional message
git commit -m "feat: add 5 new poster images"

# 4. Create PR (no label)
gh pr create --title "Add new poster images" --body "..."

# 5. PR passes CI checks
# 6. You merge PR to master (manual)
# 7. Workflow automatically:
#    → Detects input/ changed
#    → Generates mods
#    → Creates releases (v1.0.1, v1.0.2, etc)
#    → Publishes to Thunderstore
#    → All mods live! ✅
```

### Example 2: Update GitHub Actions
```bash
# 1. Create feature branch
git checkout -b feature/update-ci

# 2. Edit .github/workflows/
nano .github/workflows/publish-thunderstore.yml

# 3. Commit with conventional message
git commit -m "ci: improve error handling in publish workflow"

# 4. Create PR with 'ci-cd' label
gh pr create --title "Improve CI/CD" --label ci-cd

# 5. PR passes CI checks
# 6. Workflow AUTOMATICALLY merges (no manual action)
# 7. Updated workflow live on master ✓
#    (No release created, no Thunderstore publish)
```

### Example 3: Manual Release Trigger
```bash
# To manually trigger generation (optional):
gh workflow run generate-and-release.yml -r master

# Workflow will:
# → Generate all mods
# → Create releases for ANY changed mod
# → Publish to Thunderstore
```

---

## ⚙️ Configuration Files

### `mods/versions.json`
Tracks versions and used media.

**Auto-updated by:** `generate-and-release.yml`
**Format:**
```json
{
  "versions": {
    "ModName": "vX.X.X"
  },
  "used_media": [
    "input/file1.jpg",
    "input/file2.mp4"
  ]
}
```

### `.gitignore`
Must include:
```
mods/versions.json  # Will be auto-updated and pushed
build/              # Temporary artifacts
```

---

## 📋 Checklist: Setting Up CI/CD

- [ ] Create org secret `THUNDERSTORE_SVC_API_KEY`
- [ ] Update `mods/versions.json` initial values
- [ ] Commit `.github/workflows/*.yml` to master
- [ ] Create initial release manually (or push changes)
- [ ] Verify first mod publishes to Thunderstore
- [ ] Document in team Slack/Wiki

---

## 🐛 Troubleshooting

### PR doesn't auto-merge with `ci-cd` label
- Check: PR has `ci-cd` label ✓
- Check: Only `.github/workflows/**` files changed ✓
- Check: CI checks passing ✓
- Manual merge fallback: Yes (merge button works)

### Release not creating
- Check: `mods/versions.json` exists ✓
- Check: Version format is `vX.X.X` ✓
- Check: Git user configured in workflow ✓

### Thunderstore publish failing
- Check: `THUNDERSTORE_SVC_API_KEY` secret set ✓
- Check: API key has correct permissions ✓
- Check: Mod namespace is `Bikininjas` ✓
- Check: ZIP file in release asset ✓

---

## 📞 Support

For issues:
1. Check workflow logs: Actions → Workflow → View logs
2. Verify secrets are set correctly
3. Test manually: `gh workflow run generate-and-release.yml`

---

**Zero-intervention CI/CD pipeline complete!** 🚀
