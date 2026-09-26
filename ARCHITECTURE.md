# ARCHITECTURE.md

## 2026-09-27 short-face proportion control

`faceShortening` follows the existing public parameter, effect resolver,
face-shape provider, and shared CPU/Metal geometry point path. It emits two
bounded points for a selected face with valid contour and a sufficiently tall
bounding box. No new detector, shader, target, backend, or model is added.

## 2026-09-27 texture resource admission

The existing texture pipeline keeps its CPU-owned implementation and shared
CPU/Metal-selected output route. A package texture budget is checked at the
public decoded, encoded-declaration and pixel-buffer facades and again at the
backend request boundary. No new detector, mask, shader, model, target or
backend is introduced.

## 2026-09-27 dense geometry capacity route

The public still-image facade checks the aggregate selected-face point count
before submitting to the retained Metal executor. A plan exceeding its
256-point uniform capacity runs through the existing CPU reference executor
with the same immutable plan, request-local observation and composed carrier.
The Metal executor and shader remain strict and unchanged; construction and
runtime errors are not retried. The public pixel-buffer path has no selected
face support and retains its existing backend selection. A fixed aggregate
result metric reports the capacity route, without exposing point coordinates.

## 2026-09-27 whole-face image-plane tilt

`wholeFaceTilt` follows the existing public parameter, resolver, face-shape
provider and unified CPU/Metal geometry route. Four bounded cardinal points
rotate the selected face region around its validated bounds center. No depth
input, model, shader, target or backend is added.

## 2026-09-26 result-local diagnostic events

`BeautyDiagnosticCode` and `BeautyDiagnosticEvent` are closed BeautyCore
values. `BeautyResult` carries their array with a source-compatible empty
default. The engine decorates successful public result routes after backend
execution; encoded input delegates to the still-image route and replaces the
same event list, so it is not duplicated. No logging target or persistent
diagnostic store is added.

## 2026-09-26 request-local performance metric

`enablePerformanceLog` adds one result-local numeric metric through the
existing `BeautyResult.metrics` boundary. The engine uses a monotonic clock
around each public `processResult` facade and retains no timer or input data
between requests. Encoded input includes byte preflight and decode. No new
target, logger sink, OS log, or persistence path is added.

## 2026-09-26 whole-face horizontal image control

The owner-local `wholeFaceXPosition` field follows the existing public
parameter, resolver, face-shape provider, and unified CPU/Metal geometry
point route. It adds one bounded point only when the selected face has valid
contour support; there is no new target, shader, depth input, or model.

## 2026-09-26 encoded still-image facade

`BeautyEngine.processResult(encodedImageData:metadata:parameters:)` decodes
one in-memory ImageIO frame after byte and declared-pixel preflight, then
delegates to the existing `CIImage` result path. It adds no target, external
file reader, decoder dependency, or effect/backend route.

## 2026-09-26 whole-face vertical image control

The owner-local `wholeFaceYPosition` field uses the existing parameter,
resolver, face-shape warp provider, CPU still-image and Metal geometry routes.
It adds one bounded control point from the selected request-local face bounds;
there is no new target, model, depth estimate, shader, backend, UI, or public
biometric payload. The SDK-owned renderer exposes both signed directions.

## 2026-09-26 explicit detection cadence

An indexed camera/video CIImage facade passes a scheduling decision into the
existing geometry route. Off-cycle calls resolve without selected face support
and report a fixed skip reason; no observation cache, tracker, new backend,
shader, or output format is introduced. Unindexed still-image calls keep their
existing detection path.

## 2026-09-26 preferred Vision detection size

`preferredProcessingSize` now reaches `VisionFaceDetectionInput` through the
existing engine/detector configuration path. Vision materializes a bounded
working raster only for detection; the source carrier and backend still render
at admitted original dimensions. No new target, cache, or output resize path
was added.

## 2026-09-26 skin texture path

`BeautyEffects` now owns one request-local luminance-detail transform for
`skinSmoothing` and `skinSharpen`. CPU still-image and pixel-buffer paths call
it before their existing color/geometry work; the Metal-selected executor
applies the same CPU transform to admitted RGBA8 bytes before its retained
passes. This preserves one effect definition without adding a Metal shader,
backend, model, public parameter, detector dependency, or target. The Metal
selection still runs through the existing runtime for other passes and output
conversion; it is not a claim that texture work executes on the GPU.
The facade snapshots `renderQuality` into the backend request; both backend
selections use the same 3×3, 5×5, or 7×7 CPU-owned spatial implementation.

