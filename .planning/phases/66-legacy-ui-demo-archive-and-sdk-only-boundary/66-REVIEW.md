---
phase: 66-legacy-ui-demo-archive-and-sdk-only-boundary
reviewed: 2026-08-14T03:36:54Z
depth: standard
iteration: 2
files_reviewed: 29
files_reviewed_list:
  - scripts/archive-legacy-ui.py
  - scripts/check-sdk-only-boundary.sh
  - scripts/run-no-skip-swiftpm.sh
  - scripts/check-no-skip-transcript.py
  - archives/legacy-ui/README.md
  - archives/legacy-ui/BeautyDemo-v1.16.manifest.tsv
  - archives/legacy-ui/BeautyDemo-v1.16.zip
  - archives/legacy-ui/BeautyDemo-v1.16.zip.sha256
  - archives/legacy-ui/meituxiuxiu-v1.16.manifest.tsv
  - archives/legacy-ui/meituxiuxiu-v1.16.zip
  - archives/legacy-ui/meituxiuxiu-v1.16.zip.sha256
  - docs/SDK_EFFECT_TAXONOMY.md
  - AGENTS.md
  - ARCHITECTURE.md
  - FRONTEND.md
  - PRODUCT_SENSE.md
  - QUALITY_SCORE.md
  - SECURITY.md
  - RELIABILITY.md
  - PLANS.md
  - .planning/PROJECT.md
  - .planning/codebase/STACK.md
  - .planning/codebase/STRUCTURE.md
  - .planning/codebase/TESTING.md
  - docs/README.md
  - .planning/codebase/ARCHITECTURE.md
  - .planning/codebase/INTEGRATIONS.md
  - .planning/codebase/CONVENTIONS.md
  - .planning/codebase/CONCERNS.md
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
  resolved: 12
status: clean
---

# Phase 66: Code Review Report

**Reviewed:** 2026-08-14T03:36:54Z
**Depth:** standard
**Files Reviewed:** 29
**Status:** clean

## Resolution Summary

All seven Critical, three Warning, and two iteration-2 follow-up findings are
closed by commits `5ddd6cb`, `46b6ab8`, `c26d7c4`, `76ba3f3`, and `8d4fe9b`.
The archive, boundary, and transcript mutation self-tests pass, canonical artifact
verification and artifact-only reproduction pass with both live roots absent,
and the mandatory bounded SwiftPM gate executes 650 tests with all eight opt-ins,
zero failures, and zero skips.

## Iteration 2 Follow-up Findings

### F2-01: Rollback collision could delete quarantined originals

**Status:** Fixed (`76ba3f3`). Rollback now preflights every destination before
restoring any root. A recreated source path preserves the complete two-root
quarantine and reports its manual recovery path; a partial restore failure also
leaves every not-yet-restored original in quarantine. The deterministic
post-quarantine recreation self-test proves the replacement and both staged
originals coexist unchanged, requires a failure result, then performs explicit
fixture recovery.

### F2-02: Post-archive symlink scan rejected ignored SwiftPM build links

**Status:** Fixed (`8d4fe9b`). The scanner prunes only real directories named
exactly `.build` when `git check-ignore --no-index` confirms the tree is ignored.
Its self-test accepts ignored `.codex` skill-source and `.planning` spike build
symlinks while the existing active source-tree and file symlink mutations still
fail closed.

## Original Summary

The committed archives currently match their manifests and recorded digests, the
archive and boundary self-tests pass, and the current source/test inventory counts
are accurate. The implementation is nevertheless not safe to ship as the claimed
archive boundary. The post-retirement verifier accepts a completely empty,
self-consistent replacement bundle; retirement has an unverified race immediately
before irreversible deletion; the documented recovery command extracts before
verification; and both archive and no-skip parsers have reproducible fail-open
cases. The SDK-only scanner also misses symlinked trees and several current documents
that are already stale.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: Artifact-only verification accepts complete historical data loss

