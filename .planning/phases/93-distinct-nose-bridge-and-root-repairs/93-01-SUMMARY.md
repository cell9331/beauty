---
phase: 93-distinct-nose-bridge-and-root-repairs
plan: "01"
subsystem: testing
tags: [swiftpm, nose, registration, bounded-evidence]
status: complete
tasks_completed: 3
tasks_total: 3
implementation_attempt: 1
attempt_status: open
requires:
  - phase: 93-planning
    provides: D-09 authorization and independently checked five-plan protocol
provides:
  - Bounded gate and immutable source/authority baseline
  - Independent in-memory source and additive Testing SPI cases
  - Verified old-root RED followed by four GREEN registration/regression methods
  - Fixed root positioning and immutable registration binding
affects: [93-02, 93-03, 93-04, 93-05]
tech-stack:
  added: []
  patterns: [bounded child capture, exact named discovery, immutable hashes, shared attempt ledger]
key-files:
  created:
    - scripts/check-phase93-nose-repair.py
    - BeautySDK/Tests/BeautyCoreTests/NoseRepairFixture.swift
    - BeautySDK/Tests/BeautyCoreTests/NoseFixtureRegistrationTests.swift
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-BASELINE.json
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-REGISTRATION.json
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-ATTEMPTS.md
  modified:
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
    - BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift
    - PLANS.md
    - .planning/STATE.md
key-decisions:
  - Retain the original baseline; use only the independently reviewed hash-linked gate amendment.
  - Open shared attempt 1 before the sole D-09 adapter correction and leave it open for subsequent plans.
  - Registration proves fixture alignment, not rendered semantic efficacy.
requirements-completed: []
requirements-addressed: [NOSE-01, NOSE-02]
duration: 38min
completed: 2026-09-10
coverage:
  - deliverable: Independent source, actual detector mapping and canonical/missing controls
    verification:
      - kind: test
        ref: NoseFixtureRegistrationTests/testSourceAnatomyRegistersIndependently
        status: pass
      - kind: test
        ref: NoseFixtureRegistrationTests/testMissingNoseAndCanonicalControl
        status: pass
    human_judgment: false
  - deliverable: Corrected root positioning with unchanged legacy/tip templates
    verification:
      - kind: test
        ref: NoseFixtureRegistrationTests/testAdapterMatchesSourceRootAndBridge
        status: pass
      - kind: test
        ref: FaceShapeWarpProviderTests/testFaceGeometryAdapterKeepsLegacyNoseAndAddsExplicitRootAndTipSupports
        status: pass
    human_judgment: false
  - deliverable: Bounded admission and source baseline
    verification:
      - kind: command
        ref: python3 scripts/check-phase93-nose-repair.py self-test
        status: pass
      - kind: command
        ref: python3 scripts/check-phase93-nose-repair.py authorities
        status: pass
    human_judgment: false
  - deliverable: Immutable registration binding with shared attempt 1 open
    verification:
      - kind: command
        ref: python3 scripts/check-phase93-nose-repair.py freeze-registration
        status: pass
    human_judgment: false
---

# Phase 93 Plan 01: Independent Nose Registration Summary

**The independently authored source now registers the corrected upper root and retained bridge supports; four named tests pass and the registration binding is frozen.**

## Accomplishments and evidence

All three tasks are complete. Both NOSE requirements remain active: this plan establishes registration and does not score rendered efficacy.

| Task | Verified result | Commit |
|---|---|---|
| 93-01-01 — gate and independent source | Initial self-test 50/0/0; reviewed amendment self-test 69/0/0; SwiftPM test build passed | `71f5fef3`, `09f92f5d`, amendment `8ececea9` |
| 93-01-02 — source, RED and fixed adapter correction | Fresh current-gate old-root RED: 3 discovered, 2 passed, exactly one named failure, 0 skips. After begin 1 and the sole root-Y correction: 4 discovered, 4 passed, 0 failures/skips | RED `c2f81b9d`; GREEN `08358ffc` |
| 93-01-03 — freeze registration | Four methods freshly repeated GREEN; regular hash-only registration binding created; authorities passed | `70542110` |

The source test verifies independent anatomical ordering, deterministic opaque sRGB carriers, literal checked floor/floor exclusive raster edges and textured protected guards. The real detector-to-adapter path verifies common source bounds, root/bridge membership, both prescribed source/cap-target radius envelopes, missing-nose rejection and canonical controls. The fourth method retains the original legacy/tip expected arrays and updates only the named root regression.

The only production algorithm change is the two approved root-Y literals in `noseRoot(in:)`. Its X values, cardinality, group admission and every other adapter helper remain byte-identical. The provider and its tests are unchanged. No gate, fixture, SPI, regression or source recipe was edited during the final production continuation.

## Shared candidate state and handoff

The append-only ledger has exactly **one begin event, attempt 1**, created before the adapter edit, and **zero finish events**. The joint candidate remains open for Plan 93-03 under the unchanged two-attempt ceiling. No efficacy claim or accepted-candidate finish is issued from registration.

