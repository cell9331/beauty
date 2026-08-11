---
phase: 63-guarded-per-eye-sclera-production-integration
plan: "02"
subsystem: image-effects
tags: [swift, sclera, per-eye, hard-envelope, q16]
requires:
  - phase: 63-01
    provides: frozen RED provider, transform and mutation contracts
provides:
  - stateless canonical-order per-eye sclera provider
  - pre-score anatomy guard and post-feather hard reclip
  - immutable-source bounded red-excess transform and zero-to-two units
affects: [63-03, 63-04, sclera-output]
tech-stack:
  added: []
  patterns: [per-eye-local-abstention, geometry-before-color, immutable-source-target]
key-files:
  created:
    - BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift
    - BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessTransform.swift
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessProviderTests.swift
key-decisions:
  - "Ambiguous side ownership rejects all sclera work; canonical missing or malformed support rejects only that side."
  - "Frozen mechanics constants use a 12% checked-ROI contour margin and actual-pupil ellipse scaling of 27% eye width by 40% eye height."
  - "The transform caps effective strength at 0.52 and restores source luminance before deterministic RGBA8 quantization."
patterns-established:
  - "Hard guard is aperture erosion minus actual-pupil, expanded highlight and expanded lash exclusions before score."
  - "Provider emits stable left-then-right owner-issued units with aggregate outcomes only."
requirements-completed: [SCLERA-09, SCLERA-10, SCLERA-11, SCLERA-12, SCLERA-13]
coverage:
  - id: D1
    description: "Per-eye validation, hard guard, score and peer-local abstention are deterministic."
    requirement: SCLERA-10
    verification:
      - kind: unit
        ref: "BeautyScleraRednessProviderTests (11 tests)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Targets are source-only, bounded and composed once with collision-to-source semantics."
    requirement: SCLERA-12
    verification:
      - kind: unit
        ref: "BeautyScleraRednessProviderTests + BeautyLocalRetouchCompositionTests (32 tests)"
        status: pass
      - kind: other
        ref: "check_phase63_sclera_provider_boundaries.py --provider"
        status: pass
    human_judgment: false
duration: 6 min
completed: 2026-08-07
status: complete
---

# Phase 63 Plan 02: Guarded Per-Eye Provider Summary

**A stateless package provider now converts actual canonical eye support into independently guarded source-derived sclera units with post-feather containment.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-08-07T10:40:36Z
- **Completed:** 2026-08-07T10:46:50Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Implemented finite/simple contour and exact actual-pupil validation with
  stable left/right outcomes and affected-eye-only abstention.
- Built aperture erosion plus pupil/iris, highlight and lash exclusions before
  redness score, followed by radius-one softening and exact hard reclip.
- Implemented source-only measured-red-excess reduction, luminance restoration,
  Q16-once unit creation, alpha identity and collision-to-source proof.

## Task Commits

1. **Task 1: Implement per-eye validation and guard-before-score selection** — `2c1766b`
2. **Task 2: Prove bounded target and owner-unit collision safety** — `5ad6842`

## Files Created/Modified

- `BeautyScleraRednessProvider.swift` — checked per-eye raster, guard, score and units.
- `BeautyScleraRednessTransform.swift` — bounded immutable-source color target.
- `BeautyScleraRednessProviderTests.swift` — 11 provider/transform/peer/collision tests.

## Decisions Made

- Input arrays are normalized to stable left-then-right processing without
  changing anatomical ownership.
- Geometry and protected-source exclusions are authoritative; the redness score
  cannot compensate for a missing guard.
- Thresholds remain conservative and unchanged after the focused test result.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Implemented the transform in Task 1**
- **Found during:** Task 1 provider compilation.
- **Issue:** Unit issuance depends on the source-target type, so the provider could not compile independently.
- **Fix:** Added the bounded transform with the provider, then used Task 2 for composition/collision closeout.
- **Verification:** 11 provider tests and provider HIGH mode pass.
- **Committed in:** `2c1766b`

**2. [Rule 1 - Test Fixture] Replaced broad rectangular support with an eye aperture polygon**
- **Found during:** Task 1 focused tests.
- **Issue:** The rectangle intentionally enclosed background skin and contradicted the actual-aperture contract.
- **Fix:** Used a deterministic 16-point elliptical contour while retaining malformed rectangle cases.
- **Verification:** Protected skin/exterior and peer tests pass.
- **Committed in:** `2c1766b`

**Total deviations:** 2 auto-fixed (one blocking dependency, one fixture bug). **Impact:** No scope expansion; both preserve the frozen safety contract.

## Issues Encountered

None after the two bounded fixes.

## User Setup Required

None.

## Next Phase Readiness

Ready for 63-03 engine wiring and lifecycle observations. The provider remains
package-only and no renderer, Demo or public output promotion changed.

## Self-Check: PASSED

- Provider and transform files exist.
- 11 provider tests pass; provider plus composition selection is 32/32.
- T-63-02 through T-63-05 provider checker mode passes 4/4.
- Both task commits exist and no private media/path is tracked.

