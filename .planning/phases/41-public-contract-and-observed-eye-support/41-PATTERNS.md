# Phase 41: Public Contract and Observed Eye Support - Pattern Map

**Mapped:** 2026-07-16  
**Files analyzed:** 11 planned source/test files  
**Analogs found:** 11 / 11 (exact or role/data-flow match; new observed-eye validation has only partial analogs)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
| --- | --- | --- | --- | --- |
| `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` | model | request-response + Codable transform | same file's existing nose/mouth additions | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` | test | round-trip/compatibility batch | same file's Phase 38 contract tests | exact |
| `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` | service/provider | request-response (Vision acquisition) | same file's injected provider and `mapObservation` | exact |
| `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` | model | request-scoped transform | same file's package-private landmark model | exact |
| `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` | test | fixture request-response | same file's injected observations and redaction checks | exact |
| `BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift` | test | coordinate transform | same file's bounds/mirror mapping tests | exact |
| `BeautySDK/Tests/BeautyDetectionTests/CoordinateMapperTests.swift` | test | deterministic transform matrix | same file's orientation and mirror matrix | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` | adapter/utility | transform + validation | same file's group-gated derived geometry | role/data-flow match |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` | test | transform/validation batch | `FaceShapeWarpProviderTests.swift` adapter assertions | role-match (new file) |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | integration test | field-local degradation | same file's missing-eye and redaction tests | exact |
| `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` | regression test | provider request-response | same file's deterministic eye/skip tests | exact |

The ten public scalars remain owned by `BeautyParameters`; observed points remain package-internal and request-scoped. `CoordinateMapper` is an existing dependency and should be reused at one boundary rather than duplicated in providers.

## Pattern Assignments

### `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` (model, request-response + Codable)

**Analog:** existing initializer, decoder, normalization, and encoder synthesized by `BeautyParameters.swift`.

**Stored fields and coding keys** (lines 1-86): add each eye field in declaration and `CodingKeys` order; preserve the current stored-field inventory convention (`Mirror` sees all stored properties, including `filterId` and `filterIntensity`).

**Defaulted initializer and normalization** (lines 88-172):

```swift
public init(/* existing labeled arguments */, eyeSize: Float = 0, eyeDistance: Float = 0) {
    // ... existing assignments ...
    self.eyeSize = Self.clampUnit(eyeSize)
    self.eyeDistance = Self.clampSigned(eyeDistance)
}
```

Use `clampUnit` for nine positive-only fields and `clampSigned` for `eyeTilt`; keep defaults at zero and preserve existing argument labels/order so source calls remain valid. The helpers at lines 261-274 return zero for non-finite values and clamp to the requested interval.

**Missing-key decoding** (lines 174-215 and 277-280): every new key must be passed through `decodeFloatIfPresent`, whose `decodeIfPresent(...) ?? 0` behavior is the established legacy compatibility seam.

**Normalized copy** (lines 218-259): pass all ten fields into a fresh `BeautyParameters` value so mutable out-of-range assignment is repaired without mutating the source.

### `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` (test, round-trip/compatibility)

**Analog:** Phase 38 tests in the same file.

**Inventory/default assertions** (lines 6-48): extend the `Mirror(reflecting: parameters).children.count` assertion from 38 to 48 and assert all ten fields are zero. Keep the per-field assertion style; it catches omitted stored properties and accidental aliases.

**Range and independence tests** (lines 50-120, 218-330): use table-driven overflow/non-finite cases, then construct unequal values and assert each field survives independently. Follow the existing `accuracy: 0.0001` convention for signed values.

**Codable compatibility** (lines 332-486):

```swift
let data = try JSONEncoder().encode(parameters)
let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)
XCTAssertEqual(object.count, 38) // update Phase 41 contract to 48
XCTAssertEqual(decoded, parameters)
```

Mirror the legacy-33 and legacy-38 fixtures with a complete legacy 38-key payload (new fields absent => zero), and assert a complete 48-key payload round-trips unequal ten-field values. Preserve preset text and existing labeled initializer neutrality tests (lines 488-510).

### `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` (service/provider, request-response)

**Analog:** injected `ObservationProvider`, `summarize`, `mapObservation`, and default Vision request (lines 53-120, 136-230, 267-320).

**Provider seam and error handling** (lines 59-70, 101-129): retain `@Sendable` provider injection; map known failures to `BeautyDetectionSummary` reason codes and all unknown failures to a redacted `.detectorUnavailable` summary. Do not put raw Vision objects or points in errors.

**Single mapper boundary** (lines 166-198, 206-230): create one `CoordinateMapper` per detection and map every Vision contour/pupil point through it before building `BeautyFaceObservation`; catch `CoordinateMapper.MappingError` and return `.partial`/`.mappingFailed` with counts only. Validate mapped coordinates for finite closed-unit bounds at this boundary.

**Vision acquisition** (lines 267-320): preserve the one `VNDetectFaceLandmarksRequest` and `VNImageRequestHandler` orientation. The current `landmarks(from:)` only records availability (lines 296-320); extend the private provider payload with optional raw regions, map them once, and never retain `VNFaceObservation`/`VNFaceLandmarkRegion2D` beyond the request.

### `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` (model, request-scoped transform)

**Analog:** package visibility and value semantics already used by `BeautyFaceObservation`/`BeautyFaceLandmarks` (lines 3-22, 34-60).

```swift
package struct BeautyFaceObservation: Equatable, Sendable {
    package let stableID: String?
    package let confidence: Double
    package let normalizedArea: Double
    package let imageBounds: CoordinateRect?
    package let landmarks: BeautyFaceLandmarks
}
```

Add an optional observed-eye support value beside these coarse fields with `package` visibility, `Equatable`, and `Sendable`. Keep it non-`Codable`, non-`CustomStringConvertible`, and lifecycle-bound to this observation; preserve `BeautyLandmarkGroup.hasRequiredGeometry` as the coarse complete-eye gate.

### `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` (test, fixture request-response)

**Analog:** injected provider tests and diagnostics scanner (lines 8-160, 182-208, 248-261).

Use closure-injected `VisionDetectionObservation` fixtures to test valid left/right contours, missing pupils, malformed points, mapping failure, and orientation/mirror. Keep summary assertions on `availability`, reason codes, `faceCount`, and `usedFaceCount`; never assert or print raw points. Reuse `assertNoRawVisionDiagnostics`, whose forbidden tokens include `VNFaceObservation`, `boundingBox`, `landmark`, `NSError`, and paths (lines 248-261).

For actual Vision integration, retain the existing portrait fixture loop (`e1.png`…`e6.jpg`, lines 182-207) and only assert usable/redacted aggregate outcomes.

### `BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift` (test, coordinate transform)

**Analog:** existing bounds and input-mirror cases (lines 8-79).

```swift
let result = detector.detect(
    metadata: metadata(orientation: .up, inputMirrored: true),
    imageExtent: CGSize(width: 400, height: 200)
)
assertRect(result.observations[0].imageBounds,
    equals: CoordinateRect(x: 0.70, y: 0.50, width: 0.20, height: 0.30))
