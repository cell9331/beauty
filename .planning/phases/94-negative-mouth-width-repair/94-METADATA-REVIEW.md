# Phase 94 independent metadata-recovery review

```yaml
status: PASS
scope: exact_metadata_test_patch_and_successor_gate
blockers: 0
issues: []
self_test: {passed: 17, failed: 0, skipped: 0, exit_code: 0}
status_check: {state: ready_for_fresh_baseline, exit_code: 0}
native_acceptance: not_run
phase_complete: false
implementation_attempts: 0
```

## Reviewed identities

Independently checked current bytes:

| Artifact | SHA-256 |
|---|---|
| Metadata runner | `32d982b3d5cc35c733b2bdda6b59b6603700aa19aacdb7a601898583ca62de18` |
| Metadata amendment | `244e499c515fc79f13ec7c80344cd34b02235370d5baf7492c9d903282363ca9` |
| Public test after patch | `b06820a45a24f398042f5c1714b3b8c202a2a076f510f8ceacc666990ff1c282` |
| Frozen oracle | `5d5b2a9f98a427ed189c2625951e23961c31e794a5875367fac61e9c91622d0c` |

The previously reviewed public-test before hash is `74ba99d798cf3f05808f065a677dda3c816b757b6bdf69f88ebeec04110b1c77`. The current git diff retains exactly the reviewed metadata correction.

## Findings

**Exact exception, preserved failures.** Admission requires the original authority chain, exact compile amendment, and complete compile-event hash `12034279d402cd4e6fc8b790a8c3a6e14ec588d2877d13da8d52ea189fcd1eba`. That history contains registration GREEN 3/0/0, then baseline discovery 9 with executed 7, passed 6, failed 1, skipped 0 and unexecuted 2; its terminal classification remains `assertion_failure`, stage `test`, exit 1. This is not an exemption for arbitrary assertion failures. Both earlier runners, the original binding/events, and compile amendment/events match commit `5e680ebb` byte-for-byte. No original receipt is substituted or overwritten.

**Swift patch is narrowly bound.** The runner requires the entire after hash, reverses each exact patch fragment once, then requires the entire before hash. Only `lipColor_0p50` admits an optional color-space tag; a present tag must be RGB with three components. Neutral and emitting-geometry checks remain strict. Optional-tag equality covers wrappers and repeats, including legacy repeats transitively. Named-sRGB extraction, source, oracle, pixel thresholds, alpha, extents, detector counts and digest assertions are unchanged.

**Source-backed correction, not inferred effect failure.** The existing color pipeline returns filtered/composited CIImage output for lipColor; the geometry pipeline's empty-point guard bypasses the explicit Device RGB bitmap construction. Repository source does not promise a particular concrete tag for that color-only graph. The parent-reported diagnostic identifies the line-143 color guard, not the precise failing row by itself. Both diagnostic invocations, including the first incomplete parser result, remain explicitly parent provenance. The parent-confirmed successful post-patch build has zero tests and `acceptance=false`; this review did not reproduce it or infer an effect failure.

**No hash substitution in delegated checks.** The two compile-runner module instances are loaded from verified bytes. Rebinding changes only the successor's identity/output paths and authority/history functions; hashing, file reads, child classification, method selection and thresholds are not replaced. Original checks still read actual original files. Original measured inputs are checked except for the public test, whose sole exception is the exact reversible patch; the oracle remains pinned.

**Nine fresh methods remain mandatory.** An empty successor history inherits permission to start baseline only from the hash-bound actual registration GREEN; it creates no synthetic registration events. The delegated baseline lane still builds, discovers and executes all three registration methods, two oracle methods, two public methods and two retained provider methods. Previous partial passes cannot replace these executions. Exact discovery, anchored filters, zero failures/skips, nine passed methods and complete aggregate records are required for GREEN.

**Later failure or drift blocks continuation.** Source/input and history identities are rechecked before children and before finalization. A failed lane records a successor terminal hold; no subsequent restart transition is admitted. Interrupted started histories also prevent automatic resumption. Status validates current hashes and receipts rather than trusting an old GREEN. New events and exclusive baseline receipt use only `94-METADATA-*` paths, with amendment, original binding/history, successor prefix, inputs, counts and records linked and checked. Receipt content remains MOUTH-01 incomplete and negative pixels not measured.

**Privacy and bounded execution remain intact.** The pinned child helper retains memory-only pipes, 8 MiB capture limits, finite child deadlines, process-group cleanup and sanitized classifications. The baseline retains its 2130-second envelope and exact result/count admission. Persisted records remain allowlisted aggregates/hashes, with no raw child diagnostics. These child behaviors were inspected, not exercised in this review.

## Verification and limits

Ran only `python3 scripts/check-phase94-metadata-recovery.py self-test` and `python3 scripts/check-phase94-metadata-recovery.py status`: 17/0/0 and `ready_for_fresh_baseline`, both exit 0. These paths perform pure in-memory checks and read-only snapshots, with no native children or evidence writes. Static review covered the delegated lane and receipt logic as well as the new code; self-test success alone was not treated as acceptance proof.

PASS applies only to the identities above and this routine infrastructure correction. Fresh baseline acceptance remains outstanding; MOUTH-01 and Phase 94 remain incomplete, attempts 0/2. Only this review file was written; no native run, source/gate/amendment edit, commit or change to another agent's work was made.
