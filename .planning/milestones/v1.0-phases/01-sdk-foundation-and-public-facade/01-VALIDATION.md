---
phase: 01
slug: sdk-foundation-and-public-facade
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-10
audited: 2026-06-23
---

# Phase 01 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via Swift Package Manager |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK` |
| **Full suite command** | `swift test --package-path BeautySDK` plus static scans listed below |
| **Estimated runtime** | ~30 seconds after package exists |

Static scans for the full suite:

```bash
rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects|import BeautyResources" BeautyDemo BeautySDK/Tests
rg -n "SwiftUI|UIKit" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautyRender BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyEffects
rg -n "fatalError|try!|as!" BeautySDK/Sources BeautyDemo/BeautyDemo
xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj
```

---

## Sampling Rate

- **After every task commit:** Run `swift test --package-path BeautySDK` once `BeautySDK/Package.swift` exists.
- **After every plan wave:** Run the full suite command above.
- **Before `$gsd-verify-work`:** Full suite must be green or exact environment failures must be recorded.
- **Max feedback latency:** 60 seconds for package tests; Xcode project build evidence may be longer when simulator resolution is required.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01-01 | 1 | SDK-01, SDK-02 | T-01-01 / — | SDK targets contain no UI pages and facade tests import only `BeautySDK`. | package + static | `swift test --package-path BeautySDK` | yes | green |
| 01-02-01 | 01-02 | 1 | SDK-03, SDK-05, SDK-06 | T-01-02 / — | Invalid parameters and preset data are clamped, zeroed, or rejected before rendering with redacted typed errors. | unit | `swift test --package-path BeautySDK` | yes | green |
| 01-03-01 | 01-03 | 2 | SDK-04, SDK-06 | T-01-03 / — | Unsupported inputs return `BeautyError`, not raw framework errors or original input fallback. | unit + fixture | `swift test --package-path BeautySDK` | yes | green |
| 01-04-01 | 01-04 | 3 | SDK-01, SDK-02, SDK-03, SDK-04, SDK-05, SDK-06, SDK-07 | T-01-04 / — | Verification scans reject internal Demo imports, SDK UI dependencies, and release-path crash shortcuts. | full suite | full suite command above | yes | green |

All task rows are green after the 2026-06-23 validation audit.

---

## Wave 0 Requirements

- [x] `BeautySDK/Package.swift` — package manifest with required targets and test targets.
- [x] `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift` — facade import smoke test.
- [x] `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` — defaults, ranges, non-finite, Codable, Equatable, Sendable.
- [x] `BeautySDK/Tests/BeautyCoreTests/BeautyPresetTests.swift` — decode, unknown fields, unknown resource IDs, typed errors.
- [x] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` — init, reset, no-op processing, typed errors.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Local simulator availability for Demo project compile evidence | SDK-01 | Simulator names and OS versions vary by machine. | Run `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj`, then use an explicit available iOS Simulator destination for any Demo build evidence. |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify.
- [x] Wave 0 covers all previously absent references.
- [x] No watch-mode flags.
- [x] Feedback latency < 60s for package tests after package exists.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-23 after milestone audit cleanup

## Validation Audit 2026-06-23

| Metric | Count |
|--------|-------|
| Task rows audited | 4 |
| Green rows | 4 |
| Wave 0 items complete | 5 |
| Escalated manual-only items | 0 |

Evidence:

- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 119 tests during the v1.0 milestone audit run.
- `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- `01-VERIFICATION.md` records Phase 1 requirements `SDK-01` through `SDK-07` as passed.
