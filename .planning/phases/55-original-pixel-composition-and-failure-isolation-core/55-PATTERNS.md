# Phase 55: Original-Pixel Composition and Failure-Isolation Core - Pattern Map

**Mapped:** 2026-08-03
**Files analyzed:** 15 likely new/modified source, test, checker, and contract files
**Analogs found:** 15 / 15 (the composition algorithm has no exact live production analog; Spike 012 is its behavioral blueprint)

## Scope Guard

Phase 54 closed all three candidate gates. This map therefore assigns patterns only to a feature-neutral package core and opaque mechanics wiring. It does **not** assign a candidate field, `CodingKey`, preset key, named feature provider, transform, renderer case, public/SPI mask surface, Demo route, realtime route, or production admission. `BeautyEffectResolver.localRetouchAdmission(parameters:)` must remain exact-empty.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift` (likely new; exact name discretionary) | service/model | transform / batch / file-I/O | `BeautyCanonicalStillImage.swift`; Spike 012 integration recipe | role/data-flow composite |
| `BeautySDK/Sources/BeautySDK/BeautyStillImageRequestContext.swift` | model/owner | request-response | current same file | exact |
| `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | controller/facade | request-response | current admitted still-image branch | exact |
| `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` | test provider/hook | event-driven | existing local-retouch hooks and `SDKTestingFaceDetectionProvider` | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyLocalRetouchAdmission.swift` | config/admission | transform | current exact-empty opaque admission | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | service | transform | current `localRetouchAdmission` | exact |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` (only if the handoff is extended) | service | transform | canonical-image overload in same file | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift` (likely new) | test | transform / batch | `GeometryConflictResolverTests.swift`; `BeautyCanonicalStillImageTests.swift`; Spike 012 byte oracles | strong role-match |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift` | integration test | request-response | current same file | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | compatibility test | transform | Phase 53 exact no-admission assertions in same file | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` and `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` | compatibility tests | serialization / file-I/O | exact inventories in same files | exact |
| `.planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py` (likely new) | utility/test | file-I/O / batch | Phase 53 boundary checker | exact role |
| `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` | config/contracts | documentation | existing Phase 53/54 contract sections | exact role |

## Pattern Assignments

### `BeautyLocalRetouchComposition.swift` (feature-neutral package core)

**Primary analogs:** immutable source ownership in `BeautyCanonicalStillImage.swift`; validation/checked arithmetic in `BeautyCanonicalStillImage.swift` and `BeautyStillImageCanonicalizer.swift`; ownership behavior in `.codex/skills/spike-findings-beauty/references/still-image-integration.md`.

**Imports and access-control pattern** (`BeautyCanonicalStillImage.swift` lines 1-17):

```swift
import CoreGraphics
import CoreImage
import Foundation
import ImageIO

