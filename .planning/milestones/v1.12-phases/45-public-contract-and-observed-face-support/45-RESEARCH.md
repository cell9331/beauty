# Phase 45: Public Contract and Observed Face Support - Research

**Researched:** 2026-07-21
**Domain:** Swift/Apple Vision compatibility-safe public face controls and private observed contour/median-line support
**Confidence:** HIGH for repository boundaries, public compatibility, and integration seams; MEDIUM for the recommended face-specific numerical validation thresholds

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Public Scalar Contract
- Add exactly `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper` to `BeautyParameters`; do not add aliases or any public face-support type.
- Keep all four fields positive-only and normalize each public `Float` to `[0, 1]`, with non-finite input falling back to `0`.
- Default every new field to zero in source initialization and missing-key decoding so existing call sites, the legacy 48-field JSON shape, bundled presets, shipped caps, and shipped vectors remain unchanged.
- Encode all four fields independently and prove the exact stored inventory becomes 52 fields: 51 numeric fields plus `filterId`.

### Observed Face-Support Model
- Capture Vision `faceContour` and `medianLine` points in one package-private, `Sendable`, request-scoped representation owned by `BeautyDetection`; do not reconstruct either support from face bounds.
- Convert face-bounds-normalized Vision coordinates exactly once into repository image-normalized coordinates through the existing `CoordinateMapper`, then validate finite closed-unit bounds at the conversion boundary.
- Preserve contour ordering while canonicalizing stable left/right traversal and centerline direction independently of Vision winding, portrait orientation, and mirrored metadata.
- Keep the legacy seven-point synthetic face-box contour only for already shipped face controls. The four new fields may consume only validated observed support and must fail closed when it is absent.

### Validation and Degradation
- Reject support that is empty, duplicate-only, non-finite, out of bounds, undersized, degenerate, side-inverted, internally inconsistent, or above an explicit fixed point ceiling before it reaches providers.
- Validate contour and median line independently, but expose field eligibility conservatively: contour-only transforms may use validated contour support, while any centerline-dependent derivation requires a valid median line.
- Missing or malformed observed support disables only the four new fields; eligible shipped face controls and face-agnostic domains continue unchanged.
- Use face-specific validation thresholds and tests. Do not reuse eye-support constants solely because a prior structure looks similar.

### Privacy, Scope, and Ownership
- Keep raw and derived contour/centerline coordinates package-internal, ephemeral, non-Codable, non-persistent, and absent from public APIs, logs, metrics, warnings, errors, descriptions, snapshots, and Demo imports.
- Use fixed redacted reason codes and aggregate counts only; diagnostics must not reveal coordinates, bounds, point samples, or biometric-adjacent payloads.
- Add no dependency, semantic model, resource manifest, runtime download, network/cloud path, render pass, facade method, or public result type.
- Keep `去双下巴`, `去双下巴 Pro`, and `发际线` explicitly future. A person matte, synthetic face-box region, or unlicensed/unversioned model is not acceptable evidence for them.

### Verification Boundary
- Contract tests cover defaults, normalization, non-finite input, exact 52-field inventory, legacy-payload decode, new-field round trip, and unchanged bundled preset JSON.
- Detection/adapter tests cover one-time conversion, stable ordering, side and centerline orientation, validation bounds, malformed rejection, absence behavior, and legacy synthetic-path isolation.
- Boundary tests prove no public/Codable/persistent/diagnostic/Demo exposure and no semantic resource or dependency is introduced.
- Phase 45 closes only FACE-07, FACE-08, FACE-09, FACE-12, SUPP-01, SUPP-02, and SUPP-04; provider geometry and visible output remain downstream.

### the agent's Discretion
- Exact package-private type names, file splits, and conservative validation thresholds may follow existing observation/adapter conventions.
- The adapter may retain validated full contours plus derived semantic indices when that avoids lossy re-derivation, provided ownership and privacy boundaries remain intact.
- A small internal refactor is allowed to share bounded point-validation helpers when it does not change shipped-field behavior or broaden scope.

### Deferred Ideas (OUT OF SCOPE)
- Four field-specific provider transforms, named emissions, resolver/conflict/facade routing, and provider-empty effective accounting — Phase 46.
- Renderer cases, decoded strict output comparisons, no-face/missing/malformed evidence, and ignored gallery — Phase 47.
- Final exact caps, exhaustive nine-field face transitions, thirty-seven-field geometry convergence, boundary closeout, and exact four-row promotion — Phase 48.
- `去双下巴`, `去双下巴 Pro`, `发际线`, local semantic models/resources, Demo UI, physical-device validation, commercial naturalness, optimized performance, packaging, shipping, and launch readiness — future scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|---|---|---|
| FACE-07 | Independent positive-only `faceContourSmooth` with zero-default source/Codable compatibility. | Extend the existing `BeautyParameters` stored-property, key, defaulted initializer, decoder, normalization, and round-trip pattern; do not route it to a provider in this phase. [VERIFIED: `BeautyParameters.swift`; `45-CONTEXT.md`] |
| FACE-08 | Independent positive-only `templeFullness`, not an alias of `faceSmall` or `faceSlim`. | Give it unique storage/key/round-trip values and keep provider semantics deferred to Phase 46. [VERIFIED: `BeautyParameters.swift`; `45-CONTEXT.md`] |
| FACE-09 | Independent positive-only `cheekboneSlim`, without whole-cheek evidence borrowing. | Prove unique public storage now and require validated observed contour eligibility for downstream use. [VERIFIED: `45-CONTEXT.md`; `BeautyFaceGeometryAdapter.swift`] |
| FACE-12 | Independent positive-only `chinTaper`, without changing signed `chinLength`. | Use `clampUnit` for the new field and leave `chinLength` on `clampSigned`; prove unequal values round-trip independently. [VERIFIED: `BeautyParameters.swift`; `45-CONTEXT.md`] |
| SUPP-01 | Actual Vision contour and median line map once into image-normalized coordinates, never from the seven-point proxy. | Extend the current default Vision landmark payload and `mapObservation` seam, composing face-local points into Vision image space before one `CoordinateMapper` call. [VERIFIED: `VisionFaceDetector.swift`; `CoordinateMapper.swift`] [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d] |
| SUPP-02 | Canonicalized contour/centerline rejects malformed or inconsistent input. | Canonicalize only by whole-array reversal against mapper-derived face-local axes; preserve adjacency; then run independent face-specific topology validation in the adapter. [VERIFIED: `45-CONTEXT.md`; archived Phase 41 pattern] |
| SUPP-04 | Support remains private, ephemeral, non-Codable, non-persistent, and non-diagnostic. | Follow `BeautyObservedEyeSupport`/`BeautyFaceObservation` package-access lifecycle and add a fail-closed boundary helper based on the archived Phase 41 gate. [VERIFIED: `BeautyFaceObservation.swift`; archived `check_eye_support_boundaries.py`; `SECURITY.md`] |
</phase_requirements>

