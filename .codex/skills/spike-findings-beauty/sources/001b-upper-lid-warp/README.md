---
spike: 001b
name: upper-lid-warp
type: comparison
validates: "Given the same band, when pixels redistribute inside fixed eye/brow boundaries, then the result is distinct from eye-opening geometry and remains natural."
verdict: INVALIDATED
related: [001a]
tags: [eyelid, warp, still-image]
---

# Spike 001b: Upper-Lid Warp

## What This Validates

Tests whether a small vertical redistribution entirely inside the upper-lid
band can create an independent `去脂` effect without moving the eye or eyebrow
boundaries and without behaving like `eyeHeight` or `upperEyelidLift`.

## Research

Landmarks can bound a warp, but they do not provide a target surface or a
fullness estimate. The same edge-aware literature used by Spike 001a warns that
multi-scale manipulation is artifact-prone; an interior warp also adds a
sampling/texture failure mode that color-only work avoids.

## How to Run

```bash
.planning/spikes/retouch-lab/.build/release/retouch-spike-lab \
  --mode upper-lid-warp \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/001-b-upper-lid-warp/artifacts/e6-release
```

## What to Expect

The eye and eyebrow boundaries remain fixed and `changedOutsideMask` remains
zero. Compare the eye region at 100% with Spike 001a; the warp should not be
promoted unless it has a clearer fullness benefit without texture loss.

## Observability

The shared harness emits the same aggregate counts, maximum delta,
luminance delta, texture-energy ratio, timing, and peak RSS as Spike 001a.

## Investigation Trail

1. Used the exact Spike 001a mask for a controlled comparison.
2. Forced displacement to zero at all band boundaries.
3. Kept displacement small and blended sampled pixels back into the source.
4. Both fixtures remained contained, but the warp reduced texture energy while
   providing no clearer perceptual `去脂` signal than the tone path.

## Results

**Verdict: INVALIDATED — reject this warp formulation.**

At 1728×2304 the warp changed 4,489 pixels with zero mask leakage, but maximum
channel delta rose to 0.1569 and texture-energy ratio fell to 0.9305. At
506×900 the ratio fell to 0.9188 and mean luminance shifted by -0.0090. The
release transform was fast (2.0 ms and 0.54 ms), but speed does not compensate
for lost texture and unproven semantics.

This invalidates the current boundary-fixed redistribution, not every possible
learned eyelid model. It also confirms that v1.14 must not alias `去脂` to an
existing eye-opening geometry parameter.
