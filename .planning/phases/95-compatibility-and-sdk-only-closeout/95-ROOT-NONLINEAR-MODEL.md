# Arbitrary horizontal correspondence experiment

2026-09-15. Generated-only, review pending; not a metric freeze or portrait gate.

## Model

Each of3/5/7 observed RGB samples has an independent horizontal inverse sample
coordinate q_i=x_i-d_i. There is no constant, affine, smoothness or monotonicity
assumption across samples. A supplied integer search radius1...64 bounds all
signed displacements. Search16 covers the analytic matrix; search32 covers two
selected actual-root generated sampler windows. It is not certified for every
root, resolution or portrait. Bounds are not changed after inspecting outputs.

Photometry is shared within a patch: gain g in[.5,2], offset b in[-32,32],
unclipped samples with byte error E (default1, permitted0...2). This does not
cover arbitrary spatial illumination, per-channel changes, vertical movement,
blur or transparent input. A finite root sampler test motivates investigating
E=1; it is not a universal full-SDK error certificate.

For each integer source segment q=j+t, t in[0,1], RGB interpolation is B+G*t.
With alpha=1/g and beta=-b/g, each observation imposes

    (C-E)*alpha+beta <= B+G*t <= (C+E)*alpha+beta.

The noncentral samples' independent t variables are eliminated exactly via
Fourier-Motzkin: every lower t bound is paired with every upper bound; zero
coefficients contribute their original photometric inequalities. All integer
segments are retained as a UNION of convex polygons in(alpha,beta). Across
samples, intersect these unions without selecting the best correspondence.

Convex polygon clipping uses exact rational arithmetic, including point/segment
degeneracies. Intersecting convex pieces may be merged only when the area of
their convex hull equals the sum of their areas minus intersection area. Empty
intersections never merge; collinear intersecting segments can merge. Therefore
this is union simplification, not an overapproximate convexification or beam
search. The original ramp test reached the512-state cap before this exact
simplification; that failed run is preserved as development history.

For each final photometric piece, reintroduce central t and enumerate ALL
central source segments. The existing SHA-pinned exact4D clipping primitive
projects t extrema (one auxiliary dimension is irrelevant). Convert to signed
displacement x-j-t and return the hull over every feasible component. Flat,
periodic or photometrically ambiguous inputs can return broad hulls; there is
no tuned width cutoff. Empty or resource-exhausted solves fail closed.

## Bounds and privacy

Input width32...4096,3...7 samples, search<=64, states<=512, pair work<=100000,
and cooperative90-second deadline per interval. No state is truncated to meet
a cap. No private image path or image-file CLI exists; CLI only runs self-tests.
Actual generated source rows and output patches pass through a Python child in
memory from XCTest. The child emits only a containment count; stderr is discarded.
Nothing persists pixels, raw geometry, fixture locators or child transcripts.

## Verification contract

- Arbitrary non-affine signed profiles, including +/-4px, with two photometries.
- 1024-wide analytic paired contraction amounts-32/0/15/16/17/20/32/1024Q16,
  two photometries. Actual center truths must be contained; no amount<=16 may
  pass. Every32/1024Q16 pair MUST pass the unchanged16Q16 conservative margin.
- Flat/brightness-ramp controls preserve their true/ambiguous possibilities.
- The Swift integration reads actual canonical root renderer RGB at512 pixels
  on two generated field-center windows with displacement>1px. Bounds must
  contain independently evaluated Double sampler-input displacement. This
  checks model applicability to actual bytes, NOT independent anatomical truth.

Full effect scoring still requires source-only anatomical registration, source
and output format admission, protected/sibling checks, a reviewed frozen metric,
and the unchanged seven-active/one-deferred portrait gate. No Phase95 completion
or portrait acceptance follows from this experiment alone.
