# Project Research Summary

**Project:** Beauty v1.14 Local Facial Retouch
**Domain:** Local-first still-image facial retouch SDK for iOS/macOS
**Researched:** 2026-07-30
**Confidence:** HIGH for architecture, scope, and safety mechanics; MEDIUM for teeth/sclera product readiness; LOW for `去脂` readiness

## Executive Summary

Beauty v1.14 should be built as a conservative extension of the existing Swift package, not as a new subsystem. The milestone's durable product is a shared still-image local-retouch boundary: normalize one opaque input once to an up-oriented sRGB RGBA8 raster, run one selected-face Vision landmarks request, keep all anatomy and masks private to that request, and let one composer derive accepted local edits from immutable original pixels. Apple Vision, ImageIO, Core Graphics, Core Image, SwiftPM, and the existing `BeautySDK`/`BeautyDetection`/`BeautyEffects` seams are sufficient; no external dependency, model, cloud service, new package target, Demo UI, or realtime route is justified.

The visible scope must be promoted feature by feature. Teeth whitening and guarded sclera redness reduction are independent vertical slices and may ship independently after their own rights-approved positive and negative bundles, deterministic containment/safety gates, public-facade output, and original-detail review pass. Synthetic and spike fixtures prove mechanics, not naturalness or target effectiveness. `去脂` is not a required sibling: it remains absent and `future` unless genuine upper-eyelid-fullness positives and negatives validate a distinct non-warp implementation that preserves geometry, crease, texture, and identity. It must never alias eye lift, brow movement, smoothing, dark-circle/eye-bag behavior, or the invalidated warp.

The primary risks are misaligned input ownership, anatomical leakage, hidden transform ordering, sensitive diagnostic persistence, and evidence overclaiming. Mitigate them with transparent-input rejection before Vision, actual mapped lip/eye/pupil support from the single request, hard envelopes re-applied after feathering, per-eye/per-region failure isolation, overlap-to-original composition, aggregate-only diagnostics, and independent promotion ledgers. Correctness comes before optimization; target-device profiling may later select bounded ROI, Core Image, or Metal execution without changing the ownership oracle.

## Key Findings

### Recommended Stack

Keep the current Swift 6 / SwiftPM package graph and deployment baselines (iOS 17+, macOS 14+). Use Apple Vision's existing `VNDetectFaceLandmarksRequest` once per eligible still-image request; ImageIO/Core Graphics/Core Image own validation, EXIF orientation, explicit sRGB RGBA8 canonicalization, and facade-compatible restoration. Extend the existing package targets rather than adding a `BeautyRetouch` target or dependency: `BeautySDK` orchestrates, `BeautyDetection` maps request-local support, and `BeautyEffects` owns retouch semantics, masks, transforms, and composition.

**Core technologies:**

- **Swift + SwiftPM:** public zero-default scalars, immutable request context, typed degradation, and XCTest within the current package graph.
- **Apple Vision:** one selected-face landmarks request supplying actual inner/outer lips, eye contours, pupils, and only conditionally eyebrows; nullable support is never assumed usable.
- **ImageIO + Core Graphics + Core Image:** one canonical opaque up-oriented sRGB RGBA8 raster shared by detection and rendering, using a reused `CIContext`.
- **Existing Beauty package seams:** `BeautySDK` facade, `BeautyDetection` mapper, and `BeautyEffects` providers/composer preserve established dependency direction and public redaction.
- **XCTest and local review harness:** verify compatibility, one-request routing, masks, collisions, privacy, facade output, and rights-approved original/mask/after review without tracking portrait artifacts.

No dependency installation, model resource, remote configuration, new target, or deployment-target raise is recommended. Add exactly two public stored scalars if teeth and sclera pass (59 to 61 fields); add a 62nd for upper-eyelid fullness only if its separate gate passes. All admitted fields are positive-only, finite-normalized, default-zero, and source/JSON/preset compatible.

### Expected Features

**Must have (table stakes):**

