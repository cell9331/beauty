# Phase 41: Public Contract and Observed Eye Support - Research

**Researched:** 2026-07-16  
**Domain:** Swift/Apple Vision private eye-landmark support and compatibility-safe SDK parameters  
**Confidence:** HIGH for project boundaries, existing seams, and resolved support-validation thresholds; MEDIUM for optional real-portrait pupil coverage

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Public Scalar Contract
- Add exactly `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, `eyeTilt`, `innerCornerOpen`, `outerCornerOpen`, and `eyeSymmetry` to `BeautyParameters`; do not add aliases or a public eye-support type.
- Keep `eyeTilt` signed and normalize it to `[-1, 1]`; keep the other nine new fields positive-only and normalize them to `[0, 1]`.
- Default every new field to zero in source initialization and missing-key decoding so existing call sites, the legacy 38-field JSON shape, presets, shipped caps, and shipped vectors remain unchanged.
- Encode all ten fields independently and prove the exact stored inventory becomes 48 fields: 47 numeric fields plus `filterId`.

### Observed Eye-Support Model
- Capture Vision left/right eye contours and optional left/right pupils in one private, `Sendable`, request-scoped representation owned by `BeautyDetection`; never synthesize a pupil when Vision omits one.
- Convert face-bounds-normalized Vision coordinates exactly once into the repository image-normalized convention before provider use, with finite and closed-unit-bounds validation at the conversion boundary.
- Preserve anatomical side identity explicitly and canonicalize semantic upper, lower, inner, outer, corner, center, and pupil supports independently of input winding; cover portrait orientation and mirrored metadata with fixtures.
- Prefer validated observed support for the new fields while retaining the established symmetric proxy path only for shipped zero-default compatibility and shipped fields.

### Validation and Degradation
- Reject contour support that is empty, duplicate-only, non-finite, out of bounds, implausibly small/large, degenerate, or over a fixed point ceiling before it reaches `BeautyEffects`.
- Validate pupils independently using finiteness, containment relative to the owning eye, bounded center offset, and paired plausibility so blink-inaccurate or malformed pupils cannot move eyelids or create gaze evidence.
- Missing or implausible pupil support invalidates only `pupilSize` and `gazeCorrection`; contour-only siblings remain eligible when their contour support is valid.
- Missing either eye contour preserves the existing complete eye-domain skip; paired-only symmetry support also fails closed without fabricating the absent side.

### Privacy and Ownership
- Keep all raw and derived contour/pupil coordinates package-internal, ephemeral, and absent from public APIs, Codable state, logs, metrics, warnings, errors, descriptions, snapshots, and Demo imports.
- Use fixed redacted reason codes and aggregate counts only; no diagnostic may reveal side-specific coordinates, bounding boxes, pupil offsets, contour samples, or biometric-adjacent payloads.
- Add no dependency, target, model download, network/cloud path, persistence, render pass, facade method, or public result type.
- Phase 41 tests own compatibility, conversion, ordering, side identity, validation, field-local support availability, and boundary scans; visible transform semantics and cap calibration remain downstream.

### the agent's Discretion
- Exact private type names and file splits may follow the existing `BeautyFaceObservation` / `VisionFaceDetector` / `BeautyFaceGeometryAdapter` seams.
- Exact conservative numerical validation thresholds and point ceilings may be selected during planning, provided they are explicit, bounded, fixture-tested, and not presented as final visual caps.
- The adapter may retain validated full contours in addition to derived semantic subsets when that avoids lossy re-derivation, provided lifecycle and privacy constraints remain intact.

### Deferred Ideas (OUT OF SCOPE)
- Ten field-specific provider transforms, fourteen named emissions, resolver/conflict/facade routing, correction dead zones, and automatic symmetry behavior — Phase 42.
- Renderer matrix, strict decoded output comparisons, eligibility-aware fixture evidence, and ignored gallery — Phase 43.
- Final exact caps, exhaustive degradation/transitions, provider-eligible combined convergence, fail-closed boundary checker, ledger promotion, and owner closeout — Phase 44.
- `去脂`, `祛红血丝`, Demo UI, physical-device validation, commercial naturalness, optimized performance, packaging, shipping, and launch readiness — future scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research support |
|---|---|---|
| EYE-01 | Nine positive-only eye scalars are independent, default-zero, finite-clamped to `0...1`, and never aliases. | Extend `BeautyParameters`' existing initializer, `CodingKeys`, `normalized()`, and field-by-field tests. [VERIFIED: BeautyParameters.swift] |
| EYE-02 | Signed `eyeTilt` defaults to zero, clamps to `-1...1`, and preserves both directions. | Reuse `clampSigned`; add signed round-trip/normalization tests. [VERIFIED: BeautyParameters.swift; BeautyParametersTests.swift] |
| EYE-03 | Legacy 38-field JSON/presets decode ten zeros; unequal 48-field values round-trip; stored inventory is 47 numeric plus `filterId`. | Mirror the established 33-to-38 compatibility tests and `Mirror(reflecting:)` inventory assertion. [VERIFIED: BeautyParametersTests.swift; bundled preset JSON] |
| EYE-04 | Zero new fields preserve shipped eye behavior and each new field remains independently distinguishable. | Keep existing four eye fields and proxy path untouched; Phase 41 proves neutral equality while Phase 42 owns vector distinction. [VERIFIED: CONTEXT.md; EyeWarpProvider.swift] |
| EYE-05 | Private request-scoped left/right contours and optional pupils convert Vision coordinates to image-normalized coordinates without public leakage. | Extend the current detector provider payload, `CoordinateMapper`, and package-only `BeautyFaceObservation`. [VERIFIED: VisionFaceDetector.swift; CoordinateMapper.swift; SECURITY.md] |
| EYE-06 | Adapter canonicalizes side-aware semantic supports and rejects malformed structures before effects. | Introduce validated private support beside `FaceGeometry`; deterministic ordering must not depend on Vision winding. [VERIFIED: BeautyFaceGeometryAdapter.swift; CONTEXT.md] |
| EYE-07 | Invalid pupils remove only pupil-dependent work; missing either contour retains complete eye-domain skip. | Keep pupil eligibility independent from contour eligibility and preserve resolver's existing eye skip behavior. [VERIFIED: BeautyEffectResolver.swift; MissingLandmarkDegradationTests.swift] |
</phase_requirements>

## Summary

Phase 41 is a compatibility and evidence-boundary phase, not a renderer phase. The repository already centralizes public scalar normalization and Codable compatibility in `BeautyParameters`, converts Vision bounds through `CoordinateMapper`, stores selected faces in package-only `BeautyFaceObservation`, and derives proxy geometry in `BeautyFaceGeometryAdapter`. [VERIFIED: BeautyParameters.swift; CoordinateMapper.swift; BeautyFaceObservation.swift; BeautyFaceGeometryAdapter.swift]

The material addition is a private, `Sendable`, request-scoped observed-eye payload. The detector should carry left/right contour samples and optional pupil samples from the existing `VNDetectFaceLandmarksRequest`; the mapper should convert once from Vision's face-bounds-normalized coordinates into image-normalized coordinates; the adapter should validate and canonicalize semantic supports while preserving anatomical side identity. Apple Vision documents eye regions and pupil regions on `VNFaceLandmarks2D`; its pupil documentation warns that pupil location can be inaccurate while blinking, so pupil-dependent fields must fail closed independently. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d] [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d/leftpupil]

**Primary recommendation:** Add the ten defaulted public fields first, then thread one private validated observed-support value through detector → observation → adapter; do not expose points, persist them, or implement provider transforms in this phase. [VERIFIED: 41-CONTEXT.md; ARCHITECTURE.md; SECURITY.md]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|---|---|---|---|
| Ten-field public contract and JSON compatibility | BeautyCore public model | Core tests/resources | `BeautyParameters` owns stored fields, coding keys, defaults, and normalization. [VERIFIED: BeautyParameters.swift] |
| Vision contour/pupil acquisition and coordinate conversion | BeautyDetection | Core `CoordinateMapper` | The existing single Vision landmark request and mapper are the platform seam; no new request or target is needed. [VERIFIED: VisionFaceDetector.swift; CoordinateMapper.swift; Package.swift] |
| Semantic support validation/canonicalization | BeautyEffects planning adapter | BeautyDetection observation | `BeautyFaceGeometryAdapter` already converts selected observations into effect geometry; raw points remain package-private. [VERIFIED: BeautyFaceGeometryAdapter.swift] |
| Provider transforms, fourteen emissions, conflict and facade routing | BeautyEffects / BeautySDK | — | Explicitly deferred to Phase 42; Phase 41 only establishes inputs and eligibility. [VERIFIED: 41-CONTEXT.md; ROADMAP.md] |
| Privacy/boundary tests and redacted diagnostics | Cross-module tests | `SECURITY.md` / `RELIABILITY.md` | Existing active-source scans and summary types prohibit raw biometric-adjacent coordinates in public or diagnostic surfaces. [VERIFIED: SECURITY.md; VisionFaceDetectorTests.swift] |

## Standard Stack

### Core

| Technology | Version | Purpose | Why standard |
|---|---|---|---|
| Swift / SwiftPM | tools 6.0; local compiler 6.3.3 | Public model, package concurrency, detection and adapter code | `BeautySDK/Package.swift` already defines the module graph and platform floor; no dependency change is required. [VERIFIED: Package.swift; `swift --version`] |
| Apple Vision | iOS 17 baseline | `VNFaceLandmarks2D` eye contours and optional pupils | The existing detector already uses one `VNDetectFaceLandmarksRequest`; official Vision regions are the observed-support source. [VERIFIED: VisionFaceDetector.swift; Package.swift] [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d] |
| Core Graphics / ImageIO | platform SDK | Orientation metadata and normalized coordinate types | `BeautyInputMetadata` and `CoordinateMapper` already own orientation/mirror behavior. [VERIFIED: CoordinateMapper.swift; BeautyInputMetadata.swift] |
| Existing unified local warp | repository implementation | Downstream geometry execution | Phase 41 must not add a render pass; all transforms remain in the existing pipeline. [VERIFIED: DESIGN.md; ROADMAP.md] |

### Supporting

| Tool | Version | Purpose | When to use |
|---|---|---|---|
| XCTest | Xcode 26.6 toolchain | Contract, mapping, validation, and privacy tests | Run focused tests while implementing each seam and the full package suite at the phase gate. [VERIFIED: Package.swift; `xcodebuild -version`] |
| Python standard library | 3.9.6 locally | No Phase 41 renderer helper is needed; reserve the bounded helper pattern for Phase 43. [VERIFIED: `python3 --version`; 41-CONTEXT.md] |

### Alternatives Considered

| Instead of | Could use | Tradeoff |
|---|---|---|
| Existing Apple Vision request | Third-party face SDK or Core ML gaze model | Adds dependency, model, privacy, licensing, and supply-chain scope prohibited by the locked boundary. [VERIFIED: 41-CONTEXT.md; Package.swift; SECURITY.md] |
| Private frame-scoped support | Public landmark/pupil type or persisted debug state | Violates scalar-only public API and biometric-adjacent retention rules. [VERIFIED: SECURITY.md; DESIGN.md] |
| One canonical mapper conversion | Per-provider coordinate conversions | Duplicates orientation/mirror logic and risks side/origin inversion. [VERIFIED: CoordinateMapper.swift; PITFALLS.md] |

**Installation:** None. Phase 41 adds no package, target, model, or network service. [VERIFIED: 41-CONTEXT.md; Package.swift]

## Package Legitimacy Audit

No external package is installed or recommended for this phase. The package graph remains the existing local SwiftPM targets. [VERIFIED: Package.swift]

## Architecture Patterns

### System Architecture Diagram

```text
BeautyParameters (48 stored fields; ten eye fields default zero)
        │ geometry-required request
        ▼
