---
phase: 53-canonical-still-image-contract-and-private-request-foundatio
plan: "02"
subsystem: still-image-input
tags: [swift, core-image, srgb, rgba8, input-validation, privacy]
requires:
  - phase: 53-01
    provides: compile-clean canonical-input RED contract and fail-closed boundary checker
provides:
  - package-only immutable canonical sRGB RGBA8 still-image carrier
  - validate-orient-color-manage-render-once decoded CIImage boundary
  - payload-free pre-Vision rejection for unsafe decoded inputs
affects: [53-03, 53-04, 53-05, 53-06, still-image, local-retouch]
tech-stack:
  added: []
  patterns: [one request-owned canonical raster, reused explicit-sRGB CIContext, fail-before-Vision validation]
key-files:
  created:
    - BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift
    - BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift
  modified:
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyCanonicalStillImageTests.swift
    - DESIGN.md
    - SECURITY.md
    - RELIABILITY.md
    - PRODUCT_SENSE.md
    - PLANS.md
key-decisions:
  - "Reuse payload-free BeautyError.invalidInput and unsupportedPixelFormat; canonical rejection does not need a new caller action."
  - "Keep the synthetic canonicalization harness package-only and add no new SPI; it exposes only opaque fixture summaries and identities."
  - "Reuse one explicit-sRGB CIContext while keeping every rendered pixel allocation request-owned."
patterns-established:
  - "Canonical carrier: one checked opaque RGBA8 Data backing supplies every package-only view."
  - "Canonicalizer order: extent/ceiling -> orientation -> color/range -> oriented bounds/overflow -> one render -> alpha scan."
requirements-completed: [PATH-02, PATH-03]
coverage:
  - id: D1
    description: One immutable zero-origin up-oriented explicit-sRGB RGBA8 raster owns accepted still pixels
    requirement: PATH-02
    verification:
      - kind: unit
        ref: "swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests#carrier/orientation/profile cases"
        status: pass
    human_judgment: false
  - id: D2
    description: Unsupported decoded still inputs reject with fixed payload-free errors before Vision or support work
    requirement: PATH-03
    verification:
      - kind: unit
        ref: "swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests#extent/orientation/color/alpha cases"
        status: pass
      - kind: other
        ref: "python3 .planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/check_still_image_foundation_boundaries.py --self-test"
        status: pass
    human_judgment: false
duration: 19min
completed: 2026-07-30
status: complete
---

# Phase 53 Plan 02: Canonical Still-Image Contract and Private Request Foundation Summary

**One checked request-owned sRGB RGBA8 raster now consumes decoded still-image orientation, mirroring, color conversion, and opacity policy exactly once before Vision**

## Performance

- **Duration:** 19 min
- **Started:** 2026-07-30T09:10:33Z
- **Completed:** 2026-07-30T09:29:47Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments

- Added one package-only immutable `BeautyCanonicalStillImage` with checked exact dimensions, row bytes, total bytes, normalized metadata, opaque backing, and a zero-origin explicit-sRGB `.RGBA8` CIImage view over the same owned data.
- Added one package-internal `BeautyStillImageCanonicalizer` that preflights decoded extents/ceiling, orientation, output-capable standard-range RGB semantics, oriented bounds, and allocation overflow before one explicit-sRGB render and alpha rejection.
- Turned all six canonical tests green across eight EXIF orientations and input-mirror variants, sRGB/Display-P3, exact/over limits, overflow-shaped extents, malformed orientation, nil/gray/CMYK/indexed/extended color, and partial/zero alpha.
- Preserved payload-free errors, request-owned pixels, the inactive 59-field behavior, and explicit encoded-container/HDR/gain-map/transparent/performance/concurrency nonclaims without adding a candidate field, provider, renderer route, facade route, realtime route, or SPI.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add the immutable canonical raster carrier** - `9c22ecf` (feat)
2. **Task 2: Implement validate-orient-color-manage-render-once rejection ordering** - `5b53650` (feat)

## Files Created/Modified

- `BeautyCanonicalStillImage.swift` - Package-only immutable checked RGBA8 owner and zero-origin sRGB image view.
- `BeautyStillImageCanonicalizer.swift` - Reused-context validation, orientation/mirror, color conversion, allocation, render, and opacity boundary.
- `BeautyEngineTestingSupport.swift` - Package-only synthetic fixture/result harness; no new SPI.
- `BeautyCanonicalStillImageTests.swift` - Production-backed canonical and fail-before-Vision contract cases.
- `DESIGN.md` - D-05/D-17 carrier ownership and verification contract.
- `SECURITY.md` - D-06/D-07 decoded-input trust boundary and privacy-safe rejection contract.
- `RELIABILITY.md` - D-18 error mapping, ordering, recovery, ownership, and nonclaims.
- `PRODUCT_SENSE.md` - Integrator-facing canonical still-input acceptance and excluded claims.
- `PLANS.md` - Command-backed Wave 1 execution evidence.

## Decisions Made

- Kept `.invalidInput` for malformed extent/orientation, ceiling/overflow, and alpha rejection; kept `.unsupportedPixelFormat` for unknown, non-RGB, non-output-capable, and extended-range color. These existing cases are payload-free and already provide the only two stable caller actions needed.
- Kept the canonical test harness package-only instead of exporting canonical bytes or adding testing SPI. Its digest and backing identity cover only deterministic synthetic fixtures.
- Reused the canonicalizer's explicit-sRGB `CIContext` across calls while allocating and retaining canonical pixels only in each returned request value.
- Enforced only decoded `CIImage` facts. Original encoded bytes, malformed container metadata not retained by the host decode, gain maps, and HDR container inventory remain intentionally unobservable.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- SwiftPM's nested manifest sandbox intermittently failed with `sandbox_apply: Operation not permitted`; the focused suite was rerun outside the sandbox with the repository's existing `/private/tmp/beauty-clang-module-cache` convention and passed.
- The local Core Graphics SDK requires current Swift spellings (`CGColorSpace.supportsOutput` and `CGColorSpace(indexedBaseSpace:last:colorTable:)`); compilation identified the obsolete C spellings, which were corrected before verification.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 53-03 can attach actual observed lip support to the existing single Vision/mapping boundary without owning a second orientation or color interpretation.
- Plan 53-04 can route admitted private still requests through the canonical carrier while legacy inactive and pixel-buffer paths remain unchanged.
- Transparent/HDR/gain-map, encoded-input/container validation, feature admission, same-engine concurrency/cancellation, and performance/device/release evidence remain explicitly outside this result.

## Self-Check: PASSED

- Created files `BeautyCanonicalStillImage.swift` and `BeautyStillImageCanonicalizer.swift` exist.
- Task commits `9c22ecf` and `5b53650` exist in history.
- `BeautyCanonicalStillImageTests` passes 6/6, including exact size/backing, all orientation/mirror variants, profile conversion, limits/overflow, color/range, and alpha rejection.
- Boundary checker self-test passes 6/6 and preserves exact `16 = 13 automated + 3 flagged` equality.
- Rejected-input tests keep detector/support counters at zero and accept only payload-free `.invalidInput` / `.unsupportedPixelFormat`.
- Source scans find no candidate field/route, new SPI, device-RGB canonical render, or byte-bearing exported carrier surface.
- `git diff --check` passes.

---
*Phase: 53-canonical-still-image-contract-and-private-request-foundatio*
*Completed: 2026-07-30*