package struct BeautyCanonicalStillImage: @unchecked Sendable {
    package let width: Int
    package let height: Int
    package let rowBytes: Int
    package let metadata: BeautyInputMetadata

    private let storage: Storage
```

Place the core in `BeautyEffects`, which already depends on `BeautyCore`, `BeautyDetection`, `BeautyRender`, and `BeautyResources` (`Package.swift` lines 28-31). Use `package` values, immutable inputs, non-`Codable` state, and no public/SPI bytes, coordinates, masks, anatomy labels, or owner identities. Do not add a target or package dependency.

**Canonical source-binding pattern** (`BeautyCanonicalStillImage.swift` lines 34-49, 64-85):

```swift
let (expectedRowBytes, rowOverflow) = width.multipliedReportingOverflow(by: 4)
guard rowOverflow == false,
      rowBytes == expectedRowBytes
else { throw BeautyError.invalidInput }

let (expectedByteCount, totalOverflow) = rowBytes.multipliedReportingOverflow(by: height)
guard totalOverflow == false,
      rgba8Data.count == expectedByteCount
else { throw BeautyError.invalidInput }

self.storage = Storage(rgba8Data: rgba8Data, image: image)

package var rgba8Data: Data { storage.rgba8Data }
package var backingIdentity: Int { ObjectIdentifier(storage).hashValue }
```

Bind every unit to the current carrier's checked dimensions and immutable backing. The live carrier is the sole source of original bytes. A proposal must never accept an unverified second raster or read a sibling's output. Prefer checked multiplication/addition (`multipliedReportingOverflow`, `addingReportingOverflow`) before buffer sizing or `pixelIndex * 4`; reject the smallest unit on proposal-structure failure. A malformed canonical carrier is already a request-level typed error and must not be reconstructed here.

**Composition blueprint** (`still-image-integration.md` lines 71-95):

```swift
// Blueprint semantics, not candidate-specific production code:
// 1. clamp final soft weight
// 2. re-intersect with hard envelope after feather/growth
// 3. detect zero/one/multiple effective claims
// 4. multiple claims => copy source pixel
// 5. one claim => blend once from source pixel
// 6. preserve canonical alpha
```

The concrete Spike excerpt at lines 80-92 demonstrates the required collision-to-source rule, but do **not** copy its `teeth`/`sclera` names into production. Model opaque independently rejectable units. Reject duplicate pixel claims inside one unit as a structural unit failure. Across otherwise valid units, suppress only colliding pixels; retain all noncolliding pixels from every sibling. Zero weight means unowned. Copy every outside-union pixel exactly.

Define the RGBA8 blend with integer arithmetic and one documented rounding rule so ordering and device floating-point behavior cannot affect bytes. Preserve source alpha (currently guaranteed 255 by `BeautyCanonicalStillImage.swift` lines 48-49). Build output from a copy of canonical bytes, never a partially composed input.

**Aggregate-only result pattern** (`GeometryConflictResolverTests.swift` lines 91-127):

```swift
XCTAssertEqual(Set(resolved.metrics.keys), [
    "beauty.effects.weakenedCount",
    "beauty.effects.geometryStrengthScale"
])
let metadata = (
    resolved.warnings.map { "\($0.code) \($0.message)" } +
    Array(resolved.metrics.keys)
).joined(separator: " ")
```

The composition summary should expose only allowlisted aggregate counts such as accepted/rejected units and owned/changed/outside-union/collision pixels. No description, mirror, metric, error, or hook may reveal pixels, indices/coordinates, masks, labels, tokens, paths, or raw errors.

### `BeautyStillImageRequestContext.swift`

**Analog:** current stack-local request owner (`BeautyStillImageRequestContext.swift` lines 4-29).

```swift
package struct BeautyStillImageRequestContext: @unchecked Sendable {
    package let canonicalImage: BeautyCanonicalStillImage
    package let selectedFaceObservation: BeautyFaceObservation?

    package var redactedSummary: RedactedSummary {
        RedactedSummary(
            selectedFaceCount: selectedFaceObservation == nil ? 0 : 1,
            outerLipPointCount: selectedFaceObservation?.observedLipSupport?.outer?.count ?? 0,
            innerLipPointCount: selectedFaceObservation?.observedLipSupport?.inner?.count ?? 0
        )
    }
}
```

Keep composition ownership stack-local to one admitted request. If a request-local composer/owner is attached here, it must be a value initialized from this exact `canonicalImage`, not stored on `BeautyEngine`, not reused across calls, and not added to `RedactedSummary` except as aggregate counts. Do not persist proposals or summary state.

### `BeautyEngine.swift` and `BeautyEngineTestingSupport.swift`

**Facade analog:** existing admitted branch (`BeautyEngine.swift` lines 95-169).

```swift
let productionAdmission = BeautyEffectResolver.localRetouchAdmission(parameters: validated)
let admission = localRetouchTestingHooks.map {
    BeautyLocalRetouchAdmission(opaqueDemandCount: $0.admittedPrivateDemandCount)
} ?? productionAdmission

guard admission.isEmpty == false else {
    return legacyStillImageResult(image: image, metadata: metadata, parameters: validated)
}

let requestContext = BeautyStillImageRequestContext(
    canonicalImage: canonical,
    selectedFaceObservation: route.selectedFaceObservation
)
```

Extend only the opaque admitted testing path enough to prove the core consumes `requestContext.canonicalImage`. Preserve the existing trace ownership: canonicalize once, detect/map once, create one request context, then render/compose once. Keep production parameters on `legacyStillImageResult` structurally and byte-for-byte. A local unit failure becomes an abstention and cannot suppress unrelated color/filter work.

**Realtime/reset isolation analog** (`BeautyEngine.swift` lines 56-73, 196-203):

```swift
let validated = try BeautySDKResources.validate(parameters: parameters)
let plan = BeautyEffectResolver.resolve(parameters: validated)
return BeautyResult(
    output: try BeautyColorEffectPipeline.apply(to: pixelBuffer, plan: plan),
    warnings: plan.warnings,
    metrics: plan.metrics,
    detectionSummary: initialDetectionSummary
)

public func reset() {
    resetGeneration &+= 1
    faceDetector.resetTracking()
}
```

Do not mention or instantiate composition in the pixel-buffer path. `reset()` must not retain or clear composition pixels because none may survive the request.

**Testing-hook analog** (`BeautyEngineTestingSupport.swift` lines 62-95):

```swift
@_spi(Testing) public enum SDKTestingFaceDetectionFixture: Sendable { /* opaque cases */ }

@_spi(Testing) public final class SDKTestingFaceDetectionProvider: @unchecked Sendable {
    private let lock = NSLock()
    private var invocationCountValue = 0

    public var invocationCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return invocationCountValue
    }
}
```

Follow the existing locked counter and opaque-fixture pattern. Testing SPI may report invocation order, carrier identity equality, and aggregate summaries; it must not return proposals, indices, masks, source/output bytes, labels, or stable owner tokens. Mechanics byte assertions should remain in package tests using `@testable import`, not be exported through SPI.

### `BeautyLocalRetouchAdmission.swift` and `BeautyEffectResolver.swift`

**Exact-empty compatibility pattern** (`BeautyLocalRetouchAdmission.swift` lines 1-17; `BeautyEffectResolver.swift` lines 67-74):

```swift
package struct BeautyLocalRetouchAdmission: Equatable, Sendable {
    package static let none = BeautyLocalRetouchAdmission(opaqueDemandCount: 0)
    private let opaqueDemandCount: Int
    package var isEmpty: Bool { opaqueDemandCount == 0 }
}

