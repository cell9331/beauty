---
spike: 009
name: adaptive-teeth-mask
type: standard
validates: "Given wide smiles with darker side teeth, when adaptive local scoring and connected candidates are compared with the fixed Vision/color baseline, then useful coverage increases without lip/tongue/gum leakage and closed-mouth behavior remains fail-closed."
verdict: PARTIAL
related: [002a, 002b, 004, 006]
tags: [teeth, deterministic, comparison, coverage]
---

# Spike 009: Adaptive Teeth Mask

## What This Validates

Tests whether the deterministic teeth path can recover side teeth that Apple
Vision's `innerLips` polygon excludes, without introducing a model dependency.
The comparison keeps the fixed inner-lip/color mask as high-confidence seeds,
derives local brightness/chroma thresholds, and grows only connected candidates
inside a narrow mouth envelope.

## Research

- Apple documents [`innerLips`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/innerlips)
  as the outline of the space between the lips. The broad-smile fixtures confirm
  that this is useful seed support but not full teeth segmentation.
- [Otsu's original threshold-selection paper](https://skynet.ecn.purdue.edu/~ace/vip/A_Threshold_Selection_Method_from_Gray-Level_Histograms_otsu.pdf)
  provides a deterministic way to derive a local intensity split from each
  mouth rather than fixing one global luminance threshold.
- [Seeded Region Growing](https://www.csd.uoc.gr/~hy471/papers/SRG.pdf) describes
  growing regions from explicit seeds according to local similarity. Here the
  fixed mask supplies the seeds and eight-connected color candidates bound the
  growth.
- [EasyPortrait](https://arxiv.org/abs/2304.13509) treats teeth as a separate
  semantic class and shows why real segmentation remains the stronger reference
  path when its dataset, checkpoint, and license chain can be approved.

| Approach | Pros | Cons | Status |
| --- | --- | --- | --- |
| Fixed `innerLips` + absolute color gate | Simple, dependency-free, fail-closed | Misses side teeth outside the aperture polygon | Baseline |
| Otsu threshold alone | Adapts to shade and exposure | Cannot distinguish connected teeth from lip/tongue by itself | Rejected alone |
| Outer-lip polygon + adaptive color | Recovers side teeth | Initial version leaked into the upper lip | Rejected |
| Seeded growth in a narrow mouth envelope | Local, deterministic, expands only from accepted teeth, preserves closed-mouth failure | Still needs licensed real review across gums, tongue, braces, occlusion, and skin tones | **Chosen** |

## How to Run

```bash
swift build -c release --package-path .planning/spikes/retouch-lab

.planning/spikes/retouch-lab/.build/release/retouch-spike-lab \
  --mode teeth-compare \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/009-adaptive-teeth-mask/artifacts/e6

open .planning/spikes/009-adaptive-teeth-mask/review.html
```

Repeat with `example-images/parked-portraits/e2.png` for a second smile and
`e3.png` for the closed-mouth negative. The no-face gradient must exit 1.

## What to Expect

- `fixed-overlay.png` covers only the central teeth supported by `innerLips`.
- `adaptive-overlay.png` extends laterally across connected neutral tooth pixels
  while remaining vertically bounded near the detected mouth aperture.
- `comparison.json` records strong-mask additions/drops, transforms, timings,
  texture energy, and containment; it contains no landmark coordinates.
- The closed-mouth case emits zero masks and zero changed pixels.

## Observability

Events contain only face/support counts, mouth-region pixel counts, timings,
and aggregate fixed/adaptive mask counts. Raw landmarks, candidate colors,
mouth geometry, masks, and teeth descriptors are not serialized into events.
PNG masks remain local disposable spike artifacts.

## Investigation Trail

1. Re-ran the fixed baseline with a non-feathered `innerLips` containment mask.
   On e6 it strongly selected 4,711 pixels, visibly limited to the central four
   teeth; adaptive scoring inside that same polygon added only 23 pixels.
2. Confirmed the blocker was geometric support rather than the absolute color
   threshold: visible side teeth lie outside Vision's inner-lip aperture.
3. Tried adaptive growth across the full outer-lip polygon. Coverage improved,
   but a visible strip of upper lip was selected, so that version was rejected.
4. Restricted the search to the outer-lip polygon intersected with a small
   vertical envelope: a 5% upper safety inset and a 10% lower extension of the
   inner-lip aperture. Fixed-mask pixels seed an eight-connected flood through
   candidates scored by local Otsu/percentile luminance and chroma limits.
5. Preserved the fixed mask with `max(fixed, adaptive)`, clipped the final mask
   to the candidate envelope, and retained the 1.5%–94% plausibility guard.
   Missing seeds and implausible geometry fail closed.
6. Added deterministic self-tests for the upper-lip safety inset, connected
   candidate growth, empty-seed failure, and already-light whitening no-op;
   the shared harness now passes 23/23 self-tests.

## Results

**Verdict: PARTIAL — adaptive coverage wins on mechanics fixtures; real protected-tissue evidence is still absent.**

| Fixture | Fixed strong px | Adaptive strong px | Added | Dropped | Outside-mask changes |
| --- | ---: | ---: | ---: | ---: | ---: |
| e6 wide smile | 4,711 | 7,396 | 2,685 (+57.0%) | 0 | 0 |
| e2 smile | 462 | 805 | 343 (+74.2%) | 0 | 0 |
| e3 closed mouth | 0 | 0 | 0 | 0 | 0 |

The final overlays visibly cover the side teeth on e6 and e2 without the upper
lip leakage seen in the rejected full-envelope attempt. Both transforms report
zero changes outside their own masks; e3 remains zero, and the no-face input
exits 1 with `No usable face landmarks were detected`. Release build and all
23 shared harness self-tests pass.

This clears the narrow deterministic mechanics question but not product
feasibility. The fixtures are AI-generated, there are only two positive smiles,
and there is no licensed review evidence for lip, tongue, gum, braces, shade,
occlusion, or demographic variation. Production must therefore remain gated by
Spike 006 and should still compare against an approved teeth segmenter when one
is legally available.