- **Canonical still-image processing:** one validated opaque input feeds both Vision and render; transparent, malformed, or unsupported non-RGB local-retouch input rejects before analysis.
- **One deterministic selected face:** one Vision request and one request-local observation serve all enabled face-dependent effects; no per-feature retry, stale support, or silent multi-face expansion.
- **Independent conservative controls:** teeth and sclera have separate public semantics, caps, evidence, diagnostics, and promotion decisions; valid sibling work continues when a region or eye fails.
- **Original-pixel composition:** providers produce bounded masks/results, while one owner composes from original canonical pixels and restores original pixels for any unexpected mask overlap.
- **Natural protected-region behavior:** immutable anatomical envelopes, bounded transforms, post-feather hard re-clipping, zero outside-mask change, and strict teeth/iris/highlight/skin protection.
- **Private transient support:** landmarks, pupils, masks, vein-like detail, pixels, asset paths, and review media remain request-local and unpersisted; only fixed reason codes and aggregate counts/timings may escape.
- **Evidence-backed promotion:** each feature requires public-facade output plus complete rights-approved P+/P- bundles, predeclared blinded 100%-detail review, regression/privacy gates, synchronized ledgers, and independent audit.

**Should have (competitive):**

- **Teeth whitening:** seeded adaptive selection inside actual lip support, conservative yellow-excess reduction and bounded luminance lift, preserved enamel texture/shading, and safe abstention for closed/occluded/unsupported mouths.
- **Guarded sclera redness reduction:** left/right eligibility and failure isolation, guard-before-color-score, uncertainty-inflated iris exclusion, highlight protection, and both geometric and adversarial final-output safety oracles.
- **Smallest-unit degradation:** invalid teeth, left eye, right eye, or conditional eyelid band becomes a local no-op without disabling eligible peers or existing shipped effects.
- **Evidence honesty:** independently qualified teeth can close the `嘴唇` branch; redness alone does not close `眼睛`; exact ledger status follows exact rows.

**Conditional / defer beyond the qualified v1.14 slice:**

- **`去脂` / upper-eyelid fullness:** add only after genuine rights-approved positives and negatives prove an independent non-warp tone/frequency or other semantically valid method; otherwise add no public field/provider and keep `眼睛` partial.
- **Realtime/pixel-buffer retouch, transparent/HDR/gain-map input, multi-face/per-face controls, learned segmentation, Demo UI/presets, commercial/device/packaging/launch claims:** separate future scopes with their own contracts and evidence.

### Architecture Approach

The architecture is a single canonical request pipeline with requirement-aware detection and independent providers behind one composition owner. `BeautySDK` validates and canonicalizes once, `BeautyDetection` runs at most one selected-face request and returns immutable mapped support, and `BeautyEffects` validates feature-local context, creates masks, applies bounded original-pixel transforms, resolves collisions, then hands the composed canonical image to the existing unified geometry pipeline once. The facade restores presentation and exposes only the image plus redacted aggregate outcomes. Masks and support die with the request.

**Major components:**

1. **CanonicalStillImageNormalizer** — validates extent/pixel ceiling/input type, rejects transparency, applies EXIF orientation/mirroring once, renders explicit sRGB RGBA8 once, and owns inverse presentation restoration.
2. **Requirement-aware selected-face detection** — runs zero or one `VNDetectFaceLandmarksRequest`, maps actual lip/eye/pupil/brow values once, and preserves existing deterministic face selection.
3. **LocalRetouchRequestContextAdapter** — validates package-private request support without synthesizing, persisting, or exposing anatomy.
4. **Independent mask providers** — teeth and per-eye sclera providers (plus only a gated future eyelid provider) return accepted request-local regions or precise local no-ops; they do not write pixels.
5. **LocalRetouchCompositionOwner** — clamps/re-clips ownership, reads immutable original pixels, composes disjoint results, restores original pixels on collision, and emits aggregates only.
6. **Existing facade and geometry pipeline** — preserve base color/lip behavior, run local color retouch once, apply existing unified geometry once, restore output contract, and retain legacy result compatibility.

### Critical Pitfalls

