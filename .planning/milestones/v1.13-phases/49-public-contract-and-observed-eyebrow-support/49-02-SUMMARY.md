---
phase: 49-public-contract-and-observed-eyebrow-support
plan: "02"
subsystem: public-model-compatibility
tags: [swift, codable, compatibility, eyebrow, tdd, presets]

requires:
  - phase: 49-01
    provides: Fail-closed Phase 49 checker and no-activation boundary
provides:
  - Exact 59-field BeautyParameters contract with seven independent eyebrow scalars
  - Legacy 52-key JSON and five-preset missing-key neutrality
  - Executable proof that all seven nonzero eyebrow values remain runtime-inert
  - Boundary and non-finite normalization evidence for six signed fields and one unit field
affects: [49-03, 49-04, 49-05, phase-50-eyebrow-geometry]

tech-stack:
  added: []
  patterns: [defaulted additive Codable evolution, finite boundary normalization, storage-before-activation]

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
    - BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift

key-decisions:
  - "Keep the first six eyebrow controls signed in -1...1 and eyebrowPeakDefinition positive-only in 0...1, with all non-finite values normalized to zero."
  - "Evolve the public model additively to exactly 59 stored fields while preserving historical 31/33/38/48/52 fixture meanings and unchanged preset bytes."
  - "Keep all seven fields storage-only in Phase 49: they do not trigger face geometry or alter resolver plans, emissions, warnings, metrics, or control points."

patterns-established:
  - "Every public eyebrow identifier is forwarded exactly once through storage, CodingKeys, defaulted initialization, finite clamping, missing-key decoding, and normalized-copy reconstruction."
  - "Compatibility is proved with unequal complete payloads and real key removal rather than explicit zero keys in legacy or preset JSON."

requirements-completed: [BROW-01, BROW-02]

coverage:
  - id: D1
    description: "Seven independent public eyebrow fields with exact signed/unit domains, zero defaults, finite clamping, equality, reset, and non-mutating normalized copies"
    requirement: BROW-01
    verification:
      - kind: unit
        ref: "BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift#testBROW01SignedFieldsNormalizeEveryFiniteAndNonFiniteBoundaryIndependently"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift#testBROW01PeakDefinitionNormalizesUnitAndNonFiniteBoundaries"
        status: pass
      - kind: unit
        ref: "BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift#testBROW02SourceDefaultsResetInventoryAndSnapshotDiffAreExact"
        status: pass
    human_judgment: false
  - id: D2
    description: "Exact 59 stored/58 numeric inventory with complete unequal round-trip and neutral legacy 52-key decoding"
    requirement: BROW-02
    verification:
      - kind: unit
        ref: "BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift#testBROW02Complete59KeyRoundTripAndLegacy52PayloadRemainIndependentAndNeutral"
        status: pass
      - kind: unit
        ref: "swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests"
        status: pass
    human_judgment: false
  - id: D3
    description: "Exactly five byte-stable bundled presets remain eyebrow-key-free and decode seven zeros"
    requirement: BROW-02
    verification:
      - kind: unit
        ref: "BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift#testBROW02ExactlyFiveBundledPresetsDecodeSevenMissingEyebrowFieldsAsZero"
        status: pass
      - kind: other
        ref: "python3 .planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py --self-test"
        status: pass
    human_judgment: false
  - id: D4
    description: "Seven nonzero eyebrow values remain inert across face-geometry triggering, complete resolver plans, effective strengths, domains, warnings, metrics, emissions, and control points"
    requirement: BROW-02
    verification:
      - kind: integration
        ref: "BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift#testBROW02SevenNonzeroEyebrowFieldsRemainRuntimeInert"
        status: pass
    human_judgment: false

# Metrics
duration: 8 min
completed: 2026-07-24
status: complete
---

# Phase 49 Plan 02: Neutral Public Eyebrow Contract Summary

**Exact seven-scalar eyebrow storage in a 59-field Codable model, preserving legacy 52-key and five-preset neutrality while proving complete resolver inertness**

## Performance

- **Duration:** 8 min
- **Started:** 2026-07-24T07:44:12Z
- **Completed:** 2026-07-24T07:53:04Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Expanded `BeautyParameters` from 52 to exactly 59 stored properties: 58 numeric values plus `filterId`, with all seven eyebrow identifiers wired through every manual lifecycle seam.
- Locked exact normalization, zero-default, equality, reset, snapshot-diff, non-mutating copy, complete round-trip, and real legacy-52 missing-key behavior.
- Proved all five bundled presets remain byte-identical and decode seven neutral eyebrow values, with no eyebrow key added to resource JSON.
- Proved a request containing all seven nonzero eyebrow values is identical to its all-seven-zero counterpart across face-geometry triggering and the complete shipped resolver plan/control-point output.

## Public Range Contract

| Field | Public range | Finite overflow | Non-finite |
| --- | --- | --- | --- |
| `eyebrowYPosition` | `-1...1` | clamps to nearest edge | `0` |
| `eyebrowThickness` | `-1...1` | clamps to nearest edge | `0` |
| `eyebrowLength` | `-1...1` | clamps to nearest edge | `0` |
| `eyebrowSpacing` | `-1...1` | clamps to nearest edge | `0` |
| `eyebrowHeadSpacing` | `-1...1` | clamps to nearest edge | `0` |
| `eyebrowTilt` | `-1...1` | clamps to nearest edge | `0` |
| `eyebrowPeakDefinition` | `0...1` | negative to `0`, positive overflow to `1` | `0` |

