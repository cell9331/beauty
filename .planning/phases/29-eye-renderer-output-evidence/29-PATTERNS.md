# Phase 29: Eye Renderer Output Evidence - Pattern Map

**Mapped:** 2026-07-09
**Files analyzed:** 8 new/modified files
**Analogs found:** 8 / 8

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | utility | batch file-I/O | `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | test | request-response transform | `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | exact |
| `.planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py` | utility | batch file-I/O transform | `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py` | exact |
| `example-images/generate_gallery.py` | utility | batch file-I/O | `example-images/generate_gallery.py` | exact |
| `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | documentation | batch evidence | `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | exact |
| `example-images/README.md` | documentation | batch evidence | `example-images/README.md` | exact |
| `QUALITY_SCORE.md` | documentation | batch evidence | `QUALITY_SCORE.md` | exact |
| `.planning/phases/29-eye-renderer-output-evidence/29-EYE-RENDERER-EVIDENCE.md` | documentation | batch evidence | `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-FACE-SHAPE-RENDERER-EVIDENCE.md` | exact |

## Pattern Assignments

### `BeautySDK/Sources/BeautyExampleRenderer/main.swift` (utility, batch file-I/O)

**Analog:** `BeautySDK/Sources/BeautyExampleRenderer/main.swift`

**Imports pattern** (lines 1-5):
```swift
import AppKit
import CoreImage
import Foundation
import ImageIO
import BeautySDK
```

**Case matrix pattern** (lines 95-140):
```swift
RenderCase(
    id: "geometryBaseline_noop",
    displayName: "geometry baseline noop",
    parameters: BeautyParameters()
),
RenderCase(
    id: "faceSlim_0p35",
    displayName: "faceSlim 0.35",
    parameters: BeautyParameters(faceSlim: 0.35)
),
RenderCase(
    id: "chinLength_minus0p30",
    displayName: "chinLength -0.30",
    parameters: BeautyParameters(chinLength: -0.30)
)
```

**Apply for Phase 29:** Add exactly these six `RenderCase` entries using existing public fields only:
```swift
RenderCase(id: "eyeSize_0p35", displayName: "eyeSize 0.35", parameters: BeautyParameters(eyeSize: 0.35))
RenderCase(id: "eyeDistance_plus0p25", displayName: "eyeDistance +0.25", parameters: BeautyParameters(eyeDistance: 0.25))
RenderCase(id: "eyeDistance_minus0p25", displayName: "eyeDistance -0.25", parameters: BeautyParameters(eyeDistance: -0.25))
RenderCase(id: "eyeYPosition_plus0p20", displayName: "eyeYPosition +0.20", parameters: BeautyParameters(eyeYPosition: 0.20))
RenderCase(id: "eyeYPosition_minus0p20", displayName: "eyeYPosition -0.20", parameters: BeautyParameters(eyeYPosition: -0.20))
RenderCase(id: "eyeTailLift_0p25", displayName: "eyeTailLift 0.25", parameters: BeautyParameters(eyeTailLift: 0.25))
```

**Core file-I/O pattern** (lines 168-192):
```swift
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
        let outputName = "\(baseName)__\(renderCase.id).png"
        try png.write(to: destination, options: .atomic)
    }
}
```

**Error handling pattern** (lines 13-36, 195-198):
```swift
enum ExampleRendererError: Error, CustomStringConvertible {
    case missingInputDirectory(String)
    case missingInputImages(String)
    case unknownCase(String, [String])
    case imageLoadFailed(String)
    case renderFailed(String)
    case pngEncodingFailed(String)
}

} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
```

**Fixture discovery pattern** (lines 209-232):
```swift
for case let url as URL in enumerator {
    guard ["png", "jpg", "jpeg"].contains(url.pathExtension.lowercased()) else {
        continue
    }
    let values = try? url.resourceValues(forKeys: [.isRegularFileKey])
    guard values?.isRegularFile == true else {
        continue
    }
    urls.append(url)
}
```

### `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` (test, request-response transform)

