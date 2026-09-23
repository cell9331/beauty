---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-23T01:31:49Z
depth: deep
files_reviewed: 26
files_reviewed_list:
  - scripts/phase95-root-surface-native.swift
  - scripts/phase95-root-surface-generated.swift
  - scripts/phase95-root-surface-horizontal.py
  - scripts/phase95-root-surface-worker.py
  - scripts/phase95-root-surface-probe.py
  - scripts/test-phase95-root-surface-horizontal.py
  - scripts/test-phase95-root-surface-worker.py
  - scripts/test-phase95-root-surface-probe.py
  - scripts/phase95-root-sampler-correspondence.py
  - scripts/phase95-root-forward-span.py
  - scripts/phase95-root-regional-motion.py
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-SURFACE-MARKER-DEFINITION.md
  - BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift
  - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
  - BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift
  - BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift
  - BeautySDK/Tests/BeautyEffectsTests/Phase95RootSurfaceRepairTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautyMetalGeometryPassTests.swift
  - scripts/phase95-root-mesh-source-diagnostic.py
  - DESIGN.md
  - PRODUCT_SENSE.md
  - RELIABILITY.md
  - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
  - BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
---

# Root surface execution review

Current authorization and bindings are in the candidate12 revision appended below. The initial candidate10 scope and evidence are retained as history.

## Narrative Findings (AI reviewer)

No unresolved BLOCKER or WARNING remains in this bounded review. This grants execution eligibility for **one invocation of the reviewed probe containing two original-input evaluations**, each including candidate root, neutral and all three original siblings. It does not grant effect acceptance, anatomical accuracy, portrait admission, milestone completion, device qualification or distribution approval.

The operational object is the source-fixed dorsal surface-marker span defined in the bound definition. Integer-row projection is source-only; repeated raster locations retain their original parameter weights and are not independent observations. It is not a physical bone/base-width measurement.

### Mathematical and execution checks

The RGB inverse solver enumerates every feasible source cell; its hull only enlarges the feasible set. Monotone interval propagation and forward inversion preserve admissible explanations. Signed pair spans are averaged before full-image Q16 normalization. No pair is dropped after output inspection. Actual RGB supplies correspondences; provider fields supply applicability, search and secant bounds only.

The native path verifies canonical source raster bytes, manual canonical rendering against public Engine bytes, output transport bytes, and the one-byte RGB model residual throughout the crop. It rejects source-coordinate clamping. Root row supports are disjoint in Double arithmetic. Sibling identity requires both absence of effective sampling support in the complete original ROI and actual complete-ROI byte identity. Unsupported siblings fail closed.

The probe binds all source/test scripts, the semantic definition, the previously reviewed model/runtime payload and each fresh build's objects/modules/binary. It uses isolated network-denied Python children, bounded memory pipes and process-group cleanup. Persistent stdout is reconstructed from a fixed aggregate schema. Source coordinates, pixels and child transcripts are not review artifacts.

### Findings resolved during review

- **BLOCKER, resolved:** two render paths agreeing did not establish correspondence to transported source RGB. Canonical input/output raster checks and per-crop RGB model validation now close this gap.
- **BLOCKER, resolved:** sibling support exclusion used unadjusted radii although the renderer can clamp them. Geometry that the renderer would alter is now rejected or unsupported.
- **WARNING, resolved:** candidate byte identity discarded valid motion explanations in constant/periodic images. The shortcut was removed; identity remains available only through the separately admitted identity-role path.
- **BLOCKER, resolved:** a positive secant bound was applied without excluding sampler clamping. The measured crop now rejects out-of-domain unclamped coordinates.
- Float row-support arithmetic and definition/alias-weight discrepancies were also corrected before this snapshot.

### Validation and limits

Reviewer independently ran the final horizontal suite (12 tests), worker suite (6 tests), and aggregate protocol checks (11) under Python optimization: no failures, errors or skips. Earlier normal-mode execution passed horizontal 10 and worker 6 tests before the final two ambiguity regressions were added; the implementation agent separately reports final 12-test normal-mode success. A real isolated worker consumed a generated-only source packet and registered all 32 fixed parameters. The reviewer reproduced the removed identity shortcut's exclusion of 8/8 admissible constant-image motion positions.

The final orchestrator-run native calibration receipt is bound to exactly the current snapshot: 6/6 actual SDK generated cases measured, 432/432 truth positions enclosed, all 60 moving truth positions measured, all six signed mean intervals containing truth, zero unavailable cases. Maximum interval-midpoint error was 0.406 pixels; this is not an asserted error bound. The reviewer checked the recorded calibration's schema/conjunction and exact snapshot equality, but did not rerun SwiftPM or access the private input.

This review is conditional on runtime checks succeeding. It provides no prior knowledge that the original source/siblings will satisfy applicability or that the effect will pass. LK/ECC estimates and their empirical error floors are not admitted by this review.

## Snapshot

Input digest: `72efd2e35f6ba490a6c8a56c8f43d444214c046342342f05ed5fcd01fc802c6a`. The paired JSON includes the complete 431-file input snapshot, runtime binding and semantic-definition binding. Reviewed file hashes:

