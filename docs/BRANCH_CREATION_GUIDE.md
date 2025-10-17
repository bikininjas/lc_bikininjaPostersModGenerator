# Branch Creation Safety Scripts

These scripts prevent accidentally committing mod packs to `master` by checking that mods have been generated before creating a new branch.

## Overview

**Problem:** Accidentally running `git checkout -b feature/...` on master without generating mods first could lead to committing incomplete changes.

**Solution:** Two helper scripts that:
1. ✅ Check if mod packs exist in `./build/` and `./mods/`
2. ✅ Only create a branch if at least one mod pack was found
3. ✅ Warn and exit if no mods are found

## Workflow

### Typical Workflow (Recommended)

```bash
# Step 1: Generate mods
bash generate_mods.sh

# Step 2: Mods created? Create branch automatically
bash scripts/create_branch_from_mods.sh feature/my-new-posters

# Step 3: Commit your changes
git add .
git commit -m "feat: add new poster packs"

# Step 4: Push to GitHub
git push origin feature/my-new-posters

# Step 5: Auto-PR workflow creates PR automatically!
```

---

## Scripts

### 1. `scripts/create_branch_from_mods.sh` (Linux/Mac)

**Purpose:** Create a branch ONLY if mod packs exist (bash version)

**Usage:**
```bash
bash scripts/create_branch_from_mods.sh [branch_prefix]
```

**Parameters:**
- `branch_prefix` (optional): Branch name to create (default: `feature/new-mods`)

**Examples:**

```bash
# Create with default name
bash scripts/create_branch_from_mods.sh
# → Creates: feature/new-mods

# Create with custom name
bash scripts/create_branch_from_mods.sh feature/my-posters
# → Creates: feature/my-posters

# Create with descriptive name
bash scripts/create_branch_from_mods.sh feature/landscape-photos-2025
# → Creates: feature/landscape-photos-2025
```

**Behavior:**

✅ **If mods found:**
```
Checking for generated mod packs...
  Archives in ./build: 2
  Folders in ./mods: 2
✓ Found mod packs!
Created and switched to branch: feature/my-posters
```

❌ **If no mods found:**
```
Checking for generated mod packs...
  Archives in ./build: 0
  Folders in ./mods: 0
✗ No mod packs found!
Before creating a branch, you need to:
  1. Add media files to ./input/
  2. Run the generator: bash generate_mods.sh
  3. Check that .zip files appear in ./build/
  4. Then run this script again
```

---

### 2. `scripts/create_branch_from_mods.ps1` (Windows)

**Purpose:** Create a branch ONLY if mod packs exist (PowerShell version)

**Usage:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/create_branch_from_mods.ps1 [branch_prefix]
```

**Parameters:**
- `branch_prefix` (optional): Branch name to create (default: `feature/new-mods`)

**Examples:**

```powershell
# Create with default name
powershell -ExecutionPolicy Bypass -File scripts/create_branch_from_mods.ps1
# → Creates: feature/new-mods

# Create with custom name
powershell -ExecutionPolicy Bypass -File scripts/create_branch_from_mods.ps1 "feature/my-posters"
# → Creates: feature/my-posters
```

**Behavior:** Same as bash version (checks for mods before creating branch)

---

## Safety Features

### 1. **Prevents Empty Commits**
The scripts check for:
- `.zip` archives in `./build/` (generated mods)
- Mod folders in `./mods/` (mod structure)

If neither exists, they refuse to create a branch.

### 2. **Warns About Wrong Branch**
If you're not on `master`, the script warns:
```
⚠ Warning: Currently on branch 'feature/other'
Continue creating branch 'feature/my-posters'? (y/n)
```

### 3. **Handles Existing Branches**
If the branch already exists:
```
⚠ Branch 'feature/my-posters' already exists!
Switch to existing branch? (y/n)
```

---

## Integration with Workflows

These scripts work seamlessly with the project's auto-PR workflow:

```
1. Generate mods
   bash generate_mods.sh
        ↓
2. Create branch (only if mods exist)
   bash scripts/create_branch_from_mods.sh feature/my-posters
        ↓
