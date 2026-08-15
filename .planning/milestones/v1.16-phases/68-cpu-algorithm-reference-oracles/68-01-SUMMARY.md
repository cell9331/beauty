---
phase: 68-cpu-algorithm-reference-oracles
plan: 01
subsystem: testing
tags: [swiftpm, xctest, cpu, rgba8, srgb, fixtures, metrics]

# Dependency graph
requires:
  - phase: 67-swiftpm-consumer-and-cli-validation-contract
    provides: SDK-only SwiftPM test and consumer validation boundary
provides:
  - Deterministic in-memory RGBA8/sRGB fixtures for CPU reference tests
  - Aggregate-only pixel, color, geometry, and region metric primitives
  - Public-facade CIImage and transparent-input validation fixtures
affects: [68-02, 68-03, 68-04, cpu-oracles]

# Tech tracking
tech-stack:
  added: []
  patterns: [target-local generated fixtures, transient aggregate metrics, exact alpha and metadata contracts]

key-files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/CPUReferenceFixtureFactory.swift
    - BeautySDK/Tests/BeautyEffectsTests/CPUReferenceMetrics.swift
    - BeautySDK/Tests/BeautyEffectsTests/CPUReferenceFixtureTests.swift
    - BeautySDK/Tests/BeautyCoreTests/CPUReferenceFacadeFixtureFactory.swift
    - BeautySDK/Tests/BeautyCoreTests/CPUReferenceFacadeFixtureTests.swift
  modified: []

key-decisions:
  - "Keep mandatory CPU evidence target-local and generated in memory; no portrait media or production/SPI fixture surface is added."
  - "Use exact named-sRGB RGBA8 dimensions, alpha, metadata, and fail-closed transparent-input contracts as the facade baseline."

patterns-established:
  - "Fixture builders return transient bytes/CIImage/support values and never write media or persist raw evidence."
  - "Metric helpers report aggregate sets and scalar color/geometry values without printing pixels, coordinates, masks, or paths."

requirements-completed: [CPU-01]

# Metrics
duration: 12m
completed: 2026-08-14
---

# Phase 68 Plan 01: Generated CPU Fixture Foundation Summary

**Deterministic in-memory RGBA8/sRGB fixtures and aggregate CPU metrics now underpin the mandatory SwiftPM oracle suites.**

## Performance

- **Duration:** 12 minutes
- **Started:** 2026-08-14T07:10:00Z (approximate)
- **Completed:** 2026-08-14T07:22:35Z
- **Tasks:** 2
- **Files modified:** 5 created

## Accomplishments

- Added generated opaque color-ramp, checker, geometry-gradient, alpha-boundary, protected/outside, and deterministic support fixtures to `BeautyEffectsTests`.
- Added transient changed-index, alpha, luminance/chroma, red/yellow-excess, displacement, direction, locality, and finite-normalized metric primitives.
- Added independent `BeautyCoreTests` facade fixtures for named-sRGB CIImage inputs, exact metadata/extent/byte contracts, repeatability, and transparent local-retouch fail-closed validation.

## Task Commits

Each task was committed atomically:

1. **Task 1: Build target-local generated CPU fixture and metric support** - `cc3199f` (test)
2. **Task 2: Add public-facade generated input and boundary contracts** - `94be4c8` (test)

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceFixtureFactory.swift` - In-memory RGBA8 patterns, region labels, and complete/malformed/no-face support stubs.
- `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceMetrics.swift` - Aggregate-only transient metric functions.
- `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceFixtureTests.swift` - Fixture completeness, determinism, and no-media contract tests.
- `BeautySDK/Tests/BeautyCoreTests/CPUReferenceFacadeFixtureFactory.swift` - Generated public-facade CIImage inputs and test metadata.
- `BeautySDK/Tests/BeautyCoreTests/CPUReferenceFacadeFixtureTests.swift` - Facade shape, color-space, alpha, repeatability, and fail-closed contracts.

## Decisions Made

- Mandatory CPU fixtures remain generated and target-local so clean clones need no portrait media and the BeautySDK public/SPI surface remains unchanged.
- Transparent local-retouch input is exercised through the public facade and must return typed `.invalidInput` before canonicalization/detection work.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The initial compile surfaced missing `@testable` access to the existing internal `FaceGeometry` test fixtures and a Core Foundation color-space type mismatch. Both were corrected within the fixture tests before commit; no production code changed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plans 68-02 and 68-03 can consume the target-local fixture factories and metric primitives. No Metal, GPU, UI/Demo, device, or tracked-media work was introduced.

---
*Phase: 68-cpu-algorithm-reference-oracles*
*Completed: 2026-08-14*

## Self-Check: PASSED

- Summary file exists at the planned path.
- Task commits `cc3199f` and `94be4c8` are present in git history.
- Focused fixture suites pass and `git diff --check` is clean.
