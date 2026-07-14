# Phase 28: Face Shape Slice Completion and Documentation Closeout - Pattern Map

**Mapped:** 2026-07-07  
**Files analyzed:** 18  
**Analogs found:** 18 / 18

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | utility | batch file-I/O | `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | test | batch request-response | `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | exact |
| `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py` | utility | batch file-I/O transform | `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py` | exact |
| `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-FACE-SHAPE-RENDERER-EVIDENCE.md` | documentation | batch evidence | `.planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md` | exact |
| `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-VERIFICATION.md` | documentation | batch evidence | `.planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | exact |
| `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` | documentation | ledger update | `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` | exact |
| `docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md` | documentation | ledger update | `docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md` | exact |
| `docs/meitu-function-blueprint/FEATURE_MATRIX.md` | documentation | ledger update | `docs/meitu-function-blueprint/FEATURE_MATRIX.md` | exact |
| `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | documentation | batch evidence | `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | exact |
| `.planning/REQUIREMENTS.md` | planning ledger | state transition | `.planning/REQUIREMENTS.md` | exact |
| `.planning/ROADMAP.md` | planning ledger | state transition | `.planning/ROADMAP.md` | exact |
| `.planning/STATE.md` | planning ledger | state transition | `.planning/STATE.md` | exact |
| `PLANS.md` | planning ledger | state transition | `PLANS.md` | exact |
| `QUALITY_SCORE.md` | documentation | ledger update | `QUALITY_SCORE.md` | exact |
| Root docs: `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md` | documentation | contract sync | Phase 27 root-doc closeout pattern in `PLANS.md` and `27-VERIFICATION.md` | role-match |

## Pattern Assignments

### `BeautySDK/Sources/BeautyExampleRenderer/main.swift` (utility, batch file-I/O)

**Analog:** `BeautySDK/Sources/BeautyExampleRenderer/main.swift`

**Imports and facade boundary** (lines 1-5):
```swift
import AppKit
import CoreImage
import Foundation
import ImageIO
import BeautySDK
```

Copy this boundary exactly. Phase 28 renderer cases must stay public-facade-only; do not import `BeautyCore`, `BeautyDetection`, `BeautyEffects`, `BeautyRender`, or `BeautyResources`.

**Renderer case pattern** (lines 95-110):
```swift
RenderCase(
    id: "geometryBaseline_noop",
    displayName: "geometry baseline noop",
    parameters: BeautyParameters()
),
RenderCase(
    id: "faceShapeCombo_0p35",
    displayName: "face shape combo 0.35",
    parameters: BeautyParameters(
        faceSlim: 0.35,
        faceSmall: 0.30,
        faceVShape: 0.35,
        jawSlim: 0.30,
        chinLength: 0.20
    )
)
```

Add Phase 28 cases in this same matrix style: one each for `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, plus positive and negative `chinLength`. `下颌线` must not get a separate case; document it as sharing `jawSlim`.

**Processing and output pattern** (lines 146-165):
```swift
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

### `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` (test, batch request-response)

**Analog:** `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`

**Inventory pattern** (lines 10-22):
```swift
private static let expectedRendererCaseIDs = [
    "skinSmoothing_0p50",
    "skinWhitening_0p50",
    "skinRosy_0p40",
    "skinSharpen_0p40",
    "brightness_plus0p25",
    "contrast_plus0p25",
    "filter_softClean_0p50",
    "filter_warmLight_0p50",
    "skinCombo_0p50",
    "geometryBaseline_noop",
    "faceShapeCombo_0p35"
]
```

Append Phase 28 IDs here whenever renderer cases are added.

**Public import guard** (lines 41-48):
```swift
XCTAssertTrue(source.contains("import BeautySDK"), "BeautyExampleRenderer/main.swift should import BeautySDK")

