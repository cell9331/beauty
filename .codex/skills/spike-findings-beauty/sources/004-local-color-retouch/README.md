---
spike: 004
name: local-color-retouch
type: standard
validates: "Given accepted teeth and redness masks, when bounded chroma correction runs, then yellow/red excess falls while luminance and texture remain stable."
verdict: PARTIAL
related: [002a, 002b, 003, 005]
tags: [color, compositing, safety]
---

# Spike 004: Local Color Retouch

## What This Validates

Tests one request-local color pass that whitens teeth by reducing yellow excess
and reduces sclera redness while preserving local luminance, texture, and all
pixels outside the accepted masks.

## Research

The segmentation research in Spikes 002 and 003 supports separating tissue
selection from color modification. The transform therefore does not infer
anatomy, move geometry, globally desaturate the face, or smooth texture.

## How to Run

```bash
.planning/spikes/retouch-lab/.build/release/retouch-spike-lab \
  --mode combined-color \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/004-local-color-retouch/artifacts/e6
```

## What to Expect

`teeth-mask.png` and `sclera-mask.png` are disjoint. The after image has a
restrained change and `changedOutsideMask` is zero.

## Observability

The shared metrics report coverage, maximum delta, mean luminance delta,
texture-energy ratio, duration, and peak RSS. Logs contain no region geometry.

## Investigation Trail

1. Implemented separate tooth-yellow and sclera-red corrections.
2. Added a luminance correction after chroma edits and capped teeth brightness.
3. Composed both masks once rather than applying a global or repeated filter.
4. Ran at 506×900 and 1728×2304; the second run includes both accepted masks
   after the broad-smile heuristic was repaired.

## Results

**Verdict: PARTIAL — bounded transform is sound; mask/product validation remains.**

At 1728×2304 the union covered 10,987 pixels, changed 7,807, leaked to zero
outside pixels, and capped channel delta at 0.0745. Mean masked luminance rose
0.00954 and texture-energy ratio was 1.0356. At 506×900 the respective values
were 0.00658 and 1.0236.

The transform can be reused behind a validated mask provider. It does not make
the heuristic or external Core ML mask production-ready by itself.
