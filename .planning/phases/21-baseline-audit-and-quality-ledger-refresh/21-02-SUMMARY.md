---
phase: 21-baseline-audit-and-quality-ledger-refresh
plan: 02
subsystem: quality-ledger
tags: [quality-score, debt-routing, planning-ledger, verification]

requires:
  - phase: 21-baseline-audit-and-quality-ledger-refresh
    plan: 01
    provides: Current baseline evidence in 21-BASELINE-AUDIT.md
provides:
  - Refreshed v1.4 quality baseline in QUALITY_SCORE.md
  - Routed TD-005, TD-008, TD-009, TD-010, and stale codebase map debt
  - Completed AUD-01 through AUD-04 traceability
  - Phase 21 closeout verification in 21-VERIFICATION.md
affects: [QUALITY_SCORE, PLANS, PROJECT, STATE, REQUIREMENTS, ROADMAP, phase-22, phase-23, phase-24, phase-25]

tech-stack:
  added: []
  patterns: [evidence-backed-score-refresh, debt-route-ledger, blocker-preserving-closeout]

key-files:
  created:
    - .planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-VERIFICATION.md
  modified:
    - QUALITY_SCORE.md
    - PLANS.md
    - .planning/PROJECT.md
    - .planning/STATE.md
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md

key-decisions:
  - "Phase 21 closes the baseline audit requirements without fixing later-phase QA, performance, renderer, or privacy debt."
  - "Demo simulator build/test pass is not claimed while the local Metal Toolchain blocker remains."
  - "Current .planning scope text was cleaned up; remaining scope-scan hits are historical PLANS.md false positives."
  - "Stale .planning/codebase/* maps are recorded as TD-011 and left deferred."

patterns-established:
  - "Quality-score changes cite the current audit artifact, not archived-only evidence."
  - "Technical-debt rows name the exact routed phase or blocker instead of staying vague open risks."

requirements-completed: [AUD-01, AUD-02, AUD-03, AUD-04]

duration: 50 min
completed: 2026-06-30
---

# Phase 21 Plan 02: Quality Score, Debt Routing, and Planning Ledger Refresh Summary

**Phase 21 is closed as an audit/ledger-refresh phase, with current SDK and renderer evidence passing and Demo simulator evidence explicitly blocked by missing local Metal Toolchain.**

## Performance

- **Duration:** 50 min
- **Started:** 2026-06-30T07:45:00Z
- **Completed:** 2026-06-30T08:55:00Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments

- Refreshed `QUALITY_SCORE.md` from `21-BASELINE-AUDIT.md`, including the 141-test SDK pass, renderer build/run pass, 45 ignored output baseline, Demo Metal Toolchain blocker, privacy manifest absence, and stale `.planning/codebase/*` disposition.
- Routed TD-005 to Phase 25, TD-008 to Phase 22/23 with physical iPhone evidence blocked until hardware exists, TD-009 to Phase 22, TD-010 across Phases 22/23/24/25, and TD-011 as deferred stale codebase-map work.
- Updated `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/REQUIREMENTS.md`, and `.planning/ROADMAP.md` so AUD-01 through AUD-04 are complete and Phase 22 is next.
- Created `21-VERIFICATION.md` with closeout evidence and remaining routed work.

## Task Commits

1. **Task 1: Refresh QUALITY_SCORE.md from the baseline evidence** - `c1af498` (docs)
2. **Task 2: Route technical debt and synchronize current planning ledgers** - `a53a001` (docs)
3. **Task 3: Create closeout verification and run consistency gates** - `5d37dab` (docs)

## Files Created/Modified

- `QUALITY_SCORE.md` - Current v1.4 baseline snapshot, Phase 21 evidence section, repair queue, and decision log.
- `PLANS.md` - Phase 21 completed ledger entry and routed Tech Debt rows.
- `.planning/PROJECT.md` - Current Phase 21 baseline and toolchain blocker context.
- `.planning/STATE.md` - Phase 21 complete, Phase 22 next.
- `.planning/REQUIREMENTS.md` - AUD-01 through AUD-04 marked complete.
- `.planning/ROADMAP.md` - Phase 21 progress set to 2/2 complete.
- `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-VERIFICATION.md` - Closeout verification.

## Decisions Made

- Phase 21 does not claim current Demo simulator build/test success; Phase 22 must rerun after Metal Toolchain repair or document the same blocker.
- Release-like visual naturalness, hardware parity, performance budgets, long-run checks, renderer regression thresholds, and privacy manifest completion remain routed to later v1.4 phases.
- Exact negative scope scan hits in old `PLANS.md` completed entries are historical false positives; active `.planning` scope files have no matching expansion claims.

## Deviations from Plan

- The exact Plan 21-02 negative scope scan still reports historical `PLANS.md` lines from completed older phases. Current `.planning/PROJECT.md`, `.planning/STATE.md`, and `.planning/ROADMAP.md` were reworded and scanned clean. This is recorded in `21-VERIFICATION.md` as a false positive, not an active scope issue.

---

**Total deviations:** 1 classified false positive.
**Impact on plan:** None; current ledgers preserve v1.4 hardening-only scope.

## Issues Encountered

- The Demo simulator build/test blocker remains: local Xcode cannot execute `metal` until the Metal Toolchain component is installed.

## User Setup Required

- Run `xcodebuild -downloadComponent MetalToolchain` before Phase 22 if current Demo simulator build/test and screenshot capture should execute on this machine.

## Next Phase Readiness

Ready for `$gsd-discuss-phase 22`.

## Self-Check: PASSED

- `QUALITY_SCORE.md` and planning ledgers cite Phase 21 evidence instead of archived-only claims.
- AUD-01 through AUD-04 are complete in `.planning/REQUIREMENTS.md`.
- `21-VERIFICATION.md` exists with `status: passed`.
- `verify.schema-drift 21` reported no drift.
- No Swift source, public API, SwiftUI route, renderer case, or privacy manifest change was introduced.

---
*Phase: 21-baseline-audit-and-quality-ledger-refresh*
*Completed: 2026-06-30*