for forbiddenTarget in ["BeautyCore", "BeautyDetection", "BeautyEffects", "BeautyRender", "BeautyResources"] {
    XCTAssertFalse(
        source.contains("import \(forbiddenTarget)"),
        "BeautyExampleRenderer/main.swift should not import \(forbiddenTarget)"
    )
}
```

**Redaction guard** (lines 211-238):
```swift
let metadata = (
    result.warnings.map { "\($0.code) \($0.message)" } +
    Array(result.metrics.keys) +
    (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
).joined(separator: " ")

for forbidden in [
    "VNFaceObservation",
    "boundingBox",
    "controlPoint",
    "/private/var",
    "NSError",
    "AVError",
    "rawPresetJson",
    "raw JSON",
    "image bytes",
    "landmarks=",
    "landmarkCoordinates",
    "rawLandmark",
    "SIMD"
] {
    XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)", file: file, line: line)
}
```

### `check_face_shape_renderer_outputs.py` (utility, batch file-I/O transform)

**Analog:** `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py`

**Case inventory and baseline pattern** (lines 15-44):
```python
PORTRAIT_FIXTURE_NAMES = [
    "e1.png",
    "e2.png",
    "e3.png",
    "e4.png",
    "e5.png",
]

NO_FACE_FIXTURE_NAME = "no-face-gradient.png"

BASELINE_CASE_ID = "geometryBaseline_noop"
GEOMETRY_CASE_ID = "faceShapeCombo_0p35"
```

For Phase 28, keep the same fixture split and compare every per-tool face-shape case against `geometryBaseline_noop`. Use a list of geometry case IDs, not a single `GEOMETRY_CASE_ID`.

**Top-region comparison pattern** (lines 222-242):
```python
def comparable_top_region_rows(width: int, height: int) -> int:
    font_size = max(34.0, min(72.0, width / 30.0))
    padding = max(24.0, width / 70.0)
    watermark_band = font_size * 1.75
    excluded_bottom_rows = int(math.ceil(padding * 2 + watermark_band))
    return max(0, height - excluded_bottom_rows)

def top_region_differs(baseline_path: Path, geometry_path: Path, label: str) -> bool:
    baseline = read_png_rgba_pixels(baseline_path, f"output/{baseline_path.name}")
    geometry = read_png_rgba_pixels(geometry_path, f"output/{geometry_path.name}")
    if baseline.width != geometry.width or baseline.height != geometry.height:
        raise RendererOutputError(f"{label}: comparison dimensions differ")
```

**Output and dimension checks** (lines 274-308):
```python
for case_id in RENDERER_CASE_IDS:
    output_name = expected_output_name(fixture_name, case_id)
    output_path = output_dir / output_name
    output_label = f"output/{output_name}"

    if not output_path.is_file():
        failures.append(f"{output_label}: missing")
        continue
...
    if output_dimensions != fixture_dimensions:
        failures.append(
            f"{output_label}: dimensions {output_dimensions[0]}x{output_dimensions[1]} "
            f"!= {fixture_name} {fixture_dimensions[0]}x{fixture_dimensions[1]}"
        )
        continue
```

**Helper result format** (lines 346-353):
```python
print(f"phase 27 geometry renderer output check passed: {checked}/{expected} outputs")
for dimensions, count in sorted(dimension_counts.items()):
    width, height = dimensions
    print(f"dimensions {width}x{height}: {count} outputs")
print(f"portrait geometry-vs-baseline top-region comparisons: {portrait_comparisons}/{len(PORTRAIT_FIXTURE_NAMES)}")
print(f"no-face geometry output present: {NO_FACE_FIXTURE_NAME} -> {no_face_output}")
print("fixtures: " + ", ".join(FIXTURE_NAMES))
print("cases: " + ", ".join(RENDERER_CASE_IDS))
```

### `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` (test, transform)

**Analog:** `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift`

**Face slim pattern** (lines 6-24):
```swift
let result = FaceShapeWarpProvider().makeControlPoints(
    face: .fixture,
    strengths: strengths(faceSlim: 1)
)

XCTAssertNil(result.skipReason)
XCTAssertEqual(result.points.count, 2)
...
XCTAssertLessThanOrEqual(left.strength, BeautySafetyCaps.faceSlim)
```

**Face small pattern** (lines 27-41):
```swift
let result = FaceShapeWarpProvider().makeControlPoints(
    face: face,
    strengths: strengths(faceSmall: 1)
)

