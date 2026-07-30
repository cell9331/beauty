---
spike: 011
name: guarded-sclera-color-integration
type: standard
validates: "Given Spike 010's per-eye guard and Spike 003/004 redness scoring and transform, when native and color-adversarial eye candidates are recomputed across the deterministic perturbation grid, then the final feathered mask and transform change zero protected iris/highlight pixels, fail closed per affected eye, and retain measurable redness candidates on accepted open eyes."
verdict: VALIDATED
related: [003, 004, 005, 006, 010]
tags: [sclera, integration, color, safety, privacy]
---

# Spike 011: Guarded Sclera Color Integration

## What This Validates

Integrates Spike 010's per-eye landmark guard with Spike 003's redness score and
Spike 004's bounded color transform. Unlike the geometry-only oracle, this
study measures the final byte-level output after feathering and color
correction. It verifies that an invalid eye becomes an empty local mask without
disabling an accepted peer eye.

The study runs both the native fixture and a request-local adversarial copy in
which protected non-highlight iris pixels are changed to a sclera-like red.
That second input prevents dark iris color from making unsafe geometry appear
safe. The adversarial image, masks, and heatmaps remain disposable local review
artifacts; tracked evidence contains aggregate counts only.

## Research

- Apple states that [`VNFaceLandmarks2D.leftPupil`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/leftpupil)
  may be inaccurate while an eye is blinking, so support rejection must happen
  independently per eye before color selection.
