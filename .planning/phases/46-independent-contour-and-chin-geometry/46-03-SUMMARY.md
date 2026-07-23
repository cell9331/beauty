---
phase: 46-independent-contour-and-chin-geometry
plan: "03"
subsystem: geometry-testing
tags: [swift, xctest, degradation, unified-warp, facade, redaction, red-first]

requires:
  - phase: 46-independent-contour-and-chin-geometry
    plan: "01"
    provides: asymmetric observed-contour fixtures and deliberately RED named face/chin provider contracts
  - phase: 46-independent-contour-and-chin-geometry
    plan: "02"
    provides: RED resolver lifecycle, exact conflict accounting, and provider-empty convergence contracts
provides:
  - representative RED support and freshness degradation matrix for all four independent geometry fields
  - exact final named-emission oracle for once-only unified pipeline dispatch
  - deterministic RED public-facade routing, shipped-sibling preservation, and aggregate-only redaction contracts
affects: [46-04, 46-05, 46-06, geometry-providers, geometry-pipeline, public-facade]

tech-stack:
  added: []
  patterns:
    - table-driven support-class and named-emission degradation coverage
    - direct final provider-array concatenation as the unified dispatch oracle
    - one-shot public-facade rows with an explicit aggregate diagnostic allowlist

key-files:
  created: []
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyGeometryEffectPipelineTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift

key-decisions:
  - "Keep all three focused suites deliberately RED until downstream plans add the four effective fields, caps, named provider emissions, and facade routing."
  - "Compare unified pipeline output directly with the stable concatenation of final face, chin, eye, nose, and mouth provider arrays so duplicate dispatch cannot hide behind aggregate counts."
  - "Limit public-facade evidence to deterministic aggregate metrics and reject geometry coordinates, support labels, framework types, and filesystem details."

patterns-established:
  - "Each degradation row binds a public parameter setter, effective key path, named emission path, and required observed-support class."
  - "Fresh, reused, stale, and renewed-fresh observations are resolved independently so no prior-face work can carry across calls."

requirements-completed: []

duration: 11 min
completed: 2026-07-23
---

# Phase 46 Plan 03: RED Degradation, Dispatch, and Facade Summary

**Executable RED contracts for field-local degradation, once-only named-emission dispatch, and redacted public-facade routing across four independent contour/chin fields**

## Performance

- **Duration:** 11 min
- **Started:** 2026-07-23T09:19:44Z
- **Completed:** 2026-07-23T09:30:37Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Added a representative support matrix covering complete, contour-only, missing or malformed centerline, legacy proxy-only, no-face, stale, reused, and locally provider-empty observations for all four independent geometry fields.
- Locked fresh-to-reused-to-stale-to-fresh statelessness, including the exact pre-combined-scale reused value of `0.125` and equality between initial and renewed-fresh plans and emissions.
- Required invalid new-field work to disappear locally while a valid shipped face-slim or chin-length sibling continues through domains, metrics, control points, and the existing geometry pipeline.
- Added an exact unified-dispatch oracle that concatenates final named face, chin, eye, nose, and mouth provider arrays in stable order and compares both pipeline overloads and resolver point accounting.
- Added deterministic one-shot public-facade route checks for each new field, explicit-zero shipped face/chin preservation checks, and a strict aggregate-only diagnostic redaction allowlist.

## Task Commits

Each task was committed atomically:

1. **Task 46-03-01: Write RED representative degradation and unified-dispatch contracts** — `a6037e5` (`test`)
2. **Task 46-03-02: Write RED deterministic observed-support facade route and redaction contracts** — `98ee836` (`test`)

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` — support/freshness row descriptor, representative degradation matrix, stateless freshness sequence, and provider-empty shipped-sibling contract.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyGeometryEffectPipelineTests.swift` — final named provider-array concatenation and exactly-once unified dispatch/accounting assertions.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` — four-field observed-support facade routing, explicit-zero sibling preservation, and expanded aggregate diagnostic redaction checks.

## Verification

- Task 46-03-01 plan command — **PASS as inverted RED** for both focused suites. The underlying build exits nonzero because the future face/chin field-emission types, provider `fieldEmissions` APIs, and four effective fields/caps are intentionally absent.
- Task 46-03-02 plan command — **PASS as inverted RED**. SwiftPM reaches the same intentional Wave 0 compile boundary before the facade suite can execute.
- All seven required test symbols exist in the three existing XCTest files.
- Phase 46 pre-implementation boundary checker — **PASS, 12/12**.
- `git diff --check e99980f..HEAD` — **PASS**.
- The two task commits change only the three plan-owned XCTest files; no production source, renderer, output helper, gallery, generated artifact, owner ledger, resource, dependency, or Demo file changed.

## Expected RED Evidence

- `FaceShapeWarpFieldEmissions` and `ChinWarpFieldEmissions` do not exist.
- `FaceShapeWarpProvider.fieldEmissions` and `ChinWarpProvider.fieldEmissions` do not exist.
- `BeautyEffectiveStrengths` and `BeautySafetyCaps` do not yet expose `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, or `chinTaper`.
- Public-facade routing and observed-support fixture behavior remain owned by downstream implementation plans.

These failures are the required RED contract boundary and are not implementation defects in this test-only plan.

## Decisions Made

- Kept support classification and named-emission selection test-private, with no parallel production model or aggregate emission alias.
- Used final provider arrays as the sole pipeline oracle and asserted exact geometry point accounting, preventing duplicated or stale arrays from passing through totals alone.
- Used a fresh deterministic detector per facade row and compared only public summaries, metrics, warnings, and output extent; raw geometry and framework internals remain unobservable.

## Deviations from Plan

None - plan scope and RED contracts were executed exactly as written.

## Issues Encountered

- Focused SwiftPM commands compile the package's other RED Phase 46 test targets first, so facade execution stops at the same intentionally missing downstream APIs. The inverted plan command passes and diagnostics are attributable only to that expected boundary.
- `state.update-progress` correctly reported 8/11 and 73% but left the persisted frontmatter percentage at 25%; routine state bookkeeping was corrected to the handler's reported result.

## Known Stubs

None. Empty byte buffers and fixture defaults in test helpers are intentional deterministic test construction, not product or UI data stubs. Missing production routing is explicitly assigned to Plans 46-04 and 46-05.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 46-04 can implement the independent face/chin provider emissions against exact degradation, sibling-preservation, and named-array contracts.
- Plan 46-05 can wire caps, effective strengths, resolver convergence, unified dispatch, and public-facade routing without inventing new accounting or diagnostic evidence.
- No GEOM requirement is marked complete by this RED-only plan; production, integration, output, final-cap, and promotion evidence remain downstream.

## Self-Check: PASSED

- All three plan-owned XCTest files and this summary exist.
- Task commits `a6037e5` and `98ee836` exist in repository history.
- All seven required symbols, both inverted RED verification commands, the 12/12 pre-implementation boundary check, scope inventory, and diff hygiene were verified.

---
*Phase: 46-independent-contour-and-chin-geometry*
*Completed: 2026-07-23*
