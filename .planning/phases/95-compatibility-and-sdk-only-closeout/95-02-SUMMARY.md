---
phase: 95-compatibility-and-sdk-only-closeout
plan: "02"
status: complete
requirements: [COMPAT-01]
tasks: 2
commits: 0
---

# Phase 95 Plan 02: Compatibility contract baseline summary

Established additive COMPAT-01 coverage for the owner-local BeautySDK public
contract: 62 Codable fields, five manifest-authoritative presets, 75 renderer
case IDs, both still-image facade signatures, CPU/GPU routing markers, the
SDK-only boundary, and neutral non-target behavior.

## Evidence

- `python3 scripts/check-phase95-closeout.py author-build --batch compat`: passed.
- `swift test --package-path BeautySDK --filter RepairedControlCompatibilityTests`: 4/0/0, zero skips.
- Independent review: `95-02-TEST-REVIEW.md`, PASS; exact inputs frozen in `95-COMPAT-BINDING.json`.
- `python3 scripts/check-phase95-closeout.py freeze --batch compat --review .planning/phases/95-compatibility-and-sdk-only-closeout/95-02-TEST-REVIEW.md`: passed.
- `python3 scripts/check-phase95-closeout.py compat-baseline`: `baseline_pass`, 7/7 predicate categories, 0 failures, 0 skips.
- `git diff --check`: passed.

## Files

- `scripts/check-phase95-closeout.py`
- `BeautySDK/Tests/BeautyCoreTests/RepairedControlCompatibilityFixture.swift`
- `BeautySDK/Tests/BeautyCoreTests/RepairedControlCompatibilityTests.swift`
- `95-02-TEST-REVIEW.md`
- `95-COMPAT-BINDING.json`
- `95-COMPAT-EVENTS.jsonl`
- `95-COMPAT-BASELINE.json`

## Deviations from Plan

The existing runner exposed only the Phase 95 safety commands, so the planned
compatibility author-build, freeze, and baseline lanes were added additively to
the same script. The live preset manifest uses `natural`, `clear`, `refined`,
`male-natural`, and `id-photo-natural`; the fixture binds those actual repository
IDs instead of the stale prose examples in the plan. No production source,
prior-phase fixture/test, threshold, or historical receipt was changed.

## Remaining Obligations

Phase 95 Plans 95-03 and 95-04 still own the clean portrait rerun, complete
no-skip closeout, owner-document synchronization, and final qualification.

## Self-Check: PASSED

All summary, binding, event, baseline, review, fixture, test, and runner files
exist; the focused suite and compatibility baseline passed; unrelated working
tree changes were preserved.
