---
phase: 52-eyebrow-safety-and-branch-closeout
plan: "01"
subsystem: eyebrow-geometry-safety
tags: [swift, eyebrow, geometry, safety, lifecycle, concurrency]
status: complete

requires:
  - phase: 51-public-facade-eyebrow-output-evidence
    provides: Accepted public-facade direction, locality, distinction, and no-face output evidence
provides:
  - Exact final 0.25 cap and Float.ulpOfOne dead-zone contract for all seven eyebrow fields
  - One typed seven-row executable oracle for parameters, strengths, emissions, semantics, reuse, radii, and unavailable support
  - Exhaustive request-local lifecycle, local-failure, transition, concurrency, interruption, sibling, extent, and redaction evidence
affects: [52-02-combined-convergence, 52-03-security-gates, 52-04-product-promotion]

tech-stack:
  added: []
  patterns: [typed test descriptor, named cap authority, separate strength and geometry tolerances, request-local isolation]

key-files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift
    - BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift

key-decisions:
  - "Use BeautySafetyCaps as the only final eyebrow maximum authority while binding each named cap once per provider evaluation."
  - "Keep Float.ulpOfOne solely as the strength dead zone and retain 0.000001 only for topology, face, vector, and radius validity."
  - "Drop only non-representable source-target pairs after all finite/unit checks pass, so adjacent eligible strength is not confused with malformed geometry."

requirements-completed: [SAFE-01, SAFE-02]

coverage:
  - id: exact-cap-contract
    description: "Seven exact caps, dead-zone adjacency, signed/positive-only semantics, overflow accounting, final named provider maximums, and bounded radii."
    requirement: SAFE-01
    verification:
      - kind: unit
        ref: "BeautySafetyCapsTests 7/7; BeautyEffectResolverTests 27/27; EyebrowWarpProviderTests 14/14"
        status: pass
    human_judgment: false
  - id: lifecycle-local-failure
    description: "Fresh, reused, stale, no-face, nil, single-side, missing chord/apex, provider-empty, both-direction, and valid-invalid-valid behavior is stateless and field-local."
    requirement: SAFE-02
    verification:
      - kind: unit
        ref: "MissingLandmarkDegradationTests 51/51"
        status: pass
    human_judgment: false
  - id: facade-isolation
    description: "Parallel/interrupted work remains request-local while public output extent, safe siblings, and aggregate-only diagnostics remain stable."
    requirement: SAFE-02
    verification:
      - kind: integration
        ref: "BeautyEngineGeometryFacadeTests 20 executed, 1 explicit opt-in skip, 0 failures"
        status: pass
    human_judgment: false

duration: 15 min
completed: 2026-07-27
---

# Phase 52 Plan 01: Eyebrow Safety and Lifecycle Summary

**Seven final eyebrow caps now share one authority, exact dead-zone adjacency, bounded named emissions, and deterministic request-local lifecycle behavior.**

## Performance

- **Duration:** 15 min
- **Started:** 2026-07-27T03:06:53Z
- **Completed:** 2026-07-27T03:21:21Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments

- Replaced provisional eyebrow-cap ownership with seven exact final `0.25` constants and one typed descriptor covering public construction, effective key paths, named emissions, semantics, reuse, radii, and narrowest unavailable support.
- Corrected the provider's overloaded tolerance so `Float.ulpOfOne.nextUp` is eligible when its displacement is representable, while malformed topology, vectors, bounds, radii, and non-representable point work still fail closed.
- Proved all seven lifecycle and local-failure rows across fresh `0.25`, reused `0.125`, stale/no-face zero, nil/single-side/chord/apex/provider-empty degradation, both direction transitions, valid-invalid-valid recovery, parallel completion order, cancellation, safe siblings, public extent, and aggregate-only diagnostics.

## Task Commits

Each task was committed atomically; the two TDD tasks retain their RED and GREEN commits:

1. **Task 52-01-01: Establish the shared seven-field oracle and freeze exact cap adjacency**
   - `9b6d444` — RED: add failing cap ownership and safety matrix.
   - `de530fe` — GREEN: finalize Phase 52 cap ownership.
2. **Task 52-01-02: Make provider acceptance match the final cap and prove every support boundary**
   - `6e75ab7` — RED: add failing ULP-adjacency, radius, and prerequisite tests.
   - `8760047` — GREEN: align named provider maxima and separate strength/topology tolerances.
3. **Task 52-01-03: Complete the stateless transition, concurrency, sibling, and facade matrix**
   - `ba056c3` — complete lifecycle, isolation, sibling, extent, and redaction coverage.

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift` — Shared seven-row safety oracle plus request-local eligible/unavailable fixtures.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` — Final Phase 52 ownership for the seven exact `0.25` caps.
- `BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift` — Named cap binding, exact strength dead zone, and distinct geometry validity tolerance.
- `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` — Exact descriptor cardinality and final ownership evidence.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` — Exact-cap, adjacent overflow, direction, non-finite, warning, metric, and redaction matrix.
- `BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift` — Provider adjacency, radius, bounds, and local-prerequisite evidence.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` — Exhaustive lifecycle, transition, sibling, parallel, and interruption evidence.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` — Seven public no-face extent, safe-domain, cap-accounting, and redaction cases.

## Decisions Made

- Bound each named `BeautySafetyCaps` value once inside `fieldEmissions` and passed that value through acceptance, formula division, and final point validation. This keeps the safety constants authoritative without a provider-owned maximum.
- Preserved `0.000001` for geometry/topology validity only. The public/provider strength dead zone is exactly `Float.ulpOfOne`.
- Filtered only equal source-target pairs after the complete finite/unit validation succeeds. This retains representable adjacent-strength work without allowing invalid geometry to pass.

## Deviations from Plan

None - plan executed exactly as written. Task 02 explicitly anticipated and owned the discovered strength-versus-topology epsilon defect.

## Issues Encountered

- The initial provider-reference gate counted repeated direct constant uses rather than seven unique names. Binding each named final cap once per evaluation made acceptance, formulas, and point maximums share one value and satisfied the exact seven-reference gate.

## Known Stubs

None. Empty arrays and optional nil values in the modified tests are deliberate unavailable-support fixtures or local collection initialization, not UI/data stubs.

## Threat Flags

None. The plan changed no public/SPI surface, network endpoint, persistence path, authentication path, file-access trust boundary, or schema.

## User Setup Required

None.

## Next Phase Readiness

- Plan 52-02 can use the final seven caps and shared descriptor to freeze exact 44-field convergence and final named-dispatch agreement.
- Product rows, branch `眉毛`, SAFE-03, DOC-01, and Phase 52 completion remain unchanged and pending in later plans.

## Self-Check: PASSED

- All eight production/test files exist; the new shared fixture is tracked.
- Commits `9b6d444`, `de530fe`, `6e75ab7`, `8760047`, and `ba056c3` exist in git history.
- Final focused evidence passes 7 cap tests, 27 resolver tests, 14 provider tests, 51 degradation tests, and 20 facade tests with one explicit opt-in Apple Vision integration skip.
- Seven exact cap declarations, seven distinct provider authority references, no provisional marker, and `git diff --check` all pass.

---
*Phase: 52-eyebrow-safety-and-branch-closeout*
*Completed: 2026-07-27*
