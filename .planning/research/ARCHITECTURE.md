# Architecture Research

**Domain:** Still-image local facial retouch for teeth whitening, guarded sclera redness reduction, and gated upper-eyelid fullness reduction
**Researched:** 2026-07-30
**Confidence:** HIGH for package boundaries, shared-input/detection ownership, and teeth/sclera composition; MEDIUM for the future upper-eyelid implementation and optimized device render strategy

## Recommendation

Keep the existing Swift package and dependency graph unchanged. Add one canonical still-image boundary in `BeautyRender`, keep the existing selected-face Vision request as the sole detection owner in `BeautyDetection`, and add a target-internal local-retouch subsystem in `BeautyEffects`. `BeautySDK.BeautyEngine` remains the only host-facing orchestrator; it must never return masks, landmarks, pupils, teeth geometry, eyelid bands, or vein-like descriptors.

The most important structural change is to stop treating the current `BeautyColorEffectPipeline` as the complete still-image orchestrator. Introduce a package-only `BeautyStillImageEffectPipeline` in `BeautyEffects` that adapts the selected observation once, produces the existing base color/lip result, asks independent local-retouch providers for request-local support, gives all accepted masks to one composition owner, then invokes the existing geometry pipeline once. This creates an exact original-pixel ownership boundary without adding a second warp path.

Ship `teethWhitening` and `scleraRednessReduction` as independent zero-default still-image controls after their separate evidence gates pass. Do not add or route a public upper-eyelid-fullness control merely to make the three-feature list look complete. `upperEyelidFullnessReduction` enters the public model only after licensed real positives/negatives validate a non-warp tone/frequency implementation. Until then, its provider, facade route, and branch promotion remain absent.

## Standard Architecture

### System Overview

```text
Host / BeautyDemo
  |
  | public BeautyParameters + CIImage + BeautyInputMetadata
  v
+------------------------------------------------------------------+
| BeautySDK facade                                                  |
| BeautyEngine validates ceilings and processing mode              |
|   -> calls normalization once                                    |
|   -> requests detection at most once                             |
|   -> returns output + redacted summary/warnings/aggregate metrics|
+-------------------------+----------------------------------------+
                          |
          +---------------+----------------+
          |                                |
          v                                v
+--------------------------+    +----------------------------------+
| BeautyRender             |    | BeautyDetection                  |
| CanonicalStillImage-     |    | one VNDetectFaceLandmarksRequest |
| Normalizer               |    | deterministic selected face      |
| up + sRGB + RGBA8        |    | mapped eye/pupil, lip, brow data  |
| opaque-only validation   |    | package-only request values       |
+-------------+------------+    +----------------+-----------------+
              |                                  |
              +----------------+-----------------+
                               v
+------------------------------------------------------------------+
| BeautyEffects                                                    |
| BeautyStillImageEffectPipeline                                   |
|   1. resolve independent intent / feature requirements           |
|   2. adapt selected support once                                 |
|   3. render existing base color + lip behavior                   |
|   4. request independent masks                                   |
|        TeethMaskProvider                                         |
|        GuardedScleraMaskProvider (left/right independently)      |
|        UpperEyelidFullnessProvider (absent until its gate passes) |
|   5. LocalRetouchCompositionOwner                                |
|        clamp -> hard-contain -> reject overlap -> original pixel |
|   6. existing BeautyGeometryEffectPipeline once                  |
+-----------------------------+------------------------------------+
                              |
                              v
              canonical result -> facade orientation restore
                              -> public BeautyResult
```

No new target or package is justified. `Package.swift` already permits exactly the required direction: `BeautySDK` can orchestrate all internal targets, `BeautyEffects` can consume detection values and render primitives, and `BeautyDetection` remains independent of effects/render implementation.

### Component Responsibilities

