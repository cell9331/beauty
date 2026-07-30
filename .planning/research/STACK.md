# Stack Research

**Domain:** Beauty v1.14 local-first still-image facial retouch (`白牙`, `祛红血丝`, conditionally `去脂`)
**Researched:** 2026-07-30
**Confidence:** HIGH for stack and integration boundaries; MEDIUM for final device execution strategy; LOW for a shippable `去脂` implementation

## Recommendation in One Sentence

Productize v1.14 entirely inside the existing Swift package with Apple Vision, ImageIO, Core Graphics, and a reused color-managed Core Image context; add private request-local lip/eye mask providers and one original-pixel composer to `BeautyEffects`, but add no package target, external dependency, Core ML asset, second Vision request, realtime path, or transparent/HDR support.

## Recommended Stack

### Core Technologies

| Technology | Version / baseline | Purpose | Why Recommended |
| --- | --- | --- | --- |
| Swift + SwiftPM | Existing `swift-tools-version: 6.0`; iOS 17+ / macOS 14+ | Public zero-default parameters, immutable request context, typed failures, package-internal providers, XCTest | This is the shipped SDK stack. v1.14 needs no language, platform, product, target, or dependency-graph migration. Local evidence was reproduced with Xcode 26.6 / Swift 6.3.3 / Apple SDK 26.5, but those installed versions are evidence tooling, not a raised deployment target. |
| Apple Vision `VNDetectFaceLandmarksRequest` | Available since iOS 11 / macOS 10.13; already in `BeautyDetection` | One selected-face request supplying eye contours, pupils, lips, and—only if `去脂` is later admitted—eyebrows | Apple exposes eye, eyebrow, inner/outer-lip, and pupil landmark regions through `VNFaceLandmarks2D`. The existing request already obtains eyes/pupils and lip availability; v1.14 should copy actual inner/outer-lip points into a new private request-scoped carrier, not run another request or introduce a segmenter. |
| ImageIO + Core Graphics | Platform frameworks; current deployment baseline | Validate orientation/color model and create the canonical raster boundary | ImageIO exposes per-image metadata and EXIF orientation. `CGImagePropertyOrientation` represents all eight TIFF/EXIF cases. Use it before Vision and rendering rather than allowing the two consumers to interpret source pixels separately. |
| Core Image | Platform framework; current deployment baseline | Normalize once to up-oriented sRGB RGBA8, render bounded ROIs/masks, and return a same-image result | `CIContext` can explicitly control output color space and `CIFormat`; Apple recommends creating the context during setup and reusing it. This directly matches Spike 013 and avoids adding a third-party image engine. |
| Existing `BeautySDK` / `BeautyDetection` / `BeautyEffects` seams | Current v1.13 package | Public facade, one request, effect planning, request-local masks, composition, redacted results | These boundaries already hide Vision and raw geometry. The minimum production change is to extend them, not create `BeautyRetouch` as another target or bypass the facade. |

### Supporting Libraries and APIs

| Library / API | Version | Purpose | When to Use |
| --- | --- | --- | --- |
| `CGImageSourceCopyPropertiesAtIndex` + `kCGImagePropertyOrientation` | ImageIO on current platform baseline | Read/validate per-image orientation before canonical rendering | Use when ingestion still has encoded metadata. The existing typed `CIImage` facade must continue to validate its explicit `BeautyInputMetadata.orientation`; do not add an encoded-data API merely to satisfy v1.14 unless a separate public API decision owns byte input. |
| `CIImage.oriented(forExifOrientation:)` | Core Image on current platform baseline | Apply the accepted EXIF rotate/mirror exactly once | Use only in the canonical still-image normalizer. After normalization, pass `.up` to Vision and do not reapply orientation in effects or output composition. |
| `CIContext` with explicit sRGB working/output color spaces and `.RGBA8` output | Core Image on current platform baseline | Produce the canonical 8-bit RGB raster and deterministic ROI buffers | Make the context engine-owned or held by a dedicated reusable still-image normalizer. Do not create it per request as the current geometry MVP path does. Do not rely on device RGB or Core Image defaults. |
| `VNFaceLandmarks2D.innerLips` / `.outerLips` | Vision on current platform baseline | Seed and contain adaptive deterministic teeth selection | Add actual mapped point values to a package-only, non-Codable `BeautyObservedLipSupport`; current landmark-group availability and synthetic mouth proxies are not sufficient for teeth masking. |
| `VNFaceLandmarks2D.leftEye` / `.rightEye` / `.leftPupil` / `.rightPupil` | Vision on current platform baseline | Per-eye sclera aperture and iris exclusion | Reuse the existing `BeautyObservedEyeSupport` and one-mapper path. Apple explicitly warns pupil values can be inaccurate during blinking, which supports the existing fail-closed per-eye guard. |
| Core Image mask blending or an equivalent bounded ROI compositor | Built-in; no package install | Blend one accepted local transform over the canonical original while preserving original pixels elsewhere | Use behind one `LocalRetouchComposer`. If built-in mask blending cannot express the exact yellow/red-excess formulas and overlap suppression, keep a bounded ROI CPU implementation first; move only the compositor kernel into `BeautyRender` after target-device evidence justifies it. Do not introduce an unreviewed whole-frame CPU loop as the final performance design. |

