---
spike: 003
name: sclera-redness-mask
type: standard
validates: "Given actual eye contours and pupils, when sclera/redness candidates are extracted, then iris, lashes, skin, and specular highlights remain protected."
verdict: PARTIAL
related: [001a, 004, 005]
tags: [eyes, redness, privacy]
---

# Spike 003: Sclera Redness Mask

## What This Validates

Tests a local sclera candidate from the observed eye aperture, mandatory
pupil-centered iris exclusion, specular protection, and a bounded red-excess
score.

## Research

- Apple notes that [`leftPupil`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/leftpupil)
  may be inaccurate during a blink, which makes missing/blinking support a
  fail-closed case rather than a reason to guess.
- [Robust Sclera Segmentation for Skin-tone Agnostic Face Image Quality Assessment](https://arxiv.org/abs/2312.15102)
  demonstrates a landmark eye hull plus iris exclusion and reports robustness
  across skin tone, resolution, transparent glasses, and small pose changes.
  The spike adopts that geometric principle, then adds conservative color and
  highlight gates; it does not implement or claim the paper's full method.
- Sclera vasculature can be identifying. Masks and vein-like descriptors stay
  request-local and are absent from logs.

## How to Run

```bash
.planning/spikes/retouch-lab/.build/release/retouch-spike-lab \
  --mode sclera-redness \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/003-sclera-redness-mask/artifacts/e6-release
```

## What to Expect

`overlay.png` marks red sclera candidates inside the eye aperture, mainly near
the inner corners on these fixtures. Iris, pupil, lashes, skin, and highlights
remain unmarked.

## Observability

Events contain eye/pupil support counts and aggregate timings only. Raw masks
exist only as explicit local spike artifacts for visual review; production
diagnostics must never persist them.

## Investigation Trail

1. Built the aperture from actual Vision eye contours.
2. Excluded a pupil-centered iris radius derived from eye width/height.
3. Added luminance, saturation, redness, and specular gates.
4. Inspected a high-resolution brown-eye fixture and a smaller blue-eye fixture;
   both masks stayed in visible sclera and changed no protected pixels.

## Results

**Verdict: PARTIAL — geometry/privacy mechanics pass; real-positive coverage is unproven.**

The e6 run masked 4,888 pixels and changed 2,267 with zero outside-mask change,
0.0706 maximum channel delta, -0.000025 mean luminance delta, and 0.99993
texture-energy ratio. The release transform took 65.3 ms after detection. The
e3 fixture changed only 178 pixels and retained a 0.99955 texture ratio.

Licensed real positives with veins/redness, glasses, blink, side pose, makeup,
contact lenses, and low light are still required before a product verdict.