**Analog:** `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`

**Imports pattern** (lines 1-4):
```swift
import CoreImage
import ImageIO
import XCTest
import BeautySDK
```

**Inventory pattern** (lines 10-28):
```swift
private static let expectedRendererCaseIDs = [
    "skinSmoothing_0p50",
    "skinWhitening_0p50",
    "geometryBaseline_noop",
    "faceShapeCombo_0p35",
    "faceSlim_0p35",
    "jawSlim_0p35"
]
```

**Public facade guard pattern** (lines 40-56):
```swift
XCTAssertEqual(
    rendererCaseIDs(in: source),
    Self.expectedRendererCaseIDs,
    "BeautyExampleRenderer/main.swift renderer case IDs changed"
)
XCTAssertTrue(source.contains("import BeautySDK"), "BeautyExampleRenderer/main.swift should import BeautySDK")

for forbiddenTarget in ["BeautyCore", "BeautyDetection", "BeautyEffects", "BeautyRender", "BeautyResources"] {
    XCTAssertFalse(
        source.contains("import \(forbiddenTarget)"),
        "BeautyExampleRenderer/main.swift should not import \(forbiddenTarget)"
    )
}
```

**Scoped case validation pattern** (lines 97-125):
```swift
for (caseID, requiredParameter) in expectedCases {
    let snippet = try rendererCaseSnippet(for: caseID, in: source)

    XCTAssertTrue(snippet.contains(requiredParameter), "Missing \(requiredParameter) in \(caseID)")
    XCTAssertEqual(
        faceShapeFields.filter { snippet.contains($0) },
        [requiredParameter.split(separator: " ").first.map(String.init) ?? ""],
        "\(caseID) should use exactly one public face-shape parameter"
    )
    XCTAssertFalse(snippet.contains("BeautyDemo"), "\(caseID) should not introduce Demo coupling")
}
```

**No-face summary pattern** (lines 151-177):
```swift
let result = try engine.processResult(
    image: input,
    metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
    parameters: BeautyParameters(faceSlim: 0.35)
)

XCTAssertEqual(result.output.extent, input.extent)
XCTAssertEqual(result.detectionSummary?.availability, .noFace)
XCTAssertEqual(result.detectionSummary?.reasons, [.noFaceDetected])
XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 0)
XCTAssertTrue(result.warnings.contains { $0.code == "face_effects_skipped_no_face" })
assertRedacted(result)
```

**Helper parsing pattern** (lines 209-236):
```swift
private func rendererCaseIDs(in source: String) -> [String] {
    source.split(separator: "\n").compactMap { line in
        let marker = "id: \""
        guard let markerRange = line.range(of: marker) else {
            return nil
        }
        let remainder = line[markerRange.upperBound...]
        guard let endIndex = remainder.firstIndex(of: "\"") else {
            return nil
        }
        return String(remainder[..<endIndex])
    }
}
```

### `.planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py` (utility, batch file-I/O transform)

**Analog:** `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py`

**Imports/constants pattern** (lines 1-59):
```python
#!/usr/bin/env python3
"""Validate Phase 28 BeautyExampleRenderer face-shape PNG invariants."""

from __future__ import annotations

import argparse
import math
import struct
import sys
import zlib
from dataclasses import dataclass
from pathlib import Path

PORTRAIT_FIXTURE_NAMES = [
    "portraits/e1.png",
    "portraits/e2.png",
    "portraits/e3.png",
    "portraits/e4.png",
    "portraits/e5.png",
    "portraits/e6.jpg",
]
NO_FACE_FIXTURE_NAME = "negatives/no-face-gradient.png"
BASELINE_CASE_ID = "geometryBaseline_noop"
```

**Apply for Phase 29:** Use `PHASE29_EYE_CASE_IDS` with the six locked eye IDs and expand `RENDERER_CASE_IDS` from 17 to 23 IDs. Expected output count is `7 fixtures * 23 cases = 161`; expected portrait comparison count is `6 portraits * 6 eye cases = 36`.

