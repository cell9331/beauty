# FACE-01 lateral-side fit feasibility — fixed candidate, 2026-09-23

## Structural finding

The observed semantic face support has an optional median line and optional
apex index. The frozen generated FACE-01 fixture supplies neither. A candidate
whose side selection requires those fields would fail the unchanged generated
gate before it can demonstrate effectiveness. The contour itself is an ordered
simple path, however, and the generated support has distinct outer lateral
runs joined by a lower central chin arc.

## One fixed construction

This is a new, single mechanics candidate, not a parameter revision of the
failed strip probe. It is fixed before output is inspected:

1. Validate finite ordered contour points. Compute `centerX=(minX+maxX)/2`
   and `halfSpan=(maxX-minX)/2`. Only points with
   `x <= centerX-halfSpan/2` belong to the left lateral run and only points
   with `x >= centerX+halfSpan/2` belong to the right. Require each run to be
   contiguous, contain at least four points, and progress monotonically down
   or up its own side. All central chin points are excluded; ambiguous input
   makes this named field fail closed.
2. On each lateral run, interpolate the original `x(y)` linearly. Fit one
   least-squares quadratic `a+b*t+c*t²` to that run's observed x positions,
   where `t` is y normalized to its own first/last y. No output-informed
   fitting, shape selector, or fallback. Set displacement to the fitted x
   minus original x, clipped to `±0.0096` normalized units (the existing
   `0.012 * 0.80` cap in the fixed generated fixture).
3. Apply horizontal inverse sampling only in a `0.015` normalized side band
   around the original contour, with triangular falloff to exact zero at the
   band edge and a `0.04` y taper to exact zero at both lateral endpoints.
   Outside both bands copy original bytes. `|du/dx| <=0.0096/0.015=0.64`,
   so the proposed horizontal inverse determinant is at least `0.36` where
   differentiable on this generated geometry.

The owner-derived side threshold uses only contour extent, not the frozen
oracle ROI. It excludes the generated lower central arc while retaining seven
samples per side. Real-observation robustness is unproven.

## Locked first-stage gate

Use the same generated 1000×1000 stripe input and metric definitions as the
existing FACE-01 test. Require source/neutral continuity gain `>=+16 Q16`,
target signal `>=1000 changed pixels / >=3000 absolute RGB`, outside
`<=500 / <=1500`, central `<=128 / <=512`, exact background/watermark, and
deterministic repeat. Failure stops this candidate. Sibling comparisons,
actual SDK rendering, metadata, real portraits, and product quality remain
unproven even on a first-stage pass.

## Result

The first scratch run accidentally generated the input stripe from the
filtered lateral runs, which removed the lower chin portion from the *source*
fixture. Its source continuity was `-38 Q16`, inconsistent with the unchanged
fixture's `-51 Q16`; that run is invalid and receives no gate credit. The
scratch input generator was corrected to use the complete original contour.
The mapping formula, lateral partition, fit, cap, band, taper, and thresholds
were unchanged, and the corrected run produced these aggregates:

| Aggregate | Corrected result | First-stage gate |
| --- | ---: | ---: |
| Lateral support counts | `7 / 7` | at least 4 per side |
| Source continuity | `-51 Q16` | fixture identity check |
| Candidate continuity | `-44 Q16` | reference |
| Source/neutral improvement | `+7 Q16` | `>=+16 Q16` |
| Target changed pixels / absolute RGB | `15419 / 5168211` | `>=1000 / >=3000` |
| Outside changed pixels / absolute RGB | `0 / 0` | `<=500 / <=1500` |
| Central changed pixels / absolute RGB | `0 / 0` | `<=128 / <=512` |
| Background and watermark | `0 / 0` each | exact zero |
| Deterministic repeat | equal | equal |

**Disposition: STOP.** Semantic continuity misses the frozen floor even though
the side partition removes the prior locality leak. The temporary prototype
is removed after recording aggregates. This was a standalone grayscale
mechanics simulation, not Core Image or the package's frozen CPU oracle;
sibling distinction, SDK routing, metadata, and real portraits were not run.
The failure does not prove a mathematical impossibility for all future maps,
but it rules out this predeclared contour-only quadratic fit as an acceptable
repair and provides no reason to alter the threshold or promote FACE-01.
