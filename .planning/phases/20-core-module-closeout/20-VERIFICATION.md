---
phase: 20-core-module-closeout
status: in_progress
updated: 2026-06-30
requirements:
  - EDITOR-01
  - EDITOR-02
  - EDITOR-03
  - MOD-02
  - MOD-03
  - MOD-04
---

# Phase 20 Core Module Closeout Verification

## Scope

Phase 20 verifies v1.3 closeout without adding new behavior. Current authority docs and ledgers may change, but the closeout must not add SwiftUI screens, Demo routes, public `BeautyParameters`, renderer cases, geometry saved-image output, network/media transfer behavior, or release-readiness claims.

## SDK and Renderer Evidence

### Full SDK Test Suite

Command:

```bash
swift test --package-path BeautySDK
```

Result: passed.

Observed summary:

- `BeautySDKPackageTests.xctest` executed 141 tests.
- Failures: 0.
- Unexpected failures: 0.
- The Swift Testing runner reported 0 tests in 0 suites after XCTest completed, also with 0 failures.

Important covered suites included:

- `BeautyEngineTests`
- `BeautyParametersTests`
- `BeautyEffectResolverTests`
- `SkinBasicEffectTests`
- `FaceShapeWarpProviderTests`
- `EyeWarpProviderTests`
- `NoseWarpProviderTests`
- `MouthWarpProviderTests`
- `GeometryConflictResolverTests`
- `MissingLandmarkDegradationTests`
- `VisionFaceDetectorTests`

### Renderer Build

Command:

```bash
swift build --package-path BeautySDK --product BeautyExampleRenderer
```

Result: passed.

Observed summary:

- Product `BeautyExampleRenderer` built successfully for debugging.
- No source changes were required.

### Renderer All-Cases Run

Command:

```bash
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out
```

Result: passed.

Input fixtures:

- `example-images/input/e1.png`
- `example-images/input/e2.png`
- `example-images/input/e3.png`
- `example-images/input/e4.png`
- `example-images/input/e5.png`

Current built-in cases from `BeautySDK/Sources/BeautyExampleRenderer/main.swift`:

| Case | Source line |
| --- | --- |
| `skinSmoothing_0p50` | 46 |
| `skinWhitening_0p50` | 51 |
| `skinRosy_0p40` | 56 |
| `skinSharpen_0p40` | 61 |
| `brightness_plus0p25` | 66 |
| `contrast_plus0p25` | 71 |
| `filter_softClean_0p50` | 76 |
| `filter_warmLight_0p50` | 81 |
| `skinCombo_0p50` | 86 |

Output directory:

- `example-images/out/`

Observed output count:

- 45 PNG files written.
- Formula: 5 input fixtures times 9 built-in cases.

Representative output filenames:

- `example-images/out/e1__skinSmoothing_0p50.png`
- `example-images/out/e2__skinWhitening_0p50.png`
- `example-images/out/e3__skinRosy_0p40.png`
- `example-images/out/e4__filter_warmLight_0p50.png`
- `example-images/out/e5__skinCombo_0p50.png`

Ignored-output policy:

- Generated files under `example-images/out/` are local evidence artifacts and must remain out of git.

Geometry limitation:

- This renderer evidence covers the current skin, color, and filter saved-image cases only.
- It does not prove public facade saved-image completion for face shape, eyes, nose, mouth geometry, eyebrow, proportion, or 3D sculpt branches.
- Geometry-heavy shaping branches remain `partial` or `blocked-by-geometry-output` until public facade detection plus geometry render integration can produce same-dimension, watermarked saved outputs.

## Mechanical Output Checks

### Ignored Evidence Artifacts

Command:

```bash
git check-ignore -v example-images/out/e1__skinSmoothing_0p50.png example-images/out/e2__skinWhitening_0p50.png example-images/out/e3__skinRosy_0p40.png example-images/out/e4__filter_warmLight_0p50.png example-images/out/e5__skinCombo_0p50.png
```

Result: passed.

Observed summary:

- `.gitignore:7:example-images/out/` matched each representative renderer output.
- Generated renderer artifacts remain untracked evidence, not committed deliverables.

### Non-Empty Files

Command:

```bash
stat -f '%N %z' example-images/out/e1__skinSmoothing_0p50.png example-images/out/e2__skinWhitening_0p50.png example-images/out/e3__skinRosy_0p40.png example-images/out/e4__filter_warmLight_0p50.png example-images/out/e5__skinCombo_0p50.png
```

Result: passed.

Observed sizes:

- `e1__skinSmoothing_0p50.png`: 6040860 bytes.
- `e2__skinWhitening_0p50.png`: 842493 bytes.
- `e3__skinRosy_0p40.png`: 11592671 bytes.
- `e4__filter_warmLight_0p50.png`: 4650381 bytes.
- `e5__skinCombo_0p50.png`: 5621510 bytes.

