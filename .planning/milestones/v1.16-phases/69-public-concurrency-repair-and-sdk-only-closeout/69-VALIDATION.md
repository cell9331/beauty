# Phase 69 Validation Contract

**Status:** Planning contract  
**Research:** Explicitly skipped by the user; this phase uses the existing Swift
6/SwiftPM/XCTest and repository-owned shell patterns.  
**Boundary:** Public conditional sendability, SDK-only static checks, and
archive/boundary/consumer/generated-CPU/no-skip closeout only.

## Decision Traceability

| ID | Locked decision | Owning plan |
| --- | --- | --- |
| D-01 | Conditional `BeautyResult` sendability only for `Output: Sendable` | 69-01 |
| D-02 | Public compile-time and runtime transfer proof plus source compatibility | 69-01 |
| D-03 | Static negative guard for arbitrary non-sendable payloads | 69-01, 69-02 |
| D-04 | Boundary self-test and mandatory gate ordering/rejection | 69-02 |
| D-05 | Synchronized current owners and ledgers | 69-03, 69-04 |
| D-06 | Aggregate-only durable evidence and nonclaims | 69-02..04 |

## Nyquist Matrix

| Requirement | Owning plan | Automated evidence | Required assertion |
| --- | --- | --- | --- |
| CONC-01 | 69-01 | `swift test --package-path BeautySDK --filter 'BeautyResultConcurrencyTests'`; `rg` source guard | `BeautyResult` has conditional `Sendable` conformance and no unconditional generic `@unchecked Sendable`. |
| CONC-02 | 69-01 | focused public test suite and full build | A concrete sendable result compiles through `T: Sendable`, transfers through an async task, preserves all fields, and existing `BeautyResult(output:)` source remains valid. |
| CLOSE-01 | 69-03, 69-04 | owner scans, `git diff --check`, final ledger checks | Root and planning owners agree on conditional sendability, SDK-only SwiftPM validation, and all nonclaims. |
| CLOSE-02 | 69-02, 69-04 | `bash scripts/check-sdk-only-boundary.sh --self-test`; `bash scripts/run-no-skip-swiftpm.sh` | Static mutations reject UI/Xcode/media/Metal drift and unconditional generic sendability; final mandatory child has positive execution, zero failures, and zero skips. |

Focused commands diagnose ownership; only the final conjunction closes the
phase:

```bash
swift test --package-path BeautySDK --filter 'BeautySDKTests.BeautyResultConcurrencyTests'
swift build --package-path BeautySDK
bash scripts/check-sdk-only-boundary.sh --self-test
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
bash scripts/check-swiftpm-consumer.sh
bash scripts/check-cpu-reference-oracles.sh
bash scripts/run-no-skip-swiftpm.sh
git diff --check
```

## Negative and Privacy Matrix

| Scenario | Expected result |
| --- | --- |
| `BeautyResult<SendablePayload>` passed to `T: Sendable` | Compiles and transfers through an async task without data loss. |
| `BeautyResult<NonSendablePayload>` tested against the old unconditional declaration | Boundary mutation self-test fails closed; the live source has no arbitrary-payload unchecked conformance. |
| Existing `BeautyResult(output: "ok")` construction | Compiles and preserves output/warnings/metrics/detection summary behavior. |
| Restored UI/Xcode, generated tracked media, stale backend/Metal, or unconditional result declaration | Boundary self-test or post-archive scan exits nonzero before downstream validation. |
| Missing optional private fixtures | Remains environment-gated and cannot lend success to generated or no-skip mandatory evidence. |
| Durable phase evidence | Contains only fixed identities, counts, codes, and scope/nonclaim text; never paths, child transcripts, raw outputs, pixels, masks, landmarks, support, or fixture metadata. |

## Dependency and Reachability

- `BeautyResult.swift` is imported through `BeautySDK` by the new public test;
  the compile-time assertion and task transfer therefore reach the shipped
  product surface.
- The boundary mutation writes only to a fresh temporary tree and invokes the
  same `validate_post_archive` function used by the live scanner.
- `run-no-skip-swiftpm.sh` invokes the boundary self-test and post-archive scan
  before its consumer, generated CPU preflight, private opt-ins, and one-child
  SwiftPM execution.
- Owner/ledger tasks consume only aggregate test counts and source/test inventory
  measured after code and gate changes; no task needs raw child output.

## Multi-Source Coverage Audit

| SOURCE | ID | Feature/Requirement | Plan | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| GOAL | — | Honest generic concurrency contract plus one hardened SDK-only closeout boundary | 69-01..04 | COVERED | Contract, tests, static guard, gate, and owner synchronization form the full path. |
| REQ | CONC-01 | Conditional generic `BeautyResult` sendability | 69-01 | COVERED | Source declaration and static live guard. |
| REQ | CONC-02 | Compile/runtime transfer and source compatibility | 69-01 | COVERED | Public-only XCTest plus task hop. |
| REQ | CLOSE-01 | Synchronized architecture/design/reliability/security/product/quality/planning owners | 69-03..04 | COVERED | Current owners first, measured ledgers second. |
| REQ | CLOSE-02 | Static drift rejection and zero-skip mandatory gate | 69-02..04 | COVERED | Mutation-tested boundary, wrapper ordering, and final aggregate. |
| RESEARCH | — | No research artifact | 69-01..04 | EXCLUDED | User explicitly selected research skip; no new dependency is introduced. |
| CONTEXT | D-01 | Conditional public declaration | 69-01 | COVERED | Exact source contract. |
| CONTEXT | D-02 | Public compile/runtime proof and compatibility | 69-01 | COVERED | Focused tests. |
| CONTEXT | D-03 | Static negative compile-contract guard | 69-01..02 | COVERED | Positive compile assertion plus mutation rejection. |
| CONTEXT | D-04 | Boundary and no-skip ordering | 69-02 | COVERED | Existing gate extended fail-closed. |
| CONTEXT | D-05 | Owner synchronization | 69-03..04 | COVERED | Root and planning owners. |
| CONTEXT | D-06 | Aggregate-only evidence/nonclaims | 69-02..04 | COVERED | Bounded scripts and docs. |

All GOAL, requirement, research, and context rows are covered; no unplanned
item remains in the phase source artifacts.
