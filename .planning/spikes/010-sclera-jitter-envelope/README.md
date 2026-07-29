---
spike: 010
name: sclera-jitter-envelope
type: standard
validates: "Given perturbed pupil and eye-contour support including blink-like collapse, when sclera masks are recomputed across a deterministic scenario grid, then iris/highlight leakage remains zero or the affected eye fails closed before leakage."
verdict: VALIDATED
related: [003, 004, 005, 006]
tags: [sclera, safety, perturbation, privacy]
---

# Spike 010: Sclera Jitter Envelope

## What This Validates

Tests the geometric safety boundary beneath sclera-redness selection when pupil
and eye-contour landmarks are imperfect. The study deliberately removes the
redness/color gate from the risk calculation so a dark iris cannot appear safe
merely because it has a low redness score.

The accepted guard has two parts: fail closed when the eye aperture is too
collapsed or the pupil leaves it, and inflate the pupil-centered iris exclusion
for accepted eyes before any color candidate is evaluated.

## Research

- Apple explicitly warns that [`leftPupil`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/leftpupil)
  may be inaccurate while the eye is blinking. Blink-like support must therefore
  fail closed rather than reuse or guess a pupil.
- [Eye Blink Detection Using Facial Landmarks](https://cmp.felk.cvut.cz/ftp/articles/cech/Soukupova-TR-2016-05.pdf)
  uses a height/width-derived eye aspect ratio to characterize openness. This
  spike uses a conservative bounding-height/width variant as a rejection gate,
  not the paper's temporal blink classifier.
- [CondSeg](https://arxiv.org/abs/2408.17231) models pupil/iris geometry with an
  ellipse prior and conditions visible iris support on eye openness. That
  supports separating geometric validity from downstream appearance scoring.
- [Robust Sclera Segmentation for Skin-tone Agnostic Face Image Quality Assessment](https://arxiv.org/abs/2312.15102)
  combines an eye hull with iris exclusion. Spike 003 adopted that foundation;
  this spike tests how the exclusion behaves when its landmarks move.

| Approach | Pros | Cons | Status |
| --- | --- | --- | --- |
| Evaluate the final redness mask only | Matches visible output | Dark iris/color rejection can hide geometric leakage | Rejected as a safety oracle |
| Existing pupil circle under perturbation | No extra coverage loss | Leaks into protected iris in 118/120 scenarios | Baseline only |
| 0.14-width inflation + 0.16 aspect gate | Preserves more perturbed eyes | Still leaked in 12/120 scenarios | Rejected |
| 0.14-width inflation + 0.30 aspect gate | Zero iris/highlight leakage across all three grids | Fails closed on 75% of stress scenarios and retains only 28.6%–32.2% of baseline geometric eligibility | **Chosen safety envelope** |

The numeric thresholds are spike parameters, not production constants. Their
purpose is to expose the safety/coverage tradeoff and a reproducible calibration
target for licensed real data.

## How to Run

```bash
swift build -c release --package-path .planning/spikes/retouch-lab

.planning/spikes/retouch-lab/.build/release/retouch-spike-lab \
  --mode sclera-jitter \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/010-sclera-jitter-envelope/artifacts/e6

open .planning/spikes/010-sclera-jitter-envelope/review.html
```

Repeat with `example-images/parked-portraits/e2.png` and `e3.png`. Each fixture
evaluates two eyes over 60 scenarios per eye: five horizontal pupil shifts,
three vertical pupil shifts, and four vertical eye-contour scales.

## What to Expect

- `legacy-leak-heatmap.png` shows orange/red risk over the protected iris.
- `guarded-leak-heatmap.png` is unchanged because its leak count is zero.
- `protected-overlay.png` shows the unperturbed iris protection reference in
  blue.
- Baseline overlays show the geometric sclera-eligible envelope before the
  redness gate; the guarded version is intentionally smaller.
- `comparison.json` contains aggregate grid counts only, never raw coordinates
  or per-scenario geometry.

## Observability

The event log allowlists face/eye/pupil support counts, total scenarios, leak
scenario counts, guarded fail-closed count, and duration. It excludes pupil
positions, contour points, per-scenario offsets, raw masks, heatmap values, and
vein-like descriptors. PNGs are explicit local disposable review artifacts.

## Investigation Trail

1. Defined protected iris truth from each unperturbed eye using Spike 003's
   existing `max(eyeHeight * 0.58, eyeWidth * 0.16)` exclusion. Input specular
   pixels form a separate protected mask.
2. Built a color-independent geometric envelope inside each perturbed eye
   aperture. This adversarial form asks what *could* be selected if color gates
   were permissive, rather than trusting the current fixture's iris color.
3. Swept pupil x by ±12% and ±6% of eye width, pupil y by ±8% of eye height,
   and eye-contour height through 100%, 70%, 40%, and 20%. The existing circle
   leaked in 118 of 120 eye-scenarios on every fixture.
4. Added a 14%-of-eye-width uncertainty margin plus a 0.16 aspect-ratio gate.
   This reduced but did not remove risk: 12 scenarios still leaked, so the
   candidate was rejected.
5. Raised the conservative aspect gate to 0.30. All 70%/40%/20% collapse
   scenarios now fail closed; accepted full-height scenarios use the inflated
   iris exclusion and report zero protected leakage.
6. Added deterministic self-tests proving that a shifted legacy envelope leaks,
   the guarded envelope does not, and blink-like collapse returns an empty mask.
   The shared harness now passes 13/13 tests.

## Results

**Verdict: VALIDATED — the deterministic safety envelope passes its bounded grid; product calibration remains open.**

| Fixture | Legacy iris-leak scenarios | Guarded iris-leak scenarios | Guarded fail-closed | Highlight leaks | Guarded baseline retention |
| --- | ---: | ---: | ---: | ---: | ---: |
| e6 | 118 / 120 | 0 / 120 | 90 / 120 | 0 | 32.2% |
| e2 | 118 / 120 | 0 / 120 | 90 / 120 | 0 | 29.6% |
| e3 | 118 / 120 | 0 / 120 | 90 / 120 | 0 | 28.6% |

The no-face input exits 1 with `No usable face landmarks were detected`.
Release build and all 13 harness self-tests pass. The result validates the
explicit perturbation/fail-closed invariant and shows that the unguarded Spike
003 geometry must not be promoted unchanged.

It does **not** validate the 0.30/0.14 thresholds for users. They are deliberately
conservative, sacrifice roughly 68%–71% of baseline geometric eligibility, and
were tested on AI-generated frontal portraits. Licensed real open/partial/blink,
gaze, glasses, contacts, iris-color, pose, demographic, and redness fixtures are
still required to calibrate the guard and prove useful coverage through Spike
006 before any product path is authorized.
