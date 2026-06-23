---
phase: 06
slug: core-beauty-effects
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-21
audited: 2026-06-23
---

# Phase 06 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via SwiftPM and Xcode |
| **Config file** | `BeautySDK/Package.swift`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` |
| **Quick run command** | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectsTests` |
| **SDK suite command** | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` |
| **Demo suite command** | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` |
| **Estimated runtime** | Focused tests under 180 seconds where possible; full SDK plus Demo simulator tests may take several minutes based on simulator state |

---

## Sampling Rate

- **After every `BeautyEffects` task:** Run focused `BeautyEffectsTests` covering caps, effect resolution, provider output, and degradation.
- **After every engine/render task:** Run focused `BeautyEngineTests` plus any `BeautyRenderTests` touched by the plan.
- **After every Demo task:** Run focused `BeautyParameterStoreTests`, `BeautyDemoViewStateTests`, and `BeautyDemoImportBoundaryTests`.
- **After every wave:** Run all focused tests for the files changed in that wave and the Demo internal-import scan.
- **Before `$gsd-verify-work`:** Run full SDK SwiftPM tests, full Demo simulator tests, Demo facade-only import scan, public geometry/privacy leak scan, visual-scope scan, and `git diff --check`.
- **Max feedback latency:** Keep focused commands under about 180 seconds where possible; record exact environment failures instead of marking them green.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 06-01-01 | 06-01 | 1 | EFFECT-01, EFFECT-09 | T-06-01 | Effect resolver and safety caps keep default no-op, cap high strength, and emit redacted warning/metric evidence. | unit | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectsTests` | yes | green |
| 06-01-02 | 06-01 | 1 | EFFECT-01, EFFECT-09 | T-06-01 | Pixel-buffer and image output become fixture-visible for skin/color/filter while preserving default no-op. | fixture/unit | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEngineTests` | yes | green |
| 06-02-01 | 06-02 | 2 | EFFECT-04, EFFECT-09 | T-06-02 | Face-shape provider output is capped, compound weakened, and skipped without usable face contour. | unit/fixture | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectsTests` | yes | green |
| 06-03-01 | 06-03 | 3 | EFFECT-05, EFFECT-06, EFFECT-09 | T-06-03 | Eye and nose providers skip only missing groups and keep coordinate-derived output internal. | unit/fixture | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectsTests` | yes | green |
| 06-04-01 | 06-04 | 4 | EFFECT-07, EFFECT-09 | T-06-04 | Mouth provider and lip color skip missing mouth landmarks and avoid raw geometry in public warnings/metrics. | unit/fixture | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectsTests` | yes | green |
| 06-05-01 | 06-05 | 5 | EFFECT-01, EFFECT-04, EFFECT-05, EFFECT-06, EFFECT-07, EFFECT-09 | T-06-05 | Combined no-face, stale, cap, preset, Demo copy, docs, and static-scan evidence close the phase without leaking internals. | full/static | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` | yes | green |

All task rows are green after the 2026-06-23 validation audit.

---

## Wave 0 Requirements

Existing infrastructure covers the phase enough to start:

- `BeautySDK/Tests` runs with XCTest through SwiftPM.
- `BeautyDemo/BeautyDemoTests` runs with Xcode simulator XCTest.
- `BeautyEngineTests` already has reusable BGRA and CI image fixture helpers.
- `CopyRenderPassTests` already has a RenderGraph ordering seam and BGRA fixture helpers.
- Demo import-boundary and privacy scans exist and must be preserved.

Phase 6 added required infrastructure:

- [x] `BeautyEffectsTests` target in `BeautySDK/Package.swift`.
- [x] Deterministic effect-plan and fixture helpers for caps, provider output, warnings, metrics, and pixel deltas.
- [x] Focused Demo tests that remove the old Phase 6 status copy and cover existing panel paths.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Naturalness of fixture-visible output | EFFECT-01, EFFECT-04, EFFECT-05, EFFECT-06, EFFECT-07, EFFECT-09 | Automated pixel deltas prove output changed, not whether it looks natural. | Inspect the fixed fixture outputs or simulator preview after applying medium values and the five built-in presets; confirm output is visible but conservative. |
| Panel clipping after stale copy removal | EFFECT-01, EFFECT-04, EFFECT-05, EFFECT-06, EFFECT-07 | XCTest view-state covers content, but final layout fit may require screenshot or human visual smoke. | Launch Demo, open Beauty, Face Shape, Eyes, Nose, Mouth, Filters, and Presets; confirm controls fit without clipping or category regression. |
| Real camera/photo visual parity | EFFECT-09 | Unit fixtures cannot prove real Vision quality or device camera mirror behavior. | If hardware is available, process one front-camera frame and one still image with the same preset; confirm both show effects and no crash. |

If manual checks cannot run during execution, record the exact reason in the phase summary and leave the release-like visual QA risk explicit.

---

## Validation Sign-Off

- [x] All planned tasks have automated verify coverage or an explicit manual-only reason.
- [x] Sampling continuity: no three consecutive implementation tasks without automated verify.
- [x] Wave 0 identifies the missing `BeautyEffectsTests` infrastructure.
- [x] No watch-mode flags.
- [x] Feedback latency target documented.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-21; audited green 2026-06-23

## Validation Audit 2026-06-23

| Metric | Count |
|--------|-------|
| Task rows audited | 6 |
| Green rows | 6 |
| Wave 0 items complete | 8 |
| Escalated manual-only items | 0 |

Evidence:

- `swift test --package-path BeautySDK --filter BeautyEffectsTests`, `--filter BeautyEngineTests`, `--filter CombinedEffectSafetyTests`, and `--filter MissingLandmarkDegradationTests` passed during Phase 6 closeout.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 119 tests during the v1.0 milestone audit run.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed during the v1.0 milestone audit run.
- `06-VERIFICATION.md` records `EFFECT-01`, `EFFECT-04`, `EFFECT-05`, `EFFECT-06`, `EFFECT-07`, and `EFFECT-09` as passed.