### Development and Evidence Tools

| Tool | Purpose | Notes |
| --- | --- | --- |
| XCTest in the existing six test targets | Parameter compatibility, normalization, single-request routing, support validation, region-local failure, overlap suppression, redaction, no-op regression | Add tests to existing targets only. `BeautyDetectionTests` owns Vision mapping; `BeautyEffectsTests` owns masks/composition; `BeautySDKTests` / `BeautyCoreTests` own public facade and Codable compatibility. |
| Existing `BeautyExampleRenderer` | Public-facade saved-output evidence | Add only approved still-image cases. Generated images stay ignored and local; committed evidence records aggregate counts and review outcomes, not portrait bytes, masks, coordinates, or hashes. |
| Existing Spike 006 local review workflow | Rights, positive/negative bundle completeness, before/mask/after original-detail review | This is a product gate, not a runtime dependency. Teeth needs yellow/darker-teeth positives plus protected-tissue negatives; sclera needs genuine redness positives/negatives; `去脂` needs genuine upper-eyelid-fullness positives before a public field or provider is admitted. |
| Release-mode target-device profiling / Instruments | Normalization, Vision, mask, composition, and peak-memory evidence | Required before claiming a device budget. The current macOS spike timings and evidence-run RSS are baselines only. No realtime or 30-fps criterion belongs to this still-image milestone. |

## Package and Source Integration

No new package target is needed. Preserve the current dependency graph and place the production additions as follows:

| Existing owner | Required v1.14 addition/change | Explicit boundary |
| --- | --- | --- |
| `BeautyCore` | Add positive-only zero-default `teethWhitening` and `scleraRednessReduction` scalar parameters with normal Codable/defaulted-initializer compatibility. Add `upperEyelidFullnessReduction` only after its independent real-positive/non-warp gate passes. | Current inventory goes from 59 to exactly 61 stored fields for the teeth+sclera slice, or to 62 only if `去脂` is separately admitted. Do not reserve a misleading active `去脂` field from mechanics-only evidence. |
| `BeautySDK` | Insert one private canonical still-image normalization step before `resolveStillImageGeometry`; enforce existing pixel ceiling and transparent-input rejection before Vision/local-mask work; pass the canonical up-oriented image and `.up` metadata to detection and rendering. | Keep the existing public facade and result envelope. Do not alter the pixel-buffer route. If encoded-byte ingestion is later added, it requires a separate API/security decision and must retain the existing 32 MiB boundary. |
| `BeautyDetection` | Extend the current selected-face observation with actual mapped `innerLips` and `outerLips` support. Continue using current mapped eye/pupil support and existing eye/brow carriers. | One `VNDetectFaceLandmarksRequest`; copy only coordinate values; map each accepted point once; no Vision object, raw point array, face bounds, or mask leaves package/request scope. |
| `BeautyEffects/Planning` | Add distinct local-retouch intent/effective-strength accounting and per-feature/eye eligibility. | Teeth, left sclera, right sclera, and conditional upper-lid bands fail independently. Do not fold these fields into `.eyes`, `.mouth`, `lipColor`, geometry weakening, or a global skin/color strength. |
| `BeautyEffects/Render` | Add private `TeethMaskProvider`, `ScleraMaskProvider`, conditional `UpperEyelidFullnessProvider`, a bounded pixel-transform implementation, and one `LocalRetouchComposer` reading canonical original pixels. | Re-clip after feathering; preserve baseline teeth seeds; protect iris/highlights before redness scoring; reject cross-mask overlap to original; retain no masks after the request. This is the smallest fit with the current `BeautyColorEffectPipeline`, which already lives in `BeautyEffects`. |
| `BeautyRender` | No mandatory v1.14 source change for correctness. Use it only if profiling promotes the bounded compositor to a Metal/Core Image kernel. | Do not create a second render graph or claim the placeholder `Warp.metal` is a working local-retouch kernel. Any GPU implementation must preserve the same mask ownership and original-pixel oracle. |
| `BeautyResources` | No change. | v1.14 baseline carries no model, weights, LUT, remote asset, or manifest entry. |
| `BeautyDemo` | No change. | SDK-SPM-only milestone; no SwiftUI tool rows, permission flow, gallery feature, or debug mask UI. |