| File | SHA256 |
| --- | --- |
| `scripts/phase95-root-surface-native.swift` | `bb43a045b8709bc53ab8a58b56196cfdc0b74ec9744c1f220b44776a374b8dfb` |
| `scripts/phase95-root-surface-generated.swift` | `6f18d1d12f222b068f03c4e368a7a0b7471f8c105fa134e6cda928ef7355534d` |
| `scripts/phase95-root-surface-horizontal.py` | `af4b2b66f0bf56843a5a18cbefdebacf875bf77d6632fffe116ef6a17519a7de` |
| `scripts/phase95-root-surface-worker.py` | `ede22db79b1a369dcd36fc517818441c257cd6976c3da21982acc9f77a005f3b` |
| `scripts/phase95-root-surface-probe.py` | `4b812f94f91f487b7474e8758d2d89f7e5a5dc07114eab5cf05c49f78273aea1` |
| `scripts/test-phase95-root-surface-horizontal.py` | `c9a6ea9cce9e55df35cee2421185fe8f6b83b422eb6c5790ddf7b73f4366788d` |
| `scripts/test-phase95-root-surface-worker.py` | `fce8b2d45d5476aabd11a67de0792f48cd9d46d03c3409ad0ded5cd263766fab` |
| `scripts/test-phase95-root-surface-probe.py` | `bca74b7f36143e4f59447c600effcab56ad53a58b55c5a200dd083cf4763d221` |
| `scripts/phase95-root-sampler-correspondence.py` | `7f838e03bd78bd31075c35ed8c8049ba968bbf3b86785aa0048eab5c55fd4367` |
| `scripts/phase95-root-forward-span.py` | `0cfac9277c2efdbc47ec65f120c2a43f659d0a8d279e716940ed17051660fa2d` |
| `scripts/phase95-root-regional-motion.py` | `267902733e7a75b415ce5b80281c96a4297803cf5ead40191cda569905ab9141` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-SURFACE-MARKER-DEFINITION.md` | `c028df5f1f077fedc0753e5da4493da06ae56830a7d7bbba090e4d2b96c2fdd7` |

Reviewer: `independent-closeout-review-agent`. No implementation files or historical receipts were modified.


## Candidate11 production-repair revision — 2026-09-23T01:12:11Z

**Current disposition: clean, zero unresolved BLOCKER/WARNING.** The current paired JSON replaces the previous execution binding and permits one invocation containing two candidate11 original-input evaluations, each with all original siblings. Candidate10's actual failed observation remains historical evidence. This revision grants execution eligibility only, not effect acceptance or milestone completion.

The observed paired-eye path now places its source span from face/observed-nose dimensions, with eye room limiting radius instead of choosing the location. Source positions and radius are strength-independent; magnitude remains capped and no-fold admission still applies. The private optional row cutoff belongs only to the paired-root points and is preserved by value-copy admission. CPU and both Double sampler checks use the same integer row domain. Nil paths preserve their previous handling.

Two findings from this revision are resolved:

- **BLOCKER, resolved:** Metal serialization could discard the cutoff. The Metal adapter now rejects any non-nil cutoff with typed invalidInput before submission. Neutral recovery and eligible observed-eye geometry are tested. The retained shader was not changed.
- **WARNING, resolved:** the original 512/1024 tests did not establish nonvacuous cutoff coverage. The strengthened source-anatomy seam test covers 128/512/1024 and vertical pixel phases .49/.51/.99. In the 128/.99 case, an independent uncut sampler produces nonzero >2-byte changes on the first bridge row, while the actual row and subsequent bridge region remain source-exact. A fixed band above the seam changes and the independent inner marker still contracts, excluding an all-neutral pass.

The new generated material tests cover two independent inner markers, cap contraction, four strengths, neutral identity and both changed-pixel/RGB protection limits. Former wide stripes remain negative controls. The combined surface and Metal suites actually passed 8 tests, zero failures/skips (reported by the executing agents). The previously reported 41 focused tests also passed. Reviewer independently ran the extracted runtime protocol suite (5 tests) and aggregate protocol checks (11) under optimization, with no failures/errors/skips.

The runtime_snapshot extraction retains model, lock, isolated interpreter, installed-package inventory, wheel payload and executable-closure checks. The old snapshot still invokes its historical driver binding; only the new probe chooses the runtime-only component alongside the current full source snapshot. No historical pin was relaxed.

The recorded candidate11 actual-SDK calibration passes 6/6 cases, encloses 432/432 positions including all 72 moving positions, contains all six signed mean truths, and has zero unavailable cases. Reviewer revalidated its aggregate schema/conjunction. Since calibration, only the Metal reject guard, its test, strengthened surface test and three owner documents changed; the calibrated CPU renderer/provider, native/generated oracle, measurement code, runtime and semantic definition are identical. These changes do not invalidate the CPU calibration. Maximum interval-midpoint error 0.431 pixels is not an asserted uncertainty bound.

Current input digest: `9a618578e307edda161fa2f7a5357ced913dc252382a25af54517109e6e01596`; 432 bound input files plus runtime/definition bindings. Previous current review JSON SHA256: `0a499894e7221f7666afd8bccef581d1ef3da6468fe81122b7bf1836776348a0`. Additional/currently changed reviewed bindings:

| File | SHA256 |
| --- | --- |
| `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` | `661793b1e0a7fcc6c10466eb5ec0e65f5267f41fe55198f4bc59cba2414c82d7` |
| `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` | `50deef7fe6e6308e7819e55e086f3983933b9ef823b333575ddcf1dd4fa41629` |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | `2c18e4ad50f840a26998ab55558634ca3afe4a349a41c2bf3bce90a230b9b494` |
| `BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift` | `694398587f2ee9b835ce7041e94598386ad92079c4479a8b8ad534f27580c760` |
| `BeautySDK/Tests/BeautyEffectsTests/Phase95RootSurfaceRepairTests.swift` | `8d5cac5358cee6cf45c0e5d6cc3942b162028e962a64864ef916afb971bc2499` |
| `BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift` | `a9ffc8486af2f293e837e348fe50b0cae042bfc8e590d53f70f6f2ca7308dee5` |
| `BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift` | `50c600f44dee59103efd745f6d0e03e62d5946fb3a3988dd2f5450993d3c266b` |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalGeometryPassTests.swift` | `7b6794c0ceec8eda23497400c140042a04b759a3871ee8bacbd74c19b9bbe800` |
| `scripts/phase95-root-mesh-source-diagnostic.py` | `e27b22a8c45243779d48e0a09ea97a7c024ea3a3bb85904039de90f3ccbd26ea` |
| `DESIGN.md` | `a6bfab4b83e751e5ace582e1e9bcfed2fafe3b8280183d567c794425455b103a` |
| `PRODUCT_SENSE.md` | `235a2437702600bb8abb6dc7553ba2278f067ef7344bf8c976c7179156913f8a` |
| `RELIABILITY.md` | `370b3e4e66d109c3ddf356df424bdd2f14004fb3dacd97a191ec0ad0c6f1c2ee` |
| `scripts/phase95-root-surface-native.swift` | `f8d187129e3b14bb30d9f38d52d7b7bcb6e6a98cfeb2f724f5b03b78502c8a3c` |
| `scripts/phase95-root-surface-generated.swift` | `3850d52539f83b28017cda18551891d2c5a5373e9e4ab9afde4246278bd3d080` |
| `scripts/phase95-root-surface-probe.py` | `538a2686399029d8190b884eeffc5ecd6b32e2ac6ae5f57d41994a0e39b604ab` |

