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
| SwiftPM test files | 60 |
| Swift source lines | 14,950 |
| SwiftPM test lines | 29,738 |

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
| A10 | v1.16 retains the current CPU/Core Image behavior and pinned shader bytes without adding a Metal runtime, GPU API, backend switch, or algorithm. |
| A11 | The external consumer and CLI observe only public-product results, bounded identities, and typed aggregate outcomes; executable-internal failure seams are test machinery, not public API. |

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
| `BeautyRender` | pass/pixel-buffer foundations and retained bundled shader resource | effect policy, application code, a claimed current GPU backend |
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
  and fixture locators are request-local implementation details.
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
generated suite. The final wrapper must preserve one SwiftPM child transcript, execute all eight
documented opt-ins, and reject failure, skip, or zero execution. These gates do
not establish device, performance-budget, commercial, packaging, shipping,
launch, or release readiness.