The six signed table tests cover `-2 → -1`, `-1 → -1`, `0 → 0`, `1 → 1`, `2 → 1`, and `NaN/+∞/-∞ → 0`. Peak definition covers `-2/-1 → 0`, `0 → 0`, `1 → 1`, `2 → 1`, and `NaN/+∞/-∞ → 0`.

## Compatibility Evidence

- Current model: **59 stored fields = 58 numeric + `filterId`**.
- Historical fixture counts remain literal and behaviorally distinct: **31, 33, 38, 48, and 52**.
- A complete unequal 59-key payload round-trips exactly.
- Removing exactly the seven eyebrow keys produces a real 52-key payload; decoding restores all seven values as zero while retaining shipped values.
- `.init()` resets all seven values to zero; seven one-field snapshots are mutually unequal and unequal to reset.
- `normalized()` returns a new clamped value and leaves mutable source values unchanged.

## Bundled Preset Results

Exactly five bundled preset IDs remain in their established order and decode seven eyebrow zeros:

1. `natural`
2. `clear`
3. `refined`
4. `male-natural`
5. `id-photo-natural`

Pinned SHA-256 values remain unchanged:

| Preset file | SHA-256 |
| --- | --- |
| `clear.json` | `58327c8ef8cc8323d4a6e4d98754d8c9bf797b348804ca2a308c4c39e00856f8` |
| `id-photo-natural.json` | `d6d2d3e5872ae0aa25823c4d76e07057ecdfa336818cd116509627995941c609` |
| `male-natural.json` | `1c6e632e8740602fa662c42e41cf9709eec29b3138bf58df43fad40d8b5d0c08` |
| `natural.json` | `bd102ec3643f1625d561af66fd0e7fb67c33fe5061720600907ed3fd931a08da` |
| `refined.json` | `67f238fddf8d9dc08bc8b24121af25d11f9caf8a85b905cf83a47b0dff675722` |

## Runtime Inertness Evidence

With all seven eyebrow fields nonzero together:

- eyebrow-only input does not trigger `requiresFaceGeometry`;
- a shipped multi-domain input retains the same geometry-trigger decision;
- the complete `BeautyEffectPlan` remains equal;
- effective strengths, active/skipped domains, warnings, metrics, and geometry point counts remain equal;
- unified control points remain exactly equal.

No provider, resolver production case, safety cap, facade route, renderer/gallery output, Demo/UI behavior, or product-row promotion was added.

## Task Commits

Each task was committed atomically:

1. **Task 49-02-01: Add seven independent normalized public fields** — `91d8a4b` (RED), `a36b99f` (GREEN)
2. **Task 49-02-02: Prove legacy, preset, reset-diff, round-trip, and runtime neutrality** — `41e3ff4`

## Files Created/Modified

- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — seven stored properties, coding keys, defaulted initializer labels, clamps, missing-key decoding, and normalized-copy forwarding.
- `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` — range tables, 59/58 inventory, equality/reset/diff, historical counts, full round-trip, and legacy-52 neutrality.
- `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` — exact five-preset inventory and seven-zero decode evidence.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` — all-seven-nonzero complete runtime-inertness evidence.

## Decisions Made

- Used existing `clampSigned` for the first six fields and `clampUnit` only for peak definition; no wrapper, alias, or support type was introduced.
- Kept bundled resources unchanged so missing-key decoding—not explicit resource zeros—proves compatibility.
- Compared the entire resolver plan and unified control-point result rather than checking only aggregate domain activity.

## Verification

- `BeautyParametersTests`: **37 executed, 0 failures**.
- `BeautyResourceCatalogTests`: **10 executed, 0 failures**.
- `BeautyEffectResolverTests`: **23 executed, 0 failures**.
- Phase 49 checker self-test: **42/42 passed**.
- `git diff --check`: **passed**.
- Modified-file scope: exactly the planned model and three test owners; no preset, manifest, provider/resolver production, facade, renderer, gallery, Demo, model, resource, network, or persistence file changed.
- Full SwiftPM suite: **not run** because its Phase 49 preflight remains blocked by missing local `example-images/input/portraits/e1.png`; no full-suite green claim is made.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The first incremental SwiftPM link reused stale initializer ABI output after the public initializer expanded. `swift package --package-path BeautySDK clean` rebuilt package artifacts; the subsequent focused gates passed. No source workaround was needed.
- The known local `e1.png` fixture prerequisite remains absent, so the full suite was not reported green. This is the inherited environment gate recorded by Plan 49-01, not a Plan 49-02 regression.

## Known Stubs

None. The default `filterId: nil` is the established no-filter contract, and eyebrow runtime inertness is intentional Phase 49 scope rather than an unfinished implementation stub; Phase 50 owns activation.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 49-03 can capture and map actual Vision eyebrow regions against the now-stable seven-field public schema.
- Plan 49-04 can validate semantic support without reopening public names, ranges, storage counts, or compatibility behavior.
- The authorized `e1.png` fixture remains required before a later phase-level full-suite green claim.

## Self-Check: PASSED

- All four planned modified files exist.
- RED commit `91d8a4b`, GREEN commit `a36b99f`, and compatibility/inertness commit `41e3ff4` exist in git history.
- All task acceptance gates and plan-level focused verification commands passed.
- No unexpected tracked deletion or untracked generated artifact remains.

---
*Phase: 49-public-contract-and-observed-eyebrow-support*
*Completed: 2026-07-24*
