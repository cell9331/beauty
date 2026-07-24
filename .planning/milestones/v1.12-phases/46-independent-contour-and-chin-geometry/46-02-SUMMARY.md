---
phase: 46-independent-contour-and-chin-geometry
plan: "02"
subsystem: geometry-testing
tags: [swift, xctest, resolver, geometry-conflict, convergence, red-first]

requires:
  - phase: 46-independent-contour-and-chin-geometry
    plan: "01"
    provides: asymmetric observed-contour fixtures and deliberately RED named face/chin provider contracts
provides:
  - RED resolver lifecycle contracts for four independent contour/chin public and effective values
  - exact 37-row, 11.70-total, once-only geometry conflict ledger
  - bounded 37-pass provider-empty convergence and no-reentry contract
affects: [46-03, 46-04, 46-05, 46-06, geometry-resolver, geometry-conflict]

tech-stack:
  added: []
  patterns:
    - table-driven public/effective key-path coverage for independent geometry values
    - one exact row ledger as the source for total, count, scale, and sign assertions
    - direct named-emission agreement for provider-empty preflight and post-scale convergence

key-files:
  created: []
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift

key-decisions:
  - "Keep all three focused suites deliberately RED until downstream plans add the four effective values, provisional caps, named emissions, resolver lifecycle, and exact 37-pass convergence loop."
  - "Represent the complete geometry inventory as one exact 37-row key-path ledger totaling 11.70, so no aggregate alias can hide an omitted or duplicated field."
  - "Use a minimally perturbed locally straight observed contour to specify a field that emits before weakening but becomes provider-empty after the shared scale."

patterns-established:
  - "Resolver rows pair each public constructor and effective key path with its direct named provider emission."
  - "Provider-empty evidence is checked across final strength, domains, warning/metric keys, point accounting, and unified dispatch."

requirements-completed: []

duration: 8 min
completed: 2026-07-23
---

# Phase 46 Plan 02: RED Resolver and Conflict Accounting Summary

**Exact RED contracts for four independent contour/chin resolver paths and a 37-field, 11.70-total monotone geometry ledger**

## Performance

- **Duration:** 8 min
- **Started:** 2026-07-23T09:08:07Z
- **Completed:** 2026-07-23T09:16:01Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Replaced the Phase 45 non-routing assertion with a four-row resolver contract covering geometry triggering, positive-only normalization, provisional `0.25` caps, exact reused `0.125`, no-face/stale/proxy failure, contour-only eligibility, explicit-zero plan equality, and direct named-emission agreement.
- Added provider-empty contracts proving invalid new work cannot activate or skip a domain, enter combined weakening, contribute geometry points, or appear in unified dispatch while a valid shipped sibling remains active independently.
- Extended the existing 33-field conflict model into one exact 37-row ledger with total `11.70`, weakened count `37`, shared scale `1 / 11.70`, positive new-field direction, and exactly one multiplication per field.
- Added an exact source-bound `0..<37` convergence gate and a representative post-scale provider-empty fixture that requires removal from the retained baseline with no re-entry and recomputed face/eye/nose/mouth evidence.

## Task Commits

Each task was committed atomically:

1. **Task 46-02-01: Write RED resolver trigger, cap, explicit-zero, and provider-empty contracts** — `f2c7c2c` (`test`)
2. **Task 46-02-02: Write RED exact 37-field conflict and once-only arithmetic contracts** — `9f5f057` (`test`)

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` — four-field resolver row descriptors, lifecycle matrix, sibling isolation, and provider-empty accounting contract.
- `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` — exact 37-field row ledger, 11.70 baseline, count/scale/sign assertions, and four-field once-only proof.
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` — exact 37-pass source gate and representative provider-empty no-reentry convergence fixture.

## Verification

- Resolver plan verification command — **PASS as inverted RED**. The underlying focused suite exits nonzero because `BeautyEffectiveStrengths` lacks the four new fields and face/chin named emissions remain absent.
- Conflict/combined plan verification command — **PASS as inverted RED** for both focused suites. Diagnostics identify the intentionally missing four provisional caps/effective fields and named face/chin emissions.
- Live source evidence remains deliberately pre-implementation: `BeautyEffectResolver.swift` contains exactly the old `for _ in 0..<28` loop and no `0..<37` loop, so the new source-bound test remains RED.
- All six required GEOM test names and both row descriptor types exist.
- The exact ledger contains 37 unique rows and asserts total `11.70`, weakened count `37`, and scale `1 / 11.70`.
- Phase 46 pre-implementation boundary checker — **PASS, 12/12**.
- `git diff --check c13bb67..HEAD` — **PASS**.
- The two task commits change only the three plan-owned XCTest files; no production, renderer, facade, Demo, resource, dependency, owner-document, or ledger file changed.

## Expected RED Evidence

- `BeautySafetyCaps.faceContourSmooth`, `.templeFullness`, `.cheekboneSlim`, and `.chinTaper` do not exist.
- `BeautyEffectiveStrengths` has no matching four effective values.
- `FaceShapeWarpProvider.fieldEmissions` and `ChinWarpProvider.fieldEmissions` do not exist.
- Resolver convergence still uses the previous exact `0..<28` ceiling.

These failures are the intended Wave 0 contract boundary and are not treated as implementation defects in this plan.

## Decisions Made

- Kept the resolver row descriptor test-private and paired every field with its direct named array, avoiding a second production accounting model.
- Derived the complete total and every post-scale assertion from one 37-row table rather than maintaining a separate four-field subtotal.
- Required final point accounting to equal the concatenated final face, chin, eye, nose, and mouth named arrays, preventing aggregate pipeline counts from masking a removed field.

## Deviations from Plan

None - implementation scope and RED contracts were executed exactly as written.

## Issues Encountered

- Focused SwiftPM failures are the required RED result for absent downstream Phase 46 production behavior.
- `state.update-progress` correctly reported 7/11 and 64% but left the persisted frontmatter percentage at 25%; the routine state bookkeeping value was corrected to the handler's reported result.

## Known Stubs

None. Missing production caps, effective fields, emissions, and convergence behavior are intentionally owned by downstream Phase 46 plans rather than stubbed in this test-only plan.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 46-03 can extend deterministic public-facade fixture support against these resolver and accounting contracts.
- Plans 46-04 and 46-05 can implement named emissions, caps, effective strengths, preflight, and 37-pass convergence without interpreting inventory or arithmetic.
- No GEOM requirement is marked complete by this RED-only plan; production behavior, integration evidence, output evidence, final caps, and promotion remain downstream.

## Self-Check: PASSED

- All three plan-owned XCTest files and this summary exist.
- Task commits `f2c7c2c` and `9f5f057` exist in repository history.
- All six required test names, both descriptor types, the exact 37-row ledger, inverted RED commands, 12/12 pre-implementation boundary checks, scope inventory, and diff hygiene were verified.

---
*Phase: 46-independent-contour-and-chin-geometry*
*Completed: 2026-07-23*