**PNG/JPEG dimension pattern** (lines 74-138):
```python
def read_png_dimensions(path: Path, label: str) -> tuple[int, int]:
    with path.open("rb") as handle:
        signature = handle.read(8)
        if signature != b"\x89PNG\r\n\x1a\n":
            raise RendererOutputError(f"{label}: not a PNG")
        length_data = handle.read(4)
        chunk_type = handle.read(4)
        if len(length_data) != 4 or chunk_type != b"IHDR":
            raise RendererOutputError(f"{label}: missing IHDR")
        return struct.unpack(">II", ihdr[:8])

def read_fixture_dimensions(path: Path, label: str) -> tuple[int, int]:
    extension = path.suffix.lower()
    if extension == ".png":
        return read_png_dimensions(path, label)
    if extension in (".jpg", ".jpeg"):
        return read_jpeg_dimensions(path, label)
    raise RendererOutputError(f"{label}: unsupported fixture type")
```

**Watermark exclusion pattern** (lines 259-327):
```python
def comparable_top_region_rows(width: int, height: int) -> int:
    font_size = max(34.0, min(72.0, width / 30.0))
    padding = max(24.0, width / 70.0)
    watermark_band = font_size * 1.75
    excluded_bottom_rows = int(math.ceil(padding * 2 + watermark_band))
    return max(0, height - excluded_bottom_rows)

def top_region_differs(baseline_path: Path, geometry_path: Path, label: str) -> bool:
    baseline = read_png_payload(baseline_path, f"output/{baseline_path.name}")
    geometry = read_png_payload(geometry_path, f"output/{geometry_path.name}")
    if baseline.width != geometry.width or baseline.height != geometry.height:
        raise RendererOutputError(f"{label}: comparison dimensions differ")
    comparable_rows = comparable_top_region_rows(baseline.width, baseline.height)
    if comparable_rows <= 0:
        raise RendererOutputError(f"{label}: no comparable rows above watermark")
```

**Full-matrix validation pattern** (lines 370-417):
```python
for fixture_name in FIXTURE_NAMES:
    fixture_path = input_dir / fixture_name
    fixture_dimensions = read_fixture_dimensions(fixture_path, fixture_label)

    for case_id in RENDERER_CASE_IDS:
        output_name = expected_output_name(fixture_name, case_id)
        output_path = output_dir / output_name
        if not output_path.is_file():
            failures.append(f"{output_label}: missing")
            continue
        rendered = output_path.read_bytes()
        if not rendered:
            failures.append(f"{output_label}: zero bytes")
            continue
        output_dimensions = read_png_dimensions(output_path, output_label)
        if output_dimensions != fixture_dimensions:
            failures.append(f"{output_label}: dimensions ...")
            continue
        checked += 1
```

**Eye-vs-baseline comparison pattern** (lines 419-452):
```python
portrait_comparisons = 0
for fixture_name in PORTRAIT_FIXTURE_NAMES:
    baseline_name = expected_output_name(fixture_name, BASELINE_CASE_ID)
    for case_id in PHASE28_GEOMETRY_CASE_IDS:
        geometry_name = expected_output_name(fixture_name, case_id)
        differs = top_region_differs(
            output_dir / baseline_name,
            output_dir / geometry_name,
            f"output/{geometry_name}",
        )
        if not differs:
            failures.append(f"output/{geometry_name}: top region byte-identical to {baseline_name}")
            continue
        portrait_comparisons += 1
```

**Pass/fail output pattern** (lines 459-475):
```python
expected = len(FIXTURE_NAMES) * len(RENDERER_CASE_IDS)
if failures:
    print(f"phase 28 face shape renderer output check failed: {checked}/{expected} outputs")
    for failure in failures:
        print(f"FAIL: {failure}")
    return 1

print(f"phase 28 face shape renderer output check passed: {checked}/{expected} outputs")
print(f"portrait face-shape-vs-baseline top-region comparisons: {portrait_comparisons}/{expected_comparisons}")
print(f"no-face face-shape output present: {NO_FACE_FIXTURE_NAME} -> {no_face_output}")
```

