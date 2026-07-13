---
phase: 36-public-facade-output-evidence
source_review: .planning/phases/36-public-facade-output-evidence/36-REVIEW.md
fixed_at: 2026-07-13T10:02:38Z
status: all_fixed
iteration: 2
fix_scope: critical_warning
findings_in_scope: 1
fixed: 1
skipped: 0
fix_commits:
  - 1cfa68c
findings_fixed:
  critical: 1
  warning: 0
  info: 0
  total: 1
---

# Phase 36 Code Review Fix Report — Iteration 2

The iteration-2 critical finding CR-02 is fixed with no skipped finding. Earlier CR-01, WR-01, and WR-02 remediations remain intact.

## Iteration 2 Fix

### CR-02: Final-validation-to-deletion ancestor-swap TOCTOU

- Replaced pathname-based `shutil.rmtree` cleanup with repository-parent, repository, `example-images`, and gallery directory descriptors opened using `O_DIRECTORY | O_NOFOLLOW`.
- Requires `st_dev`/`st_ino` identity agreement between every opened descriptor and its no-follow parent entry before destructive use, after the deterministic race hook, at quarantine, and during recursive descent.
- Atomically renames the validated gallery entry to a unique quarantine name within the securely opened `example-images` descriptor before deleting it.
- Recursively enumerates and removes quarantine contents with descriptor-relative `listdir`, `stat(..., follow_symlinks=False)`, `open`, `unlink`, and `rmdir`; symbolic links are unlinked and never traversed.
- Fails closed on platforms without the required descriptor-relative, descriptor-listing, no-follow, or directory-open support.
- Added a deterministic regression that renames `example-images` and substitutes an external symlink after final validation but before destructive use. The operation rejects the device/inode mismatch, leaves the original local gallery intact, and proves the external sentinel survives.
- Added a recursive nested-symlink regression proving descriptor-relative cleanup removes only the link and recreates an empty gallery without touching the external sentinel.
- Commit: `1cfa68c` (`fix(36): anchor gallery cleanup to descriptors`).

## Finding History

### CR-01: Static gallery cleanup symlink containment — fixed in iteration 1

- Exact lexical gallery-root restriction and static symlink-component rejection remain covered for the gallery root, `example-images` ancestor, and requested gallery child.
- External-survival assertions remain in the gallery self-test.
- Commit: `cdae1a4`.

### WR-01: Bounded PNG decompression — fixed in iteration 1

- Dimension, decoded-budget, incremental-inflation, stream-completeness, trailing-data, and CRC checks remain unchanged.
- Compression-bomb, oversized-dimension, trailing-stream, and corrupt-output regressions continue to pass.
- Commit: `3c87267`.

### WR-02: Duplicate renderer gallery IDs — fixed in iteration 1

- Renderer IDs remain duplicate-checked before exact renderer/gallery set comparison.
- The duplicate `renderer=["only", "only"]` regression remains in the gallery self-test.
- Commit: `45c969c`.

## Verification

- PASS: `python3 example-images/generate_gallery.py --self-test` — exact root, prior static symlink cases, deterministic post-validation ancestor swap, recursive nested-symlink no-follow cleanup, external sentinel survival, and duplicate renderer ID rejection.
- PASS: `python3 -m py_compile example-images/generate_gallery.py`.
- PASS: Phase 36 helper `--self-test` — duplicate IDs/stems, missing/extra/corrupt outputs, bounded PNG decode, and ROI/watermark rejection.
- PASS: `python3 -m py_compile .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py`.
- PASS: clean gallery regeneration wrote exactly 252 ignored, untracked PNGs.
- PASS: live strict helper fully decoded 252/252 outputs and passed 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face comparisons.
- PASS: `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` — 10/10 XCTest cases, zero failures.
- PASS: `git diff --check`.

## Status

All iteration-2 findings in scope are fixed. The Phase 36 provisional-strength, no-promotion, generated-artifact, and Phase 37 ownership boundaries remain unchanged. This report is intentionally left uncommitted for the orchestrator.