VNDetectFaceLandmarksRequest (existing detector)
        │ Vision face-bounds coordinates
        ▼
CoordinateMapper: orientation + mirror + lower-left → image-normalized
        │ finite, closed-unit validation
        ▼
BeautyFaceObservation (package-private, request-scoped, Sendable)
        │ side-aware contour + optional pupil evidence
        ▼
BeautyFaceGeometryAdapter
  canonical upper/lower/inner/outer/center/span/tilt/pupil support
        │ eligible private support only
        ▼
Phase 42 EyeWarpProvider / resolver / unified warp (deferred)
        │
        ▼
Public image + aggregate redacted summary (no points)
```

The entry point remains the existing image/frame processing path; detection is requested only when normalized parameters require geometry. [VERIFIED: BeautyEngineGeometryDetection.swift; BeautyEffectResolver.swift]

### Recommended Project Structure

```text
BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift      # ten public scalars
BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift      # Vision payload + one conversion
BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift  # private observed support owner
BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift # validation/canonicalization
BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift     # 48-field contract
BeautySDK/Tests/BeautyDetectionTests/{CoordinateMapperTests,VisionFaceDetectorTests}.swift
BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift # required first-task test seam
```

These are existing seams except the adapter-focused test file, whose creation and synthetic fixtures are an explicit first-task dependency before adapter implementation. [VERIFIED: `rg --files BeautySDK/Sources BeautySDK/Tests`; checker-resolved Phase 41 constraint]

### Pattern 1: Defaulted compatibility-safe scalar

**What:** Add each field to the stored struct, `CodingKeys`, source initializer, decoder, and `normalized()` in one change; use zero when a key is absent and clamp non-finite values to zero. [VERIFIED: BeautyParameters.swift]

```swift
public var eyeHeight: Float
public var eyeTilt: Float

