# FACE-01 side-band feasibility — fixed candidate, 2026-09-23

## Scope and fixed construction

This study runs one generated, in-memory, grayscale raster prototype outside
`BeautySDK`. It is a mechanics probe, not the package's frozen CPU oracle or a
portrait qualification. The candidate is fixed before observing output:

- Reuse the generated left/right contour points and 1000×1000 stripe fixture
  from `FaceContourSmoothRepairTests.swift`; interpolate each side's x position
  linearly by y.
- At each row center y, set `h=0.04` and target curve
  `s(y)=(x(y-h)+2*x(y)+x(y+h))/4`, with samples clamped to the side's endpoint
  y range. Set `d(y)=clamp(s(y)-x(y), -0.0096, +0.0096)`.
- Use a side-local horizontal band `B=0.015` and vertical endpoint taper of
  width `0.04`: `u(x,y)=d(y) * max(0,1-|x-x(y)|/B) * taper(y)` inside the
  side's observed y range, zero elsewhere. Sample the original row at `x-u`
  with linear interpolation; copy original pixels exactly where `u=0`.
- No output-dependent parameter search, threshold edit, fixture change,
  second candidate, production source edit, or historical evidence rewrite.

The initial containment estimate, left `[0.150,0.240]` and right
`[0.760,0.850]`, considered only the lateral cheek samples. It was wrong for
the complete generated contour: its lower left endpoint reaches `x=0.420`
and lower right endpoint reaches `x=0.580`, placing both lower bands in the
protected central region. This error was found by the single fixed execution;
the candidate is not repaired or rerun. Because `|d|/B <= 0.64`, the
horizontal inverse map has
`1 - du/dx >= 0.36` wherever differentiable; this is a construction bound,
not measured package acceptance.

## Locked first-stage gate

Calculate the existing generated test's continuity metric, target signal,
outside signal, central signal, background, and watermark from the original
and one candidate output. First-stage go requires source/neutral signed
continuity `>=+16 Q16`, target `>=1000 changed pixels / >=3000 absolute RGB`,
outside `<=500 / <=1500`, central `<=128 / <=512`, exact background and
watermark, and deterministic repeat. Any miss is a stop. Frozen and
strengthening sibling comparisons, actual SDK rendering, metadata, and real
portrait qualification are explicitly unproven at this stage and would be
required before FACE-01 promotion.

## Result

The one predeclared temporary Swift prototype executed once against its
generated grayscale fixture. It used the same contour coordinates, stripe
generation, continuity calculation, target/central/background/watermark
regions, changed-pixel threshold, and aggregate RGB-delta definitions as the
frozen test, but it did not invoke `BeautyGeometryEffectPipeline` or Core Image.
The result is therefore a mechanics rejection, not an SDK/oracle verdict.

| Aggregate | Observed | First-stage gate |
| --- | ---: | ---: |
| Source continuity | `-51 Q16` | reference |
| Candidate continuity | `-45 Q16` | reference |
| Source/neutral improvement | `+6 Q16` | `>=+16 Q16` |
| Target changed pixels / absolute RGB | `15581 / 4654212` | `>=1000 / >=3000` |
| Outside changed pixels / absolute RGB | `1684 / 428172` | `<=500 / <=1500` |
| Central changed pixels / absolute RGB | `1583 / 385749` | `<=128 / <=512` |
| Background and watermark | `0 / 0` each | exact zero |
| Deterministic repeat | equal | equal |

**Disposition: STOP.** Continuity, outside, and central gates fail. The
unproven sibling/SDK/portrait gates were not run or credited. The private
temporary prototype is removed after this aggregate record. A successor would
need to define semantic side ownership that excludes the lower central chin
arc before proposing a new fixed candidate; this is a new design question,
not a parameter adjustment to this failed candidate.
