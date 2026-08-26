# Requirements: Beauty v1.22 Non-Local Facial Effect Repairs

**Defined:** 2026-08-26

**Core Value:** The project owner can verify that every in-scope, owner-local
still-image facial control produces its documented semantic effect through the
public SDK facade, while preserving bounded, deterministic, fail-closed
behavior and protected image regions.

**Baseline Evidence:** The authorized portrait batch completed 65/65 renderer
outputs. After excluding the three owner-deferred local-retouch controls, eight
renderer directions remain weak or inert: `faceContourSmooth`, `chinTaper`,
`gazeCorrection`, both signs of `eyebrowHeadSpacing`, `noseBridge`,
`noseRootNarrowing`, and negative `mouthWidth`.

## v1 Requirements

### Validation baseline

- [ ] **VAL-01**: One SDK-owned command processes authorized owner-local
  portrait inputs through the live five-batch, 65-case renderer inventory,
  writes parameter-watermarked output images, and writes a machine-readable
  aggregate report that compares output with both source and neutral output
  while excluding watermark pixels from effect measurements.
- [ ] **VAL-02**: Every in-scope repair direction has deterministic semantic
  ROI, polarity/locality, minimum-signal, and protected-region assertions
  derived from the documented effect contract; an arbitrary pixel difference
  or a threshold weakened only to make a case pass is not acceptance evidence.

### Face shape

- [ ] **FACE-01**: Positive `faceContourSmooth` produces a detectable,
  contour-local continuity correction on eligible observed contours, remains
  semantically distinct from `faceSlim`, `faceSmall`, `faceVShape`, and
  `jawSlim`, and keeps the eyes, nose, mouth, and background within bounded
  protected-region tolerances.
- [ ] **FACE-02**: Positive `chinTaper` produces a detectable,
  centerline-gated chin taper on eligible input, remains distinct from
  `chinLength`, `faceVShape`, and `jawSlim`, and preserves the established exact
  safety cap, neutral identity, and fail-closed behavior.

### Eyes

- [ ] **EYE-01**: Positive `gazeCorrection` measurably reduces each supported
  pupil's displacement from its own eye center without borrowing support from
  the other eye, while preserving eye aperture, eye contour, eyebrows, and
  background; missing or implausible support fails closed per eye.

### Eyebrows

- [ ] **BROW-01**: Positive and negative `eyebrowHeadSpacing` move only the two
  inner eyebrow heads in opposite documented directions, preserve the outer
  eyebrow anchors and non-brow protected regions, and remain semantically
  distinct from whole-brow `eyebrowSpacing`.

### Nose

- [ ] **NOSE-01**: Positive `noseBridge` produces a detectable bridge-definition
  effect in the bridge semantic ROI on eligible input, remains independent from
  `noseRootNarrowing`, `noseSlim`, and tip controls, and preserves non-bridge
  protected regions within bounded tolerance.
- [ ] **NOSE-02**: Positive `noseRootNarrowing` produces detectable narrowing in
  the root semantic ROI on eligible input, never aliases `noseBridge`, preserves
  bridge/tip/non-nose protected regions, and retains its exact safety cap and
  fail-closed support handling.

### Mouth

- [ ] **MOUTH-01**: Negative `mouthWidth` measurably contracts mouth width in the
  expected direction on eligible input; the already-detected positive direction
  remains correct, both directions are distinct from whole-mouth `mouthSize`,
  and mouth height, surrounding face, and background remain protected.

### Compatibility and closeout

- [ ] **SAFE-01**: Every repaired control has automated coverage for neutral
  identity, no-face and missing/malformed/stale semantic support, determinism,
  extent/orientation/color-space/alpha preservation, exact safety caps,
  protected regions, privacy-safe diagnostics, and recovery after rejected
  input; no control may use another control's semantic support as a proxy.
- [ ] **COMPAT-01**: Repairs preserve the public `BeautyParameters` Codable and
  default contract, five presets, 62 parameter fields, 75 renderer cases,
  public still-image facade signatures, CPU/GPU backend contract, SDK-only
  target boundary, and existing non-target control behavior.
- [ ] **CLOSE-01**: A clean authorized-portrait rerun completes all 65 outputs
  and marks all eight in-scope directions effective against neutral through
  their semantic and protection gates; focused tests, full SwiftPM tests,
  archive-first SDK-only checks, and the zero-skip closeout gate all pass, with
  changed behavior contracts synchronized to their owner documents.

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

## Out of Scope

| Feature | Reason |
| --- | --- |
| Repairing `teethWhitening` (white teeth) | Explicitly deferred by the owner. |
| Repairing `scleraRednessReduction` (sclera redness) | Explicitly deferred by the owner. |
| Repairing `upperEyelidFullnessReduction` (`去脂`) | Explicitly deferred by the owner; the v1.21 provisional behavior remains unchanged. |
| New public parameters, presets, filters, renderer cases, or facade methods | v1.22 repairs the existing 62-field/5-preset/75-case contract only. |
| Counting the watermark or unrelated pixel changes as proof | Acceptance requires semantic ROI, direction, locality, and protected-region evidence. |
| Threshold-only changes that hide an inert or wrong-direction effect | Thresholds describe the contract; they cannot substitute for a functional repair. |
| New UI/Demo, application lifecycle, realtime/video pipeline, model, dataset, weights, or network path | The active product surface remains the owner-local SDK and SDK-owned still-image validation. |
| Hairline, double-chin, facial proportion, or 3D additions | These remain future taxonomy rows and are not repairs of the eight observed directions. |
| Device, commercial quality, packaging, shipping, launch, release, or external distribution claims | Automated owner-local evidence does not establish those claims. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| VAL-01 | Pending roadmap | Pending |
| VAL-02 | Pending roadmap | Pending |
| FACE-01 | Pending roadmap | Pending |
| FACE-02 | Pending roadmap | Pending |
| EYE-01 | Pending roadmap | Pending |
| BROW-01 | Pending roadmap | Pending |
| NOSE-01 | Pending roadmap | Pending |
| NOSE-02 | Pending roadmap | Pending |
| MOUTH-01 | Pending roadmap | Pending |
| SAFE-01 | Pending roadmap | Pending |
| COMPAT-01 | Pending roadmap | Pending |
| CLOSE-01 | Pending roadmap | Pending |

**Coverage:** 12 total, 0 mapped, 0 complete, 12 pending roadmap.

---
*Last updated: 2026-08-26 for v1.22 requirements definition*
