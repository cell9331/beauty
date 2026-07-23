---
phase: 46-independent-contour-and-chin-geometry
plan: "05"
subsystem: geometry-integration
tags: [swift, resolver, conflict-ledger, observed-support, facade]

requires:
  - phase: 46-independent-contour-and-chin-geometry
    plan: "04"
    provides: four provisional effective fields and exact 7+2 named face/chin emissions
provides:
  - complete four-field cap, freshness, provider-preflight, domain, and facade lifecycle
  - exact 37-field retained-baseline conflict convergence with once-only final accounting
  - deterministic asymmetric observed-support input through the production mapper and adapter
affects: [46-06, geometry-resolver, geometry-conflict, public-facade]

tech-stack:
  added: []
  patterns:
    - provider-emitting retained fields are the sole authority for conflict and aggregate evidence
    - stable face-to-chin-to-eye-to-nose-to-mouth preflight and post-scale sanitization
    - deterministic testing input traverses the real mapping and validation boundary

key-files:
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
    - BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
    - BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift
    - BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift

key-decisions:
  - "Fresh provider-empty new work disappears from active/skipped evidence; no-face and stale requests retain the generic face-shape degradation signal."
  - "All final strengths, domains, warnings, metrics, geometry point counts, and unified dispatch derive from the same post-conflict named emissions."
  - "Accumulate the exact 37-field total through Double intermediates and convert once to Float to avoid order-dependent 11.70 drift."

requirements-completed: [GEOM-01, GEOM-02, GEOM-03, GEOM-04]

duration: 9 min
completed: 2026-07-23
---

# Phase 46 Plan 05: Resolver, Conflict, and Facade Integration Summary

**Four independent contour/chin fields now route from public intent through provider-owned eligibility, exact 37-field convergence, one unified warp, and redacted public-facade evidence.**

## Accomplishments

- Added all four fields to geometry triggering, provisional capping, eligible reuse scaling, no-face/stale zeroing, face/chin provider preflight, and final domain/accounting decisions.
- Expanded the retained-baseline convergence loop to exactly `0..<37`, sanitizing face, chin, eye, nose, and mouth emissions after every shared scale without allowing removed fields to re-enter.
- Replaced aggregate face-pipeline point counting with exact final face plus chin named-emission counts; eye, nose, and mouth final arrays are each counted once.
- Added an asymmetric 11-point contour and 3-point median to the existing `.usableFace` testing fixture. The payload traverses the production Vision mapper, Phase 45 validator, adapter, resolver, and facade.

## Task Commits

1. **Tasks 46-05-01/02: Route the four fields and converge/account the exact retained set** — `e02f5cd`
2. **Task 46-05-03: Supply deterministic observed support through the existing fixture** — `32f2909`

The first two tasks share the same resolver transaction and were committed together after the typed executor exhausted its external usage quota. No partial executor changes existed.

## Verification

- `BeautyEffectResolverTests` — **21/21 passed**.
- `GeometryConflictResolverTests` — **13/13 passed**.
- `CombinedEffectSafetyTests` — **14/14 passed**.
- `BeautyGeometryEffectPipelineTests` — **2/2 passed**.
- `MissingLandmarkDegradationTests` — **43/43 passed**.
- `BeautyEngineGeometryFacadeTests` — **15/15 passed**.
- Phase 46 boundary checker self-test — **24/24 passed**.
- Phase 46 live boundary checker — **14/14 passed**.
- `git diff --check` — **passed**.

## Deviations from Plan

### Auto-fixed integration defects

- Extended the Phase 46-04 Float-scale search and added a bounded single-scale quantization fallback so exact cap/reuse strengths and real mapped fixture coordinates remain finite, centered, bounded, and observable without per-point clamps.
- Made near-straight smoothing strength-responsive so the planned post-scale provider-empty case fails closed and cannot re-enter the retained set.
- Stabilized the exact 37-field `11.70` total with Double accumulation and aligned the generated test oracle; the previous Float left-fold produced `11.700002`.

No public API, renderer, Demo, dependency, resource, model, network, or generated-output surface was added.

## Next Phase Readiness

Plan 46-06 can run full SwiftPM/static evidence and synchronize the architecture, design, security, reliability, product-acceptance, and execution owners. Decoded output remains Phase 47; final caps, exhaustive matrices, and promotion remain Phase 48.

---
*Phase: 46-independent-contour-and-chin-geometry*
*Completed: 2026-07-23*
