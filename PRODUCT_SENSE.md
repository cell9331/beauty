# PRODUCT_SENSE.md

> Current SDK product and acceptance contract. Historical application journeys
> remain in archived milestone evidence and the verified legacy ZIPs.

## Current Post-Archive Acceptance Status

v1.21 is the current owner-local acceptance boundary. On 2026-08-25 the owner
superseded the earlier `去脂` deferral and accepted the existing bounded v4
mechanics as a provisional public still-image effect. The acceptance fact is
owner-provided; the repository does not claim that a new blinded manual review
was executed. Current visual quality is known to be weak and remains future
optimization work. The callable surface is 62 `BeautyParameters` fields, five
presets, and 75 renderer cases; this does not establish device, commercial,
packaging, shipping, launch, or release readiness.
The final archive-first no-skip gate passed `816/0/0` with all eight opt-ins
exactly once and zero skips.

v1.17 was historically archived at `afb04b4` after a Metal-available package
host reported focused parity `12/0/0` and full `765/0/0`. The post-archive audit
has repaired public non-up/mirrored raw metadata compatibility (`53e8da1`), made
unavailable-host typed coverage explicitly non-crediting
(`parity_executed=0`, `d29b90a`), and moved oversized geometry point payloads to
a request-local shared `MTLBuffer` (`556499a`). Only an available branch reports
`focused_tests=13` / `parity_executed=1`.

The current Metal-available branch recorded `metal_available=1`,
`metal_unavailable=0`, `parity_executed=1`, `focused_tests=13`, and
`unavailable_tests=0`. The archive-first closeout passed on 2026-08-18 at
XCTest `776/0/0`, with all eight opt-ins exactly once and `skipped_tests=0`.

The archived milestone checkboxes remain historical lifecycle records, not a
current end-to-end GPU or release acceptance. Local retouch is CPU-composed and
identity-transported by Metal; `.gpu` still images are exact-opaque bounded RGB
with named-sRGB output; generated still-image coefficients/lip math match the
CPU oracle within `max <= 2` / mean `< 0.75`; and callers serialize one
non-`Sendable` engine instance. Independent instances may run concurrently. All
F-01 through F-10 audit findings are dispositioned,
while device, commercial, packaging,
shipping, launch, and
release readiness remain outside acceptance.

The F-09 follow-up derives geometry, plan, control points, locality envelope,
and request support from one immutable observation and mutation-tests that
ownership chain (`a577dd1`).

## 1. Product Position

`beauty` is a modular local-first iOS SDK for applications and tools controlled
by the project owner. It is not a standalone consumer application and is not a
third-party SDK product. The active repository exposes a Swift-public
`BeautySDK` SwiftPM product plus an SDK-owned command-line validation consumer;
`public` is an access-level and local integration contract, not a publication,
sales, customer-delivery, App Store, or redistribution promise.

Core promise:

- an owner-controlled host imports one public product and submits explicit image/frame metadata and
  normalized parameters;
- defaults are no-op, failures are typed, and degradation is visible through
  redacted warnings/aggregate metrics;
- processing remains local by default; and
- effect behavior stays natural, bounded, deterministic, and independently
  testable.

The maintainer/owner-host validation journey is also public-surface-only:

```text
maintainer creates a clean local-path SwiftPM consumer
→ imports only BeautySDK and generates a neutral RGBA input
→ observes real public-facade bytes and dimensions
→ runs BeautyExampleRenderer against explicit input/output directories
→ discovers the exact 75-case catalog and reads the versioned aggregate report
→ receives typed non-zero diagnostics for invalid or incomplete work
```

This validates integration and CLI behavior; it is not an application, UI, or
device journey and does not promote generated media as product evidence.

## 2. Current Product Boundary

- SwiftPM and SDK-owned CLI/scripts are the only active evidence surfaces.
- The SDK, source package, binaries, model resources, compiled weights, private
  fixtures, and derived data remain inside the owner-controlled environment.
  External users, customer integrations, public package registries, sales,
  monetization, and distribution are outside the product contract.
- `docs/SDK_EFFECT_TAXONOMY.md` owns exact implemented/partial/future status and
  the 62-field mapping.
- Historical UI layout, navigation, controls, badges, screenshots, and lifecycle
  do not establish SDK support or current acceptance.
