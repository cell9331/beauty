# Generated signed affine-motion experiment

2026-09-15. Status: experimental; independent review pending. No metric freeze,
source registration, private portrait score or milestone completion credit.

## Why the initial draft was replaced

The first one-channel/inward-only draft retained10 fixture truths but had0/2
power at32Q16. It arbitrarily rejected intervals wider than a quarter pixel and
overstated a coordinate-ramp fixture as independent truth. These are not an
accepted solution. Current fixture truth is explicitly known analytic motion,
not independently observed production geometry. Initial failed power remains
recorded here; no failed portrait run or frozen acceptance contract is altered.

## Model and exact solver

The input is five RGB samples in a generated row. Unknown signed displacement
is d(x)=d0+s*t, where t=(x-center)/2. Bounds: d0 in[-1,1] pixels, s in[-.5,.5],
every local displacement in[-1,1], gain g in[.5,2], offset b in[-32,32] bytes.
Gain/offset are common across RGB within one patch; two sides fit separately.
No per-pixel photometric freedom, arbitrary blur, non-affine motion or clipping
is included. Error E=1/2+1/512 byte is a generated sampling assumption, not a
certified full-SDK bound. The one-byte widening test checks inclusion only.

For inverse-warp sampling q=x-d(x), P(q) is linear within each integer cell.
A linear displacement changes sign at most once, so both uniform-sign patterns
and every one-crossing pattern cover all allowed cells (zero endpoints overlap).
With alpha=1/g and beta=-b/g, the observation constraint is exactly

    (C-E)*alpha + beta <= P(q) <= (C+E)*alpha + beta

with .5<=alpha<=2 and -32*alpha<=beta<=32*alpha. Each pattern therefore forms a
bounded four-dimensional rational polytope in(d0,s,alpha,beta).

Start from the16 vertices of an enclosing box. Clip successive halfspaces,
retaining old feasible vertices and exact intersections of crossing edges.
An edge's common active normals have rank three; a crossing cut gives a fourth
independent plane. The solver tries triples of common active planes to handle
redundancy, and checks each result against exact segment interpolation.
Faces/lines/points lying on the cut are retained. Project each surviving
polytope onto d0; return the hull of ALL pattern projections, including
disconnected possibilities and search-boundary points. This hull can be
conservative, never narrower than the union. No best-fit component selection
or arbitrary ambiguity-width rejection is allowed.

For two patches, contraction is(dLeft-dRight)*65536/imageWidth. The conservative
margin is min(candidate.lower, candidate.lower-neutral.upper), compared to
the unchanged16Q16. An uninformative hull cannot establish positive contraction.

## Generated results and regression contract

Widths512/1024, seeds5/17, amounts-32/0/15/16/17/20/32Q16, and photometry
(gain,offset)=(1,0),(1.25,-7),(.6,18). Each side's slope is one quarter of its
signed center displacement. All42 paired cases must contain both analytic
shifts and the true contraction. No amount<=16 may pass. Every32Q16 case MUST
pass; zero power cannot produce a successful self-test again.

Observed:84/84 true shifts contained. Per six pairs at each amount:
-32/0/15/16/17:0passes;20:5passes;32:6passes. The17Q16 near-floor sensitivity
limit remains visible; it is not rounded up or hidden by changing the floor.

Flat input with brightness change retains[-1,1]. An RGB linear ramp with
brightness change retains both zero motion and its shift-equivalent solution.
A displacement crossing zero inside the patch remains feasible. Widening E to
one byte must enclose the narrower interval. Truncation, unsafe center and
out-of-byte-range input must reject.

## Limits and next steps

1. This is a generated mathematical prototype, not a source registrar or
   production effect metric. No anatomical or population claim follows.
2. Actual root deformation is not proven affine over these patches. Its full
   spatial variation and coordinate/error budget still require validation.
3. Candidate source/output geometry cannot be inferred from production field
   vectors as the acceptance oracle. Independent production-pixel tests remain.
4. Search range, common photometry, unclipped values and error assumptions must
   be justified before real use. Motion outside the model is not certified.
5. Source-only anatomy registration, sibling distinction, locality/protection,
   reviewed definition freeze and full seven-active/one-deferred gate remain.

Supplementary primary research: Baker/Gross/Matthews, CMU-RI-TR-03-35,
[Lucas-Kanade Part3](https://publications.ri.cmu.edu/storage/publications/pub_files/pub4/baker_simon_2003_2/baker_simon_2003_2.pdf),
abstract/introduction: jointly handling warp and appearance variation is an
established alignment approach; gain terms can invalidate some approximate
updates. That motivates explicit nuisance parameters, not a proof of this
exact clipping implementation or anatomical adequacy.
