# Phase 49: Public Contract and Observed Eyebrow Support - Research

**Researched:** 2026-07-24
**Domain:** Swift public-model compatibility, Apple Vision face landmarks, open-path geometry validation, and request-local privacy
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

## Implementation Decisions

### Public Contract and Compatibility
- Add seven independent controls for vertical position, thickness, length, overall spacing, inner-head spacing, tilt, and peak definition.
- Preserve the milestone's signed-versus-positive semantics: the first six controls are signed and peak definition is positive-only; every new field defaults to zero and normalizes finitely.
- Expand `BeautyParameters` to exactly 59 stored fields, 58 numeric plus `filterId`, without changing legacy 52-field decoding, source compatibility, reset/diff/equality behavior, or bundled preset bytes.
- Keep nonzero values inert in this phase: public storage and compatibility land before any provider, resolver, facade, renderer, or output activation.

### Observation Capture and Mapping
- Reuse the existing single selected-face Vision landmarks request and copy actual left/right eyebrow traces immediately into request-local value data.
- Preflight each side independently with fixed point ceilings before mapping; malformed or oversized optional eyebrow data fails locally without erasing the selected face or valid sibling regions.
- Map every accepted point exactly once through the existing request-local orientation and mirror metadata; do not retry, cache, persist, or remap framework landmark objects.
- Never substitute eye contours, the historical eye geometry proxy, generated traces, or synthetic points for missing eyebrow evidence.

### Canonicalization and Validation
- Canonicalize both side identity and inner-to-outer point order using mapper-derived face-local axes so behavior is invariant across orientation, input mirroring, preview mirroring, and reversed Vision trace order.
- Treat each eyebrow as an independently validated open path with bounded counts, finite closed-unit coordinates, nondegenerate span, exact-bit uniqueness, and side/order checks.
- Preserve adjacency by whole-array reversal only; do not sort points or infer a closed polygon.
- Keep paired eligibility distinct from per-side validity so a malformed side does not contaminate valid support or unrelated landmark domains.

### Privacy, Lifecycle, and Evidence
- Keep raw and derived eyebrow support package-only, request-scoped, non-Codable, non-persistent, non-networked, and unavailable to Demo imports or public API.
- Diagnostics may expose only fixed reasons and aggregate counts; coordinates, stable geometry signatures, and biometric/profile-like data must not escape.
- Prove alternating, repeated, interrupted, stale/no-face, and parallel request isolation with no shared mutable support state.
- Close only BROW-01, BROW-02, SUPP-01, SUPP-02, and SUPP-03; explicitly retain all provider/output/promotion and v1.14-v1.16 claims as future.

### the agent's Discretion
- Exact internal type names, validation constants, helper placement, and test decomposition may follow existing face/eye support conventions, provided the ROADMAP counts, privacy boundaries, and fail-closed behavior remain exact.

### Deferred Ideas (OUT OF SCOPE)

## Deferred Ideas

- Phase 50: seven distinct eyebrow providers, resolver/conflict accounting, unified warp/facade routing.
- Phase 51: decoded public-facade image evidence and exact renderer/gallery inventory.
- Phase 52: final caps, exhaustive transitions, exact promotion, branch closeout.
- v1.14-v1.16 and all Demo/UI, device, commercial, packaging, shipping, and release-readiness work.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|---|---|---|
| BROW-01 | An SDK integrator can request seven independent normalized eyebrow controls—vertical position, thickness, length, overall spacing, inner-head spacing, tilt, and peak definition—with zero-default product-neutral semantics. | Exact field names, normalization domains, initialization, and independence tests are specified below. [VERIFIED: `.planning/REQUIREMENTS.md`; `.planning/research/FEATURES.md`] |
| BROW-02 | Existing source calls, legacy 52-field JSON payloads, all bundled preset bytes, normalization, equality, reset, diff, and round-trip behavior remain compatible when the stored model expands to exactly 59 fields. | The current manual initializer/decoder/normalizer and compatibility-test inventory identify every count and fixture that must change or remain frozen. [VERIFIED: `BeautyParameters.swift`; `BeautyParametersTests.swift`; `BeautyResourceCatalogTests.swift`] |
| SUPP-01 | A geometry-enabled request copies actual left/right Apple Vision eyebrow traces from the existing single selected-face landmarks request and maps each accepted point exactly once through the request-local coordinate metadata. | Official Vision API availability and the repository's selected-face request/value-copy/mapping seams are documented below. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d] [VERIFIED: `VisionFaceDetector.swift`] |
| SUPP-02 | Eyebrow traces are independently bounded, validated as open paths, canonicalized for side and inner/outer order across orientation and mirroring, and rejected locally when malformed without substituting eye contours or synthetic proxies. | A prescriptive side/order algorithm, open-path boundary matrix, and local-failure architecture are provided below. [VERIFIED: `BeautyFaceGeometryAdapter.swift`; `FaceObservationMappingTests.swift`] |
| SUPP-03 | Raw and derived eyebrow support remains package-only, request-scoped, non-Codable, non-persistent, non-networked, and absent from public API and raw diagnostics; only fixed reasons and aggregate counts may escape. | Existing redacted observation and semantic-support conventions are mapped to static and runtime boundary checks. [VERIFIED: `BeautyFaceObservation.swift`; `WarpControlPoint.swift`; archived Phase 45 boundary checker] |
</phase_requirements>

## Summary

Phase 49 should extend two deliberately separate contracts. The public contract adds seven neutral stored `Float` properties to the existing manually maintained `BeautyParameters` value, taking the exact inventory from 52 to 59 stored properties and from 51 to 58 numeric properties. The first six use the existing signed clamp and `eyebrowPeakDefinition` uses the existing unit clamp. Existing defaulted call sites, custom decoding, synthesized equality, default-value reset behavior, legacy fixture reconstruction, and preset bytes can all remain compatible if every manual reconstruction site is updated and no eyebrow key is added to bundled presets. [VERIFIED: `BeautyParameters.swift`; `BeautyParametersTests.swift`; `.planning/REQUIREMENTS.md`]

The private contract should copy `VNFaceLandmarks2D.leftEyebrow` and `.rightEyebrow` from the already selected face, before the framework object leaves the request scope, then independently preflight and map each trace through the existing `CoordinateMapper`. Apple documents both properties as optional `VNFaceLandmarkRegion2D` values whose normalized coordinates are relative to the face bounding box; installed SDK headers expose point classification and establish that the framework owns the point buffer. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d/lefteyebrow] [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d/righteyebrow] [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarkregion2d] [VERIFIED: Xcode 26.5 `Vision/VNFaceLandmarks.h`]

Canonicalization belongs after exactly-once mapping because the mapper-derived face-right and face-down axes are the stable basis across EXIF orientation and both mirror modes. Each side remains an open, adjacency-preserving array: determine side from centroid projection, determine endpoint direction from the face-right axis, and reverse the entire array only when required. Validate each side separately; paired eligibility is derived only after both valid sides exist. No provider, resolver, facade, renderer, Demo, resource, model, dependency, or visible-output work belongs in this phase. [VERIFIED: `VisionFaceDetector.swift`; `BeautyFaceGeometryAdapter.swift`; `49-CONTEXT.md`]

