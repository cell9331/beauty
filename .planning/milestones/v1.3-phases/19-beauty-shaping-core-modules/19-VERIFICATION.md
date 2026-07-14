---
phase: 19-beauty-shaping-core-modules
status: passed
updated: 2026-06-29T06:53:08Z
---

# Phase 19 Verification Evidence

## Test Evidence

All commands below were run from the repository root on 2026-06-29.

| Command | Exit | Observed result |
| --- | --- | --- |
| `swift test --package-path BeautySDK --filter FaceShapeWarpProviderTests` | 0 | Passed 7 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter EyeWarpProviderTests` | 0 | Passed 6 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter NoseWarpProviderTests` | 0 | Passed 6 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter MouthWarpProviderTests` | 0 | Passed 6 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter GeometryConflictResolverTests` | 0 | Passed 6 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` | 0 | Passed 11 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter BeautyEffectResolverTests` | 0 | Passed 7 tests, 0 failures. |
| `swift test --package-path BeautySDK --filter BeautyEffectsTests` | 0 | Passed 65 tests, 0 failures. |
| `swift test --package-path BeautySDK` | 0 | Passed 141 tests, 0 failures. |

## Provider And Resolver Evidence

- Face-shape/chin/proportion-adjacent evidence: deterministic/clamped provider assertions for `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`; `faceSmall` remains only partial proportion-adjacent coverage.
- Eye evidence: deterministic/clamped provider assertions for `eyeSize`, `eyeDistance`, `eyeYPosition`, and `eyeTailLift`, plus `eye_inputs_missing` skip behavior.
- Nose evidence: deterministic/clamped provider assertions for `noseSlim`, `noseWingSlim`, `noseTipSize`, and `noseBridge`, plus `nose_inputs_missing` skip behavior.
- Mouth/lip evidence: deterministic/clamped provider assertions for `mouthSize`, `mouthWidth`, and `smile`; `lipColor` is visible color evidence and does not activate the mouth geometry domain or complete the full lips branch.
- Resolver/degradation evidence: no-face, missing eye/nose/mouth/lip, stale geometry, reused geometry, combined cap/weakening, and emitted warning/metric redaction assertions passed.

## Geometry Output Boundary

Provider, resolver, control-point, and MVP proxy evidence remains internal evidence. Public facade saved-image geometry output is still deferred until face detection plus geometry render integration can produce same-dimension, watermarked `BeautyExampleRenderer` outputs for geometry branches.

No Phase 19 command added `BeautyExampleRenderer` geometry cases, public `BeautyParameters` fields, SwiftUI files, Demo routes, 3D sculpt implementation, or eyebrow implementation.

## Redaction Evidence

XCTest assertions scan emitted warning codes/messages and metric keys for sensitive terms including `landmark`, `control point`, `controlPoint`, `bounding`, `VNFaceObservation`, `/private/var`, `image bytes`, `SIMD`, and point-array literals.

The broad source scan `! rg -n 'landmark|control point|controlPoint|bounding|VNFaceObservation|/private/var|image bytes|SIMD|\\[0\\.' BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` reports the legitimate internal implementation call `.controlPoints(...)` in `BeautyEffectResolver.swift`. Per the accepted Phase 19 planning caveat, redaction evidence is scoped to emitted warning/metric strings instead of all implementation identifiers.

## Final Closeout Scans

These final scans were run from the repository root on 2026-06-29 after Plan 19-04 evidence and before BSHAPE ledger closeout.

| Command | Exit | Observed result |
| --- | --- | --- |
| Exact public-field comparison for `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` against the 31 pre-existing fields: `skinSmoothing`, `skinWhitening`, `skinRosy`, `skinSharpen`, `brightness`, `contrast`, `saturation`, `temperature`, `tint`, `exposure`, `highlight`, `shadow`, `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength`, `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift`, `noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge`, `mouthSize`, `mouthWidth`, `smile`, `lipColor`, `filterId`, `filterIntensity`. | 0 | Public fields matched exactly; no D-08/D-09 advanced controls or other public fields were added. |
| `git diff --quiet -- BeautyDemo` | 0 | No Demo or SwiftUI file differs from `HEAD`. |
| `! rg -n 'faceSlim|faceSmall|faceVShape|jawSlim|chinLength|eyeSize|eyeDistance|eyeYPosition|eyeTailLift|noseSlim|noseWingSlim|noseTipSize|noseBridge|mouthSize|mouthWidth|smile|lipColor' BeautySDK/Sources/BeautyExampleRenderer/main.swift` | 0 | No shaping or lip parameter renderer case was added. |
| `! rg -n 'id: "(face|eye|nose|mouth|lip|chin|jaw|proportion|3d|brow)|BeautyParameters\\([^)]*(faceSlim|eyeSize|noseSlim|mouthSize|lipColor)' BeautySDK/Sources/BeautyExampleRenderer/main.swift` | 0 | No geometry-oriented saved-image renderer case or fake geometry claim was added. |
| `! rg -n 'Beauty shaping \\| (3D塑颜|比例|脸型|眼睛|嘴唇|鼻子|眉毛) \\| implemented|Status: `implemented`' docs/meitu-function-blueprint/features/beauty-shaping docs/meitu-function-blueprint/FEATURE_MATRIX.md` | 0 | Blueprint docs do not promote beauty-shaping branches to `implemented`. |
| Scoped emitted warning/metric string scan over `BeautyEffectResolver.swift`, `GeometryConflictResolver.swift`, and `BeautyEffectPlan.swift`. | 0 | Emitted strings contain none of `landmark`, `control point`, `controlPoint`, `bounding`, `VNFaceObservation`, `/private/var`, `image bytes`, `SIMD`, or point-array literals. |
| `swift test --package-path BeautySDK` | 0 | Passed 141 tests, 0 failures. |

Closeout status remains honest: `比例`, `脸型`, `眼睛`, `嘴唇`, and `鼻子` are `partial`; `3D塑颜` is `blocked-by-geometry-output`; `眉毛` is `future`; public facade saved-image geometry output remains deferred until face detection plus geometry render integration exists.