- Bounded opaque still-image `teethWhitening`, `scleraRednessReduction`, and
  provisional `upperEyelidFullnessReduction` are independently callable.
- New semantic-mask features, new algorithms, trained models, and realtime
  local retouch remain outside current acceptance. Phase-74 generated parity is historical;
  current acceptance is limited to the verified bounded repairs, without a
  broad CPU/GPU equivalence claim.
- Physical iPhone testing is optional user evaluation after SDK completion; its
  absence cannot block milestone completion or subsequent SDK work. Device
  quality, population sufficiency, commercial approval, packaging, shipping,
  launch, and release readiness remain separate, explicitly authorized claims.

## 2.1 Owner-Local Still-Image Retouch Call

The three implemented local-retouch controls are directly callable from the
owner-controlled host. A minimal photo path is:

```swift
import CoreGraphics
import CoreImage
import BeautySDK

let engine = try BeautyEngine()
let metadata = BeautyInputMetadata(
    orientation: .up,
    source: .photo
)
let parameters = BeautyParameters(
    teethWhitening: 0.65,
    scleraRednessReduction: 0.55,
    upperEyelidFullnessReduction: 0.60
)
let result = try engine.processResult(
    image: inputCIImage,
    metadata: metadata,
    parameters: parameters
)
let outputCIImage = result.output
```

`BeautyEngine.process(image:orientation:parameters:)` is the shorter equivalent
when the host only needs the output image. All three controls are positive-only,
default to zero, and clamp finite strengths to `0...1`. Zero strength is a
source-preserving no-op. The supported local-retouch path is an opaque bounded
still `CIImage` with `BeautyInputSource.photo`; transparent input is rejected,
realtime/pixel-buffer local retouch is not activated, and the SDK validates
extent, alpha, named-sRGB output, local support, and typed failure/degradation
before returning a result. Callers serialize access to one `BeautyEngine`
instance; independent instances may run concurrently.

This is an owner-local integration contract, not a third-party distribution or
release claim. `upperEyelidFullnessReduction` routes `去脂` through the existing
per-eye semantic envelope and bounded relief editor. Missing or untrusted
support is source-exact. The internal result is currently subtle/weak by owner
decision and may improve later; it must not be substituted by `eyeHeight`,
`upperEyelidLift`, a generic warp, smoothing, or an unrestricted dark patch.

## 3. Primary User Journey

