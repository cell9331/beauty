---
phase: 62
slug: sclera-evidence-and-admission-contract
status: passed
nyquist_compliant: true
wave_0_complete: true
created: 2026-08-07
security_standard: OWASP ASVS Level 1
block_on: HIGH
requirements: [EVID-06, EVID-08, EVID-09, EVID-10, SCLERA-07, SCLERA-08]
---

# Phase 62 — Validation Strategy

> Validate one independent genuine sclera decision before one scalar and one
> demand are admitted. Provider, mask, transform and visible output remain out
> of scope.

## Test Infrastructure

| Property | Value |
| --- | --- |
| Framework | Node built-in test, Python standard library, SwiftPM XCTest, Xcode XCTest |
| Config file | Existing `BeautySDK/Package.swift` and `BeautyDemo.xcodeproj` |
| Quick run | `node --test <phase contract> && python3 <phase checker> --self-test` |
| Focused SDK | `swift test --package-path BeautySDK --filter 'BeautyParametersTests|BeautyEffectResolverTests'` |
| Full suite | `swift test --package-path BeautySDK` plus explicit Demo test/build |
| Estimated quick latency | under 30 seconds on the current host |

## Sampling Rate

- After every task commit: run the task's Node/Python or focused Swift command.
- After every wave: run all completed Phase 62 checker modes plus focused SDK
  tests that exist at that wave.
- Before final verification: run required private evidence, fresh ledger byte
  reproduction, every isolated HIGH mode, full SwiftPM and explicit Demo tests.
- No three consecutive tasks may rely only on manual review.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirements | Threat Ref | Test type | Automated command/owner | Status |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| 62-01-01 | 01 | 1 | EVID-08, EVID-09, EVID-10 | T-62-01/02/06 | contract | Node contract + JSON validation | green |
| 62-01-02 | 01 | 1 | EVID-10 | T-62-01/03/08 | mutation | checker closed/live/self-test | green |
| 62-02-01 | 02 | 2 | EVID-06, EVID-09 | T-62-01/02/06 | unit | adapter/runner negative-path tests | green |
| 62-02-02 | 02 | 2 | EVID-06, EVID-09, EVID-10 | T-62-02/06/08 | privacy | closed ledger + tracked/staged fixed-output scan | green |
| 62-03-01 | 03 | 3 | EVID-06, EVID-08 | T-62-01/02/07 | private/manual | guarded derivatives + original-detail review | green |
| 62-03-02 | 03 | 3 | EVID-06, EVID-09, EVID-10 | T-62-01/02/06 | private | ReviewCore open export + exact ledger bytes | green |
| 62-04-01 | 04 | 4 | SCLERA-07 | T-62-03/04 | XCTest | model/Codable/preset compatibility filters | green |
| 62-04-02 | 04 | 4 | SCLERA-08 | T-62-03/05/07 | XCTest | resolver/lifecycle/provider-absence filters | green |
| 62-05-01 | 05 | 5 | all six | T-62-01...08 | mutation/privacy | exact-open live, privacy and isolated threat modes | green |
| 62-05-02 | 05 | 5 | all six | T-62-04/06/07/08 | regression | full SwiftPM, Demo, owner/lifecycle checks | green |

Task count equality target: **10 task IDs = 10 validation rows**.

## Wave 0 Requirements

- `62-evidence-admission.contract.test.js` must freeze the closed/open schemas,
  review fields and aggregate-only privacy contract before real review.
- `check_phase62_sclera_admission_boundaries.py --self-test` must prove at
  least one failing mutation for every T-62-01 through T-62-08 owner before
  final verification.
- `62-private-evidence-runner.js` must test missing and ambiguous discovery
  without revealing candidate paths.

Wave 0 is complete only after Plan 62-02 passes. It does not open sclera.

## Manual-Only Verifications

| Behavior | Requirement | Why manual | Instructions |
| --- | --- | --- | --- |
| Genuine positive/negative polarity and natural output | EVID-06, EVID-08 | Semantics and naturalness cannot be inferred from hashes or mechanics metrics | Inspect blinded original/mask/after at original detail; record only fixed fields |
| Protected anatomy and negative stability | EVID-08 | Final judgment must inspect iris/pupil/highlight/lash/skin/makeup leakage and no-op behavior | Compare original/mask/after; reject on any protected leakage or unnatural change |

## Exact Final Gates

1. Required private runner discovers exactly one fully ignored sclera bundle and
   never prints its path, media names, digests, rights details or review prose.
2. Phase 54 ReviewCore issues both accepted reviews and fresh serializer bytes
   match the canonical ledger exactly.
3. Teeth remains exact open, sclera is exact open, upper eyelid remains exact
   closed; mechanics and siblings have zero borrowed weight.
4. Model/admission inventories are exactly 61 fields, five unchanged presets,
   73 renderer cases, three disabled Demo rows and independent 0/1/2 demands.
5. Checker self/live/privacy and T-62-01 through T-62-08 isolated modes pass;
   missing, skipped or foreign assertions fail.
6. Full SwiftPM, explicit Demo, JSON, privacy and diff hygiene pass after owner
   synchronization.

## Validation Sign-Off

- [x] Every planned task has an automated owner or an explicit private/manual gate.
- [x] Sampling continuity has no three consecutive manual-only tasks.
- [x] Wave 0 contract, runner and mutation checker are green.
- [x] Licensed positive/negative original-detail review is accepted.
- [x] All eight HIGH threats pass in isolation.
- [x] Full SDK and Demo regression is green.

**Approval:** passed — all ten task rows and eight HIGH owners are green
