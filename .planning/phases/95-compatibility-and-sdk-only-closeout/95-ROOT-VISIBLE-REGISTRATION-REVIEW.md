---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-22T08:46:56Z
depth: standard
files_reviewed: 2
files_reviewed_list:
  - scripts/phase95-root-visible-registration.py
  - scripts/test-phase95-root-visible-registration.py
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
source_registration_admission: false
portrait_acceptance: false
---

# Visible registration prototype review

## Narrative Findings (AI reviewer)

Final reviewed version has no unresolved implementation finding within its generated-only, conditional local-knot scope. One independently reproduced BLOCKER was corrected during review; this is not source semantic admission.

### Resolved CR-01 — BLOCKER: bilateral polarity filtering discarded the real outer pair

The earlier `row_candidates` required equal left/right slope-change signs. A generated asymmetric-lighting profile retained each real exterior knot in `supported_side`, then silently removed their bilateral pairing while returning eight other pairs. Thus single-side preservation did not establish row-level preservation.

The implementation at lines 81–86 now takes every ordered left/right candidate combination and carries both signs; it does not assume bilateral lighting symmetry. The added test independently declares the true stationary exterior pair and reproduces the old failure. Reviewer additionally tested all 16 combinations of exterior/interior polarity on the two sides: all retain the independently declared exterior pair. No production pixels were used.

## Mathematical and semantic boundaries

The reused affine fit retains the feasible line polygons under its fixed error model. A strict common denominator sign justifies extrema of line-intersection position at product vertices; clipping to each declared cut cell retains the feasible position range. Local supports no longer require the complete outward profile to be affine. The module retains all detected outward alternatives of either polarity through the proposed prior's upper endpoint, then all spatially ordered bilateral combinations. Candidate-budget overflow rejects instead of truncating.

This remains conditional on the finite local support family (4, 8, 16 samples), fitting error, contrast criterion, valid source-only prior and the interpretation of a knot as relevant visible structure. It does not prove that every real outer anatomical structure produces one of these knots. An occluder or incorrect internal prior with its own supported transition can still generate candidates; no output of this module carries an anatomy/visibility qualification. Flat occlusion rejection is narrower than universal occlusion detection. Those applicability checks belong in the eventual single registrar integration, not in an assertion that this prototype already identifies root width.

The generated fixed-outer/moving-inner test composes returned intervals with the actual correlated-change reducer and rejects a positive structural verdict. A positive generated contraction survives the same interval propagation. These reducer tests use supplied mathematical maps; they are not actual RGB sampler or portrait evidence and do not establish sibling distinctness on real outputs.

## Validation

- Independently ran final seven tests under ordinary Python and `-O`: 7/7 each.
- Independently generated 16 bilateral exterior/interior polarity combinations: all true outer pairs retained.
- Checked malformed tuple/value/prior bounds and integer/fraction restrictions, typed empty support and budget rejection, both coordinate reversals, and preservation of ambiguity instead of selecting favorable peaks.
- No source image access, model inference, network, source modification, approval JSON or milestone receipt.

## Reviewed identity

| File | SHA256 |
| --- | --- |
| scripts/phase95-root-visible-registration.py | b0c04ef5ee5c84339aedd8198ab48a45ad391be268b405754d15f18c0e406e5d |
| scripts/test-phase95-root-visible-registration.py | b9f712a898d3f12123568fb5adac9b1e210c18848d3b562451866d06bd77475a |
| scripts/phase95-root-affine-source.py (called fit dependency) | 5a307c08b854eef114e2ab8462ff99ce2029eb4772cf53791f82fd63be412c4d |
| scripts/phase95-root-correlated-change.py (test dependency) | e2a1c3f6c626b1f2a978535d131f8bfc7ec5f095bf24e4a10f6747c4545f9439 |

Reviewer: independent gsd-code-review agent. This report preserves the original source ROI, 16 Q16 thresholds, sibling comparisons and protection predicates; none were exercised or granted by this generated-only review.
