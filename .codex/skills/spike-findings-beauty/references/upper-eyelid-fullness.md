# Upper-Eyelid Fullness

## Requirements

- Treat `去脂` as upper-eyelid fullness reduction only.
- Never implement it by forwarding to `eyeHeight`, `upperEyelidLift`, brow
  movement, eye opening, global smoothing, eye-bag removal, or dark-circle
  removal.
- Keep work on still images and fail closed when paired eye/eyebrow support is
  missing or the band is implausible.
- Do not promote this feature until licensed real positive and negative
  portraits pass human review at 100% detail.

## How to Build It

There is no production-ready `去脂` path yet. If the direction is explicitly
reopened, resume from the constrained tone/frequency experiment rather than
inventing a product feature from the invalidated warp.

1. Run one `VNDetectFaceLandmarksRequest` for the still image.
2. Require at least four eye points and two eyebrow points per side.
3. Form a support band strictly between the observed eye top and eyebrow
   bottom. Reject a non-positive or very small gap.
4. Feather horizontally and vertically so mask weight reaches zero at every
   boundary.
5. Estimate low-frequency luminance inside the band, move it toward the
   weighted regional mean, and add the original high-frequency detail back.
6. Preserve RGB geometry exactly. Measure texture-energy ratio, luminance
   delta, maximum channel delta, and `changedOutsideMask`.
7. Evaluate on licensed positives showing genuine upper-eyelid fullness and
   negatives spanning eyelid crease types, makeup, blink, glasses, side pose,
   expression, skin tone, and lighting. Require masked before/after human review.

The tested support-band construction was:

```swift
let eyeTop = eye.map(\.y).min()!
let eyeHeight = eye.map(\.y).max()! - eyeTop
let browBottom = brow.map(\.y).max()!
let gap = eyeTop - browBottom
guard gap > max(2, eyeHeight * 0.15) else { failClosed() }

let band = Band(
    centerX: (eyeMinX + eyeMaxX) / 2,
    radiusX: (eyeMaxX - eyeMinX) * 0.68,
    top: browBottom + gap * 0.20,
    bottom: eyeTop - gap * 0.05
)
```

Treat these coefficients as spike seeds, not public constants. The experiment
retained texture-energy ratios of 0.9996 and 0.9866 with zero mask leakage, but
the fixtures did not prove the intended product semantic.

## What to Avoid

- Do not ship the tested interior vertical warp. It reduced texture-energy ratio
  to 0.9305 and 0.9188 without a clearer fullness benefit.
- Do not interpret eye/eyebrow landmarks as a fullness detector or diagnosis.
- Do not use global smoothing or erase eyelid creases and natural skin detail.
- Do not infer success from AI-generated portraits without a true positive.
- Do not expose the experimental band, landmarks, or masks in diagnostics.

## Constraints

- Apple Vision has eye and eyebrow geometry, not an upper-eyelid-fullness
  semantic or a target surface.
- Current findings cover still images only and authorize no SDK parameter.
- The tone/frequency approach is `PARTIAL`; the tested warp is `INVALIDATED`.
- A future learned path needs an owned or explicitly licensed dataset/model and
  must demonstrate identity preservation, demographic robustness, naturalness,
  cold-start cost, and device resource bounds.

## Origin

Synthesized from spikes: 001a, 001b

Source files available in:
`sources/001a-upper-lid-tone/`, `sources/001b-upper-lid-warp/`, and
`sources/shared-retouch-lab/`.
