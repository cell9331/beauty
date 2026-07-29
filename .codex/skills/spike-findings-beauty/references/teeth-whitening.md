# Teeth Whitening

## Requirements

- Separate teeth selection from the color transform.
- `innerLips` is containment support, not a teeth label.
- Closed mouth, no candidate, implausible candidate area, missing landmarks,
  occlusion, or no face must fail closed.
- Keep lip polygons, teeth masks, tensors, and geometry request-local and out of
  public/persisted diagnostics.
- Do not vendor the tested EasyPortrait Core ML artifact unless the complete
  data/checkpoint/conversion/redistribution license chain is approved and pinned.
- Product validation requires licensed real smiles and original-detail review.

## How to Build It

1. Define a private `TeethMaskProvider` boundary that consumes a still-image
   request context and returns a request-local soft mask or a local no-op.
2. Run Vision once and convert actual `innerLips` points to image coordinates.
3. Use the inner-lip polygon as a hard containment envelope.
4. Keep the deterministic mask as a fallback and executable safety baseline:
   combine luminance, saturation neutrality, and blue-floor scores, then reject
   candidate ratios below 1.5% or above 94% of the inner-lip region.
5. For product coverage, supply an owned or explicitly commercial-licensed
   teeth segmenter. Pin its input size, orientation/crop contract, output name,
   thresholding, feathering, model hash, provenance, and lifecycle ownership.
6. Intersect every learned mask with mouth containment and validate lip, tongue,
   gum, braces, and skin leakage before transformation.
7. Apply whitening only inside the accepted mask. Reduce yellow excess, make a
   small bounded luminance lift, then correct back toward the desired luminance:

```swift
let local = mask[index] * strength
let originalLuminance = luminance(red, green, blue)
let yellowExcess = max(0, (red + green) * 0.5 - blue)
var nextRed = red + 0.018 * local
var nextGreen = green + 0.018 * local
var nextBlue = blue + yellowExcess * 0.78 * local + 0.026 * local
let desired = min(0.94, originalLuminance + 0.028 * local)
let correction = desired - luminance(nextRed, nextGreen, nextBlue)
nextRed += correction
nextGreen += correction
nextBlue += correction
```

8. Measure mask coverage, `changedOutsideMask`, maximum channel delta, mean
   luminance delta, texture energy, Vision/model timings, cold start, and peak
   RSS in release on target devices.
9. Build a licensed evaluation matrix covering wide and small smiles, darker
   side teeth, yellow/gray tooth shades, lips, tongue, gums, braces, occlusion,
   facial hair, closed mouths, pose, blur, compression, skin tone, and lighting.

The deterministic spike changed zero protected pixels and failed closed for a
closed mouth/no face, but captured only 6,099 mask pixels on the broad smile.
The learned candidate captured 9,572 and visibly improved side-tooth coverage.

## What to Avoid

- Do not treat the whole `innerLips` polygon as teeth.
- Do not globally desaturate or brighten the face or mouth.
- Do not relax the fail-closed gates merely to increase coverage.
- Do not load a Core ML model per request; the research candidate showed a
  1,680.6 ms cold load versus 21.4 ms warm load and 15.8 ms warm inference.
- Do not copy or redistribute `john-rocky/easyportrait-coreml`; the repository
  exposed no license during the audit and upstream uses a custom license PDF.
- Do not interpret a clean AI-generated smile as demographic or product proof.

## Constraints

- Vision `innerLips` has six points in the tested fixtures and supplies coarse
  containment, not tooth-level boundaries.
- The deterministic mask is `PARTIAL`: safe but incomplete.
- The tested Core ML mask is `PARTIAL`: technically better but license and
  cold-start/resource blocked. The high-resolution cold run reached 197.8 MB
  peak RSS.
- `model-audit.txt` pins the research commit and hashes without copying weights.
- The color transform is reusable only behind a validated mask provider.

## Origin

Synthesized from spikes: 002a, 002b, 004

Source files available in:
`sources/002a-teeth-vision-color/`, `sources/002b-teeth-coreml/`,
`sources/004-local-color-retouch/`, and `sources/shared-retouch-lab/`.
