---
phase: 41
slug: public-contract-and-observed-eye-support
status: complete
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-16
completed: 2026-07-16
---

# Phase 41 — Validation Strategy

> Completed per-phase validation contract for compatibility-safe eye parameters, private observed support, and exhaustive EYE-06 semantic boundaries.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via SwiftPM |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Measured full-suite runtime** | 14.787 seconds on the local arm64e macOS toolchain |

## Sampling Rate

- **After every task commit:** The task's focused `swift test --package-path BeautySDK --filter ...` command ran, with `git diff --check` when source or document boundaries changed.
- **After every plan wave:** A full `swift test --package-path BeautySDK` run was recorded in the matching summary.
- **Final Phase 41 gate:** Focused suites, fresh full SwiftPM, boundary-helper self-test/live modes, and `git diff --check` all passed on 2026-07-16.
- **Measured feedback latency:** 14.787 seconds for the final 295-test package suite, below the 120-second contract.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 41-01-01 | 01 | 1 | EYE-01, EYE-02 | T41-01 | finite bounded scalar normalization | unit | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` | ✅ | ✅ 28/28 |
| 41-01-02 | 01 | 1 | EYE-03, EYE-04 | T41-01 | legacy neutrality and no provider drift | unit/regression | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests && swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` | ✅ | ✅ 28/28 + 8/8 |
| 41-02-01 | 02 | 1 | EYE-05 | T41-02 | request-scoped non-Codable observed support | unit | `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` | ✅ | ✅ 12/12 |
| 41-02-02 | 02 | 1 | EYE-05 | T41-02 | one mapper boundary and redacted failures | unit | `swift test --package-path BeautySDK --filter BeautyDetectionTests.CoordinateMapperTests && swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests && swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` | ✅ | ✅ 9/9 + 8/8 + 12/12 |
| 41-03-01 | 03 | 2 | EYE-06 | T41-03 | bounded support validation and canonical ordering | unit/Wave 0 | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | ✅ | ✅ 13/13 |
| 41-03-02 | 03 | 2 | EYE-07 | T41-03 | pupil-local invalidation and complete-eye gating | integration/unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests && swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` | ✅ | ✅ 37/37 + 8/8 |
| 41-04-01 | 04 | 3 | EYE-01, EYE-02, EYE-03, EYE-04, EYE-05, EYE-06, EYE-07 | T41-04 | fail-closed source/privacy/artifact boundary helper | self-test | `python3 .planning/phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py --self-test` | ✅ | ✅ 24/24 |
| 41-04-02 | 04 | 3 | EYE-01, EYE-02, EYE-03, EYE-04, EYE-05, EYE-06, EYE-07 | T41-04 | synchronized owners and live boundary gate | package + boundary | `swift test --package-path BeautySDK && python3 .planning/phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py` | ✅ | ✅ 295/295 + 10/10 |
| 41-05-01 | 05 | 4 | EYE-06 | T41-03 | deterministic span/tilt, production-derived side order, and strict threshold matrix | unit/integration | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests && swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests` | ✅ | ✅ 13/13 + 8/8 |
| 41-05-02 | 05 | 4 | EYE-06 | T41-04 | owner synchronization and final Nyquist gate | package + boundary + hygiene | `swift test --package-path BeautySDK && python3 .planning/phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py --self-test && python3 .planning/phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py && git diff --check` | ✅ | ✅ 295/295 + 24/24 + 10/10 + clean |

## Wave 0 Requirements

- [x] `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` contains winding/cyclic determinism, signed tilt, side inversion, missing/duplicate sides, contour cardinality 5/6/7 and 15/16/17, unique-point 3/4/5, closed-unit axis edges, independent dimension/area predicates, pupil cardinality/containment/ellipse precedence, paired ratios, and pupil-local degradation fixtures.
- [x] `BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift` traverses production-derived order for `.up`, `.right`, `.left`, `.down`, and input-mirrored mapping, and rejects swapped/duplicate payloads.
- [x] `check_eye_support_boundaries.py` contains adversarial self-tests and live fail-closed scans; final execution passed 24/24 self-tests and 10/10 live checks.