## Current image acceptance input boundary (2026-09-24)

Image provenance does not select a different SDK architecture. Owner-authorized
generated portrait-like images may exercise the same public facade, source-fixed
effect oracle, and CPU/Metal paths as genuine portraits. Their absence as
genuine human photographs is not an implementation or milestone dependency;
see [image-effect acceptance](docs/IMAGE_EFFECT_ACCEPTANCE.md). Dated phase
architecture and signed evidence descriptions below remain historical.

## Phase 95 observed portrait support repair

The default still-image Vision provider renders a named-sRGB CGImage from the
admitted extent before its single landmarks request. Metadata orientation and
the canonical mapper keep their existing ownership. This aligns source anatomy
with the registered raster while preserving geometry-only output contracts.
The dense-mesh model and isolated Python measurement runtime are SDK-owned
validation tools only; they add no library target, model resource or dependency.

The existing Vision detection pass now carries package-only request-scoped nose
crest/contour through the canonical coordinate mapper into `FaceGeometry`.
Observed outer lips already owned by detection also reach geometry planning.
No target, dependency, public parameter, detector pass, backend or model is
added. Raw support has no Codable representation; reflection exposes counts
only. Root/bridge and negative mouth consume this support without changing
legacy sibling templates. Portrait qualification is determined by the current
registered 65-case gate and its execution-bound completion receipt.

> `beauty` 的当前 SDK-only 系统蓝图。参数与状态机见 `DESIGN.md`；effect/control
> status 见 `docs/SDK_EFFECT_TAXONOMY.md`。

## Current Post-Archive Audit Status

v1.21 adds one owner-local public scalar and route without changing target or
dependency direction: `upperEyelidFullnessReduction` enters the existing
canonicalize-once, detect/map-once, request-local per-eye semantic support,
immutable-source composition, and render-once still-image path. The owner
accepts the current bounded v4 result as provisional despite weak visual
quality. No trained model, resource, network, Metal pass, retained shader, UI,
or pixel-buffer route was added.
The final archive-first no-skip gate passed `816/0/0` with eight opt-ins
exactly once and zero skips.

v1.17 was historically completed and archived at `afb04b4`; its frozen
Phase-74 record reports focused `12/0/0` and full `765/0/0` execution on a
Metal-available package host. Those numbers remain historical. The current
archive-first closeout passed on 2026-08-18 with XCTest `776/0/0`, all eight
opt-ins exactly once, and `skipped_tests=0`.

The post-archive audit has repaired public non-up/mirrored raw-input metadata
compatibility (`53e8da1`), unavailable-host parity accounting (`d29b90a`), the
Metal geometry inline-binding overflow (`556499a`), and backend-result alpha/
extent enforcement. Geometry point arrays
are now request-local shared `MTLBuffer` resources; only the bounded scalar
point count remains inline. On an available host the parity branch reports
`focused_tests=13` and `parity_executed=1`; an unavailable host may pass its
typed availability gate only with `parity_executed=0` and never receives GPU
parity credit. Today's Metal-available branch recorded `metal_available=1`,
`metal_unavailable=0`, `parity_executed=1`, `focused_tests=13`, and
`unavailable_tests=0`. Current focused preflights passed backend-neutral
`24/0/0`, Metal runtime `42/0/0`, Metal feature `34/0/0`, configuration
`19/0/0`, and CPU reference `41/0/0`. Geometry safety parity now derives its
plan, control points, locality envelope, and rendered request from one immutable
face observation (`a577dd1`), with request equality and mutation-tested static
provenance checks.

All ten post-archive findings now have explicit dispositions. Local-retouch
bytes remain CPU-owned original-pixel/Q16 composition transported through an
identity Metal pass; Metal receives no masks or proposals. `.gpu` still images
require exact-opaque bounded non-extended RGB before detection and materialize
named-sRGB output. Metal still-image coefficients and lip math match the CPU
oracle within the pinned generated tolerance (`max <= 2`, mean `< 0.75`). A
`BeautyEngine` instance is intentionally non-`Sendable`; callers serialize all
access to one instance, while independent engines may run concurrently. These
bounded contracts do not claim transparent-input support, end-to-end GPU local-
retouch composition, shared-instance parallel safety, device performance,
commercial approval, packaging, shipping, launch, or release readiness.

