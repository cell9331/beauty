---
phase: 93-distinct-nose-bridge-and-root-repairs
plan: "01"
subsystem: testing
tags: [swiftpm, nose, registration, bounded-evidence]
status: checkpoint
tasks_completed: 1
tasks_total: 3
implementation_attempt: 0
requires:
  - phase: 93-planning
    provides: D-09 authorization and independently checked five-plan protocol
provides:
  - Bounded gate and immutable source/authority baseline
  - Independent in-memory source and additive Testing SPI cases
  - Verified source and old-root registration RED
affects: [93-02, 93-03, 93-04, 93-05]
tech-stack:
  added: []
  patterns: [bounded child capture, exact named discovery, immutable hashes]
key-files:
  created:
    - scripts/check-phase93-nose-repair.py
    - BeautySDK/Tests/BeautyCoreTests/NoseRepairFixture.swift
    - BeautySDK/Tests/BeautyCoreTests/NoseFixtureRegistrationTests.swift
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-BASELINE.json
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-ATTEMPTS.md
  modified:
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
    - BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift
    - PLANS.md
    - .planning/STATE.md
key-decisions:
  - Keep the frozen gate and source unchanged after admission rejected an overbroad regression comparison.
  - No implementation attempt starts without a successful begin event; D-09 approval remains valid.
requirements-completed: []
requirements-addressed: [NOSE-01, NOSE-02]
duration: 22min
checkpoint_date: 2026-09-10
coverage:
  - deliverable: Independent source, mapping and canonical/missing controls
    verification:
      - kind: test
        ref: NoseFixtureRegistrationTests/testSourceAnatomyRegistersIndependently
        status: pass
      - kind: test
        ref: NoseFixtureRegistrationTests/testMissingNoseAndCanonicalControl
        status: pass
    human_judgment: false
  - deliverable: Gate self-tests and source baseline
    verification:
      - kind: command
        ref: python3 scripts/check-phase93-nose-repair.py self-test
        status: pass
    human_judgment: false
---

# Phase 93 Plan 01: Nose Registration — Checkpoint Summary

**Independent source registration proves the old root mismatch; a frozen gate comparison defect blocks attempt admission before any production correction.**

## Status and task results

- Task 93-01-01: complete. Gate self-test passed 50/0/0; SwiftPM test build passed. The independent 512-square opaque sRGB source and two additive SPI cases are bound with original Git blobs, hashes, inventory and dirty-file digests.
- Task 93-01-02: incomplete, checkpoint after verified RED. Three named methods each discovered once: 2 passed, 1 expected failure, 0 skips. Only `P93_ROOT_PLACEMENT` failed. Source anatomy, floor/floor exclusive raster regression, source/bridge envelopes for both prescribed alternatives, and missing/canonical controls passed. The named existing adapter regression now expects the approved correction; its original shared/malformed fixtures remain unchanged.
- Task 93-01-03: not started. No registration freeze exists.
- Implementation attempts started: **0/2**. `begin --attempt 1` stopped before creating a begin event. No adapter/provider production edit, rendered candidate, semantic score or later plan was executed.

## Commits

1. `71f5fef3` — test(93-01): declare gate discovery and RED admission regressions
2. `09f92f5d` — feat(93-01): bind bounded nose gate and independent source fixture
3. `c2f81b9d` — test(93-01): prove independent anatomy and old-root registration RED

Checkpoint metadata is committed separately. Work began at the recorded 2026-09-10T06:48:22Z timestamp and stopped at approximately 07:10Z. Nine task/progress files were touched, plus this summary; neither production adapter nor provider was changed.

## Precise blocker and continuation

`source_scope` in the frozen gate computes the permitted regression file with whole-file literal replacement. The literals also occur in unrelated shared and malformed-root fixtures; this erroneously demands six additional line changes outside the named adapter regression. The actual two-line edit obeys the plan and therefore fails that incorrect comparison.

The gate's hash was already bound by initialize. Plan 93-01's execution refinements prohibit rewriting the gate or earlier bindings after freeze. No attempt was made to change those unrelated fixtures, weaken the comparator, regenerate the baseline, tune source geometry/radii, or bypass admission. This is an infrastructure stop, not a registration impossibility or semantic failure.

Continuation needs an orchestrator-authorized amendment that confines this comparison to the named regression method and explicitly handles the frozen gate/baseline binding while retaining the failed record. D-09 does **not** need renewed approval. After that amendment, reverify source and exact old-root RED, admit shared attempt 1, apply only the approved adapter correction, run four GREEN registration/regression methods and freeze registration. Do not start 93-02 before that succeeds.

## Evidence and unchanged production

| Binding | SHA-256 |
|---|---|
| Gate | b2401be9ec23e331e034ec18655349db5eb1fcd03c875fa70dd4a2bfd80b6d1f |
| Baseline JSON | a95d281f619bdef97c85dd6935f10b1b2084bce5d795ae9890981692517f4c31 |
| Registration tests | 77a54acd34384fbb9a79e248aa50e95c90c3093d089f480aaac820bbf075d368 |
| Unchanged adapter | 7b3ca8d3dafad4068a49ee6fae963183601e59d10bb5eb40b0fdd8ee7f3e515d |
| Unchanged provider | 0684e2689cd5f3b780a69f13f701339879c3f418691a586205f4dda028ea23c8 |

The append-only ledger retains two compile stops, the initial missing-support test-authoring stop, the exact accepted old-root RED, and the failed begin admission. It contains zero begin events. Adapter/provider hashes were checked against their admitted original blobs: both exact, so no production rollback was necessary. Original provider 16/0/0 remains the orchestrator's historical baseline, not newly measured pixel evidence.

## Deviations from Plan

- [Rule 3 — test-authoring blocker] Simplified an overloaded Swift assertion after a type-check failure. A local row-stride rename alone did not resolve it; the equivalent explicit loop compiled. Source recipe and numeric assertions were unchanged.
- [Rule 1 — test expectation] The normal geometry detector intentionally discards a missing-nose observation. The test now asserts that rejection, then uses the existing combined-purpose partial mapping to verify adapter-local group isolation. No detection or SPI production policy changed.
- [Unresolved gate bug] The immutable regression comparison described above prevents Task 2 completion. No gate edit or binding replacement was performed.
- The SDK blocker handler resynchronized unrelated STATE frontmatter from stale session fields. Those collateral changes were reverted to the exact pre-call orchestrator frontmatter; only the added checkpoint blocker is retained and staged. Config, state.json, runtime and orchestrator progress changes remain unstaged and preserved.

## Deferred Issues / Known Limitations

The gate's later command mappings are authored but have not been exercised against the future tests. The demonstrated admission bug prevents claiming the complete gate protocol works. No stub supplies success: missing future artifacts return nonzero. No semantic effectiveness, phase completion, independent code/goal review, device quality or external-distribution claim is made. Owner contract promotion remains with the later plans.

## Privacy and threat review

Only executable fixture/test sources contain source geometry. Durable evidence contains fixed identities, statuses, bounded counts and hashes. No media, raw geometry, pixels, private locators or child transcripts were written as evidence. The local child/evidence boundary is the one already declared in the plan; no additional network, auth or schema boundary was introduced.

## Self-Check: PASSED

Verified the five created task files and this summary exist; all three implementation/test commits resolve. Baseline/gate hashes match, production adapter/provider are unchanged, and the ledger has zero begin events. Registration freeze is intentionally absent. This self-check verifies the checkpoint record, not plan completion.