package static func localRetouchAdmission(parameters: BeautyParameters) -> BeautyLocalRetouchAdmission {
    _ = parameters
    return .none
}
```

Copy this behavior exactly. Do not add a candidate enum, named demand, inert route, parameter inspection, or resolver inventory. Any Phase 55 activation remains opaque and testing-only.

### `BeautyColorEffectPipeline.swift` (only if integration needs a handoff)

Use the existing canonical overload, which already receives the same carrier and explicit sRGB ownership. The facade currently passes `requestContext.canonicalImage` at `BeautyEngine.swift` lines 152-163. Keep the legacy `CIImage` and pixel-buffer overloads unchanged. If composition produces a canonical-byte-backed handoff, do not re-canonicalize, re-run Vision, reinterpret through device RGB, or feed composed output into another local unit.

### `BeautyLocalRetouchCompositionTests.swift`

**Test placement:** `BeautyEffectsTests`, because it already imports `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyResources`, and `BeautyEffects` (`Package.swift` lines 43-46). Use `@testable import BeautyEffects` as in `GeometryConflictResolverTests.swift` lines 1-3.

**Tiny carrier/error pattern:** `BeautyCanonicalStillImageTests.swift` uses small in-memory asymmetric RGBA fixtures and allowlisted payload-free errors (lines 99-160). Build independent source and expected byte arrays; never snapshot output from the system under test as the oracle.

Wave 0 should freeze COMP-01 through COMP-05 with at least these tables:

- standalone unit, explicitly merged standalone outputs, fused disjoint output, and reversed unit order all byte-identical;
- hard envelope false + nonzero soft weight is re-clipped to zero;
- zero weight is unowned and unchanged;
- duplicate index within one unit rejects only that unit;
- cross-unit collision increments one collision-pixel count, preserves that source pixel, and composes each noncolliding sibling pixel;
- all outside-union pixels and every alpha byte exactly equal canonical source;
- invalid dimensions/counts/index/weight/non-finite value/source binding/checked arithmetic reject only the offending unit;
- injected opaque units representing one whole region or individual subregions prove smallest-unit abstention without naming production candidates;
- valid-invalid-valid requests retain no earlier bytes, ownership, proposals, or summaries;
- aggregate descriptions/mirrors/metrics contain only an exact allowlist and fail sensitive-term scans.

For every expected transformed byte, author the integer blend independently in the test or use literal expected bytes. Do not call production helpers to calculate expectations.

### `BeautyEngineLocalRetouchFoundationTests.swift`

Extend the existing suite rather than create a parallel facade harness. Existing anchors are:

- exact event order: lines 55-61;
- same carrier at detector/renderer: lines 75-88;
- unrelated color survival under no-face/missing support: lines 101-142;
- valid-invalid-valid nonreuse: lines 205-227;
- pixel-buffer/reset zero local work: lines 236-249;
- exact-empty production admission: lines 250-253.

Add opaque composition events/aggregate assertions only if necessary, while retaining the old trace as a compatibility oracle or updating it to one explicitly pinned Phase 55 trace. Prove both public CIImage entries can reach the injected path, the composition core sees the same backing identity, default production calls never construct/invoke it, and an injected local failure still preserves unrelated shipped color/filter output.

### Compatibility Regression Tests

`BeautyRendererOutputRegressionTests.swift` lines 691-703 already pins unchanged no-admission bytes, warnings, metrics, and detection summary; lines 972-975 pin the exact 72 renderer cases and candidate absence. Keep those assertions exact.

Retain the Phase 53 exact inventories:

- 59 stored/CodingKey fields (58 numeric plus `filterId`);
- five bundled presets;
- 72 renderer cases;
- no candidate field/provider/renderer/preset/admission route;
- unchanged source-call defaults and missing-key neutrality.

No Phase 55 test should weaken exact equality to approximate/contains checks for these inventories.

### `check_phase55_composition_boundaries.py`

**Analog:** `check_still_image_foundation_boundaries.py` lines 14-48, 73-116, 119-166, 169-243, and 246-274.

```python
@dataclass(frozen=True)
class Rule:
    name: str
    pattern: str
    should_exist: bool