**Classification:** BLOCKER

**Status:** Fixed (`5ddd6cb`). Independent code-owned ZIP/manifest digests,
exact 45/26 counts and path inventories, and an empty-bundle mutation now fail
before parsing or extraction.

**File:** `/Users/yakangwang/codes/beauty/scripts/archive-legacy-ui.py:191-218`

**Issue:** `parse_manifest` accepts a header-only manifest, and
`verify_bundle_bytes` checks only self-consistency among the mutable ZIP, manifest,
and adjacent digest record. It never pins the expected archive digest, manifest
digest, file count, or canonical path inventory after the live roots are gone.
A reproducible probe passed an empty ZIP, `path\tsize\tsha256\n`, and the empty
ZIP's matching digest record to `verify_bundle_bytes`; the function returned
success. Replacing both retained histories with similarly self-consistent empty
bundles would therefore let `verify`, the boundary gate, and the mandatory
no-skip gate pass after all 71 historical files had been lost.

**Fix:** Pin independent post-retirement trust anchors in code or another protected
authority: at minimum the exact ZIP SHA-256 values, manifest SHA-256 values, exact
counts (`45` and `26`), and required path inventories. Reject an empty manifest
unconditionally. Verify the pinned values before parsing or extracting. Add a
self-test that replaces all three files of a bundle with a valid empty bundle and
requires failure.

### CR-02: Retirement can delete content added or changed after reproduction

**Classification:** BLOCKER

**Status:** Fixed (`5ddd6cb`). Both exact roots are renamed into quarantine
before file-descriptor inventory/reproduction; a late untracked mutation test
proves rollback preserves the added bytes.

**File:** `/Users/yakangwang/codes/beauty/scripts/archive-legacy-ui.py:481-516`

**Issue:** The expensive fresh reproduction completes before either source root is
moved. The code then moves the live directories and irreversibly removes the
quarantine without re-inventorying the moved bytes. A concurrent edit, newly
created untracked file, or directory replacement in this window is not in the
verified archive but is still deleted. The tracked-deletion check cannot see
untracked additions and therefore does not close the race. This breaks the stated
digest-bound transaction and creates a direct data-loss path.

**Fix:** Atomically rename both exact roots into quarantine first, while rollback
is still possible; enumerate and hash the quarantined directories without
following links; compare that frozen inventory exactly with the pinned manifests
and verified ZIP content; then check sentinels/deletions and remove quarantine.
Any mismatch must restore both roots. Add a mutation test that inserts an untracked
file between initial verification and quarantine validation and proves it is not
deleted.

### CR-03: Source enumeration can follow a raced symlink outside the source root

**Classification:** BLOCKER

**Status:** Fixed (`5ddd6cb`). Descriptor-relative traversal uses `O_NOFOLLOW`,
`fstat`, stable device/inode/size/mtime checks, and an adversarial swap test.

**File:** `/Users/yakangwang/codes/beauty/scripts/archive-legacy-ui.py:142-159`

**Issue:** Each entry is `stat`ed with `follow_symlinks=False`, but the later
`Path.read_bytes()` reopens by pathname and follows links. A file can be replaced
with a symlink between those operations, causing arbitrary outside-repository bytes
to be archived. Directories have the same pathname race between `stat` and later
enumeration. This defeats the advertised symlink rejection and can persist private
files in the tracked ZIP.

**Fix:** Walk using directory file descriptors and open files with `O_NOFOLLOW`
(plus `O_CLOEXEC`), then `fstat` the opened descriptor and hash/read from that same
descriptor. Verify regular-file type and stable device/inode/size metadata. Do not
reopen validated entries by pathname. Add an adversarial swap test.

### CR-04: Recovery instructions extract unverified bytes into a predictable existing directory

**Classification:** BLOCKER

**Status:** Fixed (`5ddd6cb`). `restore --destination` verifies one pinned
snapshot before creating a nonexistent destination under a fresh private temp
parent; README recovery no longer invokes a general extractor.

