# Phase 53: Canonical Still-Image Contract and Private Request Foundation - Research

**Researched:** 2026-07-30
**Domain:** Swift Package still-image input normalization, Vision request ownership, private mapped support, and public compatibility
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

The following locked decisions, discretion, and deferred items are copied verbatim from `53-CONTEXT.md`; the whole block is [VERIFIED: `.planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/53-CONTEXT.md`].

### Locked Decisions

### Public Still-Image Entry and Runtime Isolation
- Reuse the existing public `BeautyEngine.process(image:orientation:parameters:)` and `processResult(image:metadata:parameters:)` facade entries; callers must not import an internal target or adopt a parallel local-retouch facade.
- Introduce the reusable local-retouch request foundation behind the still-image path only. `CVPixelBuffer` and realtime/camera/video routes must remain unable to activate v1.14 retouch and retain their shipped behavior.
- Keep the foundation feature-neutral: Phase 53 may add private admission plumbing and compatibility scaffolding, but visible feature controls and providers are added only after their independent Phase 54 gates permit them.
- Preserve safe-domain continuation: invalid local-retouch support or unavailable face support must not suppress unrelated shipped face-agnostic color behavior, while invalid canonical input must fail before Vision or local-mask work.

### Canonical Image Ownership and Rejection Policy
- Create exactly one opaque, up-oriented, explicitly color-managed sRGB RGBA8 canonical raster per admitted still-image request and share that same raster with Vision, private support providers, and rendering.
- Reject transparent input in v1.14 before Vision; do not silently composite, preserve alpha as a partial policy, or infer a background. Transparent/HDR/gain-map/extended-range ownership remains future work.
- Validate finite non-empty extent, configured pixel ceilings, orientation validity, supported RGB semantics, and opacity before local-retouch analysis, returning an existing or narrowly additive typed privacy-safe `BeautyError` without embedding metadata, paths, dimensions, or portrait-derived detail.
- Apply orientation and managed-color conversion once at the canonicalization boundary. Vision receives the canonical raster with `.up`; no downstream mapper or renderer may own a second orientation/color interpretation.

### Selected Face and Request-Local Support
- Perform at most one `VNDetectFaceLandmarksRequest` and one mapping pass for a still-image request with any admitted local-retouch effects; sibling effects consume one shared mapped request context rather than re-running detection.
- Preserve the existing selected-face policy semantics, but make the still-image local-retouch support value request-scoped and non-reusable: no mask, landmark, pupil, lip/teeth, sclera, or eyelid support may be stored on the engine or cross repeated, parallel, canceled, reset, or no-face requests.
- Treat selection, mapped observations, and eventual masks as package-private implementation data. Public results and diagnostics retain only current redacted summaries and allowlisted aggregates.
- Fail closed at the smallest supported unit in later providers. A no-face or missing-support result produces empty local support for the affected feature without stale fallback or cross-feature contamination.

### Compatibility and Admission Contracts
- Preserve the legacy 59 stored fields, trailing-default source construction, missing-key JSON decoding, bundled preset decoding, zero defaults, and shipped output byte behavior when no admitted local-retouch control is active.
- Any field later admitted by an independent gate must be a distinct positive-only `Float`, finite-normalized to `0...1`, default-zero, decode-missing-as-zero, and appended compatibly; no field may alias global whitening, brightness, lip color, eye geometry, or another candidate.
- Lock exact stored-field and Codable inventory tests at each admission. A closed feature gate adds no public field, coding key, preset key, provider, renderer case, or inert route.
- Keep existing input ceilings authoritative and reject before allocation-heavy canonicalization or Vision where the public input surface makes the condition observable; document narrower observability for already-decoded `CIImage` values rather than claiming encoded-byte validation the facade cannot perform.

### the agent's Discretion
- Choose the smallest package-internal types and file layout that make canonical raster ownership and request-local support explicit while preserving target dependency direction.
- Choose focused typed-error cases only where existing `invalidInput` or `unsupportedPixelFormat` cannot express a stable caller action without leaking sensitive context.
- Choose deterministic test fixtures and injection seams that prove exactly-once canonicalization/detection/mapping and zero cross-request retention without tracking portrait media.

