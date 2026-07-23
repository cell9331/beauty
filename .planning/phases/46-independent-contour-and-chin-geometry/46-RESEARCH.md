# Phase 46: Independent Contour and Chin Geometry - Research

**Researched:** 2026-07-23  
**Domain:** Swift package-internal face-contour geometry, provider eligibility, conflict convergence, and public-facade routing  
**Confidence:** HIGH for repository seams, contracts, and test architecture; MEDIUM for provisional displacement constants

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Geometry Semantics and Locality

- `faceContourSmooth` is a contour-only local continuity transform: move eligible interior contour points conservatively toward their immediate-neighbor chord while preserving endpoints, overall center, and gross face scale. It must not reuse whole-face `faceSmall` shrinkage or modify the five shipped face-field vectors.
- `templeFullness` is a contour-only upper-lateral transform: select symmetric upper-side contour support and move it outward from the face centerline with local falloff. It must not move the full contour or borrow cheek/jaw sources.
- `cheekboneSlim` is a contour-only mid-lateral transform: select symmetric middle-side contour support and move it inward toward the face centerline with local falloff. Its sources and vertical band must remain distinct from `templeFullness`, shipped `faceSlim`, `faceSmall`, and `jawSlim`.
- `chinTaper` requires complete contour-plus-centerline eligibility and the validated semantic apex. Move only contour points adjacent to the apex inward toward the median axis, keep the apex vertical position unchanged, and never reuse signed `chinLength`, `faceVShape`, or the synthetic seven-point proxy.
- All source/target/radius/falloff values must be finite, unit-bounded, conservative, and expressed in the repository's image-normalized coordinate system. Exact displacement constants are provisional Phase 46 implementation choices, not final naturalness evidence.

### Provider Emissions and Eligibility

- Extend the existing face/chin providers with one independently addressable named emission per shipped and new face field, following the established eye/nose/mouth field-emission pattern. Do not hide the four additions behind one aggregate face array.
- The three contour-only fields require `observedFaceSupport.contourEligible`; `chinTaper` additionally requires `centerlineEligible`, a valid median line, and a valid apex index. Explicit malformed or incomplete observed support never falls back to the synthetic compatibility contour.
- The five shipped face fields keep their current seven-point compatibility behavior and vectors. New support and emissions are attached beside those paths and cannot alter them at zero or when ineligible.
- A requested field whose own provider emission is empty must be zeroed before active-domain membership, conflict totals, weakened counts, warnings, metrics, geometry-point counts, or dispatch. Eligible new and shipped siblings continue independently.
- Add conservative provisional caps for the four new effective strengths in Phase 46 and mark them as provisional. Phase 48 remains the authority for final evidence-backed caps and dead-zone policy.

### Resolver, Conflict, and Facade Routing

- Add all four fields to `requiresFaceGeometry`, `BeautyEffectiveStrengths`, cap application, requested/reusable face-work checks, freshness handling, zero/scale helpers, face-domain activation, and unified pipeline dispatch without adding a new public API or render pass.
- Preflight face/chin field emissions before conflict accounting, then re-evaluate all provider emissions from one retained baseline after combined weakening. The mask-and-recompute loop must remain monotone and bounded: fields can only be removed, never revived.
- Provider-empty work contributes zero times to final strength, total, count, scale, weakened count, active-domain evidence, geometry point count, warnings, metrics, and emitted control points.
- Preserve established freshness behavior: no face and stale geometry disable the four new fields; reused geometry applies the existing exact non-eye reuse scale only when the required observed support remains eligible. Missing contour or centerline degrades only dependent new fields while shipped and face-agnostic domains continue.
- Keep diagnostics aggregate and redacted. Do not expose field-specific contour indices, point counts beyond existing approved aggregates, coordinates, bounds, displacements, or support-derived measurements through warnings, metrics, descriptions, or facade results.

### Testing and Evidence

- Add deterministic asymmetric observed-contour fixtures that make upper temple, middle cheekbone, local continuity, and apex-adjacent taper sources distinguishable. Symmetric aggregate point-count assertions alone are insufficient.
- For each field, assert named emission ownership, non-empty valid output, exact source subset, direction/locality, finite bounded control points, zero neutrality, nearest shipped-field distinction, and unchanged existing face/chin emissions.
- Add representative contour-only, missing contour, missing centerline, malformed, no-face, stale, reused, provider-empty, and valid-sibling cases. Exact exhaustive nine-field transitions and the final thirty-seven-field convergence ledger remain Phase 48.
- Verify isolated public requests enter detection and the existing facade/unified-warp route, but defer decoded image comparisons, ROI thresholds, renderer case matrices, and gallery generation to Phase 47.
- Run focused provider, resolver, conflict, pipeline, degradation, and facade tests plus the full SwiftPM suite and diff hygiene. Do not claim visual naturalness, final caps, product-row promotion, Demo behavior, or release readiness.

### Privacy, Scope, and Ownership

- Preserve Phase 45's package-only, non-Codable, request-scoped observed support and aggregate-only reflection/description contract.
- Add no dependency, target, semantic model/resource, network/cloud path, new render pass, facade method, public geometry/result type, Demo import, tracked generated image, or commercial path.
- Keep `去双下巴`, `去双下巴 Pro`, `发际线`, branch-level `脸型` completion, device parity, commercial approval, performance certification, packaging, shipping, and launch readiness outside this phase.

### the agent's Discretion

- Choose private emission/helper type names, contour band/index selection rules, provisional cap values, radii, falloff, and displacement constants where the codebase has no locked value.
- A small shared face/chin provider refactor is allowed when it preserves byte-for-byte zero behavior and exact shipped vectors in tests.
- Select the narrowest representative degradation and combined-conflict fixtures needed for Phase 46, leaving exhaustive matrices and final constants to Phase 48.

### Deferred Ideas (OUT OF SCOPE)