1. **Shipping proxy `去脂`** — make real-positive acquisition and a non-warp geometry/detail gate a hard go/no-go; omit the public field and runtime route when it fails.
2. **Calling mechanics product evidence** — keep M/S fixtures out of P+/P- aggregates; require feature-specific rights, polarity, complete assets, frozen criteria, and blinded local review.
3. **Whitening a mouth aperture or the wrong color polarity** — seed connected tooth candidates within a narrow lip-supported envelope, preserve fixed safe support, protect oral tissue, reduce measured yellow excess, and cap luminance/detail loss.
4. **Letting native iris color hide sclera leakage** — guard geometry before color scoring and require both color-independent protected-region truth and adversarial recolored-iris final-output oracles.
5. **Feather escape and sequential ownership** — retain immutable hard envelopes, re-clip after every spatial operation, make all transforms read original pixels, and preserve source pixels on any overlap.
6. **Multiple input/detection owners** — canonicalize once, pass `.up` to the sole Vision request, and render the same pixels; never repeat detection per provider or reuse stale observations.
7. **Sensitive support or evidence leakage** — prohibit public/SPI/Codable masks and geometry, diagnostic coordinates/paths/free text, tracked media, network review, and stable cross-request identifiers.
8. **Mistaking correct CPU composition for performant composition** — establish the byte-level oracle first, then profile release builds on supported iPhones and optimize bounded ROIs/contexts/kernels without weakening ownership.

## Implications for Roadmap

Research supports six accountable phases. Rights acquisition should begin concurrently with foundation work, but no visible feature may promote before its bundle is complete. Teeth and sclera remain peer vertical slices; `去脂` is a conditional decision, not a dependency.

### Phase 1: Contract, Canonical Input, and Private Request Foundation

**Rationale:** Every mask, transform, and compatibility claim depends on one shared raster and one selected-face owner. This is the highest-impact integration risk and must stabilize before feature calibration.

**Delivers:** Conditional public-field staging rules; legacy/default neutrality; canonical opaque sRGB RGBA8 input and restoration; all-eight EXIF coverage; transparent-input rejection before Vision; requirement-aware zero/one Vision request; actual mapped lip/eye/pupil support; aggregate-only degradation and request-local lifetime tests.

**Addresses:** TS-01 through TS-06 and TS-09; still-image-only facade behavior.

**Avoids:** Split orientation/color ownership, repeated detection, stale support, hidden realtime activation, sensitive diagnostic leakage, and premature inert `去脂` API.

### Phase 2: Rights-Approved Evidence and Feature Eligibility Gates

**Rationale:** Fixture polarity and review criteria must exist before tuning; otherwise mechanics fixtures and the current already-light portrait will bias thresholds and create false product claims.

**Delivers:** Per-feature rights manifests; genuine teeth/sclera P+ and P- bundles; protected-tissue/challenge matrices; frozen naturalness/safety judgments; sanitized review export; explicit `去脂` go/no-go based on genuine fullness fixtures and a credible independent non-warp design.

**Addresses:** TS-10, evidence classification, independent promotion, and exact branch-status rules.

**Avoids:** Mechanics-as-product proof, post-hoc polarity, demographic/commercial overclaims, unlicensed assets/models, and all-or-nothing milestone coupling.

### Phase 3: Original-Pixel Composition and Failure-Isolation Core

**Rationale:** Composition policy is a shared correctness primitive and should be proved with injected masks before anatomy providers can mutate production output.

**Delivers:** Provider/composer protocol; immutable original/base dual inputs; hard-envelope sanitization; collision-to-original policy; standalone-versus-fused oracle; left/right/feature failure injection; outside-union equality; aggregate ownership diagnostics.

**Addresses:** TS-06 through TS-09 and the shared foundation required by every admitted retouch.

**Avoids:** Sequential output feedback, transform-order priority, double edits, feather leakage, global failure coupling, and mask persistence.

### Phase 4: Teeth Whitening Vertical Slice and Independent Gate

**Rationale:** Teeth is the lower-risk visible slice and can deliver an independently shippable result while validating the complete provider-to-facade workflow.

**Delivers:** `teethWhitening` contract if eligible; actual-lip-support adapter; conservative fixed seeds plus connected adaptive growth; bounded yellow/luminance transform from original pixels; protected oral-tissue/no-face/closed-mouth/occlusion tests; public-facade output; rights-approved P+/P- review and independent promotion decision.

**Addresses:** `白牙`, mouth branch closeout when passed, adaptive side-tooth coverage, already-light abstention/naturalness, and compatibility.

**Avoids:** Whole-aperture masks, lost fixed support, lip/tongue/gum/braces leakage, chalky/blue output, and borrowing sclera evidence.

### Phase 5: Guarded Sclera Vertical Slice and Conditional Eyelid Decision

**Rationale:** Sclera needs more difficult per-eye geometry and calibration, while upper-eyelid work should begin only if Phase 2 opens its gate. Combining the decision point here preserves independent shipability without inventing a proxy.

