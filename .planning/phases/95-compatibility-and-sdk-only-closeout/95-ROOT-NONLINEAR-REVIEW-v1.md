---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-15T05:23:13Z
depth: standard
status: issues_found
files_reviewed: 2
files_reviewed_list:
  - scripts/phase95-root-nonlinear-probe.py
  - BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift
context_reviewed_list:
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-NONLINEAR-MODEL.md
  - scripts/phase95-root-affine-motion-probe.py
  - BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift
findings:
  critical: 0
  warning: 1
  info: 0
  total: 1
hash_algorithm: sha256
reviewed_working_tree_sha256:
  scripts/phase95-root-nonlinear-probe.py: 8be3b6a27d3dab808ffad4dd516ce820e0c1efd16d26f54fdcc4bfd3f11ccbdf
  BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift: 344dd2f43558b3b2c2482e256375bbfea2417288ebe5374e74c1a6d82d1f45cf
  .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-NONLINEAR-MODEL.md: 73bbbd8c146c46b3f9d3daa0e5aadcc3b993f625a51432332a20ec070ab14552
  scripts/phase95-root-affine-motion-probe.py: 0d99954325288c2b7da43cb4dcb90412decb7aeb441fcc82ae605d4edfe8f06c
  BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift: bbffaffbeecb6432ee1c917e9b7d2143fae8ca46028aedeecb01f5f690b0981a
head_at_review: 1af7fba6ed7ae58f6a3af44551c6d421922f7fcb
independent_checks:
  fraction_feasibility_comparisons: 3000
  polygon_pairs: 225
  polygon_union_membership_comparisons: 30025
  polygon_merges_exercised: 99
  separated_collinear_gap_controls: 1
  exact_end_to_end_oracle_cases: 12
  exhaustive_active_triples: 2284692
  feasible_vertices_enumerated: 696
  mathematical_disagreements: 0
  swift_child_mutation_modes: 2
  reproduced_false_success_modes: 1
swiftpm_rerun: false
portrait_scoring_attempts: 0
acceptance_credit: false
phase_complete: false
---

# Phase 95: Independent nonlinear experiment review

## Narrative Findings (AI reviewer)

### Summary

One test-reliability warning is independently reproduced. No mathematical
discrepancy was found in the bounded direct-oracle checks described below.
This is not a universal correctness certificate or a formal metric approval.

Both scoped source files were read completely, with particular attention to
the new Swift integration at lines 131–205. The requested model document was
read as the experiment contract; it is listed separately from source scope.
The affine dependency and canonical renderer were inspected as supporting
context. The three submitted file hashes matched at initial and final checks;
the working-tree hashes above, rather than HEAD alone, identify this review.

### Warnings

#### WR-01: Optimized Python silently removes the containment oracle

**Classification:** WARNING — test reliability / false success.

**File:** `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift:173-183`

**Issue:** The child uses Python `assert` as its only comparison between the
computed interval and the Double sampler-input truth. `Process` inherits the
parent environment, and `-B` only disables bytecode-file creation. With
`PYTHONOPTIMIZE=1`, Python removes line 181, but still increments `count` and
prints the same success summary. The Swift checks at lines 200–204 therefore
accept successful interval computation even when it excludes both truths.
The test no longer verifies the behavior named in its title in that mode.

**Independent reproduction:** Extracted the exact embedded child program from
the reviewed Swift bytes and substituted only the interval provider in memory
with one returning intervals that exclude the supplied truths. Executed it
using the same `/usr/bin/python3 -B -c` invocation. Under
`PYTHONOPTIMIZE=0`, it rejected the mutation with a nonzero exit. Under
`PYTHONOPTIMIZE=1`, it exited zero and returned the parent-accepted
`contained: 2` summary. Only aggregate outcomes were emitted; no source edits
or full SwiftPM execution were involved.

**Impact:** This is a generated integration-test robustness defect, not a
demonstrated solver defect or an external security boundary. It does not
establish that the previously reported ordinary Swift run was false.

**Fix:** Make rejection unconditional rather than relying on an assertion:

```python
if not lo <= F(str(case['truth'])) <= hi:
    raise SystemExit('containment_failed')
count += 1
```

Keep the failure text fixed and aggregate-only. Verify the exclusion mutation
rejects under both normal and optimized Python, and valid containment still
passes. No source repair was made during this review.

### Independent mathematical checks

