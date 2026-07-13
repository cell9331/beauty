---
phase: 36-public-facade-output-evidence
source_review: .planning/phases/36-public-facade-output-evidence/36-REVIEW.md
fixed_at: 2026-07-13T10:20:43Z
status: all_fixed
iteration: 3
fix_scope: critical_warning
findings_in_scope: 3
fixed: 3
skipped: 0
fix_commits:
  - 392edfd
  - 6659685
findings_fixed:
  critical: 2
  warning: 1
  info: 0
  total: 3
---

# Phase 36 Code Review Fix Report — Iteration 3

All three iteration-3 findings are fixed with no skipped finding. The redesign preserves the earlier duplicate-inventory, bounded-decompression, static-symlink, and pre-deletion ancestor-swap repairs while removing gallery cleanup entirely.

## Findings Fixed

### CR-03: Descriptor protection ended before gallery population

- Replaced pathname-based gallery directory creation and `shutil.copy2` destinations with a fresh `.gallery-staging/` tree created below securely opened repository and `example-images` descriptors.
- Every group/case directory uses descriptor-relative `mkdir` plus `open(O_DIRECTORY | O_NOFOLLOW)`. Every destination uses descriptor-relative `open(O_WRONLY | O_NOFOLLOW | O_CREAT | O_EXCL)`.
- Renderer sources are opened through the anchored `output` directory descriptor with `O_NOFOLLOW`, required to be regular files, copied at the original `fstat` size, and rejected on truncation, growth, or identity/size change.
- Repository, `example-images`, input/output, staging/quarantine, every created directory, and every staged file device/inode identity is revalidated immediately before publication.
- The completed staging tree is published only with descriptor-relative atomic rename. There are no production pathname destination writes after validation.
- The deterministic post-recreation race hook renames `example-images` and substitutes an external tree immediately before publication. Identity revalidation fails closed; the staged file stays in the displaced repository tree and the external expected-name sentinel remains byte-identical.
- Commit: `392edfd` (`fix(36): publish gallery from anchored staging`).

### CR-04: Recursive cleanup could traverse mounted directories

- Deleted recursive gallery cleanup entirely. Production code contains no `shutil.rmtree`, recursive remover, old-gallery enumeration, `os.listdir`, unlink, or rmdir operation.
- A preexisting gallery is moved intact, using only descriptor-relative rename, into one ignored `.gallery-quarantine/previous/` slot. Neither the gallery nor quarantine contents are traversed.
- Existing `.gallery-staging/` or `.gallery-quarantine/` blocks the run. The generator deliberately does not claim cleanup; explicit out-of-band operator handling is documented before retry.
- A mount-like regression instruments `os.listdir` to raise on any attempted traversal, places a nested external symlink and sentinel under the old gallery, publishes successfully, and proves the intact old tree is quarantined while the external sentinel survives.
- A repeated-run regression proves the single occupied quarantine slot fails closed without changing the published gallery or external sentinel.
- `.gitignore`, `example-images/README.md`, `SECURITY.md`, `RELIABILITY.md`, and `PLANS.md` record the bounded non-destructive quarantine contract.
- Commit: `392edfd` (`fix(36): publish gallery from anchored staging`).

### WR-03: PNG pathname stat/read TOCTOU allowed unbounded acquisition

- PNG acquisition now opens once with `O_NOFOLLOW`, `fstat`s that same descriptor, requires a regular file, and retains at most `MAX_PNG_FILE_BYTES + 1` bytes through bounded `os.read` calls.
- A pre-read oversize, retained extra byte, same-file growth, identity/size change, or length mismatch fails closed. Parsing and incremental zlib budgets remain unchanged.
- JPEG fixture acquisition uses the same single-descriptor bounded helper with its own 16 MiB ceiling; the former unbounded `Path.read_bytes()` path is removed.
- The replacement race opens a valid PNG, replaces its pathname after `fstat` with a sparse oversized file, and proves decoding remains anchored to the already-open valid descriptor. The growth race enlarges that opened file after `fstat` and proves the `MAX + 1` read rejects it before parsing.
- Commit: `6659685` (`fix(36): bound renderer image reads by descriptor`).

## Verification

- PASS: `python3 example-images/generate_gallery.py --self-test` — descriptor-relative staging/copy/publication, deterministic post-recreation ancestor swap, instrumented non-traversal of a mount-like nested tree, external survival, bounded quarantine, and repeat-run fail-closed behavior.
- PASS: `python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py --self-test` — prior negative paths plus single-descriptor replacement and growth races.
- PASS: `python3 -m py_compile` for both changed Python tools.
- PASS: live strict helper — 36 cases × 7 fixtures, 252/252 non-empty fully decoded same-dimension PNGs; 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face comparisons.
- PASS: fresh gallery publication — visible gallery contains exactly 252 PNGs. The intact prior 252-PNG gallery is preserved in the one quarantine slot; staging is absent.
- PASS: containment scan — all 504 visible-plus-quarantined PNGs are ignored; gallery/quarantine/staging tracked and staged counts are zero. A production repeated run fails closed on the occupied quarantine and leaves the visible gallery at 252.
- PASS: `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` — 10/10 XCTest cases, zero failures.
- PASS: `swift test --package-path BeautySDK` — 220/220 XCTest cases, zero failures.
- PASS: exact forbidden-operation scan finds no production `shutil`, `rmtree`, recursive remover, old-tree `listdir`, pathname `copy2`, or PNG/JPEG `read_bytes` acquisition.
- PASS: `git diff --check`.

## Finding History Preserved

- Iteration 1 CR-01, WR-01, and WR-02 remain fixed by `cdae1a4`, `3c87267`, and `45c969c`.
- Iteration 2 CR-02's descriptor identity pattern remains, but its recursive quarantine deletion has been superseded by the iteration-3 non-destructive single-slot design.
- Phase 36 remains output evidence only. Provisional strengths, no-promotion boundaries, and Phase 37 cap/safety/promotion ownership are unchanged.

## Status

All iteration-3 critical and warning findings are fixed. This report is intentionally left uncommitted for the orchestrator.
