# Phase 18: Skin Retouch Core Modules - Pattern Map

**Mapped:** 2026-06-27
**Files analyzed:** 13 new/modified files or file groups
**Analogs found:** 13 / 13

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` | service | transform | `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | service | transform | `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` | config | transform | `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` | model | transform | `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` | exact |
| `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | public facade | request-response | `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | role-match |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | test | request-response | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | exact |
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | utility | file-I/O | `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | exact |
| `docs/meitu-function-blueprint/features/skin-retouch/**` | docs | transform | `docs/meitu-function-blueprint/features/skin-retouch/README.md` | exact |
| `docs/meitu-function-blueprint/FEATURE_MATRIX.md`, `MODULES.md`, `EXAMPLE_IMAGE_VALIDATION.md` | docs | batch | Phase 17 blueprint docs and Phase 16 renderer docs | exact |
| `PLANS.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md` | ledger | event-driven | `PLANS.md` Phase 16/17/18 entries | exact |

## Pattern Assignments

### `BeautyColorEffectPipeline.swift` (service, transform)

**Analog:** `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`

**Imports pattern** (lines 1-4):
```swift
import CoreGraphics
import CoreImage
import CoreVideo
import BeautyCore
```

**Pixel-buffer output pattern** (lines 11-35, 61-92): preserve input dimensions and pixel format, allocate a new output buffer, lock/unlock both buffers with `defer`, then transform each BGRA pixel. Formula changes for Basic skin must stay inside `transform(...)` unless both pixel-buffer and CIImage paths are intentionally updated.

**CIImage output pattern** (lines 99-142):
```swift
guard plan.hasVisibleColorOutput else {
    return image.cropped(to: image.extent)
}

let strengths = plan.effectiveStrengths
let brightness = CGFloat(
    strengths.brightness * 0.14 +
    strengths.exposure * 0.10 +
    strengths.skinWhitening * 0.16 +
    filter.brightness
)
...
return output.cropped(to: image.extent)
```

**Basic skin formula surface** (lines 173-200):
```swift
let lightLift = strengths.brightness * 0.16 +
    strengths.exposure * 0.10 +
    strengths.skinWhitening * 0.18 +
    filter.brightness
...
let smoothing = strengths.skinSmoothing * 0.08
if smoothing > 0 {
    r = r * (1 - smoothing) + luminance * smoothing
    g = g * (1 - smoothing) + luminance * smoothing
    b = b * (1 - smoothing) + luminance * smoothing
}
```

**Planner instruction:** copy the dual-path shape. Any Phase 18 formula change should update CIImage lines 104-141 and pixel transform lines 155-207 consistently, keep `cropped(to: image.extent)`, and avoid new passes, masks, repair, inpainting, segmentation, or production `SkinPass` work.

---

### `BeautyEffectResolver.swift` (service, transform)

**Analog:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`

**Layered no-face pattern** (lines 3-10):
```swift
public enum BeautyEffectResolver {
    public static func resolve(parameters: BeautyParameters) -> BeautyEffectPlan {
        resolve(parameters: parameters, faceGeometry: nil, treatsMissingFaceAsNoFace: false)
    }

    static func resolve(parameters: BeautyParameters, faceGeometry: FaceGeometry?) -> BeautyEffectPlan {
        resolve(parameters: parameters, faceGeometry: faceGeometry, treatsMissingFaceAsNoFace: true)
    }
```

**Skin cap and activation pattern** (lines 17-29, 107-114):
```swift
let normalized = parameters.normalized()
...
strengths.skinSmoothing = capUnit(normalized.skinSmoothing, cap: BeautySafetyCaps.skinSmoothing, cappedCount: &cappedCount)
strengths.skinWhitening = capUnit(normalized.skinWhitening, cap: BeautySafetyCaps.skinWhitening, cappedCount: &cappedCount)
strengths.skinRosy = capUnit(normalized.skinRosy, cap: BeautySafetyCaps.skinRosy, cappedCount: &cappedCount)
strengths.skinSharpen = capUnit(normalized.skinSharpen, cap: BeautySafetyCaps.skinSharpen, cappedCount: &cappedCount)
...
if anyNonZero(strengths.skinSmoothing, strengths.skinWhitening, strengths.skinRosy, strengths.skinSharpen) {
    if noUsableFace {
        skippedDomains.insert(.skin)
        appendNoFaceWarningIfNeeded()
    } else {
        activeDomains.insert(.skin)
    }
}
```

**Metadata and warning pattern** (lines 269-297, 339-343):
```swift
metrics["beauty.effects.activeCount"] = Double(activeDomains.count)
metrics["beauty.effects.cappedCount"] = Double(cappedCount)
...
BeautyValidationWarning(
    code: "face_effects_skipped_no_face",
    message: "Face-dependent geometry was skipped because no usable face was available."
)
```

**Planner instruction:** preserve the distinction between public facade no-detection skin and explicit internal no-face skin skip. If Phase 18 adds any future weakening metadata, use redacted `BeautyValidationWarning` and `metrics` keys only; do not expose geometry, landmarks, paths, raw detector details, or image data.

---

### `BeautySafetyCaps.swift` (config, transform)

**Analog:** `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift`

**Cap constants pattern** (lines 1-5):
```swift
enum BeautySafetyCaps {
    static let skinSmoothing: Float = 0.60
    static let skinWhitening: Float = 0.50
    static let skinRosy: Float = 0.40
    static let skinSharpen: Float = 0.40
```

**Planner instruction:** keep public range and effective caps separate. Public `BeautyParameters` may normalize to `1`, while resolver output stays capped for natural output. If constants change, update resolver tests and cap tests in the same plan.

---

### `BeautyEffectPlan.swift` (model, transform)

**Analog:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift`

**Plan surface pattern** (lines 3-22):
```swift
public struct BeautyEffectPlan: Equatable, Sendable {
    public let activeDomains: Set<BeautyEffectDomain>
    public let skippedDomains: Set<BeautyEffectDomain>
    public let warnings: [BeautyValidationWarning]
    public let metrics: [String: Double]
    public let effectiveStrengths: BeautyEffectiveStrengths
```

**Effective strengths pattern** (lines 25-30):
```swift
public struct BeautyEffectiveStrengths: Equatable, Sendable {
    public var skinSmoothing: Float = 0
    public var skinWhitening: Float = 0
    public var skinRosy: Float = 0
    public var skinSharpen: Float = 0
```

**Planner instruction:** Phase 18 should usually not need to add fields. New repair, teeth, hairline, mask, texture, or region fields are out of scope unless root contracts are updated first, which Phase 18 decisions forbid.

---

### `BeautyEngine.swift` (public facade, request-response)

**Analog:** `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`

**Imports pattern** (lines 1-7):
```swift
import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import ImageIO
import BeautyCore
import BeautyEffects
```

**Facade process-result pattern** (lines 36-50, 72-88):
```swift
try Self.validate(pixelBuffer: pixelBuffer)
let validated = try BeautySDKResources.validate(parameters: parameters)
let plan = BeautyEffectResolver.resolve(parameters: validated)
return BeautyResult(
    output: try BeautyColorEffectPipeline.apply(to: pixelBuffer, plan: plan),
    warnings: plan.warnings,
    metrics: plan.metrics,
    detectionSummary: initialDetectionSummary
)
```

```swift
let validated = try BeautySDKResources.validate(parameters: parameters)
let plan = BeautyEffectResolver.resolve(parameters: validated)
return BeautyResult(
    output: BeautyColorEffectPipeline.apply(to: image, plan: plan),
    warnings: plan.warnings,
    metrics: plan.metrics,
    detectionSummary: initialDetectionSummary
)
```

**Planner instruction:** public-path tests and renderer cases should validate through `BeautyEngine.processResult(...)`, not by reaching into internal targets. No-detection facade output should continue to apply Basic skin full-frame because the facade calls `resolve(parameters:)`.

---

### `SkinBasicEffectTests.swift` (test, transform)

**Analog:** `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift`

**Imports pattern** (lines 1-5):
```swift
import CoreImage
import XCTest
import BeautyCore
import BeautyResources
@testable import BeautyEffects
```

For the new focused file, use only the imports needed for formula tests, likely `CoreImage`, `XCTest`, `BeautyCore`, and `@testable import BeautyEffects`.

**CI fixture and bytes pattern** (lines 86-106, 131-143):
```swift
let image = CIImage(color: CIColor(red: 0.25, green: 0.30, blue: 0.35, alpha: 1))
    .cropped(to: CGRect(x: 0, y: 0, width: 2, height: 1))
let inputBytes = rgbaBytes(from: image)
...
let output = BeautyColorEffectPipeline.apply(to: image, plan: plan, face: .fixture)
XCTAssertNotEqual(rgbaBytes(from: output), inputBytes, presetID)
```

```swift
private func rgbaBytes(from image: CIImage) -> [UInt8] {
    let context = CIContext(options: [.workingColorSpace: CGColorSpaceCreateDeviceRGB()])
    var output = [UInt8](repeating: 0, count: 2 * 1 * 4)
    context.render(
        image,
        toBitmap: &output,
        rowBytes: 2 * 4,
        bounds: CGRect(x: 0, y: 0, width: 2, height: 1),
        format: .RGBA8,
        colorSpace: CGColorSpaceCreateDeviceRGB()
    )
    return output
}
```

**Planner instruction:** create focused tests for no-op preservation, smoothing direction, whitening luminance lift, rosy red bias, sharpen/contrast direction, combo visible change, and cap-respecting medium strengths. Prefer explicit channel/delta assertions over only `XCTAssertNotEqual`.

---

### `BeautyEffectResolverTests.swift` (test, transform)

**Analog:** `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift`

**Imports pattern** (lines 1-3):
```swift
import XCTest
import BeautyCore
@testable import BeautyEffects
```

**Public range vs cap pattern** (lines 15-34):
```swift
let parameters = BeautyParameters(
    skinSmoothing: 1,
    skinWhitening: 1,
    skinRosy: 1,
    skinSharpen: 1
)

XCTAssertEqual(parameters.normalized().skinSmoothing, 1)

let plan = BeautyEffectResolver.resolve(parameters: parameters)

XCTAssertTrue(plan.activeDomains.contains(.skin))
XCTAssertEqual(plan.effectiveStrengths.skinSmoothing, 0.60, accuracy: 0.0001)
XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 4)
```

**Redaction pattern** (lines 51-60):
```swift
let combined = (
    plan.warnings.map { "\($0.code) \($0.message)" } +
    Array(plan.metrics.keys)
).joined(separator: " ")

for forbidden in ["/private/var", "NSError", "VNFaceObservation", "bounding", "landmark", "rawPresetJson"] {
    XCTAssertFalse(combined.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
}
```

**Planner instruction:** add/adjust tests to assert public `resolve(parameters:)` keeps `.skin` active without geometry, and keep explicit `resolve(parameters:faceGeometry:nil)` skip behavior covered in `CombinedEffectSafetyTests`.

---

### `BeautySafetyCapsTests.swift` (test, transform)

**Analog:** `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift`

**Caps assertion pattern** (lines 5-11):
```swift
final class BeautySafetyCapsTests: XCTestCase {
    func testPhase6SafetyCapsMatchCanonicalConstants() {
        XCTAssertEqual(BeautySafetyCaps.skinSmoothing, 0.60, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.skinWhitening, 0.50, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.skinRosy, 0.40, accuracy: 0.0001)
        XCTAssertEqual(BeautySafetyCaps.skinSharpen, 0.40, accuracy: 0.0001)
```

**Planner instruction:** if Phase 18 leaves caps unchanged, reuse this file as evidence only. If cap constants change, rename or add a Phase 18-specific assertion and update resolver expectations.

---

### `BeautyEngineTests.swift` (test, request-response)

**Analog:** `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`

**Public facade imports pattern** (lines 1-5):
```swift
import CoreImage
import CoreVideo
import ImageIO
import XCTest
import BeautySDK
```

**Visible skin output pattern** (lines 35-58, 60-81):
```swift
let result = try engine.processResult(
    pixelBuffer: input,
    metadata: BeautyInputMetadata(orientation: .up, source: .camera),
    parameters: parameters
)

XCTAssertFalse(input === result.output)
XCTAssertNotEqual(try PixelBufferFixtures.bytes(from: result.output), try PixelBufferFixtures.bytes(from: input))
XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 3)
```

```swift
let result = try engine.processResult(
    image: image,
    metadata: BeautyInputMetadata(orientation: .up, source: .photo),
    parameters: parameters
)

XCTAssertEqual(result.output.extent, image.extent)
XCTAssertNotEqual(try PixelBufferFixtures.rgbaBytes(from: result.output), try PixelBufferFixtures.rgbaBytes(from: image))
```

**Fixture helper pattern** (lines 159-222): use `PixelBufferFixtures.makeBGRA(...)`, `bytes(from:)`, and `rgbaBytes(from:)` for public-facade assertions without importing internals.

**Planner instruction:** use this file only for public facade no-detection and metadata evidence. Keep it importing `BeautySDK` only.

---

### `BeautyExampleRenderer/main.swift` (utility, file-I/O)

**Analog:** `BeautySDK/Sources/BeautyExampleRenderer/main.swift`

**Facade-only imports pattern** (lines 1-5):
```swift
import AppKit
import CoreImage
import Foundation
import ImageIO
import BeautySDK
```

**Renderer case pattern** (lines 44-95):
```swift
RenderCase(
    id: "skinSmoothing_0p50",
    displayName: "skinSmoothing 0.50",
    parameters: BeautyParameters(skinSmoothing: 0.50)
),
...
RenderCase(
    id: "skinCombo_0p50",
    displayName: "skin combo 0.50",
    parameters: BeautyParameters(
        skinSmoothing: 0.50,
        skinWhitening: 0.50,
        skinRosy: 0.35,
        skinSharpen: 0.25
    )
)
```

**Run/output pattern** (lines 97-149):
```swift
let inputURL = URL(fileURLWithPath: inputDirectory, isDirectory: true)
let outputURL = URL(fileURLWithPath: outputDirectory, isDirectory: true)
...
let result = try engine.processResult(
    image: inputImage,
    metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
    parameters: renderCase.parameters
)
...
let outputName = "\(baseName)__\(renderCase.id).png"
try png.write(to: destination, options: .atomic)
```

**Watermark pattern** (lines 166-221): watermark text is the display name, drawn at bottom over a translucent band.

**Planner instruction:** Phase 18 should normally not edit this file because all required skin cases already exist. Do not add `skinRepair`, `teeth`, `hairline`, `blemish`, `pore`, segmentation, AI, resource, or Demo/UI cases.

---

### Blueprint Docs (docs, transform/batch)

**Analogs:** `docs/meitu-function-blueprint/features/skin-retouch/README.md`, branch READMEs, `FEATURE_MATRIX.md`, `MODULES.md`

**Family branch table pattern** (`features/skin-retouch/README.md` lines 13-19):
```markdown
| Basic skin | implemented | `BeautyEffects` | `skinSmoothing`, `skinWhitening`, `skinRosy`, `skinSharpen` | None for current basic skin branch. | XCTest coverage plus `BeautyExampleRenderer` saved-image cases. |
| Skin repair | future | `BeautyEffects` | None | Blemish, pore, texture, and local repair controls need design updates if promoted. | No v1.3 completion evidence until promoted. |
| Teeth/hairline | future | `BeautyEffects` | None | Teeth whitening and hairline controls need landmark/segmentation/resource design if promoted. | No v1.3 completion evidence until promoted. |
```

**Basic branch pattern** (`skin-basic/README.md` lines 9-17): current SDK supports MVP output, may be face-aware or full-frame depending on detection availability, uses four public skin parameters, and expects XCTest plus renderer evidence.

**Future branch boundary pattern** (`skin-repair/README.md` lines 9-17; `teeth-hairline/README.md` lines 9-16): future branches require region/mask, local repair, segmentation, landmarks, optional resources, and explicit promotion before evidence counts.

**Matrix status pattern** (`FEATURE_MATRIX.md` lines 3-10, 25-27): use only `implemented`, `partial`, `blocked-by-geometry-output`, and `future`; provider/resolver tests do not count as visible completion without public facade saved-image output.

**Module ownership pattern** (`MODULES.md` lines 39-41, 56-60): Basic skin belongs to `BeautyEffects` with `BeautyRender` color/skin path and public `BeautySDK` facade; renderer imports only `BeautySDK` and must not reach internal targets or Demo SwiftUI state.

**Planner instruction:** tighten docs only if implementation changes the real contract. Keep Basic skin `implemented`; keep Skin repair and Teeth/hairline `future`; do not add commercial-grade or release-like claims.

---

### `EXAMPLE_IMAGE_VALIDATION.md` (docs, file-I/O)

**Analog:** `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`

**Command/output pattern** (lines 15-30, 32-41):
```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input \
  --output example-images/out \
  --case skinWhitening_0p50
```

Output rules: use `example-images/out/`, keep outputs ignored, include source image and case id in names, draw a bottom watermark, and keep same pixel dimensions.

**Current skin cases pattern** (lines 43-58): required Phase 18 cases are `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, and `skinCombo_0p50`.

**Planner instruction:** executor evidence should build the renderer, run all five current skin cases, check representative dimensions with `file`, and record only factual visual observations.

---

### Planning Ledgers (ledger, event-driven)

**Analogs:** `PLANS.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`

**Update rules pattern** (`PLANS.md` lines 6-14): update existing Active plan, record every completed verifiable step, record blockers with attempted actions, move completed work into Completed with evidence, and write "未验证" with reason when verification was not run.

**Active Phase 18 pattern** (`PLANS.md` lines 29-50): keep the existing active plan and advance checklist evidence rather than creating a duplicate Active entry.

**Phase 18 context closeout pattern** (`PLANS.md` lines 60-77): completed entries list scope, requirements, files, verification commands/evidence, build status, and outcome bullets.

**Requirements pattern** (`.planning/REQUIREMENTS.md` lines 32-34, 86-88): `SKIN-01`, `SKIN-02`, and `SKIN-03` remain pending until Phase 18 execution evidence passes.

**Roadmap pattern** (`.planning/ROADMAP.md` lines 67-83): planned slots are `18-01` audit, `18-02` implementation, and `18-03` verification.

**Planner instruction:** plan closeout should mark SKIN requirements complete only after focused XCTest, all five renderer cases, dimension checks, factual visual review, facade/import scans, negative future-branch scans, and `git diff --check` pass or are honestly recorded as not run.

## Shared Patterns

### Public Range vs Effective Caps

**Source:** `BeautyParameters` + `BeautyEffectResolver.swift` lines 17-29 + `BeautySafetyCaps.swift` lines 1-5
**Apply to:** resolver tests, formula tests, engine tests, docs

Public parameter values stay normalized; algorithm output is capped in resolver. Do not duplicate clamp logic in render code.

### Facade No-Detection vs Internal No-Face

**Source:** `BeautyEffectResolver.swift` lines 3-10 and 107-114; `CombinedEffectSafetyTests.swift` lines 8-41
**Apply to:** resolver tests, engine tests, docs

Public `resolve(parameters:)` keeps Basic skin active without geometry; internal `resolve(parameters:faceGeometry:nil)` treats missing face as no usable face and skips skin with redacted metadata.

### Redacted Metadata

**Source:** `BeautyEffectResolverTests.swift` lines 51-60; `CombinedEffectSafetyTests.swift` lines 109-128
**Apply to:** resolver, engine, future weakening metadata

Warnings and metrics can include stable codes and aggregate counts/scales. They must not contain paths, raw errors, Vision objects, bounding boxes, landmarks, image bytes, SIMD coordinate dumps, or detector internals.

### Renderer Public-Facade-Only

**Source:** `BeautyExampleRenderer/main.swift` lines 1-5 and 130-149; `MODULES.md` lines 56-60
**Apply to:** renderer evidence and import scans

Renderer imports `BeautySDK` only, uses `BeautyEngine.processResult(image:metadata:parameters:)`, writes ignored local PNGs, and must not import `BeautyCore`, `BeautyDetection`, `BeautyEffects`, `BeautyRender`, `BeautyResources`, SwiftUI, or UIKit.

### Future Branch Negative Scans

**Source:** `18-VALIDATION.md` lines 39 and 45; current negative scan output showed intentional docs matches, so scanners must narrow paths or allowlist future-doc authorities.
**Apply to:** Phase 18 plans and verification summaries

Use narrow scans for public parameters and renderer cases:
```bash
! rg -n "blemish|pore|texture|skinRepair|teeth|hairline" BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
! rg -n "skinRepair|repair|teeth|hairline|blemish|pore" BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

For implementation scans, exclude expected lip-color `mask` terms in `BeautyColorEffectPipeline.swift` or narrow patterns so existing lip behavior does not create false failures.

### Factual Visual Evidence

**Source:** `EXAMPLE_IMAGE_VALIDATION.md` lines 32-41 and 65-78; `PLANS.md` lines 147-148 for Phase 16 evidence wording
**Apply to:** Phase 18 renderer evidence and summaries

Allowed observations: output exists/non-empty, dimensions match input, watermark is readable, watermark does not cover the face, and current skin cases show visible but natural changes. Do not claim commercial-grade naturalness, release-like visual QA, or production render quality.

## No Analog Found

No Phase 18 target lacks an analog. The only new likely file, `BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift`, should copy existing XCTest/Core Image fixture patterns from `CombinedEffectSafetyTests.swift` and public-path assertions from `BeautyEngineTests.swift`.

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, `docs/meitu-function-blueprint`, `.planning/phases/16-example-image-validation-harness`, `.planning/phases/17-core-beauty-contracts-and-module-boundaries`, `PLANS.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`
**Files scanned:** 30+
**Project skills:** no repo-local `.codex/skills/` or `.agents/skills/` directory found
**Pattern extraction date:** 2026-06-27
