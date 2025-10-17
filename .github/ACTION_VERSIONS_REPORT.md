# GitHub Actions Version Audit Report
**Date:** October 17, 2025  
**Status:** ⚠️ CRITICAL UPDATES NEEDED

## Executive Summary
Several GitHub Actions used in our CI/CD workflows are outdated and require urgent updates. The most critical issues are:
- `actions/upload-artifact@v3` → **DEPRECATED** (should upgrade to `v4.6.2`)
- `actions/download-artifact@v3` → **DEPRECATED** (should upgrade to `v4.1.9`)
- `softprops/action-gh-release@v1` → **EXTREMELY OUTDATED** (should upgrade to `v2.4.1`)

---

## Detailed Findings

###  ❌ CRITICAL: actions/upload-artifact
- **Current:** `@v3`
- **Latest:** `@v4.6.2` (March 19, 2025)
- **Status:** End-of-life, no longer maintained
- **Breaking Changes in v4:**
  - Hidden files/folders excluded by default (security improvement)
  - Use `include-hidden-files: true` if needed
- **Recommendation:** ⚠️ **UPDATE TO v4.6.2** (breaking changes manageable)

### ❌ CRITICAL: actions/download-artifact
- **Current:** `@v3`
- **Latest:** `v5.0.0` (August 5, 2024)
- **Status:** End-of-life, superseded by v4 and v5
- **Breaking Changes in v5:**
  - Path behavior changed for single artifact downloads by ID
  - By name: extraction unchanged
  - By ID: now extracts directly to path (was nested before)
- **Recommendation:** ⚠️ **UPDATE TO v4.3.0** (safer, fewer breaking changes than v5)

### ❌ CRITICAL: softprops/action-gh-release
- **Current:** `@v1` (ancient)
- **Latest:** `v2.4.1` (January 7, 2025)
- **Status:** v1 is from ~2020, severely outdated
- **Improvements in v2:**
  - Better async file handling
  - Fix for brace expansion in file globs
  - Graceful fallback to body when body_path fails
  - Race condition handling for `already_exists`
  - Recent bug fixes (last week)
- **Recommendation:** ✅ **UPDATE TO v2.4.1**

### ⚠️ MEDIUM: actions/checkout
- **Current:** `@v4`
- **Latest:** `@v5.0.0` (August 11, 2024)
- **Status:** Outdated but v4 still functional
- **Breaking Changes in v5:**
  - Requires runner v2.327.1 or later
- **Recommendation:** Consider `@v4.3.0` (stable, well-tested)

### ⚠️ MEDIUM: actions/setup-python
- **Current:** `@v4`
- **Latest:** `@v6.0.0` (September 4, 2024)
- **Status:** v5 is better choice than v6 for stability
- **Breaking Changes in v6:**
  - Requires runner v2.327.1 or newer
  - Upgraded to Node 24
- **Recommendation:** ✅ **UPDATE TO v5.6.0** (LTS-like stability)

### ✅ OK: GreenTF/upload-thunderstore-package
- **Current:** `@v4.3`
- **Latest:** `@v4.3` ✅ ALREADY UP TO DATE
- **Status:** Current and stable
- **Recommendation:** No action needed

---

## Update Priority Matrix

| Priority | Action | Current | Target | Impact | Effort |
|----------|--------|---------|--------|--------|--------|
| 🔴 CRITICAL | softprops/action-gh-release | @v1 | @v2.4.1 | High | Low |
| 🔴 CRITICAL | upload-artifact | @v3 | @v4.6.2 | High | Medium |
| 🔴 CRITICAL | download-artifact | @v3 | @v4.3.0 | High | Medium |
| 🟡 MEDIUM | setup-python | @v4 | @v5.6.0 | Medium | Low |
| 🟡 MEDIUM | checkout | @v4 | @v4.3.0 | Low | Low |
| 🟢 OK | GreenTF/upload-thunderstore | @v4.3 | N/A | - | - |

---

## Implementation Plan

### Phase 1: CRITICAL Updates (Do First)
1. Update `softprops/action-gh-release@v1` → `@v2.4.1`
   - Files: `generate-and-release.yml`
   - Risk: Low (many releases since v1, well-tested)

2. Update `actions/upload-artifact@v3` → `@v4.6.2`
   - Files: `generate-and-release.yml`
   - Risk: Medium (breaking changes, but our code doesn't use hidden files feature)
   - Action: Add `include-hidden-files: false` to be explicit

3. Update `actions/download-artifact@v3` → `@v4.3.0`
   - Files: `generate-and-release.yml`
   - Risk: Medium (path behavior change, need to test)
   - Note: We don't use artifact-ids, so path behavior unchanged

### Phase 2: MEDIUM Priorities (Nice to Have)
4. Update `actions/setup-python@v4` → `@v5.6.0`
   - Files: `ci.yml`, `generate-and-release.yml`
   - Risk: Low (backward compatible)

5. Update `actions/checkout@v4` → `@v4.3.0`
   - Files: Multiple files
   - Risk: Very Low (patch version, backward compatible)

---

## Recommended File Changes

### File: `.github/workflows/generate-and-release.yml`
```diff
- uses: actions/checkout@v4
+ uses: actions/checkout@v4.3.0

- uses: actions/setup-python@v4
+ uses: actions/setup-python@v5.6.0

- uses: actions/upload-artifact@v3
+ uses: actions/upload-artifact@v4.6.2
+ with:
+   include-hidden-files: false

- uses: actions/download-artifact@v3
+ uses: actions/download-artifact@v4.3.0

- uses: softprops/action-gh-release@v1
+ uses: softprops/action-gh-release@v2.4.1
```

### File: `.github/workflows/ci.yml`
```diff
- uses: actions/checkout@v4
+ uses: actions/checkout@v4.3.0

- uses: actions/setup-python@v4
+ uses: actions/setup-python@v5.6.0
```

### File: `.github/workflows/auto-merge-ci-cd.yml`
```diff
- uses: actions/checkout@v4
+ uses: actions/checkout@v4.3.0
```

### File: `.github/workflows/publish-thunderstore.yml`
```diff
- uses: actions/checkout@v4
+ uses: actions/checkout@v4.3.0
```

---

## Testing Strategy After Updates

1. **Create a test branch** from feature/cicd-automated-release
2. **Make version updates** one action at a time
3. **Run CI workflow** to validate each change
4. **Test full pipeline** with manual workflow dispatch
5. **Monitor** first automatic release for errors

---

## References

- [actions/checkout releases](https://github.com/actions/checkout/releases)
- [actions/setup-python releases](https://github.com/actions/setup-python/releases)
- [actions/upload-artifact releases](https://github.com/actions/upload-artifact/releases)
- [actions/download-artifact releases](https://github.com/actions/download-artifact/releases)
- [softprops/action-gh-release releases](https://github.com/softprops/action-gh-release/releases)
- [GreenTF/upload-thunderstore-package releases](https://github.com/GreenTF/upload-thunderstore-package/releases)

---

## Questions to Resolve Before Updating

1. **Should we use major version tags or specific patch versions?**
   - Current: Major only (`@v4`)
   - Recommended: Use major with patch for stability (`@v4.6.2`)

2. **Can we run a test workflow to validate before merge?**
   - Suggest creating a test dispatch workflow

3. **Should we add artifact retention policy updates?**
   - v4 upload-artifact has new concurrency/timeout env vars

---

## Conclusion

**Action Required:** All three CRITICAL actions need updating. These should be done before next production release.

**Recommended Timeline:**
- ✅ This week: Make critical updates
- ✅ Next PR: Test updates thoroughly
- ✅ Before next release: Deploy with updated actions