## 1. Current Repository Contract

The repository contains one Swift Package rooted at `BeautySDK/`. SwiftPM library
and executable products, SwiftPM tests, and SDK-owned scripts are the only active
build/test/validation surfaces.

`BeautySDK` is an owner-only local component. Its Swift `public` declarations
exist so applications and tools controlled by the project owner can import the
facade and so the repository can test that boundary. They do not define a
third-party SDK offering or authorize package-registry publication, binary SDK
delivery, customer integration, App Store distribution, or model/weight
redistribution. Any future expansion beyond this owner-controlled environment
requires a new license, security, privacy, compatibility, and product review.

The retired application/UI trees are historical artifacts under
`archives/legacy-ui/`. They are not dependencies, source examples, current
requirements, or completion evidence. `FRONTEND.md` owns this redirect.

Current source/test inventory, excluding `.build`:

| Inventory | Count |
| --- | ---: |
| Swift source files | 79 |
| SwiftPM test files | 118 |
| Swift source lines | 20,867 |
| SwiftPM test lines | 46,441 |
| `BeautyConfiguration` stored fields | 11 |

## 2. Top-Level Invariants

| ID | Invariant |
| --- | --- |
| A1 | SDK targets contain no application pages, UI state, navigation, or protected-resource prompts. |
| A2 | Owner-controlled host code imports only the Swift-public `BeautySDK` product. |
| A3 | Dependency direction is acyclic and flows inward toward `BeautyCore`. |
| A4 | Detection/support values remain package-only, request-local, and absent from public diagnostics. |
| A5 | Geometry controls enter the existing single `BeautyGeometryEffectPipeline`; no per-feature warp path exists. |
| A6 | Local retouch canonicalizes once, detects/maps once, composes original-pixel proposals once, and fails locally. |
| A7 | Public parameters and presets remain backend-independent normalized values. |
| A8 | Resource lookup is centralized and validates logical identifiers rather than interpreting caller paths. |
| A9 | SwiftPM plus SDK-owned CLI/script validation is the sole current evidence boundary. |
| A10 | v1.16 historically retained CPU/Core Image behavior and pinned shader bytes without a public Metal API; the current package exposes `.cpu`/`.gpu` policy while keeping the Metal runtime package-internal and CPU as the reference. |
| A11 | The repository-owned consumer fixture and CLI observe only owner-local public-surface results, bounded identities, and typed aggregate outcomes; executable-internal failure seams are test machinery, not public API. |
| A12 | `BeautyResult<Output>` is `Sendable` only when `Output: Sendable`; public concurrency tests cover compile-time acceptance and a complete async task hop without making arbitrary payloads transferable. |
| A13 | Provisional upper-eyelid fullness reuses the existing local-retouch owner chain, preserves independent per-eye failure and collision-to-source behavior, and exports only a scalar—not support geometry, masks, or experimental types. |

## 3. Products and Targets

```text
BeautyCore
    ↑
    ├── BeautyResources
    ├── BeautyDetection
    └── BeautyRender
             ↑
BeautyEffects ───── uses package-only support and render primitives
    ↑
BeautySDK            public library product
    ↑
BeautyExampleRenderer public-product command-line consumer
```

| Target | Owns | Must not own |
| --- | --- | --- |
| `BeautyCore` | public/shared value models, errors, the 11-field configuration including `BeautyRenderBackend`, canonical carrier, redacted diagnostics | Vision implementation, application state |
| `BeautyDetection` | Vision detection, mapping, selection, package-only observed support | rendering, public raw geometry |
| `BeautyRender` | pass/pixel-buffer foundations, the retained bundled shader resource, and the package-internal `BeautyMetalRuntime` resource/synchronization owner | effect policy, application code, a public backend selector, or a claimed device backend |
| `BeautyResources` | bundled manifest/presets and identifier validation | arbitrary external path loading |
| `BeautyEffects` | resolver, safety caps, geometry/color pipelines, local-retouch providers/transforms/composition | public facade, application controls |
| `BeautySDK` | stable host facade, immutable `BeautyBackendFactory` selection, and request-local policy propagation | support-region export, application lifecycle |
| `BeautyExampleRenderer` | public-facade fixture input/output validation, deterministic 75-case discovery, and typed report aggregation | internal-target imports, public backend selection, product claims from generated media |