## Summary

Phase 45 should be implemented as two independent contracts that meet at the detection-to-effects seam. First, add exactly four default-zero, positive-only public scalars to the existing manually coded `BeautyParameters` lifecycle. Second, carry actual Vision `faceContour` and `medianLine` regions through the existing request, one coordinate conversion, a package-only observation, and a separate adapter-produced semantic support. The current 48-field model, mapper, Vision request, observation type, adapter, and focused XCTest suites already provide all required seams; no dependency, target, request, render pass, or public geometry type is needed. [VERIFIED: `BeautyParameters.swift`; `VisionFaceDetector.swift`; `BeautyFaceObservation.swift`; `BeautyFaceGeometryAdapter.swift`; `Package.swift`]

The critical architectural rule is to keep two face paths in parallel. `FaceGeometry.faceContour` is currently a synthetic seven-point face-box contour and must remain unchanged for the five shipped face controls. The four new fields must later read only a new optional validated observed-face support property. Therefore invalid or absent observed support must set only that new property/eligibility to nil while leaving the synthetic contour, eyes, nose, lips, and face-agnostic work unchanged. [VERIFIED: `BeautyFaceGeometryAdapter.swift`; `WarpControlPoint.swift`; `45-CONTEXT.md`]

Apple documents face landmark points as normalized to the face observation bounding box with a lower-left origin; `faceContour` traces from one cheek over the chin to the other, and `medianLine` traces vertically down the center. The existing eye implementation already composes face-local points into Vision image-normalized coordinates and then calls `CoordinateMapper` once. Reuse that lifecycle, but do not reuse eye counts, size ratios, or angular topology. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d] [VERIFIED: `VisionFaceDetector.swift`; `45-CONTEXT.md`]

**Primary recommendation:** Add the 52-field contract first, then add one optional private observed-face payload with independently optional contour/median arrays, canonicalize each by reversal using mapper-derived face-local axes, validate open-polyline topology in the adapter, attach a separate semantic support to `FaceGeometry`, and close with focused XCTest plus a fail-closed boundary checker. [VERIFIED: repository seams; `45-CONTEXT.md`]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|---|---|---|---|
| Four-scalar public/source/JSON contract | BeautyCore public model | BeautyCore/BeautyResources tests | `BeautyParameters` owns stored fields, keys, defaulted initialization, decoding, and normalization. [VERIFIED: `BeautyParameters.swift`] |
| Vision region capture and one-time coordinate mapping | BeautyDetection | Existing `CoordinateMapper` | `VisionFaceDetector` already owns the single request and face-bounds point composition pattern. [VERIFIED: `VisionFaceDetector.swift`; `CoordinateMapper.swift`] |
| Canonical traversal/direction | BeautyDetection mapping boundary | BeautyDetection tests | Only this tier still has mapper metadata and the original face-local axes required to make orientation/mirror-independent direction decisions. [VERIFIED: current eye-order implementation in `VisionFaceDetector.swift`] |
| Topology validation and semantic indices | BeautyEffects planning adapter | Private `FaceGeometry` support | The adapter is the existing detection-to-effects trust boundary and can reject malformed arrays before providers. [VERIFIED: `BeautyFaceGeometryAdapter.swift`; archived Phase 41 implementation] |
| Legacy five-field face compatibility | Existing synthetic `FaceGeometry.faceContour` path | Existing face/chin providers | The current seven-point proxy remains solely for shipped controls and must not be replaced. [VERIFIED: `BeautyFaceGeometryAdapter.swift`; `FaceShapeWarpProvider.swift`; `ChinWarpProvider.swift`] |
| Four new transforms/routing/caps/output | Phase 46-48 BeautyEffects/BeautySDK | — | Explicitly downstream; Phase 45 exposes contract and eligibility only. [VERIFIED: `45-CONTEXT.md`; `.planning/ROADMAP.md`] |
| Privacy, dependency, resource, and Demo boundary | Cross-module static gate | Root security/reliability contracts | The repository already uses fail-closed classified scans and aggregate-only evidence for biometric-adjacent support. [VERIFIED: archived Phase 41 boundary helper; `SECURITY.md`; `RELIABILITY.md`] |

## Standard Stack

### Core

| Technology | Version / Baseline | Purpose | Why Standard |
|---|---|---|---|
| Swift / SwiftPM | tools 6.0; local Apple Swift 6.3.3 | Public value model, package access, `Sendable`, adapter implementation | Already defines the repository module graph and source-compatibility surface; no package change is required. [VERIFIED: `BeautySDK/Package.swift`; `swift --version`] |
| Apple Vision | Existing iOS 17+ platform floor | `VNDetectFaceLandmarksRequest`, `faceContour`, and `medianLine` | The current detector already performs the required request and official regions supply the observed evidence. [VERIFIED: `VisionFaceDetector.swift`; `Package.swift`] [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d] |
| CoreGraphics / ImageIO / CoreImage | Platform SDK in Xcode 26.6 | Orientation, image metadata, test fixtures, and Vision input | These are already imported by the detector/mapper and introduce no dependency. [VERIFIED: `VisionFaceDetector.swift`; `CoordinateMapper.swift`; `xcodebuild -version`] |
| Existing unified geometry pipeline | Repository implementation | Downstream consumption of validated support | Phase 45 adds no render pass; Phase 46 later extends existing providers/resolver. [VERIFIED: `ARCHITECTURE.md`; `45-CONTEXT.md`] |

### Supporting

| Tool | Version | Purpose | When to Use |
|---|---|---|---|
| XCTest via SwiftPM | Xcode 26.6 | Contract, mapping, topology, isolation, and redaction tests | Run the narrow affected test class per task and the full suite per wave/phase gate. [VERIFIED: `Package.swift`; local command probe] |
| Python standard library | 3.9.6 locally | Fail-closed boundary checker with adversarial self-tests | Use only for source/resource/dependency/privacy boundary verification, not geometry computation. [VERIFIED: `python3 --version`; archived Phase 41 checker] |
| Local committed portrait fixtures | Six portraits under `example-images/input/portraits` | Aggregate real-Vision availability probe | Use as non-coordinate aggregate integration evidence; keep synthetic injected observations normative for exact thresholds/orientation. [VERIFIED: local fixture inventory and Vision probe] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|---|---|---|
| Existing Vision request | A second Vision request or third-party detector | Duplicates work or adds dependency/privacy/supply-chain scope prohibited by the phase. [VERIFIED: `45-CONTEXT.md`; `Package.swift`] |
| Separate observed support beside the proxy | Replace `FaceGeometry.faceContour` globally | Would silently change the shipped five-field geometry contract and fail on observations without new support. [VERIFIED: current adapter/providers; `45-CONTEXT.md`] |
| Whole-array reversal | Sort points by X, angle, or distance | Sorting destroys Vision's cheek-to-chin adjacency and makes local smoothing/semantic bands invalid. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d/facecontour] |
| Package-only non-Codable value | Public/Codable debug model | Expands the API and retention surface for biometric-adjacent coordinates. [VERIFIED: `SECURITY.md`; `45-CONTEXT.md`] |