## Public-Parameter Staging

| Gate result | Public stack result | Feature result |
| --- | --- | --- |
| Teeth and sclera fixture gates pass; `去脂` gate does not | Add exactly two scalars; 61 stored fields total | Ship `白牙` and `祛红血丝`; keep `去脂` future and branch `眼睛` partial. |
| All three independent gates pass | Add three scalars; 62 stored fields total | Ship three independent controls; `去脂` uses only the approved non-warp provider. |
| Teeth or sclera product gate fails before the public-contract freeze | Do not add that feature's scalar or runtime provider in the shipping slice | Keep the row future/partial; do not weaken containment/guard thresholds merely to force milestone completion. |

The public range should remain `0...1`, zero-default, finite-normalized, and non-mutating; product safety caps and all experimental mask thresholds remain internal and must be calibrated on rights-approved real fixtures. No spike coefficient is a versioned public constant.

## Installation

No dependency installation and no `Package.swift` dependency or target change are recommended.

```bash
# Existing package build/test path remains authoritative.
swift test --package-path BeautySDK

# Inspect the package graph; it should still contain no external dependency.
swift package --package-path BeautySDK show-dependencies
```

Expected package diff for v1.14: source/test files inside existing targets only. A new `.package(...)`, binary target, model resource, runtime download, or executable dependency is a scope violation unless separately approved.

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
| --- | --- | --- |
| Deterministic adaptive teeth provider over actual Vision lip support | Licensed Core ML teeth segmenter | Only after the full dataset/checkpoint/conversion/redistribution chain is independently approved and pinned, and the model beats deterministic containment, naturalness, cold-start, memory, and target-device gates. This is not the v1.14 default. |
| Guarded per-eye Vision/color sclera provider | Generic face/eye semantic segmentation | Only in a later milestone with an approved local model and a materially better protected-tissue/coverage result. It is unnecessary to begin the validated guarded path. |
| Bounded ROI CPU/Core Image composition with one reusable context | New Metal compute compositor | Use Metal only when release profiling on supported iOS devices shows the correctness-first path misses an explicit still-image latency or memory budget. Port the same oracle; do not redesign ownership by transform order. |
| Existing Objective-C-style `VNDetectFaceLandmarksRequest` API | New Swift Vision `DetectFaceLandmarksRequest` | Reconsider only after the newer API is final across the deployment toolchain and migration has a concrete benefit. Apple currently marks that newer documentation preliminary/beta, while the existing request is stable and already integrated. |
| Reject any non-opaque input before Vision | Composite transparent input against a declared background and restore alpha | Only after a separate public composite policy, cross-background Vision stability bounds, alpha restoration semantics, and fixtures are approved. |
| 8-bit sRGB RGBA canonical path | HDR / gain-map / extended-range preservation | A future export-quality milestone may use it after defining color/headroom semantics, memory budgets, and auxiliary-data handling. Spike 013 did not validate this variant. |

## What NOT to Use or Add

