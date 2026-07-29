# Sclera Redness Reduction

## Requirements

- Require actual eye-contour and pupil support for each processed eye.
- Missing/inaccurate/blinking/closed/occluded support fails closed per eye.
- Protect iris, pupil, lashes, skin, and specular highlights.
- Keep eye geometry, pupil position, raw sclera masks, and vein-like structure
  request-local; diagnostics contain aggregates only.
- Product validation requires licensed real redness positives and negatives.

## How to Build It

1. Run Vision once for the still image and retain a private request-local face
   context.
2. Rasterize each observed eye contour into a soft aperture mask.
3. Require its pupil point. Estimate a conservative iris exclusion radius from
   both aperture height and width:

```swift
let eyeWidth = maxEyeX - minEyeX
let eyeHeight = maxEyeY - minEyeY
let irisRadius = max(eyeHeight * 0.58, eyeWidth * 0.16)
guard distance(pixelCenter, pupil) > irisRadius else { continue }
```

4. Reject near-white specular highlights rather than shifting them.
5. Inside the remaining aperture, combine a light/low-saturation sclera score
   with a bounded red-excess score:

```swift
let scleraLikelihood = smoothstep(0.22, 0.68, light)
    * (1 - smoothstep(0.48, 0.85, saturation))
let redness = max(0, red - 0.83 * green - 0.17 * blue)
let rednessScore = smoothstep(0.008, 0.14, redness)
mask[index] = aperture[index] * scleraLikelihood * rednessScore
```

6. Feather the accepted mask locally. Never expand beyond the eye aperture.
7. Reduce only the measured red excess, add a small compensating green/blue
   component, and restore original luminance:

```swift
let local = mask[index] * strength
let redExcess = max(0, red - (0.83 * green + 0.17 * blue))
var nextRed = red - redExcess * 0.76 * local
var nextGreen = green + redExcess * 0.08 * local
var nextBlue = blue + redExcess * 0.13 * local
let correction = originalLuminance - luminance(nextRed, nextGreen, nextBlue)
```

8. Validate each eye separately and compose only accepted masks. Measure
   protected-region leakage, luminance, texture, channel delta, mask coverage,
   and release/device cost.
9. Evaluate mild/severe redness, visible vessels, glasses, contacts, blink,
   partial closure, makeup, lashes, blue/brown irises, side pose, low light,
   highlights, blur, compression, and demographic/illumination diversity.

The spike reported zero outside-mask changes, texture-energy ratios of 0.99993
and 0.99955, and almost unchanged mean luminance on its two fixtures.

## What to Avoid

- Do not treat the whole eye aperture as sclera.
- Do not edit within the pupil-centered iris exclusion.
- Do not use global red-channel suppression or skin-based color normalization.
- Do not guess a pupil when Vision support is absent or unreliable.
- Do not log, cache, publish, or persist raw vessel-like masks or descriptors.
- Do not claim redness coverage from fixtures that contain only weak positives.

## Constraints

- Apple warns pupil landmarks may be inaccurate during a blink; fail closed.
- The mask/transform mechanics are `PARTIAL`: containment is proven, real
  positive coverage and naturalness are not.
- The 1728×2304 release transform took 65.3 ms after detection in the spike;
  this is macOS harness evidence, not an iOS device budget.
- Sclera vasculature may be identifying, so privacy treatment is stricter than
  ordinary transient color masks.

## Origin

Synthesized from spikes: 003, 004

Source files available in:
`sources/003-sclera-redness-mask/`, `sources/004-local-color-retouch/`, and
`sources/shared-retouch-lab/`.