public init(eyeHeight: Float = 0, eyeTilt: Float = 0, /* existing args */) {
    self.eyeHeight = Self.clampUnit(eyeHeight)
    self.eyeTilt = Self.clampSigned(eyeTilt)
    // existing assignments remain unchanged
}

func decodeFloatIfPresent(_ key: BeautyParameters.CodingKeys) throws -> Float {
    try decodeIfPresent(Float.self, forKey: key) ?? 0
}
```

The exact implementation must preserve the existing full initializer argument order and source-call compatibility. [VERIFIED: BeautyParameters.swift]

### Pattern 2: One mapper boundary

**What:** Convert every Vision point through the existing `CoordinateMapper` exactly once, then reject non-finite or out-of-unit results before storing them. [VERIFIED: CoordinateMapper.swift]

```swift
let mapped = try points.map { point in
    let imagePoint = try mapper.map(
        point: CoordinatePoint(x: Double(point.x), y: Double(point.y)),
        from: .visionNormalized,
        to: .imageNormalized
    )
    guard imagePoint.x.isFinite, imagePoint.y.isFinite,
          (0...1).contains(imagePoint.x), (0...1).contains(imagePoint.y)
    else { throw SupportError.invalidCoordinate }
    return SIMD2<Float>(Float(imagePoint.x), Float(imagePoint.y))
}
```

The mapper already flips Vision's lower-left normalized Y and applies orientation/input-mirror metadata; preview mirroring must not alter image-normalized support. [VERIFIED: CoordinateMapper.swift; CoordinateMapperTests.swift]

### Pattern 3: Evidence-first, field-local support

**What:** Store contours and pupils as optional private evidence, derive semantic subsets deterministically, and let pupil invalidity remove only pupil-dependent fields. [VERIFIED: 41-CONTEXT.md; ARCHITECTURE.md]

```swift
package struct ObservedEyeSupport: Equatable, Sendable {
    package let side: EyeSide
    package let contour: [SIMD2<Float>]
    package let upper: [SIMD2<Float>]
    package let lower: [SIMD2<Float>]
    package let innerCorner: SIMD2<Float>
    package let outerCorner: SIMD2<Float>
    package let center: SIMD2<Float>
    package let pupil: SIMD2<Float>?
}
```

This example is a private shape, not a required type name; raw/derived support must not be `public`, `Codable`, logged, or retained across requests. [VERIFIED: 41-CONTEXT.md; SECURITY.md]

### Anti-Patterns to Avoid

- **Symmetric proxy correction:** Do not use existing `eyeSize`/center proxies as gaze or symmetry evidence; they cannot establish an observed deviation. [VERIFIED: PITFALLS.md]
- **Provider-local coordinate math:** Do not let Phase 42 providers repeat orientation, mirror, or winding handling. [VERIFIED: CoordinateMapper.swift; 41-CONTEXT.md]
- **Global pupil gate:** Do not require pupils for contour-only controls or zero the entire eye domain when a pupil is absent. [VERIFIED: 41-CONTEXT.md; EYE-07]
- **Diagnostic payloads:** Do not include points, side labels paired with coordinates, bounding boxes, pupil offsets, or raw Vision descriptions in summaries/errors. [VERIFIED: SECURITY.md]

## Don't Hand-Roll

| Problem | Don't build | Use instead | Why |
|---|---|---|---|
| Orientation/mirror conversion | A second eye-specific transform | Existing `CoordinateMapper` | It is already tested across up/right/left/down and input/preview mirror cases. [VERIFIED: CoordinateMapperTests.swift] |
| Face landmark acquisition | A new Vision request or third-party detector | Existing `VNDetectFaceLandmarksRequest` path | Keeps one request, current availability semantics, and no new dependency/model. [VERIFIED: VisionFaceDetector.swift; Package.swift] |
| Scalar normalization | Per-field ad hoc setter logic | `BeautyParameters` clamp helpers and `normalized()` | Existing behavior guarantees finite fallback and range consistency. [VERIFIED: BeautyParameters.swift] |
| Render geometry execution | Eye-only render pass | Existing `WarpControlPoint` / unified geometry pipeline | Phase 41 owns support only; split passes would break later accounting. [VERIFIED: DESIGN.md; ROADMAP.md] |
| Public geometry diagnostics | Debug serialization of landmarks | Fixed reason codes and aggregate counts | Root security contract classifies landmarks as biometric-adjacent and forbids logging/persistence. [VERIFIED: SECURITY.md] |

**Key insight:** The hard part is preserving evidence provenance and lifecycle, not generating point arrays. Reusing the repository's mapper, detector request, scalar clamp, and privacy seams prevents coordinate drift and accidental public/persistent biometric data. [VERIFIED: existing source and root contracts]

## Common Pitfalls

### Pitfall 1: Vision origin or orientation inversion

**What goes wrong:** Upper/lower, left/right, or mirrored metadata reverses semantic supports. [VERIFIED: PITFALLS.md]  
**Why it happens:** Vision points are face-bounds normalized while rendering uses image-normalized coordinates; orientation and input mirroring are separate metadata. [CITED: https://developer.apple.com/documentation/vision; VERIFIED: CoordinateMapper.swift]  
**How to avoid:** Convert once with `CoordinateMapper`, then use synthetic fixtures for all four representative orientations plus input mirroring. [VERIFIED: CoordinateMapperTests.swift]  
**Warning signs:** A mapped point leaves `[0,1]`, a mirrored fixture has unchanged X, or inner/outer labels swap.

### Pitfall 2: Pupil support survives blinking or malformed input

**What goes wrong:** Pupil-size or gaze work moves an eyelid or invents a direction. [VERIFIED: PITFALLS.md]  
**Why it happens:** Apple documents pupil locations may be inaccurate while blinking. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d/leftpupil]  
**How to avoid:** Validate finite bounds, containment in the owning contour, bounded center offset, and paired plausibility; invalidate only `pupilSize`/`gazeCorrection`. [VERIFIED: 41-CONTEXT.md]  
**Warning signs:** A pupil outside its eye is accepted or a pupil-only failure zeros contour siblings.

### Pitfall 3: Input winding determines semantic order

**What goes wrong:** Upper/lower or nasal/temporal corners change when Vision winding differs. [VERIFIED: 41-CONTEXT.md]  
**Why it happens:** Winding is an acquisition detail, while anatomical side is a semantic invariant. [ASSUMED]  
**How to avoid:** Canonicalize by side, extrema/center relationships, and deterministic ordering; test reversed and rotated fixture orderings. [VERIFIED: 41-CONTEXT.md]

### Pitfall 4: Public compatibility drift

**What goes wrong:** Existing source initializers, presets, or legacy JSON gain nonzero defaults or a changed field count. [VERIFIED: PLANS.md; BeautyParametersTests.swift]  
**Why it happens:** A field is added to storage but omitted from a coding key, decoder default, `normalized()`, or inventory test. [VERIFIED: BeautyParameters.swift]  
**How to avoid:** Assert 48 reflected stored fields, decode a complete legacy 38-key payload, and round-trip unequal ten-field values. [VERIFIED: established 33-to-38 tests]

### Pitfall 5: Raw support leaks through diagnostics or state

**What goes wrong:** String descriptions, errors, metrics, snapshots, Demo imports, or persistence expose coordinates. [VERIFIED: SECURITY.md]  
**Why it happens:** A convenient `CustomStringConvertible`/Codable conformance or debug cache outlives the request. [ASSUMED]  
**How to avoid:** Keep support package-private and non-Codable, use fixed category codes/counts, and run active-source/public-surface scans. [VERIFIED: SECURITY.md; VisionFaceDetectorTests.swift]

### Pitfall 6: Phase boundary creep

**What goes wrong:** Provider transforms, caps, facade cases, gallery files, or ledger promotion are implemented before support evidence is stable. [VERIFIED: 41-CONTEXT.md; ROADMAP.md]  
**How to avoid:** Limit Phase 41 to EYE-01–EYE-07 and support/compatibility tests; record later concerns in the next phase plans. [VERIFIED: REQUIREMENTS.md]

## Code Examples

Verified repository patterns and official API references:

### Existing mapper orientation contract

```swift
let point = try mapper.map(
    point: CoordinatePoint(x: 0.25, y: 0.75),
    from: .visionNormalized,
    to: .imageNormalized
)
// .up -> (0.25, 0.25); input mirroring flips X only.
```

This is the behavior already asserted by `CoordinateMapperTests`; retain it for contour points. [VERIFIED: CoordinateMapper.swift; CoordinateMapperTests.swift]

### Existing defaulted decoding pattern

```swift
let value = try container.decodeIfPresent(Float.self, forKey: .eyeHeight) ?? 0
```

Missing keys must remain neutral, matching the existing decoder extension. [VERIFIED: BeautyParameters.swift]

### Vision source seam

```swift
let request = VNDetectFaceLandmarksRequest()
try handler.perform([request])
// map request.results' eye regions and optional pupil regions through CoordinateMapper
```

Use the existing single request and do not persist `VNFaceObservation` or landmark objects. [VERIFIED: VisionFaceDetector.swift; SECURITY.md] [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d]

## State of the Art

| Old approach | Current approach | When changed | Impact |
|---|---|---|---|
| Availability-only eye groups plus symmetric proxy points | Private observed contours and optional pupils with field-local eligibility | Phase 41 design, 2026-07-16 | Enables honest later gaze/symmetry evidence without changing public API. [VERIFIED: 41-CONTEXT.md; .planning/research/ARCHITECTURE.md] |
| Public fields added without observed evidence | Compatibility-safe scalar contract first, provider semantics later | Established v1.9/v1.10 phase ordering | Keeps source/JSON compatibility independent of geometry rollout. [VERIFIED: PLANS.md; ROADMAP.md] |

**Deprecated/outdated:**

- **Proxy-only gaze or symmetry:** Not sufficient for v1.11 correction claims; retain only for shipped zero-default compatibility. [VERIFIED: 41-CONTEXT.md]
- **Persisted landmark debugging:** Conflicts with the current local-first privacy posture. [VERIFIED: SECURITY.md]

## Assumptions Log

| # | Claim | Section | Risk if wrong |
|---|---|---|---|
| A1 | Vision contour winding may vary across acquisition fixtures and therefore should not define semantics. | Common Pitfalls | Canonicalization tests could overfit an ordering that is actually stable; keep threshold/ordering decisions fixture-backed. [ASSUMED] |
| A2 | A dedicated adapter-focused test file is preferable to placing all support tests in existing detector tests. | Recommended Project Structure | Planner may instead extend existing suites; no runtime impact. [ASSUMED] |

## Open Questions (RESOLVED)

### Resolved support-validation thresholds

- Each per-eye contour accepts **6...16 input points** and must retain at least **4 unique finite points**. Reject a contour before `BeautyEffects` when any mapped point is non-finite or outside closed `[0,1]`, when the input exceeds 16 points, or when the result is duplicate-only or otherwise degenerate. [VERIFIED: checker-resolved Phase 41 planning constraint]
- Relative to the owning face bounds, the contour bounding width must be in **`0.04...0.50`**, bounding height in **`0.01...0.30`**, and bounding area must be strictly greater than **`0.0004`**. Reject support outside these bounds. [VERIFIED: checker-resolved Phase 41 planning constraint]
- Each pupil region accepts exactly **one unique point per anatomical side**. The mapped point must lie inside the owning contour bounds expanded by **10%**, and its normalized center offset must satisfy `sqrt((dx / halfWidth)^2 + (dy / halfHeight)^2) <= 0.70`. [VERIFIED: checker-resolved Phase 41 planning constraint]
- Paired pupil plausibility additionally requires left/right owning-eye width ratios and height ratios each in **`0.50...2.00`**. A failed pupil rule invalidates only pupil-dependent support; valid contours and contour-dependent siblings remain available. [VERIFIED: checker-resolved Phase 41 planning constraint; 41-CONTEXT.md]
- These constants are **support-validation ceilings**, not final visual-effect caps. Every boundary and just-inside/just-outside case must be fixture-tested; Phase 44 still owns final visual caps. [VERIFIED: checker-resolved Phase 41 planning constraint; ROADMAP.md]

### Resolved fixture eligibility

- Synthetic observations injected through `VisionFaceDetector.ObservationProvider` are the normative Phase 41 evidence for coordinate conversion, winding independence, anatomical sides, contour rejection, pupil-local rejection, and sibling survival. [VERIFIED: VisionFaceDetector.swift; checker-resolved Phase 41 planning constraint]
- A real-portrait pupil inventory is optional exploratory evidence for Phase 43. Its absence or variation cannot block EYE-01 through EYE-07, because Phase 41 acceptance is determined by deterministic synthetic observations and the public compatibility suite. [VERIFIED: checker-resolved Phase 41 planning constraint; REQUIREMENTS.md]
- No Phase 41 research question remains open. The planner should encode these thresholds and normative fixtures directly in the first plan tasks. [VERIFIED: checker-resolved Phase 41 planning constraint]

## Environment Availability

| Dependency | Required by | Available | Version | Fallback |
|---|---|---|---|---|
| Swift compiler | Source and SwiftPM tests | ✓ | Apple Swift 6.3.3 | — |
| SwiftPM package manifest | Module graph and tests | ✓ | tools 6.0 | — |
| Xcode | XCTest / Apple SDK verification | ✓ | 26.6 (17F113) | `swift test` for package-only checks |
| Apple Vision SDK | Detector implementation/tests | ✓ | iOS 17 deployment baseline in manifest | None for actual Vision integration; use injected provider fixtures for unit tests |
| Python 3 | Not required for Phase 41 | ✓ | 3.9.6 | Not applicable |

No missing dependency blocks Phase 41 implementation. [VERIFIED: command probes; Package.swift]

## Validation Architecture

### Test Framework

| Property | Value |
|---|---|
| Framework | XCTest via SwiftPM/Xcode 26.6 [VERIFIED: Package.swift; `xcodebuild -version`] |
| Config file | None; targets and dependencies are declared in `BeautySDK/Package.swift`. [VERIFIED: Package.swift] |
| Quick run command | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` (or the focused detector/adapter test class) |
| Full suite command | `swift test --package-path BeautySDK` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test type | Automated command | File exists? |
|---|---|---|---|---|
| EYE-01 | Nine positive-only fields clamp/default/normalize independently. | Unit | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` | ✅ extend existing |
| EYE-02 | Signed tilt preserves both directions and finite fallback. | Unit | same focused command | ✅ extend existing |
| EYE-03 | 38-key legacy decode, 48-field round trip, reflected inventory. | Unit | same focused command | ✅ extend existing |
| EYE-04 | Zero-default new fields preserve existing four-eye values. | Unit/regression | `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` | ✅ existing; add neutral assertions |
| EYE-05 | Vision contour/pupil conversion, finite bounds, orientation, mirror, no raw diagnostics. | Unit | `swift test --package-path BeautySDK --filter BeautyDetectionTests` | ✅ extend existing |
| EYE-06 | Canonical ordering, side identity, malformed/duplicate/degenerate rejection. | Unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | ❌ required first task |
| EYE-07 | Pupil-only invalidation and complete eye-domain skip when either contour is absent. | Integration/unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests` | ✅ extend existing |

