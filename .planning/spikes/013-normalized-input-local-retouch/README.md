---
spike: 013
name: normalized-input-local-retouch
type: standard
validates: "Given the same visible still portrait represented by all EXIF orientation and mirror cases, sRGB/Display-P3 encodings, transparent borders, and invalid metadata or non-RGB input, when it is normalized once into the canonical image space before Vision, mask generation, and original-pixel composition, then orientation variants byte-match the canonical oracle, color-managed variants remain within a declared conversion tolerance without changing mask topology, alpha and outside-mask pixels are preserved, and unsupported input fails closed without sensitive diagnostics."
verdict: PARTIAL
related: [005, 009, 010, 011, 012]
tags: [integration, orientation, color-space, alpha, safety, privacy]
---

# Spike 013: Normalized Input Local Retouch

## What This Validates

Tests the handoff from encoded still-image input to Spike 012's request-local
adaptive-teeth and guarded-sclera composition. ImageIO metadata is validated,
Core Image rotates or mirrors pixels into one up-oriented sRGB RGBA8 canvas,
and Vision plus rendering consume that same canonical image.

The experiment separates three questions: lossless EXIF orientation identity,
color-profile round-trip sensitivity, and transparent-canvas behavior. It also
injects invalid orientation and non-RGB input before Vision. No production
normalizer or public contract is modified.

## Research

