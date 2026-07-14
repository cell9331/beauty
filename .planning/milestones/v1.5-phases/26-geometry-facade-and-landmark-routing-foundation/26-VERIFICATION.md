---
phase: 26-geometry-facade-and-landmark-routing-foundation
status: passed
verified: 2026-07-06
requirements:
  - GEO-01
  - GEO-02
summaries:
  - 26-01-SUMMARY.md
  - 26-02-SUMMARY.md
---

# Phase 26 Verification - Geometry Facade and Landmark Routing Foundation

## Result

Phase 26 passes automated verification for the facade/routing foundation scope.

What is proven:

- GEO-01: public `BeautyEngine.processResult(image:metadata:parameters:)` runs geometry-triggered still-image detection only when face-shape, eye, nose, mouth, or `lipColor` parameters require geometry.
- GEO-02: selected package-only detection observations can feed internal `FaceGeometry` planning through `BeautyEffectResolver` without public raw landmark, bounds, control-point, or framework diagnostic exposure.

What is not claimed:

- No `BeautyExampleRenderer` geometry cases were added.
- No generated PNG or saved-output geometry evidence is claimed.
- No Demo UI behavior changed.
- No public raw geometry, raw landmark, bounding-box, control-point, or Vision observation API was added.
- No `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` `脸型` row was promoted to `implemented`.
- No commercial quality, full Meitu parity, or release readiness claim is made.

## Command Evidence

### Focused XCTest

