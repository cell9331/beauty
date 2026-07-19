---
phase: 41-public-contract-and-observed-eye-support
finding: CR-01
status: fixed_requires_human_verification
fixed_at: 2026-07-16
---

# Review Fix: CR-01

## Face-local Vision landmark conversion

`VisionFaceDetector.mapObservation` now requires finite, positive face bounds
whenever observed eye support is present. Each contour and pupil point is
validated as finite and face-local (`0...1`), composed into Vision image space
with `visionBounds.origin + localPoint * visionBounds.size`, and passed through
`CoordinateMapper` exactly once for orientation and mirror handling. Missing or
invalid bounds fail closed with the existing redacted mapping-failed summary.

The mapping tests now use a non-unit face bounding box and assert the resulting
points across up/right/left/down orientations and input mirroring. A dedicated
test covers missing bounds, and malformed local points remain fail-closed.

## Verification

- Focused detection tests: 18/18 passed (`VisionFaceDetectorTests`,
  `FaceObservationMappingTests`)
- Full SwiftPM suite: 284/284 passed
- `check_eye_support_boundaries.py --self-test`: 24/24 passed
- `check_eye_support_boundaries.py` live mode: 10/10 passed
- `git diff --check`: passed

The fix changes coordinate semantics in production mapping, so the status is
marked `fixed_requires_human_verification` for the phase verifier to confirm
against real Vision landmark behavior.
