---
phase: 92-signed-eyebrow-head-spacing
plan: "02"
status: blocked-attempt-1
implementation_attempt: 1
subsystem: eyebrow-geometry-repair
tags: [swift, eyebrow-head-spacing, actual-pixels, reversible-failure]

requires:
  - phase: 92-signed-eyebrow-head-spacing
    provides: Frozen five-test BROW-01 provider and public-pixel oracle from Plan 92-01
provides:
  - Named fixed-aggregate rejection evidence for the first provider candidate
  - Byte-exact restoration of the pre-attempt provider with RED tests retained
affects: [92-attempt-2-plan-revision, BROW-01]

tech-stack:
  added: []
  patterns: [normalized-progress carriers, smoothstep taper, reversible candidate admission]

key-files:
  created:
    - .planning/phases/92-signed-eyebrow-head-spacing/92-02-SUMMARY.md
  modified: []

key-decisions:
  - "Reject attempt one because provider-level conformance produced no target-region pixel signal through the public facade."
  - "Classify the failure as target_signal, signed_direction, opposite_sign_distinction, whole_brow_plus_distinction, and whole_brow_minus_distinction."
  - "Restore the provider byte-for-byte and require a separately reviewed attempt-two plan before another candidate."

duration: 12min
completed: 2026-09-07
---

# Phase 92 Plan 02: Attempt-One Provider Repair Summary

**Attempt one satisfied the focused provider geometry contract but produced zero BROW-01 target signal in public-facade pixels, so it was rejected and rolled back byte-for-byte.**

## Outcome

- **Status:** blocked-attempt-1
- **Implementation attempt:** 1 of at most 2
- **Implementation commit:** `80e168a`
- **Rollback commit:** `d62617c`
- **Next permitted action:** independently revise and check an attempt-two plan from the named aggregates below; do not tune inside this plan.

## Candidate and Restoration

- Pre-attempt provider blob: `124946d79d380fe7e2eb14a36b3686ebdc1580a3`.
- Attempt-one provider blob: `a6db47808b50e30ce6f1aac719a9de0532c3fa06`.
- Restored provider blob: `124946d79d380fe7e2eb14a36b3686ebdc1580a3`.
- The retained candidate used canonical cumulative progress below `0.5`, the exact smoothstep-complement taper and `0.065` displacement coefficient, the `0.020/0.025` nominal radius coefficients, finite/unit rejection, and falloff `2`.
- To satisfy the frozen sign-symmetric provider-radius assertions while remaining conservative for both signs, its support cap used the farther outward signed target as the shared clearance bound and separately validated the actual moved-target clearance. This did not weaken any pixel gate and the candidate was rejected before retention.

## Provider Gate

- Discovery found the provider class and executed **16 tests**.
- All **16 tests passed with 0 failures and 0 unexpected failures** while the attempt-one candidate was present.
- Both focused BROW-01 provider methods passed for 4-, 5-, and 16-sample traces, both sides and signs, exact dead zone/cap, malformed-peer isolation, provider-empty behavior, sibling equality, and valid-invalid-valid recovery.
- The production diff was confined to `EyebrowWarpProvider.headSpacingPoints`; no sibling provider or shared helper changed.

## Public-Pixel Rejection Evidence

The combined admission command discovered exactly **5 repair tests**. With the attempt-one candidate present it executed **19 tests** total: all 16 provider tests passed, while all 3 public-facade tests failed with **20 assertion failures and 0 unexpected failures**.

### Named failure classes and fixed aggregates

| Failure class | Fixed result | Frozen requirement |
| --- | ---: | ---: |
| `target_signal` | plus/source `0 / 0`; plus/neutral `0 / 0`; minus/source `0 / 0`; minus/neutral `0 / 0` changed pixels / RGB delta | each comparison at least `500 / 2,000` |
| `signed_direction` | plus/source `0`, plus/neutral `0`, minus/source `0`, minus/neutral `0` Q16 | plus at least `+16`; minus at most `-16` |
| `opposite_sign_distinction` | `0` Q16 | at least `16` |
| `whole_brow_plus_distinction` | head-plus/whole-plus `0`; head-minus/whole-plus `0` Q16 | each at least `16` |
| `whole_brow_minus_distinction` | head-plus/whole-minus `0`; head-minus/whole-minus `0` Q16 | each at least `16` |

- Left-only and right-only valid-side target changes were each `0` changed pixels; rejected-peer regions remained source-exact.
- The valid-invalid-valid sequence remained byte-deterministic and the invalid middle output remained source-exact, but the valid output had `0` target changed pixels and therefore supplied no effectiveness evidence.

### Passing fixed predicates

- Outside-target, outer-anchor, eye, background, and watermark aggregates were all `0 / 0`, within their unchanged ceilings.
- Neutral identity, repeated bytes, repeated metrics/warnings, provider invocation counts, usable detection metadata, extent, explicit sRGB input, opaque alpha, provider-empty behavior, invalid/no-face source identity, lifecycle equality, and redaction assertions passed.
- No crash, build failure, zero-test condition, or unexpected test failure occurred.

## Restored RED State

- After rollback, the provider hash exactly matched the recorded pre-attempt blob.
- The focused repair inventory still discovered exactly **5 tests** and exited nonzero with **78 intended assertion failures and 0 unexpected failures**: 20 public-pixel failures plus 58 provider-formula failures.
- Both Wave-1 test files remain tracked and unchanged. No test, manifest, comparator, threshold, region, sibling list, package target, backend, shader, or public API was altered.

## Security, Privacy, and Scope

- Durable evidence contains only fixed counts, bounded deltas, Q16 margins, hashes, commits, and pass/fail facts.
- No image, raw pixel buffer, mask, eyebrow coordinate, private fixture locator, generated media, renderer report, local path, or transcript was persisted.
- No UI/Demo, model, data, weight, Metal/GPU backend, retained `Warp.metal`, owner document, or external dependency changed.
- This failed generated-fixture attempt establishes no real-device, portrait-quality, commercial, packaging, shipping, launch, release-readiness, or distribution claim.

## Deviations from Plan

- The frozen provider tests required equal positive/negative radii, while the prose formula's literal moved-target clearance is sign-dependent. The candidate reconciled this by using the conservative outward signed target for the shared support cap and validating each actual moved target. The provider gate passed, but the public-pixel oracle rejected the candidate; any attempt-two plan must resolve this contract wording explicitly before implementation.

## Required Decision Point

Attempt two remains available only through a separately revised and independently checked plan that cites these named zero-signal aggregates. If that second candidate fails the unchanged oracle, Phase 92 must stop for an explicit owner repair/defer/stop decision; attempt three is unavailable.

## Self-Check: PASSED

- Candidate and rollback commits exist.
- Provider pre/restored blob identity is exact.
- Exact five-test inventory and controlled RED state remain.
- The candidate is absent from the working tree and no generated media or report artifact was retained.

---
*Phase: 92-signed-eyebrow-head-spacing*
*Completed: 2026-09-07*