Boundary scans should also assert no public support type, Codable geometry, Demo imports, raw coordinates in diagnostics, network/cloud path, new dependency, or generated artifacts. [VERIFIED: SECURITY.md; existing v1.9/v1.10 boundary evidence]

### Sampling Rate

- **Per task commit:** Run the narrowest affected class command above. [VERIFIED: AGENTS.md]
- **Per wave merge:** Run `swift test --package-path BeautySDK`. [VERIFIED: AGENTS.md; PLANS.md]
- **Phase gate:** Full SwiftPM suite plus active-source/privacy/artifact scans before planning moves to Phase 42. [VERIFIED: 41-CONTEXT.md; QUALITY_SCORE.md]

### Wave 0 / First-Task Dependencies

- [ ] **Required first task:** create `BeautyFaceGeometryAdapterTests.swift` (or a deliberately named equivalent focused suite) before adapter implementation. It must encode the resolved contour and pupil thresholds as executable boundary cases. [VERIFIED: `rg --files BeautySDK/Tests`; checker-resolved Phase 41 planning constraint]
- [ ] **Required first task:** create deterministic injected Vision observations covering reversed winding, anatomical left/right identity, all representative orientations, mirrored metadata, 6/16 accepted contour points, 5/17 rejected point counts, fewer than 4 unique points, non-finite/out-of-unit points, duplicate-only/degenerate contours, every face-relative width/height/area boundary, missing/outside/offset pupil, paired-ratio failure, and contour-sibling survival. [VERIFIED: 41-CONTEXT.md; checker-resolved Phase 41 planning constraint]
- [ ] Add a public-boundary scan for new eye field names and forbidden geometry tokens, following prior phase gates. [VERIFIED: SECURITY.md; PLANS.md]