XCTAssertGreaterThanOrEqual(result.points.count, 4)
for point in result.points {
    XCTAssertLessThan(
        LandmarkGeometryHelper.distance(point.target, face.center),
        LandmarkGeometryHelper.distance(point.source, face.center)
    )
    XCTAssertLessThanOrEqual(point.strength, BeautySafetyCaps.faceSmall)
}
```

**V shape and jaw pattern** (lines 72-83):
```swift
let vShape = provider.makeControlPoints(face: face, strengths: strengths(faceVShape: 1))
let jawSlim = provider.makeControlPoints(face: face, strengths: strengths(jawSlim: 1))

XCTAssertFalse(vShape.points.isEmpty)
XCTAssertFalse(jawSlim.points.isEmpty)
XCTAssertTrue(vShape.points.allSatisfy { $0.source.y >= face.bounds.midY })
XCTAssertTrue(jawSlim.points.allSatisfy { $0.source.y >= face.bounds.midY })
```

**Signed chin pattern** (lines 85-99):
```swift
let longer = provider.makeControlPoints(face: face, strengths: strengths(chinLength: 1))
let shorter = provider.makeControlPoints(face: face, strengths: strengths(chinLength: -1))

let longPoint = try! XCTUnwrap(longer.points.first)
let shortPoint = try! XCTUnwrap(shorter.points.first)

XCTAssertGreaterThan(longPoint.target.y, longPoint.source.y)
XCTAssertLessThan(shortPoint.target.y, shortPoint.source.y)
XCTAssertLessThanOrEqual(longPoint.strength, BeautySafetyCaps.chinLength)
XCTAssertLessThanOrEqual(shortPoint.strength, BeautySafetyCaps.chinLength)
```

**Missing contour degradation pattern** (lines 117-125):
```swift
let result = FaceShapeWarpProvider().makeControlPoints(
    face: .missingContour,
    strengths: strengths(faceSlim: 1, faceSmall: 1, faceVShape: 1, jawSlim: 1)
)

XCTAssertTrue(result.points.isEmpty)
XCTAssertEqual(result.skipReason, "missing_face_contour")
```

### Resolver, caps, and combined weakening tests (test, transform)

**Analogs:** `BeautyEffectResolver.swift`, `BeautySafetyCaps.swift`, `CombinedEffectSafetyTests.swift`, `GeometryConflictResolverTests.swift`

**Existing face-shape activation and signed cap pattern** (`BeautyEffectResolver.swift` lines 74-79):
```swift
strengths.faceSlim = capUnit(normalized.faceSlim, cap: BeautySafetyCaps.faceSlim, cappedCount: &cappedCount)
strengths.faceSmall = capUnit(normalized.faceSmall, cap: BeautySafetyCaps.faceSmall, cappedCount: &cappedCount)
strengths.faceVShape = capUnit(normalized.faceVShape, cap: BeautySafetyCaps.faceVShape, cappedCount: &cappedCount)
strengths.jawSlim = capUnit(normalized.jawSlim, cap: BeautySafetyCaps.jawSlim, cappedCount: &cappedCount)
strengths.chinLength = capSigned(normalized.chinLength, cap: BeautySafetyCaps.chinLength, cappedCount: &cappedCount)
```

**Caps inventory** (`BeautySafetyCaps.swift` lines 8-12):
```swift
static let faceSlim: Float = 0.60
static let faceSmall: Float = 0.45
static let faceVShape: Float = 0.50
static let jawSlim: Float = 0.45
static let chinLength: Float = 0.35
```

**No-face degradation pattern** (`CombinedEffectSafetyTests.swift` lines 8-41):
```swift
let plan = BeautyEffectResolver.resolve(
    parameters: BeautyParameters(
        skinSmoothing: 0.6,
        brightness: 0.2,
        faceSlim: 1,
        eyeSize: 1,
        noseSlim: 1,
        mouthSize: 1,
        lipColor: 1,
        filterId: "soft_clean",
        filterIntensity: 0.5
    ),
    faceGeometry: nil
)

