# Requirements: Beauty v1.22 Non-Local Facial Effect Repairs

Latest completed milestone: **v1.24 去脂效果改进**. Its frozen requirements and phase
sequence are in [V1.24-UPPER-EYELID-CURRENT.md](V1.24-UPPER-EYELID-CURRENT.md).
The v1.22 requirements below remain historical. v1.23 completed only its
generated-input mechanics scope; FACE-01 real-portrait effectiveness remains
FUTURE-04.

Current successor requirement: **FACE01-23** is the separately authorized
v1.23 `faceContourSmooth` repair and qualification in
[V1.23-FACE01-CURRENT.md](V1.23-FACE01-CURRENT.md). The candidate has passed
the unchanged generated oracle but has not passed a meaningful positive
portrait direction gate; its taxonomy remains `partial`. The v1.22
requirements and FUTURE-04 wording below describe the completed historical
scope and the source state at its closeout.

## Current evidence interpretation (2026-09-23)

v1.22 completed 2026-09-23: 7/7 phases, 33/33 plans, 11/11 active requirements; [verified COMPLETE](phases/95-compatibility-and-sdk-only-closeout/95-COMPLETE.json).
Actual portrait: 65/65 outputs, 2 reconciled runs, seven effective directions and one deferred/partial direction. Current safety 1/0/0, compatibility 4/0/0, archive-first full SwiftPM 937/0/0; all 8 opt-ins accounted for.
VAL-02/NOSE-02 use the reviewed rootSurfaceSpanQ16_v4 measurement and current actual-batch acceptance.
FACE-01/faceContourSmooth remains explicitly deferred/partial under FUTURE-04, without effectiveness credit. The repaired observed paired-eye root uses CPU; retained Metal rejects its unsupported private raster cutoff with typed invalidInput before submission and recovers for later supported requests. This is owner-local SDK validation, with no device, population, commercial quality, packaging, shipping, launch, release-readiness or distribution claim. No owner annotation or device action remains. Phase96 is absorbed into95-03, and no next milestone is started.

**Defined:** 2026-08-26

**Core Value:** The project owner can verify that every in-scope, owner-local
still-image facial control produces its documented semantic effect through the
public SDK facade, while preserving bounded, deterministic, fail-closed
behavior and protected image regions.

**Baseline Evidence:** The authorized portrait batch completed 65/65 renderer
outputs. After excluding the three owner-deferred local-retouch controls, eight
renderer directions remain weak or inert: `faceContourSmooth`, `chinTaper`,
`gazeCorrection`, both signs of `eyebrowHeadSpacing`, `noseBridge`,
`noseRootNarrowing`, and negative `mouthWidth`. On 2026-09-02 the owner narrowed
v1.22 to seven active repair directions and explicitly deferred
`faceContourSmooth`; its current public field and fail-closed implementation
remain unchanged and are not accepted as an effective repair.

## v1 Requirements

### Validation baseline

- [x] **VAL-01**: One SDK-owned command processes authorized owner-local
  portrait inputs through the live five-batch, 65-case renderer inventory,
  writes parameter-watermarked output images, and writes a machine-readable
  aggregate report that compares output with both source and neutral output
  while excluding watermark pixels from effect measurements.

- [x] **VAL-02**: Every in-scope repair direction has deterministic semantic
  ROI, polarity/locality, minimum-signal, and protected-region assertions
  derived from the documented effect contract; an arbitrary pixel difference
  or a threshold weakened only to make a case pass is not acceptance evidence.

### Face shape

- [x] **FACE-02**: Positive `chinTaper` produces a detectable,
  centerline-gated chin taper on eligible input, remains distinct from
  `chinLength`, `faceVShape`, and `jawSlim`, and preserves the established exact
  safety cap, neutral identity, and fail-closed behavior.

### Eyes

- [x] **EYE-01**: Positive `gazeCorrection` measurably reduces each supported
  pupil's displacement from its own eye center without borrowing support from
  the other eye, while preserving eye aperture, eye contour, eyebrows, and
  background; missing or implausible support fails closed per eye.

### Eyebrows

- [x] **BROW-01**: Positive and negative `eyebrowHeadSpacing` move only the two
  inner eyebrow heads in opposite documented directions, preserve the outer
  eyebrow anchors and non-brow protected regions, and remain semantically
  distinct from whole-brow `eyebrowSpacing`.

### Nose

- [x] **NOSE-01**: Positive `noseBridge` produces a detectable bridge-definition
  effect in the bridge semantic ROI on eligible input, remains independent from
  `noseRootNarrowing`, `noseSlim`, and tip controls, and preserves non-bridge
  protected regions within bounded tolerance.

- [x] **NOSE-02**: Positive `noseRootNarrowing` produces detectable narrowing in
  the root semantic ROI on eligible input, never aliases `noseBridge`, preserves
  bridge/tip/non-nose protected regions, and retains its exact safety cap and
  fail-closed support handling.

### Mouth