Plan 93-02 has not run: no pixel oracle, semantic RED, provider amplitude mutation or later-plan test/artifact was created. The orchestrator may proceed to 93-02 to freeze actual-pixel RED at the registered adapter and original provider. Phase-wide independent code review and goal verification remain future obligations. The clean infrastructure review covers only the gate amendment/CR-01 correction.

## Current bindings

| Binding | SHA-256 |
|---|---|
| Effective reviewed gate | fcee37289aeba5d657179e2d5a6c02f1caf33a3c514d81887c59b6688a9778e0 |
| Original immutable baseline JSON | a95d281f619bdef97c85dd6935f10b1b2084bce5d795ae9890981692517f4c31 |
| Registration tests | 77a54acd34384fbb9a79e248aa50e95c90c3093d089f480aaac820bbf075d368 |
| Corrected adapter | cf191001ae1245a82b042cc54eaca63aa6b3ba2abeed40e86781bc056eb159d9 |
| Original unchanged provider | 0684e2689cd5f3b780a69f13f701339879c3f418691a586205f4dda028ea23c8 |
| Frozen registration JSON | 87d1990da6f2c6780dc2bff37784fcca20962ae88824238508f36e7c8d3a0f81 |

The registration JSON binds the original baseline, effective gate, fixture/SPI, registration test, corrected adapter and scoped existing regression; its counts distinguish three new methods from one retained regression. It records two prescribed envelope alternatives and pixel efficacy as unmeasured.

## Historical checkpoint and deviations

The checkpoint summary at `43a734fc` and all earlier ledger records remain history, not retroactive success. Before production, two test-build stops and a missing-support expectation failure were followed by verified exact old-root RED. The initial begin command then stopped at `source_scope` with **zero attempts started**, because whole-file literal replacement incorrectly required six unrelated fixture changes. Production adapter/provider bytes were original at that checkpoint; no rollback was needed.

- **[Rule 3 — test authoring]** Replaced an overloaded Swift assertion with an equivalent explicit loop after a row-stride rename alone did not resolve type checking. Source recipe and numerical assertions were unchanged.
- **[Rule 1 — test expectation]** Asserted the existing geometry detector's missing-nose rejection, then used its existing combined-purpose partial mapping to test adapter-local group isolation. No detection policy changed.
- **[Rule 1 — infrastructure, reviewed amendment]** The parent scoped regression validation to the named method and introduced `93-GATE-AMENDMENT.json`, preserving original baseline bytes and linking the previous/effective gate hashes. Independent review found CR-01: superseded-gate RED could still admit begin 1. A test reproduced the bypass; the precise effective-gate identity check fixed it. The current 69-case self-test and independent historical-prefix probes reject superseded receipts. The parent committed the clean reviewed amendment at `8ececea9`, then authorized continuation under the existing D-09 decision.
- **State tooling:** Earlier SDK blocker recording resynchronized unrelated parent frontmatter. Those collateral changes were restored. Final task progress is scoped to this plan; parent configuration, state.json, runtime and unrelated STATE edits remain preserved and unstaged.

The gate's later command mappings are implemented but await the future tests/artifacts specified by Plans 93-02 through 93-05; their missing prerequisites fail closed. No success-returning stub was found in this plan's files. No unresolved blocker remains for the completed 93-01 scope.

## Commits and timing

- `71f5fef3`: test(93-01): declare gate discovery and RED admission regressions
- `09f92f5d`: feat(93-01): bind bounded nose gate and independent source fixture
- `c2f81b9d`: test(93-01): prove independent anatomy and old-root registration RED
- `43a734fc`: docs(93-01): record pre-attempt gate checkpoint
- `8ececea9`: fix(93-01): scope regression admission and bind fresh gate receipts
- `08358ffc`: fix(93-01): register upper nose root with independent source anatomy
- `70542110`: test(93-01): freeze verified nose registration and open candidate binding

Started at the recorded 2026-09-10T06:48:22Z timestamp; completed on 2026-09-10 at approximately 07:26Z, about 38 minutes elapsed including checkpoint/review time. Nine planned task files, two progress owners and this summary were changed; the parent separately owns the three amendment/plan/review files. Completion metadata is committed separately.

## Privacy and scope

Durable evidence contains fixed statuses, counts, hashes and aggregate results only. Executable fixture/test sources retain the source recipe; no media, raw geometry, pixels, private locators or child transcripts were persisted as evidence. The local child/evidence boundary was already declared in the plan; no new network, auth or resource boundary was introduced. This is owner-local generated registration evidence, with no device, naturalness, commercial or external-distribution qualification.

## Self-Check: PASSED

Verified all six created task files, the summary and seven preceding task/amendment/checkpoint commits exist. Current immutable hashes agree, production diff is exactly the approved two-line adapter correction, the provider remains original, and the registration binding records four passing methods. The ledger contains one open attempt and no finish. No later-plan artifacts exist. This self-check establishes 93-01 completion only.