- Decoded public-facade output matrix, strict ROI/non-alias comparisons, ignored output helper/gallery, and representative no-face/malformed image evidence — Phase 47.
- Final caps/dead zones, exhaustive nine-field face transitions, thirty-seven-field geometry convergence, active-source boundary checker, final security/reliability closeout, exact four-row promotion, and milestone owner synchronization — Phase 48.
- `去双下巴`, `去双下巴 Pro`, `发际线`, semantic-region models/resources, Demo UI, physical-device evidence, commercial visual approval, optimized performance, packaging, shipping, and launch readiness — future scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|---|---|---|
| GEOM-01 | Smooth-contour output reduces local lateral contour irregularity without globally shrinking the face or changing the five shipped face controls. | Use observed-contour interior neighbor-chord deltas, exclude endpoints/extrema, center the displacement set, and lock legacy emission vectors byte-for-byte. [VERIFIED: `.planning/REQUIREMENTS.md`, `46-CONTEXT.md`] |
| GEOM-02 | Temple output applies bounded upper-lateral outward movement spatially distinct from `faceSmall` and `faceSlim`. | Use a disjoint upper path-progress band from actual observed contour, contour-derived axis, outward direction, and exact-source/vector distinction tests. [VERIFIED: `.planning/REQUIREMENTS.md`, `46-CONTEXT.md`] |
| GEOM-03 | Cheekbone output applies bounded mid-lateral inward movement distinct from whole-cheek slimming and jaw narrowing. | Use a disjoint middle path-progress band, inward axis motion, and comparisons against temple, `faceSlim`, `faceSmall`, and `jawSlim`. [VERIFIED: `.planning/REQUIREMENTS.md`, `46-CONTEXT.md`] |
| GEOM-04 | Chin-taper output narrows adjacent lower-contour points toward the apex without lengthening or shortening the chin. | Require complete centerline eligibility; emit only the two apex-adjacent contour sources; interpolate the median axis at each source Y; leave the apex and all target Y values unchanged. [VERIFIED: `.planning/REQUIREMENTS.md`, `46-CONTEXT.md`] |
</phase_requirements>

## Summary

Phase 46 is an extension of the existing provider/resolver contract, not a new render feature. The current package already supplies validated package-only `BeautyFaceSemanticSupport`, four mature named-emission provider patterns, one `BeautyEffectiveStrengths` ledger, one `GeometryConflictResolver`, and one unified `BeautyGeometryEffectPipeline`. The four public values already normalize independently but are intentionally absent from every runtime seam. [VERIFIED: `BeautyParameters.swift`, `WarpControlPoint.swift`, `BeautyEffectResolver.swift`, `46-CONTEXT.md`]

The core planning risk is accounting drift, not point generation. The present resolver preflights eye/nose/mouth emissions, but face/chin providers expose only aggregate arrays; `hasFaceShapeValues` is computed before conflict resolution; and face-shape geometry-point accounting calls the unified pipeline, which also contains eye/nose/mouth points. Phase 46 must make all nine face/chin fields individually sanitizable, include both face/chin providers in every convergence pass, derive domain activity from final emissions, and count each final provider point exactly once. [VERIFIED: `BeautyEffectResolver.swift:217-230,261-319,475-506`, `BeautyGeometryEffectPipeline.swift:14-20`]

The geometry itself should be topology-driven and intentionally modest. Use canonical contour traversal to choose non-overlapping upper and middle bands; use immediate-neighbor chords for smoothing; and use the validated apex plus median line only for taper. All four should enter the existing local warp, with provisional caps and relative provider tests now; Phase 47 owns decoded image/ROI evidence and Phase 48 owns final calibration and exhaustive convergence. [VERIFIED: `DESIGN.md` Phase 45 contract, `46-CONTEXT.md`]

**Primary recommendation:** Implement two named emission values (`FaceShapeWarpFieldEmissions` for seven fields and `ChinWarpFieldEmissions` for two), sanitize them before and after a 37-removal monotone convergence loop, and make final emissions the single source for strengths, domain activity, diagnostics, point counts, and unified dispatch. [VERIFIED: established `EyeWarpFieldEmissions`/`NoseWarpFieldEmissions`/`MouthWarpFieldEmissions` pattern; 37-field inventory derived from current 33 plus four scoped additions]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|---|---|---|---|
| Public scalar request and normalization | API / Backend (BeautyCore) | — | The four public fields already exist and normalize to positive-only closed-unit values. [VERIFIED: `BeautyParameters.swift`] |
| Actual contour/median eligibility | API / Backend (BeautyDetection → BeautyEffects adapter) | — | Vision mapping and topology validation are complete predecessor contracts; Phase 46 consumes only validated semantic support. [VERIFIED: `45-VERIFICATION.md`] |
| Field-local control-point generation | API / Backend (`BeautyEffects/Warp`) | — | Providers own source selection, target vectors, radii, falloff, and field emissions. [VERIFIED: `ARCHITECTURE.md`, current provider source] |
| Cap, freshness, provider-empty sanitization | API / Backend (`BeautyEffects/Planning`) | — | `BeautyEffectResolver` centralizes effective strengths, activation, warnings, and metrics. [VERIFIED: `BeautyEffectResolver.swift`] |
| Combined strength convergence | API / Backend (`BeautyEffects/Warp`) | — | `GeometryConflictResolver` owns shared geometry total/count/scale. [VERIFIED: `GeometryConflictResolver.swift`] |
| Render dispatch | API / Backend (`BeautyEffects/Render`) | CDN / Static — none | Existing provider points feed one local geometry warp; no new pass is permitted. [VERIFIED: `BeautyGeometryEffectPipeline.swift`, `46-CONTEXT.md`] |
| Public-facade route evidence | API / Backend (`BeautySDK`) | — | The existing still-image engine invokes detection when `requiresFaceGeometry` is true and exposes only aggregate results. [VERIFIED: `BeautyEngineGeometryFacadeTests.swift`, `SECURITY.md`] |

## Project Constraints (from AGENTS.md)

