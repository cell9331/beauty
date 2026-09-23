# Phase95 generated subpixel correspondence model

Date: 2026-09-15. Status: experiment, not an amended acceptance contract.

## Successor affine-motion probe checkpoint

The initial one-channel, inward-only affine draft had0/2 power at32Q16.
Its arbitrary quarter-pixel rejection and overstated coordinate-ramp truth
were not accepted. A signed RGB successor now records42 paired cases and84
analytic true-motion containments,32Q16 power6/6 and20Q16 power5/6.
See95-ROOT-AFFINE-MODEL.md for the distinct model, exact clipping and limitations.
This does not modify/promote the constant-translation experiment below or
constitute source registration, portrait scoring or completion evidence.

## Scope and image-formation assumption

`scripts/phase95-root-subpixel-probe.py --self-test` exercises the exact current
`writeInterpolatedPixel` body from `BeautyGeometryEffectPipeline.swift`, admitted
by whole-file SHA256 `bbffaffbeecb6432ee1c917e9b7d2143fae8ca46028aedeecb01f5f690b0981a`.
It does not edit production code. An in-memory wrapper supplies generated opaque
RGB textures with equal adjacent rows and explicit horizontal sample coordinates.
The script compares every returned sample to an independent Fraction-arithmetic
interpolator. No generated pixels or child transcript are persisted.

This isolates the interpolation/rounding step. It does NOT test the full SDK
facade, Float field evaluation, normalized-coordinate reconstruction, CI color
conversion, PNG encoding/reload or portrait detection. Those error sources
remain outstanding. The 0.501953125 byte bound is an experimental assumption
for this narrow sampler model, not a certified full-pipeline error budget.

## Exact feasible intervals, not the best correlation

Given a source RGB patch P and observed integer output pixels C, assume a
constant local horizontal translation d and C[k,c] = P[k-d,c] + e[k,c], with
|e| <= 1/2 + 1/512. P is the piecewise-linear interpolant of source bytes.
Search d in [-4,4] source pixels, across each integer-knot cell [j,j+1].
Inside each cell P[k-d,c] is affine in d, so each channel/sample contributes
an exact rational interval constraint. Intersect all constraints, union all
cells, and retain the complete feasible set. Empty, disconnected, or boundary-
touching sets reject. There is no subpixel scan step, interpolated candidate,
best-fit selection, learned detector or use of production displacement as truth.

For two generator-known patches, inward change is (dLeft-dRight)*65536/width.
Report an enclosing interval. The candidate's lower bound must exceed both
source zero and the neutral interval's upper bound by the unchanged16Q16.
This experiment does not implement sibling distinction, protection rectangles,
source anatomy registration or final acceptance-report dispatch.

## Declared experiment and observations

Widths512/1024/2304; texture seeds1/7/23; change amounts-32/0/15/16/17/20/32Q16;
both sides give126 actual sampler cases. Generator truth must lie in every
measured shift interval and every derived width-change interval. Positive
power at32Q16 and no false promotion below16 are mandatory assertions; the
17/20 observations are reported, not post-hoc required test conditions.

Initial run:126/126 sampler/reference byte matches and truth containments;
maximum error0.5 byte. For each amount,9 pairs were evaluated:

| True change Q16 | Passed unchanged16Q16 conservative gate |
| --- | --- |
| -32 / 0 / 15 / 16 | 0/9 each |
| 17 / 20 / 32 | 9/9 each |

Exactly-at-threshold samples are conservatively unproven, not silently rounded
up. Seven negative controls reject: flat, periodic, +12 brightness, 0.8 gain,
symmetric three-tap blur, truncated output, invalid center. These are specific
generated attacks, NOT arbitrary photometric/blur robustness.

A separate one-byte budget run retains every narrower interval, still has no
sub-threshold false promotion, and detects17Q16 in3/9 cases and20/32Q16 in9/9
each. This preserves the sensitivity cost of a wider error budget instead of
assuming the isolated sampler bound applies to an entire image pipeline.

Two new `Phase95ImageFormationTests` methods pass2/0/0. They exercise the actual
canonical sRGB geometry entry point and in-memory PNG encode/decode at64x48
and257x193: neutral bytes are identical, warped PNG round-trip bytes are
identical, opaque alpha and extent are preserved, outside-field bytes do not
change, and a Double reference matches within one byte. The spatially varying
horizontal field is a generated mouth fixture using the shared sampler, not
the root anatomy. Its control points are legitimate sampler-oracle inputs,
but MUST NOT be used as the independent semantic-motion oracle. This bounded
matrix is not proof of a universal one-byte error budget or facade/portrait
coverage; the script's source/neutral/actual-portrait chain remains untested.

An asymmetric two-tap blur exactly equals fractional translation; that
equivalence is explicitly retained and tested. It cannot be rejected solely
from these pixels. Removing the old arbitrary-blur nuisance is therefore not
enough to establish semantic soundness on arbitrary image edits.

## Remaining proof obligations before a real successor

1. Constant local translation is not the root provider's spatially varying
   field. Develop and validate a suitable deformation model or a conservative
   local approximation bound without reading candidate control points as truth.
2. Brightness/gain controls on three-channel texture do not prove all
   photometric attacks reject. A ramp plus brightness can equal a shift under
   this model. A production metric requires a justified nuisance model and
   source-side identifiability tests; this prototype must not be promoted as-is.
3. Validate full source/neutral/output canonicalization and readback error,
   including noninteger normalization, color, alpha, extent and directions.
4. Anatomical registration must be source-only and independently frozen before
   evaluating the same authorized portrait. Generator-known patch centers are
   not a substitute. Preserve ROI/threshold/source/history and sibling/locality
   conjunctions. No original frozen metric/registrar is changed by this work.
5. Require independent mathematical/implementation review, then actual source
   registration and complete seven-active/one-deferred portrait acceptance.

The last full portrait remains6/7 and Phase95 remains incomplete. This advances
measurement-power evidence beyond the integer-only probe, not product efficacy.
