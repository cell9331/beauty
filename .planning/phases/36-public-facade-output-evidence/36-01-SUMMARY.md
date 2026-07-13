---
phase: 36-public-facade-output-evidence
plan: "01"
subsystem: renderer-testing
tags: [swift, public-facade, nose-geometry, regression]

requires:
  - phase: 35-public-contract-and-independent-geometry
    provides: independent public noseRootNarrowing and noseTipLift facade routing
provides:
  - exact 36-case public-facade renderer inventory with two isolated 0.25 nose cases
  - seven-case six-field nose isolation and alias rejection regression
  - representative redacted no-face facade evidence for both new fields
affects: [36-02-output-helper, 36-03-gallery-closeout, 37-nose-safety-boundary]

tech-stack:
  added: []
  patterns: [single public BeautyEngine facade render path, requirement-named no-face regression]

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyExampleRenderer/main.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift

key-decisions:
  - "Keep the two new cases isolated at exact provisional 0.25 strengths and route them through the existing single BeautyEngine.processResult loop."
  - "Reject legacy aliases through exact case-ID, initializer-label, and display-label guards so noseRootNarrowing remains valid."

patterns-established:
  - "Nose renderer evidence enumerates seven cases across exactly six public fields, with signed noseTipSize owning two cases."
  - "Representative no-face facade evidence asserts extent, category-only degradation, aggregate metrics, and redaction without expanding into exhaustive Phase 37 safety coverage."

requirements-completed: [NOSE-07, NOSE-09]

duration: 3 min
completed: 2026-07-13
---

# Phase 36 Plan 01: Public-Facade Output Contract Summary

**Two isolated 0.25 public nose cases expand the renderer to exactly 36 entries, with precise six-field isolation and redacted no-face facade regressions.**

## Performance

- **Duration:** 3 min
- **Started:** 2026-07-13T09:02:38Z
- **Completed:** 2026-07-13T09:05:40Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added exactly `noseRootNarrowing_0p25` and `noseTipLift_0p25`, each with one matching public parameter at exact `0.25`.
- Froze the ordered renderer inventory at 36 cases and the nose subset at seven isolated cases across six public fields, while retaining one shared public facade path and rejecting aliases precisely.
- Exercised both new isolated requests against the committed no-face fixture and verified unchanged extent, `.noFace` / `.noFaceDetected`, zero used faces, aggregate-only metrics/warnings, and redacted metadata.

## Task Commits

Each task was committed atomically:

1. **Task 36-01-01: Add and freeze the exact two isolated renderer cases** - `6516f86` (feat)
2. **Task 36-01-02: Lock representative no-face public-facade behavior** - `29697c0` (test)

## Files Created/Modified

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` - Adds the two isolated public-facade cases beside the existing nose cases.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` - Freezes exact inventory, isolation, alias, facade-path, and representative no-face behavior.

## Verification

- `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` passed with 10/10 XCTest cases and zero failures.
- Exact source scan passed with 36 `RenderCase` entries, each new ID once, one `engine.processResult` call site, and no internal Beauty module import.
- Scope scan found no Phase 37 promotion-owner, Demo, provider, resolver, gallery, generated-artifact, or ledger change.
- `git diff --check` passed.
- ASVS L1 threat review found no unresolved HIGH threat: exact field/case guards prevent alias or combo evidence, the renderer stays on the public facade, and no-face diagnostics remain aggregate and redacted.

## Decisions Made

- Used exact alias guards rather than broad substring rejection because `noseRoot` is a valid prefix of `noseRootNarrowing`.
- Kept representative no-face coverage limited to the two new fields; missing, stale, reused, provider-empty, all-six-field, cap, and promotion work remains Phase 37 scope.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for `36-02-PLAN.md` to regenerate and validate the discovered 36-case × 7-fixture output matrix.
- Saved-output visibility, ROI independence, gallery containment, and final NOSE-07 through NOSE-09 closeout are not claimed by this plan.
- `山根`, `提升`, and branch-level `鼻子` remain unpromoted; Phase 37 retains final caps, exhaustive safety, boundaries, and atomic promotion.

## Self-Check: PASSED

---
*Phase: 36-public-facade-output-evidence*
*Completed: 2026-07-13*
