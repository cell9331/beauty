# Phase 24: Renderer Output Regression Hardening - Pattern Map

**Mapped:** 2026-07-02
**Files analyzed:** 5 new/modified files
**Analogs found:** 5 / 5

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | test | file-I/O + request-response facade | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | role-match |
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | utility / executable | file-I/O + transform | `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | exact |
| `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md` | evidence | batch + file-I/O | `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` | role-match |
| `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | documentation | batch evidence + file-I/O | `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | exact |
| `docs/meitu-function-blueprint/FEATURE_MATRIX.md` | documentation | status guard | `docs/meitu-function-blueprint/FEATURE_MATRIX.md` | exact |

## Pattern Assignments

### `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` (test, file-I/O + facade request-response)

**Analog:** `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`

**Imports pattern** (lines 1-5):

```swift
import CoreImage
import CoreVideo
import ImageIO
import XCTest
import BeautySDK
```

Use `CoreImage`, `ImageIO`, `XCTest`, and `BeautySDK`. Do not import `BeautyCore`, `BeautyEffects`, `BeautyRender`, `SwiftUI`, or `UIKit` in this focused renderer regression test.

**XCTest class and requirement evidence pattern** (lines 7-9):

```swift
// Requirement evidence: SDK-02, SDK-04, SDK-06, SDK-07.
final class BeautyEngineTests: XCTestCase {
    func testSDK04PixelBufferNoopPreservesPixelsInNewOutputBuffer() throws {
```

Copy the concise requirement-evidence comment style and name tests after the requirement being protected, e.g. `RENDER01...`, `RENDER02...`, `RENDER03...`, `RENDER04...`.

**Facade no-op pixel equality pattern** (lines 24-33):

```swift
func testSDK04ImageNoopPreservesExtentAndRenderedPixels() throws {
    let image = CIImage(color: CIColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 1))
        .cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
    let engine = try BeautyEngine(configuration: .default)

    let output = try engine.process(image: image, orientation: .up, parameters: .init())

    XCTAssertEqual(output.extent, image.extent)
    XCTAssertEqual(try PixelBufferFixtures.rgbaBytes(from: output), try PixelBufferFixtures.rgbaBytes(from: image))
}
```

Adapt this to load `example-images/input/e1.png` through `e5.png`, call `BeautyEngine.processResult(image:metadata:parameters:)` with default `BeautyParameters`, compare pre-watermark output extent to input extent, then compare rendered bytes exactly unless a documented platform color-management tolerance is intentionally added.

**Visible-output changed-pixels pattern** (lines 60-80):

```swift
let result = try engine.processResult(
    image: image,
    metadata: BeautyInputMetadata(orientation: .up, source: .photo),
    parameters: parameters
)

XCTAssertEqual(result.output.extent, image.extent)
XCTAssertNotEqual(try PixelBufferFixtures.rgbaBytes(from: result.output), try PixelBufferFixtures.rgbaBytes(from: image))
XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 3)
```

Use this assertion shape for visible output checks when comparing rendered input/output bytes. For fixture-size images, add a helper that renders the full extent rather than the existing 1x1 helper.

**Rendered-byte helper pattern** (lines 280-292):

```swift
static func rgbaBytes(from image: CIImage) throws -> [UInt8] {
    let context = CIContext(options: [.workingColorSpace: CGColorSpaceCreateDeviceRGB()])
    var bytes = [UInt8](repeating: 0, count: 4)
    context.render(
        image,
        toBitmap: &bytes,
        rowBytes: 4,
        bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
        format: .RGBA8,
        colorSpace: CGColorSpaceCreateDeviceRGB()
    )
    return bytes
}
```

Copy the `CIContext.render(..., format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())` approach, but scale `bytes`, `rowBytes`, and `bounds` to the fixture image width and height. The renderer executable uses both `.workingColorSpace` and `.outputColorSpace`; use the same fixed color-space setup for deterministic fixture comparisons.

### `BeautySDK/Sources/BeautyExampleRenderer/main.swift` (utility / executable, file-I/O + transform)

**Analog:** `BeautySDK/Sources/BeautyExampleRenderer/main.swift`

**Imports and facade boundary pattern** (lines 1-5):

```swift
import AppKit
import CoreImage
import Foundation
import ImageIO
import BeautySDK
```

This executable is allowed to use AppKit for watermark drawing. It should continue to import only the public `BeautySDK` facade from SDK targets.

**Canonical case matrix pattern** (lines 44-95):

```swift
let cases = [
    RenderCase(
        id: "skinSmoothing_0p50",
        displayName: "skinSmoothing 0.50",
        parameters: BeautyParameters(skinSmoothing: 0.50)
    ),
    RenderCase(
        id: "skinWhitening_0p50",
        displayName: "skinWhitening 0.50",
        parameters: BeautyParameters(skinWhitening: 0.50)
    ),
    RenderCase(
        id: "skinRosy_0p40",
        displayName: "skinRosy 0.40",
        parameters: BeautyParameters(skinRosy: 0.40)
    ),
    RenderCase(
        id: "skinSharpen_0p40",
        displayName: "skinSharpen 0.40",
        parameters: BeautyParameters(skinSharpen: 0.40)
    ),
    RenderCase(
        id: "brightness_plus0p25",
        displayName: "brightness +0.25",
        parameters: BeautyParameters(brightness: 0.25)
    ),
    RenderCase(
        id: "contrast_plus0p25",
        displayName: "contrast +0.25",
        parameters: BeautyParameters(contrast: 0.25)
    ),
    RenderCase(
        id: "filter_softClean_0p50",
        displayName: "filter soft_clean 0.50",
        parameters: BeautyParameters(filterId: "soft_clean", filterIntensity: 0.50)
    ),
    RenderCase(
        id: "filter_warmLight_0p50",
        displayName: "filter warm_light 0.50",
        parameters: BeautyParameters(filterId: "warm_light", filterIntensity: 0.50)
    ),
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
]
```

Phase 24 tests and docs should mirror these exact 9 IDs. Do not add geometry or new product-feature cases unless a later plan explicitly changes scope and updates evidence/docs.

**Input discovery, selected case, and error pattern** (lines 97-117):

```swift
let inputURL = URL(fileURLWithPath: inputDirectory, isDirectory: true)
let outputURL = URL(fileURLWithPath: outputDirectory, isDirectory: true)
let fileManager = FileManager.default
guard fileManager.fileExists(atPath: inputURL.path) else {
    throw ExampleRendererError.missingInputDirectory(inputURL.path)
}
try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true)

