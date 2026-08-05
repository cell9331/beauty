---
phase: 59
slug: teeth-evidence-and-admission-contract
status: validated
nyquist_compliant: true
wave_0_complete: true
created: 2026-08-05
security_standard: OWASP ASVS Level 1
block_on: HIGH
---

# Phase 59 — Validation Strategy

> Validate the teeth evidence-to-admission transition. The current canonical
> decision is closed; the newly supplied local real positive/negative bundle is
> still pending frozen blinded review. The closed branch must remain exact
> absence. Only a genuine, rights-approved, complete, blinded-reviewed
> `teeth_whitening` result with `status: open` may unlock the public scalar and
> opaque admission demand.

## Test Infrastructure

| Property | Value |
| --- | --- |
| Evidence contract | Existing Phase 54 dependency-free Node core/reviewer and aggregate-only ledger |
| SDK framework | SwiftPM XCTest through `BeautySDK/Package.swift` |
| Boundary checker | Standard-library Python checker with live temporary-copy mutations |
| Focused SDK sample | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-phase59-clang-module-cache swift test --package-path BeautySDK --filter 'BeautyParametersTests|BeautyEffectResolverTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests|BeautyEngineLocalRetouchFoundationTests'` |
| Focused Demo sample | Explicit iPhone 17e/iOS 26.5 `xcodebuild` test for `BeautyDemoViewStateTests` when the local Xcode supports the selector |
| Final-only regression | Full SwiftPM and explicit iPhone 17e/iOS 26.5 Demo build/test, owned only by `59-04-02` |
| Security | OWASP ASVS Level 1, `block_on: HIGH`; every T-59 HIGH row must be green |
| Diff hygiene | `git diff --check` in every task and final gate |

## Sampling Contract

- Wave 0 freezes the evidence contract, checker mutation matrix, exact threat
  IDs, and manual bundle/review precondition before production source changes.
- No task may turn a closed evidence row into a passed/open row by editing JSON,
  adding synthetic media, or treating `portrait_002` as product evidence.
- Focused SwiftPM/checker samples provide construction feedback. Full SwiftPM,
  complete Demo regression, GSD gates, owner sync, and validation promotion are
  final-only.
- The final task records actual executed, failed, skipped, and blocked results;
  a later broad regression cannot convert an unrun HIGH row to green.

## Planned Per-Task Verification Map

| Actual task ID | Wave | Requirements | Automated evidence | Manual/evidence gate | Status |
| --- | ---: | --- | --- | --- | --- |
| `59-01-01` | 1 | SEQ-01, EVID-07, TEETH-07, TEETH-08 | Node syntax/tests, checker self-test, exact Phase 54 authority parsing, privacy allowlist, fail-closed scanner mutations | None | passed; closed branch |
| `59-01-02` | 1 | SEQ-01, EVID-07 | Canonical ledger decision and checker live mode | Run frozen blinded original-detail review on the recalibrated positive/negative after assets in the Phase 54 reviewer | blocked; canonical review replacement pending |
| `59-01-03` | 1 | SEQ-01, EVID-07 | Sanitized ledger/evidence projection and exact sibling-row preservation | Review decision must be `open` before public branch | passed; closed projection |
| `59-02-01` | 2 | TEETH-07 | Focused `BeautyParametersTests` with exact 59-field inventory, normalization, Codable, legacy decode, source-call compatibility | None | not_applicable_closed_gate |
| `59-02-02` | 2 | TEETH-08 | Focused resolver matrix and one-demand lifecycle assertion | None | not_applicable_closed_gate |
| `59-03-01` | 3 | SEQ-01, TEETH-07, TEETH-08 | Preset, renderer/facade, lifecycle, and Demo boundary tests | None | passed; exact absence |
| `59-03-02` | 3 | SEQ-01, EVID-07, TEETH-07, TEETH-08 | Phase checker live mode, exact inventories, sanitized evidence/validation records | None | passed; closed branch |
| `59-04-01` | 4 | SEQ-01, EVID-07, TEETH-07, TEETH-08 | Requirements/decision/task/threat equality, privacy/scope, owner consistency | None | passed; blocker recorded |
| `59-04-02` | 4 | SEQ-01, EVID-07, TEETH-07, TEETH-08 | Full SwiftPM, explicit Demo build/test, checker, GSD gates, diff hygiene | None | passed; downstream blocked |

Task count equality target: **9 XML task IDs = 9 validation rows**. Every task
has an automated command; the real evidence gate is separately marked as a
manual precondition rather than being inferred from a synthetic fixture.

## Evidence and Decision Matrix

| Source condition | Required result |
| --- | --- |
| Missing/incomplete/unapproved/failed bundle | Valid closed decision; no field, no admission, no inert route |
| Complete genuine positive + genuine negative, frozen criteria, accepted review | Canonical teeth row `status: open`; positive branch may proceed |
| Candidate-only, synthetic, AI/mechanics, authorization-only, historical, sibling | Zero product/effectiveness/naturalness/admission weight |
| `portrait_002/original.png` | Mechanics-only, zero product weight |
| Any sclera or `去脂` mutation | Reject exact-absence boundary |

## Final-Only Gate

`59-04-02` ran, in order:

1. Phase 59 checker self-test and live mode, including exact canonical ledger
   decision and all T-59 HIGH mutations.
2. Focused SDK/Demo compatibility, admission, preset, lifecycle, renderer, and
   disabled-taxonomy suites.
3. Full SwiftPM and explicit iPhone 17e/iOS 26.5 Demo build/test.
4. GSD schema/UI/decision/requirements/post-planning checks and exact task /
   validation / threat / owner equality.
5. `git diff --check` and final sanitized evidence/validation promotion.

The canonical row is still closed. The final record reports the blocker and
preserves exact absence; TEETH-07/08 are not marked complete and no open
admission branch is claimed.

## Privacy and Scope Rules

Committed artifacts may contain only opaque IDs, fixed reason/judgment fields,
decisions, aggregates, commands, and counts. They must not contain media,
paths, hashes, rights records, masks, geometry, pixels, output digests,
reviewer identity, raw scanner matches, or raw errors. No provider, mask,
transform, renderer output, Demo activation, realtime/pixel-buffer route,
external model, or release claim is part of this phase.