**Installation:** None. Do not edit `BeautySDK/Package.swift`, add a model/resource, or introduce a package manager operation. [VERIFIED: `45-CONTEXT.md`]

## Package Legitimacy Audit

No external package is installed or recommended. The SwiftPM package graph remains the existing local targets plus Apple platform frameworks. [VERIFIED: `BeautySDK/Package.swift`; `45-CONTEXT.md`]

## Architecture Patterns

### System Architecture Diagram

```text
Host request
  └─ BeautyParameters (52 stored fields; four new fields default zero)
       │
       │ Phase 45: storage only; provider/facade routing deferred
       ▼
Existing VNDetectFaceLandmarksRequest
  ├─ face bounds
  ├─ faceContour  ─┐ face-bounds-normalized, open ordered path
  └─ medianLine   ─┘
       │
       ▼
VisionFaceDetector mapping boundary
  compose face-local → Vision image point
  → CoordinateMapper exactly once
  → finite/[0,1]/count preflight
  → mapper-axis canonical reversal (never sort)
       │
       ▼
BeautyFaceObservation
  package-only + Sendable + request-scoped + non-Codable
       │
       ▼
BeautyFaceGeometryAdapter
  ├─ legacy synthetic 7-point contour ──► shipped face controls unchanged
  └─ validated observed face support
       ├─ contour eligibility
       └─ contour + median eligibility / semantic apex indices
             │
             └─► Phase 46 providers (deferred)

Public output: image + fixed aggregate diagnostics only; never point payloads
```

The main request still enters through the existing facade/detector pipeline. Phase 45 does not add the new fields to `requiresFaceGeometry`, `BeautyEffectiveStrengths`, safety caps, providers, renderer cases, or facade routing because those are explicitly Phase 46 responsibilities. [VERIFIED: `BeautyEffectResolver.swift`; `45-CONTEXT.md`]

### Recommended Project Structure

```text
BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift
BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift

BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift
BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift
.planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py
```

All Swift files and test suites above already exist; only the boundary checker is a new planned file. Keeping the support types in the existing observation and geometry files avoids creating a misleading public/domain package. [VERIFIED: `rg --files BeautySDK`; `45-CONTEXT.md`]

### Pattern 1: Atomic manual scalar lifecycle

**What:** Add each field to storage, `CodingKeys`, the defaulted initializer, the initializer assignment, decoder arguments, and `normalized()` in one task. Use `clampUnit`; preserve signed `chinLength` unchanged. [VERIFIED: `BeautyParameters.swift`]

```swift
public var faceContourSmooth: Float
public var templeFullness: Float
public var cheekboneSlim: Float
public var chinTaper: Float

public init(
    // existing labels...
    faceContourSmooth: Float = 0,
    templeFullness: Float = 0,
    cheekboneSlim: Float = 0,
    chinTaper: Float = 0
) {
    self.faceContourSmooth = Self.clampUnit(faceContourSmooth)
    self.templeFullness = Self.clampUnit(templeFullness)
    self.cheekboneSlim = Self.clampUnit(cheekboneSlim)
    self.chinTaper = Self.clampUnit(chinTaper)
}
```

The actual edit must retain the file's full existing initializer argument order and all old assignments; the excerpt is illustrative. Missing keys already flow through `decodeFloatIfPresent` to zero. [VERIFIED: `BeautyParameters.swift`]

### Pattern 2: One optional face-support envelope with independent regions

**What:** Use one package-only value whose contour and median line are independently optional. `VisionDetectionObservation` carries face-bounds-local injected/source data; `BeautyFaceObservation` carries only mapped image-normalized data. [VERIFIED: current eye-support DTO/observation pattern]

```swift
package struct BeautyObservedFaceSupport: Equatable, Sendable {
    package let contour: [CoordinatePoint]?
    package let medianLine: [CoordinatePoint]?
}
```

This is a recommended private shape, not a locked type name. It must not conform to `Codable`, `CustomStringConvertible`, or any persistence protocol. [VERIFIED: `45-CONTEXT.md`] [ASSUMED]

### Pattern 3: Map once, reject region-locally

**What:** Compose every face-local point into Vision image space and map once, but reject malformed contour and median regions independently. A bad observed region must not throw away the whole otherwise usable face observation. [VERIFIED: existing composition in `VisionFaceDetector.mapObservation`; `45-CONTEXT.md`]

```swift
let visionImagePoint = CoordinatePoint(
    x: visionBounds.x + local.x * visionBounds.width,
    y: visionBounds.y + local.y * visionBounds.height
)
let mapped = try mapper.map(
    point: visionImagePoint,
    from: .visionNormalized,
    to: .imageNormalized
)
guard mapped.isFinite,
      (0...1).contains(mapped.x),
      (0...1).contains(mapped.y)
else { return nil } // nil for this region, not the whole face
```

Do count/unique/raw closed-unit preflight before mapping so an oversized injected payload cannot force unbounded conversion work. Preserve existing behavior for invalid face bounds themselves; invalid shared bounds may still make the observation unmappable. [VERIFIED: `VisionFaceDetector.swift`; `CoordinateMapper.swift`] [ASSUMED]

### Pattern 4: Canonicalize by reversal, not reordering

**What:** While the mapper and original face bounds are available, derive normalized face-local right and down axes from mapped bounds anchors. For the contour, project `(last - first)` onto the right axis and reverse the entire array when negative. For the median, project `(last - first)` onto the down axis and reverse when negative. Reject a near-zero projection. [VERIFIED: mapper-axis eye-order pattern in `VisionFaceDetector.swift`] [ASSUMED]

```swift
func canonicalized(_ points: [CoordinatePoint], along unitAxis: SIMD2<Double>) -> [CoordinatePoint]? {
    guard let first = points.first, let last = points.last else { return nil }
    let delta = SIMD2(last.x - first.x, last.y - first.y)
    let projection = dot(delta, unitAxis)
    guard projection.isFinite, abs(projection) > directionEpsilon else { return nil }
    return projection > 0 ? points : points.reversed()
}
```

For `faceContour`, "right-axis increasing" means face-bounds-local min-X toward max-X; do not label these endpoints as anatomical left/right in diagnostics. Apple names the source path from the subject's left cheek to right cheek, while rendered visual left/right can reverse under mirroring. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d/facecontour] [VERIFIED: local Vision probe]

### Pattern 5: Separate semantic support from the legacy proxy

**What:** Add an optional adapter-produced support beside `FaceGeometry.faceContour`; never overwrite the existing property. Let the semantic value expose two levels such as `contourEligible` and `centerlineEligible`, plus derived apex/side indices only after cross-support validation. [VERIFIED: `WarpControlPoint.swift`; `45-CONTEXT.md`] [ASSUMED]

