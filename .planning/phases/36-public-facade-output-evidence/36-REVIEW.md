---
phase: 36-public-facade-output-evidence
status: issues_found
depth: deep
reviewed: 2026-07-13
files_reviewed: 10
findings:
  critical: 0
  warning: 3
  info: 0
  total: 3
---

# Phase 36 Final Code Re-Review - Iteration 4

## Scope

Fresh independent review after remediation commits `392edfd` and `6659685` covered the same six Phase 36 files, the four remediation-owned repository contracts, the latest review/fix history, and both remediation diffs:

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`
- `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py`
- `example-images/generate_gallery.py`
- `example-images/README.md`
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`
- `.gitignore`
- `SECURITY.md`
- `RELIABILITY.md`
- `PLANS.md`

## Findings

### WR-04: Failed descriptor acquisition leaks one file descriptor per invocation

**Severity:** Warning
**File:** `example-images/generate_gallery.py:266-268`

`publish_gallery(...)` opens `input_fd`, then attempts to open `output_fd`, and only afterward appends both descriptors to the cleanup list. If the output open fails, `input_fd` is unreachable by the `finally` loop and remains open. The same ownership gap exists inside `_mkdir_open(...)`: an opened directory is not closed if its post-open identity check raises before the descriptor is returned to its caller.

A deterministic temporary-repository reproducer omitted `example-images/output` and invoked `publish_gallery(...)` 40 times in one process. Every call failed as intended, but `/dev/fd` grew from 5 to 45. This contradicts fail-closed repeated/library invocation semantics and can exhaust the process descriptor limit under repeated invalid state or a raced identity failure.

Register each descriptor for cleanup immediately after each successful open, rather than batching registration after subsequent fallible operations. `_mkdir_open(...)` should close its local descriptor on every exception before ownership transfers to the caller. Add repeated failure-path descriptor-count tests for missing output and post-open identity mismatch.

### WR-05: Same-inode, same-size source mutation can publish a torn gallery file

**Severity:** Warning
**File:** `example-images/generate_gallery.py:211-228`

The source-copy check compares only device, inode, and size before and after copying. A concurrent in-place write that preserves the file size changes none of those values, so `_copy_regular_file(...)` accepts a byte stream assembled from different source states. The later staging validation checks only the destination inode and cannot recover source consistency.

A deterministic reproducer copied a 2 MiB source while replacing its second MiB in place after the first `os.read`. `_copy_regular_file(...)` returned success and produced a 2 MiB destination whose first half came from the old state and second half from the new state. Such a destination is eligible for atomic publication even though it was never a stable renderer output. A prior strict-helper run does not close the race between validation and gallery copying.

Capture and compare mutation metadata such as `st_mtime_ns` and `st_ctime_ns` in addition to identity and size, and fail if it changes across the copy. For stronger evidence integrity, validate the completed staged PNG bytes or copy from an immutable snapshot. Add a same-size in-place mutation regression that must fail before publication.

### WR-06: Gallery source copying has no file-size or work budget

**Severity:** Warning
**File:** `example-images/generate_gallery.py:212-224`

`_copy_regular_file(...)` trusts `before.st_size` as the loop bound but imposes no maximum. A sparse or otherwise oversized regular file with an expected renderer-output name is read and materialized into staging until its entire declared size has been written, permitting unbounded disk consumption and runtime. The helper's 16 MiB PNG acquisition ceiling does not protect the generator because gallery generation is an independent command and never invokes that helper.

Apply a gallery-source ceiling consistent with the committed PNG budget before creating the destination, retain the extra-read growth detection, and cover both pre-open sparse oversize and post-open growth at the ceiling. This keeps descriptor-relative copying bounded as well as path-safe.

## Confirmed Repairs and Checks

- Descriptor-relative staging, exclusive no-follow destination creation, quarantine rename, and staging-to-gallery publication prevent pathname redirection into an external tree.
- The pre-publication ancestor swap self-test fails closed and preserves the external sentinel. Old gallery contents are renamed intact into one quarantine entry without enumeration, recursive deletion, or mount/link traversal.
- Existing staging/quarantine blocks repeat publication as documented; the visible published gallery and external sentinel remain unchanged on that blocked run.
- PNG and JPEG acquisition opens once with `O_NOFOLLOW`, requires a regular file, retains at most the configured ceiling plus one byte, and closes its descriptor. Sparse oversize, growth beyond the ceiling, and pathname replacement are bounded or rejected as intended.
- PNG parsing retains chunk/CRC/IEND/order-end checks and bounded incremental zlib output. The decoded-length, EOF, unused-data, unconsumed-tail, and trailing-stream gates remain sound under the 16 MiB compressed and 64 MiB decoded ceilings.
- `python3 example-images/generate_gallery.py --self-test` passed.
- `python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py --self-test` passed.
- `python3 -m py_compile` passed for both Python tools.
- `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` passed 10/10 XCTest cases.
- The live strict helper passed: 252/252 fully decoded same-dimension PNGs, 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face comparisons.

## Verdict

Phase 36 is not clean at deep review depth. The iteration-3 remediation closes the two prior critical containment defects and the unbounded PNG/JPEG pathname acquisition defect; no critical finding remains. Three warning-level source-acquisition and descriptor-lifetime gaps remain: repeated failed gallery calls leak descriptors, same-size in-place source mutation can publish a torn file, and gallery copying has no source-size/work ceiling.
