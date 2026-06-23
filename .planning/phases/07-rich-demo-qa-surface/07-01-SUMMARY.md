---
phase: 07-rich-demo-qa-surface
plan: 07-01
subsystem: ios-demo
tags: [swiftui, xctest, parameter-json, presets, reset, privacy]

requires:
  - phase: 06-core-beauty-effects
    provides: SDK-backed visible Demo parameters, presets, filters, and quiet parameter status
provides:
  - Deterministic schemaVersion 1 parameter JSON export/import preview
  - Imported, preset, and custom parameter source semantics
  - Preview-toolbar Parameter JSON sheet with copy/paste import/export
affects: [07-rich-demo-qa-surface, demo-qa, parameter-workflows]

tech-stack:
  added: []
  patterns:
    - Demo-side JSON envelope around public BeautyParameters
    - Enum-driven SwiftUI sheet presentation
    - XCTest view-state seams for sheet copy and apply gating

key-files:
  created:
    - BeautyDemo/BeautyDemo/State/ParameterJSONCoding.swift
    - BeautyDemo/BeautyDemo/Editor/ParameterJSONSheetView.swift
    - BeautyDemo/BeautyDemoTests/ParameterJSONCodingTests.swift
  modified:
    - BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift
    - BeautyDemo/BeautyDemo/Editor/EditorShellView.swift
    - BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift
    - BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift
    - BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift

key-decisions:
  - "Parameter JSON export serializes the current normalized snapshot without facade validation; preview import performs facade validation before Apply."
  - "Imported JSON is explicit source state, not a preset chip or persisted custom preset."
  - "The exact broad privacy rg command includes historical test guard literals, so active State/Editor surfaces are scanned separately for leakage evidence."

patterns-established:
  - "Preview-before-apply JSON import state exposes a candidate only after size, schema, decode, and facade validation pass."
  - "BeautyParameterStore applies preset/import snapshots through a private sync path so user-driven source clearing remains distinct."
  - "Parameter JSON sheet copy is tested through value state instead of simulator UI automation."

requirements-completed: [DEMO-06]

duration: 14h 20m
completed: 2026-06-23
---

# Phase 07 Plan 07-01: Add Preset, Reset, and Parameter JSON Workflows Summary

**Deterministic copy/paste parameter JSON with preview validation, imported/preset/custom source tracking, and reset semantics for the Demo QA surface.**

## Performance

- **Duration:** 14h 20m
- **Started:** 2026-06-22T10:39:35Z
- **Completed:** 2026-06-23T01:00:01Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments

- Added `ParameterJSONCoding` with `schemaVersion: 1`, 65,536-byte pre-decode limit, sorted-key deterministic export, redacted import errors, and `BeautySDKResources.validate(parameters:)` preview validation.
- Added `BeautyParameterSource` plus imported apply behavior so preset, import, manual slider/filter edits, single reset, and reset all have explicit tested semantics.
- Added a preview-toolbar `Parameter JSON` sheet with Import/Export modes, preview-before-apply gating, copy/paste-only UI, and photo reprocessing after valid Apply.

## Task Commits

1. **Task 1 RED:** `935e434` test(07-01): add failing parameter JSON coding coverage
2. **Task 1 GREEN:** `a0920a7` feat(07-01): implement deterministic parameter JSON coding
3. **Task 2 RED:** `e8204c0` test(07-01): add failing store source semantics coverage
4. **Task 2 GREEN:** `2ebb03b` feat(07-01): add parameter source and imported reset semantics
5. **Task 3 RED:** `9a68db1` test(07-01): add failing parameter JSON sheet coverage
6. **Task 3 GREEN:** `9d162b8` feat(07-01): wire parameter JSON sheet into preview toolbar

## Files Created/Modified

- `BeautyDemo/BeautyDemo/State/ParameterJSONCoding.swift` - Demo-side JSON envelope, import state, redacted errors, deterministic export, and validated preview import.
- `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` - Source tracking and imported snapshot application.
- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` - Enum-driven sheet presentation and preview toolbar action.
- `BeautyDemo/BeautyDemo/Editor/ParameterJSONSheetView.swift` - SwiftUI copy/paste Import/Export sheet.
- `BeautyDemo/BeautyDemoTests/ParameterJSONCodingTests.swift` - JSON round-trip, failure, size, schema, and unknown-filter coverage.
- `BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift` - Source/reset/import/preset transition coverage.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` - Toolbar and sheet copy/apply gating coverage.
- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` - Active JSON surface local-first/copy-paste privacy scan.

## Decisions Made

- Export does not reject an otherwise serializable current snapshot with an unknown filter; import preview is the trust boundary that validates pasted payloads before Apply.
- The JSON sheet uses `UIPasteboard` only for the explicit copy action; no file picker, share sheet, persistence, network, or saved custom preset was added.
- Per the run instruction, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, and `PLANS.md` were not updated by this plan.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The exact plan-level broad scan `rg -n "URLSession|http://|https://|upload|DocumentPicker|fileImporter|fileExporter|rawPresetJson|/private/var|NSError" BeautyDemo/BeautyDemo/State BeautyDemo/BeautyDemo/Editor BeautyDemo/BeautyDemoTests` reports existing test guard literals and assertions only. The active production-surface scan over `BeautyDemo/BeautyDemo/State` and `BeautyDemo/BeautyDemo/Editor` returned no matches, and `InputPipelinePrivacyTests.testDEMO06ParameterJSONSurfacesStayLocalFirstAndCopyPasteOnly` passed.
- Xcode emitted pre-existing actor-isolation warnings from `CameraBeautyPipelineTests` while compiling the focused test target; no 07-01 test failed.

## Verification

- PASS: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -quiet -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyParameterStoreTests -only-testing:BeautyDemoTests/ParameterJSONCodingTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests -only-testing:BeautyDemoTests/InputPipelinePrivacyTests`
- PASS: `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests || true` returned no matches.
- PASS with expected test-guard matches: broad forbidden-token scan reported only existing XCTest guard literals/assertions, not active production code.
- PASS: active forbidden-token scan over `BeautyDemo/BeautyDemo/State BeautyDemo/BeautyDemo/Editor` returned no matches.
- PASS: `rg -n "Parameter JSON|Preview Parameter JSON|Apply Imported Parameters|Copy Parameter JSON|Current settings stay unchanged" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` found expected sheet/test copy.
- PASS: `git diff --check --` for all 07-01 touched production/test files returned no output.

## Known Stubs

None. Stub-pattern scan only matched legitimate optional `nil` defaults, empty local arrays in test helpers, and empty sheet text state.

## Threat Flags

None. No new network endpoints, auth paths, file access patterns, schema migrations, or SDK trust-boundary expansion were introduced.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for `07-02` compare/debug overlay and unavailable-state polish. Remaining release-like visual naturalness, real-device camera/Vision parity, and long-run hardware checks stay outside 07-01 and remain Phase 7 closeout risks.

## Self-Check: PASSED

- Found created files: `BeautyDemo/BeautyDemo/State/ParameterJSONCoding.swift`, `BeautyDemo/BeautyDemo/Editor/ParameterJSONSheetView.swift`.
- Found commits: `935e434`, `a0920a7`, `e8204c0`, `2ebb03b`, `9a68db1`, `9d162b8`.
- No unexpected tracked-file deletions in 07-01 commits.
- Summary created at `.planning/phases/07-rich-demo-qa-surface/07-01-SUMMARY.md`.

---
*Phase: 07-rich-demo-qa-surface*
*Completed: 2026-06-23*