```swift
struct BeautyFaceSemanticSupport: Equatable, Sendable {
    let contour: [SIMD2<Float>]?
    let medianLine: [SIMD2<Float>]?
    let apexIndex: Int?

    var contourEligible: Bool { contour != nil }
    var centerlineEligible: Bool {
        contour != nil && medianLine != nil && apexIndex != nil
    }
}
```

`makeGeometry` should always build shipped proxy fields exactly as today, then independently attach `observedFaceSupport: validatedSupport(...)`. This makes malformed observed support a field-local absence rather than a legacy-domain failure. [VERIFIED: current adapter construction; `45-CONTEXT.md`]

### Recommended Face-Specific Validation Envelope

The six committed portrait fixtures currently produce one face each; every observed face contour has 17 unique points, every median line has 10 unique points, and both regions report `.openPath`. Across those fixtures, face-local contour width is `0.809...0.889`, height `0.631...0.834`, endpoint separation `0.676...0.872`, and apex depth `0.300...0.669`; median vertical span is `0.515...0.661`, bottom-to-nearest-apex distance is `0.000...0.331`, and median bottom falls between contour sides. Only these aggregate ranges were recorded; no coordinates enter the repository. [VERIFIED: local Apple Vision aggregate probe over `e1...e6`]

Use the following conservative support-validation constants as the planning baseline. They are deliberately distinct from eye thresholds and are not visual caps. Because Apple does not document stable point counts or these plausibility ranges, lock them with exact/inside/outside tests and revisit if supported-OS fixture evidence fails. [ASSUMED]

| Rule | Recommended Bound | Reason |
|---|---|---|
| Contour point count | `7...32` | Seven is the minimum useful open cheek/chin topology; 32 is a bounded ceiling above the observed 17. [ASSUMED; VERIFIED local fixture count] |
| Median point count | `3...16` | Three supports direction/curvature checks; 16 is above the observed 10. [ASSUMED; VERIFIED local fixture count] |
| Exact uniqueness | every point unique within each open path | Prevent zero-length/repeated segments and satisfies duplicate rejection. [ASSUMED] |
| Raw face-local bounds | all points finite in closed `[0,1]` | Vision face landmarks are face-bounds normalized; the phase locks boundary validation. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d] [VERIFIED: `45-CONTEXT.md`] |
| Contour face-local width | `0.50...1.00` | Conservative envelope around observed `0.809...0.889`. [ASSUMED; VERIFIED local fixture probe] |
| Contour face-local height | `0.20...1.00` | Rejects nearly flat paths while retaining observed `0.631...0.834`. [ASSUMED; VERIFIED local fixture probe] |
| Contour endpoint horizontal separation | `>= 0.35` | Rejects same-side/side-inverted endpoints; observed minimum is `0.676`. [ASSUMED; VERIFIED local fixture probe] |
| Contour curvature | maximum perpendicular distance from endpoint chord `>= 0.10` | Treat the contour as an open polyline; do not use closed-polygon area as the primary degeneracy test. [ASSUMED] |
| Median net down projection | `>= 0.25` face-local | Rejects horizontal/coincident centerlines; observed minimum vertical span is `0.515`. [ASSUMED; VERIFIED local fixture probe] |
| Median-to-contour side consistency | median bottom projection along the endpoint chord lies in `0.15...0.85` | Both contour sides must straddle the centerline anchor; observed range is `0.503...0.675` before canonical reversal. [ASSUMED; VERIFIED local fixture probe] |
| Median bottom to contour apex | nearest contour distance `<= 0.40` face-local and nearest index leaves at least two contour points on each side | Supplies a stable interior chin anchor; observed maximum distance is `0.331`. [ASSUMED; VERIFIED local fixture probe] |
| Direction epsilon | `1e-6` after normalized axis projection | Matches the repository's existing eye-order near-coincident guard without reusing eye topology thresholds. [VERIFIED: `VisionFaceDetector.swift`] [ASSUMED] |

Do not require the median line to have a small horizontal span: one current portrait reaches `0.432` face-local X span, consistent with pose/perspective variation. Do not assume the chin apex is the middle array index: five fixtures place it at index 8 of 17, while one pose places it at index 5 before canonical reversal. [VERIFIED: local Apple Vision aggregate probe]

### Anti-Patterns to Avoid

- **Sorting the contour:** X/angle sorting destroys neighbor relationships needed by smoothing and may reorder a turned face. Reverse only the full path. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d/facecontour] [VERIFIED: local probe]
- **Closed-polygon eye logic:** Face contour and median line are open paths in current Vision evidence; copying the eye adapter's shoelace-area topology is conceptually wrong. [VERIFIED: local `pointsClassification == .openPath` probe; `BeautyFaceGeometryAdapter.swift`]
- **Global observation failure for local malformed support:** Do not reuse the eye `mapPoints` throw path unchanged; a malformed face-support region must not remove shipped or safe sibling work. [VERIFIED: `VisionFaceDetector.swift`; `45-CONTEXT.md`]
- **Replacing the synthetic contour:** Do not make shipped controls depend on observed support in Phase 45. [VERIFIED: `45-CONTEXT.md`]
- **Premature routing:** Do not add strengths, caps, emissions, resolver cases, facade cases, or renderer cases in this phase. [VERIFIED: `45-CONTEXT.md`]
- **Semantic-resource backfill:** Do not add a person matte, face-box region, Core ML model, or third-party dependency for deferred double-chin/hairline rows. [VERIFIED: `45-CONTEXT.md`; `.planning/REQUIREMENTS.md`]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---|---|---|---|
| Orientation/lower-left/mirror conversion | Face-specific coordinate transforms | Existing `CoordinateMapper` | It already owns Vision-to-image convention and metadata handling. [VERIFIED: `CoordinateMapper.swift`; tests] |
| Face landmark acquisition | New detector/request/model | Existing `VNDetectFaceLandmarksRequest` | The same request already exposes face contour and median line. [VERIFIED: `VisionFaceDetector.swift`] [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d] |
| Public numeric validation | Field-specific setters/wrappers | Existing `clampUnit`, decoder helper, and `normalized()` | Preserves established finite/range behavior and source compatibility. [VERIFIED: `BeautyParameters.swift`] |
| Observed contour from bounds | Interpolation of the seven-point proxy | Actual `landmarks.faceContour.normalizedPoints` | Bounds cannot prove contour irregularity, temple, cheekbone, or chin topology. [VERIFIED: `45-CONTEXT.md`] |
| Median line from bounds | A vertical line through `bounds.midX` | Actual `landmarks.medianLine.normalizedPoints` | A synthetic line erases pose/asymmetry evidence and violates SUPP-01. [VERIFIED: `45-CONTEXT.md`] |
| Geometry privacy diagnostics | Point dumps, descriptions, JSON, snapshots | Fixed reason codes plus aggregate counts | Coordinates are biometric-adjacent and explicitly excluded from diagnostics/persistence. [VERIFIED: `SECURITY.md`; `45-CONTEXT.md`] |
| Boundary scan design | Ad hoc `rg ... || true` | Archived fail-closed Phase 41 checker pattern | It distinguishes match/no-match/tool-error and adversarially tests classifiers. [VERIFIED: archived `check_eye_support_boundaries.py`] |

