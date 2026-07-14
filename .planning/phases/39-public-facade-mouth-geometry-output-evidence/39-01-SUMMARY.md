---
phase: 39-public-facade-mouth-geometry-output-evidence
plan: "01"
subsystem: renderer-contract
tags: [swift, public-facade, mouth-geometry, no-face, redaction]
requires:
  - phase: 38-public-contract-and-lip-support-geometry
    provides: five public controls and private provider/resolver routing
provides:
  - exact eight-case mouth geometry renderer extension
  - exact 44-case source inventory and fourteen-case mouth isolation contract
  - representative eight-case no-face facade and redaction evidence
affects: [39-02, 39-03, phase-40]
tech-stack:
  added: []
  patterns: [isolated public BeautyParameters case, aggregate-only no-face facade evidence]
key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyExampleRenderer/main.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
key-decisions:
  - "Keep all eight output cases at provisional 0.25 and route them through the one existing BeautyEngine.processResult loop."
  - "Replace the archived Phase 33 prohibition with an exact fourteen-case/nine-field mouth contract instead of deleting the guard."
patterns-established:
  - "Every renderer evidence case sets exactly one public mouth/lip field."
  - "No-face evidence combines extent/summary/metric/warning checks with field-specific redaction checks."
requirements-completed: [MOUTH-09, MOUTH-11]
duration: 4 min
completed: 2026-07-14
---

# Phase 39 Plan 01: Exact Public Renderer and No-Face Contract Summary

**Eight isolated public mouth-geometry cases extend the renderer to 44 cases with one-field source assertions and aggregate-only no-face behavior for every new direction/control.**

## Performance

- **Duration:** 4 min
- **Started:** 2026-07-14T08:23:00Z
- **Completed:** 2026-07-14T08:27:00Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added both directions of Y position, tilt, and X position plus isolated peak/plump cases at provisional `0.25`.
- Froze the ordered renderer inventory at exactly 44 and the mouth/lip subset at fourteen one-field cases across nine public fields.
- Added eight-case committed no-face-fixture evidence for extent, no-face summary, zero counts, category warning, metrics, and redaction.
- Focused `BeautyRendererOutputRegressionTests` passed 11/11 with zero failures.

## Task Commits

The source and its exact regression/no-face contract were committed as one atomic invariant:

1. **Tasks 39-01-01 and 39-01-02: Exact renderer plus no-face contract** — `4595616` (feat)

## Files Created/Modified

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — eight isolated public-facade render cases.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` — exact 44-case inventory, fourteen-case one-field mouth contract, and eight-case no-face/redaction checks.

## Decisions Made

- Kept output evidence at Phase 38's provisional `0.25`; Phase 40 still owns final-cap lock.
- Kept one public facade loop and strengthened the old mouth exclusion into an exact allowed inventory.

## Deviations from Plan

The two tightly coupled tasks share one atomic commit so the renderer source never exists in history without its exact inventory and no-face regression contract. No scope or acceptance criterion changed.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 39-02 can derive the live 44-case matrix and generate strict output evidence.
- Final caps, exhaustive safety, and all product promotion remain untouched for Phase 40.

## Self-Check: PASSED

- Both modified files exist and are committed.
- Focused suite passed 11/11; renderer source contains exactly 44 `RenderCase` entries, one facade process call, and no internal Beauty target import.
- `git diff --check` passed.

---
*Phase: 39-public-facade-mouth-geometry-output-evidence*
*Completed: 2026-07-14*