## EYE-06 Exact Boundary Matrix

The focused adapter suite exercises the production constants through isolated pure predicates and composed validation:

- Contour cardinality 5/6/7 and 15/16/17; unique points 3/4/5; both axes at just outside, exact, and just inside closed-unit endpoints.
- Width and height independently just below, exact, and just above lower/upper limits (`0.04...0.50`, `0.01...0.30`); isolated area below/equal/above `0.0004`; composed cases record that dimension minima subsume the strict area floor.
- Pupil cardinality 0/1/2; each expanded-containment edge just inside/exact/just outside; ellipse offset below/exact/above `0.70`; composed containment-edge cases still fail the stricter offset guard.
- Paired contour width and height ratios independently just below/exact/just inside/just above `0.50` and `2.00`; invalid pairs clear both pupils while retaining both valid contours.
- Reversed and cyclic contours preserve package-private image-normalized span and signed canonical tilt. Production-derived order accepts all four orientations plus input mirroring and rejects swapped/duplicate side pairs.

## Boundary Scan Contract and Final Evidence

The checked-in helper is the canonical fail-closed command. It classifies `rg` status 0/1, blocks other statuses or runner failures, scans active SDK sources, compares manifest/Demo state with baseline `f1c28fa`, and checks all output/gallery/staging/quarantine roots.

```bash
python3 .planning/phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py --self-test
python3 .planning/phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py
```

Measured 2026-07-16 results:

- Self-test: 24/24 checks passed.
- Live gate: 10/10 checks passed; public/SPI unclassified 0, persistence/Codable unclassified 0, diagnostics/network/commercial/import unclassified 0.
- Baseline/artifacts: manifest/Demo changed 0 and untracked 0; generated roots tracked 0, staged 0, non-ignored untracked 0, representatives not ignored 0.
- Full SwiftPM: 295/295 tests passed with 0 failures.
- `git diff --check`: passed.

## Phase Boundary and Non-Claims

Phase 41 verifies compatible scalar storage plus private observed contour/pupil/span/tilt/order evidence only. Phase 42 remains the owner of provider vectors, effect transforms, provisional caps, emissions, resolver convergence, and facade routing. Phases 43-44 retain renderer/gallery output, final-cap calibration, exhaustive effect safety, and promotion. This ledger does not claim Demo UI, device or subjective visual quality, commercial naturalness, optimized performance, packaging, shipping, launch readiness, or whole-branch `眼睛` completion.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|-----------|-------------------|
| None | — | All Phase 41 behaviors use injected Vision fixtures and package tests; real portrait pupil inventory is exploratory Phase 43 work. | — |

## Validation Sign-Off

- [x] All tasks have focused automated verification or an executed Wave 0 dependency.
- [x] Sampling continuity: no three consecutive tasks lack automated verification.
- [x] Wave 0 artifacts were created and exercised before validation completion.
- [x] Every locked EYE-06 threshold has exact/inside/outside executable evidence, including isolated overlapping predicates and composed precedence.
- [x] Production-derived side-order and canonical span/tilt are covered without exposing geometry.
- [x] No watch-mode flags are used.
- [x] Feedback latency remains below 120 seconds.
- [x] Full SwiftPM and checked-in boundary self-test/live modes pass.
- [x] Phase 42 provider-transform/cap non-claims remain explicit.
- [x] `nyquist_compliant: true` and `wave_0_complete: true` reflect recorded execution evidence.

**Approval:** Approved 2026-07-16 after focused 13/13 adapter and 8/8 mapping suites, fresh 295/295 full SwiftPM, 24/24 boundary self-tests, 10/10 live boundary checks, and clean diff hygiene.
