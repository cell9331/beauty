---
phase: 90-face-contour-and-chin-repairs
plan: "02"
subsystem: geometry
tags: [swift, swiftpm, core-image, chin-taper, semantic-validation]

requires:
  - phase: 89-semantic-validation-baseline
    provides: Frozen FACE-02 centerlineTaper regions, thresholds, sign, and sibling set
provides:
  - Centerline-owned exact-cap chin taper using a bounded paired lower-chin band
  - Generated Effects and public-facade FACE-02 pixel, locality, protection, and recovery evidence
affects: [90-03, 90-04, 95-compatibility-and-sdk-only-closeout]

tech-stack:
  added: []
  patterns: [request-local paired contour band, checked PPM/Q16 pixel oracle, array-backed facade recovery]

key-files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/ChinTaperRepairTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineChinTaperRepairTests.swift
  modified:
    - BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift

key-decisions:
  - "Exact-cap and quantization-hostile taper requests expand to the narrowest three paired contour samples; sub-cap compatible contours retain the prior two-point topology."
  - "Every added source remains observed-centerline owned, X-only, bounded by 1.6% of face width, and unable to cross the interpolated median."

patterns-established:
  - "FACE-02 public evidence independently repeats the frozen PPM/Q16 oracle over generated explicit-sRGB RGBA8 bytes."
  - "Invalid centerline ownership fails only chinTaper while valid shipped siblings and later valid requests remain unchanged."

requirements-completed: [FACE-02]

duration: 13min
completed: 2026-08-28
---

# Phase 90 Plan 02: Chin Taper Repair Summary

**Exact-cap `chinTaper` now produces a deterministic centerline contraction through the existing CPU/public still-image route while keeping the apex, Y coordinates, protected pixels, sibling controls, and invalid-support paths source-safe.**

## Performance

- **Duration:** 13 min
- **Started:** 2026-08-28T06:45:00Z
- **Completed:** 2026-08-28T06:58:00Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Replaced the inert exact-cap two-neighbor field with a six-point paired lower-chin band only when exact-cap or Float quantization requires it; ordinary sub-cap compatibility remains two-point.
- Bound the provider to exact `0.25` clamping, `0.016 * face width` displacement, interpolated median ownership, unchanged Y, apex exclusion, bilateral support, deterministic traversal, and field-local failure.
- Added generated 512×512 RGBA8/sRGB Effects and public-facade oracles. The public result measured `1001` target changed pixels, `48557` absolute RGB delta, `+60 Q16` centerline taper, and `0/0` changed pixels/RGB delta outside the frozen target.
- Proved byte-identical neutral/repeat behavior, alpha and extent preservation, at least `16 Q16` semantic distance from both chin-length signs, `faceVShape`, `jawSlim`, and `faceContourSmooth`, plus no-face/missing/malformed and valid-invalid-valid recovery.

## Task Commits

Each TDD gate was committed atomically:

1. **Task 1 RED: generated provider and CPU-raster semantic oracles** - `b8c63cb` (`test`)
2. **Task 1 GREEN: centerline-owned paired chin band** - `1719690` (`feat`)
3. **Task 2 RED: public-facade semantic/protection/recovery oracles** - `2a4a40e` (`test`)
4. **Task 2 GREEN: exact-cap facade-visible paired band** - `781a409` (`fix`)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift` - Caps provider-local input, preserves sub-cap topology, and expands exact-cap/quantization-hostile support to three validated bilateral pairs.
- `BeautySDK/Tests/BeautyEffectsTests/ChinTaperRepairTests.swift` - Covers narrow/wide/asymmetric/reversed geometry, half strength, cap, Float edges, bilateral ownership, malformed support, CPU pixels, locality, protection, and determinism.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineChinTaperRepairTests.swift` - Repeats the FACE-02 metric at the existing public facade and covers aggregate metadata, siblings, invalid fixtures, and recovery.

## Verification

- `swift test --package-path BeautySDK --filter 'BeautyEngineChinTaperRepairTests|BeautyEngineGeometryFacadeTests|MissingLandmarkDegradationTests/testGEOMFreshReusedStaleFreshTransitionsCarryNoPriorFaceWork|MissingLandmarkDegradationTests/testSAFE01CompleteNineFieldFaceTransitionsAreFieldLocalAndStateless|MissingLandmarkDegradationTests/testGEOMProviderEmptyNewFieldPreservesValidShippedSibling|ChinTaperRepairTests|FaceShapeWarpProviderTests'`
  - `48` tests executed, `0` failures, `1` pre-existing opt-in Vision integration skip.
- `git diff --check` passed.
- Frozen public FACE-02 result: target `1001/48557`, signed direction `+60 Q16`, outside `0/0`; upper face, mouth, background, and watermark remained within their frozen ceilings, with background/watermark byte-exact.

## Decisions Made

- The prior two-point field stays compatible below the cap when it has geometric leverage. Exact-cap output uses three paired offsets because the existing public fixture's immediate apex neighbors do not reach the frozen FACE-02 target region.
- The expansion does not borrow legacy contour, chin-length, face-shape, backend, or renderer behavior; every target comes from the request-local median at the source Y.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Exact-cap normal support still missed the frozen public target region**
- **Found during:** Task 2 public-facade RED
- **Issue:** The Task 1 quantization-triggered band repaired the generated hostile contour, but the existing `.usableFace` fixture retained two immediate points below the chin ROI and produced `0` target signal through the public facade.
- **Fix:** Exact-cap requests now select the same narrowest three bilateral pairs; sub-cap compatible behavior remains unchanged.
- **Files modified:** `BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift`
- **Verification:** Public target moved from `0/0/0` to `1001/48557/+60 Q16`; full focused regressions passed.
- **Committed in:** `781a409`

---

**Total deviations:** 1 auto-fixed bug
**Impact on plan:** The correction was required for the plan's public FACE-02 truth and remained entirely inside the assigned provider seam.

## Issues Encountered

- The first public generated image used asymmetric chin bands and reached only `+14 Q16`. Making the deterministic left/right ink widths symmetric produced a stable `+60 Q16` without changing production thresholds or regions.
- The plan-owned test files use only generated in-memory bytes and persist no portrait, pixel, geometry, or locator. The prescribed broader `BeautyEngineGeometryFacadeTests` regression also ran its pre-existing authorized local fixture checks; this plan added no read path or durable media evidence.

## Known Stubs

None.

## Threat Flags

None. No network endpoint, authentication path, schema, model, file-access production path, public/SPI seam, renderer case, backend, or shader was added.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- FACE-02 mechanics and public-facade evidence are ready for Phase 90 integration and owner-document closeout.
- FACE-01 remains owned by Plan 90-01; this plan did not edit or stage its concurrent test file.

## Self-Check: PASSED

- All three plan-owned source/test files and this summary exist.
- RED/GREEN commits `b8c63cb`, `1719690`, `2a4a40e`, and `781a409` are present in repository history.
- The only empty-array matches are local accumulators populated before use; no UI/data-source stub is present.

---
*Phase: 90-face-contour-and-chin-repairs*
*Completed: 2026-08-28*
