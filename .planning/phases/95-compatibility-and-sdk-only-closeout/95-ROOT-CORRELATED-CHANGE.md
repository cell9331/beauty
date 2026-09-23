# Shared-source structural change — generated-only successor component

Date: 2026-09-22. No portrait admission, source registrar or production change.

## Problem

The existing absolute-width reducer safely overapproximates source and candidate
widths independently. Their anatomical locations are actually the SAME source
material points. Subtracting independently widened absolute intervals can lose
this correlation and reject a measurable change. This is conservatism, not an
unsafe old PASS. Existing historical results remain unchanged.

For example source anchors[20,22] and[76,78] with inverse candidate map
q(x)=224x/223 contract by[54/224,58/224] pixels. At512 image width the lower
margin exceeds16 Q16. Independently subtracting the two absolute width intervals
gives a negative lower margin despite this uniformly positive contraction.
These are generated analytic coordinates, not private image data.

## Bound construction

For a fixed uncertain source location s, measure d(s)=f_reference(s)-f_candidate(s),
where each f is the forward inverse of its independently admitted increasing q.
Use the existing reviewed forward helper at each cell endpoint. If q secant
bounds are[m,M], the forward bounds are[1/M,1/m]; therefore d has secant bounds
[1/M_reference-1/m_candidate,1/m_reference-1/M_candidate].

Every source interval is partitioned into8 equal cells by default (1..32 allowed
for generated analysis, never selected from output success). Within a cell of
width w and endpoint bounds A,B, retain both Lipschitz cones:

- lower(t)=max(A.lo+low*t, B.lo-high*(w-t));
- upper(t)=min(A.hi+high*t, B.hi-low*(w-t)).

Exact rational extrema of these two-line envelopes occur at endpoints or their
intersection. Hull ALL cells; do not choose a midpoint or favorable cell. The
left and right shared-source differences yield reference width minus candidate
width as d(right)-d(left), conservatively combining independent side intervals.
Inputs remain bounded (source interval<=64px, at most33 inverse samples/model,
128-bit input Fraction numerator/denominator); malformed/unbracketed/inconsistent
correspondence rejects. Genuine map secant bounds cannot be inferred merely from
samples. The helper does not generate such admission.

## Cohort reduction

measure_changes retains the existing source-frozen12..16 row inventory and full
image normalization. It accepts signed changes against source, neutral and the
exact three original siblings. Sum signed intervals across all rows before
outward Q16 rounding and distance from zero for siblings: opposite row signs
may cancel. Source and neutral are signed positive contractions. All require
>=16 Q16. No missing row/reference, copied sibling or unresolved zero-motion
explanation gets credit. Existing target/protection/metadata conditions remain
mandatory outside this generated-only component.

## Limits

This improves propagation of an independently supplied source uncertainty; it
cannot identify anatomy or make unsupported source geometry valid. The two
source-visible models and current Vision contour diagnostics remain unavailable.
No private source or output is read by this work; no new source run is justified
solely by these generated tests. A reliable automatic source definition remains
necessary before real-image integration, separate independent review and scoring.

## Actual generated pixel integration

Two additional Phase95RootImageFormationTests methods reuse the pre-existing
positive row143 and fixed-boundary negative row164. Source material boundaries
are declared by the generated red stripe, independently of provider points.
Each side retains its full +/-0.5px source interval and32 cells, fixed equally
for both tests. Candidate inverse samples come from actual canonical rendered
RGB bytes and the reviewed one-byte sampler correspondence. The source map is
identity. Existing horizontal no-fold admission supplies only secant bounds,
not a positive displacement oracle. Source/destination coordinates and pixels
remain in the existing bounded in-memory test transport.

The new tests require genuine contraction to meet16Q16 and the fixed-boundary
case to retain zero and fail contraction. Both actually pass2/0/0. This is a
bounded generated demonstration of shared-location uncertainty, not calibration
of uncertainty or semantics for the private portrait. The full related suite
result and independent review are recorded in the current ledgers after execution.
