---
phase: 36-public-facade-output-evidence
status: issues_found
depth: standard
reviewed: 2026-07-13
files_reviewed: 6
findings:
  critical: 1
  warning: 2
  info: 0
  total: 3
---

# Phase 36 Code Review

## Scope

Reviewed the requested Phase 36 executable, test, helper, gallery, and durable evidence files:

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`
- `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py`
- `example-images/generate_gallery.py`
- `example-images/README.md`
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`

## Findings

### CR-01: A symlinked allow-list root can redirect recursive gallery deletion outside the repository

**Severity:** Critical  
**File:** `example-images/generate_gallery.py:15-16, 114-120, 136-144`

`ALLOWED_GALLERY_ROOT` is defined as the resolved target of `example-images/gallery`, and validation rejects only `gallery_dir.is_symlink()` at the final path component. If `example-images/gallery` is a symlink to an external directory and the caller supplies a child such as `example-images/gallery/victim`, the child itself is not a symlink, both resolved paths are under the same external target, and validation succeeds. `shutil.rmtree(gallery_dir)` then recursively deletes the external `victim` directory.

This bypasses the stated repository containment boundary and the Phase 36 high-severity path-cleanup threat mitigation. A safe reproducer that stopped before deletion confirmed `validate_gallery_directory(...)` accepts this symlink-ancestor arrangement.

Reject a symlink in every component from the repository root through the requested gallery path, and anchor containment against the lexical repository path rather than an allow-list root whose own `.resolve()` may escape the repository. Revalidate the physical target immediately before deletion; requiring the exact canonical `example-images/gallery` root would further reduce the destructive surface.

### WR-01: PNG decompression is unbounded before decoded-size validation

**Severity:** Warning  
**File:** `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py:195-263`

The helper correctly checks signatures, chunk bounds, CRCs, supported encodings, decoded length, and filter types, but it calls `decompressor.decompress(...)` and `flush()` without a maximum output length. Dimension and expected-size checks occur only after zlib has materialized the entire stream. There is also no accepted maximum width, height, compressed file size, or decoded byte count.

Because the Phase 36 threat model treats fixture/output bytes as untrusted, a small expected-name PNG containing a high-ratio stream can exhaust memory or terminate CI before the helper can return its controlled fail-closed error. Bound dimensions and decoded bytes before inflation, reject values outside the fixture/output budget, and use bounded incremental decompression (for example, expected scanline bytes plus one) so excess output is rejected without being fully allocated.

### WR-02: Gallery inventory validation does not reject duplicate renderer IDs

**Severity:** Warning  
**File:** `example-images/generate_gallery.py:188-214`

`validate_case_inventory` rejects duplicates only in `gallery_case_ids`, then compares sets. Duplicate IDs in the discovered renderer list are collapsed, so `validate_case_inventory(["only"], ["only", "only"])` succeeds. That is not the documented duplicate-free renderer/gallery bijection and could let the renderer overwrite the same flat output name while the gallery still reports a matching inventory.

The strict Phase 36 output helper independently rejects duplicate renderer IDs, so the current accepted 36-case run is unaffected, but `generate_gallery.py` is callable on its own and claims to enforce this invariant before copying. Reject duplicates in `renderer_case_ids` as well, then compare counts/order or sets as appropriate.

## Verified Behavior

- Focused `BeautyRendererOutputRegressionTests` passed 10/10.
- Helper self-tests and Python compilation passed.
- The live strict helper passed 252/252 full decodes with the documented 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face results.
- Current output and gallery inventories each contain exactly 252 PNGs.
- Renderer cases remain isolated on the public `BeautySDK` facade; representative no-face diagnostics remain aggregate and redacted.
- Documentation preserves provisional `0.25`, no-promotion, no device/commercial/packaging/launch claim, and Phase 37 ownership boundaries.
- `git diff --check` passed before this report was added.

## Verdict

Phase 36 is not clean at standard review depth. The current generated evidence is internally consistent, but the destructive gallery path guard has a symlink-ancestor escape and the strict helper/gallery validators have the two fail-closed gaps above.
