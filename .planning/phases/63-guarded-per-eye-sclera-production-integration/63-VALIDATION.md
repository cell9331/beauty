---
phase: 63
slug: guarded-per-eye-sclera-production-integration
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-08-07
security_standard: OWASP ASVS Level 1
block_on: HIGH
requirements: [SCLERA-09, SCLERA-10, SCLERA-11, SCLERA-12, SCLERA-13]
---

# Phase 63 — Validation Strategy

> Validate a stateless per-eye guarded still-image provider and its production
> integration. Phase 64 output promotion and adversarial closeout remain out of scope.

## Test Infrastructure

| Property | Value |
| --- | --- |
| Framework | SwiftPM XCTest, Python standard library, Node fixed-output runner, Xcode XCTest |
| Config file | Existing `BeautySDK/Package.swift` and `BeautyDemo.xcodeproj` |
| Quick run | `swift test --package-path BeautySDK --filter BeautyScleraRednessProviderTests` |
| Security run | `python3 <phase checker> --self-test` then focused live modes |
| Full suite | `swift test --package-path BeautySDK` plus explicit Demo build/test |
| Estimated quick latency | under 60 seconds on the current host |

## Sampling Rate

- After every task commit: run the task's focused XCTest or checker command.
- After every plan wave: run all completed Phase 63 focused suites and checker modes.
- Before closeout: run the required private pair, all eight isolated HIGH modes,
  full SwiftPM and explicit Demo build/test.
- Maximum intended feedback latency is 60 seconds for focused checks; no three
  consecutive tasks may rely only on manual evidence.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirements | Threat Ref | Secure behavior | Test type | Automated owner | Status |
| --- | --- | ---: | --- | --- | --- | --- | --- | --- |
| 63-01-01 | 01 | 1 | SCLERA-09/10/11 | T-63-01/02/03/04 | actual support, per-eye guard and reclip frozen before source | RED XCTest | provider filter | expected RED; missing Phase 63 source only |
| 63-01-02 | 01 | 1 | SCLERA-12/13 | T-63-05/06/07/08 | bounded transform, lifecycle/private/security contracts frozen | RED + mutation | integration/private filters + checker self-test | expected RED; checker 8/8 green |
| 63-02-01 | 02 | 2 | SCLERA-09/10/11/13 | T-63-02/03/04 | independently validated per-eye hard envelopes and local abstention | XCTest | provider filter | pending |
| 63-02-02 | 02 | 2 | SCLERA-11/12 | T-63-04/05 | post-feather containment and immutable-source target/Q16 once | XCTest + checker | provider/composition filters | pending |
| 63-03-01 | 03 | 3 | SCLERA-09/13 | T-63-01/02/06 | one provider request, stable units, teeth/sclera shared composition | XCTest | engine integration filters | pending |
| 63-03-02 | 03 | 3 | SCLERA-09/13 | T-63-02/06/08 | per-eye failure/recovery and deferred-route absence | XCTest + checker | lifecycle filters + integration mode | pending |
| 63-04-01 | 04 | 4 | SCLERA-10/11/12/13 | T-63-03/04/05/07 | private actual-Vision positive/negative frozen bounds and privacy | private XCTest + checker | Phase 62 runner + eight threats | pending |
| 63-04-02 | 04 | 4 | all five | T-63-01...08 | full regression, owners and Phase 64-only handoff | full regression | SwiftPM + Demo + inventories | pending |

Task count equality target: **8 task IDs = 8 validation rows**.

## Wave 0 Requirements

- `BeautyScleraRednessProviderTests.swift` freezes support, guard, score,
  reclip, transform and peer-isolation behavior before production source.
- `BeautyEngineScleraRednessIntegrationTests.swift` freezes one-request,
  independent activation and lifecycle behavior.
- `BeautyScleraRednessRealFixtureTests.swift` freezes aggregate bounds before
  actual private output execution.
- `check_phase63_sclera_provider_boundaries.py --self-test` proves at least one
  failing mutation for every T-63-01 through T-63-08.

Wave 0 is complete only after Plan 63-01 produces intended RED XCTest failures
for missing production seams and a green checker self-test.

## Manual-Only Verifications

None in Phase 63. The already accepted original-detail review is reused only as
private input authority; all Phase 63 production acceptance has automated fixed
aggregate checks. Phase 64 owns new final visual review.

## Exact Final Gates

1. Provider and transform tests cover threshold sides, deterministic rounding,
   protected anatomy, post-feather reclip and peer independence.
2. Engine tests prove one canonical Vision request, one provider invocation,
   one composition and independent teeth/sclera activation and recovery.
3. Required private runner executes the authorized pair through actual Vision;
   absence, ambiguity, skip or unclassified child status blocks.
4. Checker self/live and exact T-63-01 through T-63-08 isolated modes pass.
5. Tracked/staged privacy, exact 61 fields/five presets/73 renderer cases/three
   disabled Demo rows, full SwiftPM and explicit Demo build/test pass.
6. Decision D-01...D-16, requirement, task, threat, plan, summary and owner
   inventories agree before Phase 64 handoff.

## Validation Sign-Off

- [x] All tasks have an automated verify command or Wave 0 dependency.
- [x] Sampling continuity has no three consecutive tasks without automation.
- [x] No watch-mode command is used.
- [x] `nyquist_compliant: true` is set.
- [x] Wave 0 contracts are implemented and green/expected RED as appropriate.
- [ ] All eight HIGH threats and final regressions pass.

**Approval:** pending execution