**Delivers:** `scleraRednessReduction` contract if eligible; guard-before-score per-eye provider; iris/highlight exclusions; post-feather re-clipping; dual safety oracles; peer-eye isolation; bounded red-excess transform; public-facade output and P+/P- review. If and only if eligible, add and validate a separate `upperEyelidFullnessReduction` non-warp vertical slice; otherwise record its absence and keep `眼睛` partial.

**Addresses:** `祛红血丝`, conditional `去脂`, individual eye failure, natural vessel/detail retention, and honest eye-branch status.

**Avoids:** Whole-eye whitening, native-color-hidden iris leakage, peer-eye coupling, eye/brow warp aliases, texture erasure, and blocking qualified teeth/redness on `去脂`.

### Phase 6: Combined Facade Closeout, Device Profiling, and Independent Promotion

**Rationale:** Only after standalone slices are correct can mixed effects, compatibility, privacy, performance, and exact documentation status be evaluated without obscuring ownership failures.

**Delivers:** Teeth+sclera standalone/fused equivalence; injected overlap suppression; mixed color/lip/44-field geometry regression; facade dimensions/orientation/no-op guarantees; static privacy/resource/network scans; target-iPhone stage timing and peak-memory evidence; bounded execution optimization if needed; synchronized ledgers and independent milestone audit. Promote only each passing feature.

**Addresses:** Full v1.14 qualified slice, exact public-field count, regression, evidence, privacy, performance measurement, and branch ledgers.

**Avoids:** Scope creep into realtime/UI/cloud/HDR/model work, unsupported speed claims, tracked sensitive artifacts, broad release/commercial claims, and false whole-branch completion.

### Phase Ordering Rationale

- Canonical pixels, face selection, private support, and public compatibility precede masks because every downstream coordinate and safety assertion depends on them.
- Evidence acquisition starts early and independently because rights/polarity scarcity, not code mechanics, is the largest product-readiness uncertainty.
- Composition is proven before feature providers so failure isolation and ownership do not become emergent behavior of sequential filters.
- Teeth and sclera are complete peer vertical slices with their own ship gates; neither borrows evidence or failure from the other.
- `去脂` is evaluated after acquisition and never sits on the critical path for teeth/sclera. A failed gate produces no public/API implementation, not an inert placeholder.
- Mixed-effect, device, security, ledger, and audit closeout comes last because it validates the admitted set rather than predetermining it.

### Research Flags

Phases likely needing deeper research during planning:

- **Phase 2:** fixture acquisition, rights/polarity schema, and predeclared human-review sampling remain the dominant non-code uncertainty.
- **Phase 4:** teeth candidate thresholds and natural yellow/luminance caps require calibration on genuine discoloration positives and protected-tissue negatives.
- **Phase 5:** sclera guard/coverage calibration needs genuine redness/challenge bundles; any `去脂` work requires a dedicated research phase because algorithm readiness is LOW.
- **Phase 6:** target-iPhone profiling should research the execution primitive only if the correctness-first bounded path misses an explicit measured budget.

Phases with established patterns that can normally skip research-phase:

- **Phase 1:** Apple APIs, existing package seams, Spike 013, and project contracts already define normalization, one-request routing, compatibility, and privacy invariants.
- **Phase 3:** original/base composition, collision suppression, request-local ownership, and fault-injection oracles are well specified by spike and architecture evidence.
- **Phase 6 security/regression closeout:** existing Beauty package tests, scans, renderer evidence, and milestone-audit conventions are established; only performance escalation is conditional research.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Existing package graph and Apple platform APIs are verified; no dependency or target migration is needed. Exact production CPU/Core Image/Metal execution remains profile-driven. |
| Features | MEDIUM | Scope, semantics, and independent gates are strong. Teeth and sclera still lack complete genuine P+/P- review; `去脂` readiness is LOW. |
| Architecture | HIGH | Canonical input, one request, request-local support, independent providers, one composer, and fail-closed overlap are supported by repository seams and spikes. Mixed existing-effect ordering still needs visual regression. |
| Pitfalls | HIGH | Project spikes and current contracts strongly establish integration, safety, privacy, and overclaim hazards. Product calibration and device performance remain empirical. |