| Component | Status | Responsibility | Must not own |
| --- | --- | --- | --- |
| `BeautyEngine` / still-image route | Modify | Validate pixel ceiling first; normalize once; derive still-image requirements; call one detector request; call one Effects orchestrator; restore facade-compatible orientation; merge redacted diagnostics. | Anatomy logic, masks, thresholds, a second Vision request, realtime activation. |
| `CanonicalStillImageNormalizer` (`BeautyRender`) | New | Reuse one explicit `CIContext`; apply EXIF/input-mirror transform once; render a zero-origin, up-oriented, sRGB RGBA8 opaque image; retain request-local inverse presentation transform. | Face selection, masks, effect parameters, diagnostics containing metadata payloads. |
| `VisionFaceDetector` (`BeautyDetection`) | Modify | Accept a dedicated canonical-still call whose Vision orientation is always `.up`; perform the single landmarks request; select the existing deterministic primary face; copy/map required regions once. | Color scoring, mask construction, effect routing, render passes. |
| `BeautyFaceObservation` support carriers | Modify/new | Continue carrying actual request-local eye contours/pupils and brows; add actual mapped `innerLips` and `outerLips` support for retouch rather than using synthetic `FaceGeometry` lip proxies. | Codable/public conformance, caches, persistent stable signatures, raw diagnostics. |
| `BeautyEffectRequirements` / local intent | Modify/new (`BeautyEffects`) | Distinguish legacy geometry need from teeth, sclera, and optional eyelid need; make pixel-buffer mode explicitly unsupported/no-op for all three retouch strengths. | Geometry or mask data. |
| `BeautyStillImageEffectPipeline` | New (`BeautyEffects`) | Become the package-only still-image effect orchestrator; build semantic context once and coordinate base color, local retouch, and the existing unified geometry path. | Public API, Vision execution, persistent state. |
| `LocalRetouchRequestContextAdapter` | New (`BeautyEffects`) | Validate selected request support into actual mouth, per-eye, and eye/brow semantic values; never fall back to synthetic geometry for new retouch fields. | Pixel mutation, public support export, retry/detection. |
| `TeethMaskProvider` | New (`BeautyEffects/LocalRetouch`) | Fixed inner-lip safety baseline plus seeded adaptive growth inside a narrow outer-lip envelope; return an accepted soft mask or local no-op. | Whole-mouth tinting, learned-model fallback, public teeth geometry. |
| `GuardedScleraMaskProvider` | New (`BeautyEffects/LocalRetouch`) | Validate each eye independently; create aperture/iris/highlight hard envelope before color scoring; feather and hard re-clip; return separate left/right outcomes. | Guessing pupils, peer-eye failure propagation, whole-eye/global red suppression. |
| `UpperEyelidFullnessProvider` | Deferred, not scaffolded into production routing | If the evidence gate passes, build a paired eye/brow band and tone/frequency candidate from original pixels. | Warp, eye opening/lift, brow motion, smoothing proxy, public field before evidence. |
| `LocalRetouchCompositionOwner` | New (`BeautyEffects/LocalRetouch`) | Sole owner of all request masks after providers return; validate dimensions/weights, re-apply hard containment, detect pairwise collisions, and compose accepted transforms from original canonical pixels over the existing base. | Transform precedence, persisted masks, anatomy-specific mask creation. |
| Existing `BeautyColorEffectPipeline` | Modify/split | Expose base color/lip work separately from geometry so the still-image orchestrator can insert the owned local composition boundary. | Vision/support acquisition or local-mask ownership. |
| Existing `BeautyGeometryEffectPipeline` | Reuse unchanged in role | Remain the only geometry delivery path, invoked once after local color composition. | `去脂` proxy warp or retouch masks. |
| `BeautyResources` | No change for teeth/sclera | None; deterministic Apple-framework/local algorithms require no model resource. | Research-only EasyPortrait model or unapproved weights. |

## Recommended Project Structure

