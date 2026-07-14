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
| `脸型` | partial | `BeautyEffects` | `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength` | Smooth face, temple, cheekbone, double chin, pointed chin, hairline | Phase 28 completes only the scoped rows `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`; remaining rows still need separate evidence. |
| `眼睛` | partial | `BeautyEffects` | `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift` | Eye height, length, pupil, gaze, lower lid, redness, corners, symmetry | Phase 29 public-facade output and Phase 30 safety/degradation evidence implement exactly `大小`, `上下`, `眼距`, and `眼尾上扬`; remaining eye tools need separate design and evidence. |
| `嘴唇` | partial | `BeautyEffects` | Geometry: `mouthSize`, `mouthWidth`, `smile`, `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, `lipPlump`; color-only: `lipColor` | `白牙` teeth-region segmentation/color retouch | Phase 40 promotes exactly 上下, 倾斜, 左右, M唇, and true 丰唇 after Phases 38-40 contract/output/safety evidence; branch remains partial because `白牙` is future. |
| `鼻子` | implemented | `BeautyEffects` | `noseSlim`, `noseWingSlim`, signed `noseTipSize`, `noseBridge`, `noseRootNarrowing`, `noseTipLift` | No additional control is implied by the exact six-row taxonomy | Phases 31-32 and 35-37 implement exactly `大小`, `提升`, `鼻翼`, `山根`, `鼻梁`, and `鼻尖`; SDK-core branch complete with UI/device/commercial boundaries preserved. |
| `眉毛` | future | `BeautyEffects` | None | Position, thickness, length, distance, head distance, tilt, peak; resources only if explicitly designed | No v1.3 completion evidence until promoted. |

## Phase 19 Evidence

Phase 19 strengthens provider, resolver, degradation, cap, and redaction tests for the current public fields while preserving branch status honesty. `swift test --package-path BeautySDK` and focused shaping suites pass as SDK evidence, but public facade saved-image geometry output is still required before geometry-heavy branches can claim visual completion. `lipColor` remains visible color evidence for a subtool; it does not complete the full lips branch.

## Phase 28 Face-Shape Evidence

Phase 28 adds public-facade saved-output evidence for six scoped face-shape rows: `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`. The renderer/helper path records 102 ignored outputs and 30/30 top-region comparisons in `28-FACE-SHAPE-RENDERER-EVIDENCE.md`, with final closeout in `28-VERIFICATION.md`.

`下颌线` remains a documented `jawSlim` alias and shares evidence with `下颌角`. The branch remains `partial` until the unscoped face-shape rows and broader `美型 / 五官` branches have their own SDK behavior and evidence.

## Phase 30 Eye Evidence

Phase 30 implements exactly four existing-parameter eye subtools: `大小`, `上下`, `眼距`, and `眼尾上扬`. The `眼睛` branch remains `partial` because eye height, length, pupil, gaze, lids, redness, corners, symmetry, eye-fat, and other future tools still require separate product-neutral design and evidence.

Phase 32 implemented exactly four legacy nose subtools: `大小`, `鼻翼`, `鼻梁`, and signed `鼻尖`, while deliberately leaving `山根` and `提升` unresolved. Phases 35-36 established their independent contract/output chain; Phase 37 implements `山根` through `noseRootNarrowing` and `提升` through `noseTipLift`, without borrowing `noseBridge` or signed `noseTipSize` evidence, and closes the exact six-row SDK-core `鼻子` branch with device and commercial boundaries preserved.

Public-facade output for the four subtools is recorded in `29-EYE-RENDERER-EVIDENCE.md`. Input semantics, caps, missing/reused/stale degradation, combined weakening, privacy, and active-source boundaries are recorded in `30-EYE-SAFETY-EVIDENCE.md`.

## Phase 40 Mouth Geometry Evidence

The exact SDK-core mouth geometry set is `mouthSize`, `mouthWidth`, `smile`, `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, and `lipPlump`. Phase 40 closes exact caps, eight-field degradation/transitions, fourteen-removal convergence, redacted diagnostics, and fail-closed source/artifact boundaries after Phase 39's 308-output evidence. `lipColor` remains color-only. The branch stays `partial` because `白牙` remains future.

## Boundary

No public landmarks/control points. Demo taxonomy maps to product-neutral SDK parameter names.
`BeautyResources` is only a future dependency for resource-backed shaping.
Filters, makeup, stickers, templates, downloads, VIP, payment, and entitlement behavior remain deferred product/resource areas.

Implementation work in this family is SDK-core work only unless a future milestone explicitly scopes UI. Do not add SwiftUI surface area to mark a tool complete.