The package declares no remote dependency. New dependencies, models, resource
downloads, or network behavior require explicit security/licensing review.

The repository-owned consumer fixture under `IntegrationTests/` is a separate
SwiftPM executable with one local path dependency and only the public
`BeautySDK` product. It generates its own neutral input and observes real output
bytes/dimensions; it is an integration fixture, not a third-party consumer, SDK
target, distribution artifact, or public release promise.
`BeautyExampleRenderer` accepts the compatible `--input`, `--output`, `--case`,
and `--no-watermark` flags, requires a pre-existing output directory, and
preserves the exact 75-case catalog. Public backend selection is owned by
`BeautyConfiguration`; the CLI remains a public-product consumer and does not
create a second backend-policy surface.

The renderer writes a versioned privacy-safe JSON report only after each output
is non-empty, decodable, and dimension-preserving. Reports contain bounded
relative public input/case/output identities and reconciled requested,
succeeded, failed, and skipped counts. Unknown arguments/cases, duplicate
arguments/stems, missing or invalid paths, decode/render/encode/write/
validation/report failures, and incomplete output return typed non-zero
diagnostics. The render/encode failure injection is an executable-internal
test seam and is absent from SDK products, help, diagnostics, and reports.

## 4. Processing Paths

Still image:

```text
public BeautyEngine input
→ validate extent/orientation/color/limits
→ canonical opaque sRGB request carrier when local retouch is admitted
→ one optional Vision detection/mapping request when parameters require support
→ resolve normalized/capped effects
→ select immutable CPU or GPU policy through `BeautyBackendFactory`
→ CPU/Core Image or package Metal color + unified geometry + request-local local-retouch composition
→ public output, typed error, redacted warning/aggregate metrics
```

Pixel buffer:

```text
public BeautyEngine input
→ validate BGRA and dimensions
→ resolve face-independent supported work
→ create a distinct output buffer
```

The pixel-buffer path currently performs no detection-backed geometry or local
retouch. A future realtime or alternate-backend contract cannot be inferred from
existing foundation types or resource filenames.

## 5. Effect and Privacy Ownership

- `docs/SDK_EFFECT_TAXONOMY.md` is the exact 62-field taxonomy authority.
- `BeautyParameters` is the public contract; archived labels/layout never create
  a field, alias, provider, or product claim.
- `teethWhitening`, `scleraRednessReduction`, and provisional
  `upperEyelidFullnessReduction` are bounded opaque still-image controls. The
  `去脂` route reuses candidate-v4 package mechanics by explicit owner decision
  and cannot proxy through eye/brow movement, smoothing,
  generic/landmark-driven warp, or a Metal route.
- Raw masks, landmarks, pupil positions, tooth/eye geometry, candidate pixels,
  and private fixture locations are request-local implementation details.
- Generated output remains ignored and disposable; committed evidence is
  aggregate and privacy-safe.

The mandatory CPU reference layer is generated in-memory Swift RGBA8/sRGB
fixtures and target-local XCTest oracles. It covers exact neutral bytes,
alpha/extent metadata, geometry displacement/direction/locality, color
luminance/chroma/red/yellow-excess direction, local-retouch containment,
collision-to-source ownership, and request recovery. The generated preflight
(`scripts/check-cpu-reference-oracles.sh`) runs before private/native-Vision
opt-ins and the single full SwiftPM child; it records only aggregate pass
counts. The current CPU/Core Image implementation remains the permanent reference.

Candidate-v4 upper-eyelid mechanics added one package-only `BeautyEffects`
analysis stage between semantic support and original-pixel composition. Its
frozen private automation failures remain historical quality evidence. v1.21
does not rewrite those results; the owner accepts the same bounded mechanics as
a provisional current product path and carries its weak visual result as debt.

## 5A. Learned Upper-Eyelid Boundary

The learned/data boundary remains dormant. The current public facade route is
the no-model source-derived v4 path; there is no model resource, Core ML import,
dataset, weight, download, or training work. Restarting a learned replacement
requires a new explicit milestone and may not remove or silently change the
neutral/Codable/fail-closed public parameter contract.