**Primary recommendation:** Implement this as a Phase-45-style five-plan rollout: Wave 0 safeguards, exact 59-field public compatibility, actual request-local Vision capture/mapping, open-path semantic validation/lifecycle evidence, then owner-document and boundary closeout. [VERIFIED: `.planning/phases/45-public-contract-and-observed-face-support/`; `49-CONTEXT.md`]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|---|---|---|---|
| Seven public eyebrow values and compatibility | API / Backend (SDK public model) | — | `BeautyParameters` owns the source and serialized contract; Phase 49 does not activate rendering. [VERIFIED: `BeautyParameters.swift`; `49-CONTEXT.md`] |
| Vision eyebrow capture | API / Backend (BeautyDetection package target) | Apple Vision framework | The current selected-face Vision request owns framework-object access and immediate value copying. [VERIFIED: `VisionFaceDetector.swift`] |
| Orientation/mirror mapping | API / Backend (request-local detector mapper) | — | `CoordinateMapper` already composes orientation and mirror metadata for every accepted landmark. [VERIFIED: `VisionFaceDetector.swift`] |
| Open-path validation and semantic support | API / Backend (BeautyEffects adapter boundary) | — | Existing eye/face observed data is converted into package-only semantic support at the geometry adapter boundary. [VERIFIED: `BeautyFaceGeometryAdapter.swift`; `WarpControlPoint.swift`] |
| Diagnostics and lifecycle privacy | API / Backend (package-private carriers) | Test/static boundary gate | Existing observation and geometry carriers implement aggregate-only description/reflection; tests enforce request isolation. [VERIFIED: `BeautyFaceObservation.swift`; `WarpControlPoint.swift`] |
| Persistence, network, UI, resources, visible output | Out of scope | — | The phase explicitly prohibits these tiers and artifacts. [VERIFIED: `49-CONTEXT.md`] |

## Project Constraints (from AGENTS.md)

- Treat repository text as the record system; do not assume facts not present in the repository. [VERIFIED: `AGENTS.md`]
- Before changes, read `PLANS.md`, the routed owner documents, related code/tests, and historical documents only as background. [VERIFIED: `AGENTS.md`]
- Resolve conflicts in this order: code and tests, `PLANS.md`, specialized root documents, then historical `docs/`. [VERIFIED: `AGENTS.md`]
- Preserve the smallest task scope, do not overwrite unrelated local changes, and record additional discoveries in `PLANS.md`. [VERIFIED: `AGENTS.md`]
- Update the document that owns any changed contract: `DESIGN.md` for parameter/support design, `ARCHITECTURE.md` for package boundaries, `SECURITY.md` for privacy/validation, `RELIABILITY.md` for errors/lifecycle, `PRODUCT_SENSE.md` for acceptance criteria, and `PLANS.md` for phase tracking. [VERIFIED: `AGENTS.md`]
- Verification results must be real and reproducible; simulator builds require an explicitly available iOS Simulator destination. No Demo or simulator build is required for this SDK-only phase. [VERIFIED: `AGENTS.md`; `49-CONTEXT.md`]
- Every implementation change must leave the next agent a trace of what changed, why, and how it was verified. [VERIFIED: `AGENTS.md`]

## Standard Stack

### Core

| Library / Framework | Version | Purpose | Why Standard |
|---|---|---|---|
| Swift | Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`) | Public value model, package-only carriers, validation, tests | This is the repository's current language/toolchain; no language or manifest change is needed. [VERIFIED: local `swift --version`; `BeautySDK/Package.swift`] |
| Foundation | Installed Apple SDK | `Codable`, finite-number handling, collections | `BeautyParameters` already uses Foundation and manual decoding; keep the same compatibility seam. [VERIFIED: `BeautyParameters.swift`] |
| Vision | iPhoneOS SDK 26.5 | Actual selected-face left/right eyebrow regions | Vision is the existing detector dependency and officially exposes optional eyebrow regions. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d] [VERIFIED: `VisionFaceDetector.swift`] |
| CoreGraphics | Installed Apple SDK | `CGPoint`, normalized geometry, axis projections | Current observation, mapper, and effects support use `CGPoint`; no replacement abstraction is warranted. [VERIFIED: `BeautyFaceObservation.swift`; `VisionFaceDetector.swift`] |
| Swift Testing / XCTest through SwiftPM | Installed Swift toolchain | Focused unit and integration verification | The package already has executable focused tests and `swift test` scripts; use the existing infrastructure. [VERIFIED: `BeautySDK/Tests`; local focused test runs] |

### Supporting

| Library / Tool | Version | Purpose | When to Use |
|---|---|---|---|
| `Mirror` / `CustomReflectable` / `CustomStringConvertible` | Swift standard library | Aggregate-only diagnostic surfaces | Apply to every new raw or derived eyebrow carrier, including nested geometry values. [VERIFIED: `BeautyFaceObservation.swift`; `WarpControlPoint.swift`] |
| Python boundary checker | Python 3.9.6 | Static scope, privacy, source-token, and preset-hash gate | Adapt the archived Phase 45 checker before production changes; make checker self-tests fail closed. [VERIFIED: local `python3 --version`; `.planning/phases/45-public-contract-and-observed-face-support/`] |
| `rg` | Local executable | Source/boundary inventory | Use in planning and closeout to prove forbidden artifacts and stale count claims are absent. [VERIFIED: local environment] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|---|---|---|
| Actual `leftEyebrow` / `rightEyebrow` regions | Eye contours, old eye geometry proxy, generated traces | Forbidden: these create false evidence and violate SUPP-01/SUPP-02. [VERIFIED: `49-CONTEXT.md`] |
| Request-local value copies | Retained `VNFaceLandmarkRegion2D`, cache, or shared actor/global state | Forbidden: framework-owned storage and cross-request lifecycle would violate the locked privacy/lifecycle contract. [VERIFIED: Xcode 26.5 `VNFaceLandmarks.h`; `49-CONTEXT.md`] |
| Mapper-axis projection and whole-array reversal | Sorting points by screen `x` | Sorting destroys adjacency and screen axes change under orientation/mirroring. [VERIFIED: `49-CONTEXT.md`; `VisionFaceDetector.swift`] |
| Independent per-side validation | All-or-nothing paired validation | All-or-nothing behavior would erase valid sibling evidence and contradict the local-failure decision. [VERIFIED: `49-CONTEXT.md`] |

**Installation:** No external package installation or `Package.swift` dependency change is required. [VERIFIED: `49-CONTEXT.md`; `BeautySDK/Package.swift`]

## Package Legitimacy Audit

This phase installs no external packages, so the Package Legitimacy Gate and registry/slopcheck checks are not applicable. The boundary checker should fail if `BeautySDK/Package.swift` gains a dependency or target for Phase 49. [VERIFIED: `49-CONTEXT.md`]

### Bundled Preset Byte Baselines

| Resource | Required SHA-256 |
|---|---|
| `clear.json` | `58327c8ef8cc8323d4a6e4d98754d8c9bf797b348804ca2a308c4c39e00856f8` |
| `id-photo-natural.json` | `d6d2d3e5872ae0aa25823c4d76e07057ecdfa336818cd116509627995941c609` |
| `male-natural.json` | `1c6e632e8740602fa662c42e41cf9709eec29b3138bf58df43fad40d8b5d0c08` |
| `natural.json` | `bd102ec3643f1625d561af66fd0e7fb67c33fe5061720600907ed3fd931a08da` |
| `refined.json` | `67f238fddf8d9dc08bc8b24121af25d11f9caf8a85b905cf83a47b0dff675722` |

These current bytes must remain unchanged and contain none of the seven eyebrow keys; decoding absence to zero is the compatibility mechanism. [VERIFIED: local `shasum -a 256`; preset JSON inventory; `BeautyResourceCatalogTests.swift`]

## Architecture Patterns

### System Architecture Diagram

```text
Public request
  └─ BeautyParameters (59 stored / 58 numeric + filterId)
       └─ eyebrow values remain stored + normalized but inert

