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

## Pending Checks

- Mechanical output checks: ignored status, non-empty files, source/output dimensions, and factual visual observations.
- Scope scans: public API inventory, renderer geometry-case exclusion, Demo facade-only imports, non-UI SDK target imports, BeautyDemo source diff, shaping status honesty, and sensitive-token scan.
- Ledger checks: requirements, roadmap, state, project context, `PLANS.md`, roadmap analysis, plan index, and schema drift.
