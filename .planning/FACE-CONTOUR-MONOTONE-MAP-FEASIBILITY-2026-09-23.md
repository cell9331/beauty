# FACE-01 monotone row-map feasibility — fixed candidate, 2026-09-23

## Predeclared construction

Use the unchanged generated 1000×1000 grayscale FACE-01 stripe fixture,
including its full lower chin arc. Side ownership and one least-squares
quadratic target curve are exactly the prior lateral-fit candidate: derive
`centerX` and `halfSpan` from contour min/max x, select contiguous runs beyond
`centerX ± halfSpan/2`, require at least four monotone-y points per side, fit
one quadratic in normalized y, and clip target shift to `±0.0096`.

Change only the raster mapping mechanism. At each eligible row, taper the
target shift to zero within `0.04` y of either lateral-run endpoint. The left
source band is `[contourX-0.030, contourX+0.015]`; the right source band is
`[contourX-0.015, contourX+0.030]`. Fix both band endpoints and map the source
contour center to `contourX+shift` with one affine segment on each side.
For each output pixel inside the same band, invert that two-segment strictly
increasing map and sample the original row linearly. Copy source bytes exactly
outside the bands. No amplitude, band, fit, or threshold search follows output.

For the generated lateral x ranges, left bands stay within `[0.135,0.240]`
and right bands within `[0.760,0.865]`, both inside the frozen target ROIs.
The maximum normalized center shift `0.0096` is smaller than the narrowest
half-band `0.015`; each forward segment therefore has derivative at least
`1-0.0096/0.015=0.36`, so the horizontal map is order preserving at every
row. This is a mechanical bound, not actual SDK acceptance.

## Fixed first-stage gate

Match the frozen test's generated input and aggregate continuity, target,
outside, central, background, watermark, and repeat calculations. Require
source/neutral gain `>=+16 Q16`, target `>=1000 changed pixels / >=3000
absolute RGB`, outside `<=500 / <=1500`, central `<=128 / <=512`, exact
background/watermark, and repeat equality. A miss is STOP. A pass would only
permit a separate package-level prototype with sibling, metadata, degraded
support, backend, and real-portrait gates; it does not change the current
`partial` status or old signed receipts.

## Result

The one fixed standalone mechanics run used the full generated contour for the
source fixture and seven lateral samples per side for the map. It returned:

| Aggregate | Observed | First-stage gate |
| --- | ---: | ---: |
| Source continuity | `-51 Q16` | fixture identity check |
| Candidate continuity | `-53 Q16` | reference |
| Source/neutral improvement | `-2 Q16` | `>=+16 Q16` |
| Target changed pixels / absolute RGB | `17506 / 5767164` | `>=1000 / >=3000` |
| Outside and central | `0 / 0` each | `<=500 / <=1500`; `<=128 / <=512` |
| Background and watermark | `0 / 0` each | exact zero |
| Deterministic repeat | equal | equal |

**Disposition: STOP.** This row map preserves the generated protection bands
and stays order preserving, but the predeclared quadratic target worsens the
continuity metric. The temporary prototype is removed. This is a standalone
grayscale mechanics observation, not a frozen SwiftPM oracle or a portrait
result. No sibling, metadata, degraded-support, backend, or real-photo credit
is assigned. Any successor needs a target-curve construction justified by
contour continuity itself rather than another tuning of this failed fit.
