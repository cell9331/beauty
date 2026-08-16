# PRODUCT_SENSE.md

> Current SDK product and acceptance contract. Historical application journeys
> remain in archived milestone evidence and the verified legacy ZIPs.

## 1. Product Position

`beauty` is a modular local-first iOS SDK for host applications. It is not a
standalone consumer application. The active repository exposes a public
`BeautySDK` SwiftPM product plus an SDK-owned command-line validation consumer.

Core promise:

- a host imports one public product and submits explicit image/frame metadata and
  normalized parameters;
- defaults are no-op, failures are typed, and degradation is visible through
  redacted warnings/aggregate metrics;
- processing remains local by default; and
- effect behavior stays natural, bounded, deterministic, and independently
  testable.

The maintainer/host validation journey is also public-product-only:

```text
maintainer creates a clean local-path SwiftPM consumer
→ imports only BeautySDK and generates a neutral RGBA input
→ observes real public-facade bytes and dimensions
→ runs BeautyExampleRenderer against explicit input/output directories
→ discovers the exact 74-case catalog and reads the versioned aggregate report
→ receives typed non-zero diagnostics for invalid or incomplete work
```

This validates integration and CLI behavior; it is not an application, UI, or
device journey and does not promote generated media as product evidence.

## 2. Current Product Boundary

- SwiftPM and SDK-owned CLI/scripts are the only active evidence surfaces.
- `docs/SDK_EFFECT_TAXONOMY.md` owns exact implemented/partial/future status and
  the 61-field mapping.
- Historical UI layout, navigation, controls, badges, screenshots, and lifecycle
  do not establish SDK support or current acceptance.
- Bounded opaque still-image `teethWhitening` and
  `scleraRednessReduction` remain independently implemented.
- `去脂`, semantic-mask features, new algorithms, realtime local retouch, and a
  new render backend remain outside current acceptance.
- Device quality, population sufficiency, commercial approval, packaging,
  shipping, launch, and release readiness require separate authorization and
  evidence.

## 3. Primary User Journey

```text
host adds the BeautySDK Swift package
→ imports BeautySDK
→ constructs BeautyEngine, BeautyConfiguration, and BeautyParameters
→ passes image or supported pixel buffer with explicit metadata
→ receives output or typed BeautyError
→ consumes only redacted warnings and aggregate metrics
```

Acceptance:

| Check | Pass criteria |
| --- | --- |
| Consumer boundary | A clean SwiftPM consumer imports only `BeautySDK`. |
| Defaults | Default parameters preserve input within the documented copy/render tolerance. |
| Input | Invalid extent, orientation, color, format, or configured limit fails before expensive work. |
| Output | Successful generated input/output validation uses actual public-facade bytes/dimensions, not a stub or label. |
| Errors | Callers receive stable typed, payload-free errors rather than framework detail. |
| Degradation | Missing/no-face/malformed support fails only dependent work while safe siblings continue. |
| Privacy | No unredacted support, masks, raster data, paths, or private fixture location crosses public/durable boundaries. |
| Reset/recovery | Invalid or failed requests do not contaminate a later valid request. |
| CLI matrix | Every requested input×case completes with a non-empty, decodable, same-size output and reconciled report counts; partial work exits non-zero. |
| CLI scope | `--backend cpu` is the only accepted backend token in v1.16; `gpu` and unknown values fail until v1.17, without a public SDK backend API. |
| CLI privacy | Reports persist only versioned aggregate counts and relative public identities; raster data, geometry, private metadata, absolute paths, and child output stay transient. |
| Result concurrency | `BeautyResult<Output>` is transferable only when `Output: Sendable`; the public suite proves a complete async task hop and preserves all public fields, while ordinary non-sendable result construction remains valid. |

## 4. Effect Acceptance

- Every current effect maps to a documented `BeautyParameters` field or an
  explicitly documented alias in the taxonomy.
- Numeric values normalize deterministically; non-finite input becomes the
  documented no-op and algorithm caps remain separate from public ranges.
- Geometry work uses actual validated request-local support and the one unified
  warp pipeline; missing support cannot be guessed or borrowed.
- Local retouch uses canonical opaque sRGB input, original-pixel composition,
  hard ownership containment, collision-to-source behavior, and local failure.
- Synthetic/AI-generated fixtures can prove mechanics only. Product evidence for
  local retouch requires its rights-approved positive/negative bundle and frozen
  original-detail review.
