---
phase: 19-beauty-shaping-core-modules
status: in_progress
updated: 2026-06-29T06:45:54Z
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