```text
BeautySDK/Sources/
├── BeautyCore/
│   └── Models/
│       └── BeautyParameters.swift                 # modify: 2 required scalars; 3rd only after gate
├── BeautyRender/
│   └── StillImage/
│       └── CanonicalStillImageNormalizer.swift    # new: one up/sRGB/RGBA8 opaque boundary
├── BeautyDetection/
│   ├── BeautyFaceObservation.swift                # modify: request-local actual lip support
│   ├── VisionFaceDetector.swift                   # modify: canonical-still single-request entry
│   └── LocalRetouchObservedSupport.swift          # new: package-only lip carrier if separated
├── BeautyEffects/
│   ├── Planning/
│   │   ├── BeautyEffectResolver.swift             # modify: mode + independent detection requirements
│   │   ├── BeautyEffectPlan.swift                 # modify: independent effective strengths only
│   │   └── LocalRetouchIntent.swift               # new: target-internal feature intent
│   ├── LocalRetouch/
│   │   ├── LocalRetouchRequestContext.swift       # new: validated ephemeral supports
│   │   ├── LocalRetouchMask.swift                 # new: internal soft mask + hard envelope
│   │   ├── TeethMaskProvider.swift                # new
│   │   ├── GuardedScleraMaskProvider.swift        # new
│   │   ├── LocalRetouchTransforms.swift           # new: deterministic original-pixel functions
│   │   └── LocalRetouchCompositionOwner.swift     # new: sole ownership/collision boundary
│   └── Render/
│       ├── BeautyStillImageEffectPipeline.swift   # new orchestrator
│       ├── BeautyColorEffectPipeline.swift        # modify: base color/lip stage
│       └── BeautyGeometryEffectPipeline.swift     # reuse
└── BeautySDK/
    ├── BeautyEngine.swift                         # modify still-image path only
    └── BeautyEngineGeometryDetection.swift        # rename/modify to face-context route
```

Do not create `BeautyTeeth`, `BeautyEyes`, or `BeautyRetouch` package targets. The providers share the same canonical pixels, selected observation, composition owner, diagnostics, and tests; splitting targets would add carriers and tempt public/support leakage without an independent release boundary.

## Architectural Patterns

### 1. Canonical Request Boundary

**What:** Every accepted still image is rasterized exactly once to an explicit opaque, up-oriented, zero-origin, sRGB RGBA8 representation before Vision or any effect reads pixels. The normalizer also records the inverse presentation transform needed to preserve the existing facade's storage-orientation behavior.

**Why here:** Current production passes the original `CIImage` to Vision with caller metadata and passes the original image separately to Effects. That is insufficient for local color scoring because orientation and implicit working color space can diverge. `BeautyRender` already owns reusable render contexts; `BeautySDK` is the orchestration owner.

**Contract:**

```swift
// Conceptual package-only shape; exact API may differ.
struct CanonicalStillImage {
    let image: CIImage          // up, zero-origin, sRGB, RGBA8, alpha == 1
    let originalExtent: CGRect
    let presentationTransform: CGAffineTransform
}
```

The facade validates the configured pixel ceiling before allocating this representation. Any alpha below the opaque contract, malformed orientation at an encoded-input boundary, non-RGB input, unsafe extent, or failed rasterization returns the existing redacted typed input error before Vision. Missing EXIF orientation may default to `.up` only where the encoded-input API already defines that behavior; it must not be guessed later.

Because current `BeautyResult<CIImage>` has no output-orientation field, restore the final canonical result to the caller's original storage orientation at the facade boundary. This preserves compatibility while keeping all detection, masks, transforms, and verification canonical. All eight EXIF rotation/mirror encodings must compare equivalently after re-normalization.

### 2. One Detection Request, Requirement-Aware Eligibility

**What:** `BeautyEffectResolver` exposes package-only detection requirements for the current parameter snapshot and processing mode. The facade calls `VisionFaceDetector` once if legacy geometry or any still-image local-retouch field is active.

**Why:** The current trigger is named `requiresFaceGeometry` and the detector filters on `BeautyFaceLandmarks.hasRequiredGeometry`, which requires contour, both eyes, nose, and outer lips. Teeth or sclera work must not require an unrelated nose/contour, and a missing local region must degrade locally rather than make the selected request disappear.

