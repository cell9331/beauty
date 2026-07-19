---
phase: 41-public-contract-and-observed-eye-support
plan: "02"
subsystem: detection
tags: [swift, vision, coordinates, privacy, eye-support]
requirements-completed: [EYE-05]

# Phase 41 Plan 02: Observed Eye Support Summary

## Outcome

Vision detection now carries request-scoped, package-only observed eye evidence. A single `VNDetectFaceLandmarksRequest` reads left/right contours and optional pupils, and the detector maps injected/request payloads through the existing `CoordinateMapper` boundary into finite, closed-unit image-normalized points. Anatomical side labels survive orientation and input-mirror transforms; absent pupils remain absent.

## Task commits

1. `5ac65b1` — capture private observed eye support and map default Vision payloads.
2. `6f55761` — add orientation, mirror, malformed-point, missing-pupil, and redaction fixtures.

## Verification

- `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` — 11 tests passed.
- `swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests` — 6 tests passed.
- `swift test --package-path BeautySDK --filter BeautyDetectionTests.CoordinateMapperTests` — 9 tests passed.
- `git diff --check` — clean.

Coverage includes all four representative orientations, input mirroring, independent left/right side labels, optional pupil absence, out-of-unit mapping failure, aggregate face/reason summaries, and the existing no-raw-Vision diagnostic scanner.

## Privacy and scope

`BeautyObservedEyeSide`, `BeautyObservedEyeSupport`, and `CoordinatePoint` are package-only `Equatable`/`Sendable` values with no Codable or diagnostic surface. Raw Vision landmark objects are consumed within the provider and are not retained. No new target, dependency, network path, public field, or Demo import was added. Contour/pupil semantic validation and adapter eligibility remain Plan 41-03 work; provider transforms, caps, facade output, and promotion remain downstream.

## Deviations

- `[Rule 2 - Critical correctness]` `CoordinatePoint` was promoted to package visibility because package-visible observed support cannot expose an internal coordinate element type under Swift 6 access checking. Its value semantics and coordinate implementation are unchanged.
- `[Rule 1 - Bug]` The default provider initially evaluated the landmark payload twice while wiring both coarse availability and support; it was corrected to evaluate the request payload once before constructing `VisionDetectionObservation`.

## Self-check

PASS — both task commits exist, focused suites and `git diff --check` are green, and the working tree is clean before this summary commit.