**Overall confidence:** MEDIUM-HIGH. The foundation and roadmap boundaries are clear; which visible rows ultimately promote depends on evidence not yet acquired.

### Gaps to Address

- **Teeth product evidence:** acquire genuine yellow/gray discoloration positives plus already-light, protected-tissue, occlusion, brace, pose, blur, and lighting negatives; freeze naturalness and detail bounds before review.
- **Sclera product evidence:** acquire genuine mild/severe redness positives and clear/blink/gaze/iris/highlight/glasses/contact/occlusion negatives; calibrate useful coverage without relaxing zero-leak safety.
- **Upper-eyelid feasibility:** no genuine positive currently proves a useful non-warp result. Treat this as a gate, not scheduled implementation; omit the field if unresolved.
- **Canonical input compatibility:** confirm all-eight EXIF equivalence, bounded P3-to-sRGB fresh/fixed-anchor stability, facade presentation restoration, pixel ceilings, and opaque rejection on production paths.
- **Mixed-effect visual order:** verify existing base color/lip, local retouch, and unified geometry ordering on facade outputs without changing ownership semantics.
- **Target-device budgets:** establish explicit supported-iPhone release-mode latency and peak-memory targets before selecting ROI/Core Image/Metal optimization; macOS/simulator spikes are not device evidence.
- **Exact admitted field and ledger inventory:** freeze 61 fields for teeth+sclera or 62 only if `去脂` independently passes; synchronize branch status to the rows that actually pass.

## Sources

### Primary (HIGH confidence)

- [STACK.md](./STACK.md) — platform stack, target ownership, public-field staging, alternatives, compatibility, and execution gates.
- [FEATURES.md](./FEATURES.md) — table stakes, feature semantics, evidence classes, independent promotion, MVP boundary, and requirement seeds.
- [ARCHITECTURE.md](./ARCHITECTURE.md) — canonical request flow, component ownership, verification seams, build order, and anti-patterns.
- [PITFALLS.md](./PITFALLS.md) — critical failure modes, hard promotion gates, recovery, phase accountability, and nonclaims.
- [PROJECT.md](../PROJECT.md) — authoritative v1.14 milestone goal, constraints, requirements, and current evidence limitations.
- Repository `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and `QUALITY_SCORE.md` — current package, privacy, reliability, UX, evidence, and quality contracts.
- `.codex/skills/spike-findings-beauty/` references — thirteen mechanics spikes, canonical-input integration, teeth/sclera/upper-eyelid findings, licensed-fixture rules, invalidated warp, and original-pixel composition oracle.
- `BeautySDK/Package.swift` and current `BeautySDK`, `BeautyDetection`, and `BeautyEffects` sources — existing dependency graph, facade, one-request detection, mapping, resolver, render, and test seams.

### Official Platform Sources (HIGH confidence)

- [Apple VNDetectFaceLandmarksRequest](https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest) and [VNFaceLandmarks2D](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — request behavior and nullable lip/eye/pupil/brow landmark support.
- [Apple VNImageRequestHandler](https://developer.apple.com/documentation/vision/vnimagerequesthandler) — still-image request handling with explicit orientation.
- [Apple CGImagePropertyOrientation](https://developer.apple.com/documentation/imageio/cgimagepropertyorientation) — EXIF/TIFF rotation and mirroring semantics.
- [Apple CIContext](https://developer.apple.com/documentation/coreimage/cicontext) and [CIBlendWithMask](https://developer.apple.com/documentation/coreimage/ciblendwithmask) — explicit color/format rendering, context reuse, and mask-based composition primitives.
- Installed Xcode 26.6 / Apple SDK 26.5 headers — locally verified availability and pupil/blink caveats; these are research tooling evidence, not a deployment-target increase.

### Empirical / Pending Validation (MEDIUM to LOW confidence)

- Spike mechanics and adversarial fixtures — strong for containment and failure invariants, not sufficient for product effectiveness, demographics, or commercial quality.
- Current rights-approved exposed-smile portrait — prospective already-light teeth containment/over-whitening negative only when bundled and reviewed; not a teeth discoloration, sclera-redness, or upper-eyelid-fullness positive.
- macOS/simulator timing and memory measurements — baseline diagnostics only; target-iPhone release profiling remains required before any performance claim.

---
*Research completed: 2026-07-30*
*Ready for roadmap: yes*
