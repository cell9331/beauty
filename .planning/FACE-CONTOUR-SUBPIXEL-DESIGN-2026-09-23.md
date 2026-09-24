# FACE-01 contour raster refinement design — 2026-09-23

## Contract audit

The Phase 89 manifest, portrait comparator and SwiftPM generated oracle use
the same row-centroid absolute-second-difference metric and the same `+16 Q16`
minimum for `faceContourSmooth`. They are internally consistent. The generated
fixture rounds its observed piecewise-linear contour to whole pixel columns;
the source-only audit found most lateral roughness between its geometry joints.
Five contour-point or contour-curve targets did not pass the frozen first-stage
gate. The remaining gap is not remedied by changing a document label or
lowering the threshold.

## Exploratory mechanics, before SDK integration

A generated-only in-memory calculation shifted each lateral stripe row from
its rounded center column toward its observed continuous contour position by
at most half a pixel. The source stayed `-51 Q16`; direct row translation
reached `-15 Q16` (`+36`) with 11,000 changed target pixels and 343,482
absolute RGB delta. A bounded variant with a 14-pixel contour band, a 6-pixel
horizontal feather, and a 20-row endpoint taper reached `-16 Q16` (`+35`),
10,644 changed target pixels, and 329,469 absolute RGB delta. Both wrote only
the two target ROIs in the standalone calculation; neither was the SDK
renderer, a portrait result, or an acceptance receipt.

## Candidate integration rules

- Keep the existing public scalar, positive-only cap, observed-support gate,
  source-exact neutral, field-local failure, and historical evidence.
- Derive contiguous outer left/right lateral runs from the observed contour;
  leave the central chin arc unowned. Ambiguous support abstains.
- Apply the bounded subpixel x correction from immutable original raster bytes
  before the existing geometry warp, using the same request-local helper in
  CPU and Metal still-image paths. Copy alpha and all pixels outside the
  contour band exactly; reject correction where opaque-neighbor sampling is
  unavailable. Do not modify retained `Warp.metal`.
- Localize the existing point correction to the same lateral runs and reduce
  its maximum displacement/radius so the two mechanisms cannot reach the
  generated central or outside regions. Keep a positive inverse-map margin.
- Require the unchanged generated `+16 Q16` direction and signal floors,
  sibling distinction, outside/central/background/watermark ceilings,
  deterministic repeats, missing/malformed support recovery, compatible
  dimensions/orientations/color/alpha, and backend behavior before changing
  `partial`. A stand-alone mechanics pass is insufficient.

The source-only correction can smooth raster stairs without necessarily
smoothing a real portrait outline. Real owner-local portrait qualification and
its independent visual assessment remain necessary before promotion; failure
must leave FACE-01 `partial` and be recorded without altering old receipts.
