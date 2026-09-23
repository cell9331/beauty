---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-23T02:33:31Z
depth: deep
files_reviewed: 31
files_reviewed_list:
  - scripts/compare-face-feature-batches.swift
  - scripts/run-clean-65-portrait.sh
  - scripts/phase95-root-surface-batch.py
  - scripts/phase95-root-surface-batch-native.swift
  - scripts/phase95-root-surface-probe.py
  - scripts/phase95-root-surface-native.swift
  - scripts/phase95-root-surface-worker.py
  - scripts/phase95-root-surface-horizontal.py
  - scripts/phase95-root-mesh-source-diagnostic.py
  - scripts/phase95-root-mesh-source-worker.py
  - scripts/phase95-root-sampler-correspondence.py
  - scripts/phase95-root-forward-span.py
  - scripts/phase95-root-regional-motion.py
  - scripts/phase95-closeout-evidence.py
  - scripts/phase95-genuine-gate.py
  - scripts/test-phase95-closeout-evidence.py
  - scripts/test-phase95-root-surface-batch.py
  - scripts/test-phase95-root-surface-probe.py
  - scripts/test-phase95-root-surface-worker.py
  - scripts/test-phase95-root-surface-horizontal.py
  - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
  - BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift
  - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
  - BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift
  - BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift
  - BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/Phase95RootSurfaceRepairTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautyMetalGeometryPassTests.swift
  - scripts/check-metal-feature-passes.sh
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
---

# Surface-v4 implementation review

## Narrative Findings (AI reviewer)

No unresolved BLOCKER or WARNING remains. This review carries forward the bounded source, sampler, privacy and production reviews recorded in 95-ROOT-SURFACE-EXECUTION-REVIEW.md and completes the actual65 integration review. The initial implementation receipt bound input digest `9f2bd14ec386184d07f5915c35c5d2baa85b135cc7dba86aabcf1ab3cb73821b`, including the newly created measurement admission. It is not a full-closeout result or independent final goal verdict.

Resolved findings: (BLOCKER) the new batch pipe formerly killed only its leader and could leave detached descendants; it now acknowledges an owned group, uses nonblocking bounded I/O, handles outer cancellation, keeps build/native/model/worker children in that group, and applies bounded group cleanup. (WARNING) Swift's upper integer endpoint now matches the strict consumer's exclusive +2³¹ bound. (WARNING) portrait contract_id is now checked against the original registration digest in both full-closeout and finalization. The obsolete comparator pin was replaced by current snapshot and fresh-build identity checks; compile-only also verifies final stability.

The comparator registers the source before scoring outputs. The native helper receives the actual batch RGB, qualifies the sampler without producing replacement effect images, and rejects mismatched source/raster/ROI geometry. The same frozen cohort supplies five interval comparisons; six crop hashes and intervals participate in repeated stable payloads. Scalar root margins are reconstructed from those intervals. Original target, outside and all protection predicates remain calculated from actual full batch pixels. Strict consumers reject old metrics, mismatched identities, forged scalar margins, malformed quantities and incomplete protections.

Measurement admission is limited to the source-fixed inner dorsal surface span definition, not bone width, absolute anatomical boundaries, arbitrary photos or model accuracy certification. All 31 admitted source parameters retain their fixed weights. Runtime/model, definition, original registration, cohort commitment and all 13 implementation hashes were checked. Candidate12's two stable original observations had interval [260,373] Q16 for source, neutral and all three siblings, with zero outside/protected changes; source-related production/measurement inputs and runtime remain unchanged. Subsequent integration changes were reviewed separately rather than relabeled as an already executed batch.

Validation: reviewer independently ran optimized evidence 19/19 and batch 16/16 tests, including generated real child failure controls. Implementation agent reports Swift comparator 624 mutation checks, including nine process controls and three integer endpoints, passed; final cleanup checks allow bounded asynchronous signal delivery. The current final calibration receipt exactly matched the pre-admission source snapshot: 6/6 measured cases, 432/432 points enclosed, all 72 moving points covered, zero unavailable and zero mean interval failures. The 431 millipixel maximum is interval-midpoint error, not a universal error bound. Earlier focused Vision34 and combined surface/Metal8 tests passed. No private image/model execution was performed by this reviewer.