### Dimensions

Command:

```bash
python3 -c '<PNG header dimension scan for all example-images/out/*.png>'
```

Result: passed.

Observed summary:

- `dimension check passed: 45 outputs`.
- Every generated output preserved its source input dimensions.

Representative `file` output:

- `example-images/input/e2.png`: 576 x 1024.
- `example-images/out/e2__skinSmoothing_0p50.png`: 576 x 1024.
- `example-images/out/e2__skinWhitening_0p50.png`: 576 x 1024.
- `example-images/out/e2__skinCombo_0p50.png`: 576 x 1024.
- `example-images/out/e4__filter_warmLight_0p50.png`: 1440 x 2560.

### Visual Inspection

Representative outputs inspected with the local image viewer:

- `example-images/out/e2__skinWhitening_0p50.png`: non-empty face image, readable bottom watermark below the face, visible lightening/tone change.
- `example-images/out/e2__skinCombo_0p50.png`: non-empty face image, readable bottom watermark below the face, visible combined skin/tone change.
- `example-images/out/e4__filter_warmLight_0p50.png`: non-empty face image, readable bottom watermark below the face, visible warm filter/tone change.

Visual limitation:

- These observations are factual artifact checks only. They do not claim effect quality, naturalness, real-device parity, release readiness, or geometry saved-image completion.

## Scope Scans

### Public Parameter Inventory

Command:

```bash
python3 -c '<assert BeautyParameters public var list equals the documented 31-field v1.3 inventory>'
```

Result: passed.

Observed summary:

- `fields ok: 31`.
- No new public `BeautyParameters` field was added during closeout.

### Renderer Geometry Case Exclusion

Command:

```bash
! rg -n 'id: "(face|eye|nose|mouth|lip|chin|jaw|proportion|3d|brow)|BeautyParameters\([^)]*(faceSlim|faceSmall|faceVShape|jawSlim|chinLength|eyeSize|eyeDistance|eyeYPosition|eyeTailLift|noseSlim|noseWingSlim|noseTipSize|noseBridge|mouthSize|mouthWidth|smile|lipColor)' BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

Result: passed with no matches.

Meaning:

- `BeautyExampleRenderer` still contains only skin, color, and filter cases.
- Geometry-heavy saved-image output remains out of scope for Phase 20.

### Demo Facade-Only Imports

Command:

```bash
rg -n 'import Beauty(Core|Detection|Effects|Render|Resources)' BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests || true
```

Result: passed with no matches.

Meaning:

- Demo sources and tests do not import SDK internals directly.

### SDK UI Dependency Scan

Command:

```bash
rg -n 'SwiftUI|UIKit' BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyRender BeautySDK/Sources/BeautyEffects 2>/dev/null || true
```

Result: passed with no matches.

Meaning:

- Non-UI SDK targets remain UI-framework-free.

### BeautyDemo Source Diff

Command:

```bash
git diff --name-only -- BeautyDemo
```

Result: passed with no output.

Meaning:

- Phase 20 closeout did not change Demo source or project files.

### Shaping Status Honesty

Command:

```bash
! rg -n '3D塑颜.*implemented|比例.*implemented|脸型.*implemented|眼睛.*implemented|嘴唇.*implemented|鼻子.*implemented|眉毛.*implemented' docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/features/beauty-shaping
```

Result: passed with no matches.

Meaning:

- Shaping branches are not overclaimed as implemented in current blueprint docs.

### Sensitive Emitted String Scan

Broad implementation-token scan:

```bash
! rg -n 'VNFaceObservation|bounding|landmark|control point|controlPoint|/private/var|image bytes|SIMD|\[0\.' BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo/Editor BeautyDemo/BeautyDemo/Camera BeautySDK/Sources/BeautyEffects/Planning BeautySDK/Sources/BeautyEffects/Warp
```

Result: failed on implementation-only geometry/math identifiers such as `SIMD2`, `controlPoints`, `bounds`, and landmark model property names inside provider code.

Replacement scoped command:

```bash
python3 -c '<scan Swift string literals in the same source roots for sensitive warning/metric/debug tokens>'
```

Result: passed.

Observed summary:

- `sensitive emitted string scan passed`.
- No warning, metric, debug label, or emitted string literal exposes `VNFaceObservation`, raw bounding/landmark/control-point internals, absolute private paths, image bytes, `SIMD`, or raw normalized-coordinate examples.

## Pending Ledger Checks

- Requirements, roadmap, state, project context, and `PLANS.md` closeout.
- Roadmap analysis, plan index, schema drift, and final formatting checks.