- [x] **MOUTH-01**: Negative `mouthWidth` measurably contracts mouth width in the
  expected direction on eligible input; the already-detected positive direction
  remains correct, both directions are distinct from whole-mouth `mouthSize`,
  and mouth height, surrounding face, and background remain protected.

### Compatibility and closeout

- [x] **SAFE-01**: Every repaired control has automated coverage for neutral
  identity, no-face and missing/malformed/stale semantic support, determinism,
  extent/orientation/color-space/alpha preservation, exact safety caps,
  protected regions, privacy-safe diagnostics, and recovery after rejected
  input; no control may use another control's semantic support as a proxy.

- [x] **COMPAT-01**: Repairs preserve the public `BeautyParameters` Codable and
  default contract, five presets, 62 parameter fields, 75 renderer cases,
  public still-image facade signatures, CPU/GPU backend contract, SDK-only
  target boundary, and existing non-target control behavior.

- [x] **CLOSE-01**: A clean authorized-portrait rerun completes all 65 outputs,
  marks the seven active repair directions effective against neutral through
  their semantic and protection gates, and reports `faceContourSmooth` as the
  one explicit deferred/partial direction without promoting it; focused tests,
  full SwiftPM tests, archive-first SDK-only checks, and the zero-skip closeout
  gate all pass, with changed behavior contracts synchronized to their owner
  documents.

## Future Requirements

- **FUTURE-01**: Repair or further optimize `teethWhitening`,
  `scleraRednessReduction`, and `upperEyelidFullnessReduction` only in a
  separately authorized local-retouch milestone with its model/license,
  privacy, fixture, and adversarial-safety gates.

- **FUTURE-02**: Expand portrait diversity, population calibration, subjective
  naturalness review, and owner-device feedback only as separately authorized
  evidence; these do not replace deterministic semantic pixel gates.

- **FUTURE-03**: Realtime/video, device performance, packaging, commercialization,
  release readiness, and external distribution remain separately scoped or
  prohibited under the current owner-local boundary.

- **FUTURE-04**: Repair or further redesign `faceContourSmooth` only in a
  separately authorized milestone. The current owner-local public field,
  compatibility shape, frozen `+16 Q16` semantic/protection contract, and
  fail-closed implementation remain unchanged; Phase 90 revision 22 is
  diagnostic evidence, not repair or effectiveness evidence.

## Out of Scope

| Feature | Reason |
| --- | --- |
| Repairing `teethWhitening` (white teeth) | Explicitly deferred by the owner. |
| Repairing `scleraRednessReduction` (sclera redness) | Explicitly deferred by the owner. |
| Repairing `upperEyelidFullnessReduction` (`去脂`) | Explicitly deferred by the owner; the v1.21 provisional behavior remains unchanged. |
| Further `faceContourSmooth` repair | Explicitly deferred by the owner after the bounded Phase 90 attempt series; the existing public field remains unchanged and `partial`. |
| New public parameters, presets, filters, renderer cases, or facade methods | v1.22 repairs the existing 62-field/5-preset/75-case contract only. |
| Counting the watermark or unrelated pixel changes as proof | Acceptance requires semantic ROI, direction, locality, and protected-region evidence. |
| Threshold-only changes that hide an inert or wrong-direction effect | Thresholds describe the contract; they cannot substitute for a functional repair. |
| New UI/Demo, application lifecycle, realtime/video pipeline, model, dataset, weights, or network path | The active product surface remains the owner-local SDK and SDK-owned still-image validation. |
| Hairline, double-chin, facial proportion, or 3D additions | These remain future taxonomy rows and are not repairs of the observed directions. |
| Device, commercial quality, packaging, shipping, launch, release, or external distribution claims | Automated owner-local evidence does not establish those claims. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| VAL-01 | Phase 89 | Complete |
| VAL-02 | Phase 89 | Complete |
| FACE-02 | Phase 90 | Complete |
| EYE-01 | Phase 91 | Complete |
| BROW-01 | Phase 92 | Complete |
| NOSE-01 | Phase 93 | Complete |
| NOSE-02 | Phase 93 | Complete |
| MOUTH-01 | Phase 94 | Complete — current41/41 and independent28/28 goal verification |
| SAFE-01 | Phase 95 | Complete — verified current COMPLETE |
| COMPAT-01 | Phase 95 | Complete — verified current COMPLETE |
| CLOSE-01 | Phase 95 | Complete — verified current COMPLETE |
| FUTURE-04 | Future milestone | Deferred |

**Coverage:** 11/11 active v1.22 requirements complete and mapped exactly once. Eight historical phase requirements retain their original evidence, with the changed source and successor root measurement revalidated by current Phase95 acceptance. SAFE-01, COMPAT-01 and CLOSE-01 are closed by the verified current receipt. FUTURE-04 preserves the explicitly deferred FACE-01 intent outside this milestone.

---
*Last updated: 2026-09-23 after verified v1.22 completion*

<!-- beauty-v122-complete-sha256: 33b49fee25b4156b8a947ac437822ac33f7e5473a61ed74b1015c393035862d4 -->
