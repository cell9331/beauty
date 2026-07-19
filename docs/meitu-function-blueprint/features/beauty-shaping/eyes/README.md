# Beauty Shaping Branch: Eyes

## Business Logic

Eye tools include size, vertical position, eye height, length, distance, fat removal, muscle lift, pupil size, gaze correction, lower eyelid, tail lift, tilt, redness removal, inner/outer corners, and symmetry.

## Technical Core

- SDK geometry supports size, distance, Y position, tail lift, height, length, upper/lower lid, pupil size, gaze correction, signed tilt, inner/outer corners, and symmetry.
- Redness removal is color/region processing, not geometry only.
- Pupil/gaze correction requires eye-region detection and stricter privacy/safety review.
- Status: `partial`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` eye landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` geometry coverage is exactly the four prior fields plus `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, signed `eyeTilt`, `innerCornerOpen`, `outerCornerOpen`, and `eyeSymmetry`.
- Future needs are local retouch/color design for `去脂` and `祛红血丝` only; they are not geometry aliases.
- Evidence status: Phases 29-30 cover the four prior rows. Phase 41 contract/support, Phase 42 provider behavior, Phase 43 public-facade output, and Phase 44 exact safety/privacy/boundary evidence independently implement `眼高`, `长度`, `提肌`, `眼瞳大小`, `眼神矫正`, `眼睑下至`, `倾斜`, `内眼角`, `外眼角`, and `对称`. Branch status remains `partial` because the two retouch rows remain future.

## Boundary

Do not persist eye landmarks or expose eye geometry in public debug output.

## Phase 30 Existing-Parameter Closeout

- `eyeSize` is positive-only `[0,1]` with exact effective cap `0.45`; `eyeTailLift` is positive-only `[0,1]` with exact cap `0.30`.
- `eyeDistance` is signed `[-1,1]` with exact cap `0.30`; `eyeYPosition` is signed `[-1,1]` with exact cap `0.25`.
- Both eyes are required. Missing either eye group skips the complete eye domain with `eye_inputs_missing`.
- Reused and stale geometry also skip the complete eye domain with `eye_geometry_reused_skipped` and `eye_geometry_stale_skipped`; all four effective eye strengths become zero.
- Warnings use fixed category-only messages and observability is aggregate-only. Raw eye geometry remains private and is neither persisted nor exposed by public diagnostics.
- Implemented second-level rows are exactly `大小`, `上下`, `眼距`, and `眼尾上扬`. The eye branch remains partial because future tools still need separate neutral parameters/resources, safety design, and evidence.
- Phase 29 public-facade renderer evidence is recorded in `29-EYE-RENDERER-EVIDENCE.md`; Phase 30 safety, degradation, combined, and boundary evidence is recorded in `30-EYE-SAFETY-EVIDENCE.md`.

## Phase 44 Remaining-Geometry Closeout

- Exactly ten independent geometry rows are added to the four prior implemented rows; `去脂` and `祛红血丝` remain future and branch `眼睛` remains `partial`.
- Phase 41 owns scalar contract and observed support, Phase 42 owns provider transforms, Phase 43 owns public saved output, and Phase 44 owns final caps, fourteen-field degradation, 33-field/10.70 conflict arithmetic, 28-removal convergence, privacy, and boundary authorization.
- This is SDK automated evidence, not physical-device parity, subjective naturalness, commercial approval, packaging, shipping, or launch readiness.