```text
owner-controlled host adds the local BeautySDK Swift package
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
| Image oracle | Automation inspects applicable output pixels, extent/dimensions, orientation/mirroring, named color/alpha metadata, neutral identity, intended/protected regions, bounded numeric tolerance, and determinism; process exit alone is not acceptance. |
| Errors | Callers receive stable typed, payload-free errors rather than framework detail. |
| Degradation | Missing/no-face/malformed support fails only dependent work while safe siblings continue. |
| Privacy | No unredacted support, masks, raster data, paths, or private fixture location crosses public/durable boundaries. |
| Reset/recovery | Invalid or failed requests do not contaminate a later valid request. |
| CLI matrix | Every requested input×case completes with a non-empty, decodable, same-size output and reconciled report counts; partial work exits non-zero. |
| Backend policy | `BeautyConfiguration.renderBackend` exposes exactly `.cpu` and `.gpu`; new and legacy/missing-key configurations default to `.cpu`, and explicit unavailable `.gpu` fails as typed `.metalUnavailable` without CPU fallback. |
| CLI privacy | Reports persist only versioned aggregate counts and relative public identities; raster data, geometry, private metadata, absolute paths, and child output stay transient. |
| Result concurrency | `BeautyResult<Output>` is transferable only when `Output: Sendable`; the public suite proves a complete async task hop and preserves all public fields, while ordinary non-sendable result construction remains valid. |
| Device feedback | Physical-iPhone testing happens only as optional user evaluation after SDK completion. Missing feedback is non-blocking; reproducible findings become follow-up plans and automated regressions where possible. |

## 4. Effect Acceptance

- Every current effect maps to a documented `BeautyParameters` field or an
  explicitly documented alias in the taxonomy.
- Numeric values normalize deterministically; non-finite input becomes the
  documented no-op and algorithm caps remain separate from public ranges.
- Geometry work uses actual validated request-local support and the one unified
  warp pipeline; missing support cannot be guessed or borrowed.
- Local retouch uses canonical opaque sRGB input, original-pixel composition,
  hard ownership containment, collision-to-source behavior, and local failure.
- Generated fixtures are the mandatory repeatable mechanics oracle. When a
  local-retouch owner requires rights-approved positive/negative evidence, that
  evidence also runs through automated private opt-in scripts and frozen output
  assertions; it is separate from physical-device testing.
- Teeth, sclera, and upper-eyelid mechanics remain independent evidence paths.
  The owner's provisional `去脂` acceptance does not retroactively rewrite the
  failed v1.18/v1.19 qualification records.

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

This automated contract is the milestone authority. No current or future SDK
plan may wait for physical-iPhone access or user feedback unless the user later
creates an explicit device milestone. Post-SDK device observations are recorded
as supplemental findings and converted to deterministic regressions when
reproducible. In the absence of device evidence, the same completed milestone
must retain explicit nonclaims for on-device performance, thermals, battery,
endurance, subjective commercial quality, packaging, shipping, launch, and
release readiness.

The current focused public concurrency suite executes 3 tests with zero
failures. The v1.16 historical mandatory wrapper executed 702 tests with zero
failures and zero skips. The Phase-71 mandatory wrapper historically executed
728 tests with zero failures and zero skips. The historical Phase-73 wrapper
executed 753 tests with zero failures and zero skips, with all eight opt-ins
exactly once and separate Metal availability classifications; its boundary self-test rejects unconditional generic
`BeautyResult` sendability before the archive, consumer, generated CPU, opt-in,
and one-child stages. This evidence is SwiftPM/SDK-owned only and does not
establish UI/Demo behavior, simulator/device quality,
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

## Phase 72 Metal Feature-Pass Acceptance

At SDK-core still-image scope, existing teeth and sclera edits retain the same
request-local composition semantics on Metal: original-pixel blending,
protected-region and alpha preservation, hard containment, collision-to-source
behavior, and smallest-unit degradation. The composed carrier is the first
pass; color and geometry remain bounded siblings. This phase adds no public
backend setting, new beauty control, UI/Demo behavior, device validation,
performance, commercial, packaging, shipping, launch, or release-readiness
claim. Public configuration belongs to Phase 73 and generated parity belongs
to Phase 74.

## Phase 73 Public Backend Configuration Acceptance

An SDK integrator can construct `BeautyConfiguration(renderBackend: .cpu)` or
`.gpu`; the configuration remains immutable and separate from the 61 public
beauty fields, five presets, and 74 renderer cases. Missing and legacy Codable
backend keys resolve to `.cpu`. CPU remains the permanent reference. Explicit
GPU construction uses the package Metal runtime and either succeeds there or
returns terminal `.metalUnavailable`; it never silently executes CPU fallback.
The historical focused configuration/runtime gates recorded `16/0/0` and
`34/0/0`, while the archived full wrapper recorded `753/0/0` with eight opt-ins exactly once and
`metal_available=1` / `metal_unavailable=0`. Phase 74 owns generated parity and
SDK-only closeout; UI/Demo, simulator/device, performance, commercial,
packaging, shipping, launch, and release-readiness remain excluded.

## Phase 74 Historical SDK-Only Parity Acceptance

The archived v1.17 acceptance boundary was generated SDK-core parity: the permanent CPU
reference and available Metal consume identical normalized requests, with exact
neutral bytes and explicit bounded active tolerances. Acceptance includes
alpha/extent/named-sRGB preservation, containment and protected-region safety,
collision and degraded/no-face isolation, deterministic bounded concurrency,
and typed unavailable-GPU separation.

The historical mandatory archive-first evidence is parity focused `12/0/0`, full SwiftPM
`765/0/0`, eight opt-ins exactly once, zero skips/failures, and separate
`metal_available=1` / `metal_unavailable=0`. Current unavailable-host coverage
reports `parity_executed=0`; only an available branch can report
`parity_executed=1`. Because the remaining audit gaps above are unresolved, this
historical matrix does not establish broad current CPU/GPU equivalence. It does
not promote UI/Demo,
simulator/device, performance, commercial, packaging, shipping, launch, or
release readiness.

## v1.18 Phase 79 Failing-Branch Acceptance

The Phase-78 aggregate recommendation is `mechanics-only-not-promotion`.
Therefore the owner's local host sees the unchanged public contract: 61
`BeautyParameters` fields, five neutral presets, and 74 renderer cases. The
package-only per-eye support and deterministic fullness editor are reusable
mechanics evidence, not a public `去脂` control, route, Testing SPI, preset key,
or efficacy claim. The taxonomy remains `眼睛: partial` and `去脂: future`.

Candidate v3 confirmed the product distinction: making the upper-lid band
slightly darker is not a successful `去脂` result when a reviewer cannot see the
lid become flatter or less puffy. Candidate v4 then failed applicability,
boundary, and minimum-relief automation on genuine inputs. These outcomes end
the hand-authored tone/frequency route rather than inviting another threshold
retune.

The owner-local product may use the name `去脂` only for a learned, bounded local result that
is clearly flatter and less bulky while preserving eye opening, brow position,
lashes, iris/sclera, protected crease detail, identity, and skin texture. The
adopted route combines a small upper-lid soft-tissue flow with a low-frequency
tone residual and fails closed per eye. If the project keeps absolute geometry
identity or cannot supply paired training data authorized for the actual
owner-only use, the honest effect is only subtle
`upperEyelidReliefSoftening`; `去脂` remains future and no owner-local public
field or inert route is permitted. Research-only data and derived weights stay
in a separated non-commercial local research lane and may not be repurposed for
commercial use or distribution.

Plan 80-20 deliberately adds no visible output. It renames the rejected editor
and semantic analyzer as experimental and makes the new model owner unavailable
by default. This is a product correction: a safe no-op is preferable to showing
another dark patch while the rights-approved learned model does not yet exist.

On 2026-08-25 the owner canceled the remaining `去脂` work. This is a deliberate
future deferral, not a blocker: the experimental code stays package-only, no
model or public control will be added, and the independently completed
`teethWhitening` and `scleraRednessReduction` still-image journeys are unchanged.

This branch is accepted only on SDK-owned evidence: exact public absence,
canonical extent/orientation/mirror and named-sRGB metadata preservation,
alpha and request-local failure isolation, CPU-reference authority, explicit
GPU selection or typed `.metalUnavailable`, and the archive-first no-skip gate.
It does not establish genuine efficacy, naturalness, device performance,
thermal/battery behavior, commercial visual approval, packaging, shipping,
launch, or release readiness.

## Phase 90 Chin Repair and Contour Deferral Owner Journey

The owner can rely on the measured `chinTaper` repair through the existing
still-image `BeautyEngine.processResult(image:metadata:parameters:)` and
`BeautyEngine.process(image:orientation:parameters:)` facades. At the exact
`0.25` cap the request-local paired lower-chin band produces the recorded
centerline contraction while preserving neutral identity, deterministic repeat
output, protected regions, metadata, and field-local valid-invalid-valid
recovery. That owner-observable FACE-02 result is implemented behavior, not a
claim about other images, devices, or populations.

The owner can still call `faceContourSmooth`, but only under its current
source-unchanged, fail-closed, owner-local contract and `partial` taxonomy
status. Revision 22's `prior_stop_not_reproduced` result used a diagnostic
reconstruction with zero render/oracle invocations; it is not visual success,
repair evidence, effectiveness evidence, or FACE-01 GREEN authority. No
revision 23 is authorized, and FUTURE-04 requires a separately authorized
milestone.

Phase 90 changes none of the 62 stored parameter fields, five presets, 75
renderer cases, either public still-image facade, the CPU-reference/selectable-
GPU policy, or retained `Warp.metal`. Explicit GPU remains success on that
backend or terminal typed `.metalUnavailable`, never silent CPU fallback.
Phase 95 owns direct tests for the exact one-step-above-neutral input, both
cap-adjacent values, the exact and adjacent quantization-threshold values, and
strict-comparison tie behavior. It also owns the clean 65-output seven-
effective-plus-one-deferred publication and complete no-skip closeout.

All of this remains SDK-only and owner-local. Automated package-host evidence
does not qualify physical devices, performance, thermals, battery, endurance,
population behavior, commercial visual quality, packaging, shipping, launch,
release readiness, or distribution.
