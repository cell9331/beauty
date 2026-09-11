# Remaining runner — historical initial implementation review

```yaml
status: BLOCKED
scope: original_seeded_remaining_runner
blockers: 6
state: seed_only
event_count: 1
implementation_attempts: 0
negative_pixels: not_measured
native_review_execution: not_run
successor_review: pending
```

This records the six findings already reported from independent read-only inspection of the original `scripts/check-phase94-remaining.py`. It is not a review of Jason's concurrent repair. Line references below belong to the original seeded runner.

## Exact original identities

| Artifact | SHA-256 |
|---|---|
| Original seeded runner | `a72b2f3a0abb4bcef7340a85bd5be133612f0cfd3a9a9b4cf2684228ee6cd9ac` |
| 94-REMAINING-BINDING.json | `6b7785547dd2b74ce9ec2ff965e5fc2e77135f080cee8971bca033b52725470b` |
| 94-REMAINING-EVENTS.jsonl | `b92a2b38857999d9557eebed44df5a5f72bc0c49f1b94c08660a4fd2780c001a` |

The binding and event bytes were re-read solely to record these identities. History contains exactly one `seed` event, with zero implementation attempts and negative pixels not measured. The runner hash is the binding's exact value and matched the original runner during the initial inspection. Parent has requested preservation as `94-REMAINING-RUNNER-SEEDED.py`; that copy was not yet present in the phase or scripts directory when this record was written. No claim of having verified that future archive copy is made. The currently authoring runner was not reread or re-reviewed.

## Original blocking findings

```yaml
issues:
  - id: RR94-01
    severity: BLOCKER
    area: state_and_receipt_admission
    references: [history:220, control.select:423, control.begin:430]
    finding: >-
      History validates event names and hash linkage, but not state transitions or
      per-event data schemas. Select, begin and closeout consume standalone receipt
      JSON without reconciling it to its producing event and content hash. Begin 1
      checks decision policy A without revalidating the complete baseline, freezes
      and select chain. An isolated or replaced decision cannot be trusted as admission.
    minimum_fix: >-
      Validate explicit transitions and strict schemas; bind each decision/receipt to
      its unique producing event and exact content. Reject missing predecessor states,
      substituted receipts and unbound decisions before side effects.
  - id: RR94-02
    severity: BLOCKER
    area: measurement_identity
    references: [measure_lane:361, snapshot:246]
    finding: >-
      Measurement checks identities at entry and finalization, not between build,
      discovery and each test. Transient change followed by restoration can evade
      those checks and mix evidence identities. Snapshot checks frozen test bytes but
      does not recheck the stored test-review file hash.
    minimum_fix: >-
      Revalidate complete authorities, provider, frozen inputs, review identities and
      event prefix before and after every child; persist a hold on detected drift.
  - id: RR94-03
    severity: BLOCKER
    area: failure_latch_and_status
    references: [control.candidate-compile:445, control.status:410]
    finding: >-
      Candidate compile can publish a passing receipt before snapshot detects other
      input drift. That exception reaches the top-level rejection without persisting
      a hold; restored files can leave the passing receipt reusable. Status merely
      reports the last event and does not validate interruption, provider scope or
      current COMPLETE validity.
    minimum_fix: >-
      Complete all identity checks before success publication, persist a failure latch
      for failed in-flight admission, and make status validate the actual state and
      receipt chain. Interrupted, stale or drifted states must not report readiness.
  - id: RR94-04
    severity: BLOCKER
    area: admission_self_tests
    references: [self_tests:23]
    finding: >-
      Several of the advertised sixteen controls only compare hand-written dictionaries
      through exact(), or call need(False). Review/compile, historical/current drift,
      seal and closeout controls therefore do not exercise the corresponding real
      admission paths and can pass even if those protections are removed.
    minimum_fix: >-
      Exercise actual admission functions through an in-memory state/storage adapter.
      Establish a valid accepted control, then mutate each necessary field/state and
      require the intended rejection. Sixteen groups may contain multiple attacks;
      generic inequality and unconditional rejection are not coverage.
  - id: RR94-05
    severity: BLOCKER
    area: failure_counts
    references: [measure_lane:383]
    finding: >-
      classify() runs before executed/failed counts are updated. An ordinary XCTest
      failure, skip or unexpected error throws before counting the method, leaving an
      actually executed method reported as unexecuted in the hold record.
    minimum_fix: >-
      Separate parsing execution facts from acceptance classification. Reconcile
      trustworthy start/end/summary evidence before rejecting the outcome; represent
      uncertain completion explicitly rather than equating it with non-execution.
  - id: RR94-06
    severity: BLOCKER
    area: seeded_runner_revision
    references: [snapshot:252, seed:279]
    finding: >-
      Seed already binds this defective runner before the independent implementation
      review. Direct runner correction fails runner_drift, while editing/reseeding the
      original binding or history would violate immutable evidence requirements.
    minimum_fix: >-
      Preserve the exact original runner, binding and seed prefix. Use a parent-created,
      precisely hash-linked authoring disposition and independently reviewed successor
      admission for the corrected runner. Do not reset counters, rewrite old evidence
      or automatically authorize author-build through a general bypass.
```

## Next boundary

Parent will create the exact authoring disposition; independent successor review must pass before author-build is permitted. This document grants neither that approval nor permission to freeze or measure the parallel Swift authoring batch. Historical six-blocker status remains intact regardless of subsequent repair progress.

Only this new review file was written. No runner execution, native build/test, repair inspection, binding/event edit, commit or other agent's file change occurred while recording these findings.
