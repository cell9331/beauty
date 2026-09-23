---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-22T07:24:09Z
depth: standard
files_reviewed: 3
files_reviewed_list:
  - scripts/phase95-root-mesh-topology.py
  - scripts/test-phase95-root-mesh-topology.py
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-MESH-FEASIBILITY.md
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
private_source_permission: false
model_runtime_admission: false
measurement_admission: false
portrait_acceptance: false
---

# Public mesh feasibility review

## Narrative Findings (AI reviewer)

No unresolved BLOCKER or WARNING was found within the public canonical-prior
checker and its stated scope. The reviewer inspected the implementation, all
tests and the final specification, including the runtime-acquisition outcome.
Only the supplied public canonical OBJ and generated data were accessed.
No package was installed, no model inference or private source diagnostic was
run, and no implementation or historical receipt was changed.

The checker verifies its fixed public-asset digest before parsing, then checks
the required 468 vertices and 898 triangular faces. Candidate paths consist
of existing undirected triangle edges, contain no repeated vertex, lie strictly
on their designated canonical X side, have exact mirrored partners and descend
strictly in canonical Y. These are graph/template properties. The returned
prior-only flag remains true and anatomical qualification/scoring flags false.

Input checks reject boolean/nonfinite/out-of-range coordinates, malformed or
invalid-index triangles, malformed/repeated/asymmetric path definitions and
nonmonotone or absent edges. Shape/type checks precede set construction and
numeric operations that would otherwise raise unrelated type errors. The CLI
sanitizes unexpected failures to its fixed rejection record.

## Independent verification

- Submitted six tests passed independently in both normal and optimized Python.
- The supplied public OBJ matched SHA-256
  8bac80443397e113f41a8b565ea72c59390bc031d9defab289dba7bc0c54e618.
  Public inspection returned 468 vertices, 898 faces, two hypotheses and four
  chains, with prior-only/nonqualified/nonscoring flags.
- Forty-three additional malformed-domain controls all raised the declared
  Rejected exception. Cases included bad container/element shapes, boolean and
  noninteger indices, huge integers, nonfinite coordinates, invalid cardinality,
  duplicate vertices, wrong ordering and out-of-range indices.
- Two inclusive-bound positive controls passed, including coordinate,
  vertex-count, face-count and hypothesis-count limits.
- Six generated asset controls rejected missing paths, directories, empty files,
  oversized files, changed content and a symlink.
- Final source/test bytes matched the tested identities. The specification's
  subsequent acquisition-status addition was separately read and bound below.

Only fixed aggregate results and hashes are retained; temporary generated
asset files were removed. The reviewer did not read package caches, incomplete
wheel/PDF data, models or private imagery.

## What the public prior does not establish

These are explicit evidence gaps, not defects in a checker that labels its
output as an unqualified prior:

1. **Semantic ownership.** Connected mirrored descending paths need not be root
   sidewalls or visible structural boundaries. The two path choices are authored
   hypotheses, not official anatomical names. Future positive geometry tests
   must not define their truth merely by copying the selected index lists.
2. **Completeness.** Keeping inner and outer candidates prevents silently dropping
   this particular alternative; it does not establish that all plausible root
   structures are represented. A stationary outer interpretation must still
   block acceptance if it remains applicable.
3. **Index compatibility.** A 468-vertex canonical asset and a task potentially
   returning 478 landmarks cannot be treated as index-compatible solely because
   both originate in MediaPipe. The exact selected model/task needs an independently
   justified index/topology mapping before these indices are used on an image.
4. **Instance geometry.** Exact canonical symmetry and Y ordering do not imply
   real-face symmetry, visibility, the same projected ordering, root-ROI coverage
   or exclusion of eye/protected support. Do not synthesize a missing or occluded
   side by mirroring the other side.
5. **Uncertainty and output evidence.** Canonical coordinates, prediction scores,
   mean model error and repeatability are not certified individual boundary-error
   bounds. Half-pixel raster uncertainty is not detector error. Actual output
   correspondence, retained uncertainty, every sibling, original thresholds and
   protection predicates remain separate requirements.

The smallest useful next technical evidence would bind the exact runtime/model
identity and index mapping, establish safe bounded generated inference behavior,
then review a source-only ownership/uncertainty definition. This report does
not authorize those executions or guarantee that they will produce usable
root support. Shared-source change bounds can propagate supplied uncertainty;
they cannot supply the missing semantic evidence.

## Runtime and permission boundary

The final specification reports incomplete wheel acquisition, a truncated
model-card PDF, an unfinished dependency lock and no installed runtime or
inference. These are attributed execution-status statements, not acquisition
steps independently rerun by this reviewer. Repository-license provenance does
not establish approval of a model bundle or every dependency; this review is
not a license approval.

No private-image permission JSON is created. This report grants no model
installation/inference admission, source registration, measurement amendment,
effect PASS, NOSE-02 acceptance or milestone completion. Prior failed or
unavailable observations retain their original scope.

## Exact reviewed identities

| File | SHA-256 |
| --- | --- |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-MESH-FEASIBILITY.md | 31a71208670ae74bad5893367f853e993083e13ad1dd2b179445198ae640281d |
| scripts/phase95-root-mesh-topology.py | 90dadd521ee2a2b3b3cc4d232e47c2967a3f72736555adcf36aec9c0fe203064 |
| scripts/test-phase95-root-mesh-topology.py | 28e16fc5f055ef2c99c3f431a470f8b6c4fda79e787b7b528adff110bed2a51d |

_Independent reviewer: closeout-review-20260922. Public assets and generated data only._
