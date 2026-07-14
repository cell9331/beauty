---
phase: 21-baseline-audit-and-quality-ledger-refresh
plan: 01
subsystem: audit
tags: [baseline, sdk-tests, renderer, xcodebuild, privacy, debt]

requires:
  - phase: 20-core-module-closeout
    provides: v1.3 SDK, renderer, scope-scan, and limitation evidence used as archived comparison
provides:
  - Current Phase 21 baseline audit evidence in 21-BASELINE-AUDIT.md
  - Current SDK test and renderer command results
  - Reproducible Demo simulator build/test tooling blocker
  - TD-005, TD-008, TD-009, and TD-010 routing inputs
affects: [QUALITY_SCORE, PLANS, v1.4, phase-22, phase-23, phase-24, phase-25]

tech-stack:
  added: []
  patterns: [evidence-ledger, blocked-tooling-classification, stale-map-disposition]

key-files:
  created:
    - .planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md
  modified: []

key-decisions:
  - "Demo simulator build/test evidence is blocked by missing local Metal Toolchain, not by a verified Swift source failure."
  - "Stale .planning/codebase maps remain stale risk records and were not refreshed."
  - "Generated renderer outputs remain ignored local evidence and are not committed."

patterns-established:
  - "Phase 21 evidence rows classify current pass/fail/blocker/deferred/archived status before ledger interpretation."
  - "Hardware/tooling blockers include exact command, destination or assumption, environment, impact, and next step."

requirements-completed: [AUD-01, AUD-02, AUD-03, AUD-04]

duration: 35 min
completed: 2026-06-30
---

# Phase 21 Plan 01: Baseline Verification Sweep and Evidence Ledger Summary

**Current v1.4 baseline evidence now distinguishes passing SDK/renderer checks from blocked Demo simulator build/test evidence and routed manual/hardware debt.**

## Performance

- **Duration:** 35 min
- **Started:** 2026-06-30T07:09:00Z
- **Completed:** 2026-06-30T07:44:53Z
- **Tasks:** 3
- **Files modified:** 1

## Accomplishments

- Created `21-BASELINE-AUDIT.md` with environment, command inventory, SDK, renderer, static/privacy, planning consistency, stale-map, debt-routing, and manual/hardware sections.
- Ran current SwiftPM SDK and renderer checks: `swift test --package-path BeautySDK` passed with 141 tests, renderer build passed, and renderer run wrote 45 ignored non-empty PNGs.
- Ran explicit Demo simulator build evidence and classified missing local Metal Toolchain as a reproducible blocker for Demo build/test and Phase 22 screenshot work.

## Task Commits

1. **Task 1: Record toolchain, project, simulator, and command inventory** - `5f3ba69` (docs)
2. **Task 2: Run SDK, renderer, and output-baseline checks** - `221a8b4` (docs)
3. **Task 3: Run static boundary, privacy, root, and debt inventory scans** - `0edfc21` (docs)

## Files Created/Modified

- `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` - Current baseline audit ledger for Wave 2 score/debt updates.

## Decisions Made

- Demo simulator build/test pass cannot be claimed until the missing local Metal Toolchain is installed and explicit-destination build/test commands pass.
- Current Phase 21 evidence is separated from archived Phase 20 evidence; archived records support context but do not replace current command runs.
- TD-005, TD-008, TD-009, and TD-010 remain routed/open inputs, not fixed Phase 21 outcomes.

## Deviations from Plan

None - plan executed exactly as written.

---

**Total deviations:** 0 auto-fixed.
**Impact on plan:** None.

## Issues Encountered

- Explicit Demo simulator build failed because Xcode could not execute `metal` due to a missing Metal Toolchain component. This was recorded as a local tooling blocker with command, destination, environment, impact, and next step.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 21-02. The next plan should update `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `21-VERIFICATION.md` from the evidence in `21-BASELINE-AUDIT.md` without fixing later-phase debt.

## Self-Check: PASSED

- `21-BASELINE-AUDIT.md` exists and contains all planned sections.
- Task commits exist for `21-01`.
- `git diff --check` passed for `21-BASELINE-AUDIT.md` and this summary.
- No `BeautySDK` or `BeautyDemo` source changes were introduced by Plan 21-01.

---
*Phase: 21-baseline-audit-and-quality-ledger-refresh*
*Completed: 2026-06-30*