Only the admission file changed between verified calibration snapshot and implementation binding. Actual65/full no-skip execution and a distinct final goal review remain required; these receipts do not manufacture that evidence.

## Reviewed file hashes

- `scripts/compare-face-feature-batches.swift`: `90e3eabddab6192d5da7e633acd90fbdf1dd5257ad63cdc64d46328c5d3fa8e8`
- `scripts/run-clean-65-portrait.sh`: `1f35363b6b55db037aac5c3df24e5a80013e7f6e8a574392600b1106dbc5022d`
- `scripts/phase95-root-surface-batch.py`: `1cb96dfdcfdedba81972843c684f6eaf353ec633f3815820a7b90d811d803353`
- `scripts/phase95-root-surface-batch-native.swift`: `f763775010bb3b71bef5dd95305acbe29bceef93c8396d79e3e1d22b1ae082c0`
- `scripts/phase95-root-surface-probe.py`: `44b06315b2e01d24dac0ec721a9d97d9beb9750bba31558874806e82c176d967`
- `scripts/phase95-root-surface-native.swift`: `f8d187129e3b14bb30d9f38d52d7b7bcb6e6a98cfeb2f724f5b03b78502c8a3c`
- `scripts/phase95-root-surface-worker.py`: `ede22db79b1a369dcd36fc517818441c257cd6976c3da21982acc9f77a005f3b`
- `scripts/phase95-root-surface-horizontal.py`: `af4b2b66f0bf56843a5a18cbefdebacf875bf77d6632fffe116ef6a17519a7de`
- `scripts/phase95-root-mesh-source-diagnostic.py`: `e27b22a8c45243779d48e0a09ea97a7c024ea3a3bb85904039de90f3ccbd26ea`
- `scripts/phase95-root-mesh-source-worker.py`: `aee0bad28fd0463c2d18b4277d66fe77013918d327f749390057eaaad979f0cb`
- `scripts/phase95-root-sampler-correspondence.py`: `7f838e03bd78bd31075c35ed8c8049ba968bbf3b86785aa0048eab5c55fd4367`
- `scripts/phase95-root-forward-span.py`: `0cfac9277c2efdbc47ec65f120c2a43f659d0a8d279e716940ed17051660fa2d`
- `scripts/phase95-root-regional-motion.py`: `267902733e7a75b415ce5b80281c96a4297803cf5ead40191cda569905ab9141`
- `scripts/phase95-closeout-evidence.py`: `049fef372933f42df2bec3821cab6a4dd6c2972847b1d27c8c12c5dc45bf285c`
- `scripts/phase95-genuine-gate.py`: `bc4466141f8d02840deb18928eca63e9451f9fe56898dd698acc17c691a9de0e`
- `scripts/test-phase95-closeout-evidence.py`: `71ebf7a9aaf073b1a4e2ff279b8705039cb3dac5631fbb3ef1dff69277c42494`
- `scripts/test-phase95-root-surface-batch.py`: `f5e1a4b3e765fc77c987aa0710188bd6b30fc4c989305de57c6c7d086b8b3601`
- `scripts/test-phase95-root-surface-probe.py`: `bca74b7f36143e4f59447c600effcab56ad53a58b55c5a200dd083cf4763d221`
- `scripts/test-phase95-root-surface-worker.py`: `fce8b2d45d5476aabd11a67de0792f48cd9d46d03c3409ad0ded5cd263766fab`
- `scripts/test-phase95-root-surface-horizontal.py`: `c9a6ea9cce9e55df35cee2421185fe8f6b83b422eb6c5790ddf7b73f4366788d`
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`: `18886938f8c96325b5ccb37e3450fb93c15399fe8108335a69779f01f9e765a9`
- `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift`: `661793b1e0a7fcc6c10466eb5ec0e65f5267f41fe55198f4bc59cba2414c82d7`
- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift`: `50deef7fe6e6308e7819e55e086f3983933b9ef823b333575ddcf1dd4fa41629`
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`: `2c18e4ad50f840a26998ab55558634ca3afe4a349a41c2bf3bce90a230b9b494`
- `BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift`: `694398587f2ee9b835ce7041e94598386ad92079c4479a8b8ad534f27580c760`
- `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`: `72d088fb45109d95f1557efc1b628532c374f0b0649b6cb00c9f730f7370e154`
- `BeautySDK/Tests/BeautyEffectsTests/Phase95RootSurfaceRepairTests.swift`: `8d5cac5358cee6cf45c0e5d6cc3942b162028e962a64864ef916afb971bc2499`
- `BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift`: `50c600f44dee59103efd745f6d0e03e62d5946fb3a3988dd2f5450993d3c266b`
- `BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift`: `a9ffc8486af2f293e837e348fe50b0cae042bfc8e590d53f70f6f2ca7308dee5`
- `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalGeometryPassTests.swift`: `7b6794c0ceec8eda23497400c140042a04b759a3871ee8bacbd74c19b9bbe800`


## Accounting correction and current review (2026-09-23T02:18:06Z)

No unresolved findings. The sole normative/code difference from the initial reviewed snapshot is `scripts/check-metal-feature-passes.sh`: expected focused count 34 → 35. Independent source inventory confirms 35 unique methods: Color 6, Geometry 5, Backend 9, LocalRetouch 6, Runtime 9. The new observed-root Metal rejection/recovery method accounts for the increment; failure and skip checks are unchanged. Script SHA256: `93f62842682ad370a1e277b473f5a557e3c557c98afb19e7aed1876e812250bc`.

The executor reports the complete archive-first precheck passed **937 executed / 0 failed / 0 skipped**, all eight opt-ins exactly once, with equal before/after snapshot `07d4ced97a806e57e9e6a332323062dad14e9fba6076f173f9b04cda6ee16d98`. The first full-closeout already completed the actual twice-run65 v4 evaluation before stopping at the stale Metal count; its immutable observations remain separate. This accounting repair does not reuse that interrupted run as completed closeout.

The prior implementation-review JSON is preserved byte-for-byte as `95-INDEPENDENT-REPAIR-REVIEW-v1.json`. Current review binds `07d4ced97a806e57e9e6a332323062dad14e9fba6076f173f9b04cda6ee16d98`; root admission and measurement identity `c195c36885785d770034c9ae59c2a6493ca11d20a517fb82973b76e654314c96` remain unchanged. Final full-closeout must execute all stages at this identity, followed by distinct goal review and finalization.


## Cancellation self-test synchronization (2026-09-23T02:33:31Z)

No unresolved findings. Independent comparison with the admitted comparator bytes confirmed the sole normative code change is three cancellation-test synchronization edits. The optional observation callback is synchronous and unused by production calls. The generated child installs its SIGUSR1 handler before acknowledging readiness; after observing the complete leader acknowledgement, the test sends SIGUSR1, causing the child to send a real SIGTERM to the parent. A new assertion requires that trigger. The original timeout, interrupted verdict and non-executing leader/descendant cleanup assertions remain. No transport deadline, production cleanup, image qualification, pixel measurement or source-registration rule changed.

The implementation agent reports six serial and six concurrent managed self-tests passed, each with 624 checks. Current-source generated calibration was independently schema-checked and matched the complete pre-refresh snapshot: 6/6 cases, 432/432 point enclosures, all 72 moving points covered, zero unavailable/mean failures. No private source was accessed for this refresh. The fixed 31-pair source registration, definition and verified runtime remain unchanged.

Prior JSON bytes are preserved exactly in `95-ROOT-MEASUREMENT-ADMISSION-v1.json` and `95-INDEPENDENT-REPAIR-REVIEW-v2.json`. Only the comparator member of the 13-file implementation identity changed, to `395ff8cab53a5c4a3f52c8653ee5b74cb3a26a904999f522a6087e4254ad7251`. Current measurement identity is `799d7b69c11d691ce2193a61dbdcf44b8c15d0b525bd5ed95ca6bc0f79eb0f17`; current implementation review binds `56d33c8d9ddfbd6899287feeac501139d6ea1bac05250ca8982fa861482ed6f0`, including refreshed admission. Both strict validators pass. Actual all-stage closeout and distinct goal verification are still required at this final identity.
