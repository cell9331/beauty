# Beauty Shaping Branch: Eyes

## Business Logic

Eye tools include size, vertical position, eye height, length, distance, fat removal, muscle lift, pupil size, gaze correction, lower eyelid, tail lift, tilt, redness removal, inner/outer corners, and symmetry.

## Technical Core

- Existing MVP supports size, distance, Y position, and tail lift.
- Redness removal is color/region processing, not geometry only.
- Pupil/gaze correction requires eye-region detection and stricter privacy/safety review.
- Status: `partial`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` eye landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: `eyeSize`, `eyeDistance`, `eyeYPosition`, and `eyeTailLift`.
- Future parameter needs: eye height, length, pupil, gaze, lower lid, redness, corners, and symmetry.
- Evidence status: Phase 29 public-facade saved-image output and Phase 30 safety/degradation evidence complete exactly the existing-parameter subtools `大小`, `上下`, `眼距`, and `眼尾上扬`; branch-level status remains `partial` because the future tools above still need separate design and evidence.

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