- Teeth and sclera evidence cannot promote one another or `去脂`.

## 5. Current Verification Contract

```bash
swift test --package-path BeautySDK
swift run --package-path BeautySDK BeautyExampleRenderer --help
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
bash scripts/check-swiftpm-consumer.sh
bash scripts/run-no-skip-swiftpm.sh
```

The mandatory no-skip gate must execute all eight opt-ins with zero failures,
zero skips, and a nonzero denominator. Archive integrity and the SDK-only static
boundary are part of the same acceptance conjunction.

The current focused public concurrency suite executes 3 tests with zero
failures. The latest completed mandatory wrapper executes 702 tests with zero
failures and zero skips; its boundary self-test rejects unconditional generic
`BeautyResult` sendability before the archive, consumer, generated CPU, opt-in,
and one-child stages. This evidence is SwiftPM/SDK-owned only and does not
establish UI/Demo behavior, Metal/GPU execution, simulator/device quality,
performance, commercial approval, packaging, shipping, launch, or release
readiness.

## 6. Historical UI Material

Historical application/UI artifacts are recoverable only through
`archives/legacy-ui/README.md`. Restore into a new temporary directory for review;
never use restored material as an active build input, taxonomy authority, or
current acceptance gate.

## 7. Anti-Goals

- no application/UI implementation in this repository;
- no cloud upload or hidden network dependency;
- no raw biometric-adjacent diagnostics;
- no proxy implementation for unsupported taxonomy rows;
- no new Metal/GPU API, render behavior, or algorithm in v1.16;
- no release-like claims from package tests or the historical archive alone.

## Phase 70 Backend-Neutral Acceptance

The current v1.17 SDK acceptance boundary is one package-only
`BeautyBackendRequest`/`BeautyBackendResult` contract for still images and pixel
buffers. It shares validated metadata, normalized effect intent, request-local
support, canonical still-image ownership, alpha/extent/containment,
collision-to-source, and smallest-unit failure semantics. Results expose only
bounded aggregate diagnostics, and typed backend failures are terminal without
fallback. CPU remains the deterministic reference; Metal resources/passes and
public `.cpu`/`.gpu` configuration are later-phase work.

This contract does not expand the 61-field `BeautyParameters`, five neutral
presets, or 74-case renderer, and it adds no UI/Demo route, new algorithm,
device/performance evidence, commercial approval, packaging, shipping, launch,
or release-readiness claim.

## Phase 71 SDK-Only Metal Runtime Acceptance

Phase 71 accepts only package-internal runtime mechanics. `BeautyRender` owns
`BeautyMetalRuntime` device/command queue/pipeline setup and request-local
texture, buffer, and command resources; `BeautyEffects` owns the package-only
`BeautyMetalBackend` executor. `BeautySDK` remains publicly unrouted, with no
`.gpu` selector in configuration, parameters, presets, or the command-line
consumer.

The bounded journey is validate dimensions and bytes, create resources, encode
the existing identity transaction, synchronize and inspect status, materialize
the matching output, then release all request resources on success and error.
No host device yields typed `.metalUnavailable`; it is not GPU success and does
not trigger CPU fallback or retry. Aggregate status is the only durable
evidence, with no support, pixel, texture, framework, geometry, or path detail
and no application/UI/capture lifecycle dependency.

Phase 72 owns feature-pass work, Phase 73 owns public `.cpu`/`.gpu`
configuration and typed unavailable behavior, and Phase 74 owns generated
parity/no-skip closeout. CPU remains the reference and all existing 61-field,
five-preset, 74-case, dependency, archive, and privacy contracts remain in
force. This acceptance does not claim simulator/physical-device behavior,
performance, commercial approval, packaging, shipping, launch, or release
readiness.

## 8. Regression Checklist

- Public/source/Codable compatibility is explicit and tested.
- No-op, invalid, no-face, partial support, repeated, and recovery paths pass.
- Protected/out-of-mask pixels and alpha remain exact where required.
- Generated media remains ignored, untracked, bounded, and disposable.
- Archive verification and post-archive scanning pass before the full suite.
- The external consumer, focused renderer regression, and compiled Process matrix
  pass before the one-child no-skip run.
- Contract changes update `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`,
  `RELIABILITY.md`, taxonomy, and `PLANS.md` as applicable.
