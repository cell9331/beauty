---
status: investigating_measurement_identifiability
trigger: "修复"
created: 2026-09-13
updated: 2026-09-15
---

## Symptoms

Expected: unchanged registered seven-active/one-deferred portrait gate passes,
with zero protected changes and genuine closeout evidence.
Actual: prior candidate 2 margins chin/root/negative mouth are 5/0/-7;
required margins are >=16/>=16/<=-16. All locality checks pass.
Reproduction: SDK-owned clean-65 driver, same authorized source and frozen ROI.
Timeline: prior two repair candidates and failures are preserved in
95-ROI-AMENDMENT.md. Owner now requests further repair and accepts the proposed
deferred FACE-01 test-contract disposition. No metric or ROI relaxation.

## Current Focus

2026-09-15 actual source-only coverage: two exact matching records, crest11/16,
contour3/16. Existing unextrapolated contour observations cannot meet minimum12
rows and do not label bilateral root sides. Automatic image/anatomy alternatives
are not claimed exhausted; extending/validating a new recognizer or obtaining
local source-boundary confirmation needs an explicit disposition. Owner question
sent. Do not weaken12-row coverage, threshold16, source identity or old ROI.
Forward same-source-material localization and actual canonical positive/negative
generated tests are implemented; JSON/cleanup/test-oracle findings independently
cleared inv3. Full portrait still6/7; no new source registration or portrait score.
See95-ROOT-ANATOMY-COVERAGE-OBSERVATION.json and95-ROOT-FORWARD-INTEGRATION.md.

2026-09-15 nonlinear correspondence implemented and independently reviewed.
All38 analytic true shifts contained;32/1024Q16 power2/2 each; negative/zero/
15/16/17/20 all0/2. Flat and brightness-ramp ambiguity remains admitted.
Actual-root integration3/0/0 with Python optimization enabled. Reviewer WR-01
found assert removal could bypass containment; fixed with unconditional exit
and independently cleared in v2, including exclusion and positive controls.
next_action: source-only anatomical registration and explicit format/error
admission for a versioned reviewed integration. Do not reuse the old edge
registrar unchanged: it commits a different luma/structural-edge definition.
No private scoring or frozen-contract/production change. Full portrait6/7,
Phase95 incomplete. See95-ROOT-NONLINEAR-MODEL.md and v1/v2 reviews.

2026-09-15 actual generated root applicability:2 new SwiftPM tests pass.
Current paired-eye root field exceeds +/-1px and is non-affine over some
five-sample windows (necessary uniform residual>0.05px). Actual canonical/PNG
RGB agrees with unrounded Double within one byte on256/512 neutral/half/full
grids. The affine prototype cannot be promoted as a complete root model.
next_action: implement larger non-affine correspondence or justified local
error bounds with measurement power; retain photometric ambiguity and require
source-only anatomy before portrait scoring. No intensity tuning is indicated.
See95-ROOT-APPLICABILITY.md. No production/private/frozen-contract changes.

2026-09-15 main resumed after nested CLI model incompatibility/context overhead.
No owned child remains. Replaced inward-only/one-channel draft (32Q16 power0/2)
with signed RGB affine-motion and gain/offset feasible-set clipping. Removed
arbitrary ambiguity cutoff and corrected truth claim to analytic fixture truth.
42 paired cases/84 true shifts contained;32Q16 power6/6,20Q16 power5/6;
-32/0/15/16/17 all0/6. No production/source/ROI/threshold/private scoring changes.
Independent exact-clipping review now clean:22 polytopes/97 prefix vertex-set
comparisons,1172 active-set checks and no findings. Final main self-test passes
all42 pairs and the added error-widening/invalid-input controls.
next_action: validate suitability for non-affine root motion and source-only
anatomy before any metric freeze; do not rerun the generic model investigation.

Latest 2026-09-15 continuation: exact subpixel local-translation experiment
implemented and independently reviewed,126 sampler cases/7 negatives and118
independent exact-set checks. Selected canonical sRGB/PNG reference now checks
unrounded Double error <=1 byte and is independently clean; related SwiftPM
21/0/0. See95-ROOT-SUBPIXEL-MODEL.md and both SUBPIXEL-REVIEW reports. Current
next_action: address spatially varying motion and photometric/source
identifiability before source registration. Do not promote the translation
prototype or use production field vectors as independent motion truth.
No private portrait access/scoring, no production or frozen metric edits.

Earlier affine draft:10 containments/four rejected controls, but0/2 at32Q16.
Its coordinate-ramp oracle was incorrectly called independent; it reused the
fixture motion formula. Current signed successor uses explicitly analytic truth
and does not claim independent image-formation or portrait evidence.

