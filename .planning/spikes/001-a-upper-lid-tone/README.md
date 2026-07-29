---
spike: 001a
name: upper-lid-tone
type: comparison
validates: "Given an upper-lid band, when low-frequency luminance variation is compressed, then eyelid fullness appears reduced without moving protected geometry."
verdict: PARTIAL
related: [001b, 003]
tags: [eyelid, deterministic, still-image]
---

# Spike 001a: Upper-Lid Tone

## What This Validates

Tests whether a boundary-fixed band between Vision eye and eyebrow landmarks
can reduce the tonal cue of upper-eyelid fullness without moving the eye,
eyebrow, crease, or surrounding skin geometry.

## Research

- Apple Vision exposes eye, eyebrow, and pupil landmark regions, but no
  upper-eyelid-fat or fullness semantic. The band is therefore a geometric
  support region, not a diagnosis.
- [Local Laplacian Filters](https://people.csail.mit.edu/sparis/publi/2011/siggraph/)
  supports the direction of separating large-scale tone from small-scale
  detail for edge-aware edits. This spike uses a deliberately simpler
  low-frequency luminance estimate; it does not claim to implement that paper.
- No public paper or licensed model found in the research pass established
  `去脂` as a deterministic landmark-only edit. Real positive fixtures and a
  human naturalness review remain mandatory.

## How to Run

```bash
swift build -c release --package-path .planning/spikes/retouch-lab
.planning/spikes/retouch-lab/.build/release/retouch-spike-lab \
  --mode upper-lid-tone \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/001-a-upper-lid-tone/artifacts/e6-release
```

## What to Expect

`after.png` differs only inside the red band shown by `overlay.png`.
`metrics.json` must report `changedOutsideMask: 0`. The change should be
subtle; these AI-generated fixtures do not contain a licensed positive example
of upper-eyelid fullness.

## Observability

Each run writes aggregate-only `events.json` and `metrics.json`, plus local
visual artifacts. Events include support counts and timings, never landmark
coordinates.

## Investigation Trail

1. Built the band from observed eye and eyebrow support rather than a synthetic
   eye proxy.
2. Compressed only the estimated low-frequency luminance and added the original
   high-frequency residual back.
3. Ran two portraits at two resolutions and compared them with the identical
   mask used by Spike 001b.
4. Visual inspection found a restrained tonal change but no evidence that the
   result reads as reduced upper-eyelid fullness on a true positive case.

## Results

**Verdict: PARTIAL — mechanics pass; product semantics do not.**

On the 1728×2304 fixture, 8,946 mask pixels produced 7,560 changed pixels,
zero changes outside the mask, maximum channel delta 0.0667, and texture-energy
ratio 0.9996. The release transform took 28.4 ms after landmark detection.
The 506×900 fixture retained a 0.9866 texture-energy ratio.

This is the comparison winner because it preserves geometry and texture, but
it cannot authorize `去脂`: no licensed real positive/negative fixtures or
human original-detail review were available.