Use a requirement-aware filter without changing deterministic face ownership:

- Existing geometry-only requests retain existing usability requirements.
- Retouch-only requests require a confident mapped face and at least one requested local support family.
- Mixed requests select the same deterministic primary face; they do not switch faces to maximize feature coverage.
- Once selected, each provider decides its own support eligibility. Missing teeth must not select a different face than sclera.
- The still-image selection call is stateless with respect to raw support and face IDs; no contours, masks, pupils, or stable geometry signatures survive the request.

The canonical-still detector entry hardcodes Vision orientation `.up`; it must not accept arbitrary orientation metadata after normalization. Apple documents that a landmarks request detects facial features such as eyes and mouth, and that landmark points are face-bounding-box normalized. These regions are coarse anatomical support, not semantic teeth or fullness labels.

### 3. Independent Providers, Shared Composition Owner

**What:** Providers own anatomical selection and feature-local rejection. The composer owns mask validity, cross-feature ownership, and pixel writes.

Provider result shape should be internal and non-Codable:

```swift
struct LocalRetouchRegion {
    let feature: LocalRetouchFeature
    let region: LocalRetouchRegionID   // teeth, leftSclera, rightSclera, future eyelid side
    let softMask: LocalRetouchMask
    let hardEnvelope: LocalRetouchMask
}
```

The composer clamps each weight, multiplies by the final hard envelope, and checks all active feature claims. At a pixel claimed by more than one feature, it increments only an aggregate collision count and writes the original canonical pixel. It never chooses teeth over sclera, sclera over eyelid, maximum strength, or array order.

The composition inputs are deliberately two images:

- `original`: immutable canonical pixels; every accepted local transform reads only this image.
- `base`: existing color/filter/lip result; pixels outside the sanitized local union remain byte-equivalent to this image.

For one owned pixel, the composer writes exactly one candidate derived from `original`. For an ownership collision, it writes `original`. Afterward, the existing geometry pipeline may warp the composed image once. This preserves existing geometry ownership and avoids an unsupported second warp or mask-coordinate transform.

### 4. Field- and Eye-Local Degradation

**What:** Local retouch is a set of independent outcomes, not one all-or-nothing pass.

| Failure | Exact outcome |
| --- | --- |
| Transparent/non-RGB/invalid canonical input | Reject before Vision and before any mask. |
| Detector unavailable/no selected face | All face-dependent local effects no-op; safe existing face-independent color/filter work may continue with redacted degradation. |
| Missing/malformed lips or no safe teeth seed | Teeth no-op only; both sclera eyes continue independently. |
| Left eye closed/missing pupil/guard rejected | Left sclera no-op only; right sclera and teeth continue. |
| Right eye rejected | Right sclera no-op only; left sclera and teeth continue. |
| Feather expands past anatomy | Re-clip to the provider hard envelope; never composite the expanded support directly. |
| Invalid mask dimensions/non-finite weights | Reject the owning region; do not repair with stale or sibling support. |
| Cross-mask collision | Original canonical pixel; aggregate count only. |
| Eyelid gate fails | No public field, provider route, or proxy behavior; teeth/redness release remains unaffected. |
| Pixel-buffer/realtime request has nonzero retouch scalars | Strengths resolve to zero with fixed aggregate unsupported-mode evidence; no Vision request and no local pass. |

### 5. Public Scalars as Feature Gates, Not Shared Domain Switches

The public parameter model remains the only host control surface, but the new fields must not be folded into `lipColor`, `.mouth`, `upperEyelidLift`, or `.eyes` geometry strengths.

- Add independent `teethWhitening` and `scleraRednessReduction` positive-only zero-default scalars.
- Give each its own cap, effective strength, active/skipped accounting, fixed warning reason, and renderer case.
- Add `upperEyelidFullnessReduction` only after its feasibility gate. Do not ship a permanently inert public field or alias it to a geometry field.
- Extend the detection trigger to all active still-image face-dependent fields, but keep feature eligibility independent after the single selection.
- Preserve legacy JSON/preset decoding by defaulting missing keys to zero; bundled presets remain unchanged and neutral.
- Keep feature gating local/static. No remote config, entitlement, model download, or hidden network gate is warranted.