- Treat repository text as the system of record; do not assume facts absent from source, tests, plans, or owner documents. [VERIFIED: `AGENTS.md`]
- Before changes, consult `PLANS.md`; source and tests outrank planning and historical documents. [VERIFIED: `AGENTS.md`]
- Keep changes focused, preserve unrelated local edits, use existing naming/directory/abstraction patterns, run the narrowest meaningful verification, and record what changed, why, and how it was verified. [VERIFIED: `AGENTS.md`]
- Contract changes must update the owning document: `DESIGN.md` for parameter/state/pipeline semantics, `ARCHITECTURE.md` for boundaries, `SECURITY.md` for new risk boundaries, `RELIABILITY.md` for degradation/diagnostics, `PRODUCT_SENSE.md` for observable acceptance, and `PLANS.md` for completion evidence. [VERIFIED: `AGENTS.md`]
- Do not duplicate one authoritative fact across documents or expand scope; record additional issues in `PLANS.md`. [VERIFIED: `AGENTS.md`]
- If Xcode validation is needed, first list schemes/simulators and use an explicit iOS Simulator destination; report local Xcode failures honestly. Phase 46's required implementation verification is SwiftPM, so a Demo build is not needed unless Demo changes unexpectedly. [VERIFIED: `AGENTS.md`, `46-CONTEXT.md`]

## Standard Stack

### Core

| Library / Tool | Version | Purpose | Why Standard |
|---|---|---|---|
| Swift | 6.3.3 installed; package tools 6.0 | Providers, resolver, value types, tests | Existing repository language and manifest contract. [VERIFIED: `swift --version`, `BeautySDK/Package.swift`] |
| Swift Package Manager | bundled with Swift 6.3.3 | Build and test six package targets | Existing package has no external package dependencies. [VERIFIED: `BeautySDK/Package.swift`] |
| XCTest | toolchain bundled | Provider, resolver, conflict, degradation, pipeline, facade tests | All current package tests use XCTest. [VERIFIED: `BeautySDK/Tests/**/*.swift`] |
| SIMD2<Float> | Swift standard library | Image-normalized sources/targets | Existing `WarpControlPoint` and all providers use this type. [VERIFIED: `WarpControlPoint.swift`, provider source] |
| CoreImage | Apple platform framework | Existing still-image local warp evidence | `BeautyGeometryEffectPipeline` already performs the single CIImage warp. [VERIFIED: `BeautyGeometryEffectPipeline.swift`] |

### Supporting

| Library / Tool | Version | Purpose | When to Use |
|---|---|---|---|
| Python | 3.9.6 installed | Existing fail-closed boundary scripts | Use only if Phase 46 adds a scoped static security checker; do not alter implementation through Python. [VERIFIED: environment probe, Phase 45 checker] |
| Git | 2.50.1 installed | Diff hygiene and change inventory | Run `git diff --check` and scoped status/diff checks at the phase gate. [VERIFIED: environment probe, `AGENTS.md`] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|---|---|---|
| Existing Swift providers | Third-party geometry SDK | Prohibited by locked scope and dependency policy; it would add privacy, licensing, network, and package-boundary risks. [VERIFIED: `46-CONTEXT.md`, `SECURITY.md`] |
| Named per-field emissions | One aggregate face array | Prohibited because empty fields could remain in conflict/accounting and aliasing could not be proven. [VERIFIED: `46-CONTEXT.md`] |
| Existing unified warp | A second contour render pass | Prohibited and would change render ordering/performance semantics. [VERIFIED: `46-CONTEXT.md`, `DESIGN.md` D4/D6] |

**Installation:** None. Do not add packages, targets, resources, or models. [VERIFIED: `46-CONTEXT.md`]

## Package Legitimacy Audit

Not applicable. Phase 46 installs no external package; `BeautySDK/Package.swift` declares only local targets and Apple/Swift toolchain facilities. [VERIFIED: `BeautySDK/Package.swift`, `46-CONTEXT.md`]

## Architecture Patterns

### System Architecture Diagram

```text
BeautyParameters
  └─ four nonzero contour/chin scalars
        ↓ requiresFaceGeometry
Existing selected-face detection
        ↓ request-local mapped observation
BeautyFaceGeometryAdapter
  ├─ legacy seven-point faceContour ───────────────┐
  └─ observedFaceSupport(contour, median, apex) ──┤
                                                   ↓
Normalize + provisional cap + freshness policy
                                                   ↓
Named provider preflight
  ├─ FaceShape: 4 shipped + smooth + temple + cheekbone
  └─ Chin: chinLength + chinTaper
                                                   ↓
Remove empty fields from retained baseline
                                                   ↓
GeometryConflictResolver (all 37 geometry fields)
                                                   ↓
Re-evaluate all providers from the retained baseline
  ├─ unchanged mask → final strengths/emissions
  └─ smaller mask → repeat, never re-add; max 37 removals
                                                   ↓
Final emission-owned activity / metrics / point count
                                                   ↓
Existing BeautyGeometryEffectPipeline
                                                   ↓
Existing single local warp → public facade result
                      (aggregate/redacted diagnostics only)
```

[VERIFIED: current resolver/provider/pipeline flow plus locked Phase 46 convergence decision]

### Recommended Project Structure

```text
BeautySDK/
├── Sources/BeautyEffects/
│   ├── Planning/
│   │   ├── BeautyEffectPlan.swift          # four effective fields
│   │   ├── BeautySafetyCaps.swift           # provisional caps
│   │   └── BeautyEffectResolver.swift       # routing, freshness, convergence, accounting
│   ├── Warp/
│   │   ├── FaceShapeWarpProvider.swift      # 7 named emissions
│   │   ├── ChinWarpProvider.swift           # 2 named emissions
│   │   └── GeometryConflictResolver.swift   # 37-field scale/total/count
│   └── Render/
│       └── BeautyGeometryEffectPipeline.swift # unchanged provider concatenation route
├── Sources/BeautySDK/
│   └── BeautyEngineTestingSupport.swift     # deterministic observed-support SPI fixture data
└── Tests/
    ├── BeautyEffectsTests/
    │   ├── FaceShapeWarpProviderTests.swift
    │   ├── BeautyEffectResolverTests.swift
    │   ├── GeometryConflictResolverTests.swift
    │   ├── CombinedEffectSafetyTests.swift
    │   ├── MissingLandmarkDegradationTests.swift
    │   └── BeautyGeometryEffectPipelineTests.swift
    └── BeautyCoreTests/
        └── BeautyEngineGeometryFacadeTests.swift
```

[VERIFIED: current repository structure; file responsibilities extended by `46-CONTEXT.md`]

