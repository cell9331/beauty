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
| `脸型` | partial | `BeautyEffects` | Five prior fields plus independent `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper` | `去双下巴`, `去双下巴 Pro`, `发际线` local semantic-region/segmentation design | Phase 28 covers six prior rows; Phase 45 contract/support, Phase 46 provider, Phase 47 public output, and Phase 48 final safety/privacy/boundaries independently implement `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴`. |
| `眼睛` | partial | `BeautyEffects` | Four prior fields plus `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, signed `eyeTilt`, `innerCornerOpen`, `outerCornerOpen`, `eyeSymmetry`, and still-image `scleraRednessReduction` | `去脂` local retouch/segmentation design | Phases 29-44 cover fourteen geometry rows; Phases 62-64 independently admit, implement, verify and promote `祛红血丝`. |
| `嘴唇` | implemented | `BeautyEffects` | Geometry: `mouthSize`, `mouthWidth`, `smile`, `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, `lipPlump`; still-image color: `teethWhitening`; independent color-only: `lipColor` | No remaining child row in the exact mouth taxonomy; broader delivery surfaces require separate evidence. | Phases 33-40 implement all eight geometry rows. Phase 59 opens rights-approved teeth evidence/admission, Phase 60 adds the bounded request-local provider/integration, and Phase 61 closes strict public output, adversarial safety, original-detail review, and exact `白牙` promotion. |
| `鼻子` | implemented | `BeautyEffects` | `noseSlim`, `noseWingSlim`, signed `noseTipSize`, `noseBridge`, `noseRootNarrowing`, `noseTipLift` | No additional control is implied by the exact six-row taxonomy | Phases 31-32 and 35-37 implement exactly `大小`, `提升`, `鼻翼`, `山根`, `鼻梁`, and `鼻尖`; SDK-core branch complete with UI/device/commercial boundaries preserved. |
| `眉毛` | implemented | `BeautyEffects` | `eyebrowYPosition`, `eyebrowThickness`, `eyebrowLength`, `eyebrowSpacing`, `eyebrowHeadSpacing`, `eyebrowTilt`, `eyebrowPeakDefinition` | No additional control or resource is implied by the exact seven-row SDK-core taxonomy | Phase 49 contract/support, Phase 50 independent providers/pipeline, Phase 51 public-facade output, and Phase 52 final safety/privacy/boundary evidence implement exactly `上下`, `粗细`, `长短`, `间距`, `眉头间距`, `倾斜`, and `眉峰`. |

## Phase 19 Evidence

Phase 19 strengthens provider, resolver, degradation, cap, and redaction tests for the current public fields while preserving branch status honesty. `swift test --package-path BeautySDK` and focused shaping suites pass as SDK evidence, but public facade saved-image geometry output is still required before geometry-heavy branches can claim visual completion. `lipColor` remains visible color evidence for a subtool; it does not complete the full lips branch.

## Phase 28 Face-Shape Evidence

Phase 28 adds public-facade saved-output evidence for six scoped face-shape rows: `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`. The renderer/helper path records 102 ignored outputs and 30/30 top-region comparisons in `28-FACE-SHAPE-RENDERER-EVIDENCE.md`, with final closeout in `28-VERIFICATION.md`.

`下颌线` remains a documented `jawSlim` alias and shares evidence with `下颌角`. The branch remains `partial` until the unscoped face-shape rows and broader `美型 / 五官` branches have their own SDK behavior and evidence.

## Phase 48 Face Safety Evidence

Phase 48 promotes exactly `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴` after Phase 45 public contract/private support, Phase 46 independent providers, Phase 47 strict public-output evidence, and Phase 48 final cap/degradation/convergence/privacy/boundary evidence. The exact current face/chin geometry inventory is nine fields.

`去双下巴`, `去双下巴 Pro`, and `发际线` remain future because approved local semantic-region/segmentation implementations and reproducible clean-clone fixtures do not exist. Branch `脸型` stays `partial`; no Demo, device, commercial, performance, packaging, shipping, or launch-readiness claim is made.

## Phase 30 Eye Evidence

Phase 30 implements exactly four existing-parameter eye subtools: `大小`, `上下`, `眼距`, and `眼尾上扬`. The `眼睛` branch remains `partial` because eye height, length, pupil, gaze, lids, redness, corners, symmetry, eye-fat, and other future tools still require separate product-neutral design and evidence.

