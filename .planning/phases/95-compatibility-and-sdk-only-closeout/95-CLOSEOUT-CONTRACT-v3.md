# Phase95 v3 closeout contract

2026-09-22. Successor tooling specification, not an acceptance receipt.

## Stable acceptance boundary

Seven active directions: chinTaper, gazeCorrection, eyebrowHeadSpacing ±,
noseBridge, noseRootNarrowing, mouthWidth negative. faceContourSmooth alone
remains deferred/partial. Preserve same authorized source, ROI, ±16 Q16
semantic floors, protections,62 fields/5 presets/75 renderer cases, SDK-only,
CPU/GPU and owner-local privacy boundaries. No device or distribution gate.
Historical Phase89–94 completion does not accept modified source.

## Measurement admission

Legacy dark-half centroid v1/v2 portrait classification cannot close v1.22.
Before any v3 portrait run, an independent reviewer must approve a source-only,
reproducible anatomical registration and actual successor dispatch/identity wiring.
95-ROOT-MEASUREMENT-ADMISSION.json uses the strict schema implemented by
scripts/phase95-closeout-evidence.py: same source and original registration digest,
12..16 registered rows, rootStructuralEdgeSpanQ16_v3, definition and registration
commitments, exact five implementation identities and derived measurement identity.
This is a prospective transport contract, not an implemented registrar or scorer.
No such admission currently exists. Counts or image edges alone cannot prove anatomy.
Do not populate its hashes from invented/manual-unconfirmed labels. Existing
ambiguous/coverage-only records and generic freezes cannot substitute for it.
The independently reviewed classifier must execute all original source/neutral/
sibling/signal/protection predicates and propagate the admitted root identity into
phase95-clean-65-v3. Merely renaming the old metric or report is forbidden.

## Executed evidence

full-closeout must execute both RepairedControlSafetyTests and
RepairedControlCompatibilityTests with exact nonzero method discovery, no failures
or skips. These tests alone are not complete SAFE-01/COMPAT-01 proof: independent
implementation and goal reviewers inspect the full suite and current coverage of
neutral identity, malformed/missing/stale support, recovery, caps, determinism,
protected regions, orientation/extent/color/alpha, privacy and proxy-free support;
and defaults/Codable/presets/cases/facades/backend/boundary/non-target behavior.
Missing coverage is a blocker requiring additional real-pixel tests, not a PASS flag.

Run the reviewed portrait driver/classifier for65 outputs,7 active passes,1 deferred,
2 reconciled attempts, then wrapper self-test and actual archive-first full no-skip
SwiftPM with eight opt-ins exactly once. Validate live transcript totals, stage order
and same input/review/portrait hashes before writing CHECKS/BINDING-v3.

## Snapshot and review lifecycle

The v3 normative snapshot includes package, all source/tests/scripts, original ROI
registration, this contract, root admission when present, historical90–94 artifacts,
and AGENTS/DESIGN/ARCHITECTURE/SECURITY/RELIABILITY/PRODUCT_SENSE/taxonomy.
PLANS and QUALITY_SCORE are mutable reporting ledgers: their hashes are retained in
binding.ledger_snapshot for historical reference but not current admission. STATE,
ROADMAP and REQUIREMENTS checkboxes are administrative views, not evidence.
The stable requirements above cannot be relaxed by editing an excluded ledger.
Changes to normative contracts or implementation require a fresh review and execution.
No v1/v2 receipt is promoted to v3 or rewritten. Receipt files remain exclusive.

Implementation review binds the input digest with an independently supplied reviewer
identity and zero unresolved findings. Final goal verification must have a distinct
reviewer, bind exact CHECKS/BINDING/portrait/implementation-review hashes and input
digest, and affirm SAFE-01, COMPAT-01, CLOSE-01 against actual wiring/coverage.
Reviewer identity is a local workflow attribution, not a cryptographic signature;
validators check consistency, while independent authorship remains a workflow duty.
Executors must not manufacture either review. Generated tests use temporary synthetic
records only, never publish approval or completion to the actual phase directory.

## Finalization

`python3 scripts/check-phase95-closeout.py finalize` reads fixed95-GOAL-VERIFICATION.json
and verifies all preceding predicates. It rechecks inputs then atomically publishes
exclusive95-COMPLETE.json by same-filesystem link from a flushed temporary file.
Missing/duplicate/nonfinite/wrong-type/stale evidence or failed coverage rejects;
an interrupted unpublished write cannot produce a partial completion file. An existing
receipt is never overwritten. No Swift child is rerun by finalize. Later reporting-only
ledger updates do not revoke success; relevant code/contract changes invalidate current
acceptance, preserving the historical result. Full-closeout itself is never completion.
