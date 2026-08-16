# ARCHITECTURE.md

> `beauty` 的当前 SDK-only 系统蓝图。参数与状态机见 `DESIGN.md`；effect/control
> status 见 `docs/SDK_EFFECT_TAXONOMY.md`。

## 1. Current Repository Contract

The repository contains one Swift Package rooted at `BeautySDK/`. SwiftPM library
and executable products, SwiftPM tests, and SDK-owned scripts are the only active
build/test/validation surfaces.

The retired application/UI trees are historical artifacts under
`archives/legacy-ui/`. They are not dependencies, source examples, current
requirements, or completion evidence. `FRONTEND.md` owns this redirect.

Current source/test inventory, excluding `.build`:

| Inventory | Count |
| --- | ---: |
| Swift source files | 66 |
| SwiftPM test files | 61 |
| Swift source lines | 14,952 |
| SwiftPM test lines | 29,995 |

## 2. Top-Level Invariants

| ID | Invariant |
| --- | --- |
| A1 | SDK targets contain no application pages, UI state, navigation, or protected-resource prompts. |
| A2 | Host code imports only the public `BeautySDK` product. |
| A3 | Dependency direction is acyclic and flows inward toward `BeautyCore`. |
| A4 | Detection/support values remain package-only, request-local, and absent from public diagnostics. |
| A5 | Geometry controls enter the existing single `BeautyGeometryEffectPipeline`; no per-feature warp path exists. |
| A6 | Local retouch canonicalizes once, detects/maps once, composes original-pixel proposals once, and fails locally. |
| A7 | Public parameters and presets remain backend-independent normalized values. |
| A8 | Resource lookup is centralized and validates logical identifiers rather than interpreting caller paths. |
| A9 | SwiftPM plus SDK-owned CLI/script validation is the sole current evidence boundary. |
| A10 | The v1.16 contract historically retained CPU/Core Image behavior and pinned shader bytes without a public Metal API, backend switch, or algorithm; the current v1.17 Phase-71 runtime is package-internal only. |
| A11 | The external consumer and CLI observe only public-product results, bounded identities, and typed aggregate outcomes; executable-internal failure seams are test machinery, not public API. |
| A12 | `BeautyResult<Output>` is `Sendable` only when `Output: Sendable`; public concurrency tests cover compile-time acceptance and a complete async task hop without making arbitrary payloads transferable. |

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
| `BeautyCore` | public/shared value models, errors, configuration, canonical carrier, redacted diagnostics | Vision implementation, application state |
| `BeautyDetection` | Vision detection, mapping, selection, package-only observed support | rendering, public raw geometry |
| `BeautyRender` | pass/pixel-buffer foundations, the retained bundled shader resource, and the package-internal `BeautyMetalRuntime` resource/synchronization owner | effect policy, application code, a public backend selector, or a claimed device backend |
| `BeautyResources` | bundled manifest/presets and identifier validation | arbitrary external path loading |
| `BeautyEffects` | resolver, safety caps, geometry/color pipelines, local-retouch providers/transforms/composition | public facade, application controls |
| `BeautySDK` | stable host facade and request orchestration | raw support/mask export, application lifecycle |
| `BeautyExampleRenderer` | public-facade fixture input/output validation, deterministic 74-case discovery, and typed report aggregation | internal-target imports, public backend selection, product claims from generated media |

The package declares no remote dependency. New dependencies, models, resource
downloads, or network behavior require explicit security/licensing review.

The repository-owned external consumer under `IntegrationTests/` is a separate
SwiftPM executable with one local path dependency and only the public
`BeautySDK` product. It generates its own neutral input and observes real output
bytes/dimensions; it is an integration fixture, not an SDK target or public API.
`BeautyExampleRenderer` accepts the compatible `--input`, `--output`, `--case`,
and `--no-watermark` flags, requires a pre-existing output directory, preserves
the exact 74-case catalog, and accepts only the executable-local `--backend cpu`
token. `gpu` and unknown backend tokens are rejected until v1.17; no public
backend selector is implied.

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
→ CPU/Core Image color + unified geometry + request-local local-retouch composition
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

- `docs/SDK_EFFECT_TAXONOMY.md` is the exact 61-field taxonomy authority.
- `BeautyParameters` is the public contract; archived labels/layout never create
  a field, alias, provider, or product claim.
- `teethWhitening` and `scleraRednessReduction` are bounded opaque still-image
  controls. `去脂` remains future and cannot proxy through eye/brow/smoothing work.
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
counts. The current CPU/Core Image implementation remains the sole reference.

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

The current public concurrency evidence is the three-test
`BeautyResultConcurrencyTests` suite (3/0/0): a `Sendable` payload result
survives an async task hop with its public fields intact, ordinary string
construction remains source-compatible, and a non-`Sendable` payload is kept
outside the positive contract. The latest completed mandatory wrapper evidence
executes 702 tests with zero failures and zero skips. The active boundary
self-test rejects a mutation back to unconditional generic sendability before
archive, consumer, generated-CPU, opt-in, or child execution.

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
