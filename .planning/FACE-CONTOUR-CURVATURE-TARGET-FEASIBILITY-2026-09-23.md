# FACE-01 curvature-target feasibility — fixed candidate, 2026-09-23

## Predeclared construction

Keep the previous seven-sample lateral side ownership and the generated
source fixture with its entire chin arc. For each side, sample its observed
piecewise-linear contour x at every 1000px row center between the first and
last lateral sample. Let these values be `x_r`.

Find one target row curve `z_r` by minimizing the convex objective
`sum_r (z_(r-1)-2*z_r+z_(r+1))²`, subject to fixed endpoints and
`|z_r-x_r|<=0.0096`. Use deterministic projected coordinate descent, fixed
row order, at most 2000 sweeps, stopping only when a complete sweep changes
no value by more than `1e-10`. If it has not converged, reject the candidate;
do not select a partial iterate from output quality. This objective reads
only the observed contour, not source or rendered pixel values.

Apply `d_r=z_r-x_r` through the same left/right two-segment monotone row map
as [the previous mechanism](FACE-CONTOUR-MONOTONE-MAP-FEASIBILITY-2026-09-23.md):
left band `[-0.030,+0.015]`, right band `[-0.015,+0.030]` relative to each
row's observed contour, fixed endpoints, center moved by `d_r` with the same
`0.04` endpoint taper, original-row interpolation inside, exact copy outside.
The `0.0096<0.015` cap preserves a forward horizontal derivative `>=0.36`.
No output-informed parameter adjustment or fallback is permitted.

## Locked first-stage gate

The unchanged 1000×1000 generated input must have source continuity `-51 Q16`.
Require source/neutral continuity improvement `>=+16 Q16`, target signal
`>=1000 changed pixels / >=3000 absolute RGB`, outside `<=500 / <=1500`,
central `<=128 / <=512`, exact background/watermark, and deterministic repeat.
Any solver or metric miss is STOP. Even a pass would still require actual SDK
oracle, sibling, degraded-support, metadata, backend, and owner-local portrait
evidence before changing `partial` status.

## Result

The first fixed solver attempt below produced no candidate output. Its
numerically corrected successor used the same convex objective and produced
the aggregate result recorded after the addendum.

### Numerical-method addendum before any image output

The predeclared projected coordinate descent reached its 2000-sweep limit
with maximum last-sweep change `3.721195326322757e-07`; it raised
`solver_not_converged` before creating a candidate raster. This attempt is
invalid and receives no gate credit. The geometry objective, bounds, source
fixture, mapping, and acceptance thresholds remain fixed. To solve that same
convex objective, a new numerical attempt uses projected accelerated gradient
with step `1/32` (the gradient's conservative Lipschitz bound), at most 20000
iterations, and projected-gradient residual `<=1e-9`; if that also fails,
stop without rendering. This is a solver-only change made without inspecting
any candidate output.

### Corrected numerical result

The accelerated solver reached projected-gradient residual
`9.970691494665118e-10` in `15584` iterations for each side. The one
generated candidate then produced:

| Aggregate | Observed | First-stage gate |
| --- | ---: | ---: |
| Source continuity | `-51 Q16` | fixture identity check |
| Candidate continuity | `-51 Q16` | reference |
| Source/neutral improvement | `0 Q16` | `>=+16 Q16` |
| Target changed pixels / absolute RGB | `15049 / 2974476` | `>=1000 / >=3000` |
| Outside, central, background, watermark | `0 / 0` each | respective limits / exact zero |
| Deterministic repeat | equal | equal |

**Disposition: STOP.** The squared-curvature optimum is not a passing proxy
for the frozen absolute-curvature pixel metric. This does not prove all
contour-derived maps impossible. A successor would need an independently
defined absolute-curvature target rather than changing the amplitude or
selecting among outputs. The temporary prototype is deleted; no package
oracle, sibling, backend, metadata, or real-photo credit is assigned.