### Deferred Ideas (OUT OF SCOPE)
- Rights-approved feature eligibility and go/no-go decisions belong to Phase 54.
- Original-pixel ownership, provider overlap, and failure-isolation composition belong to Phase 55.
- Teeth, sclera, and conditional upper-eyelid algorithms and public controls belong to Phases 56-57 after their independent gates.
- Transparent/HDR/gain-map/multi-face policy, realtime/pixel-buffer local retouch, Demo UI, learned models, device/performance budgets, packaging, shipping, and release readiness remain outside v1.14.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|---|---|---|
| PATH-01 | Existing public still-image facade is the only integrator entry. | Keep orchestration in `BeautyEngine.processResult(image:metadata:parameters:)`; add no product or facade target. [VERIFIED: codebase grep] |
| PATH-02 | Accepted input becomes one opaque, up-oriented, color-managed sRGB RGBA8 image shared by all consumers. | Add one immutable canonical carrier backed by one RGBA8 allocation and one Core Image render; construct all consumer views from that carrier. [CITED: https://developer.apple.com/documentation/coreimage/cicontext] |
| PATH-03 | Unsupported local-retouch inputs fail before Vision or masks with typed, safe outcomes. | Retain the current extent/pixel-ceiling preflight, then check orientation/RGB/extended-range semantics, render once, scan alpha, and only then call detection. [VERIFIED: codebase grep] |
| PATH-04 | All admitted local effects share one landmarks request and mapping boundary. | Generalize the current single `resolveStillImageGeometry` route into one local request context; extend the existing observation mapping with real lip support rather than creating feature-specific detectors. [VERIFIED: codebase grep] |
| PATH-05 | Realtime and pixel-buffer behavior cannot activate local retouch. | Keep the current `CVPixelBuffer` overload on its existing validation/resolver/color pipeline and prove local-foundation collaborators have zero invocations there. [VERIFIED: codebase grep] |
| PATH-06 | Current 59-field source/JSON/preset/default/output behavior stays neutral. | Preserve a byte-identical legacy branch when no local field is admitted or active; keep exact inventory, legacy payload, preset, facade, and output regressions. [VERIFIED: focused XCTest and codebase grep] |
| PATH-07 | Every later admitted field has the exact positive-only compatibility contract. | Phase 53 must add no candidate field. Establish the admission/test seam now; each later gate must append and exhaustively test only its admitted field. [VERIFIED: `53-CONTEXT.md`] |
</phase_requirements>

## Summary

The live code already owns most of the request lifecycle: the public still-image facade validates decoded extent, validates resources, conditionally invokes one `VisionFaceDetector`, maps observations through one `CoordinateMapper`, selects a face, resolves effects, and returns only redacted summaries/aggregates. The missing boundary is that the input remains the caller's lazy `CIImage`: orientation is passed separately to both Vision and the mapper, color rendering can still use device RGB, opacity is not checked, and there is no immutable canonical-pixel owner. [VERIFIED: `BeautyEngine.swift`, `BeautyEngineGeometryDetection.swift`, `VisionFaceDetector.swift`, `BeautyGeometryEffectPipeline.swift`]

Implement Phase 53 as a conditional still-image branch, activated only by private admission plumbing. The inactive branch must remain the current implementation byte-for-byte. The active branch should preflight the already-decoded image, render once into an owned zero-origin sRGB `.RGBA8` byte buffer, reject any alpha byte other than `255`, rebuild a CIImage view from those same bytes, and pass that exact view to Vision with normalized metadata (`orientation == .up`, input mirroring already consumed). One stack-local request context should own the canonical carrier, the selected mapped observation, and the redacted detection result until the synchronous facade call returns. [VERIFIED: reasoning from locked constraints, live seams, and Apple Core Image/Vision APIs]

The important non-obvious seam is lips: eye contours/pupils, face contour/median, and eyebrows already have package-only mapped carriers, but actual Vision inner/outer lip points are currently reduced to availability flags and `BeautyFaceGeometryAdapter` synthesizes mouth points from face bounds. That proxy must remain untouched for shipped behavior, while Phase 53 adds an independent request-local observed-lip carrier for future teeth support in the same Vision/mapping pass. [VERIFIED: codebase grep]

**Primary recommendation:** Add a package-only `BeautyCanonicalStillImage` plus one `BeautyStillImageRequestContext`, route only admitted local still requests through them, extend `BeautyFaceObservation` with independently optional mapped Vision lip paths, and lock the branch with synthetic exactly-once/isolation tests while leaving the public 59-field model unchanged. [VERIFIED: reasoning from locked constraints and live dependency direction]

## Project Constraints (from AGENTS.md)

- Read `PLANS.md` before changes, respect the active plan, and record work so the next agent can trace what changed, why, and how it was verified. [VERIFIED: `AGENTS.md`]
- Treat code and tests as higher authority than `PLANS.md`, specialist documents, or historical `docs/`. [VERIFIED: `AGENTS.md`]
- Update the owning root contracts when implementation changes architecture, design, security, reliability, product acceptance, or quality evidence; do not duplicate one fact across documents. [VERIFIED: `AGENTS.md`]
- Preserve unrelated local changes, do not expand scope, and record extra issues as technical debt instead of fixing them opportunistically. [VERIFIED: `AGENTS.md`]
- Use the `spike-findings-beauty` still-image integration recipe; it requires normalize-once input, one Vision request, request-local private support, aggregate-only diagnostics, and still-image-only claims. [VERIFIED: `.codex/skills/spike-findings-beauty/SKILL.md` and `references/still-image-integration.md`]
- Build/test commands must report real environment failures; simulator builds must use an explicit available iOS Simulator. [VERIFIED: `AGENTS.md`]

## Architectural Responsibility Map

| Capability | Primary Tier / Target | Secondary Tier | Rationale |
|---|---|---|---|
| Public admission and fail-fast ordering | `BeautySDK` facade | `BeautyCore` typed errors/config | `BeautyEngine` already owns both public input overloads and configured pixel-ceiling ordering. [VERIFIED: codebase grep] |
| Canonical raster value | `BeautyCore` package-only value | `BeautySDK` factory/orchestrator | A lightweight shared carrier is needed by facade, Detection, and Effects without reversing dependencies; root architecture explicitly allows Core Image/Core Graphics/ImageIO in `BeautyCore`. [VERIFIED: `ARCHITECTURE.md`] |
| Orientation/color/opacity canonicalization | `BeautySDK` still-image boundary | Core Image/Core Graphics | This is facade input policy, not Vision mapping or an effect provider. [VERIFIED: reasoning from locked target ownership] |
| Vision request, selected face, mapped support | `BeautyDetection` | `BeautySDK` request context | Detection already owns `VisionFaceDetector`, `FaceSelectionPolicy`, `CoordinateMapper`, and package-only observations. [VERIFIED: codebase grep] |
| Feature-neutral local admission | `BeautyEffects` planning contract | `BeautySDK` routing | Effects owns parameter-to-work planning, but only the still facade is allowed to construct the local request. [VERIFIED: `ARCHITECTURE.md` and codebase grep] |
| Future masks/transforms | `BeautyEffects` | `BeautyRender` | Explicitly downstream of Phase 53; do not add providers or composition now. [VERIFIED: `53-CONTEXT.md`] |
| Pixel-buffer/realtime isolation | `BeautySDK` pixel-buffer overload | `BeautyEffects` legacy resolver | The live pixel-buffer path performs no detection and must never receive the local request context. [VERIFIED: codebase grep] |

## Live Implementation Seams

### Existing strengths to reuse

| Seam | Current fact | Planning consequence |
|---|---|---|
| `BeautyEngine.processResult(image:metadata:parameters:)` | Validates decoded extent/pixel count, validates resources, resolves geometry, then renders. [VERIFIED: codebase grep] | Insert a local-admission branch after cheap extent/resource validation; do not replace the public entry. |
| `resolveStillImageGeometry` | Calls the detector only when `BeautyEffectResolver.requiresFaceGeometry` is true and returns plan, summary, and one selected observation. [VERIFIED: codebase grep] | Generalize this into request routing so legacy geometry and admitted local support share one detector result. |
| `VisionFaceDetector.defaultObservationProvider` | Creates exactly one `VNDetectFaceLandmarksRequest` and one `VNImageRequestHandler` per invocation. [VERIFIED: codebase grep] | Preserve this request; change only its active-local input to the canonical image with `.up`. |
| `VisionFaceDetector.summarize` | Creates one mapper and maps usable detections before applying `FaceSelectionPolicy`. [VERIFIED: codebase grep] | Keep one mapping stage; do not add a provider-specific map. Prefer mapping only the selected observation if this can preserve exact selection/summary behavior. |
| Existing observed support | Eye/pupil, face contour/median, and eyebrows are immutable package-only `Sendable` values with aggregate-only descriptions. [VERIFIED: codebase grep] | Follow the same carrier and redaction pattern for lip support. |
| `BeautyParameters` | Exactly 59 stored fields; constructor/decoder/`normalized()` reapply unit/signed finite clamps and missing floats decode to zero. [VERIFIED: codebase grep and focused XCTest] | Do not add a Phase 53 field; later admitted fields append after existing initializer arguments and appear in every exact-inventory test. |
| Pixel-buffer overload | Validates count/BGRA, resolves the current plan, and calls `BeautyColorEffectPipeline` without Detection. [VERIFIED: codebase grep] | Keep this method structurally free of canonicalizer, Vision, mapped-support, and local-provider calls. |

### Gaps Phase 53 must close

1. `CIImage` is a lazy image recipe; the facade currently does not create one owned raster before Vision and rendering. Apple documents that `CIContext` evaluates/renders a `CIImage`, including rendering to an explicitly formatted bitmap. [CITED: https://developer.apple.com/documentation/coreimage/cicontext]
2. The default detector currently receives the caller image plus caller orientation, and `CoordinateMapper` applies orientation/mirroring again to Vision coordinates. The admitted local branch instead needs physically normalized pixels and normalized mapper metadata so there is one interpretation owner. [VERIFIED: codebase grep]
3. `BeautyGeometryEffectPipeline` internally renders through `CGColorSpaceCreateDeviceRGB()`. Local-active rendering must use the canonical sRGB contract (ideally through a canonical-aware overload) while the inactive legacy route remains unchanged. [VERIFIED: codebase grep]
4. Actual inner/outer lip coordinates are not retained: detection stores only landmark-group availability, and Effects derives synthetic lip geometry from face bounds. Future teeth support cannot use that proxy without violating provenance. [VERIFIED: codebase grep]
5. `maximumInputByteCount` is an encoded-data ceiling enforced by the Demo before decode, but the public SDK still-image facade accepts an already-decoded `CIImage`; it cannot truthfully validate original encoded byte count, container gain maps, or malformed container metadata. [VERIFIED: codebase grep and `SECURITY.md`]

## Standard Stack

### Core

| Technology | Repository version / deployment | Purpose | Why standard here |
|---|---|---|---|
| Swift Package Manager / Swift | tools version 6.0; local compiler 6.3.3 | Package/module access and XCTest | Existing package toolchain; no dependency change required. [VERIFIED: `Package.swift` and local CLI] |
| Core Image | Apple platform framework | Apply orientation and one explicit sRGB RGBA8 render | `CIContext.render(...toBitmap:...format:colorSpace:)` is the direct owned-buffer API. [CITED: https://developer.apple.com/documentation/coreimage/cicontext] |
| Core Graphics | Apple platform framework | sRGB color-space inspection and immutable raster views | `CGColorSpace` exposes model and extended-range checks. [CITED: https://developer.apple.com/documentation/coregraphics/cgcolorspace] |
| Image I/O | Apple platform framework | `CGImagePropertyOrientation` semantics and optional decoded metadata properties | Apple defines the eight EXIF/TIFF orientations and raw values here. [CITED: https://developer.apple.com/documentation/imageio/cgimagepropertyorientation] |
| Vision | Apple platform framework | One face-landmarks request over the canonical image | `VNImageRequestHandler` accepts CI/CG images with a declared orientation; use `.up` after normalization. [CITED: https://developer.apple.com/documentation/vision/vnimagerequesthandler] |
| XCTest | Apple toolchain | Deterministic contract and facade regression tests | Existing package test infrastructure. [VERIFIED: `Package.swift`] |

No external package should be installed, so a package-legitimacy audit is not applicable. [VERIFIED: recommended architecture uses only existing Apple frameworks]

## Apple / Core Image / Vision Facts That Constrain the Plan

- `CGImagePropertyOrientation` is an eight-case, frozen enum describing how encoded pixel axes relate to intended display; Core Image's `oriented(forExifOrientation:)` applies the corresponding rotation/mirror. [CITED: https://developer.apple.com/documentation/imageio/cgimagepropertyorientation] [CITED: https://developer.apple.com/documentation/coreimage/ciimage/oriented%28forexiforientation%3A%29]
- A `CIContext` color-matches inputs into its working space and renders from working space into the destination space; therefore both the context options and the render call must name sRGB rather than device RGB. [CITED: https://developer.apple.com/documentation/coreimage/cicontextoption/workingcolorspace]
- `CIContext.render` can target caller-owned bitmap memory with an explicit `CIFormat` and destination color space. Use `.RGBA8`, then scan the owned fourth byte of every pixel before constructing the accepted carrier. [CITED: https://developer.apple.com/documentation/coreimage/cicontext]
- Apple recommends reusing `CIContext`; it is immutable/thread-usable and expensive to create repeatedly. A context may be engine-owned, but canonical pixels and face support must remain request-owned. [CITED: https://developer.apple.com/documentation/coreimage/cicontext]
- `CIImage.colorSpace` can be `nil` when Core Image cannot determine it. For admitted local retouch, reject unknown color semantics rather than silently assigning sRGB; legacy inactive requests keep current behavior. [CITED: https://developer.apple.com/documentation/coreimage/ciimage/colorspace]
- Accept RGB input profiles such as Display P3 only when they are non-HDR/non-extended and can be color-matched to sRGB; reject non-RGB and extended-range color spaces before Vision. `CGColorSpaceUsesExtendedRange` is the platform check for the latter. [CITED: https://developer.apple.com/documentation/coregraphics/cgcolorspaceusesextendedrange%28_%3A%29]
- Already-decoded `CIImage.properties` can expose root image properties, but only URL/Data-backed or explicitly supplied properties are guaranteed to originate from Image I/O. Do not claim this facade can validate an original encoded container, byte count, or gain-map inventory. [CITED: https://developer.apple.com/documentation/coreimage/ciimage/properties]
- `VNImageRequestHandler` performs requests on one image and accepts its known orientation. The normalized route must pass the canonical CIImage with `.up`; it must not pass the caller's original orientation again. [CITED: https://developer.apple.com/documentation/vision/vnimagerequesthandler/init%28ciimage%3Aorientation%3Aoptions%3A%29-3svy6]
- A single `VNDetectFaceLandmarksRequest` locates faces and detects features; adding a second face-rectangles or per-feature landmarks request is unnecessary and violates the phase contract. [CITED: https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest]

## Recommended Architecture

### System Architecture Diagram

```text
public processResult(CIImage, metadata, parameters)
  -> cheap decoded extent + configured pixel-ceiling validation
  -> resource validation + feature-neutral local admission
       | no admitted local work
       +-> existing legacy geometry/detection/render route unchanged
       |
       | admitted local work
       +-> validate typed orientation + known non-extended RGB semantics
           -> orient/mirror once + translate to zero-origin integral bounds
           -> recheck oriented dimensions/overflow/pixel ceiling
           -> one CIContext render -> owned sRGB RGBA8 bytes
           -> alpha scan
                | any alpha != 255 -> typed BeautyError; stop before Vision
                + opaque -> immutable BeautyCanonicalStillImage
                    -> one VNDetectFaceLandmarksRequest, orientation .up
                    -> one mapper using normalized metadata (.up, not input-mirrored)
                    -> one selected BeautyFaceObservation
                       (eye/pupil + face + brow + actual lip support)
                    -> stack-local BeautyStillImageRequestContext
                    -> existing safe effects + future admitted providers
                    -> BeautyResult with image + redacted summary/aggregates

public processResult(CVPixelBuffer, metadata, parameters)
  -> existing BGRA validation/resolver/color pipeline only
  -> never constructs canonical/local request context and never calls Vision
```

Every branch and owner above is derived from the locked phase constraints and live target dependencies. [VERIFIED: `53-CONTEXT.md`, `ARCHITECTURE.md`, codebase grep]

### Recommended project structure and likely files touched

```text
BeautySDK/Sources/BeautyCore/Models/
└── BeautyCanonicalStillImage.swift       # package-only bytes/size/rowBytes/CIImage view

BeautySDK/Sources/BeautyDetection/
├── BeautyFaceObservation.swift           # add package-only observed lip carrier/property
└── VisionFaceDetector.swift               # copy/map lips in existing request and accept canonical .up input

BeautySDK/Sources/BeautySDK/
├── BeautyEngine.swift                     # conditional admitted-local branch; pixel path unchanged
├── BeautyEngineGeometryDetection.swift    # generalize one selected-face route/request context
├── BeautyStillImageCanonicalizer.swift    # input preflight + one render + alpha rejection
└── BeautyEngineTestingSupport.swift       # counters/injected admission/canonicalizer only if required

BeautySDK/Sources/BeautyEffects/
└── Planning/BeautyEffectResolver.swift    # feature-neutral still-only admission seam; no candidate field/provider

BeautySDK/Tests/BeautyCoreTests/
├── BeautyCanonicalStillImageTests.swift
└── BeautyEngineLocalRetouchFoundationTests.swift

BeautySDK/Tests/BeautyDetectionTests/
└── StillImageRequestSupportTests.swift
```

This layout adds no target and preserves `BeautySDK -> BeautyEffects -> BeautyDetection -> BeautyCore`; Detection never imports Effects or the facade. [VERIFIED: `Package.swift` and `ARCHITECTURE.md`]

### Pattern 1: One owned byte allocation

```swift
// Source API: https://developer.apple.com/documentation/coreimage/cicontext
// Illustrative package-internal shape; exact names are planner discretion.
let oriented = input.oriented(forExifOrientation: Int32(metadata.orientation.rawValue))
let bounds = oriented.extent.integral
let width = try checkedPixelDimension(bounds.width)
let height = try checkedPixelDimension(bounds.height)
let rowBytes = try checkedMultiply(width, 4)
var rgba = Data(count: try checkedMultiply(rowBytes, height))

rgba.withUnsafeMutableBytes { storage in
    context.render(
        oriented,
        toBitmap: storage.baseAddress!,
        rowBytes: rowBytes,
        bounds: bounds,
        format: .RGBA8,
        colorSpace: sRGB
    )
}
guard stride(from: 3, to: rgba.count, by: 4).allSatisfy({ rgba[$0] == 255 }) else {
    throw BeautyError.invalidInput
}
```

The implementation must also consume `isInputMirrored` at this boundary and translate the final image to zero origin; downstream metadata becomes `.up` and `isInputMirrored == false`. [VERIFIED: locked normalize-once decision and existing mapper behavior]

### Pattern 2: Branch before behavior changes

```swift
let validated = try BeautySDKResources.validate(parameters: parameters)
guard BeautyEffectResolver.requiresAdmittedLocalRetouch(parameters: validated) else {
    return try processLegacyStillImageExactlyAsShipped(
        image: image,
        metadata: metadata,
        parameters: validated
    )
}

let request = try makeLocalStillImageRequest(
    image: image,
    metadata: metadata,
    parameters: validated
)
return renderStillImage(request: request, parameters: validated)
```

The production admission function returns false throughout Phase 53 because no candidate has passed Phase 54; tests may inject an internal admission decision while still calling the public facade. Do not encode candidate names or add inert cases. [VERIFIED: `53-CONTEXT.md`]

### Pattern 3: Actual lip provenance in the existing map

```swift
package struct BeautyObservedLipSupport: Equatable, Sendable {
    package let outer: [CoordinatePoint]?
    package let inner: [CoordinatePoint]?
}

// Copy raw Vision innerLips/outerLips in the existing landmarks payload,
// preflight and map each region independently through the existing mapper,
// then attach it only to the request's selected BeautyFaceObservation.
```

Use a fixed pre-map count ceiling, finite closed-unit validation, one `mapPoints` call per accepted region, and local failure so malformed inner support does not erase valid outer support or the face. Keep the existing synthesized `FaceGeometry.outerLips/innerLips` behavior unchanged until a later admitted provider explicitly consumes observed support. [VERIFIED: established face/eyebrow support patterns and compatibility constraint]

### Pattern 4: Exact compatibility admission checklist

Every later admitted field must be physically and behaviorally independent, appended as a trailing-default initializer argument, initialized through the existing finite unit clamp, decoded through `decodeFloatIfPresent`, included in `normalized()`, absent from old payloads/presets, and excluded from pixel-buffer/realtime resolution. Exact encoded-key and stored-property counts increment only for fields whose Phase 54 gate passed. [VERIFIED: `BeautyParameters.swift`, current compatibility tests, and `53-CONTEXT.md`]

## Don't Hand-Roll

| Problem | Don't build | Use instead | Why |
|---|---|---|---|
| EXIF rotations/mirrors | Eight bespoke pixel loops | `CIImage.oriented(forExifOrientation:)` | Apple owns the orientation transforms and the spike proved all eight lossless cases with this API. [CITED: https://developer.apple.com/documentation/coreimage/ciimage/oriented%28forexiforientation%3A%29] [VERIFIED: spike harness] |
| Color conversion | Channel matrices or device RGB assumptions | `CIContext` with explicit sRGB working/destination spaces | ICC/profile conversion and destination matching are Core Image responsibilities. [CITED: https://developer.apple.com/documentation/coreimage/cicontextoption/workingcolorspace] |
| Face/landmark detection | Per-feature requests or cached coordinates | Existing `VNDetectFaceLandmarksRequest` and mapped observation | One request already returns the required Vision regions. [VERIFIED: codebase grep] |
| Selected-face behavior | A new local-retouch face chooser | Existing `FaceSelectionPolicy` semantics | The decision is locked and already tested. [VERIFIED: `53-CONTEXT.md` and `FaceSelectionPolicyTests.swift`] |
| Typed diagnostics | Raw framework errors or metadata payloads | Existing `BeautyError.invalidInput` / `.unsupportedPixelFormat` and redacted summaries | These are payload-free and already stable; add a case only if it creates a distinct safe caller action. [VERIFIED: `BeautyError.swift` and `SECURITY.md`] |
| Lip geometry | Face-box-derived or synthetic teeth proxy | Actual `VNFaceLandmarks2D.outerLips` / `innerLips` copied by the current request | The current synthetic adapter paths are compatibility geometry, not observed local-retouch evidence. [VERIFIED: codebase grep and spike requirements] |

## Common Pitfalls and Nonclaims

### Canonicalizing every still request
**What goes wrong:** Default/no-local requests get new extent, color, or byte behavior and PATH-06 fails. [VERIFIED: current legacy branch and locked compatibility]
**Avoidance:** Canonicalize only after admitted-local activation; keep one explicitly named legacy helper containing the current sequence. [VERIFIED: recommended branch architecture]

### Treating a color-space tag as opacity proof
**What goes wrong:** An RGB image can still contain partial/zero alpha. [VERIFIED: image model semantics]
**Avoidance:** Scan the actual rendered RGBA8 alpha bytes and reject before Vision. Do not composite or force alpha to one. [VERIFIED: locked rejection policy]

### Assigning sRGB to unknown input
**What goes wrong:** Unknown/non-RGB semantics are reinterpreted instead of color-managed and rejected. [CITED: https://developer.apple.com/documentation/coreimage/ciimage/colorspace]
**Avoidance:** Require a known non-extended RGB color space on the admitted path; keep unknown-space compatibility only on the inactive legacy path. [VERIFIED: locked supported-RGB policy]

### Applying `.up` without rotating pixels
**What goes wrong:** Vision and render coordinates disagree. [VERIFIED: Apple orientation documentation and existing mapper]
**Avoidance:** Physically orient/mirror once, reset origin, then pass `.up`/not-mirrored metadata to both Vision and mapping. [VERIFIED: spike integration recipe]

### Rendering canonical pixels twice
**What goes wrong:** A `createCGImage` followed by a CGContext/CIContext copy creates a second conversion and weakens the single-raster oracle. [VERIFIED: spike source has this evidence-only extra copy; locked production contract is stricter]
**Avoidance:** Render directly into the owned RGBA8 allocation and build all CI/CG/provider views over that storage. [VERIFIED: Apple bitmap-render API]

### Letting current device-RGB geometry reinterpret a local-active image
**What goes wrong:** Combined shipped geometry plus local retouch loses explicit sRGB ownership. [VERIFIED: `BeautyGeometryEffectPipeline.swift`]
**Avoidance:** Add a canonical-aware sRGB overload or byte-oriented handoff for the active branch; do not change the legacy overload. [VERIFIED: recommended compatibility architecture]

### Running Vision or mapping per future feature
**What goes wrong:** Teeth, sclera, and eyelid work can see different observations or retain different support lifetimes. [VERIFIED: spike findings]
**Avoidance:** Extend one observation payload now and pass one local request context to all later providers. [VERIFIED: locked exactly-once decision]

### Adding candidate fields in Phase 53
**What goes wrong:** A closed Phase 54 gate leaves a public/inert compatibility footprint. [VERIFIED: `53-CONTEXT.md`]
**Avoidance:** Use an internal test admission seam; keep `BeautyParameters`, CodingKeys, presets, provider cases, and renderer inventory at exactly the shipped 59-field state. [VERIFIED: locked gate policy]

### Overclaiming encoded input validation
**What goes wrong:** `CIImage` no longer exposes the original encoded byte stream or all container auxiliaries. [CITED: https://developer.apple.com/documentation/coreimage/ciimage/properties]
**Avoidance:** Enforce decoded extent/color/alpha facts that are observable, retain the Demo's predecode byte ceiling where it exists, and state that the SDK CIImage facade cannot validate encoded bytes/gain maps. [VERIFIED: codebase grep and locked observability clause]

### Overclaiming concurrency, cancellation, HDR, or performance
The public engine/result sendability decision remains TD-013, the current call is synchronous, HDR/gain maps are deferred, and spike macOS timings/memory are non-budgets. Phase 53 may prove local values are not cached and that independent request values do not share payloads, but must not claim same-engine concurrent safety, cooperative cancellation, device performance, or release readiness. [VERIFIED: `STATE.md`, `PLANS.md`, spike integration reference]

## State of the Art / Required Delta

| Current approach | Phase 53 approach | Impact |
|---|---|---|
| Caller CIImage plus separate orientation flows to Vision/mapper. [VERIFIED: codebase grep] | One physically up-oriented, zero-origin canonical raster; downstream receives `.up`. [VERIFIED: locked decision] | Removes split orientation ownership. |
| Core Image/device-RGB rendering remains implicit or device-dependent in parts of the path. [VERIFIED: codebase grep] | Explicit sRGB working/destination space and `.RGBA8` owned bytes for local-active requests. [CITED: https://developer.apple.com/documentation/coreimage/cicontext] | Makes the local input/output basis testable. |
| Raw Vision lips become only group availability; Effects synthesizes lip shapes. [VERIFIED: codebase grep] | Add independently optional actual mapped lip paths alongside existing observed eye/face/brow support. [VERIFIED: recommended reuse of established pattern] | Enables future teeth support without a second request or proxy. |
| One shared resolver is used by both still and pixel-buffer facade paths. [VERIFIED: codebase grep] | Feature-neutral still-only admission wraps the existing resolver; pixel-buffer remains structurally isolated. [VERIFIED: locked decision] | Prevents future public fields from silently reaching realtime. |
| Exact public inventory is 59. [VERIFIED: codebase grep and focused XCTest] | Still 59 after Phase 53; later phases increment only admitted rows. [VERIFIED: locked decision] | Closed gates leave no API debris. |

## Validation Architecture

### Test Framework

| Property | Value |
|---|---|
| Framework | XCTest through SwiftPM, package tools 6.0. [VERIFIED: `Package.swift`] |
| Config file | `BeautySDK/Package.swift`. [VERIFIED: codebase grep] |
| Quick run command | `swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests` [VERIFIED: existing SwiftPM filter convention] |
| Full suite command | `swift test --package-path BeautySDK` [VERIFIED: `AGENTS.md`/repository evidence] |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test type | Automated command | File exists? |
|---|---|---|---|---|
| PATH-01 | Both existing public image overloads reach the injected admitted-local foundation; no parallel public entry/type appears. | facade + static boundary | `swift test --package-path BeautySDK --filter BeautyEngineLocalRetouchFoundationTests` | No - Wave 0 |
| PATH-02 | Eight orientation/mirror cases produce the same zero-origin, opaque, sRGB RGBA8 bytes and the same object reaches detector/render test seams. | unit + integration | `swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests` | No - Wave 0 |
| PATH-03 | Invalid extent/overflow/over-limit/orientation/gray/CMYK/unknown/extended/transparent inputs fail with allowlisted `BeautyError` before detector/provider counters increment. | adversarial unit | `swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests` | No - Wave 0 |
| PATH-04 | One admitted request with all private-support demands invokes canonicalizer once, observation provider once, mapping stage once, and carries no prior lip/eye/brow/face support into valid-invalid-valid sequences. | detection + facade integration | `swift test --package-path BeautySDK --filter StillImageRequestSupportTests` | No - Wave 0 |
| PATH-05 | Pixel-buffer calls with the same parameters keep output/summary and show zero canonicalizer/detector/local-context invocations; reset adds no local state. | facade regression | `swift test --package-path BeautySDK --filter BeautyEngineLocalRetouchFoundationTests` | No - Wave 0 |
| PATH-06 | Exact 59 stored/encoded keys, legacy payloads, five bundled presets, source defaults, no-local output bytes, and public facade output remain unchanged. | compatibility/regression | `swift test --package-path BeautySDK --filter BeautyParametersTests && swift test --package-path BeautySDK --filter BeautyResourceCatalogTests && swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` | Existing tests; add Phase 53 assertions |
| PATH-07 | No candidate field/key/provider/renderer case is added; reusable test helper documents exact checks later admissions must satisfy. | inventory/static contract | `swift test --package-path BeautySDK --filter BeautyParametersTests` | Existing test file; add assertions/helper |

### Required synthetic fixtures

- Build tiny asymmetric RGBA bitmaps in memory with explicit sRGB and Display P3 profiles; do not add tracked portrait media. [VERIFIED: locked test-fixture discretion]
- Cover all eight `CGImagePropertyOrientation` cases and `isInputMirrored` true/false, including width/height swaps and zero-origin output. [VERIFIED: Apple orientation cases and existing metadata model]
- Create opaque, partial-alpha, gray, unknown-color-space, extended-sRGB, fractional/nonzero extent, exact-limit, one-over, and allocation-overflow cases. [VERIFIED: locked rejection policy]
- Inject distinct lip/eye/brow/face payload counts into consecutive and independent parallel detector values, then assert only the current result contains them and all descriptions/reflection remain aggregate-only. [VERIFIED: established support lifecycle test pattern]

### Sampling Rate

- **Per task commit:** Run the new test class for the touched owner plus `git diff --check`. [VERIFIED: repository workflow]
- **Per wave merge:** Run the three new focused suites and existing `BeautyParametersTests`, `BeautyResourceCatalogTests`, `BeautyEngineTests`, `BeautyEngineMetadataCompatibilityTests`, `BeautyEngineGeometryFacadeTests`, `VisionFaceDetectorTests`, `FaceObservationMappingTests`, and `FaceSelectionPolicyTests`. [VERIFIED: live test inventory]
- **Phase gate:** Full SwiftPM suite green, privacy/public-surface scans green, exact 59-field/current-preset inventory green, and no production local provider/candidate field. [VERIFIED: locked phase scope]

### Wave 0 Gaps

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyCanonicalStillImageTests.swift` - orientation/color/alpha/ceiling/error ordering for PATH-02/03.
- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift` - facade admission, safe continuation, exactly-once collaborators, pixel-buffer isolation for PATH-01/04/05.
- [ ] `BeautySDK/Tests/BeautyDetectionTests/StillImageRequestSupportTests.swift` - actual lip mapping, aggregate diagnostics, valid-invalid-valid and independent parallel value isolation for PATH-04.
- [ ] Extend `BeautyParametersTests.swift`, `BeautyResourceCatalogTests.swift`, and facade/output regressions with Phase 53 exact-59/no-candidate/no-local byte-neutral assertions for PATH-06/07.
- [ ] Add a fail-closed source-boundary checker only if existing direct XCTest/static scans cannot prove no public/SPI raw support, no pixel-buffer local calls, and no candidate API inventory. [VERIFIED: repository checker pattern]

## Security Domain

Security enforcement is enabled at ASVS L1 in `.planning/config.json`. [VERIFIED: `.planning/config.json`]

### Applicable ASVS Categories

| ASVS Category | Applies | Standard control |
|---|---|---|
| V2 Authentication | No | The phase is an in-process SDK image boundary with no identity/authentication surface. [VERIFIED: phase scope] |
| V3 Session Management | No | There is no session/token lifecycle. [VERIFIED: phase scope] |
| V4 Access Control | No | There is no privilege or resource authorization decision. [VERIFIED: phase scope] |
| V5 Input Validation | Yes | Finite/size/overflow/orientation/RGB/range/opacity allowlisting before Vision; fail closed with fixed typed errors. [VERIFIED: locked policy] |
| V6 Cryptography | No | No storage, transport, secret, signature, or cryptographic operation is added. [VERIFIED: phase scope] |

### Threat Patterns

| Pattern | STRIDE | Mitigation |
|---|---|---|
| Oversized/fractional/overflow-shaped extent causes excessive allocation or integer overflow | Denial of Service | Check finite positive extent and configured pixel ceiling before integer conversion; use checked row/total-byte multiplication; recheck oriented integral extent. [VERIFIED: existing ceiling pattern plus locked policy] |
| Alpha/background changes Vision interpretation | Tampering | Reject any nonopaque rendered pixel; never composite or set alpha to one. [VERIFIED: spike result and locked policy] |
| Non-RGB/unknown/extended input is silently reinterpreted | Tampering | Allow only known, output-capable, non-extended RGB color spaces; explicit sRGB render. [CITED: https://developer.apple.com/documentation/coregraphics/cgcolorspace] |
| Raw landmarks/lips/pupils leak through descriptions, errors, metrics, or persistence | Information Disclosure | Package-only non-Codable carriers, stack-local lifetime, fixed errors, aggregate-only summaries, and forbidden-token/reflection tests. [VERIFIED: `SECURITY.md` and established carrier pattern] |
| Stale support affects a later request | Tampering | No engine/static/cache field for canonical/request support; valid-invalid-valid, no-face, reset, and independent parallel-value tests. [VERIFIED: locked lifecycle contract] |
| Later local field activates pixel-buffer/realtime | Tampering | Still-only admission type is unreachable from the pixel-buffer overload; invocation-count and static call-graph tests. [VERIFIED: locked runtime isolation] |

## Assumptions Log

| # | Claim | Section | Risk if wrong |
|---|---|---|---|
| - | None. Recommendations are derived from locked decisions, live source/tests, the validated project spike, or cited Apple documentation. | - | - |

## Open Questions / Explicit Residuals (RESOLVED)

1. **Encoded input observability is intentionally incomplete.** The public SDK accepts `CIImage`, so Phase 53 cannot enforce `maximumInputByteCount`, inspect the original container's malformed orientation value, or prove gain-map absence after host decoding. Plan acceptance around observable decoded properties and document this limitation; do not add a Data/URL overload because the public entry decision is locked. [VERIFIED: live facade and Apple `CIImage.properties` documentation]
2. **Same-engine concurrent invocation is not a Phase 53 claim.** TD-013 keeps generic-result/sendability work outside the milestone, while `BeautyEngine` currently owns mutable detector selection state. Prove that request support has no shared owner and that independent request values do not cross; do not broaden the plan into engine concurrency redesign. [VERIFIED: `STATE.md`, `PLANS.md`, and codebase grep]
3. **Cross-profile landmark/mask byte identity is not an acceptance criterion.** Require correct sRGB canonicalization and containment; profile-dependent Vision stability thresholds require rights-approved real fixtures in later evidence phases. [VERIFIED: Spike 013 result and deferred Phase 54 scope]

## Sources

### Primary (HIGH confidence)

- Live sources: `BeautyEngine.swift`, `BeautyEngineGeometryDetection.swift`, `VisionFaceDetector.swift`, `CoordinateMapper.swift`, `FaceSelectionPolicy.swift`, `BeautyFaceObservation.swift`, `BeautyParameters.swift`, `BeautyInputMetadata.swift`, `BeautyError.swift`, `BeautyConfiguration.swift`, `BeautyEffectResolver.swift`, `BeautyColorEffectPipeline.swift`, and `BeautyGeometryEffectPipeline.swift`. [VERIFIED: codebase grep]
- Live tests: engine, metadata compatibility, geometry facade, parameters, resources, detector, observation mapping, coordinate mapper, and face selection tests. [VERIFIED: codebase grep]
- Project contracts: `AGENTS.md`, `PLANS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, Phase 53 CONTEXT, requirements, state, and roadmap. [VERIFIED: repository reads]
- Project skill: `spike-findings-beauty/references/still-image-integration.md` and exact shared Spike 013 harness. [VERIFIED: project skill]
- [Apple CIContext](https://developer.apple.com/documentation/coreimage/cicontext) - bitmap rendering, reuse, threading, explicit format/color-space APIs.
- [Apple Core Image working color space](https://developer.apple.com/documentation/coreimage/cicontextoption/workingcolorspace) - automatic source/working/destination matching.
- [Apple CIImage orientation](https://developer.apple.com/documentation/coreimage/ciimage/oriented%28forexiforientation%3A%29) and [Image I/O orientation](https://developer.apple.com/documentation/imageio/cgimagepropertyorientation) - rotation/mirror semantics.
- [Apple CIImage colorSpace](https://developer.apple.com/documentation/coreimage/ciimage/colorspace) and [properties](https://developer.apple.com/documentation/coreimage/ciimage/properties) - decoded-image observability limits.
- [Apple VNImageRequestHandler](https://developer.apple.com/documentation/vision/vnimagerequesthandler) and [VNDetectFaceLandmarksRequest](https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest) - single-image handler and face-landmark request behavior.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no new dependency; APIs verified in current official Apple docs and local toolchain. [VERIFIED: official docs and local CLI]
- Architecture: HIGH - follows locked decisions, current package direction, and established observed-support patterns. [VERIFIED: repository contracts and codebase grep]
- Pitfalls: HIGH - observed directly in live code or validated by the wrapped still-image spike. [VERIFIED: codebase grep and spike harness]
- Validation: HIGH - all referenced frameworks/suites exist; new test gaps are explicit. [VERIFIED: `Package.swift` and test inventory]

**Research date:** 2026-07-30
**Valid until:** 2026-08-29 (stable Apple/platform and repository-local design; recheck if Phase 54 changes admission outcomes). [VERIFIED: 30-day stable-domain convention]
