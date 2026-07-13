---
phase: 35-public-contract-and-independent-geometry
plan: "02"
subsystem: geometry
tags: [swift, nose-geometry, warp-control-points, fail-closed-validation]

requires:
  - phase: 35-public-contract-and-independent-geometry
    provides: independent public nose fields, effective storage, and provisional 0.25 caps from Plan 35-01
provides:
  - package-internal explicit default-empty nose root and tip supports with deterministic adapter population
  - independent symmetric horizontal root narrowing and vertical upward tip lift vectors
  - shared field-specific support availability with strict pre-clamp malformed-input rejection
affects: [35-03, 35-04, 36-public-facade-output-evidence, 37-nose-safety-boundary-and-branch-closeout]

tech-stack:
  added: []
  patterns: [explicit package-internal support provenance, pre-clamp geometry validation, field-specific fail-closed routing]

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
    - BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift
    - BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift

key-decisions:
  - "Keep root and tip supports as explicit package-internal arrays rather than deriving either from the legacy four-point nose proxy."
  - "Validate support provenance, bounds, symmetry, lower-tip placement, and uniqueness before any control-point clamping."
  - "Scope the legacy face.nose center guard to legacy fields so valid new supports remain independently usable."

patterns-established:
  - "Independent nose supports: adapter and fixtures provide explicit root/tip subsets while the shipped legacy nose sequence remains unchanged."
  - "Provider availability: resolver-facing support booleans and point generation share the same validators."

requirements-completed:
  - NOSE-04
  - NOSE-05
  - NOSE-06

duration: 6 min
completed: 2026-07-13
---

# Phase 35 Plan 02: Independent Nose Geometry Summary

**Explicit package-only root and tip supports now drive distinct bounded inward and upward nose vectors with strict malformed-input rejection and no legacy fallback.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-07-13T06:30:33Z
- **Completed:** 2026-07-13T06:36:35Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Added deterministic two-point root and three-point lower-tip supports without changing the established four-point legacy nose proxy.
- Implemented field-specific support availability plus symmetric horizontal root contraction and vertical upward tip lift control points.
- Proved deterministic bounds, axes, nonzero movement, full-vector non-aliasing, empty-legacy independence, and fail-closed malformed support behavior.

## Task Commits

Each task was committed atomically:

1. **Task 35-02-01: Add explicit default-empty root/tip supports while preserving the legacy nose proxy** - `fd94f07` (feat)
2. **Task 35-02-02: Implement independent provider vectors and strict field-specific support validation** - `ce74256` (feat)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` - Stores default-empty package-internal root and tip supports.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` - Populates explicit supports only for available nose observations while preserving legacy coordinates.
- `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` - Validates supports and emits independent root/tip vectors with field-specific availability.
- `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` - Locks adapter coordinates plus valid and malformed shared geometry fixtures.
- `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` - Covers axes, symmetry, direction, determinism, non-aliasing, bounds, and fail-closed behavior.

## Verification

- `swift test --package-path BeautySDK --filter FaceShapeWarpProviderTests` — PASS, 9 tests.
- `swift test --package-path BeautySDK --filter NoseWarpProviderTests` — PASS, 13 tests.
- Exact legacy/new adapter coordinate scans — PASS.
- Provider symbol and displacement-constant scans — PASS.
- Full-vector source/target/displacement non-alias assertions — PASS.
- Empty, insufficient, non-finite, duplicate, same-side, asymmetric, unequal-Y, upper-tip, and out-of-bounds support assertions — PASS.
- Scoped public/SPI and out-of-scope path scans — PASS; no public raw geometry, renderer, Demo, dependency, generated artifact, or ledger change.
- `git diff --check 0e07617..HEAD` — PASS.

## Decisions Made

- Root support requires exactly two finite same-Y points symmetric around the face-bounds centerline; tip support requires at least two distinct finite points in the lower half of face bounds.
- New-field helpers run independently of the legacy nose center, while the four legacy helper bodies and output order remain unchanged.
- Provider-empty diagnostics remain the fixed category-only `nose_inputs_missing` reason.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 35-03 can consume `NoseWarpSupportAvailability` to sanitize only the unsupported new field while preserving valid legacy and sibling-field work.
- Public-facade resolver propagation, exhaustive six-field safety, renderer evidence, final calibration, and ledger promotion remain deferred to their owning plans/phases.

## Self-Check: PASSED

- All five modified files exist and both `35-02` task commits are present.
- Every task acceptance criterion and plan verification command passed.
- No stub, raw-geometry disclosure, new external surface, or unresolved ASVS Level 1 high-severity threat remains.

---
*Phase: 35-public-contract-and-independent-geometry*
*Completed: 2026-07-13*