VNDetectFaceLandmarksRequest (existing single request)
  └─ selected VNFaceObservation
       ├─ leftEyebrow?  ─┐ immediate copy + independent preflight
       └─ rightEyebrow? ─┘
               ↓
       request-local normalized value traces
               ↓ exactly one CoordinateMapper.map call per accepted point
       mapped left/right candidates + mapped face axes
               ↓
       side identity projection
               ↓
       whole-array reversal when endpoint direction is outer→inner
               ↓
       independent open-path adapter validation
          ├─ valid left only  → retain left, paired=false
          ├─ valid right only → retain right, paired=false
          ├─ both valid       → retain both, paired=true
          └─ neither valid    → no eyebrow support
               ↓
       package-only FaceGeometry semantic support
               ↓
       aggregate diagnostics only

No provider/resolver/facade/renderer/Demo/network/persistence path in Phase 49.
```

The entry point, service boundary, processing sequence, local rejection branches, and prohibited downstream path follow the current detector-to-adapter flow. [VERIFIED: `VisionFaceDetector.swift`; `BeautyFaceGeometryAdapter.swift`; `49-CONTEXT.md`]

### Recommended Project Structure

```text
BeautySDK/
├── Sources/
│   ├── BeautyCore/Models/BeautyParameters.swift
│   ├── BeautyDetection/BeautyFaceObservation.swift
│   ├── BeautyDetection/VisionFaceDetector.swift
│   └── BeautyEffects/
│       ├── BeautyFaceGeometryAdapter.swift
│       └── WarpControlPoint.swift
└── Tests/
    ├── BeautyCoreTests/BeautyParametersTests.swift
    ├── BeautyDetectionTests/
    │   ├── VisionFaceDetectorTests.swift
    │   └── FaceObservationMappingTests.swift
    └── BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift

.planning/phases/49-public-contract-and-observed-eyebrow-support/
├── check_eyebrow_support_boundaries.py
├── 49-RESEARCH.md
└── plans and summaries
```

These are existing ownership seams; add focused code and tests there instead of introducing targets or modules. [VERIFIED: repository file inventory; `49-CONTEXT.md`]

### Pattern 1: Manual Additive Public-Model Evolution

**What:** Add seven defaulted stored properties, coding keys, initializer parameters/assignments, decode defaults, and normalization reconstruction arguments. Use `clampSigned` for the first six and `clampUnit` for peak definition. [VERIFIED: `BeautyParameters.swift`; `.planning/research/FEATURES.md`]

**When to use:** Every `BeautyParameters` construction/reconstruction path, including source calls compiled against the defaulted initializer and legacy JSON lacking the new keys. [VERIFIED: `BeautyParameters.swift`]

**Exact public names:** `eyebrowYPosition`, `eyebrowThickness`, `eyebrowLength`, `eyebrowSpacing`, `eyebrowHeadSpacing`, `eyebrowTilt`, and `eyebrowPeakDefinition`. [VERIFIED: `.planning/research/FEATURES.md`]

```swift
// Source pattern: BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
public var eyebrowYPosition: Float
// ... five additional signed fields ...
public var eyebrowPeakDefinition: Float

// In normalized():
eyebrowYPosition: Self.clampSigned(eyebrowYPosition),
// ...
eyebrowPeakDefinition: Self.clampUnit(eyebrowPeakDefinition)
```

### Pattern 2: Immediate Region Copy, Independent Local Failure

**What:** Read each optional Vision eyebrow region from the selected observation, reject zero/oversized/non-open-path data before mapping, copy its normalized points into a request-local Swift array, and map it independently. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarkregion/pointcount] [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarkregion2d/normalizedpoints] [VERIFIED: Xcode 26.5 `VNFaceLandmarks.h`]

**When to use:** Only inside the existing selected-face request result conversion. Do not make a second Vision request. [VERIFIED: `VisionFaceDetector.swift`; `49-CONTEXT.md`]

```swift
// Source properties: Apple VNFaceLandmarks2D official API.
// Recommended shape; names may follow repository conventions.
let left = copyEyebrowRegion(landmarks.leftEyebrow, side: .left)
let right = copyEyebrowRegion(landmarks.rightEyebrow, side: .right)

let mappedLeft = left.flatMap { try? mapEyebrowRegion($0, mapper: mapper) }
let mappedRight = right.flatMap { try? mapEyebrowRegion($0, mapper: mapper) }
```

### Pattern 3: Mapper-Axis Side and Order Canonicalization

**What:** Map face center, face-right, and face-down basis points with the same request mapper. For each accepted trace, classify side by the sign of the centroid's projection from mapped face center onto face-right. Determine endpoint order from `(last - first) · faceRight`: canonical left inner→outer points in the negative face-right direction, while canonical right inner→outer points in the positive direction. Reverse the whole array if needed. [VERIFIED: `VisionFaceDetector.swift`; `49-CONTEXT.md`]

**When to use:** After exactly-once mapping and before adapter validation; reject epsilon-degenerate side/order projections instead of guessing. [ASSUMED]

```swift
// Source basis pattern: VisionFaceDetector.mappedFaceAxes(...)
let sideProjection = dot(centroid - faceCenter, faceRight)
let endpointProjection = dot(points.last! - points.first!, faceRight)

guard abs(sideProjection) > epsilon, abs(endpointProjection) > epsilon else {
    return nil
}
guard (declaredSide == .left) == (sideProjection < 0) else {
    return nil
}
let pointsInnerToOuter = expectedInnerToOuter(endpointProjection, declaredSide)
    ? points
    : points.reversed()
