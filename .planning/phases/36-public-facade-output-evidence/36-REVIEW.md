---
phase: 36-public-facade-output-evidence
status: issues_found
depth: standard
reviewed: 2026-07-13
files_reviewed: 6
findings:
  critical: 2
  warning: 1
  info: 0
  total: 3
---

# Phase 36 Code Re-Review - Iteration 3

## Scope

Fresh independent review after fix commit `1cfa68c` covered the same six Phase 36 files and the latest `36-REVIEW.md` / `36-REVIEW-FIX.md` history:

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`
- `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py`
- `example-images/generate_gallery.py`
- `example-images/README.md`
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`

## Findings

### CR-03: Descriptor protection ends before gallery population, allowing an external overwrite race

**Severity:** Critical
**File:** `example-images/generate_gallery.py:122-132`

`recreate_gallery_directory(...)` securely anchors deletion and creation only for the duration of that call. It closes every descriptor before returning, after which `generate_gallery(...)` creates case directories and copies files through the original pathnames. A concurrent rename of `example-images` followed by an external symlink substitution in this interval redirects both `case_dir.mkdir(...)` and `shutil.copy2(...)` outside the repository. Existing external files with expected gallery names are opened with truncation and overwritten.

A deterministic temporary-repository reproducer wrapped the real `recreate_gallery_directory`, swapped `repo/example-images` for a symlink immediately after the descriptor-safe recreation, and provided the expected source under the external target. `generate_gallery(...)` returned success and changed an external `gallery/x/case/f.png` sentinel from `OLD` to `NEW`. Thus the Phase 36 claim that generated gallery copies stay under the ignored repository gallery is still subject to the same ancestor-swap class even though destructive cleanup itself is anchored.

Keep the validated gallery descriptor open through population and perform directory creation plus destination opens descriptor-relatively with no-follow and identity checks. Source files should likewise be opened before the destructive transition or through anchored input/output descriptors, and the final visible gallery should be published only after a descriptor-relative staging tree is complete and revalidated.

### CR-04: Recursive cleanup traverses mounted directories

**Severity:** Critical
**File:** `example-images/generate_gallery.py:217-249`

The recursive remover distinguishes only directory versus non-directory. A mount point or bind-mounted directory inside the quarantined gallery passes `stat(..., follow_symlinks=False)`, opens successfully with `O_NOFOLLOW`, and has matching `st_dev`/`st_ino` between the directory entry and opened descriptor. `_remove_directory_contents(...)` then recursively deletes the mounted filesystem's contents. `O_NOFOLLOW` prevents symbolic-link traversal but does not prevent crossing mount points, so the asserted external-deletion containment is incomplete.

Reject filesystem/mount transitions before recursion using a platform-supported no-cross-device/no-mount primitive and fail closed where that guarantee cannot be established. A same-device bind mount means a simple parent/child `st_dev` comparison is insufficient on platforms that support bind mounts. Add an isolated mount-point regression where supported and prove the mounted sentinel survives.

### WR-03: PNG file-size bounding has a stat/read TOCTOU and still permits unbounded allocation

**Severity:** Warning
**File:** `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py:202-208`

`read_png_payload(...)` checks `path.stat().st_size` and then calls `path.read_bytes()` as a separate pathname operation. Replacement or growth between those calls bypasses `MAX_PNG_FILE_BYTES`; `read_bytes()` allocates the entire new file before any post-read check. A deterministic monkeypatch made `stat()` report one byte and `read_bytes()` return 16 MiB + 1 byte; the oversized buffer was allocated and admitted to the parser, which failed only later on its signature. The incremental zlib budget remains sound, but the broader claim that all untrusted PNG allocation is bounded is not yet true.

Open once, `fstat` that descriptor, and read through a bounded loop capped at `MAX_PNG_FILE_BYTES + 1`, rejecting excess before retaining it. The same pattern should be considered for JPEG fixture dimension reads, which currently use an entirely unbounded `read_bytes()`.

## Confirmed Repairs and Checks

- The iteration-2 descriptor chain rejects the deterministic pre-deletion ancestor swap, and the original local gallery plus external sentinel survive.
- Quarantine identity checks, nested symbolic-link unlinking, recursive descriptor closure, and ordinary recreation behave correctly. A 100-cycle nested cleanup stress check left `/dev/fd` unchanged at 5 descriptors.
- `python3 example-images/generate_gallery.py --self-test` passed.
- Phase 36 helper `--self-test`, Python compilation, and the live strict helper invocation passed.
- Focused `BeautyRendererOutputRegressionTests` passed 10/10.
- PNG decoded-length, decompressor EOF/trailing-stream, chunk/CRC/IEND, dimension, and duplicate renderer inventory fixes remain present and their deterministic regressions pass. The new warning is limited to acquisition of file bytes before parsing/decompression.
- `git diff --check` passed before this report rewrite.

## Verdict

Phase 36 is not clean at standard review depth. Commit `1cfa68c` closes the reported pathname-based deletion race and shows no ordinary descriptor leak, but gallery population can still be redirected outside the repository, recursive deletion can cross a mounted directory, and PNG file acquisition is not actually bounded across the stat/read race.
