# Architecture

**Analysis Date:** 2026-08-14
**Boundary:** SDK-only SwiftPM repository

## System Overview

```text
Host application or SDK-owned command-line renderer
                         │ public BeautySDK API
                         ▼
BeautySDK facade: validation, request ownership, routing, redaction
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
   BeautyDetection  BeautyEffects  BeautyResources
          └──────────────┼──────────────┘
                         ▼
                BeautyCore / BeautyRender
```

`BeautySDK/Package.swift` is the only active build graph. It declares the public
`BeautySDK` library, the SDK-owned `BeautyExampleRenderer` executable, six
internal/library targets, and six SwiftPM test targets. No application, UI,
capture-session, simulator, or UI-test layer is active.

## Component Ownership

| Component | Current responsibility |
| --- | --- |
| `BeautyCore` | Public/shared values, the 11-field configuration including `.cpu`/`.gpu`, typed errors, canonical carriers, and privacy-safe diagnostics. |
| `BeautyDetection` | Vision detection, coordinate mapping, face selection, and package-only request support. |
| `BeautyEffects` | Parameter resolution, geometry/color pipelines, local-retouch providers, and original-pixel composition. |
| `BeautyRender` | Render-pass/pixel-buffer foundations, the byte-pinned shader resource, and package-internal `BeautyMetalRuntime` device/queue/pipeline/resource ownership. |
| `BeautyResources` | Bundled manifest/preset validation and logical resource lookup. |
| `BeautySDK` | Sole host-facing facade, request validation, immutable `BeautyBackendFactory` selection, policy propagation, orchestration, and redaction. |
| `BeautyExampleRenderer` | Command-line public-facade consumer that writes disposable ignored evidence. |

## Current Still-Image Flow

1. The host calls `BeautyEngine` with explicit metadata and parameters.
2. The facade validates dimensions, format/color, alpha, and resources before
   allocation-heavy work.
3. Local-retouch requests canonicalize orientation/color once and obtain one
   request-local Vision observation.
4. Feature providers propose bounded edits from immutable original pixels.
5. One composition owner enforces capacity, hard containment, and
   collision-to-source behavior.
6. Remaining color/geometry work executes and the facade returns only output,
   typed errors, fixed warnings, and aggregate metrics.

The pixel-buffer path remains face-independent/color-only for geometry purposes.
Realtime landmark tracking remains outside this package path; local
teeth/sclera work stays request-local, and public GPU routing is owned by the
Phase-73 `BeautyConfiguration`/`BeautyBackendFactory` contract. Phase 71's
internal identity runtime is not a feature-pass or host application route.

## Boundaries

- Hosts import only the public `BeautySDK` product; internal targets point inward
  according to the package manifest.
- Raw images, masks, landmarks, pupils, teeth/eye geometry, and private fixture
  locators remain request-local and absent from public/persisted diagnostics.
- `docs/SDK_EFFECT_TAXONOMY.md` owns current effect/control status. `去脂`
  remains future and cannot proxy through existing eye/brow/smoothing behavior.
- Historical UI/Demo content is recoverable only through verified pinned
  artifacts under `archives/legacy-ui/` into a fresh outside-repository temporary
  directory. It is not a build, test, architecture, or requirement input.
- v1.16's historical contract did not modify the retained shader or add a
  public Metal/GPU backend. Phase 71 now owns a package-internal
  `BeautyMetalRuntime` in `BeautyRender` and `BeautyMetalBackend` in
  `BeautyEffects`; it claims no device, commercial, packaging, shipping,
  launch, or release readiness.

## Active Entry Points

- `BeautySDK/Package.swift`: package graph.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`: public processing facade.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`: SDK-owned executable.
- `scripts/run-no-skip-swiftpm.sh`: archive-first bounded mandatory gate.
- `scripts/check-sdk-only-boundary.sh`: SDK-only static boundary and symlink gate.
- `archives/legacy-ui/README.md`: verified historical access only.

## Phase 71 Runtime Ownership

`BeautyRender` owns device, command queue, pipeline, and request-local
texture/buffer/command lifetime. `BeautyEffects` owns the package-only Metal
executor; `BeautySDK` remains publicly unrouted until Phase 73. The bounded
lifecycle validates dimensions and bytes, creates resources, encodes the
retained identity transaction, synchronizes and inspects status, materializes
matching output, and releases all request resources on success and error.
Unavailable hosts return `.metalUnavailable` without CPU fallback/retry or GPU
credit. Diagnostics are aggregate-only and the runtime has no application, UI,
or capture lifecycle dependency. Phase 72 owns feature passes, Phase 73 owns
the public `BeautyConfiguration.renderBackend` selector and fail-closed factory
policy, and Phase 74 owns generated parity/no-skip closeout; CPU remains the
reference and all existing dependency, archive, 61-field, five-preset, 74-case,
and privacy contracts remain in force.

### Phase 72 Feature-Pass Boundary

`BeautySDK` composes local-retouch units before backend publication. The
package-only Metal adapter receives the canonical carrier plus six aggregate
counters, dispatches composed-retouch before color and geometry, and exposes
no provider or support payload. Generated local-retouch tests and the feature
preflight preserve source binding, protected bytes, alpha, containment,
collision-to-source, and unit-local recovery. Public selection is now the
Phase-73 `.cpu`/`.gpu` configuration contract and parity/no-skip closeout
remains Phase 74.

### Phase 73 Public Backend Configuration

`BeautyCore.BeautyConfiguration` has exactly 11 stored fields, including the
two-case `BeautyRenderBackend`. New and missing/legacy-key configurations use
`.cpu`; `BeautySDK.BeautyBackendFactory` propagates an immutable selected policy
request-locally. Explicit GPU uses the package Metal runtime and fails closed as
`.metalUnavailable` when unavailable, with no CPU fallback. Package-only
injection is test-only. Phase-73 aggregate evidence is configuration `16/0/0`,
runtime `34/0/0`, full `753/0/0`, eight opt-ins exactly once, and separate
`metal_available=1` / `metal_unavailable=0` classifications. Phase 74 owns
generated parity; UI/Demo, device, performance, commercial, packaging,
shipping, launch, and release-readiness remain excluded.

### Phase 74 Generated Backend Parity

The current architecture retains CPU/Core Image as the permanent semantic
reference while public configuration selects one immutable CPU or Metal policy
per request. Generated in-memory parity fixtures exercise the same normalized
plan and carrier through both backends. Exact neutral bytes and structural
kind/dimension/alpha/extent/named-sRGB invariants are combined with pinned
active deltas; containment, protected/outside bytes, collision, degradation,
sibling isolation, and bounded concurrency remain aggregate-only. The parity
gate reports focused `12/0/0`, full `765/0/0`, and separate
`metal_available=1` / `metal_unavailable=0`. Unavailable Metal is typed terminal
failure, never fallback or parity success. UI/Demo, device, performance,
commercial, packaging, shipping, launch, and release claims remain excluded.

---
*Architecture analysis: 2026-08-14 after Phase 66 review remediation*
