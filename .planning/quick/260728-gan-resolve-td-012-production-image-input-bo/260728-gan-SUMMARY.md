---
phase: quick-260728-gan
plan: 01
status: complete
subsystem: input-security
tags: [swift, core-image, core-video, photos-picker, input-validation]
requires:
  - phase: current-state-consolidation
    provides: TD-012 production image input-bound decision
provides:
  - Source-compatible public encoded-byte and decoded-pixel ceilings
  - Fail-fast SDK CIImage and CVPixelBuffer validation
  - Demo pre-decode and pre-processing input rejection with recovery
affects: [security, reliability, still-image-input, public-configuration]
tech-stack:
  added: []
  patterns: [division-based overflow-safe dimension checks, shared configuration snapshot]
key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
    - BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift
    - BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift
    - SECURITY.md
    - PLANS.md
key-decisions:
  - "Default encoded input ceiling is 33,554,432 bytes and decoded input ceiling is 50,000,000 pixels."
  - "Over-limit inputs reuse BeautyError.invalidInput and are rejected rather than resized or downsampled."
  - "PhotosPicker pre-transfer allocation remains an explicit residual because Data is materialized before its size is observable."
patterns-established:
  - "Input dimensions are compared by division after positive/finite validation so pixel-count multiplication cannot overflow."
  - "The Demo derives byte and pixel bounds plus its production processor from one BeautyConfiguration snapshot."
requirements-completed: [TD-012]
duration: 14min
completed: 2026-07-28
---

# Quick Task 260728-gan: Production Image Input Bounds Summary

**Public 32 MiB encoded and 50,000,000-pixel ceilings now reject oversized SDK and Demo image inputs before available expensive work while preserving compatibility and recoverable photo state.**

## Performance

- **Duration:** 14 min
- **Started:** 2026-07-28T03:51:39Z
- **Completed:** 2026-07-28T04:06:03Z
- **Tasks:** 3
- **Files modified:** 14

## Accomplishments

- Added trailing defaulted public limits with non-positive normalization, current JSON round-trip, and legacy missing-key decoding.
- Added overflow-safe exact/one-over gates to both SDK input families before resource validation, detection, copy, or rendering.
- Added Demo pre-decode byte and pre-processing pixel gates with previous-snapshot preservation, friendly recovery, and stale-generation isolation.
- Synchronized current design, security, reliability, product, quality, planning, and state owners; TD-012 is complete without activating a milestone.

## Task Commits

1. **Task 1 RED: SDK boundary contracts** - `e116141` (test)
2. **Task 1 GREEN: Public limits and SDK enforcement** - `6057c23` (feat)
3. **Task 2 RED: Demo boundary contracts** - `4915067` (test)
4. **Task 2 GREEN: Demo pipeline enforcement** - `5bb11ba` (feat)
5. **Task 2 refactor: Explicit shared configuration linkage** - `1ac8835` (refactor)
6. **Task 3: Contract and ledger synchronization** - `5638ea9` (docs)

Quick planning artifacts and `.planning/STATE.md` remain uncommitted for the orchestrator's final docs commit.

## Verification

- Focused SDK: 23/23 passed.
- Focused `ImageEditorPipelineTests`: 12/12 passed on iPhone 17e / iOS 26.5.
- Full SwiftPM: 457 tests executed, six expected skips, zero failures.
- Full `BeautyDemo`: 118/118 passed on iPhone 17e / iOS 26.5.
- `git diff --check` and the required current-owner/obsolete-claim scans passed.

## Files Created/Modified

- `BeautyConfiguration.swift` - Public byte/pixel ceilings and compatible decoding.
- `BeautyEngine.swift` - Fail-fast, division-based CIImage/CVPixelBuffer validation.
- `BeautyConfigurationTests.swift`, `BeautyEngineTests.swift` - Default/custom/legacy and exact/one-over/order/arithmetic evidence.
- `ImageInputModels.swift`, `ImageEditorPipeline.swift` - Shared bounds snapshot, byte guard, decoded-extent guard, and aligned production processor configuration.
- `ImageEditorPipelineTests.swift` - Spy-backed no-decode/no-process/no-render, recovery, and stale-work evidence.
- `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md`, `.planning/STATE.md` - Routed current contracts and closure evidence.

## Decisions Made

- Kept `BeautyError` unchanged because callers can recover from all invalid/oversized inputs through the existing `invalidInput` case.
- Kept PhotosPicker on `loadTransferable(Data.self)` and documented that only post-transfer decode/render amplification is bounded.
- Raised Security from 3 to 4 only after focused and full automated verification passed; Reliability remains 3 and all hardware/600-second/screenshot/readiness limitations remain.

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None.

## Issues Encountered

The test commands continued running after their initial tool yield; completion was awaited and final XCTest/xcresult counts were recorded only after the processes finished.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- TD-012 is complete and no longer a live concern.
- TD-013 remains unchanged as the next explicit public API decision candidate.
- The repository remains without an active milestone and awaits explicitly scoped `$gsd-new-milestone` work.

## Self-Check: PASSED

All 15 implementation/contract/summary files exist, all six task commits are present, and diff hygiene passes.

---
*Quick task: 260728-gan*
*Completed: 2026-07-28*
