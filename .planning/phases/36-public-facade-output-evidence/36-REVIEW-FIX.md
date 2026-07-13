---
phase: 36-public-facade-output-evidence
source_review: .planning/phases/36-public-facade-output-evidence/36-REVIEW.md
fixed_at: 2026-07-13T09:51:00Z
status: all_fixed
iteration: 1
fix_scope: critical_warning
findings_in_scope: 3
fixed: 3
skipped: 0
fix_commits:
  - cdae1a4
  - 45c969c
  - 3c87267
findings_fixed:
  critical: 1
  warning: 2
  info: 0
  total: 3
---

# Phase 36 Code Review Fix Report — Iteration 1

All critical and warning findings from the Phase 36 standard review are fixed.

## Fixes

### CR-01: Gallery cleanup symlink containment

- Anchored the destination lexically to the physical repository root and restricted destructive cleanup to the exact canonical `example-images/gallery` path.
- Rejects symbolic links at every component from the repository root through the gallery destination.
- Repeats lexical-component, physical-target, and input/output-overlap validation immediately before `shutil.rmtree`.
- Added deterministic negative tests for a symlinked gallery root, a symlinked `example-images` ancestor, and a requested gallery child. Every case verifies an external sentinel survives.
- Commit: `cdae1a4` (`fix(36): contain gallery cleanup to repository root`).

### WR-01: Bounded PNG decompression

- Validates file size, width, height, and computed decoded scanline budget before inflation.
- Uses incremental `zlib.decompressobj` calls capped at the exact expected decoded length plus one byte; excess decoded output is rejected without materializing the remainder.
- Rejects incomplete streams, unconsumed input, unused/trailing compressed data, appended deflate streams, and excess output.
- Added deterministic negative tests for over-budget dimensions, a high-ratio compression bomb, and a trailing compressed stream while retaining the existing corrupt-output checks.
- Commit: `3c87267` (`fix(36): bound untrusted PNG decompression`).

### WR-02: Duplicate renderer gallery IDs

- `validate_case_inventory` now rejects duplicate renderer IDs before set comparison, matching the helper's duplicate-free bijection contract.
- Added the reported `gallery=["only"]`, `renderer=["only", "only"]` negative regression.
- Commit: `45c969c` (`fix(36): reject duplicate renderer gallery cases`).

## Verification

- PASS: `python3 example-images/generate_gallery.py --self-test` — exact-root, symlink-root, symlink-ancestor, external-survival, and duplicate-renderer-ID negative cases.
- PASS: `python3 -m py_compile example-images/generate_gallery.py`.
- PASS: Phase 36 helper `--self-test` — existing negatives plus bounded-decode dimension, compression-bomb, and trailing-stream cases.
- PASS: `python3 -m py_compile .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py`.
- PASS: strict helper against the current matrix — 252/252 outputs accepted with bounded full decode.
- PASS: gallery regeneration wrote exactly 252 files under the exact canonical ignored gallery root.
- PASS: `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` — 10/10 XCTest cases, zero failures.
- PASS: `git diff --check` after each finding fix.

## Status

All three in-scope findings are fixed with no skipped finding. Phase 36's provisional-strength, no-promotion, generated-artifact, and Phase 37 ownership boundaries remain unchanged. This report is intentionally left uncommitted for the orchestrator.
