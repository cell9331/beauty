# Teeth Whitening

## Requirements

- Separate teeth selection from the bounded color transform.
- Treat `innerLips` as high-confidence aperture support, not a complete teeth
  label; the tested broad smile placed visible side teeth outside that polygon.
- Closed mouth, missing seeds/landmarks, implausible mouth geometry or candidate
  area, occlusion, and no face fail closed.
- Keep lip polygons, teeth masks, candidate colors, tensors, and geometry
  request-local and out of public or persisted diagnostics.
- Do not vendor the tested EasyPortrait Core ML artifact unless the complete
  data/checkpoint/conversion/redistribution license chain is approved and pinned.
- Product validation requires rights-approved real smiles and original-detail
  blind review through `references/licensed-fixture-evaluation.md`.

## How to Build It

1. Define a private `TeethMaskProvider` that consumes a validated still-image
   request context and returns a request-local soft mask or a local no-op.
2. Run Vision once and capture both `innerLips` and `outerLips` in image
   coordinates. Missing either support set disables the adaptive provider.
3. Build the fixed safety baseline inside a non-feathered `innerLips` polygon:
   combine luminance, saturation neutrality, and blue-floor scores, then reject
   candidate ratios below 1.5% or above 94%.
4. Use accepted fixed-mask pixels above `0.15` as seeds. Never synthesize seeds
   merely to improve coverage.
5. Form the adaptive search envelope from the `outerLips` polygon, clipped to a
   narrow vertical extension of the inner aperture. Keep a small upper safety
   inset because the upper inner-lip edge is the safest available ceiling, and
   retain a 10% lower extension for lateral/occluded tooth coverage:

```swift
var region = try polygonMask(points: outerLips, featherRadius: 0)
let innerMinY = innerLips.map(\.y).min()!
let innerMaxY = innerLips.map(\.y).max()!
let apertureHeight = innerMaxY - innerMinY
let upperInset = max(1, apertureHeight * 0.05)
let lowerMargin = max(1, apertureHeight * 0.10)
for index in region.indices where region[index] > 0 {
    let y = Double(index / width) + 0.5
    if y < innerMinY + upperInset || y > innerMaxY + lowerMargin {
        region[index] = 0
    }
}
```

6. Derive local candidate limits from the mouth rather than one global shade:
   use an Otsu luminance split plus seed luminance/saturation percentiles, then
   gate red/green and red/blue imbalance. Treat all coefficients as spike seeds,
   not product constants.
7. Flood eight-connected candidates starting from the fixed seeds. Keep only
   connected pixels, feather locally, clip back to the narrow envelope, preserve
   every accepted fixed pixel with `max(adaptive, fixed)`, and enforce the same
   1.5%–94% plausibility range. Any failed invariant returns an empty mask.
8. Keep the approved/pinned learned segmenter as a comparator, not a hidden
   dependency. It must beat the adaptive path on licensed positives and
   negatives after containment, cold-start, memory, and license review.
9. Apply whitening only inside the accepted mask. Require a material yellow
   excess before changing a pixel, reduce that excess, add a small bounded
   luminance lift, and correct toward the desired luminance. Neutral and
   lightly warm already-light pixels are explicit no-op controls:

```swift
let originalLuminance = luminance(red, green, blue)
let yellowExcess = max(0, (red + green) * 0.5 - blue)
let yellowCorrection = smoothstep(0.08, 0.14, yellowExcess)
let local = mask[index] * strength * yellowCorrection
guard local > 0.001 else { return sourcePixel }
var nextRed = red + 0.018 * local
var nextGreen = green + 0.018 * local
var nextBlue = blue + yellowExcess * 1.05 * local
let desired = min(0.94, originalLuminance + 0.045 * local)
let correction = desired - luminance(nextRed, nextGreen, nextBlue)
nextRed += correction
nextGreen += correction
nextBlue += correction
```

These coefficients are mechanics calibration seeds after the authorized yellow
positive revealed that the prior transform was too subtle. They preserve the
explicit lightly warm no-op threshold and are not production constants.

10. Compare fixed and adaptive masks on the same input. Require zero dropped
    strong baseline pixels, zero outside-mask changes, closed-mouth/no-face
    failure, and human judgments for side-tooth coverage and protected tissue.
11. Evaluate wide/small smiles, darker side teeth, yellow/gray shades, lip,
    tongue, gum, braces, occlusion, facial hair, closed mouth, pose, blur,
    compression, skin tone, and lighting using rights-approved fixtures.

The adaptive mechanics run increased strong coverage from 4,711 to 7,396 pixels
on e6 (+57.0%) and from 462 to 805 on e2 (+74.2%), dropped zero fixed pixels,
changed zero pixels outside its mask, and stayed empty on e3/no-face. These are
AI-fixture mechanics results, not product coverage evidence.

## What to Avoid

- Do not treat the whole `innerLips` or `outerLips` polygon as teeth.
- Do not use Otsu or an adaptive threshold alone; it cannot distinguish lip,
  tongue, or gum from teeth.
- Do not repeat the rejected full-outer-lip growth path: it visibly selected an
  upper-lip strip before the vertical envelope was added.
- Do not relax fail-closed geometry/area gates merely to increase coverage.
- Do not globally desaturate or brighten the face or mouth.
- Do not load a Core ML model per request; the research candidate showed a
  1,680.6 ms cold load versus 21.4 ms warm load and 15.8 ms warm inference.
- Do not copy or redistribute `john-rocky/easyportrait-coreml`; its repository
  exposed no license during the audit and upstream uses a custom license PDF.
- Do not interpret two clean AI-generated smiles as demographic or product proof.

## Constraints

- Vision `innerLips` had six points and `outerLips` fourteen in the tested
  fixtures; both are coarse support, not tooth-level labels.
- The fixed path is `PARTIAL`: safe but incomplete. The adaptive path is also
  `PARTIAL`: it wins the mechanics comparison but lacks licensed protected-
  tissue and population review.
- The EasyPortrait mask remains `PARTIAL`: technically broader but license,
  conversion, cold-start, and resource blocked. The high-resolution cold run
  reached 197.8 MB peak RSS.
- The adaptive numeric thresholds are experimental calibration seeds.
- The color transform is reusable only behind a validated mask provider.

## Origin

Synthesized from spikes: 002a, 002b, 004, 009

Source files available in:
`sources/002a-teeth-vision-color/`, `sources/002b-teeth-coreml/`,
`sources/004-local-color-retouch/`, `sources/009-adaptive-teeth-mask/`, and
`sources/shared-retouch-lab/`.