let renderCases = cases.filter { selectedCase == nil || selectedCase == $0.id }
if let selectedCase, renderCases.isEmpty {
    throw ExampleRendererError.unknownCase(selectedCase, cases.map(\.id))
}

let imageURLs = try fileManager
    .contentsOfDirectory(at: inputURL, includingPropertiesForKeys: nil)
    .filter { ["png", "jpg", "jpeg"].contains($0.pathExtension.lowercased()) }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
guard !imageURLs.isEmpty else {
    throw ExampleRendererError.missingInputImages(inputURL.path)
}
```

Use this file discovery behavior as the expected generated-output matrix: sorted PNG/JPEG inputs under `example-images/input` times the canonical case list.

**Public facade render and output naming pattern** (lines 119-149):

```swift
let engine = try BeautyEngine(configuration: .default)
let context = CIContext(options: [
    .workingColorSpace: CGColorSpaceCreateDeviceRGB(),
    .outputColorSpace: CGColorSpaceCreateDeviceRGB()
])

for imageURL in imageURLs {
    guard let inputImage = CIImage(contentsOf: imageURL, options: [.applyOrientationProperty: true]) else {
        throw ExampleRendererError.imageLoadFailed(imageURL.path)
    }

    for renderCase in renderCases {
        let result = try engine.processResult(
            image: inputImage,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: renderCase.parameters
        )
        guard let cgImage = context.createCGImage(result.output, from: result.output.extent) else {
            throw ExampleRendererError.renderFailed(imageURL.path)
        }

        let watermark = watermarkText(for: renderCase, result: result)
        let watermarked = try drawWatermark(watermark, on: cgImage)
        let baseName = imageURL.deletingPathExtension().lastPathComponent
        let outputName = "\(baseName)__\(renderCase.id).png"
        let destination = outputURL.appendingPathComponent(outputName)
```

Visible-output invariant checks should expect `{source}__{case}.png`, same dimensions as input, non-empty PNG bytes, and bytes different from the source fixture for visible cases.

**Watermark drawing pattern** (lines 199-218):

```swift
let fontSize = CGFloat(max(34, min(72, width / 30)))
let padding = CGFloat(max(24, width / 70))
let bandHeight = fontSize * 1.75
let bandRect = NSRect(
    x: padding,
    y: padding,
    width: CGFloat(width) - padding * 2,
    height: bandHeight
)
NSColor.black.withAlphaComponent(0.62).setFill()
NSBezierPath(roundedRect: bandRect, xRadius: 18, yRadius: 18).fill()
```

Watermark readability evidence should be factual inspection notes. Do not add OCR or brittle watermark pixel heuristics in Phase 24.

### `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md` (evidence, batch + file-I/O)

**Analog:** `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md`

**Frontmatter and scope pattern** (lines 1-18):

```markdown
---
phase: 23-performance-and-reliability-gates
status: final
updated: 2026-07-02
requirements:
  - PERF-01
  - PERF-02
  - PERF-03
  - PERF-04
  - PERF-05
---

# Phase 23 Performance and Reliability Evidence

## Scope
```

Use the same frontmatter shape with `phase: 24-renderer-output-regression-hardening`, `status`, `updated`, and `RENDER-01` through `RENDER-04`.

**Status vocabulary and non-claims pattern** (lines 19-32):

```markdown
Status values:

- `passed`: command or scan ran in this phase and passed.
- `recorded`: current-environment evidence exists but includes a limitation or risk.
- `blocked`: hardware or tooling needed for that evidence is unavailable.
- `not run`: evidence was intentionally left to the documented rerun protocol.

## Non-claims

- Current timing is SwiftPM debug XCTest baseline data, not shipped frame-rate readiness.
- Phase 23 does not assert commercial visual review, real-device parity, screenshot acceptance, or market fitness.
```

For Phase 24, replace non-claims with renderer-specific wording: no commercial visual quality, no production naturalness, no release readiness, no all-device parity, no Meitu parity, and no geometry saved-output completion.

**Exact command results table pattern** (lines 50-62):

```markdown
| Area | Status | Exact command | Result | Requirement |
| --- | --- | --- | --- | --- |
| Swift environment | passed | `swift --version` | Apple Swift `6.3.3`, swift-driver `1.148.6`, target `arm64-apple-macosx26.0`. | PERF-01 |
| Focused SDK evidence tests | passed | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` | Executed 3 tests, 0 failures, 11.292 seconds. | PERF-01, PERF-04, PERF-05 |
| Required field scan | passed | `rg -n "PERF-01|PERF-02|PERF-03|PERF-04|PERF-05|Timing matrix|Budget comparison|Memory trend|Backpressure|Quality mode|Reset|Degradation|Redaction scan|Non-claims|Rerun protocol" .planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` | Required evidence headings and requirement IDs are present. | PERF-01, PERF-02, PERF-03, PERF-04, PERF-05 |
| Scoped no-overclaim scan | passed | Plan 23-04 scoped no-overclaim scan over this artifact | No matches after final edits. | PERF-05 |
```

Use this table shape for `swift build --package-path BeautySDK --product BeautyExampleRenderer`, all-case renderer run, focused renderer output tests, generated-output invariant checks, static case inventory scan, geometry-case exclusion scan, and no-overclaim scans.

**Evidence limitation pattern** (lines 147-153):

```markdown
Phase 23 evidence is limited to allowlisted case names, sample counts, warmup counts, duration summaries, resolution bucket, quality mode, warning codes, metric keys, memory status, blocker class, impact, next step, and rerun protocol.

The Plan 23-04 scoped redaction scan over this file returned no matches after final edits. The artifact avoids frame payloads, private local paths, face-coordinate payloads, unredacted preset payloads, user identifiers, token-like data, and diagnostic dumps.

The no-overclaim scan also returned no matches. The conclusions are limited to pass, recorded baseline, blocked, not-run, risk, and rerun status.
```

For renderer evidence, allowlist command summaries, fixture names, case IDs, dimensions, output counts, file sizes, byte-difference status, representative watermark notes, blocker class, impact, and next step.

**Requirement coverage pattern** (lines 155-163):

```markdown
| Requirement | Status | Evidence |
| --- | --- | --- |
| PERF-01 | recorded | Focused SDK evidence command records a `1280x720` timing matrix through `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)`; all current cases are classified as over-budget baseline data against `RELIABILITY.md`. |
| PERF-05 | passed | Performance logs remain optional/off by default, evidence fields are allowlisted, and redaction plus no-overclaim scans pass. |
```

End `24-RENDERER-EVIDENCE.md` with RENDER-01 through RENDER-04 rows that tie each requirement to concrete commands or blocker-honest evidence.

### `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` (documentation, batch evidence + file-I/O)

**Analog:** `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`

**Command pattern** (lines 23-30):

````markdown
Run all built-in cases:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input \
  --output example-images/out
```
````

Keep command examples in this direct shell block style. Add Phase 24 rerun/invariant commands only after they exist and are verified.

**Output rules pattern** (lines 32-41):

```markdown
- Output directory: `example-images/out/`.
- Output files are ignored by git.
- File names include source image, parameter name, and parameter strength:
  - `e2__skinWhitening_0p50.png`
  - `e4__filter_warmLight_0p50.png`
- A large bottom watermark is drawn on each image with the parameter and strength.
- The watermark is placed at the bottom to avoid covering the face.
- The output image keeps the same pixel dimensions as the input image.
```

Preserve the ignored-output and same-dimension contract. Add any Phase 24 wording factually, not as quality claims.

**Current case matrix pattern** (lines 43-57):

```markdown
| Case | Parameter coverage |
| --- | --- |
| `skinSmoothing_0p50` | Basic skin smoothing proxy |
| `skinWhitening_0p50` | Skin whitening |
| `skinRosy_0p40` | Rosy skin |
| `skinSharpen_0p40` | Sharpen/contrast proxy |
| `brightness_plus0p25` | Color brightness |
| `contrast_plus0p25` | Color contrast |
| `filter_softClean_0p50` | Built-in `soft_clean` filter |
| `filter_warmLight_0p50` | Built-in `warm_light` filter |
| `skinCombo_0p50` | Combined basic skin parameters |
```

This doc should mirror the executable case IDs exactly. If the code-owned matrix changes, this table and evidence must change intentionally in the same phase.

**Geometry limitation pattern** (lines 59-63):

```markdown
Face-shape, eye, nose, mouth, eyebrow, and 3D sculpt branches already have internal planning/provider tests, but full visual image output needs face detection plus geometry rendering integration.

Phase 19 strengthens provider, resolver, cap, degradation, and redaction XCTest evidence for current public shaping fields. That evidence remains internal partial evidence only; before marking those branches visually complete, v1.3 must extend this public facade validation path so geometry parameters produce same-dimension, watermarked saved-image outputs from the same `example-images/input` fixtures.
```

Update tense/version if needed, but keep the same claim boundary: provider/resolver tests do not prove visual saved-output completion.

### `docs/meitu-function-blueprint/FEATURE_MATRIX.md` (documentation, status guard)

**Analog:** `docs/meitu-function-blueprint/FEATURE_MATRIX.md`

**Status vocabulary pattern** (lines 3-10):

```markdown
- `implemented` - Current SDK/Demo behavior exists and has tests plus facade-visible example output when the branch produces visible image output.
- `partial` - Current public parameters, provider logic, resolver behavior, or unit evidence exists, but visible saved-image completion or branch coverage is incomplete.
- `blocked-by-geometry-output` - The branch needs public facade detection plus geometry render integration before saved example-image output can prove it.
- `future` - Out of implementation scope until explicitly promoted.

Geometry provider and resolver tests are useful provider evidence, but they do not count as visible completion until `BeautyEngine.processResult(...)` can produce public-facade saved-image output for the branch.
```

Do not weaken this status model. Phase 24 should add evidence/guards that preserve it.

**Geometry branch status pattern** (lines 20-26):

```markdown
| Beauty shaping | 3D塑颜 | blocked-by-geometry-output | `BeautyEffects` | `BeautyDetection` pose/landmarks, `BeautyRender` unified warp | None. | Symmetry, vertical, horizontal, and tilt controls need product-neutral parameters and design updates. | Detection/render integration plus public facade saved-image output required before visible completion. | Current branch is a documented geometry target only. |
| Beauty shaping | 比例 | partial | `BeautyEffects` | `BeautyDetection` landmarks, `BeautyRender` unified warp | `faceSmall` covers small-head style behavior indirectly. | Forehead, mid-face, philtrum, lower-face, short-face, and head-face controls need new parameters if promoted. | Existing provider/resolver evidence is partial; saved-image output waits for facade geometry. | Meitu branch name stays in Demo taxonomy; SDK language stays product-neutral. |
| Beauty shaping | 脸型 | partial | `BeautyEffects` | `BeautyDetection` landmarks, `BeautyRender` unified warp | `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength`. | Smooth face, temple, cheekbone, double chin, pointed chin, and hairline need new parameters or resources if promoted. | Provider/resolver tests support partial; public facade saved-image output is still required for visual completion. | Uses SDK domain `faceShape`. |
| Beauty shaping | 眼睛 | partial | `BeautyEffects` | `BeautyDetection` eye landmarks, `BeautyRender` unified warp | `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift`. | Eye height, length, pupil, gaze, lid, redness, corners, symmetry, and eye-fat controls need new parameters/resources if promoted. | Provider/resolver tests support partial; public facade saved-image output is still required for visual completion. | Uses SDK domain `eyes`. |
| Beauty shaping | 嘴唇 | partial | `BeautyEffects` | `BeautyDetection` mouth landmarks, `BeautyRender` unified warp | `mouthSize`, `mouthWidth`, `smile`, `lipColor`. | M-lip, position, tilt, left/right, and teeth controls need new parameters or a retouch/segmentation design. | Provider/resolver and lip-color output evidence are partial by subtool; geometry saved-output remains required. | Uses SDK domains `mouth` and `lipColor`. |
| Beauty shaping | 鼻子 | partial | `BeautyEffects` | `BeautyDetection` nose landmarks, `BeautyRender` unified warp | `noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge`. | Lift, root/bridge split, and additional nose shaping controls need new parameters if promoted. | Provider/resolver tests support partial; public facade saved-image output is still required for visual completion. | Uses SDK domain `nose`. |
| Beauty shaping | 眉毛 | future | `BeautyEffects` | Future landmarks/resource support only if promoted | None. | Position, thickness, length, distance, head distance, tilt, and peak controls need new parameters and possibly resources. | No v1.3 completion evidence expected until explicitly promoted. | `BeautyResources` may be a future dependency, not an active owner. |
```

Phase 24 should preserve these rows unless evidence from public-facade saved geometry outputs exists, which is explicitly out of scope.

## Shared Patterns

### Public Facade Only

**Source:** `BeautySDK/Package.swift` lines 36-41 and `BeautySDK/Sources/BeautyExampleRenderer/main.swift` lines 1-5

```swift
.executableTarget(
    name: "BeautyExampleRenderer",
    dependencies: ["BeautySDK"]
),
.testTarget(name: "BeautyCoreTests", dependencies: ["BeautyCore", "BeautySDK"]),
```

Apply to the new test and renderer evidence. The executable depends only on `BeautySDK`; the new regression test may live in `BeautyCoreTests` but should exercise the public facade through `import BeautySDK`.

### Current Fixture Set

**Source:** repository inventory and `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` lines 58-60

```markdown
| Renderer all-cases run | passed | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` | Wrote 45 PNG outputs: 5 input fixtures times 9 current renderer cases. | AUD-02, RENDER-01, RENDER-03 | Keep generated PNGs local/ignored; Phase 24 should add tolerance/regression checks. |
| Input fixture count | passed | `find example-images/input -maxdepth 1 -type f | sort` | Found `e1.png`, `e2.png`, `e3.png`, `e4.png`, and `e5.png`. | AUD-02 | Fixture set is current baseline input set. |
| Output count | passed | `find example-images/out -maxdepth 1 -type f -name '*.png' | wc -l` | Counted 45 generated PNG outputs. | AUD-02, RENDER-03 | Matches current 5 x 9 renderer matrix. |
```

Apply to no-op fixture tests and evidence checks: `e1.png` through `e5.png`, 9 cases, 45 generated visible outputs.

### Generated Output Evidence

**Source:** `.planning/phases/20-core-module-closeout/20-VERIFICATION.md` lines 127-195

```markdown
Result: passed.

Observed summary:

- `dimension check passed: 45 outputs`.
- Every generated output preserved its source input dimensions.

Representative outputs inspected with the local image viewer:

- `example-images/out/e2__skinWhitening_0p50.png`: non-empty face image, readable bottom watermark below the face, visible lightening/tone change.
```

Copy the evidence shape, but strengthen Phase 24 to cover all generated outputs mechanically and keep human inspection representative and factual.

### Geometry Exclusion Scan

**Source:** `.planning/phases/20-core-module-closeout/20-VERIFICATION.md` lines 214-227

```bash
! rg -n 'id: "(face|eye|nose|mouth|lip|chin|jaw|proportion|3d|brow)|BeautyParameters\([^)]*(faceSlim|faceSmall|faceVShape|jawSlim|chinLength|eyeSize|eyeDistance|eyeYPosition|eyeTailLift|noseSlim|noseWingSlim|noseTipSize|noseBridge|mouthSize|mouthWidth|smile|lipColor)' BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

Use this scan or a tighter equivalent to prove Phase 24 did not add geometry saved-output cases.

### Shaping Status Honesty Scan

**Source:** `.planning/phases/20-core-module-closeout/20-VERIFICATION.md` lines 271-283

```bash
! rg -n '3D塑颜.*implemented|比例.*implemented|脸型.*implemented|眼睛.*implemented|嘴唇.*implemented|鼻子.*implemented|眉毛.*implemented' docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/features/beauty-shaping
```

Apply to docs and Phase 24 evidence after edits so geometry-heavy branches stay `partial`, `blocked-by-geometry-output`, or `future`.

## No Analog Found

All planned files have close analogs in the codebase or planning ledgers.

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| n/a | n/a | n/a | n/a |

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, `docs/meitu-function-blueprint`, `.planning/phases/20-core-module-closeout`, `.planning/phases/21-baseline-audit-and-quality-ledger-refresh`, `.planning/phases/23-performance-and-reliability-gates`
**Files scanned:** 7 focused files plus phase context/research and project instructions
**Pattern extraction date:** 2026-07-02
