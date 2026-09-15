# Root forward measurement semantic review

Date: 2026-09-15
Status: issues_found
Classification: rejected measurement-definition PROPOSAL, not a finding against current production.

## Scope and verdict

This records the completed independent semantic review only. The reviewed
proposal registers paired interior pixel positions in a fixed source-anatomy
root ROI, estimates inverse horizontal correspondence at those fixed output
coordinates, and labels positive `dLeft - dRight` as `rootWidthContraction`.
That proposal does not preserve root-width semantics: even exact correspondence
can establish interior skin deformation while the root's structural width is
unchanged. Anatomical ROI membership does not bind the measured pair to the
structures defining that width.

No mathematical implementation, new forward helper, or generated-control
implementation was reviewed here. This record grants no production defect
classification, replacement approval, portrait acceptance, or completion credit.

## Fixed-coordinate counterexample

Let the source root's structural boundaries be `x=0` and `x=10`. Define the
inverse correspondence `q(x)=x-d(x)` by piecewise-linear interpolation through:

| Output x | 0 | 3 | 7 | 10 |
| --- | --- | --- | --- | --- |
| Source q(x) | 0 | 2 | 8 | 10 |

The map is strictly increasing and has no folding. Both structural boundaries
remain fixed, so root width is `10 -> 10`, with zero contraction. Nevertheless,
fixed interior output probes at 3 and 7 give `dLeft=+1`, `dRight=-1`, and
`dLeft-dRight=+2`. Identifiable texture and perfect correspondence do not repair
this semantic false positive. This is an analytic counterexample, not a claim
that a particular pixel solver was executed or returned a passing interval.

## Minimum requirements for a valid automated replacement

1. **Source-anatomy anchoring.** Before reading outputs, register paired left
   and right root structural locations, or anatomically justified landmarks
   defining the measured width, with localization uncertainty. Freeze identities,
   admitted rows, weights, templates and search regions. ROI membership and eye
   exclusions alone are insufficient; generic image edges also need anatomical
   justification.
2. **Forward localization of the same source material points.** For each frozen
   source location `s`, recover output locations satisfying `q(x)=s`. Enclose
   all admissible locations using justified interpolation and invertibility
   assumptions, or abstain when localization is unavailable. Measure
   `widthOutput=xRight-xLeft`. Evaluating `d(s)` at a fixed output coordinate
   does not generally give the forward displacement of source point `s`.
3. **Conservative acceptance.** Propagate both anatomical localization and
   correspondence uncertainty through source/neutral contraction and sibling
   comparisons. Preserve the existing full-image normalization, thresholds,
   target-signal and protection conjunctions. Generated semantic controls should
   include fixed boundaries with interior contraction, true boundary contraction,
   expansion and common translation.

Interior probes could substitute only if an independently validated model
conservatively binds their motion to structural-boundary motion. Independent
per-sample inverse displacements alone provide no such relationship.

## Automatic options and disposition

Automatic source-only anatomical contour or landmark registration remains a
valid avenue, followed by output correspondence of the frozen source structures.
Automatic alternatives have not been exhausted; no mandatory manual owner
confirmation requirement has been established. Unidentifiable anatomy should
produce typed unavailable rather than acceptance of an interior-motion proxy.
This review does not establish that any specific automatic registrar succeeds
on the authorized source.

## Source references

- [Taxonomy](../../../docs/SDK_EFFECT_TAXONOMY.md), implemented root row and
  Phase 93 qualification: independent root narrowing, with generated mechanics
  distinguished from subsequent portrait qualification.
- [Active plan](../../../PLANS.md), Phase 95 nonlinear measurement checkpoint:
  source-only anatomical registration and reviewed metric integration remain.
- [Structural metric spec](95-ROOT-METRIC-SPEC-v2.md), source-only registration
  rules: frozen structural pairs; opposite polarity and continuity are explicitly
  a bounded image-edge assumption, not proof of anatomy.
- [Nonlinear model](95-ROOT-NONLINEAR-MODEL.md), model and verification contract:
  independent inverse sample displacements; actual sampler-byte applicability
  is explicitly not independent anatomical truth.
- [Source adapter](../../../scripts/phase95-root-registration-adapter.swift),
  `sourceOnly()` registration call: supplies the retained ROI and eye exclusions
  to structural registration; those spatial constraints do not themselves
  establish that arbitrary interior points define root width.

Only this review record was written. No private images, private runtime paths,
or portrait outputs were inspected; no portrait, tests, additional agents or
mathematical implementation review were run for this record.