### `example-images/generate_gallery.py` (utility, batch file-I/O)

**Analog:** `example-images/generate_gallery.py`

**Imports/constants pattern** (lines 1-15):
```python
#!/usr/bin/env python3
"""Generate the human-review gallery from flat renderer outputs."""

from __future__ import annotations

import argparse
import shutil
import sys
from collections import Counter
from pathlib import Path

SUPPORTED_INPUT_EXTENSIONS = {".png", ".jpg", ".jpeg"}
```

**Group mapping pattern** (lines 15-41):
```python
CASE_GROUPS = {
    "skin": [
        "skinSmoothing_0p50",
        "skinWhitening_0p50",
    ],
    "face-shape": [
        "geometryBaseline_noop",
        "faceShapeCombo_0p35",
        "jawSlim_0p35",
    ],
}
```

**Apply for Phase 29:** Add an `eyes` group with exactly the six locked eye case IDs. Keep `geometryBaseline_noop` in `face-shape` unless planning explicitly chooses to duplicate baseline in gallery grouping; do not add combo or negative tail-lift cases.

**Gallery generation pattern** (lines 68-97):
```python
fixture_stems = discover_fixture_stems(input_dir)
expected_sources = [
    output_dir / f"{fixture_stem}__{case_id}.png"
    for case_ids in CASE_GROUPS.values()
    for case_id in case_ids
    for fixture_stem in fixture_stems
]
missing = [path for path in expected_sources if not path.is_file()]
if missing:
    raise GalleryError(f"Missing generated output PNGs: {sample}{suffix}")

if gallery_dir.exists():
    shutil.rmtree(gallery_dir)
gallery_dir.mkdir(parents=True, exist_ok=True)
```

**Fixture stem guard pattern** (lines 100-118):
```python
input_paths = sorted(
    path
    for path in input_dir.rglob("*")
    if path.is_file() and path.suffix.lower() in SUPPORTED_INPUT_EXTENSIONS
)
stems = [path.stem for path in input_paths]
duplicates = sorted(stem for stem, count in counts.items() if count > 1)
if duplicates:
    raise GalleryError(f"Duplicate fixture stems are not supported: {', '.join(duplicates)}")
```

### Documentation files (documentation, batch evidence)

**Analogs:**
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`
- `example-images/README.md`
- `QUALITY_SCORE.md`
- `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-FACE-SHAPE-RENDERER-EVIDENCE.md`

**Evidence artifact front matter pattern** (`28-FACE-SHAPE-RENDERER-EVIDENCE.md` lines 1-15):
```markdown
---
phase: 28-face-shape-slice-completion-and-documentation-closeout
status: passed
verified: 2026-07-08
requirements:
  - FACE-01
  - FACE-02
---

# Phase 28 Face-Shape Renderer Evidence
```

**Evidence scope and non-claims pattern** (`28-FACE-SHAPE-RENDERER-EVIDENCE.md` lines 21-35):
```markdown
What is proven:

- `BeautyExampleRenderer` runs the public `BeautySDK` still-image facade for 6 input fixtures and 17 renderer cases.
- The Phase 28 helper verifies output existence, non-empty PNG files, same input/output dimensions, and 30/30 portrait top-region differences against `geometryBaseline_noop` above the watermark band.

What is not claimed:

