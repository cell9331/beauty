---
phase: 36-public-facade-output-evidence
source_review: .planning/phases/36-public-facade-output-evidence/36-REVIEW.md
fixed_at: 2026-07-14T01:24:54Z
status: all_fixed
iteration: 4
fix_scope: critical_warning
findings_in_scope: 3
fixed: 3
skipped: 0
fix_commits:
  - efdaad4
findings_fixed:
  critical: 0
  warning: 3
  info: 0
  total: 3
---

# Phase 36 Code Review Fix Report — Iteration 4

All three iteration-4 warning findings are fixed with no skipped finding. The changes preserve descriptor-relative staging, intact single-slot quarantine, atomic publication, strict helper decoding, the exact 36 × 7 inventory, and all Phase 37 promotion boundaries.

## Findings Fixed

### WR-04: Failed descriptor acquisition leaked one file descriptor per invocation

- Each successfully acquired publication descriptor is registered for final cleanup before the next fallible acquisition or identity check. In particular, `input_fd` is owned before opening `output_fd`, and the optional gallery descriptor is owned inside its successful-open branch.
- `_mkdir_open(...)` retains local ownership until its post-open identity check succeeds and closes the descriptor on every exceptional exit before ownership can transfer to the caller.
- Deterministic self-tests repeat a missing-output publication failure 40 times and a forced `_mkdir_open(...)` post-open identity mismatch 40 times. Both assert unchanged process descriptor counts.
- Commit: `efdaad4` (`fix(36): bound gallery source acquisition`).

### WR-05: Same-inode, same-size source mutation could publish a torn gallery file

- Source stability now requires unchanged device, inode, size, `st_mtime_ns`, and `st_ctime_ns` before copying and again after the bounded copy and extra-byte growth check.
- Staged destinations retain the same full snapshot and are revalidated immediately before publication, so an in-place staging mutation also fails closed.
- A deterministic 2 MiB race rewrites the second MiB in place after the first copy chunk while preserving inode and size. The copy is rejected on metadata drift, the prior gallery remains unchanged, and no staging tree is published.
- Commit: `efdaad4` (`fix(36): bound gallery source acquisition`).

### WR-06: Gallery source copying had no file-size or work budget

- Gallery sources now share the strict helper's 16 MiB compressed-file ceiling.
- A source already above the ceiling is rejected before destination creation. A second descriptor snapshot immediately before destination creation detects post-open growth, copy reads remain capped by the accepted size, and the existing one-byte read detects later growth.
- Deterministic negatives cover a sparse `16 MiB + 1` source and an at-ceiling source grown by one byte after its first `fstat`; both fail without creating a destination.
- Commit: `efdaad4` (`fix(36): bound gallery source acquisition`).

## Verification

- PASS: `python3 example-images/generate_gallery.py --self-test` — repeated descriptor failures, sparse oversize, post-open ceiling growth, same-size torn-copy rejection before publication, descriptor-relative publication, ancestor swap, non-traversal, quarantine blocking, and external survival.
- PASS: `python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py --self-test` — duplicate/missing/extra/corrupt output paths, bounded decode, descriptor replacement/growth races, and ROI/watermark rejection.
- PASS: `python3 -m py_compile example-images/generate_gallery.py .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py`.
- PASS: live strict helper — 36 cases × 7 fixtures; 252/252 non-empty fully decoded same-dimension PNGs; 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face comparisons.
- PASS: `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` — 10/10 XCTest cases, zero failures.
- PASS: `swift test --package-path BeautySDK` — 220/220 XCTest cases, zero failures.
- PASS: `git diff --check`.

## Local Gallery State and Safe Operator Handoff

- Inspected without deletion: visible `example-images/gallery/` contains 252 files; `example-images/.gallery-quarantine/previous/` contains 252 regular files, zero symlinks, and zero other non-directory/non-regular entries; `.gallery-staging/` is absent.
- The remediation did not traverse for cleanup, remove, or rename the live quarantine. A production gallery run remains intentionally blocked while that slot exists.
- After review, the orchestrator can restore a clean gallery-only repository state without recursive deletion by first choosing a fresh path outside the repository on the same filesystem, verifying that destination is absent, and atomically renaming `example-images/.gallery-quarantine/` there. Then verify that the visible gallery still has 252 files, staging/quarantine are absent inside the repository, representative gallery files remain ignored, and `git ls-files` returns no output/gallery/staging/quarantine artifacts. The preserved outside-repository tree can be retained for later inspection or handled separately under explicit operator policy.

## Finding History Preserved

- Iteration 1 CR-01, WR-01, and WR-02 remain fixed by `cdae1a4`, `3c87267`, and `45c969c`.
- Iteration 2 CR-02's descriptor identity pattern remains, while its recursive quarantine deletion remains superseded by the iteration-3 non-destructive single-slot design.
- Iteration 3 CR-03, CR-04, and WR-03 remain fixed by `392edfd` and `6659685`.
- Iteration 4 WR-04, WR-05, and WR-06 are fixed by `efdaad4`.
- Phase 36 remains output evidence only. Provisional strengths, no-promotion boundaries, and Phase 37 cap/safety/promotion ownership are unchanged.

## Status

All iteration-4 critical/warning findings are fixed: 3/3 fixed, 0 skipped. This report is intentionally left uncommitted for the orchestrator.
