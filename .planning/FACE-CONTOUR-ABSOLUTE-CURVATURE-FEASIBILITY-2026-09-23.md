# FACE-01 absolute-curvature target feasibility — fixed candidate, 2026-09-23

## Predeclared candidate

Use the same complete generated source fixture and the same seven-point left
and right lateral runs as the previous studies. For each run, let the observed
samples be `(x_i,y_i)` in increasing y. Fix endpoint x values; for interior
samples find `z_i` minimizing

`sum_i |(z_(i+1)-z_i)/(y_(i+1)-y_i) - (z_i-z_(i-1))/(y_i-y_(i-1))|`

subject to `|z_i-x_i|<=0.0096`. This is a convex absolute slope-jump
objective on observed geometry only; it matches the *form* of the frozen
absolute-curvature metric without reading source or output pixels to choose
the target. Solve it with deterministic ADMM: split slope jumps and the box,
`rho=1`, `eta=1`, fixed ordering, at most `20000` iterations, and primal plus
dual infinity-norm residual `<=1e-8`. If it does not converge, stop without
rendering. Interpolate the target lateral curve linearly in y.

Use the same fixed piecewise-affine, strictly increasing per-row inverse map:
left band `[x-0.030,x+0.015]`, right band `[x-0.015,x+0.030]`, center shift
clipped to `±0.0096`, `0.04` y endpoint taper, original source sampling, and
exact copy outside. The forward x derivative is at least `0.36` on the
generated fixture. No output-based iteration, amplitude change, alternate
band, or fallback candidate is allowed.

## Locked first-stage gate

The source continuity must equal `-51 Q16`. Require generated source/neutral
continuity gain `>=+16 Q16`, target `>=1000 changed pixels / >=3000 absolute
RGB`, outside `<=500 / <=1500`, central `<=128 / <=512`, exact background and
watermark, and deterministic repeat. A solver or gate miss is STOP. A passing
mechanics result would still need the unchanged SwiftPM oracle, sibling
comparison, metadata, support degradation, backend, and owner-local portrait
evidence before FACE-01 could leave `partial`.

## Result

The first numerical attempt below produced no candidate output. Its exact
small-problem successor retained the same objective and produced the result
recorded after the addendum.

### Numerical-method addendum before any candidate output

The predeclared ADMM exceeded 20000 iterations with residual
`0.005938057210658209` and raised `solver_not_converged` before source or
candidate rendering. That attempt receives no gate credit. The geometry
objective, five free interior x variables per side, box, map, and thresholds
remain fixed. A solver-only successor enumerates vertices of the arrangement
formed by the five zero-slope-jump hyperplanes and ten lower/upper box faces.
For each five-hyperplane combination it solves the 5×5 system, discards
singular or box-infeasible results, and selects the minimum absolute
slope-jump objective with a deterministic lexicographic tie break. A bounded
piecewise-linear convex function on this compact box has an optimum at an
arrangement vertex. This exact small-problem method reads contour geometry
only; no rendered output has yet been inspected.

### Exact small-problem result

The vertex solver found 32 feasible arrangement vertices per side and chose
the minimum absolute slope-jump objective (`3.9123015873015867` left,
`3.912301587301572` right). The one fixed generated map produced:

| Aggregate | Observed | First-stage gate |
| --- | ---: | ---: |
| Source continuity | `-51 Q16` | fixture identity check |
| Candidate continuity | `-53 Q16` | reference |
| Source/neutral improvement | `-2 Q16` | `>=+16 Q16` |
| Target changed pixels / absolute RGB | `15985 / 4015479` | `>=1000 / >=3000` |
| Outside, central, background, watermark | `0 / 0` each | respective limits / exact zero |
| Deterministic repeat | equal | equal |

**Disposition: STOP.** Minimizing absolute slope jumps of the seven observed
lateral points still does not improve the frozen pixel-centroid continuity.
The result does not justify altering the oracle or another output-guided
candidate. This is standalone grayscale mechanics evidence only. The next
useful question is where the unchanged source oracle's roughness is located,
particularly at the lateral-to-chin transition that these side-only maps
leave untouched. The temporary candidate prototype is removed after
aggregate-only recording.