**Key insight:** Phase 45 is complete when the repository can distinguish "validated observed contour", "validated contour plus centerline", and "legacy proxy only" without changing shipped behavior or exposing coordinates. It is not complete merely because four fields exist or because a seven-point array is available. [VERIFIED: `45-CONTEXT.md`; `.planning/ROADMAP.md`]

## Common Pitfalls

### Pitfall 1: Legacy inventory tests fail for historical reasons

**What goes wrong:** Adding four encoded keys makes several old tests expecting 48 fail, and the legacy-38 test becomes a 42-key payload if it removes only the ten eye keys. [VERIFIED: `BeautyParametersTests.swift`]
**Why it happens:** The file contains historical test names and four live hard-coded `48` inventory assertions plus the 38-key removal logic. [VERIFIED: `rg` over `BeautyParametersTests.swift`]
**How to avoid:** Update current encoded/reflected inventory assertions to 52; keep explicit historical 31/33 JSON fixture counts unchanged; remove both the ten eye keys and four new face keys when reconstructing a 38-key fixture. [VERIFIED: `BeautyParametersTests.swift`]
**Warning signs:** `legacy.count == 38` reports 42 or old nose/mouth round-trip tests report 52 instead of 48.

### Pitfall 2: Face-support mapping disables the whole selected face

**What goes wrong:** One non-finite or out-of-unit contour point throws from `mapObservation`, returning `.mappingFailed` and eliminating shipped face/nose/mouth work. [VERIFIED: current `mapPoints` and outer catch in `VisionFaceDetector.swift`]
**Why it happens:** The eye-support implementation maps its whole payload with throwing `mapPoints`; Phase 45 requires more selective face-support degradation. [VERIFIED: `VisionFaceDetector.swift`; `45-CONTEXT.md`]
**How to avoid:** Keep shared-bounds failures global, but map contour and median independently into optionals and preserve the observation when a region fails. [ASSUMED]
**Warning signs:** A malformed face-support test yields zero observations or `.mappingFailed` rather than one observation with nil observed face eligibility.

### Pitfall 3: Canonicalization destroys adjacency

**What goes wrong:** Temple/cheek/chin bands later use neighbors that were never neighbors in Vision output. [VERIFIED: `faceContour` is an ordered cheek-to-chin path per Apple docs]
**Why it happens:** Sorting by X or polar angle appears deterministic but changes open-path topology, especially under pose. [ASSUMED]
**How to avoid:** Use mapper-axis endpoint projection only to decide whether to retain or reverse the full array; test reversed inputs, all four orientations, and input mirroring. [VERIFIED: existing eye axis pattern; `45-CONTEXT.md`]
**Warning signs:** The canonical point set is equal but the adjacent-pair sequence differs, or turned-face fixtures fail while symmetric fixtures pass.

### Pitfall 4: Treating mapped image X/Y as face-local axes

**What goes wrong:** Right/left or top/down semantics rotate under `.right`/`.left` orientation and flip under input mirroring. [VERIFIED: `CoordinateMapper.swift`]
**Why it happens:** Mapped image coordinates are final output axes, not the original face-local axes. [VERIFIED: mapper transformations]
**How to avoid:** Derive right/down unit vectors by mapping face-bounds anchors through the same mapper and use vector projection for direction decisions. [VERIFIED: eye order implementation in `VisionFaceDetector.swift`]
**Warning signs:** `.up` passes but `.right`, `.left`, `.down`, or mirrored cases reverse traversal.

### Pitfall 5: Eye thresholds are copied into face support

**What goes wrong:** A valid 17-point face contour is rejected by the eye maximum of 16, or face dimensions are judged against eye-width/height ratios. [VERIFIED: current eye constants; local face fixture probe]
**Why it happens:** Both paths use arrays of normalized points, but their topology and scale differ. [VERIFIED: Apple region descriptions; `45-CONTEXT.md`]
**How to avoid:** Use separately named face constants and an exact face boundary matrix. [VERIFIED: `45-CONTEXT.md`]
**Warning signs:** Production portraits have observed support but `observedFaceSupport` is always nil.

### Pitfall 6: Median line globally gates contour-only support

**What goes wrong:** A missing/invalid median disables contour smoothing or another transform that only needs contour adjacency. [VERIFIED: `45-CONTEXT.md`]
**Why it happens:** A single all-or-nothing support optional is easier than independent region eligibility. [ASSUMED]
**How to avoid:** Keep contour and median validation independent; derive centerline eligibility only from both. [VERIFIED: `45-CONTEXT.md`]
**Warning signs:** Valid contour + invalid median produces no contour eligibility.

### Pitfall 7: Bundled preset neutrality is asserted only after decoding

**What goes wrong:** Someone edits preset JSON to include explicit zeros, so runtime remains neutral but the required legacy/missing-key evidence is lost. [VERIFIED: `45-CONTEXT.md`]
**Why it happens:** Decode-only tests cannot distinguish absent keys from explicit zero keys. [VERIFIED: JSON behavior]
**How to avoid:** Assert the five current preset file hashes or exact bytes in the boundary checker and separately assert decoded new fields are zero. [VERIFIED: current preset SHA-256 probe] [ASSUMED]
**Warning signs:** Resource tests pass while `git diff` shows preset JSON changes.

### Pitfall 8: Privacy leaks through convenience conformances

**What goes wrong:** Raw arrays appear in `String(describing:)`, errors, metrics, snapshots, encoded state, or Demo imports. [VERIFIED: `SECURITY.md`; `45-CONTEXT.md`]
**Why it happens:** `Codable`, `CustomStringConvertible`, log interpolation, or a debug cache is added for inspection. [ASSUMED]
**How to avoid:** Restrict support to package access, `Equatable`/`Sendable` only, fixed reasons/counts, and a fail-closed source classifier. [VERIFIED: archived Phase 41 pattern]
**Warning signs:** Support type names occur near `public`, `Codable`, `Logger`, `metrics`, `UserDefaults`, file I/O, or Demo source.

## Code Examples

### Capture existing Vision regions in the current request

```swift
let contour = landmarks.faceContour?.normalizedPoints.map {
    CoordinatePoint(x: Double($0.x), y: Double($0.y))
}
let median = landmarks.medianLine?.normalizedPoints.map {
    CoordinatePoint(x: Double($0.x), y: Double($0.y))
}
```

