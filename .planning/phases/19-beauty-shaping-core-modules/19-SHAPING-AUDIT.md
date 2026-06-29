# Phase 19 Beauty Shaping Audit

**Date:** 2026-06-29
**Scope:** SDK-only beauty-shaping baseline for BSHAPE-01, BSHAPE-02, and BSHAPE-03.

## Boundary Summary

Phase 19 is limited to `BeautySDK` core module logic, SDK tests, and blueprint/planning docs (D-01, D-02, D-03). It does not add SwiftUI, Demo routes, category rails, tool panels, app-side interaction state, public facade geometry saved-image wiring, or `BeautyExampleRenderer` geometry cases.

Internal provider, resolver, control-point, and MVP proxy evidence can support `partial` branch status, but it does not make public facade saved-image geometry output complete (D-04, D-05, D-06). Public facade detection plus geometry render integration must produce same-dimension, watermarked renderer outputs before face-shape, eye, nose, mouth, eyebrow, proportion, or 3D sculpt branches can claim saved-image visual completion.

## Branch Status Audit

| Branch | Target status | SDK owner | Current public parameter coverage | Future parameter needs | Evidence boundary |
| --- | --- | --- | --- | --- | --- |
| `3D塑颜` | blocked-by-geometry-output | `BeautyEffects` | None | Symmetry, vertical, horizontal, tilt | D-15 keeps pose-aware 3D sculpt out of Phase 19; requires detection/render integration and public facade saved-image output before visible completion. |
| `比例` | partial | `BeautyEffects` | `faceSmall` indirect coverage only | Forehead, mid-face, philtrum, lower-face, short-face, head-face | D-14 allows only `faceSmall` as proportion-adjacent partial evidence; advanced controls remain future. |
| `脸型` | partial | `BeautyEffects` | `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength` | Smooth face, temple, cheekbone, double chin, pointed chin, hairline | D-10 allows face/chin provider, resolver, degradation, docs, and tests for existing parameters only. |
| `眼睛` | partial | `BeautyEffects` | `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift` | Eye height, length, pupil, gaze, lower lid, redness, corners, symmetry | D-11 allows eye provider, missing-eye, stale/reused, cap, and redaction evidence for existing parameters only. |
| `嘴唇` | partial | `BeautyEffects` | `mouthSize`, `mouthWidth`, `smile`, `lipColor` | M-lip, position, tilt, left/right, teeth | D-13 keeps mouth geometry partial; `lipColor` is visible color evidence for a subtool, not full lips completion. |
| `鼻子` | partial | `BeautyEffects` | `noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge` | Lift, root/bridge split, additional nose shaping | D-12 allows nose provider, missing-nose, stale/reused, cap, and redaction evidence for existing parameters only. |
| `眉毛` | future | `BeautyEffects` if promoted | None | Position, thickness, length, distance, head distance, tilt, peak | D-16 keeps eyebrow geometry, texture synthesis, resource overlays, and public eyebrow parameters out of Phase 19. |

No beauty-shaping branch should be promoted beyond these target statuses in Phase 19. `BeautyResources` remains a future dependency only when a promoted branch genuinely needs resource-backed assets.

## Allowed Public Fields

Phase 19 may use only the existing public shaping and lip fields from `BeautyParameters` (D-07):

| Field | Resolver/cap surface | Provider or effect surface | Focused test surface | Branch evidence |
| --- | --- | --- | --- | --- |
| `faceSlim` | `BeautyEffectResolver`, `BeautySafetyCaps.faceSlim` | `FaceShapeWarpProvider` | `FaceShapeWarpProviderTests`, `GeometryConflictResolverTests` | `脸型` partial |
| `faceSmall` | `BeautyEffectResolver`, `BeautySafetyCaps.faceSmall` | `FaceShapeWarpProvider` | `FaceShapeWarpProviderTests`, `GeometryConflictResolverTests` | `比例` and `脸型` partial |
| `faceVShape` | `BeautyEffectResolver`, `BeautySafetyCaps.faceVShape` | `FaceShapeWarpProvider` | `FaceShapeWarpProviderTests`, `GeometryConflictResolverTests` | `脸型` partial |
| `jawSlim` | `BeautyEffectResolver`, `BeautySafetyCaps.jawSlim` | `FaceShapeWarpProvider` | `FaceShapeWarpProviderTests`, `GeometryConflictResolverTests` | `脸型` partial |
| `chinLength` | `BeautyEffectResolver`, `BeautySafetyCaps.chinLength` | `ChinWarpProvider` | `FaceShapeWarpProviderTests`, `GeometryConflictResolverTests` | `脸型` partial |
| `eyeSize` | `BeautyEffectResolver`, `BeautySafetyCaps.eyeSize` | `EyeWarpProvider` | `EyeWarpProviderTests`, `MissingLandmarkDegradationTests` | `眼睛` partial |
| `eyeDistance` | `BeautyEffectResolver`, `BeautySafetyCaps.eyeDistance` | `EyeWarpProvider` | `EyeWarpProviderTests` | `眼睛` partial |
| `eyeYPosition` | `BeautyEffectResolver`, `BeautySafetyCaps.eyeYPosition` | `EyeWarpProvider` | `EyeWarpProviderTests` | `眼睛` partial |
| `eyeTailLift` | `BeautyEffectResolver`, `BeautySafetyCaps.eyeTailLift` | `EyeWarpProvider` | `EyeWarpProviderTests` | `眼睛` partial |
| `noseSlim` | `BeautyEffectResolver`, `BeautySafetyCaps.noseSlim` | `NoseWarpProvider` | `NoseWarpProviderTests`, `MissingLandmarkDegradationTests` | `鼻子` partial |
| `noseWingSlim` | `BeautyEffectResolver`, `BeautySafetyCaps.noseWingSlim` | `NoseWarpProvider` | `NoseWarpProviderTests` | `鼻子` partial |
| `noseTipSize` | `BeautyEffectResolver`, `BeautySafetyCaps.noseTipSize` | `NoseWarpProvider` | `NoseWarpProviderTests`, `MissingLandmarkDegradationTests` | `鼻子` partial |
| `noseBridge` | `BeautyEffectResolver`, `BeautySafetyCaps.noseBridge` | `NoseWarpProvider` | `NoseWarpProviderTests` | `鼻子` partial |
| `mouthSize` | `BeautyEffectResolver`, `BeautySafetyCaps.mouthSize` | `MouthWarpProvider` | `MouthWarpProviderTests`, `MissingLandmarkDegradationTests` | `嘴唇` partial |
| `mouthWidth` | `BeautyEffectResolver`, `BeautySafetyCaps.mouthWidth` | `MouthWarpProvider` | `MouthWarpProviderTests`, `MissingLandmarkDegradationTests` | `嘴唇` partial |
| `smile` | `BeautyEffectResolver`, `BeautySafetyCaps.smile` | `MouthWarpProvider` | `MouthWarpProviderTests`, `MissingLandmarkDegradationTests` | `嘴唇` partial |
| `lipColor` | `BeautyEffectResolver`, `BeautySafetyCaps.lipColor` | `BeautyColorEffectPipeline` mouth-region color path | `LipColorEffectTests`, `MissingLandmarkDegradationTests`, `CombinedEffectSafetyTests` | visible subtool evidence; full `嘴唇` remains partial |

