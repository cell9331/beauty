---
spike: 002a
name: teeth-vision-color
type: comparison
validates: "Given actual Vision inner-lip support, when color-gated candidates are extracted, then teeth are isolated without leaking into lips, tongue, gums, or skin."
verdict: PARTIAL
related: [002b, 004, 005]
tags: [teeth, vision, deterministic]
---

# Spike 002a: Teeth Vision/Color

## What This Validates

Tests a dependency-free teeth candidate built from Apple Vision `innerLips`
plus luminance, saturation, and neutral-color gates, with fail-closed behavior
for closed mouths, absent candidates, and no-face input.

## Research

- Apple documents [`innerLips`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/innerlips)
  as the points outlining the space between the lips. It is useful containment
  support, but it is not a teeth segmentation.
- The [EasyPortrait paper](https://arxiv.org/abs/2304.13509) treats teeth as a
  separate annotated class and reports that mask quality and dataset diversity
  matter. This makes the deterministic path a useful baseline, not a presumed
  substitute for segmentation.

## How to Run

```bash
.planning/spikes/retouch-lab/.build/release/retouch-spike-lab \
  --mode teeth-heuristic \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/002-a-teeth-vision-color/artifacts/e6
```

## What to Expect

The red `overlay.png` stays inside the visible mouth opening. The closed-mouth
`e3` run has zero mask and zero changed pixels. The no-face gradient exits 1
with `No usable face landmarks were detected`.

## Observability

Only face/support counts, timings, mask/change counts, and aggregate image
metrics are logged. No lip polygon or teeth geometry is serialized.

## Investigation Trail

1. Started with a strict inner-lip polygon and color gate.
2. The broad-smile e6 case initially failed closed because bright teeth filled
   more than the first 78% plausibility ceiling.
3. Raised only the near-solid-mask ceiling to 94%; per-pixel lip/tongue gates
   remained in place. e6 then isolated the central teeth and e3 stayed at zero.
4. Compared with Spike 002b: the heuristic is safer and dependency-free, but it
   misses darker side teeth that the learned mask captures.

## Results

**Verdict: PARTIAL — safe baseline, insufficient coverage.**

The e6 run changed 5,540 of 6,099 masked pixels with zero outside-mask changes,
maximum channel delta 0.0745, and a 1.0515 texture-energy ratio. The e2 run
changed 780 pixels, also with zero leakage. The e3 closed-mouth run produced a
zero mask, and the no-face input failed closed.

This path is suitable as a fallback and test oracle, but it should not be the
only production mask until licensed real smiles demonstrate adequate coverage
across tooth shade, lighting, braces, gums, tongue, and partial occlusion.
