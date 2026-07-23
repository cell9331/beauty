---
phase: 46-independent-contour-and-chin-geometry
plan: "01"
subsystem: geometry-testing
tags: [swift, xctest, face-contour, chin-taper, privacy, boundary-checker, red-first]

requires:
  - phase: 45-public-contract-and-observed-face-support
    provides: package-only validated contour/median support separate from the seven-point compatibility proxy
provides:
  - fail-closed Phase 46 pre-implementation/live privacy, scope, ownership, and artifact checker
  - deterministic asymmetric complete, contour-only, centerline-failure, proxy-only, and no-improvement fixtures
  - deliberately RED named-emission contracts for all four contour/chin geometry requirements
affects: [46-02, 46-03, 46-04, 46-05, 46-06, face-shape-providers]

tech-stack:
  added: []
  patterns:
    - 0/1-aware classified repository scans with adversarial isolated-corpus mutation tests
    - exact named-emission source arrays before production provider implementation
    - observed-support-only new behavior beside byte-identical legacy proxy emissions

key-files:
  created:
    - .planning/phases/46-independent-contour-and-chin-geometry/check_face_geometry_boundaries.py
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift

key-decisions:
  - "Keep the Wave 0 provider suite deliberately RED until face/chin named emissions, effective fields, and provisional caps are implemented downstream."
  - "Use an eleven-point asymmetric observed contour, a sloped three-point median, and apex index 5 to make all four source sets directly distinguishable."
  - "Pin the Phase 45 checker, Package.swift, resource inventory/manifests, and future/partial ledgers while keeping bespoke ethical prohibitions flagged rather than fabricated as verified checks."

patterns-established:
  - "Pre/live split: pre-implementation proves named production emissions are absent; live requires exact seven-face/two-chin ownership, one 0..<37 loop, and provisional-cap wording."
  - "RED geometry contracts inspect direct named arrays, exact half-open-band sources, direction, displacement ceilings, local bounds, and legacy vector equality."

requirements-completed: []

duration: 13 min
completed: 2026-07-23
---

# Phase 46 Plan 01: Geometry Boundary and RED Provider Contracts Summary

**A 24-case fail-closed Phase 46 boundary checker and asymmetric named-emission contracts that intentionally remain RED until the four production geometry paths exist**

## Performance

- **Duration:** 13 min
- **Started:** 2026-07-23T08:51:26Z
- **Completed:** 2026-07-23T09:04:04Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added a standard-library checker with pre-implementation, live, and self-test modes. Its isolated corpus rejects command errors, unclassified matches, missing/escaping paths, manifest/checker/resource/ledger drift, geometry exposure, persistence, diagnostic leakage, network/model additions, internal imports, renderer cases, artifacts, ownership drift, convergence drift, and missing provisional-cap wording.
- Added six deterministic `FaceGeometry` fixtures that keep the exact legacy seven-point proxy and all eye/nose/lip siblings unchanged while varying only observed contour/centerline support.
- Added direct RED contracts for smooth-contour mean-centering and roughness reduction, disjoint temple/cheek half-open bands, centerline-only apex-adjacent chin taper, and byte-equal preservation of four shipped face arrays plus signed `chinLength`.
- Preserved the planned Wave 0 boundary: no production provider, cap, resolver, pipeline, renderer, Demo, dependency, resource, model, network, or ledger implementation change was made.

## Task Commits

Each task was committed atomically:

1. **Task 46-01-01: Create the fail-closed Phase 46 geometry boundary checker** — `1044dcd` (`test`)
2. **Task 46-01-02: Write asymmetric named face/chin emission contracts and leave them RED** — `de95393` (`test`)

## Files Created/Modified

- `.planning/phases/46-independent-contour-and-chin-geometry/check_face_geometry_boundaries.py` — pinned, classified, adversarial pre/live geometry boundary.
- `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` — six observed-support fixtures and five named-emission RED contracts.

## Verification

- `python3 .../check_face_geometry_boundaries.py --self-test` — **PASS, 24/24**.
- `python3 .../check_face_geometry_boundaries.py --pre-implementation` — **PASS, 12/12**.
- Default live checker — **EXPECTED FAIL, 11/14** because exact nine-field named ownership, the `0..<37` convergence loop, and provisional caps do not yet exist.
- Focused `FaceShapeWarpProviderTests` — **EXPECTED RED** with exit 1. The first diagnostics report missing `BeautySafetyCaps.faceContourSmooth` and missing `FaceShapeWarpProvider.fieldEmissions`; the other three new caps/fields and chin named surface are absent as planned.
- The plan’s inverted focused verification command (`! swift test ...`) — **PASS**.
- `git diff --check` — **PASS**.
- `BeautySDK/Package.swift` remains git-object hash `6f03b078816ad1f7a426e3f70d4f57503f3152e9`.
- The Phase 45 predecessor checker remains git-object hash `7f7cb4ad0ec7463e065ad7b88c6858c0fceb10c4`.

## Decisions Made

- The checker treats default live failure as required evidence in Wave 0 rather than weakening ownership, convergence, or cap rules to accommodate absent implementation.
- Smoothing contracts derive raw immediate-neighbor lateral deltas, subtract their mean, require one shared finite scale in `0...1`, and reject locally straight/no-improvement output.
- Temple uses path progress `0.10..<0.30` and `0.70..<0.90`; cheekbone uses `0.30..<0.46` and `0.54..<0.70`. Exact source arrays and pairwise disjointness prevent alias evidence.
- Chin taper requires the two contour points adjacent to apex index 5 and interpolates the sloped median X at unchanged source Y; missing or ineligible centerline support produces no taper emission.

## Prohibition Flags

- **[FLAGGED-UNVERIFIED]** Raw or derived observed face support must not become identity, recognition, authentication, or biometric-profiling data.
- **[FLAGGED-UNVERIFIED]** The shipped seven-point synthetic proxy must not be presented or consumed as observed support for the four new fields.
- **[FLAGGED-UNVERIFIED]** Double-chin, double-chin Pro, hairline, or branch completion must not be enabled through a proxy, model, dependency, resource, network path, provider, or status edit.

The checker detects concrete source/scope manifestations of these constraints without inventing ethical verification descriptors.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. The focused suite failure and live-checker failure are the required RED Wave 0 outcomes.

## Known Stubs

None. The absent production named emissions, caps, and convergence loop are intentional downstream plan work, not placeholder implementation.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 46-02 can add RED resolver, cap, provider-empty, exact 37-field, and once-only accounting contracts behind the passing pre-implementation boundary.
- Plan 46-04 owns the first production named emissions and provisional caps that can turn the provider contracts GREEN.
- Plans 46-05 and 46-06 remain responsible for resolver/facade integration and the final live boundary; no GEOM requirement is marked complete by this RED-only plan.

## Self-Check: PASSED

- Both plan-owned artifacts and this summary exist.
- Task commits `1044dcd` and `de95393` exist in repository history.
- Boundary self-tests pass 24/24, pre-implementation checks pass 12/12, the focused suite remains deliberately RED, and `git diff --check` passes.

---
*Phase: 46-independent-contour-and-chin-geometry*
*Completed: 2026-07-23*
