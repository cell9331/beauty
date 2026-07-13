---
phase: 36-public-facade-output-evidence
status: issues_found
depth: standard
reviewed: 2026-07-13
files_reviewed: 6
findings:
  critical: 1
  warning: 0
  info: 0
  total: 1
---

# Phase 36 Code Re-Review

## Scope

Fresh independent review after fix commits `cdae1a4`, `45c969c`, and `3c87267` covered all six requested Phase 36 files:

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`
- `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py`
- `example-images/generate_gallery.py`
- `example-images/README.md`
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`

## Finding

### CR-02: The final gallery validation still has a destructive ancestor-swap race

**Severity:** Critical  
**File:** `example-images/generate_gallery.py:176-195`

The static symlink-component escape reported as CR-01 is fixed: the destination is now restricted to the exact lexical `example-images/gallery` root and existing symlinks in either `example-images` or `gallery` are rejected. However, the second `validate_gallery_directory(...)` call and `shutil.rmtree(gallery_dir)` remain separate pathname operations. A concurrent replacement of the already-validated `example-images` directory with a symlink in that interval makes `rmtree` resolve the same lexical gallery path under an external directory. Repeating the validation immediately before deletion narrows the race but does not close it.

A deterministic temporary-directory adversarial reproducer replaced `repo/example-images` inside a wrapped `shutil.rmtree` call, after the last validation and before the real deletion. `recreate_gallery_directory(...)` returned successfully and the external `external/gallery/must-survive.txt` sentinel was deleted. This violates the high-severity T36-03 containment invariant even though all non-racing symlink self-tests pass.

Perform destructive cleanup through a repository-anchored directory descriptor and refuse changed inode/device identities, or atomically rename the validated gallery directory to a quarantine name within a securely opened repository parent before deleting the quarantined object. The implementation needs a regression that forces an ancestor replacement precisely between validation and destructive use and proves the external sentinel survives.

## Confirmed Fixes and Verification

- Original CR-01 static symlink cases are rejected for the exact gallery root, a symlinked `example-images` ancestor, and a gallery child.
- Original WR-01 is fixed for PNG decoding: dimensions and decoded length are bounded before inflation; incremental decompression rejects excess output; EOF, `unused_data`, `unconsumed_tail`, appended streams, chunk bounds, IEND trailing data, and CRC checks fail closed.
- Original WR-02 is fixed: duplicate renderer IDs are rejected before the renderer/gallery set comparison, preserving the duplicate-free exact bijection.
- `python3 example-images/generate_gallery.py --self-test` passed.
- Phase 36 helper `--self-test` and Python compilation passed.
- Focused `BeautyRendererOutputRegressionTests` passed 10/10.
- The live strict helper passed 252/252 full decodes, 12/12 baseline comparisons, 6/6 root/bridge comparisons, 12/12 lift/signed-tip comparisons, and 2/2 no-face comparisons.
- `git diff --check` passed before this report rewrite.

## Verdict

Phase 36 is not clean at standard review depth. The bounded PNG and duplicate-inventory repairs are sound, and the static symlink escape is closed, but the destructive gallery cleanup still permits an external deletion through an ancestor-swap TOCTOU race.