## Data Flow and Ownership

### Still-Image Request Flow

```text
CIImage + typed metadata + immutable parameters
  -> BeautyEngine validates finite extent and configured pixel ceiling
  -> BeautySDKResources validates/normalizes public parameters
  -> CanonicalStillImageNormalizer
       orientation/mirror once
       explicit sRGB RGBA8 render once
       reject transparency/non-RGB
  -> BeautyEffectResolver derives requirements for `.stillImage`
  -> zero or one Vision landmarks request on canonical pixels, orientation `.up`
  -> deterministic selected face
  -> BeautyStillImageEffectPipeline
       adapt selected observation once
       resolve existing plan + independent local-retouch intent
       create existing base color/lip image
       TeethMaskProvider -> teeth region or no-op
       GuardedScleraMaskProvider -> left/right regions or local no-ops
       [future gated eyelid provider]
       LocalRetouchCompositionOwner
          final containment + collision suppression
          one original-pixel composition
       existing unified geometry pipeline once
  -> normalizer-owned inverse presentation transform
  -> BeautyResult(output, redacted detection summary, warnings, aggregate metrics)
  -> request-local observation/context/masks released
```

### Ownership Matrix

| Data / state | Sole owner | Lifetime | Public/persisted form |
| --- | --- | --- | --- |
| Canonical pixels and inverse presentation transform | `BeautyRender` value held by facade request | One `processResult` call | Output image only after facade restoration; no raw metadata dump. |
| Vision request and platform landmark regions | `BeautyDetection.VisionFaceDetector` | One detector call | None. |
| Selected mapped eye/pupil/lip/brow support | `BeautyDetection.BeautyFaceObservation` | Current request | None; aggregate availability/counts only. |
| Validated local semantic context | `BeautyEffects.LocalRetouchRequestContextAdapter` | Current Effects call | None. |
| Provider hard envelopes and soft masks | Owning provider until handed to composer | Current Effects call | None. |
| Sanitized mask union and collision decisions | `LocalRetouchCompositionOwner` | Composition call only | Counts/timings only. |
| Original canonical pixel source | `LocalRetouchCompositionOwner` read-only reference | Composition call | Never logged/persisted. |
| Existing geometry points | Existing `BeautyEffects` geometry pipeline | Current request | Existing aggregate point counts only. |
| Public result | `BeautySDK` facade | Caller-owned result lifetime | Image plus geometry-free summaries/warnings/metrics. |

## Internal Boundaries and Integration Points

| Boundary | Communication | Required invariant |
| --- | --- | --- |
| `BeautySDK -> BeautyRender` | package-only normalization call | Exactly one canonical rasterization before detection/effects; one inverse transform at handoff. |
| `BeautySDK -> BeautyDetection` | package-only canonical-still detector entry | At most one landmarks request; orientation fixed `.up`; no local-retouch retry. |
| `BeautyDetection -> BeautyEffects` | package-only immutable selected observation | Actual mapped lip/eye/pupil/brow support only; no Vision objects or synthetic retouch proxies. |
| `BeautySDK -> BeautyEffects` | canonical image + parameters + selected observation | Effects adapts support once and owns all retouch semantics. |
| Provider -> composer | internal region outcome | Provider cannot write pixels; composer cannot invent anatomy. |
| Composer -> existing geometry | composed canonical image | Local color work completes once before the sole existing warp. |
| `BeautySDK -> host` | existing public result envelope | No new public geometry/mask API; only aggregate diagnostics. |

`BeautyResources` is intentionally absent from the teeth/sclera flow. If a future learned eyelid or teeth segmenter is reconsidered, it is a new gated architecture decision requiring an approved license chain, pinned resource, checksum, size review, cold/warm load ownership, and packaging evidence; it must not silently replace the deterministic provider.