- Apple defines [`CGImagePropertyOrientation`](https://developer.apple.com/documentation/imageio/cgimagepropertyorientation)
  as the intended display orientation and explicitly notes that correct
  orientation matters for image processing such as face recognition.
- [`CIImage.oriented(forExifOrientation:)`](https://developer.apple.com/documentation/coreimage/ciimage/oriented%28forexiforientation%3A%29)
  applies the EXIF rotation or mirror transform, allowing Vision and rendering
  to share one up-oriented pixel canvas.
- [`CIContext`](https://developer.apple.com/documentation/coreimage/cicontext)
  color-matches inputs into its working space and renders into the destination
  space. Its explicit RGBA8/sRGB render is used rather than device RGB.
- Apple's [`VNImageRequestHandler`](https://developer.apple.com/documentation/vision/vnimagerequesthandler/init%28cgimage%3Aorientation%3Aoptions%3A%29-63ojm)
  accepts a known input orientation. This spike normalizes pixels first and then
  supplies `.up`, preventing detection and rendering from owning different
  coordinate interpretations.
- Core Graphics identifies [Display P3](https://developer.apple.com/documentation/coregraphics/cgcolorspace/displayp3)
  as DCI-P3 primaries with D65 and the sRGB transfer function. The experiment
  converts the same sRGB fixture through an 8-bit P3 TIFF and back to expose
  quantization and detector sensitivity—not to claim arbitrary gamut coverage.

| Approach | Benefit | Risk | Decision |
| --- | --- | --- | --- |
| Keep encoded pixels and pass orientation only to Vision | Avoids a canonical render | Renderer/masks still need a second coordinate mapping; easy to split detection from output ownership | Rejected for this handoff |
| ImageIO transformed thumbnail | Applies metadata during decode | Thumbnail API may scale and is not an exact full-resolution oracle | Rejected |
| Validate metadata, Core Image orient/color-manage once, then use `.up` everywhere | One pixel and coordinate owner; explicit sRGB RGBA8 boundary | 8-bit profile conversion is not byte-identical and Vision may react to tiny changes | **Chosen** |

## How to Run

```bash
swift build -c release \
  --package-path .planning/spikes/retouch-lab \
  --scratch-path /tmp/beauty-spike-013-build

/tmp/beauty-spike-013-build/release/retouch-spike-lab \
  --mode normalized-input-contract \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/013-normalized-input-local-retouch/artifacts/e6

/tmp/beauty-spike-013-build/release/retouch-spike-lab --mode self-test
open .planning/spikes/013-normalized-input-local-retouch/review.html
```

Repeat with `example-images/parked-portraits/e2.png` and `e3.png`. The no-face
gradient must still exit 1.

## What to Expect

- `orientation-6-encoded-pixels.png` is physically sideways; its normalized
  output and overlay align exactly with the canonical result.
- `canonical-*` is the lossless sRGB TIFF oracle used for all eight orientations.
- `display-p3-normalized-*` shows the P3 round trip. It looks equivalent, but
  comparison metrics expose small detector/mask differences.
- `transparent-border-*` retains a transparent outer border. Alpha and RGB
  outside the accepted union remain byte-preserved.
- `comparison.json` contains aggregate pixel, topology, anchor-delta, rejection,
  and resource counts. No file path, coordinate, mask sample, or profile payload
  is persisted.

## Observability

Tracked events contain only mode; aggregate variant count; total orientation
pixel/topology mismatch; maximum orientation anchor delta; P3 maximum channel
delta and topology mismatch; alpha mismatch; rejected-input count; and duration.
Per-variant orientation numbers exist only in aggregate comparison evidence.
Raw EXIF dictionaries, ICC data, paths, landmarks, masks, and pixels are absent
from events.

## Investigation Trail

1. Confirmed the shared harness decoded `CGImage` bytes while always telling
   Vision `.up`, and rasterized through device RGB. That path ignored metadata
   and lacked one explicit color owner.
2. Added an sRGB RGBA8 Core Image boundary backed by a reused context. Missing
   orientation defaults to `.up`; numeric values outside EXIF 1...8 and non-RGB
   color models fail before Vision.
3. Generated eight lossless TIFF representations in memory. For orientations
   5...8 the encoded dimensions swap, and orientation 6 is visibly sideways.
   After normalization, all eight inputs, anchors, strong masks, alpha bytes,
   and final outputs byte-match the canonical oracle on e6/e2/e3.
4. Converted the canonical sRGB image into Display P3 RGBA8, encoded it, and
   normalized it back to sRGB. All fixtures stayed within one input byte of the
   oracle, but fresh Vision anchors moved by 0.53–1.56 px. That produced 8, 15,
   and 76 strong-mask topology differences and maximum final channel deltas of
   9, 4, and 13 on e2, e3, and e6 respectively.
5. Recomputed P3 masks with canonical anchors held fixed. Topology differences
   fell to 3 pixels on e2, 0 on e3, and 11 on e6; maximum final delta fell to
   2, 1, and 2. Thus both one-byte color-score boundaries and, more strongly,
   Vision sensitivity contribute. Exact cross-profile topology is not a valid
   assumption.
6. Replaced only the outer border with transparent black. Composition preserved
   every alpha byte, transparent RGB pixel, and outside-mask pixel, but fresh
   Vision anchors moved by 0.77–4.89 px and changed strong-mask topology. With
   canonical anchors held fixed, all alpha-case mask topology differences were
   zero. The detector responds to canvas/background changes outside the face.
7. Added deterministic tests for all eight EXIF orientations, invalid
   orientation rejection, non-RGB rejection, and alpha preservation. Release
   build and all 23/23 harness self-tests pass. No-face still exits 1.

## Results

**Verdict: PARTIAL — canonical orientation, alpha containment, and fail-closed input mechanics pass; exact color-profile/detector topology invariance fails.**

| Fixture | EXIF input/output/topology mismatch | P3 input max Δ | P3 anchor Δ | P3 topology mismatch (fresh / fixed anchors) | P3 output max Δ (fresh / fixed) | Alpha anchor Δ | Alpha topology mismatch (fresh / fixed) | Alpha/outside changes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| e6 | 0 / 0 / 0 | 1 | 1.559 px | 76 / 11 | 13 / 2 | 4.886 px | 396 / 0 | 0 / 0 |
| e2 | 0 / 0 / 0 | 1 | 0.533 px | 8 / 3 | 9 / 2 | 1.362 px | 40 / 0 | 0 / 0 |
| e3 | 0 / 0 / 0 | 1 | 0.765 px | 15 / 0 | 4 / 1 | 0.771 px | 14 / 0 | 0 / 0 |

Every lossless EXIF rotation/mirror case is exact after normalization, including
Vision anchors and final output. Invalid orientation and non-RGB input fail
closed, while no-face behavior is unchanged. All P3 and alpha runs retain zero
changes outside their own union; alpha output is byte-preserved.

The strict cross-color requirement is not met. A one-byte color-managed input
difference can shift Vision landmarks and therefore mask edges even when the
images look identical. A transparent canvas can also influence detection
despite unchanged face pixels. Future implementation must normalize exactly
once before both Vision and rendering, but should specify bounded output/safety
invariants—not byte-identical masks across profiles. It must also decide whether
transparent inputs are composited against a declared background or rejected for
face-local effects. Those choices require production design and licensed real
fixture evaluation.

Peak RSS reached 1,088 MB on the e6 evidence run because the harness retains
multiple full-resolution orientation, P3, fixed-anchor, alpha, and oracle frames
at once. This is diagnostic harness cost, not a device budget. HDR/gain maps,
extended-range formats, optimized memory, target-device behavior, product
naturalness, and v1.14 remain unvalidated.
