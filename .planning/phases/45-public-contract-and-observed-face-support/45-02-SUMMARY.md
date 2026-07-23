---
phase: 45-public-contract-and-observed-face-support
plan: "02"
subsystem: public-parameter-contract
tags: [swift, codable, compatibility, face-geometry, presets, tdd]

requires:
  - phase: 45-public-contract-and-observed-face-support
    provides: Plan 45-01 fail-closed safeguards and private face-support separation
provides:
  - exact 52-field BeautyParameters contract with four independent positive-only face intents
  - legacy 48/38/33/31 payload compatibility and five-preset missing-key neutrality
  - shipped resolver-plan neutrality with explicit zero values and no premature nonzero routing
affects: [45-03, 45-04, 45-05, phase-46-face-providers]

tech-stack:
  added: []
  patterns:
    - seven-site manual scalar lifecycle with missing-key zero decoding
    - full-plan equality regression before downstream routing exists

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
    - BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
    - PLANS.md

key-decisions:
  - "Keep all four additions as independent clampUnit-backed stored values adjacent to the shipped face fields while preserving signed chinLength."
  - "Treat the four public values as storage-only in Phase 45; Phase 46 exclusively owns requiresFaceGeometry, effective strengths, caps, providers, and routing."
  - "Preserve preset files byte-for-byte and prove compatibility through missing-key decoding rather than explicit zero keys."

patterns-established:
  - "Public face scalar additions cross property, CodingKey, defaulted initializer, clamp assignment, decode, normalized copy, and focused tests together."
  - "Compatibility evidence distinguishes current 52-key inventory from historical literal 48/38/33/31 payload shapes."

requirements-completed: [FACE-07, FACE-08, FACE-09, FACE-12]

duration: 5 min
completed: 2026-07-23
---

# Phase 45 Plan 02: Public Face Contract and Shipped Neutrality Summary

**Exactly four independent positive-only face intents extend `BeautyParameters` from 48 to 52 stored fields while legacy payloads, five bundled presets, and every shipped resolver domain remain neutral**

## Performance

- **Duration:** 5 min
- **Started:** 2026-07-23T04:58:11Z
- **Completed:** 2026-07-23T05:03:12Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Added `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper` through every manual `BeautyParameters` lifecycle seam. Finite values clamp independently to `0...1`, non-finite values become zero, source/missing-key defaults are zero, and signed `chinLength` remains independent.
- Locked exact current inventory and compatibility: 52 reflected/encoded keys, unequal four-value round trip, neutral legacy 48-key decode, a 38-key reconstruction that removes ten eye plus four face additions, and unchanged literal 33/31 fixture counts.
- Proved the exact five bundled preset IDs decode all four absent keys as zero while their fixed SHA-256 hashes remain unchanged.
- Proved explicit four-field zeros produce the exact same shipped face/eye/nose/mouth plan, and each nonzero new request remains absent from `requiresFaceGeometry` and resolver/provider output until Phase 46.

## Task Commits

1. **Task 45-02-01: Add four independent normalized public fields**
   - `e9694e3` — RED: failing normalization, inventory, default, and non-mutating-copy contract tests
   - `d6265b8` — GREEN: four-field stored/Codable/source lifecycle
2. **Task 45-02-02: Prove legacy, preset, independence, and shipped-domain neutrality**
   - `e9f3ac7` — compatibility, preset, and resolver regression evidence

Task 2 is evidence-only and required no production change: once Task 1 established the public storage contract, its newly added legacy/preset/no-routing regressions were already green by design.

## Files Created/Modified

- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — exact 52-field storage, keys, defaults, clamping, missing-key decode, and normalized-copy forwarding.
- `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` — FACE-labeled normalization, inventory, source omission, unequal 52-key round trip, legacy 48/38 compatibility, and historical-count evidence.
- `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` — exact five-preset inventory and four-field zero decode.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` — full shipped-plan equality at explicit zero and Phase 46 no-routing evidence.
- `PLANS.md` — repository execution ledger and verification record.

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` — **PASS, 32/32**.
- `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` — **PASS, 9/9**.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` — **PASS, 20/20**.
- Focused total — **PASS, 61/61**.
- Five preset SHA-256 values exactly match the Plan 45-01 fixed baseline.
- Scope scan confirms no preset JSON, package manifest, provider, resolver production, renderer, facade, or Demo source changed.
- `git diff --check` — **PASS**.
- Full `swift test --package-path BeautySDK` probe — built and executed **325 tests**, then reproduced the prior host-environment-only **86 CoreImage/CoreVideo/Vision failures (18 unexpected)** involving zero-pixel rendering, `pixelBufferCreationFailed`, and unavailable Vision detection. All changed focused suites remained green in the full run.

## Decisions Made

- Kept the new fields beside existing face-shape values and used `clampUnit` at construction/decoding/normalization rather than introducing aliases, setters, wrappers, or public support types.
- Kept `chinTaper` positive-only and completely separate from signed `chinLength`.
- Kept provider eligibility and all runtime behavior deferred; public nonzero intent alone is not yet geometry-triggering evidence.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The first incremental build linked a stale `BeautyExampleRenderer` object against the old initializer signature. A normal `swift package clean` removed the stale build output.
- After cleaning, the restricted host denied SwiftPM user-cache/module-cache writes and one first-pass parallel rebuild briefly could not import `BeautySDK`. Re-running with the established private temporary Clang module cache and SwiftPM sandbox disabled completed the build; subsequent exact plan commands passed without the workaround.
- The full suite reproduced the same 86 environment-only CoreImage/CoreVideo/Vision failures recorded by Plan 45-01. These failures are outside the four plan-owned code/test files and were not modified.

## Known Stubs

None. The intentional lack of routing/provider behavior is the locked Phase 45 boundary, with Phase 46 explicitly owning activation.

## Threat Flags

None. The public scalar trust boundary and premature-routing risk are both present in the plan threat model and have direct normalization/no-routing tests.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 45-03 can add actual Vision contour/median capture without reopening public compatibility.
- Plan 45-04 can validate observed support while the four public requests remain deliberately unrouted.
- Phase 46 can add eligibility, strengths, caps, providers, and resolver routing against this frozen 52-field contract.

## Self-Check: PASSED

- All four implementation/test artifacts and this summary exist.
- Task commits `e9694e3`, `d6265b8`, and `e9f3ac7` exist in repository history.
- The plan changes exactly the four declared implementation/test paths before metadata, all 61 focused tests pass, preset hashes match, and `git diff --check` passes.

---
*Phase: 45-public-contract-and-observed-face-support*
*Completed: 2026-07-23*
