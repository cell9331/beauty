---
phase: 07
slug: rich-demo-qa-surface
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-22
audited: 2026-06-23
---

# Phase 07 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via Xcode and SwiftPM |
| **Config file** | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `BeautySDK/Package.swift` |
| **Quick run command** | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyParameterStoreTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests -only-testing:BeautyDemoTests/CompareStateTests -only-testing:BeautyDemoTests/InputPipelinePrivacyTests` |
| **Demo suite command** | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` |
| **SDK suite command** | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` |
| **Estimated runtime** | Focused Demo tests under 180 seconds where possible; full Demo simulator plus SDK SwiftPM tests may take several minutes based on simulator state |

---

## Sampling Rate

- **After JSON/store tasks:** Run focused `BeautyParameterStoreTests` and any new JSON import/export tests.
- **After preview/debug tasks:** Run focused `CompareStateTests`, `BeautyDemoViewStateTests`, and any new debug overlay tests.
- **After QA/privacy tasks:** Run `InputPipelinePrivacyTests`, `BeautyDemoImportBoundaryTests`, and static scans for internal imports and raw debug/JSON tokens.
- **After every wave:** Run the focused Demo command plus the Demo facade-only import scan.
- **Before `$gsd-verify-work`:** Run full Demo simulator tests, full SDK SwiftPM tests, JSON/debug/privacy scans, requirements/decision coverage checks, and `git diff --check`.
- **Max feedback latency:** Keep focused commands under about 180 seconds where possible; record exact Xcode/simulator failures instead of marking them green.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 07-01-01 | 07-01 | 1 | DEMO-06 | T-07-01 | Parameter JSON decode validates schema and filter IDs before preview/apply, and failed imports do not mutate current state. | unit | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyParameterStoreTests` | yes | green |
| 07-01-02 | 07-01 | 1 | DEMO-06 | T-07-01 | Export emits only `schemaVersion` plus `parameters` and round-trips deterministically. | unit/static | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/ParameterJSONCodingTests` | yes | green |
| 07-01-03 | 07-01 | 1 | DEMO-06 | T-07-02 | Preset, imported, custom, single-reset, reset-all, and filter-source transitions are explicit and testable. | unit | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyParameterStoreTests` | yes | green |
| 07-02-01 | 07-02 | 2 | DEMO-07 | T-07-03 | Debug overlay is read-only and exposes only redacted detection summary, counts, timings, warning count, frame status, and redacted error code/status. | unit/static | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyDemoViewStateTests -only-testing:BeautyDemoTests/CompareStateTests -only-testing:BeautyDemoTests/InputPipelinePrivacyTests` | yes | green |
| 07-02-02 | 07-02 | 2 | DEMO-07 | T-07-03 | Compare and debug toggles do not mutate parameters, compare output selection unexpectedly, detection state, or SDK output. | unit | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/CompareStateTests` | yes | green |
| 07-02-03 | 07-02 | 2 | DEMO-07 | T-07-04 | Implemented and future categories keep existing ordering and disabled/future copy remains short and explicit. | unit | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyDemoViewStateTests` | yes | green |
| 07-03-01 | 07-03 | 3 | DEMO-06, DEMO-07 | T-07-05 | Final scans prove Demo uses the public facade only and active JSON/debug surfaces do not expose raw paths, raw errors, geometry, raw JSON dumps, network, or upload behavior. | full/static | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test && CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` | yes | green |
| 07-03-02 | 07-03 | 3 | DEMO-06, DEMO-07 | T-07-06 | Requirements, roadmap, root docs, quality score, and `PLANS.md` are updated only after tests pass, and release-grade manual risks remain explicit. | docs/static | `git diff --check -- BeautyDemo BeautySDK ARCHITECTURE.md DESIGN.md FRONTEND.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md .planning` | yes | green |

All task rows are green after the 2026-06-23 validation audit.

---

## Wave 0 Requirements

Existing infrastructure covers the phase enough to start after the UI-SPEC gate is resolved:

- `BeautyDemo/BeautyDemoTests` already has deterministic XCTest seams for parameter state, view state, compare state, privacy scans, and import-boundary scans.
- `BeautySDK/Tests` already covers public parameter codability, preset decoding, resource validation, engine output, detection summaries, and effects.
- `BeautySDKResources.validate(parameters:)` is already available through the public facade for Demo filter-ID validation.
- `InputPipelinePrivacyTests` already has reusable source-scan helpers.

Phase 7 added or extended:

- [x] Demo-side parameter JSON envelope/coding tests.
- [x] Import preview/apply/failure non-mutation tests.
- [x] Source-state transition tests for preset/imported/custom/reset/filter changes.
- [x] Read-only debug overlay view-state tests.
- [x] JSON/debug privacy scans.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Final visual naturalness | DEMO-06, DEMO-07 | Automated tests prove workflows and deterministic state, not release-grade beauty quality. | Inspect fixed fixtures or simulator preview with defaults, a built-in preset, imported JSON, and compare/debug toggles; record whether output is visibly conservative. |
| Real-device camera and Vision parity | DEMO-07 | Simulator and fixtures cannot prove hardware mirroring, real Vision quality, or long-run behavior. | On a physical iPhone, run front-camera preview, no-face, partial-face, and low-light checks; confirm debug/status stays privacy-safe and non-crashing. |
| Long-run hardware readiness | DEMO-07 | Current automated suite does not run 10-minute memory/thermal checks. | If hardware is available, run realtime preview for 10 minutes and record dropped-frame/memory observations; otherwise leave as release risk. |

If manual checks cannot run during execution, record the exact reason in the phase summary and keep the release-like visual/hardware QA risk explicit.

---

## Validation Sign-Off

- [x] All planned tasks have automated verify coverage or an explicit manual-only reason.
- [x] Sampling continuity: no three consecutive implementation tasks without automated verify.
- [x] Wave 0 covers existing infrastructure and missing Phase 7 test seams.
- [x] No watch-mode flags.
- [x] Feedback latency target documented.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-22; audited green 2026-06-23

## Validation Audit 2026-06-23

| Metric | Count |
|--------|-------|
| Task rows audited | 8 |
| Green rows | 8 |
| Wave 0 items complete | 9 |
| Escalated manual-only items | 0 |

Evidence:

- Focused Phase 7 Demo tests passed for `BeautyParameterStoreTests`, `ParameterJSONCodingTests`, `BeautyDemoViewStateTests`, `CompareStateTests`, `InputPipelinePrivacyTests`, and `BeautyDemoImportBoundaryTests`.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed during the v1.0 milestone audit run.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 119 tests during the v1.0 milestone audit run.
- `07-VERIFICATION.md` records `DEMO-06` and `DEMO-07` as verified, and `07-HUMAN-UAT.md` records 4/4 human-visible checks passed.