The default provider should copy values out of the Vision region immediately and retain no `VNFaceLandmarkRegion2D` object. Both regions are optional. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d] [VERIFIED: current eye extraction pattern]

### Preserve old proxy and attach new evidence separately

```swift
return FaceGeometry(
    bounds: bounds,
    faceContour: landmarks.contains(.faceContour) ? faceContour(in: bounds) : [],
    // existing eye/nose/lip fields unchanged...
    observedFaceSupport: validatedFaceSupport(observation.observedFaceSupport, bounds: bounds)
)
```

This is the essential compatibility shape. The new optional must not alter the existing `faceContour` expression or early-return other domains on failure. [VERIFIED: `BeautyFaceGeometryAdapter.swift`; `45-CONTEXT.md`]

### Build a true legacy-48 payload test

```swift
var legacy = try XCTUnwrap(
    JSONSerialization.jsonObject(with: JSONEncoder().encode(BeautyParameters())) as? [String: Any]
)
for key in ["faceContourSmooth", "templeFullness", "cheekboneSlim", "chinTaper"] {
    legacy.removeValue(forKey: key)
}
XCTAssertEqual(legacy.count, 48)
let decoded = try JSONDecoder().decode(
    BeautyParameters.self,
    from: JSONSerialization.data(withJSONObject: legacy)
)
XCTAssertEqual(decoded.faceContourSmooth, 0)
```

Also give all four fields unequal nonzero values in the 52-key round trip so aliasing cannot pass accidentally. [VERIFIED: established `BeautyParametersTests` pattern]

## State of the Art

| Old Approach | Current Phase 45 Approach | When Changed | Impact |
|---|---|---|---|
| `BeautyLandmarkGroup.faceContour` availability plus a seven-point bounds proxy | Actual mapped Vision contour and median line beside the unchanged proxy | Phase 45 design, 2026-07-21 | Enables honest future contour semantics without changing shipped controls. [VERIFIED: current adapter; `45-CONTEXT.md`] |
| 48 stored public fields | 52 stored fields, with four missing-key/default-zero additions | Phase 45 | Preserves legacy payload/source behavior while exposing independent public intent. [VERIFIED: `45-CONTEXT.md`] |
| Eye-specific observed support validation | Independent face open-polyline validation and centerline consistency | Phase 45 | Avoids rejecting 17-point face contours with eye ceilings and preserves point adjacency. [VERIFIED: current eye adapter; local Vision probe] |
| Seven-row milestone concept including semantic regions | Four contour-driven rows only | Rescoped 2026-07-21 | Double-chin and hairline remain future because approved semantic support/fixtures are absent. [VERIFIED: `.planning/REQUIREMENTS.md`; `PLANS.md`] |

**Deprecated/outdated for this phase:**

- Milestone research passages describing seven new fields or a 55-field inventory are background from before the rescope; the current 52-field `CONTEXT.md`, `REQUIREMENTS.md`, and `ROADMAP.md` are authoritative. [VERIFIED: `.planning/research/*`; current planning files]
- A synthetic face-box contour is not valid evidence for the four new fields, though it remains a compatibility path for shipped controls. [VERIFIED: `45-CONTEXT.md`]
- Person segmentation, local semantic models, runtime downloads, and third-party beauty SDKs are not part of Phase 45. [VERIFIED: `.planning/REQUIREMENTS.md`; `45-CONTEXT.md`]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|---|---|---|
| A1 | Recommended face validation bounds are `7...32` contour points, `3...16` median points, and the listed geometry envelope. | Recommended Face-Specific Validation Envelope | A valid supported-OS Vision result may be rejected or malformed support accepted; exact synthetic boundaries plus aggregate real-fixture tests must gate the decision. |
| A2 | A single optional support struct with optional contour/median arrays is the cleanest representation. | Pattern 2 | The planner may choose equivalent enums/nested values; privacy and independent eligibility must remain identical. |
| A3 | Canonical face traversal should be face-bounds-local min-X to max-X and median top-to-bottom, implemented by reversal. | Pattern 4 | If downstream semantic naming expects anatomical left-to-right, index labels could invert; avoid anatomical labels and test orientation/mirror invariance before Phase 46. |
| A4 | Preset byte/hash checking belongs in the boundary helper in addition to runtime decoding. | Pitfall 7 | If omitted, explicit-zero preset edits could satisfy runtime tests while violating the missing-key evidence requirement. |

## Open Questions

1. **Which Phase 46 fields require the median line?**
   - What we know: Phase 45 must expose independent contour eligibility and contour-plus-centerline eligibility. [VERIFIED: `45-CONTEXT.md`]
   - What's unclear: Provider-specific requirements for smooth contour, temple, cheekbone, and chin taper are intentionally deferred. [VERIFIED: `45-CONTEXT.md`]
   - Recommendation: Do not bind fields in Phase 45; expose the two eligibility levels and let Phase 46 assign prerequisites using provider tests. [ASSUMED]

2. **Are the recommended numerical support thresholds valid across every supported Vision revision?**
   - What we know: All six current fixtures return 17/10 unique open-path points and fit the recorded aggregate envelope. [VERIFIED: local Vision probe]
   - What's unclear: Apple does not promise stable point counts or exact geometric ranges in the cited API documentation. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarkregion]
   - Recommendation: Lock the proposed conservative values for Phase 45 with exact boundary tests and one aggregate real-fixture test; if a supported-OS fixture fails, adjust thresholds from evidence without changing privacy or topology rules. [ASSUMED]

No open question blocks planning; both items are contained by the agent's discretion and downstream provider ownership. [VERIFIED: `45-CONTEXT.md`]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|---|---|---|---|---|
| Swift compiler | Source and SwiftPM tests | ✓ | Apple Swift 6.3.3 | — |
| SwiftPM manifest | Module graph and tests | ✓ | tools 6.0 | — |
| Xcode / Apple SDKs | Vision/CoreImage/XCTest | ✓ | Xcode 26.6 (17F113) | Injected observations cover deterministic unit tests, but actual Vision integration has no non-Apple fallback. |
| Apple Vision | Default observation provider and real-fixture probe | ✓ | Existing iOS 17+ deployment baseline | None; no third-party/model fallback is permitted. |
| Python 3 | Boundary helper | ✓ | 3.9.6 | Swift or shell static checks are possible, but archived Python pattern is preferred. |
| Portrait fixtures | Aggregate observed-support integration test | ✓ | 6 committed files | Synthetic injected observations remain normative for exact edge cases. |

No dependency is missing and no installation step is required. [VERIFIED: local command/file probes]

## Validation Architecture

### Test Framework

