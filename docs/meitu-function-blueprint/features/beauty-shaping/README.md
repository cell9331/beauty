# Beauty Shaping Function Family

## Business Role

Beauty shaping covers face geometry and facial feature adjustments inspired by Meitu `美型 / 五官`: `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, and `眉毛`.

`../../SHAPE_FEATURE_LEDGER.md` is the authority for the 1:1 de-duplicated second-level tool list and per-tool SDK-core status.

## Technical Core

- SDK owner: `BeautyEffects` geometry providers plus `BeautyRender` unified warp pass.
- Detection dependency: face landmarks and pose quality.
- Public model: existing `BeautyParameters` where available; new public parameters require explicit design updates.
- Safety: combined geometry weakening, caps, and missing-landmark degradation.

## Branch Contracts

| Branch | Status | Primary owner | Current public `BeautyParameters` coverage | Future parameter needs | Evidence expectation |
| --- | --- | --- | --- | --- | --- |
| `3D塑颜` | blocked-by-geometry-output | `BeautyEffects` | None | Symmetry, vertical, horizontal, tilt | Requires detection/render integration and public facade saved-image output before visible completion. |
| `比例` | partial | `BeautyEffects` | `faceSmall` | Forehead, mid-face, philtrum, lower-face, short-face, head-face | Current provider/resolver evidence is partial; facade-visible geometry output is still required. |
| `脸型` | partial | `BeautyEffects` | `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength` | Smooth face, temple, cheekbone, double chin, pointed chin, hairline | Current provider/resolver evidence is partial; facade-visible geometry output is still required. |
| `眼睛` | partial | `BeautyEffects` | `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift` | Eye height, length, pupil, gaze, lower lid, redness, corners, symmetry | Current provider/resolver evidence is partial; facade-visible geometry output is still required. |
| `嘴唇` | partial | `BeautyEffects` | `mouthSize`, `mouthWidth`, `smile`, `lipColor` | M-lip, position, tilt, left/right, teeth | Lip color has visible color evidence; geometry subtools still need facade-visible geometry output. |
| `鼻子` | partial | `BeautyEffects` | `noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge` | Lift, root/bridge split, additional nose shaping | Current provider/resolver evidence is partial; facade-visible geometry output is still required. |
| `眉毛` | future | `BeautyEffects` | None | Position, thickness, length, distance, head distance, tilt, peak; resources only if explicitly designed | No v1.3 completion evidence until promoted. |

## Phase 19 Evidence

Phase 19 strengthens provider, resolver, degradation, cap, and redaction tests for the current public fields while preserving branch status honesty. `swift test --package-path BeautySDK` and focused shaping suites pass as SDK evidence, but public facade saved-image geometry output is still required before geometry-heavy branches can claim visual completion. `lipColor` remains visible color evidence for a subtool; it does not complete the full lips branch.

## Boundary

No public landmarks/control points. Demo taxonomy maps to product-neutral SDK parameter names.
`BeautyResources` is only a future dependency for resource-backed shaping.
Filters, makeup, stickers, templates, downloads, VIP, payment, and entitlement behavior remain deferred product/resource areas.

Implementation work in this family is SDK-core work only unless a future milestone explicitly scopes UI. Do not add SwiftUI surface area to mark a tool complete.
