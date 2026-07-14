---
phase: 06-core-beauty-effects
plan: 06-05
subsystem: effects-demo-docs
tags: [combined-effect-safety, no-face-degradation, demo-status, docs, final-verification]
requires:
  - phase: 06-core-beauty-effects
    provides: 06-01 through 06-04 domain effects, safety caps, geometry providers, and missing-landmark degradation.
provides:
  - Combined all-domain cap, weakening, no-face, stale, preset, and redaction evidence.
  - Demo quiet normal parameter status and focused panel-path smoke coverage.
  - Root contract documentation for completed Phase 6 behavior and remaining manual QA risks.
affects: [rich-demo-qa-surface, release-readiness, quality-score, product-acceptance]
tech-stack:
  added: []
  patterns: [combined resolver safety tests, quiet normal demo status, facade-only demo smoke, redacted metadata verification]
key-files:
  created:
    - .planning/phases/06-core-beauty-effects/06-05-SUMMARY.md
    - BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
    - BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift
    - BeautyDemo/BeautyDemo/Support/DemoFixtures.swift
    - BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift
    - BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift
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
    - .planning/REQUIREMENTS.md
    - .planning/STATE.md
key-decisions:
  - "Public BeautyEffectResolver semantics remain backward-compatible for normal engine paths; internal faceGeometry:nil resolution treats nil as explicit no usable face."
  - "Normal Demo parameter, filter, preset, and reset interactions stay quiet now that Phase 6 visual output exists."
  - "Broad raw-token scans are interpreted with scope: policy examples in docs and guard strings in tests are expected, while active Demo/public SDK leak scans must return no matches."
patterns-established:
  - "Use resolver metrics and warnings for cap/skip/weakening evidence instead of normal UI banners."
  - "Keep Demo smoke at deterministic view-state level until Phase 7 adds richer QA UI workflows."
requirements-completed: ["EFFECT-01", "EFFECT-04", "EFFECT-05", "EFFECT-06", "EFFECT-07", "EFFECT-09"]
duration: 18 min
completed: 2026-06-22
---

# Phase 06: Plan 06-05 Summary

**Combined Phase 6 safety and Demo closeout with no-face degradation, quiet normal status, root docs, and final SDK/Demo verification.**

## Performance

- **Duration:** 18 min
- **Started:** 2026-06-22T08:32:58Z
- **Completed:** 2026-06-22T08:50:40Z
- **Tasks:** 2
- **Files modified:** 17

## Accomplishments

- Added `CombinedEffectSafetyTests` for all-domain caps, combined geometry weakening, no-face routing, built-in preset visible evidence, and redacted metadata.
- Updated `BeautyEffectResolver` so internal explicit no-face contexts skip face-dependent domains while keeping color/filter domains active, without changing normal public resolver semantics.
- Removed stale pending-visual copy from normal Demo parameter status; slider, filter, preset, and reset changes now leave `BeautyParameterStore.status` idle.
- Added focused Demo view-state coverage for Beauty, Face Shape, Eyes, Nose, Mouth, Filters, and Presets paths without reordering existing categories.
- Updated root architecture, design, frontend, security, reliability, product, and quality docs for Phase 6 behavior and remaining manual visual/hardware risks.

## Task Commits