Phase 44 promotes exactly `眼高`, `长度`, `提肌`, `眼瞳大小`, `眼神矫正`, `眼睑下至`, `倾斜`, `内眼角`, `外眼角`, and `对称` after Phase 41 contract/support, Phase 42 provider, Phase 43 public output, and Phase 44 final safety/privacy/boundary evidence. Together with the four Phase 30 rows, fourteen geometry rows are implemented. `去脂` and `祛红血丝` remain future, so branch `眼睛` stays `partial`; no device, commercial, performance, packaging, shipping, or launch claim is made.

## Phase 64 Sclera Redness Closeout

Phase 62 independently opens the authorized positive/negative sclera decision
and appends the positive-only `scleraRednessReduction` intent. Phase 63 adds the
actual-contour/actual-pupil guarded per-eye provider through one canonical
request and immutable-source composition. Phase 64 adds the exact public output
case, passes the six-output matrix, color-independent and recolored-protected
oracles, fresh original-detail review, privacy/security and full regression,
then promotes exactly `祛红血丝`.

The Demo row remains disabled with no active mapping. `去脂` remains future, so
aggregate branch `眼睛` stays `partial`; no population, realtime, device,
commercial, packaging, shipping, launch or release-readiness claim is made.

Phase 32 implemented exactly four legacy nose subtools: `大小`, `鼻翼`, `鼻梁`, and signed `鼻尖`, while deliberately leaving `山根` and `提升` unresolved. Phases 35-36 established their independent contract/output chain; Phase 37 implements `山根` through `noseRootNarrowing` and `提升` through `noseTipLift`, without borrowing `noseBridge` or signed `noseTipSize` evidence, and closes the exact six-row SDK-core `鼻子` branch with device and commercial boundaries preserved.

Public-facade output for the four subtools is recorded in `29-EYE-RENDERER-EVIDENCE.md`. Input semantics, caps, missing/reused/stale degradation, combined weakening, privacy, and active-source boundaries are recorded in `30-EYE-SAFETY-EVIDENCE.md`.

## Phase 40 Mouth Geometry Evidence

The exact SDK-core mouth geometry set is `mouthSize`, `mouthWidth`, `smile`, `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, and `lipPlump`. Phase 40 closes exact caps, eight-field degradation/transitions, fourteen-removal convergence, redacted diagnostics, and fail-closed source/artifact boundaries after Phase 39's 308-output evidence. `lipColor` remains color-only. The branch stays `partial` because `白牙` remains future.

## Phase 61 Teeth Output and Mouth Completion

Phase 59 admits the rights-approved positive/negative teeth evidence through the
canonical Phase 54 serializer. Phase 60 implements one bounded, stateless,
request-local still-image provider and immutable-source composition unit. Phase
61 adds the exact public renderer case, passes the strict positive/negative/no-
face six-output matrix, adversarial protected-region tests, tracked/staged
privacy checks, and original-detail review. `白牙` and therefore the exact
`嘴唇` branch are `implemented` at SDK-core still-image scope.

The three local-retouch Demo rows remain disabled with nil mappings. This status
does not imply realtime/pixel-buffer support, population sufficiency, device or
performance validation, commercial/release readiness, sclera redness output,
or upper-eyelid fullness reduction.

## Phase 52 Eyebrow Geometry Evidence

Status: `implemented` at SDK-core scope.

Phase 52 promotes exactly `上下`, `粗细`, `长短`, `间距`, `眉头间距`, `倾斜`,
and `眉峰` after Phase 49 public contract/private observed support, Phase 50
independent providers and unified pipeline, Phase 51 strict public-facade
output, and Phase 52 exact cap/lifecycle/convergence/privacy/boundary evidence.
The exact seven-row `眉毛` branch is `implemented` at SDK-core scope.

The v1.14-v1.16 retouch, hairline, and double-chin scopes remain future. This
status adds no SwiftUI or Demo UI, device parity, commercial-naturalness
approval, optimized-performance, packaging, shipping, launch, independent
milestone audit, archive, tag, or cleanup claim.

## Boundary

No public landmarks/control points. Demo taxonomy maps to product-neutral SDK parameter names.
`BeautyResources` is only a future dependency for resource-backed shaping.
Filters, makeup, stickers, templates, downloads, VIP, payment, and entitlement behavior remain deferred product/resource areas.

Implementation work in this family is SDK-core work only unless a future milestone explicitly scopes UI. Do not add SwiftUI surface area to mark a tool complete.