- No Demo UI behavior changed.
- No new public `BeautyParameters` field was added.
- No public raw geometry API was added.
- No generated PNG baselines, hashes, or generated outputs are committed.
```

**Command evidence table pattern** (`28-FACE-SHAPE-RENDERER-EVIDENCE.md` lines 49-63):
```markdown
| Area | Status | Exact command | Result | Requirement |
| --- | --- | --- | --- | --- |
| Renderer build | passed | `swift build --package-path BeautySDK --product BeautyExampleRenderer` | Built product `BeautyExampleRenderer` successfully. | FACE-01 through FACE-06 |
| Phase 28 helper | passed | `python3 .../check_face_shape_renderer_outputs.py --input example-images/input --output example-images/out` | Passed with 102/102 outputs and 30/30 portrait face-shape-vs-baseline top-region comparisons. | FACE-01 through FACE-06 |
```

**Generated-output helper result pattern** (`28-FACE-SHAPE-RENDERER-EVIDENCE.md` lines 88-104):
```text
phase 28 face shape renderer output check passed: 102/102 outputs
dimensions 96x96: 17 outputs
portrait face-shape-vs-baseline top-region comparisons: 30/30
no-face face-shape output present: no-face-gradient.png -> no-face-gradient__jawSlim_0p35.png
fixtures: e1.png, e2.png, e3.png, e4.png, e5.png, no-face-gradient.png
cases: skinSmoothing_0p50, ...
phase 28 cases: faceSlim_0p35, ...
```

**Example validation matrix pattern** (`EXAMPLE_IMAGE_VALIDATION.md` lines 65-90):
```markdown
`BeautySDK/Sources/BeautyExampleRenderer/main.swift` is the canonical source for this matrix. Keep this table aligned with the executable case IDs.

| Case | Parameter coverage |
| --- | --- |
| `geometryBaseline_noop` | No-geometry baseline using default parameters |
| `faceSlim_0p35` | Phase 28 `脸宽` evidence through existing `faceSlim` |
```

**Example-images README gallery pattern** (`example-images/README.md` lines 28-41):
```markdown
The gallery groups current cases under:

- `skin/`: `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, `skinCombo_0p50`
- `color/`: `brightness_plus0p25`, `contrast_plus0p25`
- `filter/`: `filter_softClean_0p50`, `filter_warmLight_0p50`
- `face-shape/`: `geometryBaseline_noop`, `faceShapeCombo_0p35`, ...
```

**Quality ledger evidence pattern** (`QUALITY_SCORE.md` lines 195-213):
```markdown
### 3.13 Phase 28 Face-Shape Slice Evidence

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 6 tests and 0 failures.
- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` wrote 119 ignored PNG outputs across 7 fixtures and 17 cases after `e6.jpg` was added.
- `python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/output` passed with 119/119 outputs, same-dimension buckets, 36/36 portrait face-shape-vs-baseline top-region comparisons, and no-face face-shape output presence.
```

## Shared Patterns

### Public Facade Only
**Source:** `BeautySDK/Sources/BeautyExampleRenderer/main.swift` lines 1-5 and `BeautyRendererOutputRegressionTests.swift` lines 48-55  
**Apply to:** Renderer source and renderer inventory tests
```swift
import BeautySDK

for forbiddenTarget in ["BeautyCore", "BeautyDetection", "BeautyEffects", "BeautyRender", "BeautyResources"] {
    XCTAssertFalse(source.contains("import \(forbiddenTarget)"))
}
```

### Public Eye Parameter Boundary
**Source:** `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` lines 22-25, 92-95, 127-130  
**Apply to:** Renderer cases and tests
```swift
public var eyeSize: Float
public var eyeDistance: Float
public var eyeYPosition: Float
public var eyeTailLift: Float

eyeSize: Float = 0,
eyeDistance: Float = 0,
eyeYPosition: Float = 0,
eyeTailLift: Float = 0,