| Avoid | Why | Use Instead |
| --- | --- | --- |
| Third-party beauty/image-processing SDK | Adds license, privacy, update, binary, and possible network risk without solving the already validated local mechanics | Apple frameworks plus local Swift code in existing targets. |
| EasyPortrait/Core ML artifact or any unapproved model/weights | The tested candidate has no approved pinned redistribution chain and substantial cold-load/memory evidence; research success is not shipping authorization | Deterministic adaptive teeth provider; keep the model only as an isolated comparator. |
| New `BeautyRetouch` package target | Splits request ownership and adds an unnecessary dependency boundary for three effects | Private providers and composer inside existing `BeautyEffects`, with optional execution primitive in `BeautyRender`. |
| Second Vision request per feature | Can select/map different observations, duplicates cost, and violates one-request ownership | Extend the existing selected-face landmark payload once. |
| Synthetic mouth ellipses or current geometry proxies for teeth | Lip availability or proxy points are not tooth segmentation and cannot contain side teeth/protected tissue | Actual Vision inner/outer-lip mapped support plus seeded adaptive color growth. |
| Whole eye aperture, global red suppression, or skin normalization | Risks iris, highlight, lash, and surrounding-skin edits | Guard each eye, exclude iris/highlights before scoring, feather, then hard re-clip. |
| Eye-height/lift/brow movement, warp, eye-bag/dark-circle code, or global smoothing labeled `去脂` | Semantically aliases a different feature; the tested upper-lid warp was invalidated | Keep `去脂` absent unless the non-warp tone/frequency path passes genuine positive review. |
| Device RGB, implicit Core Image defaults, or separate Vision/render orientation handling | Equivalent inputs can drift in detector support and masks; current Core Image defaults are not the canonical product contract | One explicit up-oriented sRGB RGBA8 canonical image for both consumers. |
| Full-frame fused Swift CPU loop presented as an optimization | Spike 012 measured it 2.6–3.1x slower than sparse sequential loops | Correctness-first bounded ROI composition, then profile and optimize. |
| Public/Codable masks, lips, pupils, coordinates, vein descriptors, tensors, or debug overlays | Biometric-adjacent and, for sclera vasculature, potentially identifying data | Request-local immutable carriers and aggregate counts/timings only. |
| Transparent input acceptance, HDR/gain maps, realtime/pixel-buffer routing, SwiftUI/Demo UI, cloud/network, or remote resources | Each lacks an approved ownership/evidence contract and is explicitly outside v1.14 | Fail closed or leave behavior unchanged outside the opaque SDR still-image route. |

## Stack Patterns by Variant

**When only teeth whitening is nonzero:**

- Normalize once, run the existing selected-face request once, require actual inner/outer-lip support, build the fixed seed mask, grow only connected adaptive candidates inside the narrow mouth envelope, and compose from original pixels.
- Do not require pupils or disable unrelated existing effects because sclera support is absent.

**When only sclera redness reduction is nonzero:**

- Normalize once, run the existing request once, validate left/right eye+pupil independently, guard before color scoring, feather then re-clip, and compose accepted eyes independently.
- A rejected eye is a local no-op; it does not disable its accepted peer or invoke a second request.

**When teeth and sclera are both nonzero:**

- Build masks independently, clamp them, reject any unexpected overlap pixel to the original value, and execute one explicit-owner composition.
- Compare fused output against independently generated standalone outputs as a correctness oracle; do not define priority by code order.

**When `去脂` still lacks genuine positives or the non-warp result fails review:**

- Do not add its runtime provider/model/resource or public parameter; ship the qualified teeth/sclera slice and preserve the partial eye branch.

**When an opaque input is Display P3 rather than sRGB:**

- Convert through the same explicit sRGB canonical context and evaluate bounded—not byte/topology-identical—fresh-anchor stability on licensed fixtures.
- Keep fixed-anchor tests to distinguish detector movement from color/mask drift.

## Version Compatibility

| Component | Compatible With | Notes |
| --- | --- | --- |
| BeautySDK package | Swift tools 6.0; iOS 17+; macOS 14+ | Keep `Package.swift` platforms and target graph unchanged. Current local evidence used Swift 6.3.3 / Xcode 26.6 / SDK 26.5. |
| `VNDetectFaceLandmarksRequest` | iOS 11+ / macOS 10.13+ | Safely inside project deployment minimums. Current headers expose revision 2 from iOS 12 and revision 3 from iOS 13; do not hardcode a revision for v1.14 without fixture revalidation. |
| `VNFaceLandmarks2D` lip/eye/pupil regions | iOS 11+ / macOS 10.13+ class baseline | All required regions are nullable; availability never implies usable support. Existing request-local validation remains mandatory. |
| `VNFaceLandmarkRegion2D.pointsClassification` | iOS 16+ / macOS 13+ | Already inside the deployment baseline; useful for existing brow preflight, but not a teeth/sclera semantic label. |
| ImageIO orientation properties | iOS 4+ / macOS 10.4+ | All eight raw values 1...8 are representable; malformed values fail closed. Missing orientation may map to `.up` only where the input contract explicitly permits it. |
| Core Image explicit `createCGImage(...format:colorSpace:)` | Inside current deployment baseline | Use `.RGBA8` plus sRGB explicitly. Apple SDK 26.5 headers show newer Core Image defaults can use RGBA-half intermediates, so v1.14 must not treat defaults as the 8-bit contract. |