### Pattern 1: Named Field Emissions as the Eligibility Authority

**What:** Add `FaceShapeWarpFieldEmissions` with `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `faceContourSmooth`, `templeFullness`, and `cheekboneSlim`; add `ChinWarpFieldEmissions` with `chinLength` and `chinTaper`. Each has a stable concatenated `points` property and `sanitizing(_:)` that zeros only requested fields whose own arrays are empty. [VERIFIED: established eye/nose/mouth source pattern; locked face/chin decision]

**When to use:** Before conflict accounting, during every convergence pass, for final domain activation, point counts, and dispatch verification. [VERIFIED: `46-CONTEXT.md`]

**Example:**

```swift
// Source pattern: BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift
struct ChinWarpFieldEmissions: Equatable, Sendable {
    let chinLength: [WarpControlPoint]
    let chinTaper: [WarpControlPoint]

    var points: [WarpControlPoint] { chinLength + chinTaper }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var result = strengths
        if strengths.chinLength != 0, chinLength.isEmpty { result.chinLength = 0 }
        if strengths.chinTaper != 0, chinTaper.isEmpty { result.chinTaper = 0 }
        return result
    }
}
```

### Pattern 2: Disjoint Canonical Contour Bands

**What:** Derive source membership from canonical open-path progress, not from the seven-point proxy or whole-face bounds alone. Use half-open disjoint bands so a contour sample can never belong to both temple and cheekbone emissions. [VERIFIED: Phase 45 preserves canonical adjacency/order; `46-CONTEXT.md` requires distinct sources]

**Recommended provisional selection:**

| Field | Path progress | Movement |
|---|---|---|
| Temple left/right | `0.10..<0.30` and `0.70..<0.90` | Away from contour-derived median X |
| Cheekbone left/right | `0.30..<0.46` and `0.54..<0.70` | Toward contour-derived median X |
| Smooth | Interior indices `1..<count-1`, excluding horizontal extrema | Toward immediate-neighbor chord, followed by displacement-centering |
| Chin taper | Exactly `apexIndex - 1` and `apexIndex + 1` | Toward interpolated median X at unchanged Y |

These starting bands intentionally yield distinct index pairs on the minimum valid seven-point contour and scale deterministically to denser contours. [ASSUMED]

### Pattern 3: Provisional Local Vectors

**What:** Normalize positive effective strength by its provisional cap, multiply by a small bounds-relative displacement, clamp source/target through `LandmarkGeometryHelper`, and use local radii with existing falloff `2`. [VERIFIED: current face/chin provider construction pattern]

**Recommended provisional constants:** cap all four at `0.25`; maximum displacement at cap `0.012 * face width` for smoothing, `0.018 * face width` for temple/cheekbone, and `0.016 * face width` for taper; radii `0.08`, `0.14`, `0.14`, and `0.12` times face width respectively, passed through the existing radius clamps; falloff `2`. These are implementation starting points only and must be labeled provisional. [ASSUMED]

**Smooth preservation rule:** compute lateral neighbor-chord deltas only for eligible interior samples, cap each delta, subtract the mean emitted delta so the vector set has approximately zero translation, and leave endpoints, vertical coordinates, and horizontal extrema untouched. Provider tests should prove reduced aggregate lateral roughness, zero-sum displacement within tolerance, unchanged extrema, and no all-points-toward-center behavior. [ASSUMED]

**Chin axis rule:** interpolate the validated median polyline's X value at each adjacent source Y; move X toward that value and keep target Y exactly equal to source Y. Do not emit the apex as a source. [ASSUMED]

### Pattern 4: One Retained Baseline, Monotone Mask Removal

**What:** Start from capped/freshness-adjusted strengths, sanitize face/chin/eye/nose/mouth emissions, resolve the shared scale, then sanitize the unscaled retained baseline using emissions evaluated at the scaled strengths. Return only when the next baseline equals the prior baseline. [VERIFIED: current resolver convergence pattern and locked Phase 46 decision]

**Bound:** Change the loop ceiling from 28 to 37 because Phase 46 makes all nine face/chin and the existing 28 eye/nose/mouth fields provider-removable. A pass may zero values but must never copy a removed value back from the original request. [VERIFIED: current 33-field ledger, four additions, and named-emission requirement]

### Pattern 5: Final Emissions Own Aggregate Accounting

**What:** Recompute final provider emissions once after convergence and derive:

- `faceShape` activity from final face + chin emission points;
- `geometryPointCount` from each final provider array exactly once;
- skipped-domain warning only when a requested domain has no final emission;
- conflict total/count/scale from the retained non-empty baseline;
- pipeline output by the same final effective strengths.

[VERIFIED: `46-CONTEXT.md`; current unified call in face-shape point accounting is a drift risk]

### Anti-Patterns to Avoid

- **Synthetic fallback for new fields:** `FaceGeometry.faceContour` is compatibility-only and cannot authorize any of the four additions. [VERIFIED: `SECURITY.md`, `46-CONTEXT.md`]
- **Aggregate face guard:** A top-level `guard !face.faceContour.isEmpty` before all field work would wrongly block observed-support-only work and prevent shipped/new sibling independence. [VERIFIED: current face/chin code structure; locked field-local eligibility]
- **Full-contour temple or cheek motion:** This aliases `faceSmall`/`faceSlim` and defeats locality evidence. [VERIFIED: GEOM-02/03]
- **Apex movement for taper:** Any Y change or apex control point aliases signed `chinLength`. [VERIFIED: GEOM-04, `46-CONTEXT.md`]
- **Sanitizing only after conflict:** Empty work would contaminate total, count, scale, weakened count, and warnings. [VERIFIED: `46-CONTEXT.md`]
- **Recomputing from the original request after removal:** This can revive a field and break bounded monotonic convergence. [VERIFIED: current retained-baseline pattern]
- **Counting the unified pipeline once per domain:** It double-counts sibling provider points in combined plans. [VERIFIED: current `BeautyEffectResolver.swift:300-305` plus unified pipeline composition]
- **Using only symmetric counts in tests:** Equal point counts do not prove source ownership, locality, or non-aliasing. [VERIFIED: `46-CONTEXT.md`]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---|---|---|---|
| Coordinate conversion | Provider-specific Vision/image orientation math | Phase 45 mapped `observedFaceSupport` | The predecessor already maps once and preserves canonical adjacency. [VERIFIED: `45-VERIFICATION.md`] |
| Input topology validation | A second face-contour validator in providers | `contourEligible` / `centerlineEligible`, plus cheap defensive finite/output guards | Duplicate validation can drift from the authoritative adapter thresholds. [VERIFIED: `BeautyFaceGeometryAdapter.swift`, `WarpControlPoint.swift`] |
| Geometry conflict policy | Per-provider strength scaling | `GeometryConflictResolver` | One scale must cover all emitting geometry fields. [VERIFIED: `DESIGN.md`, current resolver] |
| Warp rendering | A contour-specific CoreImage/Metal pass | `BeautyGeometryEffectPipeline` | Existing local warp already consumes all control points in one pass. [VERIFIED: `BeautyGeometryEffectPipeline.swift`] |
| Diagnostic payload | Field/source/index-specific metrics | Existing fixed warnings and aggregate numeric metrics | Raw/support-derived geometry is biometric-adjacent and prohibited from public diagnostics. [VERIFIED: `SECURITY.md`, `46-CONTEXT.md`] |
| Facade test detector | Real Vision as the only routing test | Existing `SDKTestingFaceDetectionProvider` with deterministic valid observed support | Provider/resolver routing must be deterministic; real Vision remains predecessor/integration evidence. [VERIFIED: `BeautyEngineTestingSupport.swift`, `45-VERIFICATION.md`] |

**Key insight:** The hard edge cases—mapping, topology rejection, conflict scale, local warp, and redaction—already have authoritative owners. Phase 46 should compose them and add field ownership, not duplicate them. [VERIFIED: source and owner contracts]

## Common Pitfalls

### Pitfall 1: The facade fixture has no observed face support

**What goes wrong:** Each isolated public request triggers detection but resolves to provider-empty, so routing tests cannot prove an active new field. [VERIFIED: `BeautyEngineTestingSupport.swift:32-40`]

**Why it happens:** `.usableFace` currently supplies bounds and coarse landmark groups only; its `VisionDetectionObservation` has no `observedFaceSupport`. [VERIFIED: `BeautyEngineTestingSupport.swift`]

**How to avoid:** Add one deterministic asymmetric valid raw contour plus median to the existing `.usableFace` fixture payload, without adding a new public result/API type. Existing shipped-provider outputs must remain identical because they continue to consume the seven-point proxy. [VERIFIED: Phase 45 support isolation contract; fixture change is a recommended implementation]

**Warning signs:** Detector invocation is one, `geometryRequired` is one, but `geometryPointCount` is absent and `.faceShape` is skipped.

### Pitfall 2: Pre-conflict booleans survive post-conflict removal

**What goes wrong:** A removed field can still cause face-domain activation or skip/warning logic based on stale `hasFaceShapeValues`. [VERIFIED: current resolver computes this before conflict]

**How to avoid:** Keep `hadRequestedFaceValues` only for deciding whether degradation evidence is relevant; derive `hasFinalFaceValues` and point counts from final emissions after convergence. [VERIFIED: established requested-vs-final pattern in nose/mouth tests]

### Pitfall 3: Reused scaling precedes support eligibility but eligibility is never rechecked

**What goes wrong:** A new field retains half strength even when reused geometry lacks contour or centerline support. [VERIFIED: risk created by extending current `scaleReusableNonEyeGeometryStrengths`]

**How to avoid:** Scale the four values by exact `0.5`, then run provider preflight against the reused `FaceGeometry`; sanitization must zero only ineligible new fields. [VERIFIED: locked freshness decision]

### Pitfall 4: Smoothing becomes a hidden small-face transform

**What goes wrong:** Moving every observed point toward `face.center` reduces scale rather than local irregularity. [VERIFIED: current `smallFacePoints` implementation and GEOM-01 distinction]

**How to avoid:** Use neighbor chords, preserve endpoints/extrema and vertical coordinates, center the displacement set, and compare vectors/sources directly against `faceSmall`. [VERIFIED: `46-CONTEXT.md`; algorithm details [ASSUMED]]

### Pitfall 5: Path bands overlap at a boundary

**What goes wrong:** The same observed point belongs to both temple and cheekbone, weakening the independence proof. [ASSUMED]

**How to avoid:** Use half-open ranges and test exact source-set disjointness on seven-point and denser asymmetric contours. [ASSUMED]

### Pitfall 6: Provider output is clamped into apparent validity

**What goes wrong:** A non-finite intermediate or wildly out-of-range displacement gets hidden by final clamping. [VERIFIED: threat pattern addressed in existing mouth/nose providers]

**How to avoid:** Validate source, axis, normalized strength, displacement, target, radius, and falloff before constructing/clamping a control point; empty the field on any invalid intermediate. [VERIFIED: `SECURITY.md` provider validation contract]

### Pitfall 7: Phase 46 overclaims output or naturalness

**What goes wrong:** Provider vectors are treated as decoded image/ROI evidence or provisional caps are called final. [VERIFIED: phase boundary]

**How to avoid:** Limit conclusions to field-independent geometry and route evidence; defer decoded output to Phase 47 and final calibration/promotion to Phase 48. [VERIFIED: `ROADMAP.md`, `46-CONTEXT.md`]

## Code Examples

### Contour-Band Membership

```swift
// Source: recommended project-specific pattern derived from Phase 45 canonical open-path contract.
func pathProgress(index: Int, count: Int) -> Float {
    guard count > 1 else { return 0 }
    return Float(index) / Float(count - 1)
}

