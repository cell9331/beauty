# Sclera Redness Reduction

## Requirements

- Require actual eye-contour and pupil support for each processed eye.
- Missing, inaccurate, blinking, closed, collapsed, occluded, or pupil-outside-
  aperture support fails closed per eye.
- Protect iris, pupil, lashes, skin, and specular highlights before evaluating
  color; never rely on a dark iris failing the redness gate as safety proof.
- Keep eye geometry, pupil position, raw sclera masks, perturbations, heatmaps,
  and vein-like structure request-local; diagnostics contain aggregates only.
- Product validation and guard calibration require rights-approved real redness
  positives/negatives and original-detail review through
  `references/licensed-fixture-evaluation.md`.

## How to Build It

1. Run Vision once for the still image and retain a private request-local face
   context. Validate the left and right eyes independently.
2. Rasterize each observed eye contour into an aperture mask and require its
   pupil. Reject malformed or collapsed geometry rather than guessing support.
3. Treat the original pupil-centered formula as a baseline, not a sufficient
   production safety boundary:

```swift
let eyeWidth = maxEyeX - minEyeX
let eyeHeight = maxEyeY - minEyeY
let baselineRadius = max(eyeHeight * 0.58, eyeWidth * 0.16)
```

4. Before any color score, apply a per-eye landmark guard. The proven mechanism
   checks aperture aspect ratio and pupil containment, then inflates the iris
   exclusion for accepted eyes:

```swift
guard eye.count >= 4, eyeWidth >= 2, eyeHeight > 0 else { return emptyMask }
guard eyeHeight / eyeWidth >= calibratedMinimumAspectRatio,
      pointInPolygon(pupil, polygon: eye)
else { return emptyMask }

let irisRadius = max(eyeHeight * 0.58, eyeWidth * 0.16)
    + eyeWidth * calibratedUncertaintyFraction
guard distance(pixelCenter, pupil) > irisRadius else { continue }
```

5. Do not copy the experimental `0.30` aspect and `0.14` width values into
   production. Calibrate them on licensed open/partial/blink and gaze data while
   preserving zero protected leakage and measuring useful sclera retention.
6. Reject near-white specular highlights before redness scoring.
7. Inside the accepted geometric envelope, combine a light/low-saturation
   sclera score with a bounded red-excess score:

```swift
let scleraLikelihood = smoothstep(0.22, 0.68, light)
    * (1 - smoothstep(0.48, 0.85, saturation))
let redness = max(0, red - 0.83 * green - 0.17 * blue)
let rednessScore = smoothstep(0.008, 0.14, redness)
mask[index] = aperture[index] * scleraLikelihood * rednessScore
```

8. Feather locally, then intersect the result with the same hard envelope again.
   A pre-filter intersection is insufficient because blur can expand nonzero
   weights back into the iris, aperture exterior, or excluded highlights:

```swift
let feathered = boxBlur(scoredMask, width: width, height: height, radius: 1)
let finalMask = zip(feathered, hardEnvelope).map { clamp($0 * $1) }
```

   Compose only accepted per-eye masks. One eye returning an empty mask must not
   disable or reuse support for its accepted peer.
9. Reduce only measured red excess, add a small compensating green/blue
   component, and restore original luminance:

```swift
let local = mask[index] * strength
let redExcess = max(0, red - (0.83 * green + 0.17 * blue))
var nextRed = red - redExcess * 0.76 * local
var nextGreen = green + redExcess * 0.08 * local
var nextBlue = blue + redExcess * 0.13 * local
let correction = originalLuminance - luminance(nextRed, nextGreen, nextBlue)
```

10. Add a color-independent geometric safety oracle. Build an eligibility
    envelope with the redness gate deliberately open, perturb pupil/contour
    support, and compare every candidate against an unperturbed protected iris
    plus input-derived highlight mask. The downstream color gate must never be
    allowed to hide geometric leakage.
11. Add a second, final-output oracle. Recolor only request-local protected
    non-highlight iris pixels to a sclera-like red, recompute the actual mask and
    bounded transform, and count byte-level changes inside the unperturbed
    protected iris/highlight truth. This proves that score, feather, final clip,
    and transform remain safe together instead of trusting a dark native iris.
12. Sweep horizontal/vertical pupil uncertainty and eye-height collapse. Record
    aggregate scenario count, protected-leak scenarios/pixels, fail-closed
    count, baseline eligibility, final changed pixels, and retention; persist no
    coordinates or adversarial pixels.
13. Evaluate mild/severe redness, vessels, glasses, contacts, blink, partial
    closure, gaze, makeup, lashes, blue/brown irises, pose, low light,
    highlights, blur, compression, and demographic/illumination diversity.

The bounded grid showed why the guard is mandatory: the unguarded geometric
envelope entered the protected iris in 118/120 scenarios on each of e6/e2/e3.
The experimental guard produced zero iris/highlight leaks across 360 combined
scenarios, but failed closed in 270 and retained only 28.6%–32.2% of baseline
geometric eligibility. This validates the safety mechanism while leaving user
calibration and useful coverage open.

The final integration grid confirmed why both oracles are necessary. On native
e2/e3, the legacy color gate showed no protected changes, but coloring the
protected iris red exposed final legacy-transform leakage in 356/360 combined
eye-scenarios. Guard-before-score plus post-feather re-clipping changed zero
protected iris/highlight pixels across 360 native and 360 adversarial scenarios,
kept nonzero candidates in both eyes on all three mechanics fixtures, and kept
`changedOutsideMask == 0`. It still failed closed in 270/360 stress scenarios
and retained only 24.6%–38.2% of the legacy baseline color mask.

## What to Avoid

- Do not promote the original pupil circle unchanged; its clean static-fixture
  appearance did not survive landmark perturbation.
- Do not evaluate only the native final redness mask as a safety oracle. Dark
  iris pixels can conceal unsafe geometry by receiving a low redness score; use
  both the color-independent envelope and the adversarial final-output oracle.
- Do not blur a guarded score and composite it directly. Re-clip after every
  feather/blur operation that can expand support beyond a hard anatomical mask.
- Do not treat the whole eye aperture as sclera or edit inside the guarded iris
  exclusion.
- Do not guess, reuse, or carry forward a pupil when support is absent or the
  eye is blinking/collapsed.
- Do not hardcode the spike's `0.30 / 0.14` guard as a user threshold.
- Do not use global red-channel suppression or skin-based normalization.
- Do not log, cache, publish, or persist vessel-like masks or descriptors.
- Do not claim redness coverage from weak-positive or AI-generated fixtures.

## Constraints

- Apple warns pupil landmarks may be inaccurate during a blink; failure must be
  local to the affected eye.
- Guarded mask/color ordering is narrowly `VALIDATED` for the deterministic
  final-output grid; real redness coverage and naturalness remain unproven.
- The deterministic jitter envelope is narrowly `VALIDATED` for its bounded
  grid, not for population thresholds, useful coverage, or product readiness.
- The 1728×2304 release transform took 65.3 ms after detection in the original
  harness; this is macOS evidence, not an iOS device budget.
- Sclera vasculature may be identifying, so privacy treatment is stricter than
  ordinary transient color masks.

## Origin

Synthesized from spikes: 003, 004, 010, 011

Source files available in:
`sources/003-sclera-redness-mask/`, `sources/004-local-color-retouch/`,
`sources/010-sclera-jitter-envelope/`,
`sources/011-guarded-sclera-color-integration/`, and
`sources/shared-retouch-lab/`.