All oracle runs used standard-library Python, generated in-memory values,
exact rational arithmetic, and a 105-second watchdog per command. They did
not invoke the submitted self-test. Outputs contained aggregate counts only.

1. **Independent fraction elimination:** For 120 generated RGB segment/error
   cases and 25 photometric points each, independently intersected the three
   direct channel bounds on the interpolation fraction with its unit interval.
   Compared this existential feasibility result with `project_t`'s projected
   inequalities: 3,000 agreements, including zero-gradient cases.
2. **Convex union simplification:** Exercised every ordered pair from 15
   point, segment, triangle and rectangle cases. Independent geometric
   membership predicates compared the original union with the inserted states
   at a rational grid, all input vertices, and cross-component midpoints:
   225 pairs, 99 merges and 30,025 agreements. Cases included touching,
   overlapping, crossing and degenerate components. A separate extremely
   small rational gap between collinear segments remained unmerged.
3. **Complete interval oracle:** Used different variables from the submitted
   solver: gain `g`, offset `b`, and `h_i = g*t_i`. Direct observation bounds
   become linear in these variables, with `0 <= h_i <= g`. Enumerated every
   integer-cell assignment, eliminated noncentral `h_i` independently, then
   enumerated all triples of active constraints for the remaining three
   variables. Tested each exact candidate against every inequality and
   projected `h_center/g`. Positivity of `g` makes the ratio extrema attainable
   at vertices of each bounded feasible polytope. This oracle does not call
   the submitted `project_t`, polygon operations, affine `box`, `clip`, or
   `solve4`. Twelve complete feasible/infeasible interval comparisons agreed,
   across 2,284,692 active triples and 696 feasible vertices counted over the
   enumerated cell components. Cases covered 3/5/7 samples, signed reversals,
   motion beyond one pixel, both search endpoints, nonidentity photometry,
   zero and nonzero error, point/segment degeneracies, flat/ramp ambiguity,
   and infeasible RGB observations. These small exhaustive searches use
   search radii one and two; they do not exhaust radius 64 or every input.

### Mathematical and integration assessment

- `cell_constraints` has the correct signs for output-space error after the
  positive inverse-gain substitution. `project_t` pairs every lower and upper
  fraction bound; zero coefficients retain their photometric inequalities.
  Each noncentral sample has its own eliminated fraction. Intersecting their
  unions therefore requires one shared photometry without imposing affine
  motion, monotonicity, or a sign prior.
- `exact_union_insert` requires nonempty intersection before testing exact
  hull-area equality. For two full-dimensional closed convex polygons, a
  convex-hull enlargement outside their union would have positive area.
  Adding an exterior point/segment to a full-dimensional polygon also adds
  positive area. If the hull has zero area, nonempty intersection makes the
  union of its collinear compact intervals convex. Thus the degeneracies do
  not invalidate this merge criterion. The explicit intersection guard is
  essential for separated collinear pieces.
- The final affine box's first coordinate is reused as the central fraction,
  whose additional bounds are `[0,1]`; it is not the total displacement.
  Every central cell is enumerated, so the old unit displacement bound and
  affine sign-pattern helper do not limit the nonlinear search. The unused
  second coordinate introduces no coupling. The independent oracle checks
  the resulting full displacement extrema, not merely truth containment.
- `dependency()` hashes bytes and executes those same bytes directly. The
  observed affine digest equals the pin. No second dependency read is used
  for execution in the reviewed delta.
- The Swift reference evaluates displacement from production control points
  using Double arithmetic and checks canonical generated renderer bytes.
  It remains a sampler-input/model-applicability experiment. The model
  document correctly excludes independent anatomical truth, universal error
  bounds, portrait acceptance and Phase 95 completion. Its earlier ramp
  state-limit failure remains documented as development history.

### Scope and limits

The review used the GSD review instructions and the project's spike guidance
for request-local data and aggregate-only evidence. Serena was unavailable;
source discovery and tracing used direct reads/searches. No structural
pre-pass was supplied. The generated-only, local-child boundary was assessed
proportionally; no private-image or hostile image-file input route was assumed.

The main's reported 38 containments, threshold matrix and Swift 3/0/0 are
background claims, not independently rerun results in this report. The running
main rerun was not inspected or credited. No broad phase-history gate, full
SwiftPM run, private fixture, external AI CLI, agent, installation, commit,
source edit or historical-report replacement was performed. This new review
is the only file written. No formal metric or effect-acceptance credit follows.

_Reviewer: independent gsd-code-reviewer; standard depth._