func isTemple(_ progress: Float) -> Bool {
    (0.10..<0.30).contains(progress) || (0.70..<0.90).contains(progress)
}

func isCheekbone(_ progress: Float) -> Bool {
    (0.30..<0.46).contains(progress) || (0.54..<0.70).contains(progress)
}
```

[ASSUMED]

### Apex-Adjacent Taper

```swift
// Source: recommended project-specific pattern constrained by GEOM-04.
guard support.centerlineEligible,
      let median = support.medianLine,
      let apexIndex = support.apexIndex,
      support.contour.indices.contains(apexIndex - 1),
      support.contour.indices.contains(apexIndex + 1)
else {
    return []
}

let sourceIndices = [apexIndex - 1, apexIndex + 1]
// For each source, interpolate median X at source.y, move X inward,
// keep target.y == source.y, and never emit support.contour[apexIndex].
```

[VERIFIED: eligibility guards in `BeautyFaceSemanticSupport`; interpolation policy [ASSUMED]]

### Monotone Convergence Skeleton

```swift
// Source pattern: BeautyEffectResolver.resolveGeometryConflict.
var retainedBaseline = preflightSanitizedStrengths
for _ in 0..<37 {
    let resolution = GeometryConflictResolver().resolve(strengths: retainedBaseline)
    let nextBaseline = sanitizeAllProviderEmissions(
        evaluatedAt: resolution.strengths,
        baseline: retainedBaseline,
        face: faceGeometry
    )
    if nextBaseline == retainedBaseline {
        return resolution
    }
    retainedBaseline = nextBaseline
}
return GeometryConflictResolver().resolve(strengths: retainedBaseline)
```

[VERIFIED: existing retained-baseline implementation; 37 bound derived from Phase 46 field inventory]

## State of the Art

| Old Approach | Current Phase 46 Approach | When Changed | Impact |
|---|---|---|---|
| Aggregate face/chin provider arrays | Nine named face/chin field emissions | Phase 46 | Enables field-local empty-output removal and exact ownership evidence. [VERIFIED: phase goal] |
| Five face fields in shared geometry total | Nine face fields; 37 geometry fields total | Phase 46 | Four new controls participate exactly once in weakening. [VERIFIED: current 33-field ledger plus four requirements] |
| No observed face support consumption | Three contour-only consumers plus one contour/centerline consumer | Phase 46 | Actual mapped contour drives only the new fields; legacy proxy remains isolated. [VERIFIED: Phase 45/46 contracts] |
| 28-removal convergence ceiling | 37-removal ceiling | Phase 46 | All named provider fields can fail closed without re-entry. [VERIFIED: field inventory] |
| New public values intentionally unrouted | Detection/resolver/unified-warp route active | Phase 46 | Public isolated requests can produce internal control points while facade diagnostics remain aggregate. [VERIFIED: Phase 45 boundary and Phase 46 goal] |

**Deprecated/outdated:**

- Phase 45 tests asserting the four nonzero fields do not require geometry become outdated in Phase 46 and must be replaced with positive routing expectations while retaining explicit-zero neutrality. [VERIFIED: `BeautyEffectResolverTests.swift:154-202`, phase boundary]
- Phase 45 owner text saying none of the four fields enters runtime seams must be updated to record Phase 46's provisional provider/routing contract, without promoting product rows or final caps. [VERIFIED: `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|---|---|---|
| A1 | Use disjoint path-progress bands `0.10..<0.30`/`0.70..<0.90` for temple and `0.30..<0.46`/`0.54..<0.70` for cheekbone. | Architecture Patterns | A valid dense contour could place the selected samples outside the visually intended anatomical band; Phase 47/48 may recalibrate. |
| A2 | Start all four provisional effective caps at `0.25`. | Architecture Patterns | Conflict totals and visible strength change; Phase 48 must calibrate and may replace them. |
| A3 | Start maximum displacement at 1.2%/1.8%/1.8%/1.6% of face width and local radii at 8%/14%/14%/12%. | Architecture Patterns | Output may be too subtle/strong; provider correctness is unaffected but downstream ROI/naturalness evidence may require adjustment. |
| A4 | Preserve smooth-contour center/scale using lateral-only, mean-centered deltas while excluding endpoints and horizontal extrema. | Architecture Patterns | Mean correction could reduce local improvement for a highly asymmetric contour; tests must require aggregate improvement and fail closed on no usable delta. |
| A5 | Preserve chin length by interpolating median X at source Y and keeping every taper target Y unchanged. | Architecture Patterns | A strongly rotated/sloped median may be better served by perpendicular projection; Phase 47 visual evidence can inform later calibration without changing eligibility. |

