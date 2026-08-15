---
phase: 68-cpu-algorithm-reference-oracles
plan: 02
subsystem: testing
tags: [swift, swiftpm, cpu, geometry, color, xctest, generated-fixtures]

# Dependency graph
requires:
  - phase: 68-cpu-algorithm-reference-oracles
    provides: Generated in-memory RGBA8 fixtures, transient metrics, and deterministic support stubs from Plan 68-01.
provides:
  - Table-driven geometry oracle covering all 44 current geometry fields through resolver/provider and unified CPU pipeline paths.
  - Table-driven color oracle covering skin, global tone, filters, and local lip color with semantic directional metrics.
affects: [68-04 CPU reference gate, 69 sendability and SDK closeout]

# Tech tracking
tech-stack:
  added: []
  patterns: [Target-local table-driven CPU semantic oracles, aggregate-only pixel metrics, generated sRGB fixture rendering]

key-files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/CPUReferenceGeometryOracleTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/CPUReferenceColorOracleTests.swift
  modified: []

key-decisions:
  - "Use a complete generated support face, including deterministic eye and eyebrow support, so every current geometry row reaches its real provider emission path."
  - "Judge color behavior with luminance, chroma, channel-spread, red/blue, green/red, and yellow-excess metrics; changed-byte presence is only a supporting locality observation."
  - "Keep generated pixels and support request-local in XCTest; do not add production API, algorithm, backend, Metal, UI, or media fixtures."

patterns-established:
  - "Geometry rows bind a public BeautyParameters key path, effective-strength key path, safety cap, and provider emission closure, then verify unified pipeline inclusion."
  - "Color rows render BGRA CPU pixel buffers and compare aggregate RGBA metrics while preserving alpha and exact no-op behavior."

requirements-completed: [CPU-03]

# Metrics
duration: 11min
completed: 2026-08-14
---

# Phase 68 Plan 02: Geometry and Color CPU Oracles Summary

**Semantic CPU reference suites now exercise all current geometry fields and color families with direction, locality, cap, alpha, and safety metrics over generated fixtures.**

## Performance

- **Duration:** 11 min
- **Started:** 2026-08-14T07:24:00Z
- **Completed:** 2026-08-14T07:35:51Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added a 44-row geometry inventory covering face/chin, eyes, eyebrows, nose, and mouth providers through `BeautyEffectResolver` and `BeautyGeometryEffectPipeline`.
- Added signed positive/negative direction checks, finite normalized control points, exact resolver caps, monotonic strength evidence, local warp envelopes, neutral bytes, alpha, outside sentinels, and no-global-bias checks.
- Added color rows for the four skin controls, eight global tone controls, both current filters, and local lip color using luminance/chroma/channel/red-blue/green-red/yellow-excess metrics with no-face abstention.

## Task Commits

Each task was committed atomically:

1. **Task 1: Freeze geometry direction, displacement, locality, and cap semantics** - `806b05e` (test)
2. **Task 2: Freeze color direction, chroma, red-excess, and bounded output semantics** - `5a66d2e` (test)

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceGeometryOracleTests.swift` - 44 current geometry field rows and generated raster locality/safety checks.
- `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceColorOracleTests.swift` - generated BGRA CPU color metrics, filter/lip rows, no-op and metadata/extent contracts.

## Decisions Made

- Geometry support is assembled entirely from existing target-local deterministic shapes so pupil, paired-eye, eyebrow, and observed-face rows exercise the same provider seams without persisted support data.
- Lip color uses red-blue and yellow-excess movement as the local color oracle, matching the existing transform's channel ownership while retaining chroma/alpha/containment checks.

## Deviations from Plan

None - plan executed exactly as written. Test compilation and metric calibration were resolved within the two planned test files; no production or dependency changes were required.

## Issues Encountered

- The initial phase fixture lacked pupil/eyebrow support for several taxonomy rows; the test now composes those deterministic support stubs locally, preserving the generated-only boundary.
- The existing CI color-filter path does not retain `CIImage.colorSpace` metadata after filtering, so the oracle verifies named-sRGB input and explicit named-sRGB rendering/extent while avoiding a new production behavior claim.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 68-04 can bind the two focused suites into the generated CPU-oracle preflight and aggregate the resulting test inventory.
- No Metal/GPU, UI/Demo, tracked media, device, or public API work was introduced.

## Self-Check: PASSED

- Summary and both test files exist.
- Task commits `806b05e` and `5a66d2e` are present in git history.
- Focused geometry/color suites, forbidden-token scans, and `git diff --check` passed.

---
*Phase: 68-cpu-algorithm-reference-oracles*
*Completed: 2026-08-14*
