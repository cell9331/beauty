# Root image formation and affine-model applicability

2026-09-15. Generated-only diagnosis, not a frozen measurement amendment.

## Executed tests

`Phase95RootImageFormationTests.swift` exercises the actual paired-eye observed
root provider through the canonical geometry pipeline, with fixed generated
anatomy and opaque RGB textures. Two sizes256/512 and strengths0/.125/.25 give
six executions. Six admitted points are required for each nonzero strength;
neutral requires none. Actual output is compared to an independently coded
Double sampler over the original row, without calling production interpolation
helpers. A point's field parameters are sampler inputs, not semantic truth.

Assertions pass: unrounded sampling error<=1 byte on these grids, neutral
identity, nonzero active changes, zero outside-field/alpha changes, extent,
memory PNG size and byte-exact round trip. No media or raw geometry persisted.
The two test methods passed with zero failures/skips.
The related selection (new root tests, prior image-formation, nose registration,
nose provider, inward safety and pixel-center tests) passed30/0/0. SDK-only
post-archive boundary and whitespace diff checks also passed. No fresh full
archive/no-skip run or independent acceptance review is credited.

## Applicability counterexample

The generated full-strength root fields at both sizes have displacement>1px,
outside the signed affine prototype's entire search domain. In addition, take
three samples at x-2,x,x+2. Every affine function has second difference zero.
If it approximates the true displacement with uniform error e, the true second
difference has magnitude at most4e by the triangle inequality. Therefore

    e >= abs(d[x-2] - 2*d[x] + d[x+2]) / 4.

Scanning these generated fields establishes a lower bound>0.05px for some
five-sample windows at both sizes. The exact affine assumption is thus false;
a larger search alone cannot repair it. The cone centers and disk boundaries
make this unsurprising, but these tests bind that conclusion to actual current
emissions, not a hypothetical field.

This is model inadequacy, not a demonstrated production renderer defect.
No change to nose strength, ROI, threshold, private fixture or frozen metric.
The previous affine model/review remain valid only for their declared model.

## Next implementation constraints

The successor must support larger and spatially non-affine displacement or
include a rigorously justified local-approximation error that still has power.
Do not manufacture ground truth from candidate control-point vectors. Keep
photometric ambiguity, both motion directions and conservative uncertainty.
Source-only anatomical registration and sibling/protection conjunctions remain
required before any actual portrait score. A generated renderer reference and
an applicability counterexample do not replace those gates.

No current portrait acceptance: last full result remains6/7 active controls.
Phase95 Plan03/04 and v1.22 closeout remain incomplete.
