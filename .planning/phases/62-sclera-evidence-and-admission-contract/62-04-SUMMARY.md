---
phase: 62-sclera-evidence-and-admission-contract
plan: "04"
subsystem: intent-admission
tags: [sclera, compatibility, codable, request-local, opaque-demand]
requires: [62-03]
provides: [sclera-intent-scalar, independent-demand-cardinality, downstream-absence-proof]
affects: [62-05, 63]
tech-stack:
  added: []
  patterns: [trailing-defaulted-scalar, normalize-once, feature-neutral-demand-count]
key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyLocalRetouchAdmission.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineTeethWhiteningIntegrationTests.swift
key-decisions:
  - The exact serializer-open sclera row unlocks one trailing positive-only default-zero scalar and nothing downstream.
  - Teeth and sclera independently add one opaque demand, while any nonempty count still owns one canonical request.
  - Sclera-only intent creates request-local foundation work but no provider, composition, renderer output or Demo mapping.
metrics:
  tasks: 2
  model_preset_tests: 73
  focused_admission_tests: 87
  demo_view_state: passed
  model_fields: 61
  renderer_cases: 73
completed: 2026-08-07
---

# Phase 62 Plan 04 Summary

## Outcome

Added `scleraRednessReduction` as the trailing 61st `BeautyParameters` field.
It is public scalar intent only: default and missing-key values are zero,
finite values normalize to `0...1`, and negative or non-finite values become
zero. Existing labeled calls compile unchanged, all five preset source bytes
remain unchanged, and every bundled preset decodes both local-retouch intents
as zero.

The sole local-retouch admission authority now normalizes once and produces
exact opaque cardinalities `0/1/1/2` for none, teeth-only, sclera-only and both.
Aliases, global effects, geometry, Testing names, Demo IDs/titles and `去脂`
proxies contribute no demand. Multiple positive or overflow values cannot
multiply either direct intent.

Sclera-only intent shares the existing canonical still-image request path but
has no provider or visible output. Both intents still create one canonical
request and preserve the existing teeth provider and pixel result exactly.
Renderer inventory remains 73 with no sclera case, while all three local-
retouch Demo rows remain disabled with nil mappings.

## Verification

| Gate | Result |
| --- | --- |
| Model/Codable/preset filters | 73/73 passed |
| Preset source byte diff | unchanged |
| Resolver/foundation/teeth/renderer filters | 87/87 passed |
| Demo view-state tests on iPhone 17e / iOS 26.5 | passed |
| Demand cardinality | none 0, teeth 1, sclera 1, both 2 |
| Renderer / Demo compatibility | 73 cases / three disabled nil-mapped rows |
| Diff hygiene | passed |

## Commits

| Task | Commit | Description |
| --- | --- | --- |
| prerequisite | `9cdcf88` | Declare the test-only render facade dependency |
| 62-04-01 | `6c18518` | Append the compatibility-safe sclera intent scalar |
| 62-04-02 | `24367e9` | Admit one independent opaque sclera demand |

## Deviations from Plan

- A clean SwiftPM build exposed that `BeautyRenderTests` imported the facade
  testing SPI without declaring the facade test dependency. The manifest now
  declares that test-only dependency; no production target or dependency
  direction changed.

## Nonclaims

This plan does not add a sclera provider, anatomy guard, mask, transform,
renderer output, saved image, Demo control, realtime path, product promotion,
performance claim or release-readiness claim. `祛红血丝` and `去脂` remain
disabled in the Demo; Phase 63 owns guarded per-eye production work.

## Self-Check: PASSED

- Exact-open evidence was the prerequisite for the one appended scalar.
- Model order, legacy decoding, presets, teeth output, renderer inventory and
  disabled Demo taxonomy are verified.
- Only `.planning/config.json` remains as the autonomous-chain working-tree
  change before Plan 62-05 begins.
