---
phase: 55-original-pixel-composition-and-failure-isolation-core
plan: "02"
subsystem: composition-foundation
tags: [swiftpm, rgba8, source-binding, checked-arithmetic, request-local, asvs]

requires:
  - phase: 55-01
    provides: literal mechanics RED specifications and fail-closed T-55 checker
provides:
  - exact ObjectIdentifier-backed canonical pixel source binding
  - package-only request-local proposal, unit, token, owner, result, and six-count summary values
  - bounded issuance and checked unit-local preflight
  - source-binding checker mode with mutation coverage
affects: [55-03, 55-04, 55-05, BeautyCore, BeautyEffects]

tech-stack:
  added: []
  patterns: [exact canonical storage binding, opaque monotonic unit token, checked sparse preflight]

key-files:
  created:
    - BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift
  modified:
    - BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift
    - .planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py

key-decisions:
  - "Authorization uses exact canonical storage identity plus checked layout, never the existing hash-valued testing identity."
  - "Duplicate tokens are keyed by owner identity and token together so a foreign owner's first token cannot invalidate a valid local token."
  - "The owner issues at most min(8,pixelCount) units and preflights per-unit sparse claims before later ownership reduction."

patterns-established:
  - "Source binding: a copied carrier retains the exact binding; a newly constructed byte-equal carrier does not."
  - "Local rejection: foreign, repeated, over-budget, out-of-range, duplicate-index, or effective-empty units abstain without removing a valid sibling."

requirements-completed: []

duration: 10min
completed: 2026-08-03
---

# Phase 55 Plan 02: Exact Source Binding and Preflight Summary

**The feature-neutral composer now accepts only bounded units issued for the exact current canonical storage and rejects malformed or foreign work locally.**

## Performance

- **Duration:** 10 min
- **Completed:** 2026-08-03T07:08:50Z
- **Tasks:** 2
- **Focused tests:** 14 passed, 0 failed
- **Checker:** 40 mutation cases plus source-binding live mode passed

## Accomplishments

- Added `BeautyCanonicalPixelSourceBinding` with exact storage identity and checked width, height, row-byte, and byte-count values while retaining the prior hash identity only for older tests.
- Added package-only feature-neutral proposals, opaque units/tokens, one request-local owner, six aggregate counters, and a canonical result carrier without a public, SPI, Codable, diagnostic, candidate, or admission surface.
- Bounded issuance to `min(8, pixelCount)`, bounded sparse claims per unit, and checked source, owner, token frequency, raw duplicates, indices, pixel offsets, and channel offsets before later ownership reduction.
- Added production-backed exact-copy/foreign-byte-equal, invalid-index/overflow-shaped, unit-exhaustion, duplicate-token, duplicate-raw-index, over-budget, and valid-sibling tests while retaining the independent Wave 0 byte oracle.
- Extended the boundary checker with the planned `--source-binding` mode and fail-closed mutation coverage without weakening the existing privacy, candidate, compatibility, Demo, realtime, or dependency gates.

## Task Commits

1. **Task 55-02-01: Bind units to canonical storage and checked layout** — `8921e8a`
2. **Task 55-02-02: Validate bounded issuance and source/preflight checker mode** — `109f5ce`

## Verification Results

- `BeautyLocalRetouchCompositionTests`: 14/14 passed.
- Checker Python syntax: passed.
- Checker `--self-test`: 40/40 mutation cases passed.
- Checker `--source-binding`: passed with T-55-01…07 present and no failed rule IDs.
- `git diff --check`: passed.
- Full SwiftPM and Demo regression: intentionally deferred to Plan 55-05.

## Deviations from Plan

- The Wave 0 checker exposed only `--self-test` and `--expect-wave0-red`, although Plan 55-02 required `--source-binding`; the checker file was added to the task's narrow ownership and the missing mode plus mutation guards were implemented.
- The Wave 0 oracle rule initially rejected any `BeautyEffects` import, which conflicted with Plan 55-02's required production-backed tests. It now requires the independent reference blend/literal merge oracle while allowing package production types; public/SPI/privacy checks remain unchanged.
- The assigned executor stopped at an account-usage limit before edits. The parent resumed from a clean worktree and completed the same planned scope.

## Scope and Security

- T-55-01/02/03 source-spoofing, arithmetic/cap, duplicate/token checks are production-backed.
- T-55-04…07 scope guards remain active in the checker.
- Production admission remains exact-empty; no feature name, provider, renderer case, preset, Demo, realtime/pixel-buffer, dependency, model, resource, network, persistence, or visible result was added.

## Next Phase Readiness

- Plan 55-03 can replace the preflight-only original result with deterministic Q16 blending, post-filter hard re-clipping, sorted collision-to-source ownership, and exact aggregate counts.
- The three Phase 54 feature gates remain closed and authorize no candidate route.

## Self-Check: PASSED

- All planned source/binding/preflight artifacts exist.
- Both task commits are present.
- Focused tests, checker syntax/self-test/source-binding mode, and diff hygiene are green.

---
*Phase: 55-original-pixel-composition-and-failure-isolation-core*
*Completed: 2026-08-03*