## Verification Seams

The roadmap should require package-only injection seams at ownership boundaries, not public debug APIs.

| Seam | What it proves |
| --- | --- |
| Normalizer with deterministic bitmap fixture | All 8 EXIF rotation/mirror forms reach equivalent canonical pixels; sRGB/P3 stability stays within reviewed bounds; alpha/non-RGB rejection precedes Vision. |
| Counting detector provider | Zero requests for no face-dependent work/realtime local fields; exactly one for any combination of geometry/teeth/sclera/eligible eyelid. |
| Observation mapper fixtures | Actual inner/outer lips, eye contours/pupils, and brows map once; missing region stays missing; no synthetic proxy authorizes retouch. |
| Provider injection into composer | Empty teeth, empty whole-sclera, rejected left eye, rejected right eye, and future eyelid failure leave accepted siblings byte-identical to their standalone output. |
| Collision injection | Every collided pixel is counted, suppressed, and byte-identical to original canonical input. |
| Original/base dual-input oracle | Outside sanitized union equals `base`; every local candidate equals its standalone transform from `original`; disjoint fused output matches independently transformed/merged outputs. |
| Sclera geometry oracle | Color-independent envelope has zero protected iris/highlight leakage or the affected eye fails closed. |
| Sclera adversarial final-output oracle | Recolored protected iris pixels remain unchanged after score, feather, hard re-clip, transform, and composition. |
| Public facade renderer | New cases enter through `BeautySDK` only, preserve facade orientation/dimensions, and expose only aggregate diagnostics. |
| Static boundary scans | No public/SPI/Codable mask/support, no persistence/cache/global state, no sensitive keys, no model/weights, no internal Demo imports. |
| Mixed-feature regression | Existing zero-default, color/filter/lip, and 44-field unified geometry outputs remain stable outside explicitly owned local regions. |

Human review remains a release gate rather than a debug API: before/mask/after at original detail stays local and ignored; committed evidence contains commands, thresholds, counts, and sanitized qualitative results only.

## Build Order That Minimizes Risk

1. **Rights and fixture gate before production activation.** Acquire and preflight separate licensed positives/negatives for teeth, sclera, and upper-eyelid fullness. Do not let the existing already-light portrait stand in for a yellow-teeth or redness/fullness positive. This can proceed while foundation code is built, but no feature promotion waits until the end to discover missing evidence.

2. **Canonical still-image boundary.** Add `CanonicalStillImageNormalizer`, opaque-input rejection, all-eight orientation/mirror tests, explicit sRGB output, facade-compatible restoration, and target-device memory/timing instrumentation. Route existing still-image behavior through it while local effects remain zero/inert. This is the highest-leverage dependency and the largest compatibility risk.

3. **One-request detection/context foundation.** Replace the geometry-only trigger with requirement-aware still-image detection, add actual mapped inner/outer lip support, add the dedicated canonical `.up` detector entry, and prove one request plus request-local destruction. Preserve existing geometry selection and facade summaries.

4. **Composition owner before anatomy providers.** Implement the dual-input original/base compositor using injected synthetic masks and deterministic transforms. Lock final containment, per-region failure isolation, pairwise collision-to-original behavior, outside-union equality, and aggregate-only diagnostics before real teeth/sclera masks can mutate output.

5. **Teeth vertical slice and independent ship gate.** Add the teeth scalar, cap/resolver route, adaptive provider, transform, public-facade output, protected-tissue fixtures, and original-detail review. Teeth is the lower-risk vertical slice and produces a shippable result even if later eye calibration fails.

6. **Guarded sclera vertical slice and independent ship gate.** Add the redness scalar, per-eye provider, guard-before-score ordering, post-feather hard clip, both safety oracles, peer-eye isolation, public-facade output, and licensed calibration. A failed eye/redness gate must not roll back accepted teeth behavior.

7. **Combined closeout.** Prove teeth+sclera disjoint fusion, injected collisions, existing color/lip/geometry combinations, output orientation compatibility, redaction, performance/memory on target iOS devices, and full SwiftPM regression. Promote each feature independently based on its own evidence.