**File:** `/Users/yakangwang/codes/beauty/archives/legacy-ui/README.md:85-94`

**Issue:** The documented command runs `unzip` twice before running the safe Python
verifier, and uses `mkdir -p` on a fixed, potentially pre-existing or symlinked
`/tmp/beauty-legacy-ui-restore`. A corrupt or replaced ZIP is therefore interpreted
by a general extractor before path/mode/digest validation, and existing files can
be overwritten. This directly contradicts `SECURITY.md:43-47` and the README's own
"new temporary directory" promise. Verification after extraction cannot undo the
write.

**Fix:** Add a `restore --destination <new-path>` operation that opens one verified
snapshot of each artifact, validates pinned digests/limits/entries, requires a
nonexistent destination under a freshly created `mktemp -d`, and extracts using the
tool's safe writer. Document that command only; never direct users to `unzip` first.

### CR-05: ZIP verification has no size or expansion bounds

**Classification:** BLOCKER

**Status:** Fixed (`5ddd6cb`). Pinned compressed size, entry count, per-entry and
total-uncompressed bounds, a 20:1 ratio ceiling, and streamed hashing/extraction
are covered by oversize/overflow/high-expansion mutations.

**File:** `/Users/yakangwang/codes/beauty/scripts/archive-legacy-ui.py:330-373`

**Issue:** The verifier reads the whole ZIP into memory, calls `testzip()` before
checking any `ZipInfo.file_size`, then materializes every entry again and extracts
it. Because the manifest and digest record are mutable together, an untrusted
change can provide a small high-ratio ZIP with huge declared/uncompressed content
and exhaust memory or temporary disk before rejection. The retained
`meituxiuxiu` ZIP is already 88,210,543 bytes with 88,650,871 manifest bytes, yet
no explicit policy records that intentional 84 MiB baseline or an upper bound.

**Fix:** Before CRC/decompression, enforce pinned compressed size, exact entry
count, per-entry size, total uncompressed size, and a conservative compression-ratio
limit. Stream each entry through hashing into bounded storage instead of using
`archive.read(info)`. Document the intentional canonical sizes and add oversized,
sum-overflow, and high-expansion self-tests.

### CR-06: The no-skip gate misses Swift Testing skips

**Classification:** BLOCKER

**Status:** Fixed (`46b6ab8`). The parser rejects XCTest and Swift Testing
skip/disabled events and its fixtures cover both runners' pass/fail/skip forms.

**File:** `/Users/yakangwang/codes/beauty/scripts/run-no-skip-swiftpm.sh:72-75`

**Issue:** The skip regex recognizes XCTest's `Test Case '…' skipped` and summary
`test(s) skipped`, but not Swift Testing's current output. A Swift 6 probe using
`@Test(.disabled("review probe"))` emitted
`➜ Test skippedProbe() skipped: "review probe"` and exited successfully; neither
alternative matches it. Because this package's `swift test` already launches the
Swift Testing runner after XCTest, a future mandatory Swift Testing skip can pass
the claimed zero-skip gate while the XCTest aggregate satisfies the denominator.

**Fix:** Parse both runner formats (including the Swift Testing skipped-event line
and skipped summary) or consume a machine-readable result format. Add transcript
fixtures for XCTest and Swift Testing pass/fail/skip/disabled cases and require an
exact runner accounting result before success.

### CR-07: A symlinked application tree is invisible to the SDK-only scanner

**Classification:** BLOCKER

**Status:** Fixed (`c26d7c4`). The scanner classifies active entries with
`lstat`, rejects every active symlink, and tests external directory and forbidden
file symlinks.

**File:** `/Users/yakangwang/codes/beauty/scripts/check-sdk-only-boundary.sh:252-267`