| Command | Result |
| --- | --- |
| `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | Passed: 4 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineMetadataCompatibilityTests` | Passed: 4 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` | Passed: 6 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` | Passed: 10 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests` | Passed: 14 tests, 0 failures. |

### Full SDK Suite

| Command | Result |
| --- | --- |
| `swift test --package-path BeautySDK` | Passed: 159 tests, 0 failures. |

The full suite includes the new facade geometry tests plus existing public facade, detector, coordinate, effects, renderer-regression, resource, performance, and redaction tests.

### Static Scans

| Gate | Command | Result |
| --- | --- | --- |
| Active-source raw-leak scan | `sh -c 'rg -n -e VNFaceObservation -e boundingBox -e controlPoint -e /private/var -e NSError -e AVError -e rawPresetJson -e "raw JSON" -e "image bytes" -e landmarks= -e landmarkCoordinates -e rawLandmark BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo; public_status=$?; rg -n -e /private/var -e NSError -e AVError -e rawPresetJson -e "raw JSON" -e "image bytes" BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyEffects; internal_status=$?; if [ "$public_status" -eq 1 ]; then if [ "$internal_status" -eq 1 ]; then exit 0; fi; fi; exit 1'` | Passed with zero active-source matches. |
| Public/SPI raw geometry export scan | `rg -n "public .*VisionDetectionObservation|public .*VisionFaceDetector|public .*BeautyFaceObservation|public .*FaceGeometry|@_spi\(Testing\).*VisionDetectionObservation|@_spi\(Testing\).*BeautyFaceObservation|@_spi\(Testing\).*FaceGeometry" BeautySDK/Sources/BeautySDK BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyEffects; test $? -eq 1` | Passed with zero matches. |
| Renderer geometry-case exclusion | `rg -n "id: \"(face|eye|nose|mouth|lip|chin|jaw|proportion|3d|brow)|BeautyParameters\([^)]*(faceSlim|faceSmall|faceVShape|jawSlim|chinLength|eyeSize|eyeDistance|eyeYPosition|eyeTailLift|noseSlim|noseWingSlim|noseTipSize|noseBridge|mouthSize|mouthWidth|smile|lipColor)" BeautySDK/Sources/BeautyExampleRenderer/main.swift; test $? -eq 1` | Passed with zero matches. |
| `SHAPE_FEATURE_LEDGER.md` implemented-status guard | `rg -n "\|[^\n]*脸型[^\n]*\|[^\n]*implemented|Status:[^\n]*implemented" docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md; test $? -eq 1` | Passed with zero matches. |
| Decision coverage pre-doc scan | `for d in D-01 D-02 D-03 D-04 D-05 D-06 D-07 D-08 D-09 D-10 D-11 D-12 D-13 D-14 D-15 D-16; do rg -n "$d" .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-01-PLAN.md .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-02-PLAN.md .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-01-SUMMARY.md .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-02-SUMMARY.md >/dev/null || exit 1; done` | Passed. |
| Verification artifact diff check | `git diff --check -- .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VALIDATION.md .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md` | Passed after verification artifact creation. |

## Requirement Evidence

| Requirement | Evidence | Status |
| --- | --- | --- |
| GEO-01 | `BeautyEngineGeometryFacadeTests` proves geometry-triggering still-image parameters call the detector once, route a selected usable face, preserve `.notRun` for no-geometry paths, preserve `.disabled` for disabled tracking, and degrade through no-face, low-confidence, missing-landmark, unavailable, and timeout states. | Passed |
| GEO-02 | `BeautyEffectResolverTests`, `MissingLandmarkDegradationTests`, public/SPI export scans, and active-source raw-leak scans prove selected observations feed internal geometry planning while public evidence remains `BeautyDetectionSummary`, warnings, and numeric aggregate metrics only. | Passed |

## Decision Traceability

| Decision | Verification |
| --- | --- |
| D-01 | `BeautyEffectResolver.requiresFaceGeometry(parameters:)` and `BeautyEngineGeometryFacadeTests.testNoGeometryStillImageParametersDoNotRunDetection` prove detection runs only for geometry-triggering still-image work. |
| D-02 | `BeautyEngineGeometryFacadeTests.testGeometryTriggeredDetectionDegradesAndKeepsSafeDomainsActive` proves no-face, low-confidence, missing-landmark, unavailable, and timeout states degrade and keep safe color/filter work active. |
| D-03 | `BeautyEngineMetadataCompatibilityTests` and facade tests prove `.notRun` no-geometry compatibility and `.disabled` tracking compatibility. |
| D-04 | `BeautyEngineTestingSupport.swift` and facade tests provide SPI-only deterministic detector fixtures through `BeautySDK`, with public/SPI raw export scans passing. |
| D-05 | `BeautyEngineGeometryDetection.swift` routes `detection.observations.first`; facade tests assert one selected usable face is used. |
| D-06 | Public/SPI export scans pass; no public raw observation, landmark, `FaceGeometry`, or control-point API was added. |
| D-07 | `BeautyFaceGeometryAdapter.swift` maps selected detection observations into deterministic internal `FaceGeometry` sufficient to activate current providers. |
| D-08 | `MissingLandmarkDegradationTests` proves missing eye, nose, mouth/lip, nil selected face, stale, and reused behaviors remain group-specific and redacted. |
| D-09 | `BeautyEngineGeometryFacadeTests` proves public facade geometry intent activation through detection summary, warnings, and aggregate metrics. |
| D-10 | Renderer geometry-case exclusion scan passes; no `BeautyExampleRenderer` geometry case or PNG evidence was added. |
| D-11 | Primary gates include public facade tests plus detector and effects tests; internal-only effects tests are not the only evidence. |
| D-12 | `SHAPE_FEATURE_LEDGER.md` implemented-status scan passes; Phase 26 does not promote `脸型` rows to `implemented`. |
| D-13 | Redaction assertions and active-source raw-leak scans pass for summaries, warnings, metrics, public facade, and active Demo boundaries. |
| D-14 | Public evidence is limited to availability/reason/count summaries and numeric aggregate metrics such as active/skipped counts, geometry-required flag, face counts, and geometry point count. |
| D-15 | Verification uses focused tests and scoped active-source scans over `BeautySDK/Sources/BeautyCore`, `BeautySDK/Sources/BeautySDK`, detection/effects routing code, and active Demo source. |
| D-16 | `beauty.effects.geometryPointCount` remains a numeric aggregate count; focused redaction tests and active-source scans classify it as non-coordinate evidence. |

## Changed Files Covered

- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift`
- `BeautySDK/Sources/BeautyDetection/CoordinateSpace.swift`
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift`
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`
- `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift`
- `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineMetadataCompatibilityTests.swift`
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift`
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift`

## Release Boundary

Phase 26 is ready for Plan 26-04 documentation and ledger synchronization. Phase 27 remains the owner for saved-output geometry rendering evidence, and Phase 28 remains the owner for `脸型` tool completion/status promotion.
