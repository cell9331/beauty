---
phase: 45-public-contract-and-observed-face-support
plan: "01"
subsystem: detection-contracts
tags: [swift, vision, privacy, face-geometry, boundary-checker, tdd]

requires:
  - phase: 41-public-contract-and-observed-eye-support
    provides: package-only observed-support lifecycle and fail-closed checker pattern
provides:
  - fail-closed Phase 45 privacy, compatibility, preset, dependency, model, Demo, and scope checker
  - immutable package-only observed face contour/median carrier
  - internal semantic face support separate from the shipped seven-point compatibility proxy
  - face-specific cardinality and exact topology boundary fixtures for downstream validation
affects: [45-02, 45-03, 45-04, 45-05, phase-46-face-providers]

tech-stack:
  added: []
  patterns:
    - request-scoped non-Codable observed support with independently optional regions
    - separate observed semantic evidence beside unchanged synthetic compatibility geometry
    - adversarial fail-closed static boundary checks

key-files:
  created:
    - .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py
  modified:
    - BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift
    - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift
    - PLANS.md

key-decisions:
  - "Keep observed contour/median evidence in one immutable package-only value with independent optional regions."
  - "Attach internal observed face semantics beside FaceGeometry.faceContour; never substitute for the exact seven-point compatibility path."
  - "Lock face-specific open-path bounds in test fixtures without reusing eye topology constants or polygon-area evidence."

patterns-established:
  - "Observed-face lifecycle: request-local immutable values carry no Codable, persistence, diagnostic, cache, or shared-state surface."
  - "Boundary gates classify rg status 0/1/error explicitly and reject every missing path, escape, unclassified match, or tool failure."

requirements-completed: [SUPP-02, SUPP-04]

duration: 23 min
completed: 2026-07-23
---

# Phase 45 Plan 01: Wave 0 Face-Support Safeguards Summary

**A 34-case fail-closed boundary gate plus immutable observed contour/median contracts and face-specific open-topology fixtures, while preserving the exact shipped seven-point proxy**

## Performance

- **Duration:** 23 min
- **Started:** 2026-07-23T04:25:33Z
- **Completed:** 2026-07-23T04:48:53Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Added a Python standard-library checker whose 34 deterministic self-tests cover clean/classified scans and adversarial tool, path, baseline, preset, public, Codable, persistence, diagnostic, Demo import, dependency, model, resource-manifest, network, artifact, and deferred semantic-scope failures.
- Added `BeautyObservedFaceSupport` and `BeautyFaceObservation.observedFaceSupport` as package-only, immutable, `Equatable & Sendable`, non-Codable request values with contour and median absence represented independently.
- Added `BeautyFaceSemanticSupport` and default-nil `FaceGeometry.observedFaceSupport` without changing `FaceGeometry.faceContour`, its center fallback, or existing initializer call sites.
- Added contour `6/7/8/31/32/33`, median `2/3/4/15/16/17`, and twelve named exact/inside/outside open-topology rule matrices, plus an exact seven-point compatibility assertion.

## Task Commits

Each TDD task was committed through RED then GREEN:

1. **Task 45-01-01: Create the fail-closed face-support boundary checker**
   - `e8c5f14` — RED: executable boundary-failure specification
   - `d870693` — GREEN: fail-closed checker and 34/34 adversarial self-tests
2. **Task 45-01-02: Define private face-support contracts and topology fixtures**
   - `78146c6` — RED: failing private-contract and face-topology fixture tests
   - `30164fc` — GREEN: observed/semantic contracts and source-compatible geometry storage

## Files Created/Modified

- `.planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py` — fail-closed live/self-test privacy, compatibility, preset, dependency, resource, Demo, and scope gate.
- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` — package-only observed contour/median envelope and optional observation carrier.
- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` — internal semantic support and separate default-nil `FaceGeometry` seam.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` — independent-region contracts, exact legacy proxy, Sendable checks, and face-specific topology inputs.
- `PLANS.md` — repository-level execution evidence and remaining-scope handoff.

## Verification

- `python3 .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py --self-test` — **PASS, 34/34**.
- `env CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --disable-sandbox --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` — **PASS, 18/18**.
- `git diff --check` — **PASS**.
- The post-plan full SwiftPM wave probe built and executed 319 tests, but the restricted environment produced 86 unrelated CoreImage/CoreVideo/Vision failures (`pixelBufferCreationFailed`, zero-pixel rendering, and `detectorUnavailable`). The changed focused suite remained 18/18 green within that run. This plan's required focused commands are green; no production change was made for environment-only failures.

## Decisions Made

- The observed envelope has optional `contour` and `medianLine` properties rather than an all-or-nothing payload, so interruption or malformed-region handling can discard a request-local value without cleanup or sibling impact.
- `BeautyFaceSemanticSupport.contour` remains the validated non-empty semantic input, while optional median/apex data determines the separate `centerlineEligible` level.
- The boundary helper pins only the planned pre-phase manifest/Demo baseline, the exact two existing resource-manifest paths, and the five preset SHA-256 values; it prints aggregate classifications rather than matched raw source or coordinate payloads.

## Prohibition Flags

- **[FLAGGED-UNVERIFIED]** Raw observed face landmarks must not become identity, recognition, or biometric-profiling data.
- **[FLAGGED-UNVERIFIED]** The shipped seven-point synthetic face-box proxy must not be presented, named, or consumed as observed contour or median-line support.
- **[FLAGGED-UNVERIFIED]** Deferred double-chin, double-chin Pro, and hairline rows must not be silently enabled by a proxy, model, dependency, resource, manifest, or network path.

These descriptor-less flags remain explicit inputs to the Phase 45 fail-closed closeout rather than fabricated pass claims.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The repository sandbox denied SwiftPM's default module-cache and nested sandbox operations on a repeat run. Using the repository's private temporary module cache plus SwiftPM `--disable-sandbox` produced the required focused 18/18 pass.
- The optional full-suite wave probe then exposed environment-only CoreImage/CoreVideo/Vision failures outside the four plan-owned files. They are recorded above and were not modified under the plan's scope boundary.

## Known Stubs

None. The topology matrices are intentional compiled Wave 0 inputs for Plan 45-04, not placeholder production validation.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 45-02 can add the exact 48-to-52 public scalar compatibility contract behind the new boundary gate.
- Plans 45-03 and 45-04 can map and validate actual observed regions into the explicit request/semantic seams without reopening the proxy contract.
- Plan 45-05 remains responsible for live checker execution after the 52-field and mapping implementation exists.

## Self-Check: PASSED

- All four plan-owned implementation/test artifacts exist.
- RED/GREEN commits `e8c5f14`, `d870693`, `78146c6`, and `30164fc` exist in repository history.
- Boundary self-tests pass 34/34, the focused Swift suite passes 18/18, and `git diff --check` passes.

---
*Phase: 45-public-contract-and-observed-face-support*
*Completed: 2026-07-23*
