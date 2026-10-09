# A-2026-10-09-mediapipe-sdk-integration

| Field | Value |
| --- | --- |
| Status | `completed` |
| Owner | Codex / project owner |
| Started | 2026-10-09 |
| Scope | Integrate pinned MediaPipe iOS 1.1.0 Face Landmarker into the existing BeautySDK detection/effect pipeline; retain macOS Vision. |
| Source Request | Owner: “把这个接入到BeautySDK里吧”, following the verified independent iOS probe. |
| Current Step | Completed SDK integration and scoped native/macOS verification. |
| Verification Policy | Detection/mapping unit tests, native iOS SDK consumer and repeat/no-face/recovery checks on the reused single simulator, complete archive-first SwiftPM gate. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Define scope | `completed` | Default iOS MediaPipe; macOS Vision; synchronous image mode, existing cadence/serialization; no app sources, new beauty algorithms, automatic segmentation or external distribution. |
| Implement | `completed` | Official Common/Graphs/Vision 1.1.0 binary URLs and SHA-256; pinned float16/1 model and Apache-2.0 notices; existing geometry/local-support handoff. |
| Verify | `completed` | Full SDK gate 1083/0/0 with 9 opt-ins; native iOS 23/0/0, including 14 SDK-specific tests. |
| Record outcome | `completed` | Architecture/design/security/reliability/product/quality, dependency gates, license provenance, native-test source/setup and current Vision limitation updated. |

Decisions:

- Current owner authorization admits this specific SDK dependency/model; the earlier download-only probe boundary no longer limits this implementation.
- All inference stays local. Dense points and the facial transformation matrix remain package-only, request-local and absent from public results/logs/persistent evidence.
- Default image mode avoids timestamp or cross-frame tracking contracts. Initialization can be reused, observations cannot. Failure abstains through existing detection reason codes without a second detector retry.
- The existing bounded effect tests retain their original meaning. Detector integration does not qualify new beauty effects, general portrait accuracy or device performance.

## Implemented behavior

- The default `BeautyEngine` selects MediaPipe on iOS and Vision on macOS;
  public initializers, 11 configuration fields and 77 parameter fields remain
  unchanged. Existing Vision-specific injection fixtures retain their package
  alias. There is no fallback inference after MediaPipe failure.
- Three official iOS 1.1.0 binary targets have fixed URL/SHA-256 and iOS-only
  Detection dependencies/linker flags. No Audio/Text/Retrieval/Decision runtime
  or remote source package is added. Local-path consumption actually linked,
  initialized the graph and loaded the SDK's model bundle in a native host.
- The official float16/1 model is bundled in Detection. Size 3,758,596 and SHA
  `64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff`
  are checked at task initialization. Source/license/model-card provenance is
  owned by `BeautySDK/ThirdParty/MediaPipe/README.md`; upstream LICENSE retained.
- CPU image mode reuses initialization, not observations. `reset()` releases
  the task; neutral/disabled/interval-skipped calls do not run it. Native face
  budgets over 32 abstain before C++ allocation, with ordinary recovery.
- EXIF plus explicit input mirroring are applied to detector pixels once.
  Preview mirroring does not change those pixels. Mesh points already live in
  the upright image grid and bypass the Vision coordinate mapper.
- All 478 points must have finite bounded x/y and finite z. Ordered subsets
  supply eyes/iris centers, eyebrows, nose, lips, lower contour and median.
  Existing effects consume actual mesh nose/lip/contour points with existing
  regional plausibility gates. No new beauty algorithm or 3D warp is added.
- The iOS result bridge copies column-major MatrixData, while 1.1.0's element
  accessor indexes it as row-major. The SDK explicitly transposes the packed
  data before homogeneous-row and determinant validation. Native positives
  prove that valid transforms survive this bridge. Invalid pose alone does
  not erase valid mesh support. Blendshapes are disabled in SDK inference.
- Only aggregate mesh-count/pose-availability metrics enter still-image results.
  Raw points/pose, pixels, masks and private fixture locations are not persisted
  in tracked evidence or public diagnostics.
- Five retained backend gates now use a shared fixed dependency validator;
  no other remote/path/binary dependency is admitted. Its 11 negative mutations
  and the backend-neutral self-test's dependency mutations pass. The neutral
  self-test copies only source inputs, avoiding full build-tree duplication.

## Executed verification