```

Extend this fixture style to contour/pupil points and all four representative orientations. Assert image-normalized values and side identity, not preview coordinates; retain mapping-failure assertions as fixed reason codes.

### `BeautySDK/Tests/BeautyDetectionTests/CoordinateMapperTests.swift` (test, deterministic transform matrix)

**Analog:** orientation and mirror matrix (lines 22-81).

```swift
let expected: [(CGImagePropertyOrientation, CoordinatePoint)] = [
    (.up, .init(x: 0.25, y: 0.25)),
    (.right, .init(x: 0.75, y: 0.25)),
    (.left, .init(x: 0.25, y: 0.75)),
    (.down, .init(x: 0.75, y: 0.75))
]
```

Keep this matrix as the single source of orientation/mirror truth. `CoordinateMapper.toImageNormalized` (lines 58-87) flips Vision’s lower-left Y and applies input mirror; preview mirroring must not alter mapped image-normalized support (existing test lines 66-81).

### `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` (adapter, transform + validation)

**Analog:** current `makeGeometry` and group-gated semantic derivation (lines 4-21, 24-45, 48-145).

```swift
return FaceGeometry(
    bounds: bounds,
    faceContour: landmarks.contains(.faceContour) ? faceContour(in: bounds) : [],
    leftEye: landmarks.contains(.leftEye) ? leftEye(in: bounds) : [],
    rightEye: landmarks.contains(.rightEye) ? rightEye(in: bounds) : [],
    /* ... */
)
```

Keep deterministic derivation and field-local empty arrays. Add a private validation/canonicalization path for observed contours: reject non-finite, out-of-unit, duplicate-only, degenerate, implausible, and over-ceiling input before deriving upper/lower/inner/outer/center supports. Preserve explicit left/right side labels independent of input winding; pupil invalidity must clear only pupil-dependent eligibility.

### `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` (test, transform/validation)

**Analog:** `FaceShapeWarpProviderTests.swift` adapter assertions (lines 7-38 and 40-89).

Follow the existing pattern of constructing a `BeautyFaceObservation`, calling `BeautyFaceGeometryAdapter.makeGeometry`, and asserting exact `SIMD2<Float>` arrays with a shared `assertPoints` helper. Add synthetic fixtures for reversed/rotated winding, side identity, orientation/mirror-mapped supports, duplicate/degenerate/oversized contours, missing contour, missing/outside pupil, and valid contour + invalid pupil. Verify deterministic repeated calls and that contour siblings survive pupil invalidation.

### `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` (integration test, field-local degradation)

**Analog:** existing missing-eye and redaction tests (lines 7-35, 1294-1341).

```swift
for face in [FaceGeometry.missingLeftEye, .missingRightEye] {
    let plan = BeautyEffectResolver.resolve(
        parameters: BeautyParameters(eyeSize: 1, eyeDistance: -1, eyeYPosition: 1, eyeTailLift: 1),
        faceGeometry: face
    )
    XCTAssertFalse(plan.activeDomains.contains(.eyes))
    XCTAssertTrue(plan.skippedDomains.contains(.eyes))
    XCTAssertEqual(plan.metrics["beauty.effects.skippedEyeDomains"], 1)
}
```

Extend the assertions for the observed support seam: absent/invalid pupil zeros only `pupilSize` and `gazeCorrection`, while contour-dependent fields remain eligible; missing either contour keeps the whole eye domain skipped. Reuse `assertRedacted`/`assertNoEyeSideOrRawGeometryDisclosure` (lines 1374-1417) and fixed warning/metric codes; never include side labels or coordinates in diagnostics.

### `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` (regression test, provider request-response)

**Analog:** deterministic provider and skip-reason tests (lines 6-41, 80-89).

Keep the current four-field eye behavior as a neutral regression: zero new fields must leave existing control-point output unchanged, output remains deterministic and clamped, and missing either legacy eye input still returns `eye_inputs_missing`. Do not add Phase 42 provider transforms or final caps here.

## Shared Patterns

### Scalar compatibility and normalization

**Sources:** `BeautyParameters.swift:88-172,174-215,218-280`; `BeautyParametersTests.swift:332-486`  
**Apply to:** public model and core tests.

- Add stored field, `CodingKeys`, defaulted initializer, decoder argument, and `normalized()` argument together.
- Use zero for missing keys/non-finite values; use `clampUnit` for positive-only fields and `clampSigned` for `eyeTilt`.
- Preserve source initializer labels, bundled preset text, and exact JSON field counts.

### One coordinate conversion boundary

**Sources:** `CoordinateMapper.swift:28-40,58-87,120-141`; `CoordinateMapperTests.swift:22-81`  
**Apply to:** Vision detector, observation mapping, adapter tests.

Map Vision face-bounds points once to image-normalized coordinates, validate finite closed-unit results, then pass mapped points downstream. Do not let providers repeat orientation, lower-left Y, input-mirror, or winding math.

### Package-private, ephemeral evidence

**Sources:** `BeautyFaceObservation.swift:3-22`; `VisionFaceDetector.swift:7-50,206-230`; `SECURITY.md` eye privacy rules.  
**Apply to:** all observed support source and tests.

Use `package` value types with `Equatable`/`Sendable`; never expose raw points through public API, `Codable`, logs, metrics, warnings, errors, descriptions, snapshots, Demo imports, or retained state. Diagnostics contain only fixed reason codes and aggregate counts.

### Field-local degradation and complete-eye gating

**Sources:** `BeautyEffectResolver.swift:285-313,467-472`; `EyeWarpProvider.swift:6-10`; `MissingLandmarkDegradationTests.swift:7-35,1374-1417`.  
**Apply to:** adapter eligibility and regression tests.

Missing either eye contour fails the complete eye domain closed; optional pupil failure must not globally gate contour-only work. Preserve sibling-domain activity, stable warnings, and redacted metrics.

### Fixture-driven deterministic tests

**Sources:** `VisionFaceDetectorTests.swift:182-208`; `FaceShapeWarpProviderTests.swift:7-38`; `CoordinateMapperTests.swift:34-81`.  
**Apply to:** all new validation/mapping tests.

Prefer injected fixtures, exact arrays/coordinates, repeated-call equality, representative orientation/mirror matrices, malformed-input rejection, and aggregate/redaction assertions over visual or raw-payload snapshots.

## No Analog Found

| File/Concern | Role | Data Flow | Reason |
| --- | --- | --- | --- |
| Private observed contour/pupil support type | model | request-scoped transform | Existing observation stores only availability and coarse bounds; no raw eye arrays or pupils exist. Use the `BeautyFaceObservation` seam and CONTEXT privacy rules. |
| Contour winding canonicalization and pupil plausibility validator | utility/adapter | transform + validation | Existing adapter synthesizes proxy points and has no malformed observed-array validator. Use explicit bounded thresholds and synthetic fixtures from CONTEXT/RESEARCH. |
| `BeautyFaceGeometryAdapterTests.swift` | test | validation batch | No focused adapter test file currently exists; nearest analog is `FaceShapeWarpProviderTests.swift` lines 7-89. |
| Vision pupil acquisition | service/provider | request-response | `VisionFaceDetector.landmarks(from:)` records eye availability only (lines 296-320); no existing pupil payload or blink validation. |

These are intentional Phase 41 additions, not reasons to import a dependency, add a second Vision request, or expose geometry publicly.

## Metadata

**Analog search scope:** `BeautySDK/Sources/{BeautyCore,BeautyDetection,BeautyEffects,BeautySDK}` and `BeautySDK/Tests/{BeautyCoreTests,BeautyDetectionTests,BeautyEffectsTests}`; root contracts `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and `PLANS.md` were consulted for boundaries.  
**Files scanned:** 11 primary analog files plus `CoordinateMapper`, `BeautyEffectResolver`, `BeautyDetectionSummary`, `BeautyValidationWarning`, `FaceGeometry`, and related fixture helpers.  
**Pattern extraction date:** 2026-07-16.  
**Scope guard:** Phase 41 owns EYE-01–EYE-07 compatibility, mapping, support validation, privacy, and degradation inputs only; provider transforms, caps, facade output, renderer matrices, gallery evidence, Demo/device/commercial work remain deferred.
