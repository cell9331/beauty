---
phase: 04-detection-and-coordinate-safety
plan: 04-05
subsystem: verification-contracts
tags: [privacy, contracts, verification, docs, gsd]
requires:
  - phase: 04-01
    provides: Public metadata/result detection contracts.
  - phase: 04-02
    provides: Internal detector and degradation contracts.
  - phase: 04-03
    provides: Coordinate mapping and mapping failure contracts.
  - phase: 04-04
    provides: Demo metadata propagation and safe status/debug summaries.
provides:
  - Expanded `InputPipelinePrivacyTests` source scan for public detection leakage.
  - Root contract documentation for metadata, summaries, coordinate mapping, privacy, reliability, and product acceptance.
  - Final SDK SwiftPM, Demo XCTest, import-boundary, and public-geometry scan evidence.
  - Phase 4 completion records in `PLANS.md`, `QUALITY_SCORE.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, and `.planning/REQUIREMENTS.md`.
affects: [BeautySDK, BeautyDemo, root-docs, GSD-state]
tech-stack:
  added: []
  patterns: [source privacy scan, geometry-free public summaries, explicit verification ledger, manual residual-risk tracking]
key-files:
  created:
    - .planning/phases/04-detection-and-coordinate-safety/04-05-SUMMARY.md
  modified:
    - BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift
    - ARCHITECTURE.md
    - DESIGN.md
    - FRONTEND.md
    - SECURITY.md
    - RELIABILITY.md
    - PRODUCT_SENSE.md
    - QUALITY_SCORE.md
    - PLANS.md
    - .planning/ROADMAP.md
    - .planning/STATE.md
    - .planning/REQUIREMENTS.md
key-decisions:
  - "Final Phase 4 automated evidence uses SwiftPM, full Demo simulator XCTest, Demo import scan, and public geometry/raw framework/path scan."
  - "Real-device front-camera mirroring and real Vision quality remain manual residual checks, tracked as TD-008 instead of claimed as automated evidence."
patterns-established:
  - "Root docs keep owning facts separated: architecture owns boundaries, design owns public models and coordinate state, security owns forbidden leakage, reliability owns degradation behavior, product sense owns acceptance."
requirements-completed: [PIPE-05, PIPE-07]
duration: 35 min
completed: 2026-06-18
---

# Phase 04 Plan 04-05: Privacy Scans, Contract Docs, and Final Verification Summary

**Phase 4 is closed with synchronized public contracts, privacy scans, and full automated verification evidence**

## Performance

- **Duration:** 35 min
- **Started:** 2026-06-18T07:45:00Z
- **Completed:** 2026-06-18T08:20:00Z
- **Tasks:** 2
- **Files modified:** 12

## Accomplishments

- Added a source-level privacy scan to `InputPipelinePrivacyTests` covering public SDK/Core sources and Demo Camera/Editor status surfaces.
- Confirmed Demo and tests still avoid direct imports of `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, and `BeautyResources`.
- Updated root contracts for:
  - `BeautyInputMetadata` orientation and mirroring flow.
  - Geometry-free `BeautyDetectionSummary` and Demo debug summaries.
  - Canonical `ImageNormalized` coordinate mapping.
  - Safe degraded detection states and UI status behavior.
  - Explicit privacy bans on geometry, raw Vision/framework objects, raw errors, and local paths.
  - Product acceptance and manual residual checks.
- Recorded final Phase 4 evidence in `QUALITY_SCORE.md` and `PLANS.md`.
- Marked Phase 4 complete in GSD roadmap/state/requirements tracking.

## Task Commits

This plan is committed as one closeout unit because it consists of synchronized scans, docs, verification evidence, and state updates.

## Files Created/Modified

- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` - Added public detection source leakage scan and regex helper.
- `ARCHITECTURE.md` - Recorded Vision containment, facade-only metadata/summary exposure, and architecture verification scan.
- `DESIGN.md` - Recorded public metadata, detection summary, coordinate, and degraded-state model contracts.
- `FRONTEND.md` - Recorded Demo metadata flow, status debounce, photo status persistence, and debug-safe UI boundaries.
- `SECURITY.md` - Recorded public summary/debug privacy allowlist and forbidden leakage items.
- `RELIABILITY.md` - Recorded detection degradation matrix, UI debounce/persistence, and Phase 4 evidence.
- `PRODUCT_SENSE.md` - Recorded Phase 4 acceptance criteria and manual real-device checks.
- `QUALITY_SCORE.md` - Recorded final verification commands and updated Phase 4 scores.
- `PLANS.md` - Added Phase 4 completion ledger and `TD-008` manual residual risk.
- `.planning/ROADMAP.md` - Marked Phase 4 5/5 complete.
- `.planning/STATE.md` - Advanced project state to Phase 5 readiness.
- `.planning/REQUIREMENTS.md` - Marked `PIPE-05` and `PIPE-07` complete.

## Decisions Made

- The public leak scan intentionally targets `BeautyCore`, `BeautySDK`, and Demo status surfaces, not internal `BeautyDetection`, because Vision objects and internal geometry are valid only inside the detection target.
- `missingLandmarks` remains an allowed public reason code; the scan rejects public geometry API shapes and raw framework/path leakage rather than banning all reason-code names.
- Manual front-camera and real Vision smoke checks remain recorded in `PLANS.md` as `TD-008`.

## Deviations from Plan

None - plan executed as written.

## Issues Encountered

- Existing root documentation files had unrelated pre-existing dirty changes. Phase 4 closeout edits were kept to additive/targeted contract and evidence sections.

## Verification

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/InputPipelinePrivacyTests test` passed with 8 targeted tests.
- `rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects|import BeautyResources" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 55 XCTest cases.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed with 61 Demo XCTest cases.
- `rg -n "public .*Point|public .*Rect|public .*bounding|public .*landmark|VNFaceObservation|NSError|/private/var" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor` returned no matches.

## User Setup Required

None for automated verification.

## Remaining Manual Checks

- Real-device front-camera preview: confirm mirrored preview matches user expectation while processed output/crop remains stable.
- Real Vision quality smoke: confirm no-face, partial-face, and low-light faces produce the expected status copy with no crash.

## Next Phase Readiness

Phase 5 can plan resource manifests, presets, color/filter controls, and missing-resource behavior on top of a public metadata/result contract that is now documented, tested, and privacy-scanned.

---
*Phase: 04-detection-and-coordinate-safety*
*Completed: 2026-06-18*