## Open Questions

No blocking user decision remains: contour bands, private helper names, provisional caps, radii, falloff, and displacement constants are explicitly delegated to the agent. [VERIFIED: `46-CONTEXT.md`]

Implementation should record the chosen provisional values in `DESIGN.md`/`RELIABILITY.md` as non-final and make them easy for Phase 48 to replace. [VERIFIED: `AGENTS.md`, phase ownership]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|---|---|---|---|---|
| Swift | Package implementation/tests | ✓ | 6.3.3 | — |
| SwiftPM | Build/test | ✓ | bundled with Swift 6.3.3 | — |
| Xcode | Apple frameworks if host tests need it | ✓ | 26.6 (17F113) | SwiftPM focused tests for Phase 46 |
| Python | Optional static boundary checker | ✓ | 3.9.6 | `rg`/shell scans if no checker is added |
| Git | Diff/status hygiene | ✓ | 2.50.1 | — |

[VERIFIED: 2026-07-23 environment probes]

**Missing dependencies with no fallback:** None. [VERIFIED: environment probes]

**Missing dependencies with fallback:** None. [VERIFIED: environment probes]

## Validation Architecture

### Test Framework

| Property | Value |
|---|---|
| Framework | XCTest from installed Swift 6.3.3 toolchain [VERIFIED: source/environment] |
| Config file | `BeautySDK/Package.swift` [VERIFIED: codebase] |
| Quick provider command | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` |
| Quick resolver command | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.BeautyEffectResolverTests` |
| Full suite command | `swift test --package-path BeautySDK --disable-sandbox --jobs 1` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|---|---|---|---|---|
| GEOM-01 | Smooth emission owns exact asymmetric interior sources, reduces aggregate lateral roughness, preserves endpoints/extrema/center, and differs from `faceSmall` | unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ extend |
| GEOM-02 | Temple emission uses only upper bands, moves outward, stays finite/bounded, and differs from face slim/small | unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ extend |
| GEOM-03 | Cheekbone emission uses only mid bands, moves inward, is disjoint from temple/jaw/whole-cheek sources | unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ extend |
| GEOM-04 | Taper requires contour+median+apex, uses only apex neighbors, keeps all Y/apex unchanged, and differs from chin length/V-face | unit | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | ✅ extend |
| GEOM-01..04 | Four caps/effective values, `requiresFaceGeometry`, provider-empty removal, final activation/counts | integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.BeautyEffectResolverTests` | ✅ extend |
| GEOM-01..04 | Four fields participate once in totals/scales and representative removal remains monotone | unit/integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.GeometryConflictResolverTests` | ✅ extend |
| GEOM-01..04 | Missing contour/centerline, malformed, no-face, stale, reused, provider-empty, valid sibling | integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.MissingLandmarkDegradationTests` | ✅ extend |
| GEOM-01..04 | Representative combined face/eye/nose/mouth weakening and no re-entry | integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.CombinedEffectSafetyTests` | ✅ extend |
| GEOM-01..04 | Final effective strengths dispatch through existing unified provider concatenation | integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.BeautyGeometryEffectPipelineTests` | ✅ extend |
| GEOM-01..04 | Each isolated public request invokes detection, uses observed support, preserves extent, emits aggregate point evidence, and stays redacted | facade integration | `swift test --package-path BeautySDK --disable-sandbox --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | ✅ extend |

