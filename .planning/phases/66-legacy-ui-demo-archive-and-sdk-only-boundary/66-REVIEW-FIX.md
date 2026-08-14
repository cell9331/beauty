---
phase: 66-legacy-ui-demo-archive-and-sdk-only-boundary
fixed_at: 2026-08-14T03:20:33Z
review_path: .planning/phases/66-legacy-ui-demo-archive-and-sdk-only-boundary/66-REVIEW.md
iteration: 1
findings_in_scope: 10
fixed: 10
skipped: 0
status: all_fixed
---

# Phase 66: Code Review Fix Report

**Fixed at:** 2026-08-14T03:20:33Z
**Source review:** `.planning/phases/66-legacy-ui-demo-archive-and-sdk-only-boundary/66-REVIEW.md`
**Iteration:** 1

**Summary:**

- Findings in scope: 10
- Fixed: 10
- Skipped: 0

## Fixed Issues

### CR-01: Artifact-only verification accepts complete historical data loss

**Files modified:** `scripts/archive-legacy-ui.py`, `archives/legacy-ui/README.md`, `SECURITY.md`, `RELIABILITY.md`
**Commit:** `5ddd6cb`
**Applied fix:** Pinned independent ZIP/manifest digests, exact counts and full path inventories; rejected empty manifests and self-consistent empty replacements.

### CR-02: Retirement can delete content added or changed after reproduction

**Files modified:** `scripts/archive-legacy-ui.py`, `archives/legacy-ui/README.md`, `SECURITY.md`, `RELIABILITY.md`
**Commit:** `5ddd6cb`
**Applied fix:** Renamed exact roots to quarantine first, verified the frozen descriptor inventory and deterministic digest, and restored late mutations on mismatch.

### CR-03: Source enumeration can follow a raced symlink outside the source root

**Files modified:** `scripts/archive-legacy-ui.py`
**Commit:** `5ddd6cb`
**Applied fix:** Replaced pathname reopening with descriptor-relative `O_NOFOLLOW` traversal and stable `fstat` checks; added adversarial swap coverage.

### CR-04: Recovery instructions extract unverified bytes into a predictable existing directory

**Files modified:** `scripts/archive-legacy-ui.py`, `archives/legacy-ui/README.md`, `SECURITY.md`, `RELIABILITY.md`
**Commit:** `5ddd6cb`
**Applied fix:** Added verified-snapshot `restore --destination` with fresh private temp-parent and nonexistent outside-repository destination requirements.

### CR-05: ZIP verification has no size or expansion bounds

**Files modified:** `scripts/archive-legacy-ui.py`, `archives/legacy-ui/README.md`, `SECURITY.md`, `RELIABILITY.md`
**Commit:** `5ddd6cb`
**Applied fix:** Enforced compressed, per-entry, total, count, and ratio bounds before decompression and streamed every entry through hashing/bounded extraction.

### CR-06: The no-skip gate misses Swift Testing skips

**Files modified:** `scripts/check-no-skip-transcript.py`, `scripts/run-no-skip-swiftpm.sh`, `RELIABILITY.md`
**Commit:** `46b6ab8`
**Applied fix:** Added exact XCTest/Swift Testing accounting and pass/fail/skip/disabled transcript fixtures.

### CR-07: A symlinked application tree is invisible to the SDK-only scanner

**Files modified:** `scripts/check-sdk-only-boundary.sh`
**Commit:** `c26d7c4`
**Applied fix:** Used `lstat` classification and rejected all active file/directory symlinks, including external restored-tree mutations.

### WR-01: The scanner omits current documents that are already stale

**Files modified:** `scripts/check-sdk-only-boundary.sh`, `docs/README.md`, `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/INTEGRATIONS.md`, `.planning/codebase/CONVENTIONS.md`, `.planning/codebase/CONCERNS.md`
**Commit:** `c26d7c4`
**Applied fix:** Canonicalized the complete current owner/map inventory, added per-document-class mutations, and rewrote all five stale documents to the SDK-only boundary.

### WR-02: Pre-existing unrelated tracked deletions do not block retirement

**Files modified:** `scripts/archive-legacy-ui.py`, `archives/legacy-ui/README.md`, `SECURITY.md`
**Commit:** `5ddd6cb`
**Applied fix:** Rejected any pre-existing tracked deletion and compared the absolute post-move set with the exact allowlist; added dirty-deletion coverage.

### WR-03: The claimed transcript-size and ambiguity policy is not implemented

**Files modified:** `scripts/check-no-skip-transcript.py`, `scripts/run-no-skip-swiftpm.sh`, `RELIABILITY.md`
**Commit:** `46b6ab8`
**Applied fix:** Added 16 MiB/200,000-line streaming limits with child termination and exact duplicate/contradictory aggregate rejection.

---

_Fixed: 2026-08-14T03:20:33Z_
_Fixer: the agent (gsd-code-fixer)_
_Iteration: 1_
