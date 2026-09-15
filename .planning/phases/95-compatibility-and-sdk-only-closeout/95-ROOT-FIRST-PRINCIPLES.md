# Phase 95 root repair: first-principles reassessment

Date: 2026-09-15. Status: generated-only investigation; no portrait acceptance.

## What we need to observe

Root narrowing means corresponding structures on opposite sides of the root
move closer in the actual output, while eyes/bridge/protected pixels remain
unchanged. Anatomical support, material correspondence and acceptable change
are three different questions. A dark centroid is not a structural width; a
strongest gradient is not an anatomical label; an intended displacement field
is not independent evidence that output pixels moved correctly.

## New executable counterexamples

`python3 scripts/phase95-root-identifiability-probe.py --self-test` composes the
exact SHA-pinned frozen draft2 metric with generated-only tests in memory.
No portrait, renderer/provider code, original registration or acceptance rules
are changed. The following are reproducible synthetic results, not estimates
of the actual portrait's displacement:

- A 512-pixel-wide generated stripe contracts by exactly four pixels (two per
  side): true width reduction 512 Q16, above the unchanged 16 Q16 threshold.
  The frozen conservative metric returns -594 Q16. All 32 edge observations
  still admit a zero-motion explanation under the allowed blur envelope.
- Adding a distant 30-level transition beside a 40-level target transition
  makes automatic registration reject. This proves gradient dominance is not
  necessary for correspondence of a known structure. It does NOT prove that
  the real portrait's anatomical boundaries are known or measurable.
- A minimal normalized area-correlation experiment recovers both integer
  motions in 18 generated contraction/identity/expansion × gain × offset
  cases, even with the competing transition. Flat, periodic and ramp inputs
  reject (three negative controls). Anchors are generator-known; this is NOT
  an anatomical registrar, subpixel estimator or calibrated confidence bound.

The old 346-check suite used an approximately 20-pixel width reduction for its
primary positive, while exact threshold tests supplied already-known intervals.
Those checks did not demonstrate end-to-end sensitivity near the 16 Q16 floor.
Passing them and independently reviewing implementation correctness did not
establish that the chosen nuisance model had adequate measurement power.

## Why more amplitude or manual edge selection is not the first fix

The frozen nuisance class permits any nonnegative blur supported on [-2,2],
including a point mass at a nonzero offset. Such a kernel is itself a shift.
For C(x)=P(x-d), a zero-motion explanation with kernel offset -d is allowed
whenever |d|<=2. Spatially varying kernels can explain opposite shifts at the
two edges. This is identifiability loss under the declared model, not floating
point malfunction. No estimator can distinguish these explanations from the
same samples without a justified additional assumption or observation.

Consequently, manually selecting an edge would at most address anatomical
registration; it would not repair the demonstrated loss of motion sensitivity.
Do not request manual marking as though it guarantees a fix. Do not narrow
the nuisance class merely because this source or candidate failed.

## Relevant primary implementations and literature

- OpenCV's [tracking and ECC documentation](https://docs.opencv.org/4.13.0/dc/d6b/group__video__track.html)
  separates image-area alignment from point tracking. ECC normalizes additive
  and positive multiplicative intensity changes; tracking reports invalid
  features and supports minimum-eigenvalue filtering. Optimization can fail
  or depend on initialization. An optimum correlation is not a certified bound.
- Baker and Matthews, [Lucas–Kanade 20 Years On](https://doi.org/10.1023/B:VISI.0000011205.11775.fd),
  IJCV 2004: image alignment framework. Publisher abstract/search metadata
  consulted; full paper could not be retrieved in this session, so no specific
  theorem or implementation detail is attributed to unread full text.
- Google's [Face Landmarker guide](https://developers.google.com/edge/mediapipe/solutions/vision/face_landmarker)
  supplies facial landmarks and optional transformation matrices for effects.
  This is an example of separating geometry from rendering, not proof of a
  nose-root width oracle. No MediaPipe model/dependency is introduced here.

Inference for this SDK: investigate anatomy-anchored local correspondence and
an explicitly validated image-formation model, not global strongest-edge tests
or a new uncalibrated landmark detector on every edited output.

## Bounded repair route

1. Establish actual sampling/quantization uncertainty from the existing CPU
   path independently of the candidate field. Separate photometric nuisance
   from geometric motion. Preserve arbitrary-blur attacks as rejection tests;
   do not silently reclassify those images as accepted geometric measurements.
2. Build a generated-only successor around source-frozen anatomical support
   and local material correspondence. Keep candidate/provider displacement
   out of expected-value calculation and source anchor selection. Validate
   subpixel contraction/expansion, identity, translation, brightness, contrast,
   symmetric/asymmetric blur, periodic/flat/ramp texture and protected leakage.
   Measure power near the unchanged Q16 threshold across image sizes, rather
   than using only large positives or point-interval arithmetic.
3. Independently review the new mathematical claim and executable adversaries
   before freezing it. The current minimal integer probe is insufficient for
   that approval. Retain frozen draft2/history and use a versioned successor.
4. Only after generic validation, register the same authorized source twice,
   without observing outputs. If still unidentifiable, report that specific
   limitation rather than manufacture confidence, tune to candidate outputs,
   or assume owner-confirmed anatomy. No new registration has happened yet.
5. Then run the complete seven-active/one-deferred actual-pixel comparison,
   current independent repair/security review, full no-skip and goal closeout.

No production amplitude, ROI, threshold, fixture, backend, public API or
completion status changed during this investigation. Prior 914/0/0 regression
remains historical regression evidence, not validation of this new probe or
completion of Phase95. This document corrects the earlier assumption that
owner-confirmed boundary registration was the only useful next action.
