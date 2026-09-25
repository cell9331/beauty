# Example Images

Current policy: [authorized generated portrait-like inputs are eligible for
full SDK effect acceptance](../docs/IMAGE_EFFECT_ACCEPTANCE.md). The `p1.jpg`
inventory below describes the existing renderer fixture, not an exclusive
image-source requirement for future milestones. Genuine human portraits are
optional.

`example-images` stores local renderer fixtures, flat machine outputs, and a
generated review gallery. Binary portraits remain Git-ignored; text policy and
authorization records carry the durable contract without publishing the media.
All inputs, targets, outputs, galleries, checkpoints, and derived model material
are owner-local and non-distributed. Their presence never authorizes external,
commercial, customer, package, App Store, or model/weight use.

## Directories

- `input/`: local source fixtures used by SDK tests and `BeautyExampleRenderer`.
  - `input/portraits/`: existing default `p1.jpg` and optional ignored,
    owner-authorized generated portrait inputs selected by file name.
  - `input/negatives/`: negative fixtures such as `no-face-gradient.png`.
- `parked-portraits/`: disabled historical portraits `e1` through `e6`; fixture
  discovery must never read this directory.
- `parked-generated/`: disabled output/gallery snapshots retained outside the
  active generation paths.
- `local-retouch-review/`: ignored local-only candidate and before/mask/after
  review material. It is never traversed by active renderer fixture discovery.
- `output/`: ignored flat generated renderer PNGs, named `{fixtureStem}__{caseId}.png`.
- `gallery/`: ignored generated human-review view, grouped as `{featureFamily}/{caseId}/{fixtureStem}.png`.
- `.gallery-staging/`: ignored fail-closed publication slot. A leftover means a prior run did not publish and blocks another run.
- `.gallery-quarantine/previous/`: ignored single-slot preservation of the prior gallery. The generator never traverses or deletes it.

Generated `output/` and `gallery/` contents are local artifacts. Recreate them
instead of committing PNGs. The active `p1.jpg` is a metadata-sanitized
2628×1778 JPEG below the existing 16 MiB acquisition ceiling; GPS, capture time,
device, and orientation metadata are absent. The no-face negative fixture is
64 px. Authorization and evidence limits are recorded in
`FIXTURE_AUTHORIZATION.md`.

## Current Authorized Fixture

- `p1.jpg` is the existing default portrait in `input/`. The user confirmed on
  2026-07-30 that the project has copyright, portrait/likeness, derivative, and
  future local test permission for this real portrait.
- The active copy uses opaque fixture ID `portrait_001`, contains no source
  filename or identity label, remains local/Git-ignored, and has image metadata
  stripped before storage.
- `e1.png` through `e5.png` and `e6.jpg` are parked and forbidden from future
  input discovery. Their prior outputs/gallery were moved under
  `parked-generated/2026-07-30-e6/`.
- Authorization makes `p1.jpg` eligible for internal evaluation. Its exposed
  smile is useful for teeth-mask containment and over-whitening review, but its
  already-light teeth are not automatically a yellow-teeth positive. It is not
  automatically a positive or negative for sclera redness or upper-eyelid
  fullness and cannot alone open any feature product gate.

To use a generated portrait in the current SwiftPM and archive-first gate, put
an authorized, metadata-sanitized, Git-ignored regular image under
`input/portraits/` and set `BEAUTYSDK_VISION_PORTRAIT_FIXTURE` to its file name.
The image must satisfy the same Vision face/eyebrow and output assertions;
its generated origin is not a reason to skip or fail. For teeth and sclera,
set `PHASE59_TEETH_BUNDLE` and `PHASE62_SCLERA_BUNDLE` to ignored local
generated positive/negative bundles with the existing manifest and mask
contract. See [current acceptance policy](../docs/IMAGE_EFFECT_ACCEPTANCE.md).

## Current Local-Retouch Candidate

- `portrait_002/original.png` is registered under the ignored
  `local-retouch-review/candidates/` boundary as an original-only positive-target
  mechanics candidate for both `teeth_whitening` and `sclera_redness`.
