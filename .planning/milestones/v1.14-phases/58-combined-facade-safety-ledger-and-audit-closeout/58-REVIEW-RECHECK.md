---
phase: 58-combined-facade-safety-ledger-and-audit-closeout
reviewed: 2026-08-04T18:15:00+08:00
depth: deep
files_reviewed: 3
files_reviewed_list:
  - .planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py
  - .planning/ROADMAP.md
  - .planning/STATE.md
findings:
  critical: 2
  warning: 2
  info: 0
  total: 4
status: issues_found
---

# Phase 58: Code Review Recheck

**Reviewed:** 2026-08-04T18:15:00+08:00  
**Depth:** deep  
**Status:** issues_found

## Summary

The five code-review fixes and owner-count correction were rechecked against
the live checker and temporary-root mutations. CR-01, CR-04, and CR-05 are
closed. The owner totals in WR-01 are reconciled, but stale lifecycle text
remains. CR-02, CR-03, and WR-02 still have fail-open/vacuous cases.

## Prior Finding Status

| Finding | Status | Evidence |
| --- | --- | --- |
| CR-01 | CLOSED | A copied non-Git fixture returns `{'R58-PHASE57'}` with `MUTATION_TEST_MODE=False`; `_validate_phase57_archive_members` rejects symlink and hard-link members and `assert_archive_member_safety()` returns `3`. |
| CR-02 | OPEN | The exact-token regex at `check_phase58_milestone_closeout.py:138` has no spaced aliases; a temporary source containing `let route = "teeth whitening"` is accepted by both T-58-01 and T-58-05. Phase 56 explicitly names `teeth whitening` as a forbidden alias. |
| CR-03 | OPEN | The deny-by-default token set and boundary patterns at `check_phase58_milestone_closeout.py:441-470` do not include a generic `coordinates` declaration. A temporary source containing `public var coordinates: [Float] = []` is accepted by T-58-02, despite SECURITY.md prohibiting public raw coordinates. |
| CR-04 | CLOSED | `authority_failures()` now requires `type(schema_version) is int`; the T-58-01 matrix includes boolean, null, and string mutations and reports 219 passed cases. |
| CR-05 | CLOSED | Archive validation rejects absolute/parent traversal plus symlink and hard-link members; direct archive safety self-test passes. |
| WR-01 | PARTIAL | Roadmap/state counts now agree (`27` total/completed, Phase 58 `4`, `58-04` checked), and owner checks pass. `STATE.md:11` still says “Phase 58 Plan 03 complete” while the same file records Plan 04 as stopped/completed (`STATE.md:8,28`). |
| WR-02 | OPEN | The parser requires only a substring count (`body.count("XCTAssert")`) at `check_phase58_milestone_closeout.py:610-616`. Replacing `XCTAssertEqual(canceledOutcome, .discarded)` with `fakeXCTAssertEqual(...)` leaves T-58-03 clean, so a non-asserting/no-op body is accepted. |

## Critical Issues

### CR-02: Spaced candidate aliases bypass the identity scanner

**File:** `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py:136-138`

**Issue:** `CANDIDATE_PATTERN` is built only from camelCase/snake_case/dotted/owned tokens and does not reject the documented spaced alias `teeth whitening` (nor analogous spaced eye/eyelid names). A neutral source or supplemental route can therefore carry a candidate identity while decision/output gates pass.

**Fix:** Add exact spaced aliases to the canonical identity inventory, with word boundaries and case-insensitive matching, and exercise each spelling in the authority and output mutation matrices.

### CR-03: Generic public coordinate payloads evade privacy enforcement

**File:** `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py:441-470`

**Issue:** Privacy token families omit `coordinate`/`coordinates`; the boundary regex only catches coordinates when prefixed by selected anatomy names. `public var coordinates: [Float] = []` is accepted in a temporary source, although SECURITY.md forbids raw coordinates crossing public/SPI boundaries.

**Fix:** Include coordinate/coordinates (and point/geometry aliases) in the deny-by-default token and boundary rules, while keeping only the documented aggregate allowlist exempt. Add public/SPI/Codable/persistence/logging/network coordinate mutations.

## Warnings

### WR-01: Stale lifecycle activity description after owner-count reconciliation

**File:** `.planning/STATE.md:8-11,28`

**Issue:** Counts and checklist ownership now report all four Phase 58 plans complete, but `last_activity_desc` still reports Plan 03 as complete. Consumers that display or gate on the latest activity can treat the final owner as unfinished or show stale provenance.

**Fix:** Update `last_activity_desc` to identify Plan 04 completion and keep the stopped-at/current-position fields synchronized.

### WR-02: XCTest validation still accepts fake assertion identifiers

**File:** `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py:607-631`

**Issue:** Comment/string masking is improved, but counting the substring `XCTAssert` does not prove an XCTest assertion call. A renamed helper such as `fakeXCTAssertEqual(...)` passes the lifecycle gate without asserting anything, leaving the claimed request-lifetime matrix vacuous.

**Fix:** Parse assertion call tokens (`XCTAssert[A-Za-z0-9_]*\\s*\\(`) after masking, require the exact required assertion expressions per owner, and reject helper definitions/identifiers that merely contain the token. Prefer a SwiftSyntax/AST check or execute the focused test owners when available.

---

_Reviewed: 2026-08-04T18:15:00+08:00_  
_Reviewer: the agent (gsd-code-reviewer, recheck)_  
_Depth: deep_