These are planned implementation prerequisites, not unresolved research. Real portrait pupil availability may be recorded separately for Phase 43 but is not part of the Phase 41 gate. [VERIFIED: checker-resolved Phase 41 planning constraint]

## Security Domain

### Applicable ASVS Categories

| ASVS category | Applies | Standard control |
|---|---|---|
| V2 Authentication | No | No account/authentication path is in scope. [VERIFIED: 41-CONTEXT.md; SECURITY.md] |
| V3 Session Management | No | No session or server state; request-scoped in-memory support only. [VERIFIED: SECURITY.md] |
| V4 Access Control | No | No multi-user or entitlement path. [VERIFIED: 41-CONTEXT.md] |
| V5 Input Validation | Yes | Finite, closed-unit, cardinality, duplicate, degeneracy, containment, and point-ceiling validation before effects. [VERIFIED: 41-CONTEXT.md; SECURITY.md] |
| V6 Cryptography | No | No secrets, network, persistence, or cryptographic operation is introduced. [VERIFIED: 41-CONTEXT.md] |

### Known Threat Patterns for Swift/Vision

| Pattern | STRIDE | Standard mitigation |
|---|---|---|
| Malformed/non-finite or oversized landmark arrays | Tampering / DoS | Validate before storage/effects; enforce small fixed point ceilings and bounded derived work. [VERIFIED: 41-CONTEXT.md] |
| Raw biometric-adjacent coordinates in descriptions/metrics | Information disclosure | Package-private non-Codable support, fixed reason codes, aggregate counts, active-source scans. [VERIFIED: SECURITY.md] |
| Side/orientation confusion | Tampering | Single mapper conversion and orientation/mirror fixtures. [VERIFIED: CoordinateMapper.swift; CoordinateMapperTests.swift] |
| Pupil spoof/blink outlier | Tampering | Independent pupil plausibility and paired validation; contour siblings survive. [VERIFIED: 41-CONTEXT.md; Apple pupil docs] |
| New dependency/model/network path | Supply-chain / exfiltration | Keep `Package.swift` unchanged; use existing Apple Vision request only. [VERIFIED: Package.swift; 41-CONTEXT.md] |