self.eyeSize = Self.clampSigned(eyeSize)
self.eyeDistance = Self.clampSigned(eyeDistance)
self.eyeYPosition = Self.clampSigned(eyeYPosition)
self.eyeTailLift = Self.clampSigned(eyeTailLift)
```

### Eye Provider Behavior
**Source:** `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` lines 14-43  
**Apply to:** Renderer case rationale and tests
```swift
if strengths.eyeSize > 0 {
    points.append(contentsOf: sizePoints(centers: [leftCenter, rightCenter], face: face, strength: strengths.eyeSize))
}
if abs(strengths.eyeDistance) > Float.ulpOfOne {
    points.append(contentsOf: distancePoints(leftCenter: leftCenter, rightCenter: rightCenter, face: face, strength: strengths.eyeDistance))
}
if abs(strengths.eyeYPosition) > Float.ulpOfOne {
    points.append(contentsOf: verticalPoints(centers: [leftCenter, rightCenter], face: face, strength: strengths.eyeYPosition))
}
if strengths.eyeTailLift > 0 {
    points.append(contentsOf: tailLiftPoints(face: face, strength: strengths.eyeTailLift))
}
```

### Eye Caps
**Source:** `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` lines 14-17  
**Apply to:** Strength selection, provider tests, Phase 29 limitations
```swift
static let eyeSize: Float = 0.45
static let eyeDistance: Float = 0.30
static let eyeYPosition: Float = 0.25
static let eyeTailLift: Float = 0.30
```

### Existing Eye Test Coverage
**Source:** `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` lines 43-78, 80-88  
**Apply to:** Verification selection and Phase 29 evidence notes
```swift
func testEyeDistanceMovesEyeRegionsOutwardWithCappedStrength() { ... }
func testEyeYPositionMovesBothEyesVerticallyWithCappedStrength() { ... }
func testEyeTailLiftMovesOuterTailPointsUpWithCappedStrength() { ... }
func testMissingEyeInputsReturnSkipReason() { ... }
```

### Generated Artifact Ignore Policy
**Source:** `.gitignore` lines 7-8 and `example-images/README.md` lines 10-13  
**Apply to:** Renderer outputs, gallery outputs, evidence docs
```gitignore
example-images/output/
example-images/gallery/
```

```markdown
- `output/`: ignored flat generated renderer PNGs, named `{fixtureStem}__{caseId}.png`.
- `gallery/`: ignored generated human-review view, grouped as `{featureFamily}/{caseId}/{fixtureStem}.png`.
Generated `output/` and `gallery/` contents are local artifacts. Recreate them instead of committing PNGs.
```

### Watermark-Aware Output Evidence
**Source:** `BeautyExampleRenderer/main.swift` lines 278-297 and Phase 28 helper lines 259-327  
**Apply to:** Phase 29 helper and evidence docs
```swift
let fontSize = CGFloat(max(34, min(72, width / 30)))
let padding = CGFloat(max(24, width / 70))
let bandHeight = fontSize * 1.75
NSColor.black.withAlphaComponent(0.62).setFill()
```

```python
excluded_bottom_rows = int(math.ceil(padding * 2 + watermark_band))
return max(0, height - excluded_bottom_rows)
```

### No-Overclaim Documentation
**Source:** `28-FACE-SHAPE-RENDERER-EVIDENCE.md` lines 28-35 and `29-CONTEXT.md` decisions D-12 through D-14  
**Apply to:** Phase 29 evidence, `EXAMPLE_IMAGE_VALIDATION.md`, `QUALITY_SCORE.md`, `PLANS.md`
```markdown
- No Demo UI behavior changed.
- No new public `BeautyParameters` field was added.
- No public raw geometry API was added.
- No generated PNG baselines, hashes, or generated outputs are committed.
- No commercial quality, device parity, broad Meitu parity, new geometry group, release-readiness, or whole-branch completion claim is made.
```

For Phase 29, state that public-facade renderer evidence exists for existing eye parameters, while `眼睛` rows and branch remain `partial` until Phase 30 safety/degradation/ledger closeout.

## No Analog Found

All Phase 29 files have close analogs in the codebase or Phase 28 planning artifacts.

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| None | - | - | - |

## Metadata

**Analog search scope:** `BeautySDK/Sources/BeautyExampleRenderer`, `BeautySDK/Tests/BeautyCoreTests`, `BeautySDK/Sources/BeautyCore/Models`, `BeautySDK/Sources/BeautyEffects`, `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout`, `example-images`, `docs/meitu-function-blueprint`, root quality/ledger docs, `.gitignore`  
**Files scanned:** 18  
**Pattern extraction date:** 2026-07-09