Plan 80-19 adopts an on-device learned hybrid as the only implementation route
that may later qualify as visibly obvious `去脂`. The model is trained only from
owned data or data explicitly licensed for the project's actual owner-local,
non-distributed research/training use and predicts independent
per-eye applicability/uncertainty, soft support, bounded upper-lid soft-tissue
flow, and a low-frequency log-luminance residual. Apple Vision locates and
normalizes each crop but does not own the fullness semantic.

The learned flow is a narrow local-retouch exception, not a new public or
generic geometry pipeline: it cannot move eye contour/aperture, brow, lashes,
iris/sclera, or protected crease detail, and it does not modify retained
`Warp.metal`. `BeautyDetection` owns one mapped observation, `BeautyResources`
will own a checksum-pinned bundled Core ML resource only after license/model
admission, and `BeautyEffects` now owns request-local prediction request/result
types plus independent validation. Missing or invalid models and predictions
fail closed before any proposal. No learned route, Core ML import, or model
resource is active; the distinct v1.21 public route does not invoke this seam.

Any admitted model and compiled resource remain inside the owner-controlled
environment. A dataset restricted to non-commercial research may contribute
only to a correspondingly non-commercial local research candidate; it cannot
authorize commercial use or later distribution. Redistribution rights are not
a current entry gate because redistribution is prohibited by the project
contract, but any future scope change must re-audit every input and derived
weight before use.

The full data/model/runtime/qualification authority is
[`80-LEARNED-HYBRID-DECISION.md`](.planning/phases/80-genuine-evidence-and-qualification-gate/80-LEARNED-HYBRID-DECISION.md).

## 6. Archive Boundary

The only retained legacy ownership is:

- `archives/legacy-ui/BeautyDemo-v1.16.zip` plus manifest and digest record;
- `archives/legacy-ui/meituxiuxiu-v1.16.zip` plus manifest and digest record; and
- `archives/legacy-ui/README.md` as the safe access/recovery contract.

Archive verification is mandatory before SwiftPM closeout. Restored material
must stay in a new temporary directory. Reintroducing either retired root or an
active application/UI build dependency fails the SDK-only boundary.

## 7. Change Routing

- Public model: `BeautyCore`, `DESIGN.md`, `PRODUCT_SENSE.md`, compatibility tests.
- Detection/support: `BeautyDetection`, privacy/recovery tests.
- Effect: `BeautyEffects`, taxonomy, safety/containment/output evidence.
- Resource: `BeautyResources`, manifest/trust validation.
- Facade/orchestration: `BeautySDK`, public consumer tests.
- Repository gate: `scripts/`, `QUALITY_SCORE.md`.
- Historical UI request: archive-only review outside the repository.

## 8. Validation

```bash
swift build --package-path BeautySDK
swift test --package-path BeautySDK
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
bash scripts/check-swiftpm-consumer.sh
bash scripts/check-cpu-reference-oracles.sh
bash scripts/run-no-skip-swiftpm.sh
```

The generated CPU preflight must pass with nonzero focused execution and zero
generated skips without reading tracked portrait media. Private/native-Vision
fixtures remain ignored, explicit opt-ins and cannot lend success to the
generated suite. The final wrapper must preserve one bounded SwiftPM child output, execute all eight
documented opt-ins, and reject failure, skip, or zero execution. These gates do
not establish device, performance-budget, commercial, packaging, shipping,
launch, or release readiness.

The current public-result concurrency evidence is the three-test
`BeautyResultConcurrencyTests` suite (3/0/0): a `Sendable` payload result
survives an async task hop with its public fields intact, ordinary string
construction remains source-compatible, and a non-`Sendable` payload is kept
outside the positive contract. The v1.16 historical mandatory wrapper evidence
executes 702 tests with zero failures and zero skips. The Phase-71 historical
archive-first wrapper executed 728 tests with zero failures and zero skips.
Phase 73's historical archive-first wrapper executed 753 tests with
zero failures and zero skips, with all eight opt-ins exactly once and separate
`metal_available=1` / `metal_unavailable=0` classifications. The active
boundary self-test rejects a mutation back to unconditional generic sendability
before archive, consumer, generated-CPU, opt-in, or child execution.

## 9. Phase 70 Backend-Neutral Contract