3. Commit changes
   git add . && git commit -m "feat: add new poster packs"
        ↓
4. Push to GitHub
   git push origin feature/my-posters
        ↓
5. Auto-PR workflow triggers automatically!
   → Creates PR with auto-PR workflow
   → Requests Copilot review
   → Sets proper labels
   → Notifies in comments
```

---

## Common Scenarios

### Scenario 1: Fresh Start

```bash
# 1. Add images
cp my-photos/*.jpg input/

# 2. Generate mods
bash generate_mods.sh

# 3. Create branch safely
bash scripts/create_branch_from_mods.sh feature/my-photos

# 4. Commit and push
git add .
git commit -m "feat: add photo collection"
git push origin feature/my-photos
```

### Scenario 2: Multiple Batches

```bash
# First batch
cp batch1/*.jpg input/
bash generate_mods.sh
bash scripts/create_branch_from_mods.sh feature/batch-1
git add . && git commit -m "feat: batch 1"
git push origin feature/batch-1
# → PR created automatically

# Wait for merge...

# Second batch (back on master)
git checkout master
git pull
cp batch2/*.jpg input/
bash generate_mods.sh
bash scripts/create_branch_from_mods.sh feature/batch-2
git add . && git commit -m "feat: batch 2"
git push origin feature/batch-2
# → PR created automatically
```

### Scenario 3: Testing Before Committing

```bash
# Generate mods
bash generate_mods.sh

# Test the .zip files locally
unzip build/BikininjaPosters01-v0.0.1.zip -d ~/test-install/

# Looks good? Create branch
bash scripts/create_branch_from_mods.sh feature/tested-posters

# Otherwise, regenerate with different settings
bash generate_mods.sh --tolerance 10
bash scripts/create_branch_from_mods.sh feature/tested-posters
```

---

## Troubleshooting

### Error: "No mod packs found!"

**Cause:** You forgot to run the generator first.

**Solution:**
```bash
# Step 1: Add media
cp my-images/*.jpg input/

# Step 2: Generate
bash generate_mods.sh

# Step 3: Try again
bash scripts/create_branch_from_mods.sh feature/my-branch
```

### Error: "Branch already exists"

**Cause:** Branch was already created.

**Options:**
1. Switch to existing branch:
   ```bash
   git checkout feature/my-branch
   ```

2. Create with different name:
   ```bash
   bash scripts/create_branch_from_mods.sh feature/my-branch-v2
   ```

3. Delete and recreate:
   ```bash
   git branch -D feature/my-branch
   bash scripts/create_branch_from_mods.sh feature/my-branch
   ```

### Script doesn't run (bash)

**Problem:** Permission denied

**Solution:**
```bash
chmod +x scripts/create_branch_from_mods.sh
bash scripts/create_branch_from_mods.sh feature/my-branch
```

### Script doesn't run (PowerShell)

**Problem:** ExecutionPolicy error

**Solution:** Make sure you use `-ExecutionPolicy Bypass`:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/create_branch_from_mods.ps1 "feature/my-branch"
```

---

## Best Practices

✅ **Do:**
- Run `bash generate_mods.sh` BEFORE creating a branch
- Use descriptive branch names: `feature/landscape-photos-2025`
- Test mods locally before committing
- Push immediately after committing (triggers auto-PR)

❌ **Don't:**
- Manually `git checkout -b` on master without running the generator
- Commit without reviewing the generated `./mods/` folder
- Push to master directly (use branches + PR workflow)
- Modify `mods/versions.json` manually (it auto-increments)

---

## Summary

These scripts are a **safety feature** to enforce the recommended workflow:

```
master (clean)
    ↓
generate mods
    ↓
create branch (ONLY if mods exist)
    ↓
commit changes
    ↓
push to GitHub
    ↓
auto-PR workflow creates PR
    ↓
review & merge
```

**By enforcing this workflow, you prevent:**
- Empty commits on master
- Accidental master modifications
- Incomplete mod packages
- Workflow conflicts

🎯 **Use these scripts and your workflow stays clean and organized!**