```

### Pattern 4: Open-Path Semantic Adapter

**What:** Validate bounded count, finite closed-unit coordinates, exact-bit uniqueness, nondegenerate endpoint chord/span, side/order consistency, and absence of non-adjacent self-intersection. Derive only package-private semantic values needed by Phase 50: canonical trace, inner endpoint, outer endpoint, center, and an interior apex candidate/index. [VERIFIED: `49-CONTEXT.md`; existing topology helpers in `BeautyFaceGeometryAdapter.swift`] [ASSUMED]

**When to use:** At the observed-data-to-effects semantic boundary. Keep left/right optional and compute `pairedEligible` separately from each side's validity. [VERIFIED: `BeautyFaceGeometryAdapter.swift`; `49-CONTEXT.md`]

### Pattern 5: Aggregate-Only Diagnostic Surfaces

**What:** Every new raw and derived support carrier explicitly implements redacted `description`, `debugDescription`, and `customMirror`, returning only fixed labels, booleans, and counts. Test `String(describing:)`, `String(reflecting:)`, `Mirror`, and `dump`. [VERIFIED: `BeautyFaceObservation.swift`; `WarpControlPoint.swift`; Phase 45 review history]

**When to use:** On observation payloads, detector conversion values, semantic support, and parent `FaceGeometry` containers; privacy is transitive through every enclosing value. [VERIFIED: `BeautyFaceObservation.swift`; `WarpControlPoint.swift`]

### Anti-Patterns to Avoid

- **Reusing `BeautyObservedEyeSide` or closed-eye contours:** Brows require their own open-path semantics and actual Vision eyebrow provenance. [VERIFIED: `BeautyFaceObservation.swift`; `49-CONTEXT.md`]
- **Throwing the whole selected observation for one bad brow:** Optional left/right brow failures must be caught locally, as the existing face-region optional mapping pattern does. [VERIFIED: `VisionFaceDetector.swift`; `49-CONTEXT.md`]
- **Sorting by screen coordinates:** Sorting breaks trace adjacency and becomes mirror/orientation dependent; whole-array reversal is the only allowed reorder. [VERIFIED: `49-CONTEXT.md`]
- **Applying polygon area or closed-contour validation:** Vision classifies eyebrow regions as open paths in the locally observed fixture, and the locked contract defines them as open paths. [VERIFIED: local aggregate Vision probe; `49-CONTEXT.md`]
- **Persisting mapped or semantic support in an engine/session cache:** Support must be computed and consumed inside one request and must disappear on no-face, interruption, and later requests. [VERIFIED: `49-CONTEXT.md`]
- **Activating any nonzero eyebrow field:** Resolver/provider/rendering changes belong to Phase 50, not Phase 49. [VERIFIED: `ROADMAP.md`; `49-CONTEXT.md`]

## Prescriptive Validation Constants

Use a fixed preflight ceiling of 16 points per Vision eyebrow region and an adapter acceptance range of 4...16 exact-bit-unique points. Reject an endpoint-chord length outside 0.08...0.50 in normalized face width, a vertical span above 0.25 normalized face height, or any side/order projection whose absolute value is at most `1e-6`. Do not require a positive vertical span because a nearly straight brow remains a legitimate open path. These constants are planning defaults inferred from existing repository limits and one local Vision fixture; Apple does not document a stable eyebrow point-count or geometry range, so lock them only together with Wave 0 boundary tests and record later tuning as an explicit contract change. [ASSUMED]

Do not add a cross-side width ratio or symmetry threshold in Phase 49. Paired eligibility should mean “both sides independently passed and occupy distinct canonical sides,” not “the face is sufficiently symmetric.” This avoids rejecting genuine asymmetric expressions without evidence. [ASSUMED]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---|---|---|---|
| Face landmark detection | Another detector, model, request, or synthetic eyebrow generator | Existing `VNDetectFaceLandmarksRequest` and selected `VNFaceObservation` | The repository already has one selected-face request and Apple exposes actual eyebrow regions on it. [CITED: https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest] [VERIFIED: `VisionFaceDetector.swift`] |
| Orientation/mirror transforms | Brow-specific orientation tables or screen-axis heuristics | Existing request-local `CoordinateMapper` and mapped face axes | One mapper is already the canonical request metadata boundary. [VERIFIED: `VisionFaceDetector.swift`] |
| JSON compatibility framework | Reflection-driven dynamic schema or migration package | Existing manual `CodingKeys`, decoder defaults, and defaulted initializer | The current compatibility contract is explicit and fully testable without a dependency. [VERIFIED: `BeautyParameters.swift`] |
| Closed-polygon geometry | Area/winding/hull construction | Open polyline validation plus whole-array reversal | The locked support is an open trace whose adjacency must be preserved. [VERIFIED: `49-CONTEXT.md`] |
| Biometric logging/redaction middleware | Coordinate hashes, stable signatures, or generic object dumps | Fixed reason enum plus aggregate counts and explicit redacted diagnostic protocols | Stable geometry-derived diagnostics would violate the privacy boundary. [VERIFIED: `49-CONTEXT.md`; `SECURITY.md`] |
| Paired-brow provider behavior | Geometry transforms, conflict resolution, or fallback traces | Optional semantic support only | Provider behavior is Phase 50 and synthetic fallback is forbidden. [VERIFIED: `ROADMAP.md`; `49-CONTEXT.md`] |

**Key insight:** The difficult part is not generating eyebrow geometry; it is proving that the exact public schema and actual request-scoped evidence are honest, orientation-stable, locally fail-closed, and incapable of leaking or activating before Phase 50. [VERIFIED: `49-CONTEXT.md`; `.planning/REQUIREMENTS.md`]

## Common Pitfalls

### Pitfall 1: Updating the Current Count but Breaking a Historical Fixture

**What goes wrong:** Every hard-coded `52` is mechanically changed to `59`, accidentally destroying legacy 52-field decoding evidence. [VERIFIED: `BeautyParametersTests.swift`]

**Why it happens:** The test file contains both current inventory assertions and historical 31/33/38/48/52 fixture assertions. [VERIFIED: `BeautyParametersTests.swift`]

**How to avoid:** Classify each count before editing. Update only current complete-model expectations to 59/58; preserve historical counts and add an explicit legacy-52 payload that omits all seven eyebrow keys. [VERIFIED: `BeautyParametersTests.swift`; `.planning/REQUIREMENTS.md`]

**Warning signs:** A compatibility fixture changes its key set, or the new-field test can pass without decoding a payload that truly contains 52 legacy fields. [ASSUMED]

### Pitfall 2: Claiming Reset or Diff APIs That Do Not Exist

**What goes wrong:** The plan invents public SDK reset/diff APIs to satisfy BROW-02. [VERIFIED: repository-wide `rg` inventory]

**Why it happens:** The requirement uses behavioral terms, while the SDK model currently provides default construction and synthesized equality rather than named reset/diff methods. [VERIFIED: `BeautyParameters.swift`]

**How to avoid:** Prove reset as replacement with `.init()` and diff as equality/inequality of independent snapshots; do not change public API beyond the seven fields. [ASSUMED]

**Warning signs:** New methods named `reset`, `diff`, or equivalent appear in public SDK source during Phase 49. [ASSUMED]

### Pitfall 3: Mapping or Copying a Brow More Than Once

**What goes wrong:** The region is mapped in the detector and then remapped in the adapter, or a retry maps the same points again after local validation fails. [VERIFIED: locked exactly-once rule in `49-CONTEXT.md`]

**Why it happens:** Raw face-local coordinates and mapped image coordinates are represented by the same `CGPoint` type. [VERIFIED: `VisionFaceDetector.swift`]

**How to avoid:** Use distinct internal value types or explicit names for face-local copied traces and mapped traces; inject a counting mapper in tests and assert one call per accepted point. [ASSUMED]

**Warning signs:** `CoordinateMapper.map` appears in eyebrow code outside the detector conversion seam, or call count exceeds accepted point count plus the fixed axis probes. [ASSUMED]

### Pitfall 4: Global Failure from One Optional Region

**What goes wrong:** A malformed left eyebrow causes the entire face, right brow, eye, or face-contour support to disappear. [VERIFIED: `49-CONTEXT.md`]

**Why it happens:** Existing throwing helpers can propagate failure at the observation level. [VERIFIED: `VisionFaceDetector.swift`]

**How to avoid:** Use a region-local optional mapping result for each eyebrow, retaining the selected observation and every valid sibling domain. [VERIFIED: analogous `mapFaceRegion` pattern in `VisionFaceDetector.swift`]

**Warning signs:** A test with one oversized eyebrow observes no face or loses unrelated `observedEye`/`observedFace` support. [ASSUMED]

### Pitfall 5: Mirror-Correct Shape but Wrong Semantic Side

**What goes wrong:** A trace is visually in the expected location but labeled as the wrong anatomical side or ordered outer-to-inner under some orientation/mirror combination. [VERIFIED: `49-CONTEXT.md`]

**Why it happens:** Vision-side labels, image coordinates, and preview coordinates are easy to conflate, and screen `x` changes under mirroring. [VERIFIED: `VisionFaceDetector.swift`]

**How to avoid:** Derive both side and order from mapped face axes and cover `.up`, `.right`, `.down`, `.left` with input-mirror and preview-mirror combinations plus reversed input traces. [ASSUMED]

**Warning signs:** Canonical endpoint meaning changes when only preview mirroring changes, or tests assert raw `x` rather than axis projection. [ASSUMED]

### Pitfall 6: Treating an Eyebrow as a Closed Polygon

**What goes wrong:** Endpoint closure creates a fictitious edge, area, or winding rule that rejects valid traces or accepts crossings. [VERIFIED: `49-CONTEXT.md`]

**Why it happens:** Existing eye validation is for closed contours and is tempting to reuse. [VERIFIED: `BeautyFaceGeometryAdapter.swift`]

**How to avoid:** Validate an open polyline, test only non-adjacent segment intersections, preserve endpoints, and never connect last to first. [ASSUMED]

**Warning signs:** Brow code computes polygon area/winding or modulo-wraps the last segment to the first. [ASSUMED]

### Pitfall 7: Redaction at the Leaf but Leakage Through a Parent

**What goes wrong:** The brow support type is redacted, but synthesized reflection or `dump` on `VisionDetectionObservation` or `FaceGeometry` exposes coordinates. [VERIFIED: Phase 45 review history; current explicit parent redaction in `BeautyFaceObservation.swift` and `WarpControlPoint.swift`]

**Why it happens:** Swift reflection traverses stored children unless each enclosing diagnostic surface is controlled. [VERIFIED: Swift standard-library behavior exercised by repository tests]

**How to avoid:** Test every carrier and parent through description, reflection, mirror children, and dump; allow fixed labels, booleans, and counts only. [VERIFIED: repository redaction-test convention]

**Warning signs:** Decimal coordinate fragments, `CGPoint`, arrays, inner/outer points, or stable geometry hashes appear in captured diagnostics. [ASSUMED]

### Pitfall 8: Declaring the Full Suite Green Despite Missing Local Fixtures

**What goes wrong:** Phase closeout reports a green full suite when the current checkout cannot run two geometry facade tests because `example-images/input/portraits/e1.png` is absent. [VERIFIED: local `swift test --package-path BeautySDK` baseline run]

**Why it happens:** Current ignored local media differs from historical documentation and is not tracked by git. [VERIFIED: `git ls-files example-images/input`; `.gitignore`; local file inventory]

**How to avoid:** Add a Wave 0 fixture preflight. Restore/provision the required authorized fixture outside Phase 49 code changes, or explicitly record the reproducible baseline block; never weaken unrelated tests or fabricate success. [VERIFIED: `AGENTS.md`]

**Warning signs:** Full-suite output contains the two `BeautyEngineGeometryFacadeTests` fixture failures, or an opt-in Vision corpus claims six images when only `e6.jpg` is locally present. [VERIFIED: local environment]

## Code Examples

Verified source/API patterns that the implementation should follow:

### Legacy Decode Default and Domain Normalization

```swift
// Source pattern: BeautyParameters.swift
eyebrowYPosition = try container.decodeIfPresent(
    Float.self,
    forKey: .eyebrowYPosition
) ?? 0