| Check | Observed result | Scope |
| --- | --- | --- |
| `swift test --package-path BeautySDK --filter MediaPipeAdapterTests` | 7 tests, 0 failures, 0 skips | Bundled bytes/SHA and corruption, exact 478-point validation, pose rejection, redaction, topology mapping, all 8 EXIF directions × 2 mirror settings, raster bounds/scale. |
| Native SDK/library build | Exit 0 | iOS simulator arm64 with pinned runtime modules and Swift 6 adapter. Later host tests build/link the final SDK revision. |
| External native host full suite | 23 tests, 0 failures, 0 skips; exit 0, independently confirmed by result-bundle summary | 9 original probe + 7 adapter + 3 native negative/recovery/budget + 4 SDK mesh/consumer tests. |
| Native SDK positives | Two authorized local portrait IDs each return usable face, 478 points and valid 4×4 pose; eye/brow/face support and real nose/lip/contour paths admitted | Two fixed inputs, not an independent annotated accuracy benchmark. |
| Public `BeautyEngine` pixels | Face geometry reaches actual output; dimensions retained; same nose-root input over 20 calls has exact decoded output equality; no-face then valid and reset then valid recover exactly | CPU image mode, no device-speed claim or all-effect qualification. |
| Cadence/disabled/invalid input | Skipped/disabled/no-face calls have no reused mesh metric and preserve applicable source pixels; invalid raster and budgets 33/Int.max abstain then recover | Existing synchronous facade semantics. |
| Dependency validator / backend-neutral self-test | 11 negative dependency mutations rejected; complete neutral self-test passed | Altered hash/origin/version/platform/owner, extra source/binary use rejected; retained backend predicates preserved. |
| `bash scripts/run-no-skip-swiftpm.sh` | Exit 0; **1083 tests / 0 failures / 0 skips**, 9 opt-ins; full XCTest 408.435s | Archive-first, boundary self-test/live check, image storage, historical binding, backend/runtime/configuration/parity, local consumer, CPU/fixture pixel oracles and complete macOS SwiftPM suite. |
| Backend parity accounting | metal_available=1, metal_unavailable=0, parity_executed=1, focused_tests=14 | Existing macOS backend evidence, not MediaPipe GPU inference. |

The final native result is `probe-20261009-114047.xcresult` in the authorized
external lab's `Results` directory. The native positive suite source is tracked
under `IntegrationTests/MediaPipeIOS`; adapter/provider tests are under the SDK's
Detection test target. Fixtures remain outside the repository. The latest native
summary and an aggregate integration receipt remain local in the lab.

## Verification setup and repaired findings

The reused device was **iPhone 15 Pro / iOS 17.5**,
UDID `2CE927C9-9303-4A9B-9C03-F28C42045186`, with Xcode 26.6/SDK 26.5.
No device/runtime was created or reset. Tests used one explicit destination,
parallel testing disabled, maximum concurrent destinations 1. The task released
its temporary simulator lease after verification; device/app state remains.

The original SDK native whole-package scheme also builds the AppKit renderer,
so it cannot serve as an iOS test entry without unrelated CLI changes. The
existing authorized outside-repository project was reused to select the SDK
library, compile the actual tracked native test sources and run the fixtures.
No application source or lifecycle was introduced into the repository. Setup
is documented in `IntegrationTests/MediaPipeIOS/README.md`.

Initial binary resolution timed out; the previously downloaded official archives
were rechecked against their fixed hashes and reused through SwiftPM's standard
artifact cache. No checksum or origin check was bypassed. Initial native positive
pose failures exposed the layout issue above; neither matrix validation nor the
positive expectation was weakened. The final suite includes the corrected bridge.
Legacy gates' blanket dependency prohibition was replaced by exact admission of
this newly authorized scope; their other backend/parameter/resource predicates
remain enforced.

Stable native host build directory: `/private/tmp/beauty-mediapipe-lab/Build`.
The SDK's `.build` and valid native build outputs are retained for incremental
reuse; historical frozen `.build` evidence is untouched. Full native artifacts
and intermediate troubleshooting outputs remain in the external lab, not in
tracked evidence. Raw media/landmarks/matrices/private paths were not added to
completion records. No commit, push, physical-device install or external distribution was
performed by this integration task.

## Limits

This completes dependency/model/detector integration and its scoped engineering
checks. It does not claim arbitrary portrait/pose/occlusion accuracy, requalify
all visual effects against MediaPipe support, implement automatic segmentation,
reopen terminated EYE/SEG objectives, or establish physical-device latency,
thermals/battery/endurance/commercial/distribution readiness. The old simulator
Vision defect is not internally repaired; the default iOS route no longer uses
that provider. Adjacent owner editor installation/rebuild was not part of this
request. The independent lab and caches remain available for follow-up use.