- Its embedded C2PA provenance declares `trainedAlgorithmicMedia`. At its
  historical registration it was an original-only mechanics candidate without
  a complete positive/negative effect oracle. That missing evidence, not its
  generated provenance, prevents promotion on the current record; a complete
  generated-image qualification may be performed separately.
- Each feature must produce and bind its own mask, after image, polarity row,
  structured original-detail judgment, and admission decision. A result from one
  feature does not qualify or block the other.
- The candidate is not copied into `input/`, does not change the active renderer
  inventory, and does not activate either production feature.

The Phase 51/52 `e6` counts below are retained as historical evidence only.
They do not override the current `p1` fixture inventory and must not be reused
as current-input claims.

## Generate Output

```bash
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output
```

## Face-feature batch validation

The SDK-owned semantic harness discovers the exact live 75-case renderer and
selects 65 cases in five logical batches (face shape, eyes, eyebrows, nose, and
mouth/teeth). Eight signed repair directions have frozen target, sibling,
outside, and protected-region contracts. Every selected case is rendered from
the authorized owner-local portrait input with the existing parameter
watermark. Measurement excludes the watermark rows and compares each semantic
direction against both immutable source and the neutral
`geometryBaseline_noop` control.

```bash
bash scripts/run-face-feature-batches.sh
```

The command accepts `--input`, `--output`, and `--report`, plus `--help`. Use
`--preflight-only` to validate paths, the exact 75/65/8 inventory, manifest,
renderer discovery, and comparator self-test without rendering or mutating the
output/report. Defaults are the ignored `example-images/input`,
`example-images/output/face-feature-batches`, and
`example-images/local-test-records/face-feature-batch-report.json` locations.
Input, output, and report paths must be admitted regular, non-symlink
descendants with no unsafe overlap.

Each full invocation creates two fresh independent CPU attempts. It requires
65/65 complete selected outputs in each attempt and reconciles completion
class, canonical `stableSemanticPayload` bytes, comparator digest, and the
runner reconciliation digest. Only the first complete attempt is retained in
the ignored output tree; it contains parameter-watermarked PNGs only.
Successful semantic publication requires verified removal of repeat media,
temporary comparator and renderer reports, workspaces, and child transcripts.
If cleanup cannot be verified, the run returns exit 2 with
`cleanup_failure`, publishes no creditable semantic result, and requires
owner-local containment and removal of any remaining artifacts. The ignored
aggregate report uses
schema `beauty.face-feature-batch-report.semantic.1` inside a volatile runner
envelope; timestamps and attempt IDs do not enter `stableSemanticPayload`.

Semantic acceptance is the conjunction of source and neutral target signal,
signed metric/polarity, fixed minimum signal, outside-target locality,
documented sibling distinction, and every protected-region ceiling. Arbitrary
pixel difference, the parameter watermark, or weakened pass-only thresholds
cannot accept a direction. Exit `0` means a complete deterministic 8/8
`semantic_pass`; exit 3 means a complete deterministic `semantic_fail` with
an honest aggregate report. Exit 3 is trustworthy completed measurement, not
infrastructure success and not evidence that the failing controls are repaired.
Admission, rendering, output, report, stale-state, or determinism faults return
the separate exit `2` `infrastructure_failure` class. A structurally safe,
distinct report destination is atomically replaced with a sanitized current
envelope, including when input admission fails. If the report path itself is
unsafe, aliased, or cannot be admitted, it is not mutated; exit 2 is then the
only current result and consumers must reject every pre-existing report.

The current frozen gaze row has no independently admitted request-local pupil
and own-eye contour geometry. Its former dark-pixel/rectangle-center proxy is
retired: lashes, shadows, makeup, or a foreign dark patch cannot earn gaze
credit. Until bounded anatomical support is authorized in a later milestone,
the comparator classifies `pupilToOwnEyeCenter` as transient
`unsupported_metric`, and the complete runner returns sanitized exit 2 instead
of publishing an eight-direction semantic result.