// Signed controls:
eyebrowTilt: Self.clampSigned(eyebrowTilt),

// Positive-only control:
eyebrowPeakDefinition: Self.clampUnit(eyebrowPeakDefinition)
```

The existing clamp helpers return zero for non-finite inputs, signed values in `[-1, 1]`, and unit values in `[0, 1]`. [VERIFIED: `BeautyParameters.swift`]

### Actual Vision Property Capture

```swift
// Source: Apple VNFaceLandmarks2D API
let leftEyebrow: VNFaceLandmarkRegion2D? = landmarks.leftEyebrow
let rightEyebrow: VNFaceLandmarkRegion2D? = landmarks.rightEyebrow
```

Both properties are optional 2D landmark regions. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d/lefteyebrow] [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarks2d/righteyebrow]

### Open-Path Preflight Before Allocation/Mapping

```swift
// Recommended repository-specific boundary.
guard region.pointCount >= 1, region.pointCount <= 16 else { return nil }
guard region.pointsClassification == .openPath else { return nil }
let copied = Array(UnsafeBufferPointer(
    start: region.normalizedPoints,
    count: region.pointCount
))
```

Apple exposes `pointCount`, `normalizedPoints`, and point classification; the exact ceiling is a repository policy, not an Apple guarantee. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarkregion/pointcount] [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarkregion2d] [VERIFIED: Xcode 26.5 `VNTypes.h`] [ASSUMED]

### Local Failure and Independent Pairing

```swift
// Recommended shape, following existing optional face-region mapping.
let leftSupport = mappedLeft.flatMap(adapter.makeEyebrowSupport)
let rightSupport = mappedRight.flatMap(adapter.makeEyebrowSupport)
let pairedEligible = leftSupport != nil && rightSupport != nil
```

The locked contract requires independent side validity and separate paired eligibility. [VERIFIED: `49-CONTEXT.md`]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|---|---|---|---|
| Historical eye geometry proxy for future brow work | Actual Apple Vision `leftEyebrow` and `rightEyebrow` traces | Phase 49 decision, 2026-07-24 | Support provenance becomes honest; eye contours and synthetic traces are forbidden. [VERIFIED: `49-CONTEXT.md`; `.planning/research/FEATURES.md`] |
| 52 stored fields / 51 numeric fields | 59 stored fields / 58 numeric fields | Phase 49 | Seven public controls land neutral without renderer activation. [VERIFIED: `ROADMAP.md`; `.planning/REQUIREMENTS.md`] |
| Closed eye-contour semantics | Independently validated open eyebrow polylines | Phase 49 | Preserve endpoints and adjacency; do not use area/winding or close the path. [VERIFIED: `49-CONTEXT.md`] |
| Screen-axis side/order assumptions | Mapper-derived face-axis projections plus whole-array reversal | Existing face-axis pattern, extended in Phase 49 | Canonical meaning remains stable across orientation and mirroring. [VERIFIED: `VisionFaceDetector.swift`; `49-CONTEXT.md`] |
| Leaf-only privacy checks | Transitive aggregate-only description/reflection/dump checks | Reinforced after Phase 45 review | Parent containers cannot accidentally reveal raw coordinates. [VERIFIED: current redaction implementations and Phase 45 history] |

**Deprecated/outdated:**

- Treating eye contours as eyebrow evidence is explicitly obsolete for this milestone. [VERIFIED: `49-CONTEXT.md`]
- Historical root-document counts below 52 describe earlier milestones and must not be copied into the current Phase 49 model contract; current code/tests outrank historical prose. [VERIFIED: `AGENTS.md`; current `BeautyParameters.swift`]
- Any claim that six portrait fixtures are committed is not true for the present checkout: `git ls-files example-images/input` returns no tracked files. [VERIFIED: local git inventory]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|---|---|---|
| A1 | Vision preflight ceiling 16 and adapter acceptance range 4...16 are appropriate fixed bounds. | Prescriptive Validation Constants | A future OS/device may emit a legitimate trace outside the range; valid support would fail closed until constants are revised. |
| A2 | Endpoint chord 0.08...0.50 face width, vertical span ≤0.25 face height, and epsilon `1e-6` are suitable geometry limits. | Prescriptive Validation Constants | Limits may over-reject uncommon faces or under-reject malformed input; Wave 0 matrices and authorized device corpus must validate them. |
| A3 | Canonical left inner→outer direction has negative face-right projection and right has positive projection after mapped side classification. | Architecture Pattern 3 | A side-label convention mismatch would swap endpoint semantics; full orientation/mirror tests must prove it before Phase 50 consumes support. |
| A4 | Reset/diff compatibility should be tested as default replacement and snapshot equality/inequality rather than new public methods. | Common Pitfall 2 | If an undocumented consumer contract exists outside the repository, the test may not cover it; repository policy says such a fact cannot be assumed. |
| A5 | Semantic support should carry canonical trace, endpoints, center, and an interior apex candidate/index for downstream use. | Architecture Pattern 4 | Phase 50 may need a different derived representation; keep the type package-only so it can evolve without public compatibility cost. |
| A6 | No cross-side symmetry ratio should gate Phase 49 paired eligibility. | Prescriptive Validation Constants | Some malformed pairs may remain eligible; side/order and independent topology checks still fail closed, and later evidence can add a bounded rule. |
| A7 | One local `e6.jpg` probe (one selected face, six points per brow, open-path classification) is representative only enough to confirm API wiring, not to establish production limits. | Sources / Environment | It cannot justify population-wide thresholds; do not convert it into a release or device-coverage claim. |

## Open Questions

1. **Which authorized portrait fixture source will make the full SwiftPM gate reproducible?**
   - What we know: the current full-suite baseline has at least two `BeautyEngineGeometryFacadeTests` failures because `example-images/input/portraits/e1.png` is absent, and the portrait files are not tracked. [VERIFIED: local baseline run; local git inventory]
   - What's unclear: whether the fixture is provisioned by a private setup step, intentionally local-only, or accidentally absent. [ASSUMED]
   - Recommendation: add a Wave 0 preflight/checkpoint, preserve the unrelated tests, and require a reproducible fixture provision or an explicit baseline-block record before phase closeout. [VERIFIED: `AGENTS.md`]

2. **Do the proposed point-count and geometry constants cover the supported Apple Vision/device corpus?**
   - What we know: Apple documents the region API but not a stable eyebrow point count or facial-geometry range. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarkregion2d]
   - What's unclear: distribution across devices, OS revisions, poses, and faces. [ASSUMED]
   - Recommendation: use the prescriptive fail-closed defaults for planning, cover every boundary in synthetic unit tests, and require authorized aggregate-only host probes before any later release claim. [ASSUMED]

3. **Should the semantic support persist a precomputed apex candidate or derive it in Phase 50?**
   - What we know: Phase 49 may create private derived support, while peak-definition behavior is Phase 50. [VERIFIED: `49-CONTEXT.md`; `ROADMAP.md`]
   - What's unclear: the minimal representation Phase 50's distinct providers will prefer. [ASSUMED]
   - Recommendation: store an interior apex index only if it naturally falls out of Phase 49 validation; otherwise defer apex selection without changing the canonical trace/endpoints contract. [ASSUMED]

None of these questions changes the public 59-field contract or the requirement to capture actual Vision eyebrow regions; only the missing fixture can block an honest full-suite phase gate. [VERIFIED: `49-CONTEXT.md`; local baseline run]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|---|---|---|---|---|
| Swift toolchain | Build and tests | ✓ | 6.3.3 (`swiftlang-6.3.3.1.3`) | — [VERIFIED: local `swift --version`] |
| Xcode | Apple framework headers / host Vision tests | ✓ | 26.6 (17F113) | Focused injected tests for normative coverage [VERIFIED: local `xcodebuild -version`] |
| iPhoneOS / macOS SDK | Vision eyebrow API | ✓ | 26.5 | — [VERIFIED: local SDK inventory] |
| Apple Vision framework | SUPP-01 capture | ✓ | Installed SDK 26.5 | Injected observation fixtures for deterministic logic tests [VERIFIED: installed headers; package build] |
| Python | Static boundary checker | ✓ | 3.9.6 | Shell/`rg` checks, but Python is preferred [VERIFIED: local `python3 --version`] |
| `rg` | Source inventory and boundary checks | ✓ | Installed | `grep` only if unavailable [VERIFIED: local environment] |
| Authorized portrait corpus | Full suite / optional live Vision evidence | Partial | Local `e6.jpg`; required `e1.png` absent; none tracked under `example-images/input` | No clean-clone fallback presently known [VERIFIED: local file and git inventory] |

**Missing dependencies with no fallback:**

- A reproducible authorized `e1.png` fixture/provisioning step is missing for the two current full-suite geometry-facade tests. The planner must add a Wave 0 checkpoint rather than weaken the tests. [VERIFIED: local full-suite baseline; `AGENTS.md`]

**Missing dependencies with fallback:**

- A multi-image live Vision corpus is unavailable in the present checkout; deterministic injected mapping/adapter tests provide normative Phase 49 evidence, while a live probe remains aggregate-only and opt-in. [VERIFIED: local file inventory; existing test architecture]

## Validation Architecture

### Test Framework

| Property | Value |
|---|---|
| Framework | Existing SwiftPM XCTest suites under `BeautySDK/Tests` [VERIFIED: `BeautySDK/Package.swift`; test inventory] |
| Config file | `BeautySDK/Package.swift` [VERIFIED: repository inventory] |
| Public-model quick command | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` (baseline: 32 passed) [VERIFIED: local run, 2026-07-24] |
| Mapping quick command | `swift test --package-path BeautySDK --filter BeautyDetectionTests.FaceObservationMappingTests` (baseline: 15 passed) [VERIFIED: local run, 2026-07-24] |
| Adapter quick command | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` (baseline: 32 executed, 1 skipped, 0 failures) [VERIFIED: local run, 2026-07-24] |
| Full suite command | `swift test --package-path BeautySDK` (baseline not green because at least two required-image tests cannot find `e1.png`) [VERIFIED: local run, 2026-07-24] |
| Static boundary command | `python3 .planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py` after Wave 0 creates it [ASSUMED] |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|---|---|---|---|---|
| BROW-01 | Seven exact independent fields; six signed, one unit; zero defaults; finite normalization | unit | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` | ✅ extend existing |
| BROW-02 | Exact 59/58 inventory, defaulted source calls, legacy 52 decode, equality/reset/diff snapshots, round-trip, unchanged preset bytes | unit + resource + static | `swift test --package-path BeautySDK --filter BeautyCoreTests` plus `swift test --package-path BeautySDK --filter BeautyResourcesTests` and boundary checker | ✅ extend existing / ❌ Wave 0 checker |
| BROW-02 | Nonzero eyebrow values remain inert in resolver/geometry/rendering during Phase 49 | unit + static | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` and boundary checker | ✅ extend existing |
| SUPP-01 | Direct `leftEyebrow`/`rightEyebrow` capture, fixed preflight, one existing request, exactly-once mapper calls, independent sibling retention | unit + integration | `swift test --package-path BeautySDK --filter BeautyDetectionTests` | ✅ extend existing |
| SUPP-02 | Open-path count/topology/uniqueness/bounds/span; side/order invariance over orientation/mirrors/reversed traces; local rejection | unit | mapping and adapter quick commands | ✅ extend existing |
| SUPP-03 | Package-only/non-Codable/nonpersistent/nonnetwork/non-Demo boundary; redacted description/reflection/dump; alternating/repeated/interrupted/no-face/parallel isolation | unit + static | detection/effects focused tests plus boundary checker | ✅ extend existing / ❌ Wave 0 checker |

### Required Boundary Matrices

- Public model: each field independently nonzero and pairwise unequal; `-∞`, `+∞`, and `NaN`; `-2`, `-1`, `0`, `1`, `2`; exact current and legacy key inventories. [ASSUMED]
- Vision preflight: point counts `0`, `1`, `15`, `16`, `17`; disconnected, open-path, and closed-path classifications; left invalid/right valid and the inverse. Mapping count must remain zero for rejected/oversized inputs. [ASSUMED]
- Adapter count: `3`, `4`, `5`, `15`, `16`, `17`; duplicate exact bits; non-finite; out-of-unit; zero chord; too-short/too-long chord; excessive vertical span; non-adjacent crossing; wrong side; reversed order. [ASSUMED]
- Canonicalization: `.up`, `.right`, `.down`, `.left` × input mirror on/off × preview mirror on/off × original/reversed input, asserting stable anatomical side and canonical inner/outer endpoints. [ASSUMED]
- Lifecycle: alternating valid/invalid sides, repeated requests, interruption/cancellation, stale/no-face following valid face, and parallel requests with distinct aggregate counts. [VERIFIED: `49-CONTEXT.md`]
- Privacy: every leaf and enclosing carrier through description, reflection, mirror, and dump; assert no coordinate decimal, `CGPoint`, raw array, stable hash/signature, or biometric-like profile value. [VERIFIED: `49-CONTEXT.md`; existing redaction-test pattern]

### Sampling Rate

- **Per task commit:** Run the narrow owning suite and the Phase 49 boundary checker. [ASSUMED]
- **Per wave merge:** Run the public-model, resources, resolver, mapping, and adapter focused suites, boundary checker self-tests, and `git diff --check`. [ASSUMED]
- **Phase gate:** Run full SwiftPM only after fixture preflight, all focused suites, the boundary checker, preset SHA-256/key-absence checks, owner-document audit, and scope diff. Do not report full-suite success while the fixture block remains. [VERIFIED: `AGENTS.md`; local baseline]

### Wave 0 Gaps

- [ ] `.planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py` — adapt Phase 45 fail-closed checker; cover public/SPI visibility, source provenance tokens, forbidden eye substitution, Codable/persistence/network/Demo/manifest/resource/provider/resolver/renderer scope, redaction, lifecycle markers, exact preset hashes, and adversarial checker self-tests. [VERIFIED: archived Phase 45 pattern] [ASSUMED]
- [ ] Brow-specific fixture builders and boundary matrices in `BeautyFaceGeometryAdapterTests.swift` before production validation constants are written. [ASSUMED]
- [ ] Counting-mapper and full orientation/mirror/reversal fixtures in `FaceObservationMappingTests.swift`. [ASSUMED]
- [ ] Direct actual-property capture and sibling-local-failure fixtures in `VisionFaceDetectorTests.swift`. [ASSUMED]
- [ ] Environment preflight for `example-images/input/portraits/e1.png`; restore authorized fixture/provisioning or document baseline block. [VERIFIED: local full-suite baseline]

### Recommended Plan Decomposition

1. **49-01 — Safeguards and private support skeleton:** boundary checker with self-tests, private carrier/redaction contract, and test fixtures/matrices. [ASSUMED]
2. **49-02 — Exact 59-field public contract:** model, legacy/source/normalization/equality/reset-diff snapshot/round-trip/preset/inertness evidence. [ASSUMED]
3. **49-03 — Actual Vision capture and canonical mapping:** direct property copy, independent ceiling, exactly-once mapping, face-axis side/order reversal, and request isolation. [ASSUMED]
4. **49-04 — Open-path semantic validation:** bounded topology, semantic support, independent/paired eligibility, redaction, lifecycle/concurrency tests. [ASSUMED]
5. **49-05 — Owner and boundary closeout:** update `DESIGN.md`, `ARCHITECTURE.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and `PLANS.md`; run exact scope and validation gates. [VERIFIED: `AGENTS.md`] [ASSUMED]