Reviewer performed no private-source access, image/model inference, implementation edit or historical observation rewrite.


## Candidate12: common Vision raster (2026-09-23T01:31:49Z)

No unresolved BLOCKER or WARNING remains in this bounded root execution revision. The current JSON permits one invocation containing two fresh source registrations and root/neutral/three-sibling evaluations; it grants no effect, root admission, or milestone verdict. Candidate11's actual failure remains preserved in its separate observation and is not reused as success.

The default detector now renders the actual CIImage extent through named-sRGB working/output color spaces and supplies that CGImage to Vision. It forwards the original orientation without transforming pixels or altering renderer input/mirror mapping. Raster creation rejects missing, nonfinite, empty, nonintegral, over-budget or mapper-size-inconsistent inputs with detectorUnavailable. The configured pixel budget is propagated to this boundary. This corrects a representation discrepancy instead of moving the frozen source ROI or subtracting a photo-specific pixel offset.

Independent static review covered the provider and new tests. Generated checks cover sRGB/P3/gray/alpha, all eight orientation values with both mirror flags, translated origins, actual Core Image rounding, declared-size mismatch and allocation bounds. The existing opt-in compares production source crest ownership with the independent original CG registration recipe; its row assertion was corrected during review to use the renderer's exact Double multiplication before floor. The implementation agent reports the final focused Vision suite **34 executed / 0 failed / 0 skipped**, exit 0, with existing opt-ins enabled. This reviewer did not access private images or execute their tests. No raw coordinates, pixels or child transcripts are retained here.

The existing generated sampler calibration remains applicable to its injected-geometry CPU sampler path: renderer, native RGB qualification, horizontal correspondence, worker, mesh runtime and dedicated surface definition are unchanged. The changed default detector is assessed by the new raster tests and source registration assertion; its actual effects still require the authorized evaluations. V4 closeout validator/driver/contract changes present in this snapshot are bound for identity only and are outside this root-only review; this receipt is not their final integration approval.

Current input digest: `1fb8633e876e3bfd7a645980dd58828d7f1a1675d007f6d4d65bb0e7b8d40283`. The JSON contains the complete file/runtime/definition binding. Reviewed delta hashes:

- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`: `18886938f8c96325b5ccb37e3450fb93c15399fe8108335a69779f01f9e765a9`
- `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`: `72d088fb45109d95f1557efc1b628532c374f0b0649b6cb00c9f730f7370e154`