def classify_rg(returncode: int, stdout: str, stderr: str) -> str:
    if returncode == 0:
        return "match"
    if returncode == 1 and not stdout and not stderr:
        return "clean"
    raise RuntimeError(...)
```

Copy its repository-root discovery, exact target/preset/field inventory checks, fail-closed `rg` classification, required-path checks, live mode, and mutation-driven `--self-test`. Phase 55 rules should additionally pin:

- composition source is package-only/non-`Codable` and located in `BeautyEffects`;
- no public/SPI mask/proposal/owner/byte surface;
- no persistence, network, model/weight, new dependency/target, Demo route, candidate symbol, or named candidate provider/renderer;
- exact-empty resolver admission remains literal and production-reachable;
- pixel-buffer/reset sections contain no composition activation;
- checked arithmetic and hard-reclip/collision-to-source anchors exist;
- the core is actually referenced by the opaque admitted still-image route, preventing an orphan;
- tests contain independent byte oracles for duplicate, collision, outside-union, order, failure-isolation, and valid-invalid-valid cases.

Do not let a missing source/test path classify as clean. Self-test mutations must prove each important absence/inventory rule fails closed.

### Root Contract Documents

Update the authoritative owner, not historical `docs/` text:

- `ARCHITECTURE.md`: `BeautyEffects` owns the feature-neutral composer; facade owns request wiring; no upward dependency or realtime route.
- `DESIGN.md`: immutable-original, opaque-unit, hard-envelope/final-weight, duplicate rejection, pixel-local collision-to-source, integer RGBA8 blend, alpha/outside-union identity.
- `SECURITY.md`: request-local sensitive state and aggregate-only diagnostics; no serialization/logging/SPI surface.
- `RELIABILITY.md`: smallest-unit abstention, request-level canonical failure, valid-invalid-valid recovery, checked allocation/arithmetic, unrelated-effect continuation.
- `PRODUCT_SENSE.md`: mechanics-only acceptance and explicit no-visible-output/no-feature-effectiveness claim.
- `QUALITY_SCORE.md`: focused Swift suites plus source-boundary checker and mutation self-test.
- `PLANS.md`: record Phase 55 execution/verification and preserve the closed Phase 54 decisions.

Use the current root-contract style: concise invariants and exact acceptance statements, not duplicated implementation narration.

## Shared Patterns

### Dependency and Access Control

- Preserve `BeautySDK -> BeautyEffects -> BeautyDetection/BeautyRender/BeautyResources -> BeautyCore`; no reverse import.
- The source raster remains `BeautyCanonicalStillImage` from `BeautyCore`; the composer belongs in `BeautyEffects`; only the facade may connect it to `BeautyStillImageRequestContext`.
- Production types are `package`, immutable, non-`Codable`, and request-local. SPI is limited to opaque scenarios and aggregate counters.

### Failure Isolation

- Canonical-carrier invalidity is a request-level payload-free typed error.
- Proposal/unit invalidity is an abstention for that unit only.
- Duplicate claims invalidate only their originating unit.
- Cross-unit collisions suppress only those pixels and copy canonical source.
- Missing/invalid work must not erase valid siblings or unrelated shipped color/filter behavior.
- No state survives a request; valid-invalid-valid is mandatory.

### Arithmetic and Determinism

- Check dimensions, row bytes, total bytes, proposal counts, byte offsets, and allocations before use.
- Clamp finite weights; reject non-finite values; re-clip final weights to hard containment.
- Blend once from original RGBA8 with integer-defined rounding; preserve alpha; never depend on input order or unordered reduction.

### Privacy and Diagnostics

- Allow only aggregate accepted/rejected-unit and pixel counts (plus bounded timing only where already authorized).
- Forbid masks, coordinates/indices, bytes, anatomy labels, stable owner identities, landmarks/pupils/veins, paths, raw errors, persistence, and logs.

### Exact No-Admission Compatibility

- `BeautyLocalRetouchAdmission.none` and resolver return remain exact-empty.
- No candidate field, CodingKey, preset key, provider, renderer case, transform, or inert route.
- Existing CIImage no-admission bytes/warnings/metrics/summary, pixel-buffer behavior, reset behavior, 59 fields, five presets, and 72 renderer cases stay exact.

## No Exact Production Analog

| File/Concern | Reason | Planner Guidance |
|---|---|---|
| Feature-neutral original-pixel composer | Production currently has no local pixel-ownership core | Use `BeautyCanonicalStillImage` for ownership/validation and Spike 012 only for semantics; keep production names opaque |
| Integer RGBA8 blend contract | Existing color pipeline uses floating-point transforms, not the required order-independent byte contract | Specify and independently test one integer rounding rule; do not copy current float `toByte` behavior implicitly |
| Hard-envelope plus final soft-weight proposal | No current package type represents this boundary | Introduce the minimum package-only opaque representation; do not encode anatomy or candidate identity |

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, Phase 53/54 artifacts, root contracts, and `spike-findings-beauty` still-image integration reference  
**Strong analogs used:** 5 primary (`BeautyCanonicalStillImage`, `BeautyEngine` admitted branch, testing support, foundation tests, Phase 53 checker) plus Spike 012 behavioral blueprint  
**Pattern extraction date:** 2026-08-03