Wave 1 is 49-01; 49-02 and 49-03 may run in parallel after safeguards because they own disjoint source areas; 49-04 depends on mapped support; 49-05 closes the phase. [ASSUMED]

## Security Domain

Security enforcement is enabled at ASVS L1 in `.planning/config.json`. The repository's planning convention uses ASVS v4-style category labels, while the current official OWASP ASVS release is 5.0.0; keep the repository labels for plan compatibility and apply only categories relevant to an on-device SDK. [VERIFIED: `.planning/config.json`; existing planning artifacts] [CITED: https://github.com/OWASP/ASVS]

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---|---|---|
| V2 Authentication | no | No identity/authentication surface is added. [VERIFIED: `49-CONTEXT.md`] |
| V3 Session Management | no | No web session exists; request-local lifecycle isolation is tested under SUPP-03. [VERIFIED: `49-CONTEXT.md`] |
| V4 Access Control | no external authorization; yes package boundary | Swift `package`/internal visibility plus static Demo/public-import checks. [VERIFIED: existing observation types; `49-CONTEXT.md`] |
| V5 Input Validation | yes | Fixed preflight ceilings before allocation/mapping, finite closed-unit coordinates, exact-bit uniqueness, span/topology/side/order checks, and local fail-closed behavior. [VERIFIED: `49-CONTEXT.md`] |
| V6 Cryptography | no | No encryption, hashing of geometry, credential, or cryptographic protocol is introduced. Preset SHA-256 is a test-integrity check, not data protection. [VERIFIED: `49-CONTEXT.md`; existing resource tests] |

