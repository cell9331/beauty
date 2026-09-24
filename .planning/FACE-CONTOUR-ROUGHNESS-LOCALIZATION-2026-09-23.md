# FACE-01 generated-source roughness localization — 2026-09-23

## Question and boundary

After five fixed contour-mapping mechanics candidates failed the frozen first-stage
continuity floor, locate roughness in the **unchanged generated source** before
another candidate. This is a read-only diagnosis, not an effect implementation,
an oracle revision, or a Phase 90 attempt. No generated image, raw pixel row,
mask, landmark list, or private fixture locator is persisted.

The diagnostic re-created the generated 1000×1000 grayscale stripe fixture in
memory from `FaceContourSmoothRepairTests.swift`, using Swift `Float` contour
interpolation, integer-column rounding, the same ROI bounds, grayscale
darkness weights, Q16 integer centroids, and absolute second differences.
It emitted only grouped sums and counts. The resulting source continuity
`-51 Q16` matches the frozen fixture's established source metric. It does not
run Core Image or the SDK output path; exact Core Image aggregate parity was
not independently established.

## Fixed partition and result

Each target ROI contributes second differences centered at rows 281–818.
The lateral interval is rows 281–749 and the lower transition is 750–818.
Within the lateral interval, the six sampled contour joints at rows
360, 430, 500, 580, 660, and 750 each own a ±2-row window; the remainder
is counted as `lateral between joints`. The first contour endpoint at row
300 falls in that remainder, so this partition slightly overstates the
strictly straight-segment share.

| Region | Roughness sum (Q16) | Center rows | Share of total |
| --- | ---: | ---: | ---: |
| Lateral between joints | 38,547 | 884 | 69.4% |
| Lateral joint windows | 2,670 | 54 | 4.8% |
| Lower transition | 14,291 | 138 | 25.7% |
| **Total** | **55,508** | **1,076** | **100%** |

Left/right lateral between-joint sums are 19,300/19,247; joint-window sums
are 1,370/1,300; lower sums are 6,310/7,981. Among the 884 between-joint
center rows, 708 have nonzero Q16 second difference. The between-joint sum is
93.5% of all lateral roughness. Percentages above are rounded.

The metric returns `-(roughness / 1076)` with integer division. To reach a
`+16 Q16` gain from `-51`, a candidate must have metric at least `-35`, hence
roughness at most 38,735. Starting from 55,508, it must remove at least
16,773 Q16 roughness. Even eliminating all 14,291 lower-transition roughness
while leaving the lateral interval fixed yields only `-38` (a `+13` gain).
If the lower transition stays fixed, the lateral roughness must fall by at
least 40.7%.

## Acceptance-text cross-check

The package test's `continuityMetric` and the portrait comparator's
`contourContinuityGain` both sum absolute second differences of row darkness
centroids and return the negative integer average. The Phase 89 manifest fixes
the FACE-01 case, two lateral target regions, `+16 Q16` minimum margin, and
outside/central/background/watermark protections. The current taxonomy marks
the control `partial`, while `FUTURE-04` explicitly preserves the frozen
`+16 Q16` semantic/protection contract for a separately authorized milestone.
These documents and the executable metric agree about the current numerical
gate. They do not independently establish that this metric isolates perceived
face-outline smoothness from raster stepping on the generated fixture.

## Interpretation and next decision

The source contour between its sampled joints is piecewise linear, yet its
raster stripe center is rounded to whole pixel columns. A second difference
of those integer-column, darkness-weighted centroids measures many raster
steps on geometrically straight contour pieces. This explains why smoothing
the *sampled contour points* alone is a poor proxy for passing this particular
pixel metric. The source-only partition does not prove the frozen threshold
is impossible, that the current SDK effect is effective, or that a different
renderer cannot pass.

Before another effect candidate, review the FACE-01 acceptance intent against
this measured metric: is the requirement smooth geometric contour, or the
exact row-centroid/raster response? Preserve the original frozen test and
historical receipts. Any refined semantic oracle would need a new,
independently reviewed contract and additive tests; any image-aware candidate
under the existing oracle would still need the full locality, sibling,
metadata, backend, and owner-local portrait gates. FACE-01 remains `partial`.
