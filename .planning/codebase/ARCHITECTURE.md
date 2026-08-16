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
| `BeautyCore` | Public/shared values, configuration, typed errors, canonical carriers, and privacy-safe diagnostics. |
| `BeautyDetection` | Vision detection, coordinate mapping, face selection, and package-only request support. |
| `BeautyEffects` | Parameter resolution, geometry/color pipelines, local-retouch providers, and original-pixel composition. |
| `BeautyRender` | Render-pass/pixel-buffer foundations, the byte-pinned shader resource, and package-internal `BeautyMetalRuntime` device/queue/pipeline/resource ownership. |
| `BeautyResources` | Bundled manifest/preset validation and logical resource lookup. |
| `BeautySDK` | Sole host-facing facade, request validation, orchestration, and redaction. |
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
Realtime landmark tracking, local teeth/sclera work, and public GPU routing are
absent; Phase 71's internal identity runtime is not a feature-pass or host
application route.

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
or capture lifecycle dependency. Phase 72 owns feature passes and Phase 74
owns generated parity/no-skip closeout; CPU remains the reference and all
existing dependency, archive, 61-field, five-preset, 74-case, and privacy
contracts remain in force.

---
*Architecture analysis: 2026-08-14 after Phase 66 review remediation*
