---
phase: 38-public-contract-and-lip-support-geometry
plan: "01"
subsystem: public-api
tags: [swift, codable, mouth-geometry, compatibility, safety-caps]

requires:
  - phase: 37-nose-safety-boundary-and-branch-closeout
    provides: Exact 33-field public-model baseline and established provisional-cap compatibility pattern
provides:
  - Five independent public mouth geometry controls with normalized signed or positive-only ranges
  - Exact 38-field source-rebuild and Codable compatibility contract
  - Five zero-default effective strengths and provisional 0.25 cap symbols
  - Unchanged bundled-preset missing-key neutrality evidence
affects: [38-02, 38-03, 38-04, phase-39, phase-40]

tech-stack:
  added: []
  patterns: [defaulted Codable field extension, missing-key zero compatibility, provisional internal safety caps]

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift
    - BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift

key-decisions:
  - "Keep mouthYPosition, mouthTilt, and mouthXPosition as independent signed storage and lipPeakDefinition/lipPlump as independent positive-only storage."
  - "Keep bundled preset JSON unchanged and prove compatibility through missing-key decoding to zero."
  - "Use exact 0.25 internal constants only as provisional Phase 38 caps; Phase 40 retains final calibration ownership."

patterns-established:
  - "Public-model growth updates stored properties, CodingKeys, defaulted initializer arguments, clamp assignments, missing-key decoding, and normalized-copy forwarding together."
  - "Legacy compatibility is locked by a literal complete prior inventory plus exact current encoded inventory tests."

requirements-completed:
  - MOUTH-01
  - MOUTH-02
  - MOUTH-03

duration: 5min
completed: 2026-07-14
---

# Phase 38 Plan 01: Public Contract, Compatibility, and Effective Storage Summary

**Five independent mouth geometry controls now round-trip through an exact 38-field public model with legacy JSON/source/preset neutrality and provisional internal cap symbols.**

## Performance

- **Duration:** 5 min
- **Started:** 2026-07-14T07:23:47Z
- **Completed:** 2026-07-14T07:28:56Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Added `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, and `lipPlump` through all six `BeautyParameters` seams, preserving defaulted source-style construction and missing-key decoding.
- Locked exact normalization, mutable-copy correction, independent storage/equality, literal 33-key legacy decode, and unequal 38-key round-trip behavior in 21 passing parameter tests.
- Added five zero-default effective strengths and provisional `0.25` caps, with all five unchanged bundled presets decoding the new fields to zero.
- Passed the complete SwiftPM suite with 237 tests and no failures.

## Task Commits

Each task was committed atomically:

1. **Task 38-01-01: Add five independent public fields through every BeautyParameters seam** - `1e30d66` (feat)
2. **Task 38-01-02: Add effective storage, provisional caps, and bundled-preset neutrality** - `cfa7a26` (feat)

**Plan metadata:** committed with this summary.

## Files Created/Modified

- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` - Stores, normalizes, decodes, and forwards all five public values.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` - Defines five independent zero-default effective strengths.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` - Defines five provisional `0.25` cap symbols.
- `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` - Verifies ranges, non-finite fallback, mutable normalization, independence, exact inventories, compatibility, and Sendable behavior.
- `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` - Locks the five constants with explicitly provisional wording.
- `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` - Verifies the exact five-preset inventory remains neutral through absent keys.

## Decisions Made

- Canonical field order is the three signed whole-mouth controls followed by the two positive local-lip controls, immediately after `smile` and before `lipColor`.
- Existing preset payloads remain untouched so their absent keys exercise the compatibility path rather than concealing it with explicit zeros.
- The `0.25` constants are provider/resolver inputs for subsequent Phase 38 plans, not final visual calibration claims.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The first incremental focused build linked a stale pre-change initializer symbol. A SwiftPM clean rebuilt the dependency graph; the first clean parallel build then hit a transient test-module ordering error, and the immediate rerun completed normally. All final focused and full-suite runs passed.
- The pre-existing nose round-trip test still asserted the former encoded inventory of 33. It was renamed to current Phase 38 evidence and updated to assert 38 while the new literal 33-key compatibility test preserves the old payload contract.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Public/effective names and provisional cap symbols are ready for Plan 38-03 provider consumption after Plan 38-02 supplies explicit lip supports.
- Provider, resolver, facade-output, final-cap, exhaustive-safety, and promotion work remain deliberately unclaimed.

## Self-Check: PASSED

- All six modified implementation/test files exist.
- Task commits `1e30d66` and `cfa7a26` exist and contain no tracked-file deletion.
- Focused suites, exact structural/preset/scope scans, full 237-test SwiftPM suite, and diff hygiene pass.

---
*Phase: 38-public-contract-and-lip-support-geometry*
*Completed: 2026-07-14*
