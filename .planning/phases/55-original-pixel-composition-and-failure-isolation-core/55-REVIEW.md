---
phase: 55-original-pixel-composition-and-failure-isolation-core
reviewed: 2026-08-03T08:10:18Z
depth: deep
files_reviewed: 15
files_reviewed_list:
  - BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift
  - BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift
  - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
  - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift
  - .planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py
  - ARCHITECTURE.md
  - DESIGN.md
  - PLANS.md
  - PRODUCT_SENSE.md
  - QUALITY_SCORE.md
  - RELIABILITY.md
  - SECURITY.md
findings:
  critical: 2
  warning: 3
  info: 0
  total: 5
status: issues_found
verdict: blocked
---

# Phase 55: Code Review Report

**Reviewed:** 2026-08-03T08:10:18Z
**Depth:** deep
**Files Reviewed:** 15
**Status:** issues_found
**Verdict:** BLOCKED — two HIGH findings invalidate T-55-01/T-55-02 and COMP-01/COMP-02 until fixed and re-reviewed.

## Summary

The Phase 55 production, facade, Testing SPI, unit/facade tests, mutation checker, root contracts, all five plans/summaries, context, research, validation/evidence/threat artifacts, and the Phase 54 closed decision ledger were reviewed against commits `a8635cf..989e825`.

The Q16 blend, hard re-clip, collision-to-source reduction, alpha preservation, no-change carrier reuse, exact-empty production admission, and current sequential facade tests behave as intended. Focused reruns passed 20/20 composer tests, 28/28 facade/foundation tests, checker syntax, checker 44-case self-test, and live checker mode.

Those green gates do not cover two blocking authorization/isolation defects. Authorization is represented only by lifetime-unsafe `ObjectIdentifier` addresses, and malformed issuance consumes the shared unit budget before validation. The checker currently requires the unsafe identity pattern and mutates only a synthetic contract, so it reports all HIGH rows green despite both defects.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01 [BLOCKER/HIGH]: Stale units can become authorized after `ObjectIdentifier` address reuse

**File:** `BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift:6-13`

**Related:** `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift:29-41, 79, 142-163`; `.planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py:319-334`

**Issue:** Both source and owner authorization store only `ObjectIdentifier` values. `BeautyLocalRetouchUnit` retains neither the canonical storage nor the owner identity object, so both referenced objects can be destroyed while the unit remains `Sendable`. Swift guarantees an object identifier is unique only during that object's lifetime; allocator addresses can be reused. A stale unit can therefore compare equal to a later request's source/owner after address reuse, especially because tokens restart at `1` for every owner and identical layouts are common. That breaks exact-current-request authorization (COMP-02 / T-55-01) and can apply old target pixels to a new image. A focused allocator probe during review observed reuse independently for both storage-shaped and owner-identity class instances.

**Fix:** Keep strong opaque identity tokens in the binding/unit and compare the referenced objects by identity, rather than persisting their addresses. For example, let canonical storage own an immutable `@unchecked Sendable` identity object, let `BeautyCanonicalPixelSourceBinding` retain that object strongly, and implement equality using `lhs.identity === rhs.identity` plus the checked layout. Likewise, store a strong `BeautyLocalRetouchOwnerIdentity` reference in each unit and compare with `===`. Add a churn regression that retains a stale unit while repeatedly destroying/recreating carriers and owners, and remove the checker's requirement that authorization be represented by a bare `ObjectIdentifier`.

### CR-02 [BLOCKER/HIGH]: Invalid units consume the shared issuance budget and can disable valid siblings

**File:** `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift:112-130`

**Related:** `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift:158-169`; `BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift:83-117`

**Issue:** `makeUnit` increments `nextToken` and `issuedTokens` without validating whether proposals are empty, over-budget, duplicated, or out of range. Those checks occur only later in `compose`. Consequently, one malformed producer can call `makeUnit` `effectiveUnitLimit` times with invalid proposals and exhaust every token; a subsequent valid sibling receives `nil` and never reaches composition. The existing test actually issues three malformed units and confirms they consume slots, but stops before proving a later valid sibling after full exhaustion. This contradicts COMP-01/D-55-07/D-55-13: malformed work is not isolated to its unit because it can suppress unrelated valid work. It also invalidates the T-55-02 bounded-input claim.

**Fix:** Perform proposal validation before consuming an issuance slot/token, and make issuance a one-shot centrally assigned slot per independently rejectable unit rather than an unrestricted shared mutable factory. At minimum, empty/effective-empty, over-cap, duplicate-index, invalid-index/offset, and other invalid proposal sets must return `nil` without advancing issuance state. Add a regression that attempts at least `effectiveUnitLimit` malformed or effective-empty issuances and then proves a valid sibling can still be issued and composed.

## Warnings

### WR-01 [WARNING]: `@unchecked Sendable` testing state is locked per property but not isolated per request

**File:** `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift:666-684, 742-786`

**Related:** `BeautySDK/Sources/BeautySDK/BeautyEngine.swift:121-166`

**Issue:** `BeautyLocalRetouchTestingHooks` and the public Testing harness claim unchecked Sendability, but a still request is a multi-call transaction over shared `currentCompositionScenario`, source-match state, latest observation, fixture indices, and lifecycle cleanup. Each accessor takes a lock separately; the complete `beginStillRequest -> hasOpaqueCompositionScenario -> makeOpaqueCompositionUnits -> recordComposition -> finishStillRequest` sequence is not serialized. Two concurrent calls through one Sendable harness can overwrite or clear each other's scenario and observation, producing cross-request units/results even without a memory data race. The current concurrency test uses two independent harnesses and explicitly does not exercise same-engine calls.

**Fix:** Either remove the unchecked Sendable promise from the harness while same-engine concurrency is unsupported, serialize the entire `invoke` operation, or key all hook state by an immutable request ID passed through every lifecycle operation. Add a same-harness parallel test if Sendability is retained.

### WR-02 [WARNING]: The “44 mutation” checker does not mutate the live implementation and enshrines the unsafe identity scheme

**File:** `.planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py:311-349, 497-602`

**Issue:** Live checks are mostly substring/regex anchors, while `--self-test` mutates a separate `SyntheticContract`. None of the 44 cases changes a temporary copy of the actual Swift implementation and reruns the real classifier. For T-55-01 the checker specifically requires `ObjectIdentifier`, so the lifetime-unsafe implementation in CR-01 is reported as green. Logic inversions such as changing source-binding equality from `==` to `!=` retain the required strings and still pass checker live mode. The evidence and root contracts therefore overstate the checker as adversarial proof of all seven HIGH mitigations.

**Fix:** Refactor checks to accept a repository root, create temporary copies of the real files, apply executable mutations to actual comparison/validation branches, and assert the real live checker rejects each mutation. Replace bare identity-name anchors with behavior tests for stale-source lifetime, invalid-issuance starvation, equality inversion, duplicate handling, hard re-clip, and collision suppression.

### WR-03 [WARNING]: The active plan still tells the next agent to execute already completed Phase 55 plans

**File:** `PLANS.md:39`

**Issue:** The `Next` row says to execute Plans 55-01 through 55-05, while the same active ledger records Wave 4 validation complete at line 46 and `.planning/STATE.md` says review/verification is next. This violates the repository's single-record traceability rule and can route a later agent into re-executing completed work.

**Fix:** Change `Next` to the current review/fix/re-verification step (and then Phase 56 only after Phase 55 review and verification pass), keeping it synchronized with `STATE.md` and `ROADMAP.md`.

---

_Reviewed: 2026-08-03T08:10:18Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: deep_