## Project Constraints (from AGENTS.md)

- Read `PLANS.md` before edits and leave traceable verification; do not create or duplicate active plans. [VERIFIED: AGENTS.md; PLANS.md]
- Route contract changes to owning docs: `DESIGN.md` for model/state, `SECURITY.md` for privacy/input boundaries, `RELIABILITY.md` for errors/metrics/performance, `PRODUCT_SENSE.md` for public acceptance, and `PLANS.md` for status. [VERIFIED: AGENTS.md]
- Preserve user changes and do not expand scope; record unrelated discoveries as technical debt. [VERIFIED: AGENTS.md]
- Prefer `rg`/`rg --files` for discovery, use focused SwiftPM/Xcode validation, and explicitly name any unavailable build prerequisite. [VERIFIED: AGENTS.md]
- Do not claim Demo/device/commercial/release readiness without corresponding evidence; Phase 41 is SDK-core only. [VERIFIED: AGENTS.md; 41-CONTEXT.md]
- Raw geometry must remain package-internal and privacy rules must be reflected in owning root contracts when the contract changes. [VERIFIED: AGENTS.md; SECURITY.md]

## Sources

### Primary (HIGH confidence)

- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — stored fields, coding keys, normalization, and missing-key defaults. [VERIFIED: codebase]
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` — single Vision request, detector payload, and observation mapping. [VERIFIED: codebase]
- `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift` and `CoordinateMapperTests.swift` — orientation, mirror, and normalized-coordinate behavior. [VERIFIED: codebase]
- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` and `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` — package-private observation and geometry seam. [VERIFIED: codebase]
- `AGENTS.md`, `PLANS.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `.planning/phases/41-public-contract-and-observed-eye-support/41-CONTEXT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md` — locked project constraints and phase boundary. [VERIFIED: codebase]

### Official Apple documentation (MEDIUM/HIGH citation confidence)

- [VNFaceLandmarks2D](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — eye and pupil landmark regions used by the existing Vision request. [CITED]
- [VNFaceLandmarkRegion2D](https://developer.apple.com/documentation/vision/vnfacelandmarkregion2d) — normalized landmark region representation. [CITED]
- [VNFaceLandmarks2D.leftPupil](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/leftpupil) — pupil-location limitation during blinking. [CITED]

### Secondary (MEDIUM confidence)

- `.planning/research/{STACK,FEATURES,ARCHITECTURE,PITFALLS,SUMMARY}.md` — milestone research already recorded from repository and official Apple sources. [VERIFIED: codebase]
- Archived v1.6/v1.9/v1.10 phase evidence — established compatibility, redaction, provider eligibility, and convergence patterns. [VERIFIED: PLANS.md and `.planning/milestones/`]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — package manifest and local tool versions are directly verified; Apple Vision references are official. [VERIFIED/CITED]
- Architecture: HIGH for ownership/privacy boundaries and the now-resolved support-validation thresholds; exact private type names remain discretionary. [VERIFIED: CONTEXT.md; checker-resolved Phase 41 planning constraint]
- Pitfalls: HIGH — existing mapper tests, security contract, prior phase evidence, and executable boundary values identify concrete failure modes. [VERIFIED: repository; checker-resolved Phase 41 planning constraint; CITED Apple pupil docs]

**Research date:** 2026-07-16  
**Valid until:** 2026-08-15 for this stable repository stack; re-check if Swift/Xcode deployment or Vision APIs change. [ASSUMED]