XCTAssertTrue(plan.activeDomains.contains(.color))
XCTAssertTrue(plan.activeDomains.contains(.filter))
XCTAssertFalse(plan.activeDomains.contains(.faceShape))
XCTAssertTrue(plan.skippedDomains.contains(.faceShape))
XCTAssertTrue(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
```

**Combined weakening and redacted metrics pattern** (`GeometryConflictResolverTests.swift` lines 27-61):
```swift
let resolved = GeometryConflictResolver().resolve(strengths: strengths(
    faceSlim: 1,
    faceSmall: 1,
    faceVShape: 1,
    jawSlim: 1,
    chinLength: 1,
    eyeSize: 1,
    eyeDistance: 1,
    eyeYPosition: 1,
    eyeTailLift: 1,
    noseSlim: 1,
    noseWingSlim: 1,
    noseTipSize: 1,
    noseBridge: 1,
    mouthSize: 1,
    mouthWidth: 1,
    smile: 1
))

XCTAssertEqual(resolved.warnings.map(\.code), ["combined_geometry_weakened"])
XCTAssertEqual(Set(resolved.metrics.keys), [
    "beauty.effects.weakenedCount",
    "beauty.effects.geometryStrengthScale"
])
```

### Documentation ledgers (documentation, ledger update)

**Analogs:** `SHAPE_FEATURE_LEDGER.md`, face-shape README, `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`

**Implementation status rule** (`SHAPE_FEATURE_LEDGER.md` lines 20-28):
```markdown
| Marker | Meaning | Required update when reached |
| --- | --- | --- |
| `partial` | SDK has a current parameter, provider/resolver behavior, unit evidence, or subtool evidence, but not enough facade-visible output for completion. | Update this ledger, branch README, and `FEATURE_MATRIX.md` if branch-level status changes. |
| `implemented` | SDK behavior exists, tests pass, safety/degradation is covered, and facade-visible output evidence exists when the tool has visible output. | Mark the tool implemented here; update branch README, `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, and milestone evidence. |
```

**Scoped face-shape rows to update only after evidence passes** (`SHAPE_FEATURE_LEDGER.md` lines 69-80):
```markdown
| `脸型` | 脸宽 | partial | Existing `faceSlim` coverage. | Facade-visible geometry output and branch-specific acceptance evidence. |
| `脸型` | 小脸 | partial | Existing `faceSmall` coverage. | Facade-visible geometry output and branch-specific acceptance evidence. |
| `脸型` | 下巴长短 | partial | Existing `chinLength` coverage. | Facade-visible geometry output and branch-specific acceptance evidence. |
| `脸型` | V脸 | partial | Existing `faceVShape` coverage. | Facade-visible geometry output and branch-specific acceptance evidence. |
| `脸型` | 下颌角 | partial | Existing `jawSlim` coverage. | Facade-visible geometry output and branch-specific acceptance evidence. |
| `脸型` | 下颌线 | partial | Existing `jawSlim` coverage is reused. | Decide whether this remains an alias or needs a distinct neutral parameter; facade-visible output evidence. |
```

**Do-not-promote rule** (`SHAPE_FEATURE_LEDGER.md` lines 121-131):
```markdown
When a phase completes any SDK-core tool:

1. Update the corresponding row in this ledger.
2. Update the owning branch README under `features/beauty-shaping/`.
3. Update `FEATURE_MATRIX.md` only when branch-level status changes.
4. Update `EXAMPLE_IMAGE_VALIDATION.md` when new SDK verification output exists.
5. Record exact commands and evidence in the phase verification artifact.

Do not mark a tool `implemented` from Demo-only mapping, planned taxonomy, or provider-only evidence.
```

**Face-shape README structure** (`features/beauty-shaping/face-shape/README.md` lines 7-18):
```markdown
## Technical Core

- Existing MVP supports parts of face slim, small face, V shape, jaw, and chin.
- Advanced cheekbone, temple, double-chin, and hairline need additional landmarks or segmentation.
- Safety caps must prevent extreme contour collapse.
- Status: `partial`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`.
- Future parameter needs: smooth face, temple, cheekbone, double chin, pointed chin, and hairline.
- Evidence expectation: current provider/resolver evidence is partial; visible completion needs public facade saved-image geometry output.
```

**Branch-level matrix pattern** (`FEATURE_MATRIX.md` lines 22-24):
```markdown
| Beauty shaping | 脸型 | partial | `BeautyEffects` | `BeautyDetection` landmarks, `BeautyRender` unified warp | `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength`. | Smooth face, temple, cheekbone, double chin, pointed chin, and hairline need new parameters or resources if promoted. | Provider/resolver tests support partial; public facade saved-image output is still required for visual completion. | Uses SDK domain `faceShape`. |
```

Keep this row `partial`; add scoped completion notes if useful, but do not mark the whole `脸型` branch `implemented`.

**Example image validation update pattern** (`EXAMPLE_IMAGE_VALIDATION.md` lines 40-53):
```markdown
## Output Rules

- Output directory: `example-images/out/`.
- Output files are ignored by git.
- File names include source image, parameter name, and parameter strength:
  - `e2__skinWhitening_0p50.png`
  - `e4__filter_warmLight_0p50.png`
- A large bottom watermark is drawn on each image with the parameter and strength.
- The watermark is placed at the bottom to avoid covering the face.
- The output image keeps the same pixel dimensions as the input image.
```

**Evidence summary pattern** (`EXAMPLE_IMAGE_VALIDATION.md` lines 121-130):
```markdown
## Phase 27 Evidence Summary

- `BeautyRendererOutputRegressionTests` verifies the current 11-case renderer matrix, 6 input fixtures, public-facade import boundary, Phase 27 face-shape-only case scope, and no-face summary redaction.
- The all-case renderer command produced 66 ignored PNG outputs.
- `check_geometry_renderer_outputs.py` verified those 66 outputs for existence, non-empty files, same pixel dimensions, 5/5 portrait geometry-vs-baseline top-region comparisons, and no-face geometry output presence.
- Generated PNGs remain ignored local artifacts; Markdown evidence records commands, counts, dimensions, helper results, and factual observations only.
```

### Phase 28 evidence and verification docs (documentation, batch evidence)

**Analogs:** `27-GEOMETRY-RENDERER-EVIDENCE.md`, `27-VERIFICATION.md`

**Evidence front matter and scope pattern** (`27-GEOMETRY-RENDERER-EVIDENCE.md` lines 1-23):
```markdown
---
phase: 27-geometry-render-output-and-verification-harness
status: passed
verified: 2026-07-07
requirements:
  - GEO-03
  - GEO-04
---

# Phase 27 Geometry Renderer Evidence

## Scope

This artifact records SDK-only saved-output evidence for the Phase 27 geometry render foundation.
```

**Non-claim pattern** (`27-GEOMETRY-RENDERER-EVIDENCE.md` lines 24-32):
```markdown
What is not claimed:

- No Demo UI behavior changed.
- No public raw geometry API was added.
- No generated PNG baselines or hashes are committed.
- No eye, nose, mouth, lip, proportion, 3D, or brow saved-output cases are claimed.
- No commercial, parity, device, or launch claim is made.
- Per-tool face-shape ledger promotion remains future work.
```

For Phase 28, replace the final bullet with a scoped claim only after evidence passes: six scoped rows promoted; unscoped face-shape rows and branch-level completion remain future/partial.

**Command evidence table pattern** (`27-VERIFICATION.md` lines 44-58):
```markdown
| Gate | Command | Result |
| --- | --- | --- |
| Renderer regression suite | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` | Passed: 4 tests, 0 failures. |
| Full SDK suite | `swift test --package-path BeautySDK` | Passed: 167 tests, 0 failures. |
| Renderer build | `swift build --package-path BeautySDK --product BeautyExampleRenderer` | Built product successfully. |
| Renderer run | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` | Wrote 66 PNG outputs. |
| Phase 27 helper | `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out` | Passed: 66/66 outputs, 5/5 portrait geometry-vs-baseline top-region comparisons, no-face output present. |
| Ignored output policy | `git check-ignore example-images/out/e1__faceShapeCombo_0p35.png example-images/out/e1__geometryBaseline_noop.png example-images/out/no-face-gradient__faceShapeCombo_0p35.png` | Passed: representative generated geometry outputs are ignored. |
```

**Static scan pattern** (`27-VERIFICATION.md` lines 60-70):
```markdown
| Gate | Scope | Result |
| --- | --- | --- |
| Public/SPI raw geometry export scan | `BeautySDK/Sources/BeautySDK`, `BeautySDK/Sources/BeautyDetection`, `BeautySDK/Sources/BeautyEffects` | Passed with zero matches for public or SPI exports of internal face observations, internal geometry types, raw landmarks, bounds, or point payloads. |
| Active-source redaction scan | Public/Core SDK and active Demo surfaces, plus internal Detection/Effects redaction tokens | Passed with zero matches for forbidden public raw geometry, local path, raw framework diagnostic, raw preset, or image payload leakage. |
| Renderer public-import scan | `BeautyRendererOutputRegressionTests.swift` and `BeautyExampleRenderer/main.swift` | Passed with zero internal SDK target imports. |
| Renderer scope scan | `BeautyExampleRenderer/main.swift` | Passed with zero eye, nose, mouth, lip, proportion, 3D, or brow renderer cases. |
| Shape ledger promotion guard | `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` and beauty-shaping README | Passed with zero implemented-status promotion for face-shape rows. |
```

For Phase 28, invert the ledger guard: allow only `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线` to become `implemented`; verify unscoped rows stay `future` or existing status and `FEATURE_MATRIX.md` remains `partial`.

### Planning and root ledgers (planning ledger, state transition)

**Analogs:** `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md`, `QUALITY_SCORE.md`

**Requirements update pattern** (`.planning/REQUIREMENTS.md` lines 15-28):
```markdown
### Face Shape Slice

- [ ] **FACE-01**: `脸宽` is SDK-complete through existing `faceSlim`.
- [ ] **FACE-02**: `小脸` is SDK-complete through existing `faceSmall`.
- [ ] **FACE-03**: `下巴长短` is SDK-complete through existing `chinLength`.
- [ ] **FACE-04**: `V脸` is SDK-complete through existing `faceVShape`.
- [ ] **FACE-05**: `下颌角` is SDK-complete through existing `jawSlim`.
- [ ] **FACE-06**: `下颌线` is explicitly handled as either a documented `jawSlim` alias or a separate SDK behavior decision, with ledger evidence.
```

Mark these complete only after evidence passes; final wording for FACE-06 should reflect the locked alias decision, not a split.

**Roadmap Phase 28 pattern** (`.planning/ROADMAP.md` lines 113-126):
```markdown
### Phase 28: Face Shape Slice Completion and Documentation Closeout

**Status:** Pending
**Goal:** Complete the `脸型` existing-parameter slice and update status ledgers only where facade-visible evidence exists.
**Requirements:** FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03
**Dependencies:** Phase 27

**Success Criteria:**

1. `脸宽`, `小脸`, `下巴长短`, `V脸`, and `下颌角` have SDK tests, safety/degradation evidence, and saved-output evidence through existing parameters.
2. `下颌线` is documented as a `jawSlim` alias or split into a future distinct SDK behavior decision.
```

**State closeout pattern** (`.planning/STATE.md` lines 133-141):
```markdown
- v1.5 is scoped to SDK geometry output foundation plus the `脸型` existing-parameter slice only. Phase 26 covers public facade geometry activation and privacy-safe landmark routing, Phase 27 covers saved-output geometry evidence and degradation verification, and Phase 28 covers `脸型` tool completion plus ledger/documentation closeout.
- Phase 27 completed saved-output geometry foundation evidence: `BeautyExampleRenderer` now includes `geometryBaseline_noop` and `faceShapeCombo_0p35`, writes 66 ignored PNG outputs across 6 fixtures and 11 cases, and `check_geometry_renderer_outputs.py` verifies 66/66 outputs, same dimensions, 5/5 portrait geometry-vs-baseline top-region comparisons, and no-face output presence.
```

**Quality ledger update pattern** (`QUALITY_SCORE.md` lines 37-49):
```markdown
Current repository state as of 2026-07-07 after Phase 27 geometry render output and verification harness evidence:

| Area | Score | Evidence | Next Move |
| --- | --- | --- | --- |
| GSD planning | 4 | `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, and `.planning/REQUIREMENTS.md` define v1.5 as SDK geometry output foundation plus the `脸型` existing-parameter slice. Phase 26 records GEO-01/GEO-02 complete from `26-VERIFICATION.md`; Phase 27 records GEO-03/GEO-04 complete from `27-VERIFICATION.md`; Phase 28 remains pending for per-tool face-shape completion and ledger promotion. | Discuss Phase 28 for the `脸型` existing-parameter slice and keep second-level status promotion blocked until tool-specific evidence exists. |
```

**PLANS completion entry pattern** (`PLANS.md` lines 11-18 and Phase 27 completion entry lines 44-62):
```markdown
- 完成工作后：把计划移入 Completed，并记录验证证据。
- 发现非当前范围问题：写入 Tech Debt，不顺手扩大范围。
- 改变架构、设计、安全、可靠性或产品契约时，同步更新对应根级文档。
- 未运行验证时，必须写明“未验证”和原因。
```

Use the Phase 27 completed entry structure: Scope, Requirements, Files, Verification, Build, Commit, Outcome, and Next step.

## Shared Patterns

### SDK-Only Boundary
**Source:** `AGENTS.md` and Phase 28 context.  
**Apply to:** all Phase 28 implementation and docs.  
No Demo UI work, no new public `BeautyParameters`, no entitlement/pro behavior, no network/cloud behavior, no public raw geometry API, no generated PNG baselines, and no branch-level `脸型` implemented claim.

### Public Facade Renderer
**Source:** `BeautySDK/Sources/BeautyExampleRenderer/main.swift` lines 1-5, 146-165.  
**Apply to:** renderer case additions and evidence commands.  
Renderer imports only `BeautySDK`, runs `BeautyEngine.processResult(image:metadata:parameters:)`, writes `example-images/out/<fixture>__<case>.png`, and watermarks with case display text.

### Top-Region Geometry Comparison
**Source:** `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py` lines 222-242 and 310-332.  
**Apply to:** Phase 28 helper.  
Compare each per-tool portrait output to `geometryBaseline_noop` above the watermark band; do not rely on full PNG differences or hashes.

### Alias Handling
**Source:** Phase 28 context D-01 through D-05 and current `SHAPE_FEATURE_LEDGER.md` row at line 80.  
**Apply to:** `jawSlim` renderer/test evidence, `SHAPE_FEATURE_LEDGER.md`, face-shape README, and verification docs.  
`下颌线` is alias-backed by `jawSlim` in v1.5 and shares `下颌角` evidence; do not add a separate case, public field, or algorithm.

### Redaction and Privacy
**Source:** `BeautyRendererOutputRegressionTests.swift` lines 211-238; `CombinedEffectSafetyTests.swift` lines 123-129 and 167-174; `GeometryConflictResolverTests.swift` lines 55-61.  
**Apply to:** all tests, scans, and evidence docs.  
Allowed evidence fields are case IDs, relative paths, counts, dimensions, command status, warning codes, and aggregate metric keys. Exclude raw landmarks, bounds, control points, Vision objects, local absolute paths, raw framework errors, raw JSON, image bytes, hashes, and committed PNG baselines.

### Ledger Promotion Guard
**Source:** `SHAPE_FEATURE_LEDGER.md` lines 27, 31-39, 69-80, 121-131; `FEATURE_MATRIX.md` lines 22-24.  
**Apply to:** docs and planning closeout.  
Only promote six scoped rows after evidence passes: `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`. Keep unscoped tools unchanged and `FEATURE_MATRIX.md` `脸型` branch status `partial`.

### Verification Artifact Format
**Source:** `27-VERIFICATION.md` lines 37-70 and `27-GEOMETRY-RENDERER-EVIDENCE.md` lines 33-48, 67-82, 103-123.  
**Apply to:** `28-VERIFICATION.md` and `28-FACE-SHAPE-RENDERER-EVIDENCE.md`.  
Record exact commands, pass/fail counts, helper output, ignored-output checks, static scans, non-claims, and rerun commands.

## No Analog Found

All expected Phase 28 file roles have close analogs. No new architectural pattern is required.

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, `docs/meitu-function-blueprint`, root docs, `.planning`, and Phase 27 artifacts.  
**Files scanned:** 240+ paths from `rg --files`; 18 analog files read for concrete excerpts.  
**Pattern extraction date:** 2026-07-07