The report allowlist is aggregate only: exact schema/contract identifiers, CPU
token, fixed batch/case/direction identities, opaque fixture IDs and counts,
bounded source/neutral/target/outside/protected metrics, fixed reason codes,
verdicts, and digests. Source paths or locators, raw media or pixels, masks,
landmarks, ROI/support geometry, private metadata, and transcripts must never
be persisted. This owner-local still-image validation is not naturalness,
physical-device or population evidence and does not authorize commercial use,
packaging, shipping, launch, release readiness, or distribution. It does not
change the 62 public parameter fields, five presets, 75 renderer cases, either
public still-image facade signature, or the CPU-reference/selectable-GPU
contract; local-retouch effects remain outside this repair scope.

## Generate Gallery

```bash
python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery
```

Gallery generation opens the repository, `example-images`, input, output, and every staging directory through no-follow descriptors, with immediate close ownership for every acquired descriptor. It rejects a source above 16 MiB before creating its destination, performs bounded descriptor-relative copying into exclusive destinations, and rejects identity, size, modification-time, or change-time drift before publication. It then revalidates the staging snapshots and publishes the complete tree with an atomic descriptor-relative rename. If `gallery/` already exists, it is moved intact into `.gallery-quarantine/previous/`; no old-gallery entry is enumerated or deleted, so nested mount points and links are never crossed.

The quarantine is intentionally bounded to one slot. A later run fails closed while `.gallery-quarantine/` or `.gallery-staging/` exists and does not claim cleanup. After reviewing the preserved prior gallery, an operator may remove these ignored slots using an explicitly chosen out-of-band procedure and rerun the generator.

The gallery groups current cases under:

- `skin/`: `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, `skinCombo_0p50`
- `color/`: `brightness_plus0p25`, `contrast_plus0p25`
- `filter/`: `filter_softClean_0p50`, `filter_warmLight_0p50`
- `face-shape/`: `geometryBaseline_noop`, `faceShapeCombo_0p35`, `faceSlim_0p35`, `faceSmall_0p35`, `chinLength_plus0p30`, `chinLength_minus0p30`, `faceVShape_0p35`, `jawSlim_0p35`, `faceContourSmooth_0p25`, `templeFullness_0p25`, `cheekboneSlim_0p25`, `chinTaper_0p25`
- `eyes/`: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, `eyeTailLift_0p25`
- `eyes/` Phase 43 additions: `eyeHeight_0p25`, `eyeLength_0p25`, `upperEyelidLift_0p25`, `pupilSize_0p25`, `gazeCorrection_0p25`, `lowerEyelidDrop_0p25`, `eyeTilt_plus0p25`, `eyeTilt_minus0p25`, `innerCornerOpen_0p25`, `outerCornerOpen_0p25`, `eyeSymmetry_0p25`
- `eyebrows/`: `eyebrowYPosition_plus0p25`, `eyebrowYPosition_minus0p25`, `eyebrowThickness_plus0p25`, `eyebrowThickness_minus0p25`, `eyebrowLength_plus0p25`, `eyebrowLength_minus0p25`, `eyebrowSpacing_plus0p25`, `eyebrowSpacing_minus0p25`, `eyebrowHeadSpacing_plus0p25`, `eyebrowHeadSpacing_minus0p25`, `eyebrowTilt_plus0p25`, `eyebrowTilt_minus0p25`, `eyebrowPeakDefinition_0p25`
- `nose/`: `noseSlim_0p35`, `noseWingSlim_0p35`, `noseTipSize_plus0p30`, `noseTipSize_minus0p30`, `noseBridge_0p30`, `noseRootNarrowing_0p25`, `noseTipLift_0p25`
- `mouth/`: `mouthSize_plus0p35`, `mouthSize_minus0p35`, `mouthWidth_plus0p35`, `mouthWidth_minus0p35`, `smile_0p50`, `lipColor_0p50`
- `mouth/` Phase 39 additions: `mouthYPosition_plus0p25`, `mouthYPosition_minus0p25`, `mouthTilt_plus0p25`, `mouthTilt_minus0p25`, `mouthXPosition_plus0p25`, `mouthXPosition_minus0p25`, `lipPeakDefinition_0p25`, `lipPlump_0p25`

## Verify Outputs

Run the relevant helper against the same output directory, for example:

```bash
python3 .planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/output
```

Phase 29 eye output evidence uses:

```bash
python3 .planning/milestones/v1.6-phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output
```

Phase 31 nose output evidence uses:

```bash
python3 .planning/milestones/v1.7-phases/31-nose-renderer-output-evidence/check_nose_renderer_outputs.py --input example-images/input --output example-images/output
```

The Phase 31 helper requires 196/196 decoded same-dimension outputs, 30/30 portrait nose-vs-baseline comparisons, 6/6 positive-vs-negative `noseTipSize` comparisons, and representative no-face nose output presence.

Phase 33 mouth/lip output evidence uses:

```bash
python3 .planning/milestones/v1.8-phases/33-mouth-renderer-output-evidence/check_mouth_renderer_outputs.py --input example-images/input --output example-images/output
```

The Phase 33 helper requires 238/238 decoded same-dimension outputs, 30/30 mouth-geometry ROI comparisons, 12/12 signed-pair comparisons, 6/6 separate lip-color containment checks, and representative no-face extent.

Phase 43 remaining-eye output evidence uses:

```bash
python3 .planning/milestones/v1.11-phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