`BeautyEffects/Backend/BeautyBackendContract.swift` is the single package-only
execution boundary for still-image and pixel-buffer backends. It admits a
validated input, explicit `BeautyInputMetadata`, the existing normalized
`BeautyEffectPlan`, request-local selected support, and—only for an admitted
still-image request—the canonical carrier and composition aggregate. The
boundary owns shared validation for dimensions, metadata, canonical extent and
alpha assumptions, containment, collision-to-source, and bounded failure
counts; it does not recreate detection, normalization, or composition policy.

`BeautyBackendDiagnostics` is aggregate-only: dimensions, alpha/extent flags,
and bounded unit, failure, collision, and changed-count values. It is
request-local and non-Codable. Typed terminal errors cross the boundary without
retry or fallback. `.cpu` is the only policy in this phase and the retained CPU
implementation remains the reference; Metal resources/passes and public
`.cpu`/`.gpu` configuration are later-phase work. The existing 61-field
`BeautyParameters`, five neutral presets, 74 renderer cases, target dependency
direction, generated CPU oracle, and archive-only UI/Demo boundary are
unchanged. This contract adds no public selector, new algorithm, or device,
performance, commercial, packaging, shipping, launch, or release claim.

## 10. Phase 71 SDK-Owned Metal Runtime

Phase 71 adds only an internal runtime mechanics boundary. `BeautyRender` owns
one package-internal `BeautyMetalRuntime` instance with its device, command
queue, pipeline, and request-local textures/buffers/command objects.
`BeautyEffects` owns the package-only `BeautyMetalBackend` executor that admits
the shared backend request and invokes exactly one bounded identity transaction.
`BeautySDK` remains unrouted publicly: no public `.gpu` or render-backend
selector is added to `BeautyConfiguration`, `BeautyParameters`, presets, or the
command-line consumer.

The exact request lifecycle is: validate dimensions and RGBA8 byte counts;
create bounded resources; encode the existing identity transaction; synchronize
and inspect terminal command status; materialize a matching output; then release
every request resource on both success and error. A host without a Metal device
returns typed `.metalUnavailable`; it never becomes a GPU success, CPU
fallback/retry, or parity claim. Diagnostics remain aggregate-only and omit
support, raster, texture, framework, geometry, and path details. The runtime
has no application, UI, or capture lifecycle dependency.

Phase 72 owns feature-pass implementation, Phase 73 owns public `.cpu`/`.gpu`
configuration and typed availability policy, and Phase 74 owns generated
CPU/Metal parity and no-skip closeout. CPU remains the reference. Phase-71
SwiftPM/static evidence preserves the 61-field parameter model, five presets,
74 renderer cases, dependency direction, archive boundary, and privacy
contracts; it establishes no simulator/physical-device, performance,
commercial, packaging, shipping, launch, or release-readiness claim.

## Phase 72 Metal Feature-Pass Ownership

The still-image facade remains the sole owner of local-retouch admission,
request-local support, and `BeautyLocalRetouchCompositionOwner`. It publishes
only the immutable composed `BeautyCanonicalStillImage` and six bounded
aggregate counters on `BeautyBackendRequest`. `BeautyMetalBackend` consumes
that CPU-composed carrier through an identity composed-retouch Metal pass, then applies mapped
color and geometry in CPU order; it does not receive providers, proposals,
support, masks, or source locators. Local-retouch-only output is therefore the
owner-produced carrier byte-for-byte, while mixed work starts from those same
immutable bytes. This is a GPU transport/ordering boundary, not end-to-end GPU
local-retouch computation. Geometry arrays are bound through a request-local
shared `MTLBuffer`, including payloads beyond Metal's 4 KiB inline limit; the
bounded scalar point count remains inline and cleanup is deterministic. Public
backend configuration is covered by Phase 73; Phase-74 parity evidence remains
historical, while the bounded post-archive remediation closeout is current and
green at `776/0/0`.

## Phase 73 Public Backend Configuration

`BeautyCore.BeautyConfiguration` owns the public `renderBackend` field, whose
exact two cases are `.cpu` and `.gpu`; it is execution policy and does not alter
the 61-field `BeautyParameters`, five neutral presets, or 74 renderer cases.
Missing and legacy configuration keys decode to `.cpu`, and a new
configuration defaults to `.cpu`. `BeautySDK.BeautyBackendFactory` performs
immutable construction and request-local policy propagation: explicit `.cpu`
uses the permanent CPU reference, while explicit `.gpu` uses the package Metal
runtime. If Metal is unavailable, the request terminates with typed
`.metalUnavailable`; it never reports GPU success or silently falls back to
CPU. Package-only injection seams are test-only.

