---
phase: 41-public-contract-and-observed-eye-support
plan: "01"
subsystem: core-model
tags: [swift, codable, compatibility, eye-parameters]

# Dependency graph
requires:
  - phase: 40-mouth-safety-ledger-closeout
    provides: 38-field BeautyParameters compatibility baseline and shipped eye provider behavior
provides:
  - Ten independently stored, default-zero eye geometry scalars with finite normalization
  - 48-field Codable/source compatibility and neutral shipped-eye regression evidence
affects: [phase-41-plan-02, phase-41-plan-03, phase-42-eye-geometry]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Reuse clampUnit/clampSigned across initializer, decoder, normalized copy, and tests
    - Defaulted Codable keys preserve legacy payload neutrality

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift

key-decisions:
  - "Store exactly ten named eye fields after the shipped eye controls; keep all initializer arguments defaulted to zero."
  - "Keep provider transforms deferred to Phase 42; the zero-default regression compares only the existing four shipped eye fields."

patterns-established:
  - "Public eye scalars use finite clampUnit for nine positive-only values and clampSigned for eyeTilt."
  - "Legacy compatibility is proven by removing ten keys from a complete payload and decoding the resulting 38-key shape."

requirements-completed: [EYE-01, EYE-02, EYE-03, EYE-04]

coverage:
  - id: D1
    description: "BeautyParameters exposes ten independent default-zero eye scalars with finite normalization and a 48-field reflected inventory."
    requirement: EYE-01
    verification:
      - kind: unit
        ref: "BeautyCoreTests.BeautyParametersTests.testEYE01NewPositiveOnlyInputsNormalizeIndependently"
        status: pass
      - kind: unit
        ref: "BeautyCoreTests.BeautyParametersTests.testEYE02EyeTiltNormalizesSignedValuesAndBothDirections"
        status: pass
      - kind: unit
        ref: "BeautyCoreTests.BeautyParametersTests.testEYE03InventoryContainsExactlyTenIndependentEyeFields"
        status: pass
    human_judgment: false
  - id: D2
    description: "Legacy 38-key payloads remain neutral and complete 48-field unequal values round-trip independently."
    requirement: EYE-03
    verification:
      - kind: unit
        ref: "BeautyCoreTests.BeautyParametersTests.testEYE03Legacy38FieldJSONDecodesTenNewFieldsAsZero"
        status: pass
      - kind: unit
        ref: "BeautyCoreTests.BeautyParametersTests.testEYE03All48FieldsRoundTripUnequalEyeValuesWithoutAliasing"
        status: pass
    human_judgment: false
  - id: D3
    description: "Zero-valued new fields preserve the existing four shipped eye provider control points and values."
    requirement: EYE-04
    verification:
      - kind: unit
        ref: "BeautyEffectsTests.EyeWarpProviderTests.testZeroNewEyeFieldsPreserveShippedProviderControlPoints"
        status: pass
      - kind: other
        ref: "swift test --package-path BeautySDK (273 tests, 0 failures)"
        status: pass
    human_judgment: false

# Metrics
duration: 7min
completed: 2026-07-16
status: complete
---

# Phase 41 Plan 01: Public Eye Scalar Contract Summary

**Ten default-zero eye controls now share the existing normalized Codable model, with 38-key legacy neutrality, exact 48-field round-trip coverage, and a shipped-eye provider regression.**

## Performance

- **Duration:** 7 min
- **Started:** 2026-07-16T03:47:11Z
- **Completed:** 2026-07-16T03:54:11Z
- **Tasks:** 2 (with TDD RED/GREEN commits for Task 1)
- **Files modified:** 3

## Accomplishments

- Added `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, `eyeTilt`, `innerCornerOpen`, `outerCornerOpen`, and `eyeSymmetry` as independent stored fields with default-zero source initialization and missing-key decoding.
- Wired all ten fields through `CodingKeys`, normalization, and synthesized Codable to produce exactly 48 stored/encoded fields (47 numeric plus `filterId`).
- Added table-driven finite/range/normalized-copy tests, 38-key legacy decode neutrality, unequal 48-field round-trip tests, and a neutral provider control-point regression.

## Task Commits

1. **Task 41-01-01: Add the ten defaulted normalized stored fields** - `ae2770f` (test RED), `ae28d02` (feat GREEN)
2. **Task 41-01-02: Prove inventory, legacy compatibility, independence, and neutral eye behavior** - `6426d85` (test)

## Files Created/Modified

- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` - ten public fields and all initializer/Codable/normalization seams.
- `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` - range, inventory, legacy decode, source compatibility, and round-trip contracts.
- `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` - zero-default shipped-eye output regression.

## Decisions Made

- Existing initializer ordering is preserved; new labeled arguments follow the shipped eye fields and default to zero.
- No provider transforms or public geometry/support types were added; those remain deferred to Phase 42 and later Phase 41 plans.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Updated stale 38-field expectations to the new locked 48-field contract**
- **Found during:** Task 41-01-01 GREEN verification
- **Issue:** Existing Phase 38 tests still asserted 38 reflected/encoded fields after the planned model expansion.
- **Fix:** Updated the three inventory/key-count assertions to 48; legacy 33-key compatibility assertions remain unchanged.
- **Files modified:** `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift`
- **Verification:** Focused parameter suite passed 28/28 and full SwiftPM suite passed 273/273.
- **Committed in:** `ae28d02`

**2. [Rule 3 - Blocking] Rebuilt SwiftPM artifacts after stale incremental linkage**
- **Found during:** Task 41-01-01 GREEN verification
- **Issue:** The first incremental test link retained the pre-expansion initializer symbol and failed to link `BeautyExampleRenderer`.
- **Fix:** Ran `swift package --package-path BeautySDK clean`, then reran the focused suite; the subsequent build linked successfully.
- **Files modified:** None (build artifacts are ignored).
- **Verification:** Focused suites and full `swift test --package-path BeautySDK` passed.
- **Committed in:** No source commit; build-only recovery.

**Total deviations:** 2 auto-fixed (Rule 1: 1; Rule 3: 1)
**Impact on plan:** Both fixes were directly required by the field-count expansion and did not broaden Phase 41 scope.

## Issues Encountered

- The first clean rebuild briefly emitted a parallel SwiftPM `no such module: BeautySDK` test compile error; rerunning the same focused command completed normally. No source issue remained.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

The public scalar contract and neutral shipped-eye behavior are ready for Plan 41-02 to thread private observed contour/pupil support. New provider transforms remain explicitly deferred to Phase 42.

---
*Phase: 41-public-contract-and-observed-eye-support*
*Completed: 2026-07-16*

## Self-Check: PASSED

- Summary file exists and records all two tasks, three commits, and verification evidence.
- `git diff --check` is clean; focused BeautyParameters/EyeWarpProvider tests and full SwiftPM suite passed.
- No TODO/FIXME/placeholder stubs were introduced in modified files.