The helper discovers the live inventory before freezing exactly 55 cases × seven fixtures = 385 decoded same-dimension outputs. It gates eleven new cases in one fixed eye-local ROI at committed floors, proves positive/negative tilt polarity and nearest-neighbor family distinction, records six contour/pupil/symmetry-eligible portraits plus the explicit no-face safe-no-op pool, and keeps a self-tested dark-core centroid experiment separate from strict fixture acceptance. Automatic-gaze reduction is proven by the package-internal aggregate pupil-to-own-center evidence path; the retired RGB mirror score is not treated as gaze proof. Generated output and the exact 385-file gallery remain ignored and untracked. These are provisional public-facade output facts; Phase 44 owns final caps, exhaustive safety, boundary closeout, and exact promotion.

Phase 47 remaining-face output evidence uses:

```bash
python3 .planning/milestones/v1.12-phases/47-public-facade-face-output-evidence/check_face_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

The helper freezes exactly 59 cases × seven fixtures = 413 decoded same-dimension outputs. Four shared top-origin face regions use field-specific positive floors: contour `(0.10,0.92,0.28,0.82)` at `5000/15000`, temple `(0.10,0.92,0.32,0.80)` at `4000/18000`, cheekbone `(0.20,0.82,0.24,0.65)` at `3500/20000`, and chin `(0.33,0.70,0.24,0.62)` at `1000/3000` changed pixels / absolute RGB delta. Strict evidence passes 18/18 eligible visibility/locality comparisons, 49/49 fixed-neighbor distinctions, 6/6 ineligible portrait no-ops, and 4/4 no-face no-ops. The descriptor-safe gallery is an exact duplicate-free 413-file bijection; output and gallery remain ignored, untracked, and unstaged.

These are provisional public-facade saved-output facts only. Phase 48 owns final caps, exhaustive safety/transitions, exact four-row promotion, owner synchronization, and branch closeout.

Phase 51 eyebrow output evidence uses:

```bash
python3 .planning/milestones/v1.13-phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

The current contract has one active portrait, `e6.jpg`, and the separate `no-face-gradient.png` negative. The strict helper decodes exactly 72 e6 portrait outputs and reports thirteen no-face comparisons separately; the complete output and gallery inventories are each exactly 72 cases × two fixtures = 144 disposable PNGs. Fixed brow/protected regions pass 13/13 visibility/locality, 6/6 signed-direction, 21/21 family-distinction, 40/40 portrait-comparison, and 13/13 no-face gates. The baseline plus all thirteen actual eyebrow outputs were opened individually at original detail and passed the recorded direction/locality/family review in `51-EYEBROW-OUTPUT-EVIDENCE.md`.