**Issue:** `Path.rglob` does not recurse through directory symlinks, and the loop
does not reject symlinks generally. A tracked benignly named symlink directory can
therefore point to a restored Xcode/SwiftUI tree; the scanner sees only the alias,
not its contents, and passes unless the alias itself has a forbidden suffix. This
is a concrete false negative in the claimed active-source boundary.

**Fix:** Reject every symlink in active source/build/document roots unless it is on
an explicit narrow allowlist, and use `lstat` rather than followed `is_dir`/
`is_file` classification. Add mutations for a directory symlink to an external
SwiftUI/Xcode tree and a file symlink to a forbidden artifact.

## Warnings

### WR-01: The scanner omits current documents that are already stale

**Classification:** WARNING

**Status:** Fixed (`c26d7c4`). `docs/README.md` and the four drifting codebase
maps are SDK-only; one canonical current-owner/map inventory is scanned with
mutations for root, docs, planning, map, and script classes.

**File:** `/Users/yakangwang/codes/beauty/scripts/check-sdk-only-boundary.sh:196-250`

**Issue:** Text scanning is limited to a small hard-coded owner list and does not
cover `docs/README.md` or all seven current `.planning/codebase` maps. The missed
files currently contain live false statements and commands: `docs/README.md:18-29`
says `BeautyDemo/` exists, `BeautySDK/Package.swift` does not, and current
`xcodebuild` commands are supported; `.planning/codebase/INTEGRATIONS.md:15-68`,
`CONVENTIONS.md:39-72`, `CONCERNS.md:93-160`, and
`ARCHITECTURE.md:12-75` still describe the deleted Demo as current. This contradicts
`.planning/PROJECT.md:25`'s claim that the maps were refreshed and means
ARCHIVE-03/BOUNDARY-01 are not actually satisfied even though the scanner passes.

**Fix:** Update or explicitly historical-label the stale documents, then scan all
tracked current text outside explicit immutable-history prefixes. At minimum, make
the complete current-owner/map list canonical in one place and test one forbidden
mutation in every included document class.

### WR-02: Pre-existing unrelated tracked deletions do not block retirement

**Classification:** WARNING

**Status:** Fixed (`5ddd6cb`). Retirement rejects any pre-existing tracked
deletion, compares the absolute post-move set, and self-tests an unrelated dirty
deletion plus required sentinels.

**File:** `/Users/yakangwang/codes/beauty/scripts/archive-legacy-ui.py:474-505`

**Issue:** The transaction snapshots `deleted_before` and validates only
`deleted_after_move - deleted_before`. Thus any unrelated tracked deletion already
present is silently tolerated while the destructive transaction completes, despite
the plan/README promise of an exact deletion allowlist. The later postcondition is
not called inside `retire_sources` before irreversible removal.

**Fix:** Fail before mutation when `deleted_before` is nonempty (or require an
explicit, independently approved baseline), and compare the absolute post-move
deletion set with `expected_deletions` before deleting quarantine. Cover a dirty
worktree with an unrelated deletion in self-test.

### WR-03: The claimed transcript-size and ambiguity policy is not implemented

**Classification:** WARNING

**Status:** Fixed (`46b6ab8`). Streaming capture terminates at 16 MiB or 200,000
lines; exact runner aggregates reject missing, duplicate, contradictory, failed,
skipped, disabled, oversized, or zero-test transcripts.

**File:** `/Users/yakangwang/codes/beauty/scripts/run-no-skip-swiftpm.sh:51-90`

**Issue:** `RELIABILITY.md:30` and `RELIABILITY.md:105-107` say oversized or
ambiguous transcripts fail, but the transcript is unbounded and the parser only
requires at least one aggregate match. A noisy test can fill temporary storage,
and no maximum or exact aggregate accounting is enforced.

**Fix:** Set a documented byte/line ceiling while streaming (terminate the child
on overflow), require the exact expected runner summaries/count relationship, and
add mutation tests for oversize and duplicated/contradictory aggregates. Update the
contract only if those guarantees are intentionally removed.

---

_Reviewed: 2026-08-14T03:20:33Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