| Property | Value |
|---|---|
| Framework | XCTest via SwiftPM, Apple Swift 6.3.3 / Xcode 26.6 [VERIFIED: `Package.swift`; command probes] |
| Config file | `BeautySDK/Package.swift` [VERIFIED: repository] |
| Baseline suite | 314 tests currently pass; measured local full run is under 30 seconds. [VERIFIED: `swift test --package-path BeautySDK`; test listing] |
| Quick contract command | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` |
| Quick mapping command | `swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests` |
| Quick adapter command | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` |
| Full suite command | `swift test --package-path BeautySDK` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|---|---|---|---|---|
| FACE-07 | `faceContourSmooth` default, `[0,1]`, non-finite zero, normalized copy, independent round trip | Unit | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` | ✅ extend existing |
| FACE-08 | `templeFullness` independent storage and compatibility | Unit | same | ✅ extend existing |
| FACE-09 | `cheekboneSlim` independent storage and compatibility | Unit | same | ✅ extend existing |
| FACE-12 | positive-only `chinTaper` distinct from signed `chinLength` | Unit | same | ✅ extend existing |
| FACE-07/08/09/12 | Five bundled presets omit new keys and decode four zeros | Resource regression + static hash | `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` plus boundary helper | ✅ extend existing |
| SUPP-01 | Default Vision request captures both regions; face-local points map once through orientation/mirror | Unit/integration | `swift test --package-path BeautySDK --filter BeautyDetectionTests` | ✅ extend existing |
| SUPP-02 | Reversal-only canonical order, independent region validity, count/unique/finite/bounds/degeneracy/side/internal consistency rejection | Unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | ✅ extend existing |
| SUPP-02 | Mapper-axis contour and median directions stay stable for `.up/.right/.left/.down` plus input mirror | Unit | `swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests` | ✅ extend existing |
| SUPP-01/02 | Invalid observed support leaves selected observation and legacy proxy/sibling geometry intact | Unit/integration | detector + adapter focused commands | ✅ extend existing |
| SUPP-04 | No public/Codable/persistent/diagnostic/Demo/dependency/resource exposure | Static self-test/live gate | `python3 .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py --self-test && python3 .planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py` | ❌ Wave 0 |

### Exact Test Matrices

**Public contract matrix:** [VERIFIED: `45-CONTEXT.md`; existing test patterns]

- Each of four fields: negative → 0, in-range distinct value retained, overflow → 1, NaN/+∞/−∞ → 0.
- Direct mutation followed by `normalized()` reapplies all four rules without mutating source.
- `Mirror` labels/count and JSON object count are exactly 52; four labels appear once.
- Full 52-key unequal-value round trip; legacy 48-key decode after removing the four new keys; source-style initializer omits all four.
- Update all current encoded/reflected hard-coded 48 assertions to 52 while retaining explicit historical 31/33 fixture counts; keep the legacy-38 reconstruction at exactly 38 by removing 14 later keys.

**Mapping/canonical direction matrix:** [VERIFIED: `45-CONTEXT.md`; existing mapping tests]

- Contour forward/reversed and median forward/reversed inputs yield identical canonical arrays.
- `.up`, `.right`, `.left`, `.down`, each with input mirror false/true; preview mirroring does not affect image-normalized support.
- Face-local closed-unit edge 0/1 accepted; just-outside, NaN, infinity, invalid bounds rejected region-locally with no raw diagnostic.
- Invalid contour + valid median, valid contour + invalid median, both absent, and both valid are distinct.
- Default provider over six portraits produces at least one aggregate complete support without printing coordinates.

**Adapter boundary matrix:** [ASSUMED thresholds; VERIFIED requirement categories]

- Contour counts 6/7/8 and 31/32/33; median counts 2/3/4 and 15/16/17.
- Exact duplicate, adjacent duplicate, all-identical, non-finite, out-of-unit, flat/collinear, undersized width/height, coincident endpoint direction.
- Each recommended numeric boundary at just below/exact/just above.
- Median missing, direction-degenerate, side-inconsistent, too far from apex, or nearest apex at an endpoint.
- Valid contour + invalid median preserves contour eligibility; malformed observed support preserves the exact seven-point legacy contour and all safe sibling geometry.

### Sampling Rate

- **Per task commit:** Run the narrowest affected focused command above plus `git diff --check`. [VERIFIED: `AGENTS.md`]
- **Per wave merge:** Run `swift test --package-path BeautySDK`. [VERIFIED: repository GSD validation pattern]
- **Phase gate:** Full SwiftPM, boundary helper self-test/live, preset hash/absence checks, active-source owner scan, and `git diff --check` must pass before Phase 46. [VERIFIED: `45-CONTEXT.md`; archived Phase 41 validation]
- **Maximum feedback gap:** Do not allow three consecutive implementation tasks without an automated focused test. [VERIFIED: Nyquist workflow pattern]

### Wave 0 Gaps

- [ ] `.planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py` — create fail-closed `rg` 0/1/error classification, repository path containment, public/Codable/persistence/diagnostic/Demo/dependency/semantic-resource checks, fixed preset SHA-256 checks, and adversarial `--self-test`. [ASSUMED; VERIFIED archived analog]
- [ ] Extend `BeautyFaceGeometryAdapterTests.swift` with face-specific fixtures before adapter implementation; do not reuse eye fixture helpers/constants where they obscure face topology. [VERIFIED: `45-CONTEXT.md`]
- [ ] Use pre-phase commit `9aedd6b40a7c033ac86cea2c75e06bac138cf9ef` as the immutable `BeautySDK/Package.swift` / `BeautyDemo` comparison baseline and the current hashes below as the bundled-preset byte baseline. [VERIFIED: `git rev-parse HEAD`; local SHA-256 probe]

| Bundled Preset | SHA-256 Baseline |
|---|---|
| `clear.json` | `58327c8ef8cc8323d4a6e4d98754d8c9bf797b348804ca2a308c4c39e00856f8` [VERIFIED: `shasum -a 256`] |
| `id-photo-natural.json` | `d6d2d3e5872ae0aa25823c4d76e07057ecdfa336818cd116509627995941c609` [VERIFIED: `shasum -a 256`] |
| `male-natural.json` | `1c6e632e8740602fa662c42e41cf9709eec29b3138bf58df43fad40d8b5d0c08` [VERIFIED: `shasum -a 256`] |
| `natural.json` | `bd102ec3643f1625d561af66fd0e7fb67c33fe5061720600907ed3fd931a08da` [VERIFIED: `shasum -a 256`] |
| `refined.json` | `67f238fddf8d9dc08bc8b24121af25d11f9caf8a85b905cf83a47b0dff675722` [VERIFIED: `shasum -a 256`] |

No new XCTest target or config file is needed. [VERIFIED: `Package.swift`]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---|---|---|
| V2 Authentication | No | No identity/account/authentication path is in scope. [VERIFIED: `45-CONTEXT.md`] |
| V3 Session Management | No | Support is request-scoped in-memory state, not a user/server session. [VERIFIED: `45-CONTEXT.md`] |
| V4 Access Control | No | No entitlement, payment, multi-user, or remote resource path exists. [VERIFIED: `.planning/REQUIREMENTS.md`; `45-CONTEXT.md`] |
| V5 Input Validation | Yes | Fixed counts, finite/closed-unit bounds, uniqueness, open-path degeneracy, canonical direction, and cross-support consistency before providers. [VERIFIED: SUPP-02; `45-CONTEXT.md`] |
| V6 Cryptography | No | No secrets, model signing, persistence, download, or network operation is introduced. [VERIFIED: `45-CONTEXT.md`] |

### Known Threat Patterns for Swift/Vision

| Pattern | STRIDE | Standard Mitigation |
|---|---|---|
| Oversized/malformed point arrays | Tampering / Denial of Service | Preflight fixed ceilings before mapping; validate every point and derived operation; reject region-locally. [VERIFIED: `45-CONTEXT.md`] |
| Orientation/mirror semantic inversion | Tampering | Derive axes through the same mapper, canonicalize by whole-array reversal, and test the full metadata matrix. [VERIFIED: `CoordinateMapper.swift`; `45-CONTEXT.md`] |
| Synthetic proxy presented as observation | Spoofing | Separate `observedFaceSupport` from legacy `faceContour`; new fields later require the former. [VERIFIED: `45-CONTEXT.md`] |
| Raw coordinate disclosure | Information Disclosure | Package-only non-Codable values, no description/log/metric payload, fixed reasons/counts, active-source scans. [VERIFIED: `SECURITY.md`; SUPP-04] |
| Support retained beyond request | Information Disclosure | Immutable value carried only through detection → selected observation → adapter for the current processing call; no cache/persistence. [VERIFIED: current observation lifecycle; `45-CONTEXT.md`] |
| Model/dependency/network scope injection | Supply Chain / Information Disclosure | Require unchanged `Package.swift`, no semantic asset extensions/manifests, no network/cloud imports, and no Demo internal imports. [VERIFIED: `45-CONTEXT.md`] |
| Boundary tool error treated as clean | Repudiation | Checker classifies `rg` 0/1/>1 and fails on missing paths/unclassified matches; adversarial self-test. [VERIFIED: archived Phase 41 checker] |

## Project Constraints (from AGENTS.md)

- Treat repository text as the record system; do not assume facts absent from repository evidence. [VERIFIED: `AGENTS.md`]
- Read `PLANS.md` before changes; conflict priority is code/tests, then `PLANS.md`, then specialist root docs, then historical `docs/`. [VERIFIED: `AGENTS.md`]
- Keep changes minimal and traceable, preserve unrelated/user changes, and record extra discoveries in `PLANS.md` rather than expanding scope. [VERIFIED: `AGENTS.md`]
- Do not duplicate the same fact across documents; update the authoritative owner when a contract changes. [VERIFIED: `AGENTS.md`]
- Update `DESIGN.md` for parameter/support invariants, `SECURITY.md` for privacy/input boundaries, `RELIABILITY.md` for errors/metrics/degradation, `PRODUCT_SENSE.md` for public acceptance, and `PLANS.md` for progress/evidence. [VERIFIED: `AGENTS.md`; `45-CONTEXT.md`]
- Use existing naming, directories, and abstraction levels; run the narrowest meaningful build/test/static check and report any unavailable Xcode prerequisite honestly. [VERIFIED: `AGENTS.md`]
- No Demo source is in Phase 45. If a Demo build is nevertheless needed, first list schemes/simulators and explicitly select an available iOS Simulator rather than defaulting to “My Mac.” [VERIFIED: `AGENTS.md`; `45-CONTEXT.md`]

## Sources

### Primary (HIGH confidence)

- `45-CONTEXT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md` — locked scope, requirement mapping, success criteria, and milestone state. [VERIFIED: codebase]
- `AGENTS.md`, `PLANS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md` — repository instructions and owning contracts. [VERIFIED: codebase]
- `BeautyParameters.swift` and `BeautyParametersTests.swift` — exact manual scalar/Codable lifecycle and hard-coded inventory regression sites. [VERIFIED: codebase]
- `BeautyFaceObservation.swift`, `VisionFaceDetector.swift`, `CoordinateMapper.swift`, and detection tests — private lifecycle, face-local mapping, mapper-axis order, and default request. [VERIFIED: codebase]
- `BeautyFaceGeometryAdapter.swift`, `WarpControlPoint.swift`, face adapter/provider tests — legacy proxy and detection-to-effects validation seam. [VERIFIED: codebase]
- Archived Phase 41 research/plans/validation/checker — closest lifecycle, redaction, fail-closed scan, and Nyquist analog; face topology/thresholds were intentionally researched independently. [VERIFIED: `.planning/milestones/v1.11-phases/41-public-contract-and-observed-eye-support/`]
- Local aggregate Vision probe over `e1.png...e6.jpg` — 17-point contours, 10-point median lines, open-path classification, uniqueness, and aggregate geometry ranges. [VERIFIED: executed 2026-07-21]

### Official Apple Documentation (HIGH/MEDIUM confidence)

- [VNFaceLandmarks2D](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — landmark points are face-bounds normalized with lower-left origin; exposes contour and median line. [CITED]
- [faceContour](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/facecontour) — ordered cheek-over-chin-to-cheek region. [CITED]
- [medianLine](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/medianline) — vertical center-of-face region. [CITED]
- [VNFaceLandmarkRegion2D](https://developer.apple.com/documentation/vision/vnfacelandmarkregion2d) — normalized points and point classification. [CITED]
- [VNPointsClassification](https://developer.apple.com/documentation/vision/vnpointsclassification) — open, closed, and disconnected path classifications. [CITED]

### Secondary (MEDIUM confidence)

- `.planning/research/{STACK,FEATURES,ARCHITECTURE,PITFALLS,SUMMARY}.md` — milestone discovery; use only the reduced-scope summary where older seven-field/55-field passages conflict with current planning. [VERIFIED: codebase]

### Tertiary (LOW confidence)

- None. Numerical recommendations unsupported by Apple guarantees are explicitly tagged `[ASSUMED]` and listed in the Assumptions Log.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — current manifest/tool versions and Apple API surface are directly verified. [VERIFIED/CITED]
- Public contract: HIGH — exact manual lifecycle and every stale count site are inspected. [VERIFIED]
- Architecture: HIGH — existing eye support proves the lifecycle and mapper-axis pattern; locked context fixes ownership and isolation. [VERIFIED]
- Face validation constants: MEDIUM — grounded in six local fixtures and conservative margins, but Apple does not guarantee exact counts/ranges. [VERIFIED local probe; ASSUMED bounds]
- Pitfalls/security: HIGH — concrete source behavior, archived executable boundary patterns, and locked privacy constraints support them. [VERIFIED]

**Research date:** 2026-07-21
**Valid until:** 2026-08-20 for the repository stack; re-run the aggregate Vision probe if Xcode/Vision revision, deployment platforms, or portrait fixtures change. [ASSUMED]
