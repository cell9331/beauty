---
phase: 26-geometry-facade-and-landmark-routing-foundation
status: clean
reviewed_at: 2026-07-06
depth: standard
files_reviewed: 12
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
---

# Phase 26 Code Review

## Scope

Reviewed Swift source and focused test changes from Phase 26:

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

## Findings

No critical, warning, or info findings.

## Review Notes

- Package access is limited to the detector/observation seams needed by `BeautySDK` and `BeautyEffects`; public and SPI raw-geometry export scans remain clean.
- The still-image facade validates image extent and parameters before detection, preserves no-geometry `.notRun` compatibility, preserves disabled-tracking `.disabled`, and routes only one selected observation into internal geometry planning.
- SPI testing support exposes fixture states and invocation count only; it does not expose raw detector observations, landmarks, bounds, `FaceGeometry`, or control points.
- The default `VisionFaceDetector` provider still returns `detectorUnavailable`; this is an acknowledged Phase 26 research boundary, not a new regression from this phase. Production Vision extraction and saved-output geometry evidence remain Phase 27+ scope.

## Verification Context

- Focused facade, metadata compatibility, detector, resolver, and missing-landmark degradation tests passed during Phase 26.
- Full `swift test --package-path BeautySDK` passed with 159 tests.
- Public/SPI raw geometry export scan, active-source raw-leak scan, renderer geometry-case exclusion scan, and `SHAPE_FEATURE_LEDGER.md` implemented-status guard passed.

## Residual Risk

Phase 26 proves facade geometry intent and package-internal selected-face routing. It does not prove production Vision landmark extraction, geometry render output, generated PNG evidence, Demo UI behavior, commercial visual quality, full Meitu parity, or `脸型` implementation-status promotion.
