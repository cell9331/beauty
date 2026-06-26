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
- Evidence expectation: current provider/resolver evidence is partial; visible completion needs public facade saved-image geometry output.

## Boundary

Do not persist eye landmarks or expose eye geometry in public debug output.