## Confidence and Open Stack Gates

| Area | Confidence | Evidence / remaining gate |
| --- | --- | --- |
| No external dependency or new target | HIGH | Existing package graph plus deterministic spike results. |
| One-request Vision support | HIGH | Existing production request and official Vision region APIs; actual lips still need a new private mapped carrier. |
| Canonical ImageIO/Core Image boundary | HIGH | Spike 013 mechanics and official orientation/color-render APIs. Production compatibility and memory tests remain. |
| Teeth provider/composer stack | MEDIUM-HIGH | Adaptive mechanics and current authorized smile containment are strong; yellow/darker-tooth positives and population/protected-tissue review remain required. |
| Sclera provider/composer stack | MEDIUM | Guard ordering is mechanically strong; licensed genuine-redness calibration and useful-coverage evidence remain required. |
| `去脂` runtime stack | LOW | Only tone/frequency is partial; the warp is invalidated and no genuine positive currently authorizes a public parameter. |
| GPU/Metal promotion | LOW until profiled | Correctness path is known; target-device latency, memory, and the exact production execution primitive are intentionally unproven. |

## Sources

Primary/official sources:

- [Apple: `VNDetectFaceLandmarksRequest`](https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest) — stable request behavior and revision surface.
- [Apple: `VNFaceLandmarks2D`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — eye, eyebrow, inner/outer-lip, and pupil region availability and coordinate semantics.
- [Apple: `VNFaceLandmarkRegion2D`](https://developer.apple.com/documentation/vision/vnfacelandmarkregion2d) — normalized points and region classification.
- [Apple: `VNImageRequestHandler`](https://developer.apple.com/documentation/vision/vnimagerequesthandler) — single-image handlers with explicit orientation.
- [Apple: `CGImagePropertyOrientation`](https://developer.apple.com/documentation/imageio/cgimagepropertyorientation) and [individual image properties](https://developer.apple.com/documentation/imageio/individual-image-properties) — EXIF/TIFF orientation and per-image metadata access.
- [Apple: `CIContext`](https://developer.apple.com/documentation/coreimage/cicontext) and [Core Image built-in filter guidance](https://developer.apple.com/documentation/coreimage/processing-an-image-using-built-in-filters) — explicit format/color-space render surface and context reuse.
- [Apple: `CIBlendWithMask`](https://developer.apple.com/documentation/coreimage/ciblendwithmask) — mask-based foreground/background composition primitive.
- Installed Xcode 26.6 iPhoneOS 26.5 SDK headers: `Vision.framework/Headers/VNFaceLandmarks.h`, `VNDetectFaceLandmarksRequest.h`, `CoreImage.framework/Headers/CIContext.h`, and `ImageIO.framework/Headers/CGImageProperties.h` — availability and pupil-blink caveat verified locally.

Repository sources:

- `BeautySDK/Package.swift` — current tool version, deployment platforms, targets, and zero external dependencies.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` and `BeautyEngineGeometryDetection.swift` — current still-image facade/detection routing.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` and `BeautyFaceObservation.swift` — one-request mapped eye/pupil support and missing actual lip carrier.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` and `BeautyGeometryEffectPipeline.swift` — current still-image render seam and per-call/device-RGB behavior that canonical normalization must not repeat.
- `.codex/skills/spike-findings-beauty/` — thirteen isolated spike findings, exact mechanics, invalidated warp, model-license gate, original-pixel ownership, and real-fixture limitations.
- `.planning/PROJECT.md`, `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, and `RELIABILITY.md` — v1.14 scope, package ownership, privacy, compatibility, and evidence gates.

Context7 CLI lookup was attempted first as required but its monthly quota was exhausted; current capability/version claims were therefore verified against Apple documentation and installed Apple SDK headers.

---
*Stack research for: Beauty v1.14 Local Facial Retouch*
*Researched: 2026-07-30*
