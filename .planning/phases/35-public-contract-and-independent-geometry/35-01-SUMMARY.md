---
phase: 35-public-contract-and-independent-geometry
plan: "01"
subsystem: public-api
tags: [swift, codable, compatibility, nose-geometry, safety-caps]

requires:
  - phase: 34-mouth-safety-degradation-and-ledger-closeout
    provides: stable 31-field public parameter baseline and established geometry safety patterns
provides:
  - independent public noseRootNarrowing and noseTipLift storage across every BeautyParameters seam
  - backward-compatible 31-field JSON and bundled-preset decoding with neutral new fields
  - distinct effective strengths and provisional exact 0.25 internal caps
affects: [35-02, 35-03, 35-04, 36-public-facade-output-evidence, 37-nose-safety-boundary-and-branch-closeout]

tech-stack:
  added: []
  patterns: [defaulted labeled Swift API growth, missing-key Codable neutrality, positive-only finite normalization]

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
    - BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift

key-decisions:
  - "Place both new positive-only fields after noseBridge in every public-model seam, preserving existing labeled calls through defaulted arguments."
  - "Keep bundled preset payloads unchanged so missing-key decoding itself proves compatibility."
  - "Use provisional independent 0.25 caps without claiming Phase 37 final calibration."

patterns-established:
  - "Public model growth: update stored properties, CodingKeys, initializer arguments, clamped assignments, missing-key decoding, and normalized-copy forwarding together."
  - "Compatibility evidence: test a literal complete legacy payload and real bundled resources rather than adding explicit zero keys."

requirements-completed:
  - NOSE-01
  - NOSE-02
  - NOSE-03

duration: 3 min
completed: 2026-07-13
---

# Phase 35 Plan 01: Public Contract and Compatibility Summary

**A 33-stored-field public model now carries two independent positive-only nose values with legacy JSON/preset neutrality, distinct effective storage, and provisional exact 0.25 caps.**

## Performance

- **Duration:** 3 min
- **Started:** 2026-07-13T06:22:46Z
- **Completed:** 2026-07-13T06:25:53Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Threaded `noseRootNarrowing` and `noseTipLift` through all six manual `BeautyParameters` seams while preserving existing source-style initializer calls.
- Locked default, finite clamp, non-finite fallback, mutable re-normalization, independent equality, exact 33-field inventory, literal legacy 31-key decode, and unequal-value round-trip behavior.
- Proved all five unchanged bundled presets decode both new values as zero and added distinct effective storage plus exact provisional `0.25` cap assertions.

## Task Commits

Each task was committed atomically:

1. **Task 35-01-01: Add the two independent public fields through every BeautyParameters seam** - `2dc5e7f` (feat)
2. **Task 35-01-02: Add effective storage, provisional caps, and bundled-preset neutrality evidence** - `1d5f0be` (feat)

## Files Created/Modified

- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` - Adds both stored fields, coding keys, defaulted arguments, clamping, decoding, and normalized forwarding.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` - Adds distinct zero-default effective strengths.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` - Adds two exact provisional `0.25` caps.
- `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` - Locks inventory, normalization, independence, compatibility, round-trip, source compatibility, and Sendable behavior.
- `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` - Proves five-preset inventory and missing-key neutrality.
- `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` - Directly asserts both provisional caps.

## Verification

- `swift test --package-path BeautySDK --filter BeautyParametersTests` — PASS, 14 tests.
- `swift test --package-path BeautySDK --filter BeautySafetyCapsTests` — PASS, 1 test.
- `swift test --package-path BeautySDK --filter BeautyResourceCatalogTests` — PASS, 7 tests.
- Exact public stored-property count scan — PASS, 33.
- New-key preset payload absence scan — PASS, zero preset files contain either key.
- Scoped out-of-scope diff scan — PASS; no preset JSON, package manifest, provider, resolver, renderer, Demo, or feature-ledger edit.
- `git diff --check 5eff036..HEAD` — PASS.

## Decisions Made

- Both new values remain independent positive-only public storage; neither aliases a legacy nose field.
- Unedited preset absence is the compatibility mechanism under test.
- The `0.25` values are provisional Phase 35 constants; final calibration remains Phase 37 scope.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The first incremental SwiftPM link retained the prior initializer ABI and failed after the public signature changed. A package clean followed by a direct target build refreshed artifacts; all focused suites then passed repeatedly. No source workaround or scope expansion was needed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 35-02 can add package-internal supports and independent provider vectors using the now-stable public/effective symbols.
- Resolver propagation, provider routing, final cap calibration, renderer evidence, and ledger promotion remain intentionally deferred to their owning plans/phases.

## Self-Check: PASSED

- All six modified files exist.
- Both task commits are present in git history.
- All task acceptance criteria and plan verification commands passed.
- No unresolved ASVS Level 1 high-severity threat or new security surface was found.

---
*Phase: 35-public-contract-and-independent-geometry*
*Completed: 2026-07-13*