Gallery publication places all thirteen cases under `gallery/eyebrows/{caseId}/`, requires exact renderer equality, and rejects retired `e1`–`e5` stems. Output, gallery, staging, and quarantine locations remain ignored, untracked, unstaged, and disposable. Phase 52 subsequently closed final caps, exhaustive safety/transitions, seven-row promotion, and branch `眉毛`; broader device/commercial/performance/packaging/shipping/launch-readiness claims remain out of scope.

Phase 36 remaining-nose output evidence uses:

```bash
python3 .planning/milestones/v1.9-phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

The helper discovers the live renderer and fixture inventories before requiring the current 36 × 7 = 252 matrix. It fully decodes 252/252 same-dimension outputs and separately gates 12/12 new-field-to-baseline portrait comparisons, 6/6 root-to-bridge comparisons, and 12/12 lift-to-both-signed-tip comparisons in the fixed nose ROI (x 25%-75%, y 20%-70%) at the frozen floors of 500 changed pixels and 2,000 absolute RGB delta. Both new no-face outputs preserve the 64 × 64 extent and are baseline-identical in the watermark-safe fallback region.

The values `0.25` in `noseRootNarrowing_0p25` and `noseTipLift_0p25` are the Phase 37-finalized exact SDK safety caps, not commercial calibration. Phase 36 owns the isolated public-facade output chronology; `37-NOSE-SAFETY-EVIDENCE.md` adds final exact-cap, exhaustive six-field degradation/transitions, exactly-once convergence, redaction, and active-source boundary evidence before the exact two-row and SDK-core branch promotion. That historical Phase 36 matrix contained 252 files. No Demo UI, device parity, subjective/commercial naturalness, optimized performance, packaging, shipping, launch readiness, broad parity, milestone-audit, archive, tag, or cleanup result is claimed.

Phase 39 remaining-mouth output evidence uses:

```bash
python3 .planning/milestones/v1.10-phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

The helper discovers the current 44-case renderer and seven fixtures before requiring the exact 44 × 7 = 308 matrix. It fully decodes 308/308 same-dimension PNGs and applies one fixed mouth ROI (x 10%-90%, y 40%-82%) with frozen floors of 1,000 changed pixels and 10,000 absolute RGB delta. Strict evidence passes 48/48 visibility, 18/18 signed-direction, 12/12 peak-independence, and 18/18 plump-independence portrait comparisons. All eight new no-face outputs preserve 64 × 64 and are baseline-identical across the fixed 2,048-pixel label-safe fallback.