1. **Task 1 RED: Combined safety tests** - `8fd1d77` (test)
2. **Task 1 GREEN: No-face combined safety routing** - `2ea230a` (feat)
3. **Task 2 RED: Demo status and panel smoke tests** - `936562a` (test)
4. **Task 2 GREEN: Quiet Demo status after visual effects** - `781ab13` (feat)

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` - Combined cap, no-face, preset, and redaction suite.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` - Explicit no-face routing for internal/test resolution while preserving normal public semantics.
- `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` - Normal parameter interactions now clear to idle status.
- `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift` - Removed unused stale pending-visual fixture copy.
- `BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift` - Store status now asserts quiet normal parameter changes.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` - Added Phase 6 panel-path matrix.
- `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` - Added active Demo source guard against stale pending copy.
- Root docs - Recorded Phase 6 effect ownership, degradation rules, Demo feedback behavior, privacy boundaries, reliability evidence, product acceptance, and updated scores.

## Requirements Addressed

- `EFFECT-01`, `EFFECT-04`, `EFFECT-05`, `EFFECT-06`, and `EFFECT-07` retain final suite coverage for all MVP domains.
- `EFFECT-09` is complete for no-op defaults, conservative visible presets, safety caps, combined weakening, no-face routing, partial-landmark skips, stale/reused degradation, redacted metadata, and Demo quiet/status behavior.

## Decisions Made

- `BeautyEffectResolver.resolve(parameters:)` keeps the existing normal-engine behavior by not treating absent test geometry as a hard no-face condition. The internal/test overload `resolve(parameters:faceGeometry:)` treats `faceGeometry: nil` as an explicit no usable face.
- The Demo no longer uses normal status rows to announce routine parameter application. Detection/degradation copy remains in `DetectionStatusPresentation`.
- Documentation records manual naturalness and hardware smoke as remaining risks because automated pixel/provider evidence proves deterministic change, not final visual taste or real-device detector quality.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Preserved normal public resolver semantics while adding explicit no-face routing**
- **Found during:** Task 1 (combined no-face tests)
- **Issue:** Treating every public `resolve(parameters:)` call as no-face would have skipped skin/color behavior used by existing engine tests.
- **Fix:** Added a private resolver flag so the public API preserves existing semantics, while the internal face-geometry overload treats `nil` as explicit no usable face.
- **Files modified:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`
- **Verification:** `CombinedEffectSafetyTests`, `MissingLandmarkDegradationTests`, `BeautyEngineTests`, `BeautyEffectsTests`, and full `swift test --package-path BeautySDK` passed.
- **Committed in:** `2ea230a`

**2. [Rule 3 - Blocking] Fell back from XcodeBuildMCP to explicit shell xcodebuild**
- **Found during:** Task 2 verification
- **Issue:** XcodeBuildMCP `test_sim` failed to list simulators because its environment could not find `simctl`.
- **Fix:** Ran the planned shell command with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`, which built and tested on `iPhone 17, OS=26.5`.
- **Files modified:** None
- **Verification:** Focused Demo tests and full Demo simulator tests passed.
- **Committed in:** Not applicable

---

**Total deviations:** 2 auto-handled (1 code semantics correction, 1 environment fallback).
**Impact on plan:** The final behavior is stricter for explicit no-face contexts without regressing normal engine behavior; verification evidence is stronger because shell Xcode runs completed.

## Issues Encountered

- Broad raw-token scans return expected matches in policy docs and guard tests. Refined active-surface scans returned no Demo internal imports and no public geometry/raw framework/path leaks.
- Manual visual naturalness, simulator screenshot inspection, real-device front-camera mirroring, and real Vision quality were not performed during this automated phase.

## Verification

- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter CombinedEffectSafetyTests` passed with 4 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` passed with 10 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEngineTests` passed with 9 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectsTests` passed with 45 tests.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/BeautyParameterStoreTests -only-testing:BeautyDemoTests/BeautyDemoViewStateTests -only-testing:BeautyDemoTests/BeautyDemoImportBoundaryTests -only-testing:BeautyDemoTests/InputPipelinePrivacyTests test` passed.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed with 67 Demo XCTest cases.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 119 XCTest cases.
- `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- Exact stale pending-visual Phase 6 copy scan across BeautyDemo, BeautySDK, and root docs returned no matches.
- Public geometry/raw framework/path scan over `BeautySDK/Sources/BeautyCore`, `BeautySDK/Sources/BeautySDK`, `BeautyDemo/BeautyDemo/Camera`, and `BeautyDemo/BeautyDemo/Editor` returned no matches.
- `git diff --check -- BeautySDK BeautyDemo ARCHITECTURE.md DESIGN.md FRONTEND.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md .planning` exited 0.

## User Setup Required

None - no external service configuration required.

## Self-Check: PASSED

- All planned 06-05 tasks have RED and GREEN commits.
- All automated final verification commands passed, with broad-scan scope caveats recorded.
- Root contract docs and GSD state files are updated for Phase 6 closeout.
- `EFFECT-09` is ready to move from pending to complete.

## Next Phase Readiness

Phase 7 can build on a complete MVP effect foundation. Remaining risks are visual QA, production-quality render pass refinement, simulator UI automation, hardware camera/Vision smoke, performance budgets, and long-run reliability.

---
*Phase: 06-core-beauty-effects*
*Completed: 2026-06-22*