8. **Upper-eyelid decision last.** If licensed genuine positives and negatives prove a texture-preserving tone/frequency result, add the third scalar/provider as a separate vertical slice and include it in pairwise ownership checks. If not, make no production source/API addition for it, ship teeth/redness, and keep `去脂` plus branch `眼睛` partial. Never unblock it with the invalidated warp or an alias.

The foundation, teeth, and sclera phases should each end in a coherent runnable state. The eyelid decision is not a dependency of teeth or sclera closeout.

## Scaling and Performance Considerations

| Concern | Initial production architecture | Optimize only after evidence |
| --- | --- | --- |
| Canonicalization | One reused `CIContext`, one opaque sRGB RGBA8 render, strict pre-allocation ceiling. | Tiled/ROI normalization only if target-device memory requires it without creating divergent Vision/render pixels. |
| Detection | One selected-face landmarks request per still image when required. | No per-provider requests; do not add caching for still-image support. |
| Masks | Request-local bounded arrays/planes; provider masks released after composition. | ROI masks or private Metal textures if memory/latency evidence demands it. |
| Composition | Correctness-first original/base compositor behind one owner. | Replace the spike's slower whole-frame Swift CPU loop with bounded ROI, Core Image, or Metal while retaining byte-level ownership oracles. |
| Multiple faces | Preserve the current deterministic selected-face contract. | Per-face retouch requires a separate public/API and ownership design; do not silently process all faces. |
| Realtime | Explicitly unsupported. | A later milestone must separately own cadence, backpressure, freshness, buffer lifetime, and device budgets. |

Spike macOS timings and RSS are mechanics baselines, not iOS budgets. The architecture should preserve separate normalization, Vision, mask, composition, and total timings so the first real bottleneck is measurable. Do not advertise the one-loop composition as a speedup; the tested whole-frame Swift ownership loop was slower than sparse sequential loops.

## Anti-Patterns

### Passing Orientation to Vision but Rendering the Original Image

**Why wrong:** Landmarks and color masks can refer to a different logical canvas/color interpretation.
**Do instead:** Rasterize one canonical image first; both consumers read it with orientation `.up`.

### Reusing `FaceGeometry.innerLips` for Teeth

**Why wrong:** Current `FaceGeometry` lip arrays are compatibility/proxy geometry, while teeth selection requires actual mapped Vision inner/outer lip support.
**Do instead:** Add a separate request-local observed retouch carrier and validator.

### Letting Every Provider Composite Its Own Result

**Why wrong:** Sequential order silently becomes feature precedence and failed regions can contaminate later work.
**Do instead:** Providers return masks only; one composer reads immutable original pixels and resolves ownership.

### Folding Redness into the Existing Eye Geometry Domain

**Why wrong:** It couples a color safety decision to complete-eye warp freshness/caps and makes peer-eye/local failure hard to express.
**Do instead:** Independent retouch strength, provider outcomes, reasons, metrics, and tests; share only the selected request support.

### Re-running Vision for Teeth, Sclera, or Eyelid

**Why wrong:** Duplicates expensive work and can produce inconsistent coordinates in one output.
**Do instead:** One request supplies all support; missing regions fail locally.

### Applying Feather Without a Final Hard Clip

**Why wrong:** Blur can reintroduce support into iris, highlights, lip, skin, or outside the anatomical envelope.
**Do instead:** Every provider returns a hard envelope and the composer enforces it again.

### Treating Native Iris Color as the Safety Oracle

**Why wrong:** A dark iris can hide unsafe geometry by failing the redness score.
**Do instead:** Require both the color-independent geometric oracle and the adversarial final-output oracle.

### Adding an Inert or Proxy `去脂` Field

**Why wrong:** It freezes misleading public semantics and pressures later code to alias eye lift/warp/smoothing.
**Do instead:** Add the field only after the independent evidence gate; otherwise omit it and keep the branch partial.

