---
phase: 59
slug: teeth-evidence-and-admission-contract
status: in_progress
nyquist_compliant: true
wave_0_complete: true
created: 2026-08-05
updated: 2026-08-07
security_standard: OWASP ASVS Level 1
block_on: HIGH
requirements: [SEQ-01, EVID-07, TEETH-07, TEETH-08]
---

# Phase 59 — Validation Strategy

Phase 59 validates one exact state: independently accepted teeth evidence opens
only a trailing normalized intent scalar and one opaque request-local demand.
It does not validate visible whitening, provider safety, rendering, Demo
activation, or product promotion.

## Infrastructure and invariants

| Property | Owner |
| --- | --- |
| Evidence | Phase 54 dependency-free ReviewCore and canonical serializer ledger |
| Local evidence | Private ignored-bundle runner; fixed output only |
| SDK | SwiftPM XCTest for model, admission, preset, lifecycle, and renderer boundaries |
| Demo | Explicit iOS Simulator XCTest/build for disabled taxonomy and nil mappings |
| Security | Eight exact HIGH threats, `block_on: HIGH` |
| Static gate | Standard-library Python checker with mutation self-test and isolated threat modes |
| Hygiene | Repository-wide tracked/staged privacy scan plus `git diff --check` |

The checker selects evidence by exact feature/polarity/fixture identity, not
array position. Exact schemas allow fixed `mask_coverage` and
`protected_leakage` judgments and reject all extra evidence fields. Mechanics
metrics remain corroboration only and cannot alter admission.

## Per-task verification map

| Actual task ID | Wave | Requirements | Automated evidence | Status |
| --- | ---: | --- | --- | --- |
| `59-01-01` | 1 | SEQ-01, EVID-07, TEETH-07, TEETH-08 | Evidence contract, checker self-test, privacy mutations | passed; original closed branch |
| `59-01-02` | 1 | SEQ-01, EVID-07 | Canonical decision and frozen review gate | superseded by 59-05 accepted evidence |
| `59-01-03` | 1 | SEQ-01, EVID-07 | Serializer projection and sibling preservation | passed; original closed projection |
| `59-02-01` | 2 | TEETH-07 | Parameter compatibility tests | superseded by 59-06 open branch |
| `59-02-02` | 2 | TEETH-08 | Resolver and lifecycle tests | superseded by 59-06 open branch |
| `59-03-01` | 3 | SEQ-01, TEETH-07, TEETH-08 | Preset, renderer, lifecycle, Demo boundaries | passed; absence baseline |
| `59-03-02` | 3 | SEQ-01, EVID-07, TEETH-07, TEETH-08 | Checker live mode and exact inventories | passed; absence baseline |
| `59-04-01` | 4 | SEQ-01, EVID-07, TEETH-07, TEETH-08 | Owner/requirement/threat equality | passed; blocker recorded |
| `59-04-02` | 4 | SEQ-01, EVID-07, TEETH-07, TEETH-08 | Full SwiftPM and Demo regression | passed; original branch |
| `59-05-01` | 2 | SEQ-01, EVID-07 | Private adapter, ReviewCore, exact open serialization | passed |
| `59-05-02` | 2 | SEQ-01, EVID-07 | Tracked/staged privacy migration and ledger verification | passed |
| `59-06-01` | 3 | TEETH-07 | Exact trailing 60-field model/Codable contract | passed |
| `59-06-02` | 3 | TEETH-08 | Direct normalized positive input creates one demand | passed |
| `59-07-01` | 4 | SEQ-01, TEETH-07, TEETH-08 | Five presets, 72 renderer cases, three disabled Demo rows | passed |
| `59-07-02` | 4 | SEQ-01, EVID-07, TEETH-07, TEETH-08 | Exact-open checker, mutations, isolated HIGH modes | passed |
| `59-08-01` | 5 | SEQ-01, EVID-07, TEETH-07, TEETH-08 | Five root owner documents only | planned |
| `59-09-01` | 6 | SEQ-01, EVID-07, TEETH-07, TEETH-08 | Full regression, lifecycle handoff, final decision | planned |

Task count equality target: **17 task IDs = 17 validation rows**.

## Exact gates

1. Reproduce the canonical ledger through the private runner with local evidence
   required; compare serializer bytes exactly.
2. Run the Phase 54 and Phase 59 evidence contracts.
3. Run checker self-test, decision, evidence, privacy, live, and each isolated
   `--threat T-59-01` through `T-59-08` mode.
4. Run focused and full SwiftPM tests, then explicit Demo tests/build.
5. Verify unchanged preset/renderer/Demo production paths against the pre-gap
   baseline, owner synchronization, GSD gates, JSON validity, and diff hygiene.

No skipped or unrun HIGH gate is green. A later broad pass cannot replace a
missing private-evidence, privacy, or isolated-threat result.

## Nonclaims

The admitted scalar does not establish product effectiveness, visible output,
provider/mask/transform safety, realtime behavior, population coverage,
performance, Demo activation, or release readiness. Those remain later-phase
responsibilities.
