---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-22T06:30:03Z
depth: deep
files_reviewed: 4
files_reviewed_list:
  - scripts/phase95-root-correlated-change.py
  - scripts/test-phase95-root-correlated-change.py
  - BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-CORRELATED-CHANGE.md
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
source_admission: false
portrait_acceptance: false
---

# Shared-source correlated change review

## Narrative Findings (AI reviewer)

No unresolved BLOCKER or WARNING was found within this generated-only component.
The four-file scope includes the two new testSharedSourceUncertainty methods
and their shared helper changes; it does not requalify the production renderer
or all pre-existing native tests. The reviewer traced the reused forward
localization and generated-child transport and checked the canonical sampler
integration. No source code was modified.

The old independent-width subtraction is conservative, not an unsafe acceptance.
The new calculation preserves a shared uncertain source location between maps
without substituting a midpoint or dropping uncertain positions.

## Mathematical assessment

For admitted increasing inverse maps with global secant bounds m..M, their
forward inverses have secant bounds 1/M..1/m. Subtracting the two forward
secant inequalities yields the implemented lower and upper bounds for
d(s)=f_reference(s)-f_candidate(s), even when either bound is negative.

At every cell endpoint, the existing position primitive encloses each forward
location. Subtracting those endpoint intervals encloses their difference.
For a fixed feasible pair of maps, both endpoint-derived lower lines bound
d from below throughout that cell; both upper lines bound it from above.
Their maximum lower envelope and minimum upper envelope therefore remain
conservative. Each two-line envelope has extrema only at the cell endpoints
or its in-cell line intersection, which the exact Fraction calculation includes.
Taking the hull across every cell preserves the complete anchor domain.

Width change is d(right)-d(left), with the sign used by the implementation.
Combining the two side intervals independently can widen uncertainty but cannot
create false contraction. The required source ordering prevents reversed pairs.
Cohort reduction sums signed row intervals before outward Q16 rounding.
Distance from zero is taken only after each sibling's signed mean, so opposing
row differences can cancel. Source and neutral retain signed positive margins;
all references, exact row inventory and the original 16 Q16 floor remain required.

These conclusions depend on truthful correspondence intervals and independently
admitted global secant bounds. A finite set of increasing samples alone cannot
supply those bounds. This component does not establish anatomical ownership,
canonicalization error bounds or a horizontal model for a vertical sibling.

## Independent verification

- Ran the submitted 12 Python tests in normal and optimized modes: both passed.
  Their controls include 54 affine combinations, nonlinear containment, exact
  thresholds, shared uncertainty, fixed boundaries with interior contraction,
  common translation, malformed inputs, copied references and sibling cancellation.
- Independently constructed 120 pairs of rational piecewise-linear increasing
  inverse maps. Evaluated forward-difference extrema at the complete union of
  their source-coordinate knots and anchor endpoints; this is an exact extremum
  oracle for these maps rather than a sampled grid.
- Across exact/noisy correspondence intervals and 1, 3 and 8 cells:
  720 change bounds and 720 width-change bounds enclosed independent exact
  extrema, with zero mismatches.
- Compared 200 generated signed cohorts at 12 and 16 rows against an independent
  rational mean/distance oracle: zero acceptance mismatches.

The new native tests fix the existing generated rows 143 and 164, preserve each
entire source anchor +/-0.5px interval and use 32 cells in both cases.
Actual canonical output RGB supplies correspondence observations. Provider
admission supplies secant constraints, not positive displacement expected values.
The positive requires at least 16 Q16 conservative contraction; the fixed-boundary
negative must retain zero and cannot pass contraction. Raw generated samples
travel only through the existing bounded in-memory child transport.

The executing agent reports the two new native methods passed 2/0/0 and the
complete Phase95RootImageFormationTests suite passed 9/0/0 with PYTHONOPTIMIZE=1.
Both runs used generated fixtures only. The independent reviewer inspected the
new implementation but did not run SwiftPM; these native counts are explicitly
attributed execution results, not independently rerun evidence.

## Scope limits and identities

This report approves no source diagnostic invocation, registration, contour
cohort, measurement amendment, private portrait score, NOSE-02 result or milestone
completion. It cannot repair missing source structural support. Every relevant
source interpretation and every original protection/metadata predicate remain
the responsibility of later independently reviewed integration.

Only generated checks, aggregate counts and file hashes were retained.
No private source or output, private geometry or raw child transcript was read
or persisted. Existing historical receipts and reviews remain unchanged.

The first four scope files and the three relevant dependency identities are
bound below. The specification's final native-integration addition was read
before these hashes were recorded.

| File | SHA-256 |
| --- | --- |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-CORRELATED-CHANGE.md | 59d5f4e6e218daf2bb8bb6518ce4249c19f62b740be4fe01e64d09b46f562aab |
| BeautySDK/Tests/BeautyEffectsTests/Phase95GeneratedChild.swift | ad9511cda2b156076f99fb35e00577c2d2c35b820e9d5cdbe2cb237245e49b93 |
| BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift | d1b2e2dbed611c0beb98494e597608549fef1bd4529c1dcf81f6694e27a9187c |
| scripts/phase95-root-correlated-change.py | e2a1c3f6c626b1f2a978535d131f8bfc7ec5f095bf24e4a10f6747c4545f9439 |
| scripts/phase95-root-forward-span.py | 0cfac9277c2efdbc47ec65f120c2a43f659d0a8d279e716940ed17051660fa2d |
| scripts/phase95-root-sampler-correspondence.py | 7f838e03bd78bd31075c35ed8c8049ba968bbf3b86785aa0048eab5c55fd4367 |
| scripts/test-phase95-root-correlated-change.py | ad95ee910056ee60d560db524881b4f37eea132ad8b9e6c6c32d5173b65980b9 |

_Independent reviewer: closeout-review-20260922. No approval JSON was created._