- [Eye Blink Detection Using Facial Landmarks](https://cmp.felk.cvut.cz/ftp/articles/cech/Soukupova-TR-2016-05.pdf)
  derives eye openness from landmark geometry. This spike keeps Spike 010's
  conservative aspect-ratio rejection gate rather than treating a collapsed
  aperture as valid color support.
- [CondSeg](https://arxiv.org/abs/2408.17231) separates full pupil/iris geometry
  from its visible support and conditions visibility on eye openness and gaze.
  This supports validating geometry before appearance scoring.
- [Robust Sclera Segmentation for Skin-tone Agnostic Face Image Quality Assessment](https://arxiv.org/abs/2312.15102)
  combines an eye-region boundary with iris exclusion and reports sensitivity
  to illumination. This spike therefore retains a local light/saturation score
  inside a hard anatomical boundary rather than using face-wide normalization.

| Approach | Benefit | Risk | Decision |
| --- | --- | --- | --- |
| Score and feather the legacy pupil circle | Exact Spike 003 behavior | Native dark irises conceal risk; adversarial input changes protected iris in 356/360 scenarios | Baseline only |
| Apply the guarded envelope only after feathering | Simple final intersection | Color work is computed outside trusted support and per-eye failure ownership is unclear | Rejected |
| Guard before scoring, feather, then re-clip to the same hard envelope | Color never sees rejected support; feather cannot expand back into iris/aperture/highlights; local failure remains explicit | Conservative coverage follows Spike 010's provisional thresholds | **Chosen** |
| Soft uncertainty weighting without a hard re-clip | Potentially higher coverage | Cannot establish the required zero-change invariant | Deferred to calibrated real-data work |

The `0.30` aspect ratio and `0.14 × eyeWidth` inflation remain deterministic
stress-test seeds, not production values.

## How to Run

```bash
swift build -c release \
  --package-path .planning/spikes/retouch-lab \
  --scratch-path /tmp/beauty-spike-011-build

/tmp/beauty-spike-011-build/release/retouch-spike-lab \
  --mode sclera-guarded-color \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/011-guarded-sclera-color-integration/artifacts/e6

open .planning/spikes/011-guarded-sclera-color-integration/review.html
```

Repeat with `example-images/parked-portraits/e2.png` and `e3.png`. Each fixture
tests two eyes over 60 scenarios per eye: five pupil-x shifts, three pupil-y
shifts, and four vertical eye-contour scales. Run `--mode self-test` for the
synthetic containment and per-eye failure checks.

## What to Expect

- `legacy-overlay.png` and `guarded-overlay.png` compare native candidate masks.
- `legacy-after.png` and `guarded-after.png` show the baseline bounded transform.
- `legacy-challenge-leak-heatmap.png` highlights final changed pixels inside
  protected iris/highlight truth; its guarded peer should be unchanged.
- `protected-overlay.png` and `highlight-overlay.png` show the two independent
  protection references.
- `comparison.json` records only aggregate scenario, mask, transform, leak, and
  fail-closed counts. It contains no coordinates or per-scenario geometry.

## Observability

Tracked events allow only the mode; face/eye/pupil counts; total scenario count;
legacy/guarded challenge-leak scenario counts; guarded failure count; guarded
baseline candidate count; and duration. Raw contours, pupil positions, masks,
challenge pixels, heatmap values, and vessel-like descriptors are not emitted.

## Investigation Trail

1. Reproduced Spike 003 per eye: a feathered eye aperture, pupil-centered iris
   circle, highlight rejection, sclera/redness score, then a second one-pixel
   feather. This is the legacy comparison, including its lack of final clipping.
2. Integrated Spike 010's hard per-eye envelope before color scoring. A missing
   pupil, collapsed aperture, low aspect ratio, or pupil outside the aperture
   returns an empty mask only for that eye.
3. Re-clipped the one-pixel feather to the same hard envelope. The shared color
   transform and byte rounding are used by both rendering and the grid assessor,
   so reported leaks measure final output changes rather than mask theory.
4. Added a color-adversarial copy of the unperturbed iris. On native e2/e3 the
   legacy color gate reported no protected changes, yet the adversarial run
   exposed legacy changes in 118–119 of 120 scenarios. Native-only review would
   therefore have produced a false sense of safety.
5. Kept baseline native masks and final outputs for both candidates. The guarded
   path retains nonzero changed candidates for both eyes on all three fixtures,
   while preserving zero `changedOutsideMask`.
6. Replaced an initially over-broad evaluator that recomputed texture metrics
   per scenario with an exact linear byte-transform assessor. This changes only
   evaluation cost; the rendered transform is shared and self-tested.
7. Added self-tests for adversarial legacy leakage, zero guarded final leakage,
   post-feather containment, blink-like empty masks, and independence of an open
   eye from a collapsed peer. Release self-tests pass 16/16.

## Results

**Verdict: VALIDATED — guarded mask/color integration passes the deterministic mechanics grid; user calibration and product coverage remain open.**

| Fixture | Legacy challenge iris-change scenarios | Guarded native/challenge iris changes | Guarded highlight changes | Guarded fail-closed | Guarded baseline native candidates | Retention vs legacy |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| e6 | 119 / 120 | 0 / 120 + 0 / 120 | 0 | 90 / 120 | 1,868 (901 + 967) | 38.2% |
| e2 | 118 / 120 | 0 / 120 + 0 / 120 | 0 | 90 / 120 | 223 (105 + 118) | 24.6% |
| e3 | 119 / 120 | 0 / 120 + 0 / 120 | 0 | 90 / 120 | 144 (56 + 88) | 28.8% |

Across all three fixtures, the final guarded transform changes zero protected
iris pixels and zero highlight pixels over 360 native plus 360 adversarial
eye-scenarios. The legacy adversarial path changes protected iris pixels in
356/360 scenarios; e6 also exposes 9/120 native legacy leak scenarios. All
guarded baseline outputs have nonzero candidates and changes for each eye, with
zero changes outside their masks. The no-face input exits 1 with
`No usable face landmarks were detected`.

This is a narrow integration result, not product feasibility. The conservative
guard still fails closed in 270/360 stress scenarios and retains only
24.6%–38.2% of the legacy baseline color mask on AI-generated fixtures.
Rights-approved real positive/negative cases and original-detail review remain
mandatory to calibrate openness/uncertainty, measure redness coverage and
naturalness, and decide whether the useful operating point exists. No v1.14,
production source, public API, or realtime path is authorized by this verdict.