Historical Phase 73 evidence is aggregate-only: configuration focused `16/0/0`, runtime
focused `34/0/0`, and the full archive-first no-skip wrapper `753/0/0`, with
eight opt-ins exactly once and `metal_available=1` / `metal_unavailable=0`.
Phase 74 owns generated CPU/GPU parity and SDK-only closeout. No UI/Demo,
simulator or physical-device, performance, commercial, packaging, shipping,
launch, or release-readiness claim follows from this configuration evidence.

## Phase 74 Historical CPU/GPU Parity and SDK-Only Closeout

The current package retains CPU/Core Image as the permanent semantic reference
and routes the same normalized plans and request-local carriers through Metal.
The archived Phase-74 generated SwiftPM fixtures compared input kind, dimensions, alpha, extent, named
sRGB metadata, exact neutral bytes, and explicit active tolerances (maximum
channel delta `8`, mean RGB `< 5.0`). Safety coverage checks CPU-owned
containment, protected/outside bytes, collision summaries, no-face/degraded
support, and smallest-unit failure isolation; bounded repetition/concurrency
proves request-local determinism.

The mutation-tested parity gate runs once in archive-first order after
configuration and before consumer, CPU-oracle, opt-in, and full-child stages.
Historical archive evidence is focused `12/0/0`, full SwiftPM `765/0/0`, eight opt-ins
exactly once, and separate `metal_available=1` / `metal_unavailable=0`.
The repaired current gate gives only its available branch GPU parity credit
(`focused_tests=13`, `parity_executed=1`); unavailable Metal remains typed
`.metalUnavailable`, reports `parity_executed=0`, and cannot lend success to
CPU or GPU parity. The current bounded contract resolves the audit findings but
does not turn the historical matrix into transparent-input, end-to-end GPU
local-retouch, shared-instance parallel, or release evidence. UI/Demo,
simulator/device, performance, commercial, packaging, shipping, launch, and
release-readiness remain excluded.

## Phase 91 Independent Gaze Correction Ownership

The request path remains within existing targets. `BeautyDetection` supplies
observed per-eye support; `BeautyEffects` maps each valid side into an internal
gaze-only pupil channel while preserving the paired `pupilSize` channel.
`EyeWarpProvider` selects zero, one, or two sides independently, proves strict
simple-aperture containment and half-clearance radius ownership, and emits one
bounded point per eligible eye. `BeautyEffectResolver` creates the six-field
aggregate only after final conflict resolution and exact point reconciliation.

`BeautySDK` carries those already-redacted metrics through the existing result
path. `BeautyExampleRenderer` may place them only on the matching successful
gaze output unit. The SDK-owned comparator binds schema, input, case, output,
backend, and aggregate algebra before using minimum Q16 for direction; source
and neutral target signal, sibling distinction, locality, and protected pixels
remain image-derived mandatory gates. The runner consumes both temporary
attempt reports, verifies their deletion, and publishes only aggregate status.

This flow adds no public type, target, dependency, renderer case, model, data,
network path, UI, realtime route, or GPU behavior. Exactly 62 fields, five
presets, 75 renderer cases, both still-image facades, CPU reference,
selectable `.cpu`/`.gpu`, terminal `.metalUnavailable`, and retained
`Warp.metal` remain the architecture boundary. Phase 95 owns portrait
publication and the full no-skip milestone gate.

## v1.23 FACE-01 Still-Image Ownership

`BeautyEffects` owns the new request-local `FaceContourLateralRuns` and
`FaceContourSubpixelRefiner` internals. The CPU geometry pipeline and the
selectable Metal still-image backend call the same immutable-source RGBA8
refiner before their existing warp. The point provider continues to own the
named FACE-01 control field and fail-closed admission. Neither the public
facade nor `BeautyCore` gains a type or parameter; `BeautyDetection` still
supplies observed support. The retained Metal shader, runtime API, and
pixel-buffer route are unchanged. This architecture supports generated
CPU/Metal parity only; natural portrait efficacy remains under active v1.23
qualification.