### Required Fixture Matrix

| Fixture | Purpose | Minimum Assertions |
|---|---|---|
| Asymmetric complete support | Distinguish all four source sets | Exact source arrays, non-overlap, direction, finite/unit/radius/falloff bounds |
| Contour-only | Enable smooth/temple/cheek; disable taper | Three non-empty emissions; taper empty and strength zero |
| Missing observed contour with valid legacy proxy | Prove no compatibility fallback | Four new empty; five shipped emissions byte-for-byte unchanged |
| Valid contour + missing/malformed median | Local centerline failure | Three contour fields survive; taper zero |
| Provider-empty at tiny/degenerate effective work | Prove sanitization | Zero final strength; absent total/count/scale/point contribution |
| Valid shipped sibling + invalid new field | Prove sibling independence | Face domain active from sibling; invalid new field zero; no alias vectors |
| Fresh → reused → stale → fresh | Prove statelessness | Fresh emits; reused exact 0.5 before eligible emission; stale/no-face zero new fields; final fresh restores without carryover |
| SPI usable public face with asymmetric observed support | Prove facade route | One detection call, usable summary, geometry required, positive aggregate point count, redacted metadata |

[VERIFIED: locked testing decisions and established analogous nose/mouth/eye matrices]

### Sampling Rate

- **Per provider task commit:** `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests.FaceShapeWarpProviderTests`
- **Per resolver/conflict task commit:** run the focused resolver plus conflict suite.
- **Per integration task commit:** run degradation, combined safety, pipeline, and facade focused suites.
- **Per wave merge:** `swift test --package-path BeautySDK --disable-sandbox --filter BeautyEffectsTests`
- **Phase gate:** `swift test --package-path BeautySDK --disable-sandbox --jobs 1`, then `git diff --check`.

### Wave 0 Gaps

- [ ] Add reusable asymmetric complete/contour-only/missing-centerline `FaceGeometry` fixtures in test code; current shared `.fixture` has only the seven-point legacy proxy and no observed face support. [VERIFIED: `FaceShapeWarpProviderTests.swift`]
- [ ] Make the deterministic facade `.usableFace` payload carry valid asymmetric raw contour/median support; it currently carries only coarse landmark availability. [VERIFIED: `BeautyEngineTestingSupport.swift`]
- [ ] Replace the Phase 45 resolver assertion that nonzero new fields remain unrouted with Phase 46 positive routing and explicit-zero-neutrality coverage. [VERIFIED: `BeautyEffectResolverTests.swift:154-202`]
- [ ] Add key-path helpers for the four new `BeautyEffectiveStrengths` and named emission arrays in table-driven degradation/conflict tests. [VERIFIED: analogous test structure]

No test framework installation or new test target is needed. [VERIFIED: `BeautySDK/Package.swift`]

## Security Domain

ASVS L1 enforcement is active; Phase 46 changes how untrusted biometric-adjacent contour data becomes render work, so validation, fail-closed degradation, bounded computation, and information-disclosure checks are implementation requirements rather than closeout-only documentation. [VERIFIED: `.planning/config.json`, `SECURITY.md`]

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---|---|---|
| V2 Authentication | no | No account/authentication surface exists in Phase 46. [VERIFIED: scope] |
| V3 Session Management | no | Observed support is request-scoped data, not a user session. [VERIFIED: Phase 45 contract] |
| V4 Access Control | no | No privileged/commercial/entitlement behavior is added. [VERIFIED: scope] |
| V5 Validation, Sanitization and Encoding | yes | Phase 45 topology eligibility plus provider finite/unit/source/target/radius/falloff validation and provider-empty sanitization. [VERIFIED: `SECURITY.md`, `46-CONTEXT.md`] |
| V6 Stored Cryptography | no | No storage, key, signature, or cryptographic operation is introduced. [VERIFIED: scope] |
| V7 Error Handling and Logging | yes | Fixed aggregate warning codes and numeric aggregate metrics only; no field indices, support measurements, or coordinates. [VERIFIED: `SECURITY.md`] |
| V10 Malicious Code | yes, boundary check | No dependency, model, resource, generated executable, or network path may be added. [VERIFIED: scope/dependency policy] |
| V12 Files and Resources | limited | No generated image or semantic resource is created/tracked; existing fixture files are read only by tests. [VERIFIED: scope] |
| V13 API and Web Service | limited to SDK API | Public scalar inputs normalize before expensive detection/provider work; no new facade method or result type. [VERIFIED: `SECURITY.md`, Phase 45 public contract] |

### Threat Model

