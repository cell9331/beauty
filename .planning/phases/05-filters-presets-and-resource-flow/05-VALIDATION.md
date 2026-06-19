---
phase: 05
slug: filters-presets-and-resource-flow
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-19
---

# Phase 05 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via SwiftPM and Xcode |
| **Config file** | `BeautySDK/Package.swift`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` |
| **Quick run command** | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` |
| **Full suite command** | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` |
| **Estimated runtime** | ~60 to 180 seconds depending on simulator state |

---

## Sampling Rate

- **After every SDK/resource task commit:** Run `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK`.
- **After every Demo UI/store task commit:** Run focused Demo XCTest targets for `BeautyParameterStoreTests`, `BeautyDemoViewStateTests`, and `BeautyCategoryModelTests` when available.
- **After every plan wave:** Run the full SDK test command or focused Demo simulator tests that cover files touched in that wave.
- **Before `$gsd-verify-work`:** Full SDK SwiftPM tests, full Demo simulator tests, Demo internal-import scan, and public resource/path leak scan must be green or have exact environment failure evidence.
- **Max feedback latency:** Keep focused commands under ~180 seconds where possible.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 05-01 | 1 | EFFECT-03, EFFECT-08 | T-05-01 | Bundled manifest and preset JSON decode through `Bundle.module`; invalid schema/resource IDs fail typed. | unit | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` | yes | pending |
| 05-02-01 | 05-02 | 2 | EFFECT-02, EFFECT-03 | T-05-02 | Public facade/resource placeholder APIs expose only stable IDs and typed errors, not raw paths. | unit/static | `rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects|import BeautyResources" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` | yes | pending |
| 05-03-01 | 05-03 | 3 | EFFECT-02, EFFECT-03, EFFECT-08 | T-05-03 | Demo only displays available filter/preset entries and syncs preset values without exposing internal resource errors. | unit/view-state | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyParameterStoreTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests -only-testing:BeautyDemoTests/BeautyCategoryModelTests` | yes | pending |
| 05-04-01 | 05-04 | 4 | EFFECT-02, EFFECT-03, EFFECT-08 | T-05-04 | Final scans prove no internal imports, no raw path/framework leaks, and all Phase 5 requirements are covered by tests/docs. | full/static | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` | yes | pending |

*Status: pending, green, red, flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements:

- `BeautySDK/Tests` already runs with XCTest through SwiftPM.
- `BeautyDemo/BeautyDemoTests` already runs with Xcode simulator XCTest.
- Import-boundary and privacy scans already exist in prior phases and should be preserved or extended.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Visual placement of preset/filter chips | EFFECT-03, EFFECT-08 | XCTest view-state can cover content, but visual spacing requires a human or screenshot audit. | Launch Demo, open `Beauty` and `Filters`, and confirm controls fit without clipping or changing top-level category order. |

---

## Validation Sign-Off

- [x] All tasks have automated verify or existing infrastructure coverage.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify.
- [x] Wave 0 covers all missing references.
- [x] No watch-mode flags.
- [x] Feedback latency target documented.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-19