Advanced controls from D-08 and D-09 are non-promoted parameter needs only: forehead, mid-face, philtrum, cheekbone, double chin, eye height/length, pupil/gaze, nose lift/root split, M-lip, teeth, eyebrow controls, 3D sculpt controls, and any resource-backed eyebrow or mouth asset model.

## Provider And Test Handoff

Plans 19-02 and 19-03 should strengthen evidence only where concrete tests show a gap.

| Plan | Evidence set | Required proof |
| --- | --- | --- |
| 19-02 | `FaceShapeWarpProvider`, `ChinWarpProvider`, `EyeWarpProvider`, `NoseWarpProvider`, `GeometryConflictResolver` | Clamped deterministic control points, cap-aware strengths, domain-specific missing-input skips, and redacted `combined_geometry_weakened`, `beauty.effects.weakenedCount`, `beauty.effects.geometryStrengthScale` metadata. |
| 19-03 | `MouthWarpProvider`, `BeautyEffectResolver`, lip-color color path, degradation tests | Mouth signed size/width behavior, `mouth_inputs_missing`, `lip_inputs_missing`, stale/reused degradation, safe-domain preservation, and redacted warning/metric strings. |
| 19-04 | Verification and blueprint docs | Full `swift test --package-path BeautySDK`, focused shaping suites, exact branch status scans, and documentation that saved-image geometry output remains deferred. |
| 19-05 | Negative scans and ledgers | No public parameter additions, no SwiftUI/Demo diffs, no geometry renderer cases, no overclaiming branch status, and no sensitive warning/metric leakage. |

## Renderer Boundary

`BeautyExampleRenderer` currently validates public facade output for skin/color/filter cases only. Phase 19 must keep it that way: no geometry cases, no shaping/lip render cases, and no fake saved-image claim. Renderer build or current non-geometry cases are optional regression evidence, not a Phase 19 completion gate (D-20).

## Redaction Baseline

Warning and metric evidence may use stable domain names, counts, cap totals, skipped-domain counters, geometry point counts, and reason codes. It must not expose sensitive values or payloads: landmarks, control points, bounding boxes, raw Vision objects, `VNFaceObservation`, local paths, `/private/var`, image bytes, `SIMD` point dumps, or point-array literals.

## Final Negative Scans

Before closing Phase 19:

- Run focused shaping tests for `FaceShapeWarpProviderTests`, `EyeWarpProviderTests`, `NoseWarpProviderTests`, `MouthWarpProviderTests`, `GeometryConflictResolverTests`, `MissingLandmarkDegradationTests`, and `BeautyEffectResolverTests` (D-18).
- Run full `swift test --package-path BeautySDK` (D-17).
- Scan branch docs and feature matrix to ensure `3D塑颜` is `blocked-by-geometry-output`, `比例` is `partial`, `脸型` is `partial`, `眼睛` is `partial`, `嘴唇` is `partial`, `鼻子` is `partial`, and `眉毛` is `future` (D-10 through D-16).
- Compare `BeautyParameters.swift` public fields to the expected current list; no new public parameter, coding key, initializer argument, or normalized copy may appear (D-07 through D-09).
- Verify `git diff --quiet -- BeautyDemo` to prove no UI/SwiftUI/Demo work was added (D-01 through D-03).
- Scan `BeautyExampleRenderer/main.swift` for no geometry cases and no shaping/lip parameters (D-04 through D-06, D-20).
- Scan warning/metric implementation surfaces for sensitive terms listed above (D-19).
