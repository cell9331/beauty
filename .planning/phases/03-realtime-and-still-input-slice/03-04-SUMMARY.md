---
phase: "03-realtime-and-still-input-slice"
plan: "03-04"
subsystem: "privacy-verification"
tags: ["privacy", "purpose-strings", "xctest", "static-scans", "docs"]
requires:
  - phase: "03-01"
    provides: "Camera permission and AVFoundation frame capture shell"
  - phase: "03-02"
    provides: "Bounded realtime SDK invocation without UIImage conversion"
  - phase: "03-03"
    provides: "Still-image input, processing, loading, and compare states"
provides:
  - "Machine-checkable local-first Camera/Photo purpose strings"
  - "No-upload/no-network/raw-path/raw-error input-source scans"
  - "Facade-only Demo and Demo test import scans"
  - "Final Camera/Photo state-matrix XCTest evidence"
  - "Root contract docs and quality ledger synchronized with Phase 3 evidence"
affects: ["03-complete", "PIPE-08", "DEMO-01", "quality", "privacy"]
tech-stack:
  added: ["XCTest source/project scans"]
  patterns: ["deterministic repo-root discovery from #filePath", "static privacy tests", "owner-doc evidence sections"]
key-files:
  created:
    - "BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift"
  modified:
    - "BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift"
    - "BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift"
    - "FRONTEND.md"
    - "SECURITY.md"
    - "RELIABILITY.md"
    - "PRODUCT_SENSE.md"
    - "QUALITY_SCORE.md"
    - "PLANS.md"
    - ".planning/ROADMAP.md"
    - ".planning/REQUIREMENTS.md"
    - ".planning/STATE.md"
    - ".planning/phases/03-realtime-and-still-input-slice/03-04-PLAN.md"
key-decisions:
  - "Privacy gates use deterministic source and project-file scans instead of simulator permission automation."
  - "Real Camera/Photos picker round trips remain manual OS-owned smoke checks; value and pipeline behavior is automated."
  - "Quality scores are raised only where Phase 3 has test or static-scan evidence."
patterns-established:
  - "Final phase evidence is recorded in owner root docs without duplicating implementation rules."
  - "Dirty root docs require selective staging so unrelated local changes are not committed."
requirements-completed: ["PIPE-08"]
requirements-confirmed: ["PIPE-01", "PIPE-02", "PIPE-03", "PIPE-04", "PIPE-06", "DEMO-01"]
duration: "45min"
completed: "2026-06-12"
---

# Plan 03-04 Summary

**Phase 3 now has machine-checkable privacy gates, final state-matrix coverage, and synced contract evidence for the local-first Camera/Photo input slice.**

## Performance

- **Duration:** 45 min
- **Started:** 2026-06-12T16:15:36+0800
- **Completed:** 2026-06-12T16:56:55+0800
- **Tasks:** 3
- **Files modified:** 13

## Accomplishments

- Added `InputPipelinePrivacyTests` to verify Debug/Release generated Info.plist Camera/Photo purpose strings, local-first input paths, no realtime `UIImage`, and facade-only imports.
- Expanded `BeautyDemoImportBoundaryTests` so Demo source and Demo tests fail if they import internal SDK targets.
- Expanded `BeautyDemoViewStateTests` with a Phase 3 state matrix for initial, Camera requesting/blocked/unavailable/running, and Photo empty/loading/loaded/failed states.
- Updated root contract docs with Phase 3 evidence in their owning areas: UI states, security/privacy, reliability, product acceptance, quality scoring, and plan ledger.
- Updated `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, and the 03-04 plan status to show Phase 3 complete and Phase 4 ready.

## Task Commits

1. **Input privacy gates and state-matrix tests** - `547b9ac` (test)

The documentation and planning evidence are staged separately from the test implementation so root-doc updates can avoid unrelated dirty changes.

## Files Created/Modified

- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` - Source/project scan coverage for PIPE-08, D-09, D-13, facade-only imports, and no realtime `UIImage`.
- `BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift` - Expanded public facade import scan across Demo source and tests.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` - Final Camera/Photo state matrix coverage for PIPE-01, PIPE-04, PIPE-06, PIPE-08, and DEMO-01.
- `FRONTEND.md` - Recorded implemented Camera/Photo UI state evidence.
- `SECURITY.md` - Recorded purpose strings and local-first static scan evidence.
- `RELIABILITY.md` - Recorded backpressure, stale-work, and previous-visual preservation evidence.
- `PRODUCT_SENSE.md` - Recorded Phase 3 acceptance evidence for realtime and still-image journeys.
- `QUALITY_SCORE.md` - Refreshed scores based on observed Phase 3 test and scan evidence.
- `PLANS.md` - Added Phase 3 completion ledger entry.
- `.planning/*` - Marked Phase 3 / 03-04 complete and Phase 4 ready.

## Decisions Made

Privacy and protected-resource behavior are verified through deterministic project/source scans because OS permission sheets, Settings round trips, and real Photos picker selection are brittle as unit automation. Those OS-owned flows remain manual smoke checks, while the state transitions and pipeline behavior are automated.

Scores in `QUALITY_SCORE.md` were raised only where there is direct test or scan evidence. Realtime Camera and Still Image Editing moved to score 3; `BeautyDemo`, Tests, Security, and Product acceptance improved; Reliability remains score 3 because metrics, long-run performance, and hardware smoke checks are still missing.

## Deviations from Plan

None. Scope stayed within final privacy/static tests, evidence docs, and GSD state sync.

## Issues Encountered

Initial focused XCTest compilation failed because Swift could not infer generic result types for throwing `flatMap` scans in `InputPipelinePrivacyTests`. The scan helpers were rewritten as explicit loops, and the focused test run passed.

GSD `state update-progress` rewrote the frontmatter percent incorrectly while leaving the body progress stale. `.planning/STATE.md` was manually corrected to `completed_plans: 11`, Phase 3 `4/4`, and 100% for generated Phase 1-3 plan execution.

## Verification

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer /usr/bin/xcrun simctl list devices available`
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/InputPipelinePrivacyTests -only-testing:BeautyDemoTests/BeautyDemoImportBoundaryTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests test`
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK`
- `rg -n "NSCameraUsageDescription|NSPhotoLibraryUsageDescription|Use the camera to preview beauty processing on this device|Select photos to preview beauty processing on this device" BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`
- `rg -n "UIImage" BeautySDK/Sources BeautyDemo/BeautyDemo`
- `rg -n "import Beauty(Core|Render|Detection|Effects|Resources)" BeautyDemo BeautyDemo/BeautyDemoTests`
- `rg -n "URLSession|http://|https://|upload|/private/var|NSError|AVError" BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor BeautyDemo/BeautyDemo/Support`

Result: simulator discovery listed iPhone 17 on iOS 26.5. Focused XCTest passed with 18 tests. Full Demo simulator XCTest passed with 55 tests. SDK SwiftPM tests passed with 20 tests. Purpose strings were found in Debug and Release. The `UIImage`, internal import, and network/raw-copy scans returned no matches.

## User Setup Required

None for automated checks. Manual UAT still needs real hardware/simulator camera behavior, Settings permission round trip, and real Photos picker selection.

## Next Phase Readiness

Phase 4 can start detection and coordinate safety work. The input slice now provides explicit orientation metadata, fixture/still-image seams, local-first privacy gates, and state-preserving Camera/Photo behavior for later face detection and effect work.

---
*Phase: 03-realtime-and-still-input-slice*
*Completed: 2026-06-12*