### Persisting Support for Reuse

**Why wrong:** Still images do not need cross-request biometric-adjacent cache state, and stale support breaks failure isolation.
**Do instead:** Recompute and release support/masks within one synchronous request; persist only aggregate counts/timings.

## Architecture Decisions for the Roadmap

| Decision | Recommendation | Confidence |
| --- | --- | --- |
| Package/target shape | Keep all existing targets and dependency direction; add no dependency. | HIGH |
| Normalization owner | `BeautyRender` implementation, invoked once by `BeautySDK`; facade owns final restoration. | HIGH |
| Detection owner | Existing `VisionFaceDetector`, with a dedicated canonical-still `.up` entry and one request. | HIGH |
| Retouch semantics owner | `BeautyEffects`; `BeautyDetection` only supplies mapped support, `BeautyRender` only supplies generic pixel/render mechanics. | HIGH |
| Mask owner | One `LocalRetouchCompositionOwner` after provider handoff; request-local only. | HIGH |
| Original pixel | Immutable canonical sRGB RGBA8 input, not output from another local transform. | HIGH |
| Existing effects order | Existing base color/lip -> owned local composition from original -> existing unified geometry once. | MEDIUM; mixed-effect visual review required |
| Teeth implementation | Deterministic seeded adaptive provider; no learned fallback. | HIGH mechanically, MEDIUM product readiness pending real fixtures |
| Sclera implementation | Guard per eye before score, feather then hard re-clip, two safety oracles. | HIGH mechanically, MEDIUM product readiness pending calibration |
| Upper eyelid | No production field/provider until real-positive, non-warp gate passes. | HIGH gating decision, LOW/MEDIUM algorithm readiness |
| Realtime | Explicit no-op/unsupported-mode degradation; no detector or retouch pass. | HIGH |

## Sources

### Repository and spike contracts (primary for this project)

- `.planning/PROJECT.md` — v1.14 scope, independent ship gate, transparent-input rejection, and no public/persistent biometric support.
- Root `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, and `RELIABILITY.md` — current target direction, facade contract, request-scoped support, diagnostics, degradation, and performance boundaries.
- `BeautySDK/Package.swift` — current target graph and no external dependencies.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` and `BeautyEngineGeometryDetection.swift` — current input validation, geometry trigger, selected-observation route, and public result assembly.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` and `BeautyFaceObservation.swift` — current single Vision request, face-local mapping, selected-face support, and request carrier boundaries.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`, `BeautyFaceGeometryAdapter.swift`, and `BeautyEffects/Render/BeautyColorEffectPipeline.swift` — current resolver, semantic adapter, color/lip ordering, and unified geometry invocation.
- `.codex/skills/spike-findings-beauty/references/still-image-integration.md`, `teeth-whitening.md`, `sclera-redness.md`, and `upper-eyelid-fullness.md` — experimentally validated mechanics, rejected paths, and production gates.

### Official Apple documentation

- [CIImage `oriented(forExifOrientation:)`](https://developer.apple.com/documentation/coreimage/ciimage/oriented%28forexiforientation%3A%29) — applies EXIF rotation/mirroring transforms.
- [VNImageRequestHandler](https://developer.apple.com/documentation/vision/vnimagerequesthandler) — Vision request handler accepts image data with explicit orientation.
- [VNDetectFaceLandmarksRequest](https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest) — one request locates faces and their facial features.
- [VNFaceLandmarks2D](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — eye, pupil, eyebrow, outer-lip, and inner-lip regions and face-bounding-box-normalized coordinate semantics.
- [VNFaceLandmarks2D `innerLips`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/innerlips) — outlines the space between lips, supporting its use as coarse aperture evidence rather than a teeth label.
- [VNFaceLandmarks2D `rightPupil`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/rightpupil) — Apple notes pupil support may be inaccurate during blinking, supporting per-eye fail-closed guards.

---
*Architecture research for: Beauty v1.14 Local Facial Retouch*
*Researched: 2026-07-30*