| Asset / Boundary | Threat | STRIDE | Required Mitigation | Verification |
|---|---|---|---|---|
| Observed contour/median → provider | Malformed support authorizes geometry or synthetic fallback | Spoofing / Tampering | Require exact `contourEligible`/`centerlineEligible`; never read proxy for new fields; empty only dependent emission. | Missing/malformed/legacy-proxy fixtures |
| Numeric geometry intermediates | NaN/∞/out-of-range values become render points | Tampering / DoS | Check every intermediate for finiteness; enforce closed-unit sources/targets and bounded radius/falloff before output. | Per-field malformed and finite-bound assertions |
| Contour cardinality and convergence | Excessive work or non-terminating mask oscillation | DoS | Retain Phase 45 32/16 ceilings; use O(n) band/chord calculations; loop at most 37 times; only zero fields. | Cardinality fixture, source scan for `0..<37`, no-reentry test |
| Diagnostics / Mirror / facade | Coordinates, apex index, band membership, displacement, or support measurements leak | Information Disclosure | Preserve package-only non-Codable support; expose only approved aggregate counts/codes; extend sentinel/redaction scans to new identifiers. | Resolver/facade redaction tests and static public/SPI scan |
| Provider ownership | A new field borrows a shipped source/vector | Tampering / Integrity | Named arrays, exact source subset, nearest-field vector inequality, and byte-for-byte shipped emission snapshots. | Provider unit tests |
| Freshness transition | Reused/stale prior support survives into a later request | Tampering / Privacy | Pure value providers/resolver; no cache; preflight each request after freshness scaling; fresh/reused/stale/fresh sequence. | Degradation transition test |
| Dependency/resource boundary | New model/package/network path enters implementation | Supply chain / Information Disclosure | Keep `Package.swift`, manifests, resource inventory, and active network imports unchanged. | Scoped git diff/static scans |
| Generated output | Phase 47 images become tracked evidence early | Information Disclosure / Scope | Do not run gallery generation or add output files in Phase 46. | `git status --short`, `git ls-files example-images/output example-images/gallery` |

### Security Implementation Checklist

- Provider helpers must be package/internal and must not add `public`, `package` SPI geometry, Codable, persistence, cache, static mutable state, or raw diagnostic interpolation. [VERIFIED: Phase 45 security boundary]
- Descriptions and mirrors must remain aggregate-only; do not add field names tied to source counts, indices, axis values, or eligibility details. [VERIFIED: `SECURITY.md`]
- Reuse existing stable warnings where semantically correct; if a face-input-missing category is added, its message must contain no support type, coordinate, provider, index, or field-specific measurement. [VERIFIED: diagnostic policy]
- Add a scoped static scan or extend the phase validation commands for public/SPI exposure, Codable/persistence, raw geometry diagnostic tokens, network/cloud imports, dependency/manifest drift, Demo/renderer imports, and generated artifacts. Do not weaken the historical Phase 45 checker to make new source pass. [VERIFIED: existing fail-closed checker pattern; recommendation]
- Owner docs must state that observed support remains local, request-scoped, and non-persistent and that the privacy-manifest disposition is unchanged because no collection/network/required-reason API behavior is added. [VERIFIED: `SECURITY.md` decision policy]

## Recommended Planning Sequence

1. **Wave 0 — fixtures and failing contracts:** asymmetric observed support, named emission expectations, Phase 45 unrouted-test replacement, and facade fixture support. [VERIFIED: validation gaps]
2. **Provider wave — geometry ownership:** add seven face and two chin named emissions; implement four local transforms; lock shipped emission equality. [VERIFIED: dependency order]
3. **Planning/convergence wave — ledger correctness:** effective fields, provisional caps, face-geometry trigger, freshness helpers, preflight, 37-bound conflict, and final emission accounting. [VERIFIED: runtime seam dependencies]
4. **Integration wave — unified dispatch and representative degradation:** pipeline, no-face/missing/malformed/reused/stale/provider-empty/valid-sibling and facade routing. [VERIFIED: phase success criteria]
5. **Contract/security closeout:** focused/full SwiftPM, redaction/boundary scans, diff hygiene, and synchronized `DESIGN.md`, `ARCHITECTURE.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and `PLANS.md` without promotion or final-cap claims. [VERIFIED: `AGENTS.md`, phase scope]

## Sources

### Primary (HIGH confidence)

- `.planning/phases/46-independent-contour-and-chin-geometry/46-CONTEXT.md` — locked semantics, locality, eligibility, convergence, testing, privacy, and scope.
- `.planning/REQUIREMENTS.md` and `.planning/ROADMAP.md` — GEOM-01..04 and success criteria.
- `.planning/phases/45-public-contract-and-observed-face-support/45-VERIFICATION.md` — trusted observed-support predecessor.
- `BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift` — current four shipped face vectors.
- `BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift` — current signed chin-length vector.
- `BeautySDK/Sources/BeautyEffects/Warp/{Eye,Nose,Mouth}WarpProvider.swift` — named emission and sanitization pattern.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` — caps, freshness, preflight, convergence, activity, diagnostics, and point accounting.
- `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` — current 33-field shared total/count/scale.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` — unified dispatch and local warp.
- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` and `Planning/BeautyFaceGeometryAdapter.swift` — semantic support and eligibility contract.
- Current provider/resolver/conflict/degradation/pipeline/facade XCTest sources — established validation patterns.
- `AGENTS.md`, `DESIGN.md`, `ARCHITECTURE.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `PLANS.md` — repository and owner constraints.

### Secondary (MEDIUM confidence)

- `.planning/milestones/v1.11-phases/42-independent-eye-geometry-and-pipeline-integration/42-RESEARCH.md` — closest analogous phase; verified against current source before reuse.

### Tertiary (LOW confidence)

- None. Algorithm constants and band choices are explicitly recorded as `[ASSUMED]`, not sourced facts.

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH — directly inspected package manifest and installed toolchain.
- Architecture: HIGH — directly inspected every current provider/resolver/conflict/pipeline seam and predecessor verification.
- Geometry semantics: HIGH for required direction/locality/eligibility; MEDIUM for provisional band and displacement choices delegated by context.
- Pitfalls: HIGH — most arise from direct current-source control flow; overlap/visual-constant risks are explicitly assumed.
- Security: HIGH — derived from active ASVS L1 config, current security contract, and Phase 45 boundary evidence.

**Research date:** 2026-07-23  
**Valid until:** 2026-08-22 for repository structure; provisional geometry constants remain valid only until Phase 47/48 evidence.