The current gallery inventory is a duplicate-free exact bijection with all 44 renderer cases and publishes exactly 308 ignored, untracked regular PNGs. Phase 40 finalizes the new `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, and `lipPlump` values at exact `0.25` caps, adds exhaustive safety evidence, and promotes exactly five geometry rows. `白牙` remains future and branch-level `嘴唇` remains partial. This evidence does not claim Demo/device/commercial quality, performance certification, packaging, shipping, or launch readiness. Preserved quarantine/staging slots remain ignored and untracked.

## Phase 44 Eye Geometry Closeout

The unchanged renderer now has exactly 55 cases × 7 fixtures = 385 outputs. Strict live evidence passes 385/385 same-dimension decode, 66/66 visibility, 6/6 direct signed tilt, 60/60 semantic distinctions, 132/132 portrait comparisons, and 11/11 no-face no-ops. The post-`6e4704e` package aggregate proves pupil-to-own-center gaze reduction; image-only mirror evidence remains rejected.

Output, gallery, staging, and quarantine artifacts remain ignored and untracked. Exactly ten remaining eye geometry rows are promoted; `去脂` and `祛红血丝` remain future and branch `眼睛` stays `partial`. These automated outputs do not establish subjective naturalness, physical-device parity, commercial approval, optimized performance, packaging, shipping, or launch readiness.

## Phase 47 Remaining-Face Output Evidence

- The public renderer contains exactly 59 cases and one shared `BeautyEngine.processResult` call; four isolated cases use provisional `0.25`.
- A bounded strict helper accepts 413/413 regular, fully decoded, same-dimension PNGs with 16 MiB compressed, 4096 × 4096 dimension, and 64 MiB decoded budgets.
- Eligibility is fixed at 5/6 portraits for contour/temple and 4/6 for cheekbone/chin. Accepted signal is entirely inside the fixed watermark-safe face regions; excluded pairs are exact no-ops.
- All 18 visibility/locality, 49 fixed-neighbor, six ineligible-portrait, and four no-face checks pass.
- One descriptor-safe publication produced exactly 413 ignored, untracked gallery PNGs with an exact renderer/gallery bijection.
- The full aggregate record is `.planning/milestones/v1.12-phases/47-public-facade-face-output-evidence/47-FACE-OUTPUT-EVIDENCE.md`. Final caps, exhaustive safety, promotion, root owners, branch `脸型`, and release-quality claims remain Phase 48 or future work.

## Phase 48 Final Face Evidence

- Phase 48 retains the exact 59-case renderer and 413/413 public-facade output inventory. The unchanged strict gates pass 18/18 visibility/locality, 49/49 fixed-neighbor, 6/6 ineligible portrait, and 4/4 no-face comparisons.
- Final exact `0.25` caps and safety evidence authorize `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴`; `去双下巴`, `去双下巴 Pro`, and `发际线` remain future, so `脸型` stays `partial`.
- The exact 413-file gallery and all output/gallery/staging/quarantine paths remain ignored, untracked, unstaged, non-symlinked, and disposable.
- These automated artifacts do not prove device parity, subjective or commercial naturalness, optimized performance, packaging, shipping, launch readiness, or milestone audit/archive status.

## Phase 51 Eyebrow Output Evidence

- Exactly thirteen isolated public eyebrow cases expand the renderer to 72 cases without bypassing the single public facade/unified warp route.
- The sole active portrait `e6.jpg` contributes 72/72 decoded portrait outputs; thirteen no-face comparisons are separate, and the complete output/gallery inventory is 144 files.
- Frozen gates pass 13/13 visibility/locality, 6/6 signed directions, 21/21 semantic distinctions, 40/40 portrait comparisons, and 13/13 no-face no-ops.
- The baseline and all thirteen actual e6 eyebrow outputs were opened individually at original detail; the visual verdict passes direction, locality, protected-region stability, whole-spacing versus head-spacing, and thickness versus peak.
- The descriptor-safe gallery publishes exactly 144 ignored regular PNGs with thirteen `eyebrows` case directories and no retired portrait entry.
- Final caps, exhaustive safety, all seven row statuses, branch `眉毛`, device/commercial naturalness, performance, packaging, shipping, and release readiness remain Phase 52 or later ownership.

## Phase 52 Final Eyebrow Example Contract

- The guarded clean renderer/helper/gallery commands above remain authoritative and unchanged: one active `e6.jpg` portrait yields exactly 72 decoded portrait outputs, while thirteen no-face comparisons are reported separately.
- The output tree and descriptor-safe gallery are an exact 144-file two-fixture bijection. Frozen acceptance remains 13/13 visibility/locality, 6/6 signed direction, 21/21 family distinction, and 40/40 direct portrait comparisons.
- Fourteen actual images — the baseline and all thirteen eyebrow cases — were reopened at original detail after final-cap rendering and retain a PASS for direction, eyebrow locality, protected-region stability, whole-spacing versus head-spacing, and thickness versus peak.
- Phase 52 finalizes every eyebrow maximum at exact `0.25` and promotes exactly `上下`, `粗细`, `长短`, `间距`, `眉头间距`, `倾斜`, and `眉峰`, plus branch `眉毛`, at SDK-core scope. No renderer case, fixture, helper, generator, or strict calibration changes.
- Output, gallery, staging, and quarantine remain ignored, untracked, unstaged, and disposable. These artifacts do not prove UI/Demo completion, device parity, commercial naturalness, optimized performance, packaging, shipping, launch/release readiness, milestone audit, archive, tag, or cleanup.