### Known Threat Patterns for Swift/Vision Landmark Support

| Pattern | STRIDE | Standard Mitigation |
|---|---|---|
| Oversized or malformed point buffer causes excessive work | Denial of Service | Check `pointCount` and classification per side before copying/mapping; fixed ceiling 16. [CITED: https://developer.apple.com/documentation/vision/vnfacelandmarkregion/pointcount] [ASSUMED] |
| Side/order confusion produces wrong anatomical action | Tampering | Mapper-axis centroid and endpoint projections; reject degeneracy/wrong side; whole-array reversal only. [ASSUMED] |
| Eye or synthetic proxy masquerades as actual brow evidence | Spoofing | Static source-token gate requires `leftEyebrow`/`rightEyebrow` and rejects eye-contour substitution in brow capture. [VERIFIED: `49-CONTEXT.md`] |
| Coordinates leak through descriptions/reflection/dump | Information Disclosure | Explicit aggregate-only diagnostic protocols on every carrier and parent; negative-content tests. [VERIFIED: current repository redaction convention] |
| Old support contaminates a later request | Tampering / Information Disclosure | Pure request-local value flow, no shared mutable cache, and stale/no-face/interrupted/parallel isolation tests. [VERIFIED: `49-CONTEXT.md`] |
| Scope creep introduces dependency/network/persistence/model/resource | Tampering / Supply chain | Fail-closed boundary checker over manifest, imports, file paths, and forbidden symbols; checker adversarial self-tests. [VERIFIED: `49-CONTEXT.md`; archived boundary-checker pattern] |
| Boundary checker errors are treated as success | Repudiation | Nonzero exit on missing files, parse failures, absent required markers, or adversarial fixture failure. [ASSUMED] |

## Sources

### Primary (HIGH confidence)

- [Apple VNFaceLandmarks2D](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — face-relative normalized landmark coordinate model and available facial regions. [CITED]
- [Apple leftEyebrow](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/lefteyebrow) and [rightEyebrow](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/righteyebrow) — actual optional eyebrow-region properties. [CITED]
- [Apple VNFaceLandmarkRegion2D](https://developer.apple.com/documentation/vision/vnfacelandmarkregion2d) — normalized points, point classification, precision, and image-coordinate APIs. [CITED]
- [Apple pointCount](https://developer.apple.com/documentation/vision/vnfacelandmarkregion/pointcount) — count preflight surface. [CITED]
- Installed Xcode 26.5 `Vision/VNFaceLandmarks.h` and `Vision/VNTypes.h` — framework-owned point buffer and disconnected/open/closed classification constants. [VERIFIED: local SDK headers]
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — current 52-field manual public model, decoder, initializer, normalizer, and clamp behavior. [VERIFIED: code inspection]
- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` and `VisionFaceDetector.swift` — request-local observation, selected-face request, mapper, face axes, optional region behavior, and aggregate diagnostics. [VERIFIED: code inspection]
- `BeautySDK/Sources/BeautyEffects/BeautyFaceGeometryAdapter.swift` and `WarpControlPoint.swift` — semantic adapter, topology helpers, private support, parent geometry, and redaction conventions. [VERIFIED: code inspection]
- `BeautySDK/Tests` focused suites — current compatibility, mapping, adapter, resource, privacy, and lifecycle test patterns. [VERIFIED: code inspection and local focused runs]

### Secondary (MEDIUM confidence)

- `.planning/research/FEATURES.md`, `ARCHITECTURE.md`, `PITFALLS.md`, `STACK.md`, and `SUMMARY.md` — milestone discovery, exact public names, future provider boundary, and inherited risks; cross-checked against current code and Phase 49 context. [VERIFIED: repository research artifacts]
- `.planning/phases/45-public-contract-and-observed-face-support/` — analogous safeguards/capture/mapping/validation/closeout pattern; used as a structure, not as authority over current code. [VERIFIED: repository phase archive]
- One local host Vision probe against ignored `e6.jpg` — one selected face, six points on each eyebrow, both classified open path; aggregate-only and not a clean-clone or population claim. [VERIFIED: local probe, 2026-07-24]
- [OWASP ASVS](https://github.com/OWASP/ASVS) — current official standard project/release context. [CITED]

### Tertiary (LOW confidence)

- No WebSearch-only claims are used. Context7 was unavailable both as an MCP tool and local `ctx7` CLI, so Apple official documentation and installed headers were used directly. [VERIFIED: tool/environment check]
- All LOW-confidence design thresholds and representation choices are explicitly listed in the Assumptions Log. [VERIFIED: this research]

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH — no new dependency; current Swift/Apple frameworks and official Vision properties were verified against code, docs, and installed headers. [VERIFIED]
- Public compatibility: HIGH — the model is manually explicit and existing focused tests pass; required additive edits and count traps are directly enumerable. [VERIFIED]
- Capture/mapping architecture: HIGH — actual API properties and the request-local mapper/selected-face seam are verified. [VERIFIED]
- Validation constants: LOW — Apple provides no stable eyebrow count/geometry range; proposed values require Wave 0 tests and authorized aggregate host evidence. [ASSUMED]
- Privacy/lifecycle: HIGH — decisions are locked and existing redacted/request-local patterns are testable, though the new carriers still need implementation evidence. [VERIFIED]
- Full-suite environment: MEDIUM — the failure is reproducible locally, but fixture provisioning intent is not documented in the repository. [VERIFIED] [ASSUMED]

**Research date:** 2026-07-24
**Valid until:** 2026-08-23, or earlier if the Swift/Xcode/Vision SDK, Phase 49 context, or public eyebrow field contract changes. [ASSUMED]

## What Might Have Been Missed

- No external consumer source outside this repository was inspected; repository policy forbids assuming such contracts exist. [VERIFIED: `AGENTS.md`]
- The local Vision probe cannot establish point-count or facial-geometry distributions across supported devices and people. [VERIFIED: local probe scope]
- The missing portrait fixture prevents an honest current full-suite green baseline; plans must retain this as an explicit gate. [VERIFIED: local baseline]
- Phase 50 may refine the minimal private semantic representation, but it must not change the Phase 49 public field names, actual-source provenance, canonical trace order, or privacy contract without reopening these requirements. [VERIFIED: `ROADMAP.md`; `49-CONTEXT.md`]
