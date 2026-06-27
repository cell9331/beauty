---
phase: 18
slug: skin-retouch-core-modules
status: approved
nyquist_compliant: true
wave_0_complete: false
created: 2026-06-27
---

# Phase 18 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest plus `BeautyExampleRenderer` build/run and shell static scans |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectResolverTests` |
| **Full suite command** | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectsTests` |
| **Renderer command set** | Build `BeautyExampleRenderer`, then run `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, and `skinCombo_0p50` |
| **Estimated runtime** | XCTest/runtime depends on local SwiftPM cache; shell scans should complete in under 30 seconds after build artifacts exist |

## Sampling Rate

- **After every implementation task:** Run the narrowest affected XCTest filter and `git diff --check` on touched files.
- **After Basic skin formula work:** Run `SkinBasicEffectTests` once that file exists, plus the resolver tests when caps/no-face behavior is touched.
- **After branch documentation work:** Run branch-status and future-branch negative scans.
- **After renderer evidence work:** Run renderer build, all five current skin renderer cases, same-dimension checks, facade-only import scan, and factual visual observation recording.
- **Before `$gsd-verify-work`:** Re-run focused XCTest, renderer build/run for all five skin cases, representative dimension checks, future-branch negative scans, completion-overclaim scan, and `git diff --check`.
- **Max feedback latency:** under 2 minutes for focused XCTest and shell scans after SwiftPM build artifacts exist.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 18-01-01 | 18-01 | 1 | SKIN-01, SKIN-03 | T-18-01 | Branch docs keep Basic skin separate from future Skin repair and Teeth/hairline. | static/docs | `rg -n "Basic skin|Skin repair|Teeth/hairline|implemented|future|BeautyEffects|skinSmoothing" docs/meitu-function-blueprint/features/skin-retouch docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/MODULES.md` | W0 | pending |
| 18-01-02 | 18-01 | 1 | SKIN-03 | T-18-02 | Future local repair and region branches remain absent from public SDK parameters and renderer cases. | static/code | `! rg -n "blemish|pore|texture|skinRepair|teeth|hairline" BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift && ! rg -n "skinRepair|repair|teeth|hairline|blemish|pore" BeautySDK/Sources/BeautyExampleRenderer/main.swift` | W0 | pending |
| 18-02-01 | 18-02 | 2 | SKIN-02 | T-18-03 | Basic skin formula changes stay conservative and deterministic in the existing pipeline. | unit | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter SkinBasicEffectTests` | missing until 18-02 | pending |
| 18-02-02 | 18-02 | 2 | SKIN-02 | T-18-04 | Public facade no-detection skin remains active while explicit internal no-face skin may be skipped with redacted metadata. | unit/integration | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectResolverTests` | W0 | pending |
| 18-02-03 | 18-02 | 2 | SKIN-02 | T-18-05 | Warnings and metrics do not expose raw image, face geometry, landmarks, paths, or detector internals. | unit/static | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEngineTests && ! rg -n "landmark|boundingBox|CVPixelBuffer|CIImage|path:" BeautySDK/Sources/BeautyEffects BeautySDK/Sources/BeautySDK` | W0 | pending |
| 18-03-01 | 18-03 | 3 | SKIN-02 | T-18-06 | Renderer stays public-facade-only and writes local ignored outputs. | build/runtime/static | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path BeautySDK --product BeautyExampleRenderer && ! rg -n "import Beauty(Core|Detection|Effects|Render|Resources)|import SwiftUI|import UIKit" BeautySDK/Sources/BeautyExampleRenderer` | W0 | pending |
| 18-03-02 | 18-03 | 3 | SKIN-02 | T-18-07 | All current Basic skin renderer cases save same-dimension outputs. | runtime/shell | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinSmoothing_0p50 && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinWhitening_0p50 && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinRosy_0p40 && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinSharpen_0p40 && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinCombo_0p50 && file example-images/input/e2.png example-images/out/e2__skinSmoothing_0p50.png example-images/out/e2__skinWhitening_0p50.png example-images/out/e2__skinRosy_0p40.png example-images/out/e2__skinSharpen_0p40.png example-images/out/e2__skinCombo_0p50.png` | outputs generated during 18-03 | pending |
| 18-03-03 | 18-03 | 3 | SKIN-03 | T-18-08 | Phase 18 does not introduce repair, teeth/hairline, segmentation, AI/upload, or release-like quality claims. | static/code/docs | `! rg -n "skinRepair|skin repair|blemish|pore|inpainting|teeth whitening|hairline adjustment|segmentation|mask" BeautySDK/Sources/BeautyEffects BeautySDK/Sources/BeautyRender BeautySDK/Sources/BeautyResources && ! rg -n "URLSession|http://|https://|upload|cloud|AI|segmentation" BeautySDK/Sources/BeautyEffects BeautySDK/Sources/BeautySDK BeautySDK/Sources/BeautyExampleRenderer && ! rg -n "Skin repair.*implemented|Teeth/hairline.*implemented|teeth.*implemented|hairline.*implemented|commercial-grade|release-like|production naturalness" docs/meitu-function-blueprint .planning/phases/18-skin-retouch-core-modules .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md PLANS.md` | W0 | pending |

## Wave 0 Requirements

- [x] `BeautySDK/Package.swift` already declares the tested library targets and `BeautyExampleRenderer` executable product.
- [x] Existing resolver, cap, parameter, and engine test files exist and can be used as patterns.
- [x] Existing renderer cases include `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, and `skinCombo_0p50`.
- [ ] `BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift` must be created during Phase 18 execution for focused Basic skin formula coverage.
- [ ] Plan-specific negative scans must include allowlists or narrowed paths so intentional future documentation does not create false failures.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Factual visual observations for Basic skin PNGs | SKIN-02 | Shell checks can prove output existence and dimensions, but cannot judge watermark readability or visible natural change. | Open the generated `example-images/out/e2__*.png` skin outputs and record only factual observations allowed by Phase 18 context: output is non-empty, watermark is readable, watermark does not cover the face, dimensions match, and visible changes remain natural. Do not claim commercial-grade or release-like visual quality. |

## Validation Sign-Off

- [x] All planned task areas have automated verification coverage or an explicit manual-only reason.
- [x] Sampling continuity: no three consecutive task areas without automated verification.
- [ ] Wave 0 is incomplete because `SkinBasicEffectTests.swift` is intentionally created by execution.
- [x] No watch-mode flags.
- [x] Feedback latency target documented.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-27