2026-09-15: owner requested first-principles investigation and industry sources.
Independent generated probe/review confirms an additional identifiability
problem: frozen spatially varying blur admits zero-motion explanations for a
known four-pixel contraction. Actual widths112/108, true512Q16, conservative
margin-594. Independent review warning on truth binding was fixed and cleared;
identity/expansion substitutions both reject. Current next_action: validate
actual CPU sampling uncertainty and end-to-end near-threshold measurement power
before developing/freezing a successor. Do not wait solely for manual boundary
confirmation: it would not solve this second problem. Details and research links:
95-ROOT-FIRST-PRINCIPLES.md. No portrait access/scoring or production edits.

### Prior checkpoint (2026-09-14)

2026-09-14 resumed at owner's request to finish the milestone. A bounded
source-only diagnostic preserved every predicate and changed only thrown
diagnostic labels in memory; it exited2 at `remote_competing_edge`. Pinned
registrar inputs and compiler/OS identity matched before/after. No raw geometry,
pixels or child transcript persisted; no registration or score was credited.
This locates the ambiguity in the source edge-dominance check, not in output
effect strength, transport, localization rounding or a native timeout.
Archive-first all-opt-in SwiftPM completed as pre-closeout regression:
914 tests / 0 failures / 0 skips, all eight opt-ins; actual Metal parity passed.
Complete gate snapshot matched before/after:
7e5fef4b275485b13ef414a9cae2fc0f78c7dd7c8d23a2c298bef78181be0002.
Its result cannot replace the missing portrait/goal acceptance. Aggregate record:
95-RESUMED-REGRESSION-2026-09-14.json. No completion receipt was issued.

hypothesis: independently confirmed legacy dark-centroid metric can reverse
true narrowing and accept brightness-only changes. Earlier wall-coverage
hypothesis alone was insufficient; candidates 7–10 all failed the old metric.
test: generated-only source-anchored edge intervals, explicit nuisance bounds,
independent geometry truth and identity mutation rejection.
next_action: obtain an explicit alternative source-registration disposition;
the frozen automatic registrar returns ambiguous_structure on the same source.
Generic math, adapter and transport have passed independent reviews; actual v3
source run exits2 without registration. No new portrait scoring is admitted.
Do not retune frozen constants or reinterpret a diagnostic as successful registration.
Owner explicitly authorized early independent review and measurement revision;
the unchanged ROI/threshold/source/history are mandatory. Initial review is
95-ROOT-METRIC-REVIEW.md (2eb0dee0); it is not final repair approval.
Candidate 6 remains the last complete portrait result: chin 23, six active passes,
root -2 failure. Candidate 10 single-case old margin -12 also remains failed.
Current ordinary SwiftPM: 913 tests / 0 failures / 8 opt-in skips after cleanup.
Comparator identity self-test 597 passes. Draft 1's 250 checks did not catch
three independently reproduced blockers (a74b8c33). Draft 2 fixes them and passes
346 checks; repaired generated crossing oracle plus focused suite passes 11/0/0.
Live v1 driver intentionally refuses changed comparator;
do not overwrite v1 registration to bypass a versioned amendment.

## Evidence

- Previous 117 focused tests passed; full 904 had eight opt-in skips and eight
  assertions in the pre-existing FACE-01 deferred test, reproduced on HEAD.
- No Serena callable is available. GSD debugging is performed inline under the
  skill's no-subagent fallback; symptoms and owner authorization are already known.
- Candidate 3: 106 focused/0 failures/0 skips; full 906/0 failures/8 opt-in
  skips. Two identical 65-case attempts, five active passes. Chin/root 14/0
  still fail; negative mouth -32 passes; every protected/outside delta is zero.
- Candidate 4: fresh workspace focused 22/0/0. Full SwiftPM exited zero;
  trailing buffered aggregate output prevented retaining the all-tests count,
  so no exact new full-suite count or no-skip pass is inferred from that tail.
  Comparator self-test 589, clean driver 16, boundary self-test/live and no-skip
  wrapper self-test 10 mutation rejections all pass. Frozen comparator and
  manifest SHA256 identities remain unchanged.

## Resolution

Pending. Initial metric defect review exists; no final success review is claimed.
Candidate 5: focused 23/0/0, boundary/diff pass; two reconciled 65-case attempts,
five active passes, every outside/protected delta zero. Details and exact hashes
are in 95-REPAIR-RESUMPTION.md. No further internal-bound change is implemented.
