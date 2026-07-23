---
phase: 46-independent-contour-and-chin-geometry
plan: "04"
subsystem: geometry-providers
tags: [swift, face-contour, chin-taper, named-emissions, finite-geometry]

requires:
  - phase: 46-independent-contour-and-chin-geometry
    plan: "01"
    provides: asymmetric observed-support fixtures and RED named-emission contracts
  - phase: 46-independent-contour-and-chin-geometry
    plan: "02"
    provides: RED effective-strength, cap, and provider-empty accounting contracts
  - phase: 46-independent-contour-and-chin-geometry
    plan: "03"
    provides: RED degradation, unified-dispatch, and facade-route contracts
provides:
  - four zero-default effective face/chin strengths with provisional 0.25 caps
  - seven face and two chin independently sanitizable named emission arrays
  - bounded observed-contour smoothing, temple, cheekbone, and chin-taper transforms
affects: [46-05, 46-06, face-shape-resolver, geometry-conflict, unified-warp]

tech-stack:
  added: []
  patterns:
    - shipped-first named provider emissions with field-local sanitization
    - observed-support-only finite local transforms beside the legacy proxy path
    - mean-centered smoothing with one representable uniform scale and fail-closed invariants

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift
    - BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift
    - BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift

key-decisions:
  - "Keep all four new effective values at exact zero by default and all four Phase 46 caps explicitly provisional at 0.25 pending Phase 48."
  - "Preserve the shipped proxy-backed face/chin arrays and ordering while requiring actual eligible observed support for every new emission."
  - "Fail the entire smooth field unless one shared Float-representable scale satisfies the exact ceiling, 1e-6 sum/mean and ratio tolerances, and strict roughness reduction."

patterns-established:
  - "FaceShapeWarpFieldEmissions owns exactly seven shipped-first arrays; ChinWarpFieldEmissions owns exactly two."
  - "New provider helpers validate finite/unit inputs and complete field output before constructing control points; malformed work never borrows a sibling."

requirements-completed: [GEOM-01, GEOM-02, GEOM-03, GEOM-04]

duration: 8 min
completed: 2026-07-23
---

# Phase 46 Plan 04: Independent Face and Chin Provider Emissions Summary

**Four observed-support-only contour/chin transforms now emit through exact 7+2 named provider ownership while all shipped face/chin arrays remain unchanged**

## Performance

- **Duration:** 8 min
- **Started:** 2026-07-23T09:33:55Z
- **Completed:** 2026-07-23T09:42:24Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Added `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper` to the zero-default effective ledger and assigned each an explicitly provisional exact `0.25` cap.
- Added exactly seven face and two chin named arrays, stable shipped-first concatenation, and field-local `sanitizing(_:)` behavior without changing shipped sources, targets, radii, strengths, falloff, or order.
- Implemented fail-closed observed-contour transforms: mean-centered local smoothing, disjoint upper/middle progress bands, and centerline-gated apex-neighbor taper with finite/unit validation and conservative displacement ceilings.
- Preserved `missing_face_contour` for legacy-only work while allowing eligible observed-only fields to emit independently of the seven-point compatibility proxy.

## Task Commits

Each task was committed atomically:

1. **Task 46-04-01: Add four effective values and explicit provisional caps** — `e015e08` (`feat`)
2. **Task 46-04-02: Implement seven face and two chin named emissions with four local transforms** — `19ee56a` (`feat`)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` — four zero-default effective strength slots beside the shipped face/chin ledger.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` — four exact provisional `0.25` caps with Phase 48 authority called out.
- `BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift` — exact seven-array ownership, shipped-vector preservation, field-local sanitization, and three contour transforms.
- `BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift` — exact two-array ownership, shipped signed-length preservation, and median-gated apex-adjacent taper.

## Verification

- `swift build --package-path BeautySDK --disable-sandbox` — **PASS**.
- `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` — **PASS, 17/17 tests with zero failures**.
- Provider assertions cover exact sources, directions, displacement ceilings, finite/unit bounds, strict smoothing roughness reduction, `1e-6` zero-sum/mean and shared-scale tolerances, invalid-support isolation, and shipped-array equality.
- Phase 46 live boundary checker — **13/14 expected intermediate result**: scope/privacy/artifact checks, exact 7+2 ownership, and provisional-cap wording pass; only the `0..<37` resolver convergence gate remains absent and is owned by Plan 46-05.
- `git diff --check e015e08^..19ee56a` — **PASS**.
- The commit range changes exactly the four plan-owned production files; no public model, preset, resource, dependency, renderer, facade, Demo, or generated artifact changed.

## Decisions Made

- New contour and taper emissions never fall back to `FaceGeometry.faceContour`; that compatibility proxy remains exclusive to shipped fields.
- Temple and cheekbone use exact disjoint half-open path-progress bands and one contour-derived axis, with outward and inward directions respectively.
- Smooth output is all-or-nothing after complete raw-delta centering: endpoints and horizontal extrema are excluded, no centered delta is individually clamped, and failed finite/ceiling/mean/roughness checks empty the entire field.
- Chin taper emits only `apexIndex - 1` and `apexIndex + 1`, interpolates median X at each unchanged source Y, and never emits the apex.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Made the theoretical smoothing scale representable as uniform emitted Float displacements**

- **Found during:** Task 46-04-02 focused provider verification.
- **Issue:** Applying the theoretical ceiling scale directly produced correctly centered mathematical deltas, but Float target addition/subtraction made the test-observed displacement ratios differ by about `1.7e-5`, exceeding the locked `1e-6` shared-scale tolerance.
- **Fix:** Retained the exact theoretical scale as an upper bound and selected the greatest bounded lower Float scale that makes every stored displacement share one ratio within `1e-6`; the adjustment is uniform across the complete centered set and never clamps an individual delta.
- **Files modified:** `BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift`
- **Verification:** The GEOM-01 test now passes its ceiling, sum, mean, ratio, locality, and strict roughness gates; the full focused provider suite passes 17/17.
- **Committed in:** `19ee56a`

---

**Total deviations:** 1 auto-fixed bug.
**Impact on plan:** The representability adjustment is a conservative uniform reduction below the exact ceiling and strengthens the required stored-output invariants without changing field ownership, source selection, or locality.

## Issues Encountered

- The live Phase 46 checker remains intentionally intermediate at 13/14 because Plan 46-05 owns the exact `0..<37` resolver convergence loop. All Plan 46-04-owned live gates pass.
- `state.update-progress` reported the correct 9/11 and 82% result but retained the stale frontmatter percentage; routine bookkeeping was corrected to the handler-reported value.

## Known Stubs

None. Empty arrays are deliberate fail-closed field results or local construction accumulators, not unwired product behavior.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 46-05 can route the four effective values through cap application, face-geometry triggering, freshness, preflight, exact 37-field conflict convergence, accounting, unified dispatch, and the deterministic facade fixture.
- Plan 46-06 remains responsible for the full SwiftPM/live-boundary closeout and owner-document synchronization.
- Phase 47 still owns decoded public-facade image/ROI evidence, and Phase 48 remains the authority for final caps, dead zones, exhaustive transitions, and promotion.

## Self-Check: PASSED

- The summary and all four modified production files exist.
- Task commits `e015e08` and `19ee56a` exist in repository history.
- The final Swift build, 17/17 focused provider tests, exact four-file scope, requirement inventory, and diff hygiene were reverified.

---
*Phase: 46-independent-contour-and-chin-geometry*
*Completed: 2026-07-23*
