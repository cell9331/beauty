# Phase 50: Independent Eyebrow Geometry and Pipeline Integration - Research

**Researched:** 2026-07-24
**Domain:** Swift package-internal eyebrow geometry, field-local eligibility, resolver/convergence accounting, unified warp dispatch, and public-facade routing
**Confidence:** HIGH for repository seams, locked behavior, and test architecture; MEDIUM for provisional geometry constants and the new effect-domain case

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Seven Independent Geometry Semantics
- Implement one named provider emission per public field: vertical position translates the whole supported brow vertically; thickness expands/contracts locally across the trace normal; length extends/contracts the outer endpoint region; whole-brow spacing moves both brows symmetrically away from/toward the face center; inner-head spacing moves only the inner endpoint neighborhoods; tilt applies an endpoint-weighted rotation around each brow center; peak definition moves only an eligible apex neighborhood.
- Preserve signed direction for the six signed fields and positive-only behavior for peak definition; no field may alias another field's vectors or silently reuse an eye/face parameter.
- Providers consume the Phase 49 canonical inner-to-outer semantic traces directly and must not sort, remap, close, synthesize, or persist them.
- Keep all geometry brow-local and leave every shipped face, eye, nose, and mouth control-point array byte-for-byte unaffected by eyebrow-only input.

### Eligibility and Local Degradation
- Vertical position, thickness, and length are independently eligible per valid side; a missing or malformed sibling removes only that side's contribution.
- Whole-brow spacing requires two distinct valid sides; inner-head spacing remains independently computable per valid side from its canonical inner endpoint.
- Tilt is per-side and requires a nondegenerate canonical chord; peak definition is per-side and additionally requires the Phase 49 unique interior apex.
- Provider-empty work is removed field-locally before final evidence; missing, malformed, no-face, stale, or ineligible support never fabricates fallback geometry, while eligible eyebrow siblings and unrelated safe domains continue.

### Resolver, Conflict, and Unified Dispatch
- Add seven named effective strengths and seven named provider emissions through the existing resolver and public facade; preserve normalized public values until the provider-specific provisional caps are applied exactly once.
- Extend the provider-eligible convergence inventory from 37 to exactly 44 named fields, with one monotone removal loop, no re-entry, and one final scale shared consistently by strengths, provider output, dispatch, metrics, and warnings.
- Route eyebrow emissions through the existing unified warp dispatch exactly once; do not add a second renderer, pre-warp pass, or eyebrow-special public path.
- Preserve conflict policy symmetry with existing provider-owned geometry: field-local removals are monotone, unrelated domains are not weakened merely because eyebrow support is absent, and reused eligible geometry follows the established freshness scale exactly once.

### Evidence and Scope Guardrails
- Use focused provider, resolver, conflict, combined-plan, pipeline, degradation, and public-facade tests plus the full SwiftPM suite; lock exact named-field counts, totals, scales, removals, and dispatch agreement rather than relying on visual inspection.
- Keep provisional eyebrow caps internal to Phase 50 and explicitly non-final; Phase 52 owns conservative final cap calibration and exhaustive boundary/transition evidence.
- Add no dependency, model, resource pack, SwiftUI/Demo source, network/cloud path, persistence, commercial behavior, or public/SPI raw-geometry surface.
- Do not add Phase 51 renderer/gallery cases or claim visible direction/locality/distinction evidence, and do not promote any `眉毛` product row or branch status before Phase 52.

### the agent's Discretion
- Exact provider type names, helper decomposition, provisional cap values, locality falloff functions, and test-file partitioning may follow the existing eye/mouth/face provider patterns, provided all seven semantics remain independently named, eligibility rules and the exact 44-field convergence contract are enforced, and Phase 49 privacy/non-substitution boundaries remain intact.

### Deferred Ideas (OUT OF SCOPE)

- Phase 51: thirteen isolated public-facade cases, decoded 504-output direction/locality/distinction evidence, safe no-ops, and ignored gallery containment.
- Phase 52: final caps, exhaustive fresh/reused/stale/no-face/missing/malformed/provider-empty transitions, active-source/privacy gates, exact seven-row promotion, and implemented branch status.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|---|---|---|
| GEOM-01 | Signed eyebrow vertical position translates eligible complete brow traces up or down without moving the eyes or aliasing eye vertical position. | Translate only canonical eyebrow trace points, keep every non-eyebrow provider result unchanged, and prove opposite signs plus provider-array distinction. [VERIFIED: codebase grep — `.planning/REQUIREMENTS.md`, `50-CONTEXT.md`] |
| GEOM-02 | Signed eyebrow thickness performs bounded trace-normal expansion or compression inside a protected brow-local strip without makeup, texture synthesis, or resource placement. | Derive local tangents from canonical adjacency, emit paired normal-offset strip points, and forbid resource/color paths. [VERIFIED: codebase grep — `.planning/REQUIREMENTS.md`, `50-CONTEXT.md`; exact strip constants [ASSUMED]] |
| GEOM-03 | Signed eyebrow length extends or contracts outer endpoint neighborhoods while preserving inner heads and avoiding whole-brow scaling. | Use only the canonical outer endpoint and its adjacent sample with endpoint-weighted chord displacement; assert inner-source absence and inequality from whole-brow transforms. [VERIFIED: codebase grep — `.planning/REQUIREMENTS.md`, `50-CONTEXT.md`; two-sample neighborhood [ASSUMED]] |
| GEOM-04 | Signed overall eyebrow spacing translates complete paired brows symmetrically around the face center. | Require `pairedEligible`, derive the pair axis from left/right semantic centers, and move the two complete traces by equal and opposite signed deltas. [VERIFIED: codebase grep — `.planning/REQUIREMENTS.md`, `50-CONTEXT.md`] |
| GEOM-05 | Signed eyebrow-head spacing moves only canonical inner endpoint neighborhoods and remains distinguishable from overall spacing. | Use only each trace's first two canonical samples, weighted from `innerEndpoint`, and never translate the complete trace. [VERIFIED: codebase grep — `.planning/REQUIREMENTS.md`, `50-CONTEXT.md`; two-sample neighborhood [ASSUMED]] |
| GEOM-06 | Signed eyebrow tilt rotates each eligible brow locally around its center and preserves direction across orientation and mirroring. | Require a finite nondegenerate inner-to-outer chord, rotate noncentral trace samples around the stored center, and derive sign from the canonical chord so positive/negative direction survives horizontal mirroring. [VERIFIED: codebase grep — `.planning/REQUIREMENTS.md`, Phase 49 canonicalization tests; sign convention [ASSUMED]] |
| GEOM-07 | Positive-only eyebrow peak definition adjusts a bounded interior apex relative to the endpoint chord without translating the whole brow. | Require the stored unique interior `apexIndex`, move only apex plus immediate neighbors along the chord-to-apex normal, and leave endpoints/center translation absent. [VERIFIED: codebase grep — `.planning/REQUIREMENTS.md`, `WarpControlPoint.swift`; neighbor weighting [ASSUMED]] |
| PIPE-01 | All seven eyebrow fields have named provider emissions, field-local eligibility, provider-empty removal, resolver/facade routing, and safe continuation of eligible sibling and non-eyebrow domains. | Add a seven-array emissions value with `sanitizing(_:)`, preflight/final provider evaluation, an eyebrow domain route, fixed redacted skip evidence, and isolated facade tests using actual observed support. [VERIFIED: codebase grep — `.planning/REQUIREMENTS.md`, existing eye/nose/mouth providers] |
| PIPE-02 | Combined face, eye, eyebrow, nose, and mouth geometry converges monotonically over one exact 44-field provider-eligible retained set whose final strengths, totals, counts, scale, warnings, metrics, and unified dispatch agree. | Extend all three conflict inventories, the retained-baseline loop bound, all-provider sanitization, exact combined fixtures, and dispatch concatenation from 37 to 44 fields. [VERIFIED: codebase grep — `.planning/REQUIREMENTS.md`, `BeautyEffectResolver.swift`, `GeometryConflictResolver.swift`, `CombinedEffectSafetyTests.swift`] |
</phase_requirements>

## Summary

Phase 50 is a new `BeautyEffects` provider slice routed through existing planning and rendering seams; it does not require a new detector request, public geometry carrier, renderer, pass, dependency, model, or resource. Phase 49 already delivers independently optional, canonical inner-to-outer `BeautyEyebrowSemanticTrace` values with exact points, endpoints, center, optional unique interior apex, side identity, and pair eligibility on `FaceGeometry`. [VERIFIED: codebase grep — `WarpControlPoint.swift`, `BeautyFaceGeometryAdapter.swift`, `49-VERIFICATION.md`]

The main implementation risk is cross-seam accounting drift. The current runtime has exactly 37 geometry strengths across nine face/chin, fourteen eye, six nose, and eight mouth fields; those fields are preflight-sanitized, weakened with one shared scale, recomputed from one retained baseline, counted from final named emissions, and concatenated once into `BeautyGeometryEffectPipeline`. Eyebrow fields are currently absent from `requiresFaceGeometry`, `BeautyEffectiveStrengths`, safety caps, effect domains, providers, the 37-field resolver loop, conflict totals/counts/scaling, unified dispatch, facade fixtures, and all final runtime evidence. [VERIFIED: codebase grep — `BeautyEffectPlan.swift`, `BeautyEffectDomain.swift`, `BeautyEffectResolver.swift`, `GeometryConflictResolver.swift`, `BeautyGeometryEffectPipeline.swift`, `BeautyEngineTestingSupport.swift`]

The safest plan is to add one `EyebrowWarpProvider` with seven immutable named emission arrays, make that provider the only consumer of Phase 49 semantic brow support, sanitize it both before and during conflict convergence, and use its final emissions as the sole authority for eyebrow activity and point accounting. All geometry constants in this phase must remain clearly provisional; provider-vector correctness is testable now, while decoded ROI behavior and final naturalness remain Phases 51 and 52. [VERIFIED: codebase grep — `50-CONTEXT.md`, established provider pattern; exact provisional constants [ASSUMED]]

**Primary recommendation:** Add a distinct eyebrow domain and provider between eye and nose dispatch, use provisional `0.25` caps for all seven fields, extend the exact retained inventory to 44 fields with a `13.45` all-cap baseline, and prove final named emissions, strengths, totals, counts, scale, warnings, metrics, and dispatch are identical views of one final mask. [VERIFIED: codebase grep — 37-field baseline is `11.70`; new domain/caps and resulting `13.45` total [ASSUMED]]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|---|---|---|---|
| Public eyebrow scalar normalization | API / Backend (`BeautyCore`) | — | The exact seven stored public fields and signed/unit normalization are already complete and must remain unchanged. [VERIFIED: codebase grep — `BeautyParameters.swift`, `49-VERIFICATION.md`] |
| Observed eyebrow capture and canonicalization | API / Backend (`BeautyDetection`) | API / Backend (`BeautyEffects` adapter) | Phase 49 owns the single Vision request, mapping, open-path validation, side/order canonicalization, and semantic attachment; Phase 50 only consumes the result. [VERIFIED: codebase grep — `VisionFaceDetector.swift`, `BeautyFaceGeometryAdapter.swift`] |
| Field-local eyebrow vectors | API / Backend (`BeautyEffects/Warp`) | — | A new provider should own source selection, target construction, radii, falloff, named emissions, and provider-empty results. [VERIFIED: codebase grep — existing eye/nose/mouth provider pattern; new provider name [ASSUMED]] |
| Caps, freshness, eligibility, domains, warnings, metrics | API / Backend (`BeautyEffects/Planning`) | — | `BeautyEffectResolver` is the existing authority for these plan-level decisions. [VERIFIED: codebase grep — `BeautyEffectResolver.swift`] |
| Combined 44-field weakening | API / Backend (`BeautyEffects/Warp`) | API / Backend (`BeautyEffects/Planning`) | `GeometryConflictResolver` calculates one scale; the resolver owns monotone provider re-evaluation. [VERIFIED: codebase grep — current conflict and resolver source] |
| Exactly-once geometry dispatch | API / Backend (`BeautyEffects/Render`) | `BeautyRender` local warp | `BeautyGeometryEffectPipeline` concatenates provider points and applies the existing local warp once. [VERIFIED: codebase grep — `BeautyGeometryEffectPipeline.swift`, `ARCHITECTURE.md` A5] |
| Public request routing and redacted result | API / Backend (`BeautySDK`) | — | `BeautyEngine` already triggers detection from `requiresFaceGeometry`, passes the selected observation internally, and returns only output, warnings, metrics, and a redacted summary. [VERIFIED: codebase grep — `BeautyEngine.swift`, `BeautyEngineGeometryDetection.swift`] |

## Project Constraints (from AGENTS.md)

- Treat repository text as the system of record and do not assume facts absent from repository source, tests, plans, or owner documents. [VERIFIED: codebase grep — `AGENTS.md`]
- Read `PLANS.md` and the owning technical documents before edits; code and tests outrank plans, specialist documents, and historical `docs/` material. [VERIFIED: codebase grep — `AGENTS.md`]
- Keep implementation focused, preserve unrelated local changes, follow current names/directories/abstraction levels, run the narrowest meaningful verification, and record what changed, why, and how it was verified. [VERIFIED: codebase grep — `AGENTS.md`]
- Update the owning contracts when behavior changes: `ARCHITECTURE.md` for provider/dependency boundaries, `DESIGN.md` for geometry/pipeline semantics, `SECURITY.md` for untrusted support and redaction, `RELIABILITY.md` for degradation/accounting, `PRODUCT_SENSE.md` for acceptance/nonclaims, `QUALITY_SCORE.md` if quality policy changes, and `PLANS.md` for execution evidence. [VERIFIED: codebase grep — `AGENTS.md`]
- Do not duplicate one fact across multiple documents or expand scope opportunistically; record extra issues as technical debt. [VERIFIED: codebase grep — `AGENTS.md`]
- If Xcode validation becomes necessary, list schemes and available simulators first and use an explicit iOS Simulator destination; Phase 50 is SwiftPM-only unless the implementation unexpectedly touches Demo/Xcode scope. [VERIFIED: codebase grep — `AGENTS.md`, `50-CONTEXT.md`]

## Standard Stack

### Core

| Library / Tool | Version | Purpose | Why Standard |
|---|---|---|---|
| Swift | 6.3.3 installed; package tools 6.0 | Provider math, immutable value ledgers, resolver, tests | Existing repository language and manifest contract. [VERIFIED: environment probe, `BeautySDK/Package.swift`] |
| Swift Package Manager | Bundled with Swift 6.3.3 | Build and test six library targets plus the example executable and test targets | The package declares only local targets and no external dependency. [VERIFIED: codebase grep — `BeautySDK/Package.swift`] |
| XCTest | Toolchain bundled | Provider, resolver, conflict, degradation, pipeline, and facade verification | All current package tests use XCTest. [VERIFIED: codebase grep — `BeautySDK/Tests/**/*.swift`] |
| `SIMD2<Float>` | Swift standard library | Image-normalized vector math | `FaceGeometry`, semantic traces, and every warp provider use this representation. [VERIFIED: codebase grep — `WarpControlPoint.swift`, provider sources] |
| Core Image | Apple platform framework | Existing still-image local warp and facade integration | The current unified geometry path already warps `CIImage` output through `BeautyGeometryEffectPipeline`. [VERIFIED: codebase grep — `BeautyGeometryEffectPipeline.swift`, `BeautyColorEffectPipeline.swift`] |

### Supporting

| Library / Tool | Version | Purpose | When to Use |
|---|---|---|---|
| Python | 3.9.6 | Phase-scoped fail-closed static/boundary checker | Add a Phase 50 checker derived from the Phase 49 pattern; do not weaken or repurpose the historical Phase 49 checker. [VERIFIED: environment probe, Phase 49 checker; new checker recommendation [ASSUMED]] |
| Git | 2.50.1 | Scope, tracked-artifact, and diff hygiene | Run status, scoped diff, tracked-output, and `git diff --check` gates. [VERIFIED: environment probe, `AGENTS.md`] |
| Xcode | 26.6 (17F113) | Apple framework/toolchain host | Available, but no Demo build is required when Demo/Xcode source remains untouched. [VERIFIED: environment probe, phase scope] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|---|---|---|
| Canonical Phase 49 brow traces | Eye contours, synthetic points, or regenerated curves | Explicitly prohibited; they destroy provenance and local-failure guarantees. [VERIFIED: codebase grep — `50-CONTEXT.md`, `SECURITY.md`] |
| Seven named provider arrays | One aggregate brow array | Cannot prove independent eligibility, provider-empty removal, or semantic distinction. [VERIFIED: codebase grep — `50-CONTEXT.md`, existing named-emission pattern] |
| One existing unified warp | A brow-specific pass or second render route | Explicitly prohibited and would alter ordering, accounting, and public routing. [VERIFIED: codebase grep — `50-CONTEXT.md`, `ARCHITECTURE.md` A5] |
| Pair-axis and canonical chord math | Sorting/remapping the trace inside the provider | Sorting/remapping violates the sealed Phase 49 inner-to-outer topology. [VERIFIED: codebase grep — `50-CONTEXT.md`, `49-VERIFICATION.md`] |

**Installation:** None. Do not add packages, products, targets, models, resources, or runtime downloads. [VERIFIED: codebase grep — `50-CONTEXT.md`, `BeautySDK/Package.swift`]

## Package Legitimacy Audit

Not applicable. Phase 50 installs no external package, and `BeautySDK/Package.swift` currently declares only local targets plus Apple/Swift toolchain facilities. [VERIFIED: codebase grep — `BeautySDK/Package.swift`, `50-CONTEXT.md`]

## Architecture Patterns

### System Architecture Diagram

```text
BeautyParameters (7 already-public eyebrow scalars)
        ↓ normalized; zero remains no-op
BeautyEffectResolver.requiresFaceGeometry
        ↓ one existing selected-face detection request
BeautyFaceGeometryAdapter
        ↓ existing request-local BeautyEyebrowSemanticSupport
Normalize → provisional cap → freshness policy
        ↓
EyebrowWarpProvider.fieldEmissions
  ├─ Y position: each valid side
  ├─ thickness: each valid side
  ├─ length: each valid side
  ├─ spacing: valid distinct pair only
  ├─ head spacing: each valid side
  ├─ tilt: each valid nondegenerate chord
  └─ peak: each valid unique interior apex
        ↓ sanitize requested fields whose own work is empty
Retained baseline (face + eye + eyebrow + nose + mouth = 44 fields)
        ↓ one GeometryConflictResolver scale
Re-evaluate all six provider groups at scaled strengths
  ├─ unchanged field mask → final resolution
  └─ smaller mask → retain removals and repeat; never re-add; max 44
        ↓
Final emissions own domains + warnings + metrics + point count
        ↓ exact provider order
Face → Chin → Eye → Eyebrow → Nose → Mouth
        ↓
Existing BeautyGeometryEffectPipeline local warp exactly once
        ↓
BeautyEngine public result (image + aggregate/redacted evidence only)
```

[VERIFIED: codebase grep — current resolver/provider/pipeline/facade flow plus locked Phase 50 requirements; new provider order [ASSUMED]]

### Recommended Project Structure

```text
BeautySDK/
├── Sources/BeautyEffects/
│   ├── Planning/
│   │   ├── BeautyEffectDomain.swift          # add distinct eyebrow domain
│   │   ├── BeautyEffectPlan.swift            # seven effective strengths
│   │   ├── BeautySafetyCaps.swift             # seven provisional caps
│   │   └── BeautyEffectResolver.swift         # route, freshness, sanitize, 44-loop, evidence
│   ├── Warp/
│   │   ├── EyebrowWarpProvider.swift          # seven named emissions and local vector helpers
│   │   └── GeometryConflictResolver.swift     # 44-field scale/total/count
│   └── Render/
│       └── BeautyGeometryEffectPipeline.swift # one extra provider concatenation only
├── Sources/BeautySDK/
│   └── BeautyEngineTestingSupport.swift       # deterministic valid/partial/malformed raw brow fixtures
└── Tests/
    ├── BeautyEffectsTests/
    │   ├── EyebrowWarpProviderTests.swift     # new Wave 0/provider owner
    │   ├── BeautyEffectResolverTests.swift
    │   ├── GeometryConflictResolverTests.swift
    │   ├── CombinedEffectSafetyTests.swift
    │   ├── MissingLandmarkDegradationTests.swift
    │   └── BeautyGeometryEffectPipelineTests.swift
    └── BeautyCoreTests/
        └── BeautyEngineGeometryFacadeTests.swift
```

[VERIFIED: codebase grep — current project layout and closest analog files; new file/case choices [ASSUMED]]

### Pattern 1: Seven Named Emissions with Field-Local Sanitization

Use the existing eye/nose/mouth shape: one immutable array per public identifier, stable concatenation order, and `sanitizing(_:)` that zeros only a requested field whose own array is empty. [VERIFIED: codebase grep — `EyeWarpProvider.swift`, `NoseWarpProvider.swift`, `MouthWarpProvider.swift`]

```swift
// Source pattern: BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift
struct EyebrowWarpFieldEmissions: Equatable, Sendable {
    let eyebrowYPosition: [WarpControlPoint]
    let eyebrowThickness: [WarpControlPoint]
    let eyebrowLength: [WarpControlPoint]
    let eyebrowSpacing: [WarpControlPoint]
    let eyebrowHeadSpacing: [WarpControlPoint]
    let eyebrowTilt: [WarpControlPoint]
    let eyebrowPeakDefinition: [WarpControlPoint]

    var points: [WarpControlPoint] {
        eyebrowYPosition + eyebrowThickness + eyebrowLength + eyebrowSpacing +
            eyebrowHeadSpacing + eyebrowTilt + eyebrowPeakDefinition
    }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var result = strengths
        if strengths.eyebrowYPosition != 0, eyebrowYPosition.isEmpty {
            result.eyebrowYPosition = 0
        }
        // Repeat independently for all seven names.
        return result
    }
}
```

[VERIFIED: codebase grep — named-emission/sanitization pattern; eyebrow type name [ASSUMED]]

### Pattern 2: Geometry Semantics and Provisional Constants

All helpers must first validate finite strength, support points, derived axes/normals, displacement, radius, and target bounds; final clamping must not convert invalid work into apparently valid output. [VERIFIED: codebase grep — `SECURITY.md`, mouth/face provider validation patterns]

| Field | Eligibility / sources | Required transform | Provisional Phase 50 values |
|---|---|---|---|
| `eyebrowYPosition` | Every point of each independently valid trace | Add signed image-Y displacement to every source; eyebrow-only sources prove no eye alias | cap `0.25`; max displacement `0.025 * face.height`; radius `0.08 * face.width`; falloff `2` [ASSUMED] |
| `eyebrowThickness` | Every valid trace; local tangent from canonical adjacent points; paired samples on both normal sides | Keep the trace centerline fixed; move two strip samples farther from the trace for positive and closer for negative | cap `0.25`; base half-strip `0.012 * face.height`; max change `0.006 * face.height`; radius `0.055 * face.width`; falloff `2` [ASSUMED] |
| `eyebrowLength` | Canonical outer endpoint and immediately preceding point per valid side | Move along the normalized inner-to-outer chord; endpoint weight `1`, neighbor weight `0.5`; never emit inner head | cap `0.25`; max endpoint displacement `0.025 * face.width`; radius `0.07 * face.width`; falloff `2` [ASSUMED] |
| `eyebrowSpacing` | Both distinct valid traces only | Let `pairAxis = normalize(right.center - left.center)`; move left by `-delta * pairAxis` and right by `+delta * pairAxis` for positive, reverse for negative | cap `0.25`; max displacement `0.025 * face.width`; radius `0.08 * face.width`; falloff `2` [ASSUMED] |
| `eyebrowHeadSpacing` | Canonical inner endpoint and immediately following point per valid side | Move along that side's normalized inner-to-outer chord; inner weight `1`, neighbor weight `0.5`; preserve all other points | cap `0.25`; max displacement `0.020 * face.width`; radius `0.06 * face.width`; falloff `2` [ASSUMED] |
| `eyebrowTilt` | Noncentral points of each valid trace with finite chord magnitude above Phase 49 epsilon | Rotate about stored trace center; displacement is naturally endpoint-weighted; derive angle sign from canonical chord X so positive raises both outer tails after mirroring | cap `0.25`; max angle `0.12` radians; radius `0.075 * face.width`; falloff `2` [ASSUMED] |
| `eyebrowPeakDefinition` | Stored unique interior apex plus in-bounds immediate neighbors | Project apex onto endpoint chord, take the unit chord-to-apex direction, and move weights `0.5/1/0.5`; never move endpoints or complete trace | cap `0.25`; max displacement `0.012 * face.height`; radius `0.055 * face.width`; falloff `2` [ASSUMED] |

Positive positional Y should follow the repository's existing signed position convention (`target.y = source.y + displacement`), while tests must lock both signs rather than infer product-language meaning. [VERIFIED: codebase grep — existing `eyeYPosition`, `mouthYPosition`; eyebrow direction convention [ASSUMED]]

### Pattern 3: Resolver Ordering and Freshness

The resolver order should remain: normalize → cap → determine requested work → apply freshness → provider preflight sanitization → shared conflict convergence → final provider emissions → domain/metric/warning accounting. [VERIFIED: codebase grep — `BeautyEffectResolver.swift`, `50-CONTEXT.md`]

- Add all seven fields to `requiresFaceGeometry`, `BeautyEffectiveStrengths`, cap application, requested-work checks, reusable-work checks, zero helpers, exact `0.5` reuse scaling, stale/no-face zeroing, and final eyebrow activity. [VERIFIED: codebase grep — locked resolver/freshness decision; exact reuse scale in current resolver]
- Reused eligible eyebrows should follow the existing non-eye geometry policy: multiply once by `0.5` before provider preflight, then participate once in the shared conflict scale; stale or no-face work becomes zero. [VERIFIED: codebase grep — current non-eye reuse behavior; eyebrow classification under that behavior [ASSUMED]]
- Add `.eyebrows` to `BeautyEffectDomain` rather than reporting eyebrow work as `.eyes` or `.faceShape`; this prevents semantic aliasing and permits independent active/skipped evidence. [ASSUMED]
- If at least one requested eyebrow field has final work, mark `.eyebrows` active and add exactly the final eyebrow point count; if all requested eyebrow work is empty, mark it skipped with a fixed `eyebrow_inputs_missing` warning and `beauty.effects.skippedEyebrowDomains = 1`. Partial per-side or per-field survival stays active and must not disclose which side failed. [VERIFIED: codebase grep — existing face/nose/mouth aggregate domain behavior; eyebrow names/metric [ASSUMED]]
- Include `.eyebrows` in the no-face skipped-domain aggregate without weakening color/filter or independently eligible face/eye/nose/mouth work. [VERIFIED: codebase grep — current `skippedFaceDependentCount`; new domain case [ASSUMED]]

### Pattern 4: Exact 44-Field Monotone Convergence

Extend all conflict views together: the seven scale assignments, the seven absolute-value total entries, the seven nonzero-count entries, preflight sanitization, every retained-baseline pass, final emissions, and unified dispatch. [VERIFIED: codebase grep — `GeometryConflictResolver.swift`, `BeautyEffectResolver.swift`, `CombinedEffectSafetyTests.swift`]

```swift
// Source pattern: BeautyEffectResolver.resolveGeometryConflict
var retainedBaseline = preflightSanitizedStrengths
for _ in 0..<44 {
    let resolution = GeometryConflictResolver().resolve(strengths: retainedBaseline)
    var nextBaseline = faceProvider.fieldEmissions(
        face: faceGeometry, strengths: resolution.strengths
    ).sanitizing(retainedBaseline)
    nextBaseline = chinProvider.fieldEmissions(
        face: faceGeometry, strengths: resolution.strengths
    ).sanitizing(nextBaseline)
    nextBaseline = eyeProvider.fieldEmissions(
        face: faceGeometry, strengths: resolution.strengths
    ).sanitizing(nextBaseline)
    nextBaseline = eyebrowProvider.fieldEmissions(
        face: faceGeometry, strengths: resolution.strengths
    ).sanitizing(nextBaseline)
    nextBaseline = noseProvider.fieldEmissions(
        face: faceGeometry, strengths: resolution.strengths
    ).sanitizing(nextBaseline)
    nextBaseline = mouthProvider.fieldEmissions(
        face: faceGeometry, strengths: resolution.strengths
    ).sanitizing(nextBaseline)
    if nextBaseline == retainedBaseline { return resolution }
    retainedBaseline = nextBaseline
}
return GeometryConflictResolver().resolve(strengths: retainedBaseline)
```

[VERIFIED: codebase grep — current retained-baseline implementation; provider order and 44 bound follow Phase 50 contract]

Critically, providers are evaluated at `resolution.strengths` but sanitize `retainedBaseline`; carrying scaled values into the next baseline would apply the conflict scale repeatedly, while reconstructing from requested values would revive removed fields. [VERIFIED: codebase grep — existing resolver comment and implementation]

With seven provisional `0.25` caps, the exact all-cap ledger is `9 face/chin = 3.35`, `14 eye = 4.10`, `7 eyebrow = 1.75`, `6 nose = 1.80`, and `8 mouth = 2.45`, totaling `13.45`; at threshold `1.0`, the expected shared scale is `1 / 13.45`, weakened count is `44`, and the final geometry total is `1.0`. [VERIFIED: codebase grep — existing 37-field subgroup totals; eyebrow subtotal/cap choice [ASSUMED]]

### Pattern 5: Final Emissions Are the Single Accounting Source

After convergence, compute face, chin, eye, eyebrow, nose, and mouth emissions once from final strengths. Count their arrays individually in the resolver, concatenate the same arrays in the same stable order in `BeautyGeometryEffectPipeline`, and assert the two collections are equal. [VERIFIED: codebase grep — current Phase 48 combined test pattern, `BeautyGeometryEffectPipeline.swift`]

The pipeline guard must include `.eyebrows`, or an eyebrow-only plan will produce no points even when effective strengths and provider emissions are nonzero. [VERIFIED: codebase grep — current guard contains only face/eye/nose/mouth; new case [ASSUMED]]

### Anti-Patterns to Avoid

- **Provider revalidates or reorders raw traces:** consumes the sealed semantic value directly; never sort, close, map, synthesize, or derive a fallback. [VERIFIED: codebase grep — `50-CONTEXT.md`]
- **One invalid side removes both sides:** vertical, thickness, length, head spacing, tilt, and peak must flat-map independently over available traces; only whole spacing is pair-gated. [VERIFIED: codebase grep — locked eligibility decisions]
- **Thickness moves the trace itself:** that aliases position/peak; thickness must operate on paired normal-offset strip samples around an unchanged trace centerline. [VERIFIED: codebase grep — locked semantic distinction; strip construction [ASSUMED]]
- **Length scales the whole brow:** that moves the inner head and aliases spacing/head spacing; restrict sources to the outer endpoint neighborhood. [VERIFIED: codebase grep — GEOM-03]
- **Head spacing translates the complete trace:** that aliases whole spacing; restrict it to the canonical inner neighborhood. [VERIFIED: codebase grep — GEOM-05]
- **Tilt uses one raw image-angle sign for both sides:** horizontal mirroring can invert product direction; derive sign from the canonical chord and test mirrored fixtures. [VERIFIED: codebase grep — Phase 49 orientation/mirror contract; sign rule [ASSUMED]]
- **Peak recomputes a maximum in the provider:** this can choose an ambiguous point; consume only Phase 49's stored unique `apexIndex`. [VERIFIED: codebase grep — `BeautyEyebrowSemanticTrace`, locked decision]
- **Requested strength drives activity before provider sanitization:** provider-empty work would leak into totals, warnings, metrics, and dispatch. [VERIFIED: codebase grep — PIPE-01 and current named-emission pattern]
- **A second scale or eyebrow warp is introduced:** this breaks exact totals and exactly-once dispatch. [VERIFIED: codebase grep — `50-CONTEXT.md`]
- **Raw side/coordinate details enter warnings or metrics:** expose only stable reason codes and aggregate counts. [VERIFIED: codebase grep — `SECURITY.md`, Phase 49 redaction contract]
- **Phase 50 claims image visibility or final naturalness:** decoded ROI evidence and final cap calibration are explicitly deferred. [VERIFIED: codebase grep — `50-CONTEXT.md`, `ROADMAP.md`]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---|---|---|---|
| Brow landmark acquisition | Second Vision request or generated/synthetic brow | Existing `BeautyEyebrowSemanticSupport` from the selected-face request | Provenance, canonicalization, cardinality, topology, and request isolation are already sealed. [VERIFIED: codebase grep — Phase 49 source/verification] |
| Coordinate conversion | Provider-local orientation/mirror mapper | Already mapped image-normalized semantic points | Remapping risks double transformation and inconsistent direction. [VERIFIED: codebase grep — `VisionFaceDetector.swift`, `50-CONTEXT.md`] |
| Field eligibility | Aggregate `hasBrow` boolean | Seven named emission arrays plus `sanitizing(_:)` | Per-side and pair/apex prerequisites differ. [VERIFIED: codebase grep — locked eligibility matrix] |
| Conflict weakening | Per-provider scales or a brow-only budget | Existing `GeometryConflictResolver` and retained-baseline loop | PIPE-02 requires one exact shared scale across all 44 fields. [VERIFIED: codebase grep — PIPE-02] |
| Render delivery | Brow renderer, filter, texture, or extra warp pass | Existing `BeautyGeometryEffectPipeline` | Geometry must dispatch once and remain resource-free. [VERIFIED: codebase grep — phase scope, `ARCHITECTURE.md` A5] |
| Diagnostics | Side-specific coordinate/count payload | Existing fixed warnings and aggregate numeric metrics | Eyebrow support is biometric-adjacent and raw geometry cannot escape. [VERIFIED: codebase grep — `SECURITY.md`] |
| Test image evidence | Phase 50 renderer/gallery expansion | Direct provider, plan, pipeline, and facade assertions | Phase 51 owns decoded 504-output evidence. [VERIFIED: codebase grep — `50-CONTEXT.md`, Phase 51 roadmap] |

**Key insight:** the hard part is maintaining one coherent final field mask across six provider groups; adding vector helpers without extending every resolver/conflict/accounting seam would satisfy isolated provider tests but fail PIPE-01/PIPE-02. [VERIFIED: codebase grep — current 37-field implementation and locked 44-field requirement]

## Common Pitfalls

### Pitfall 1: Partial support is treated as a domain-wide failure
**What goes wrong:** one malformed brow zeros the other side or all seven eyebrow strengths. [VERIFIED: codebase grep — prohibited by `50-CONTEXT.md`]
**How to avoid:** collect left/right traces independently for six per-side fields and pair-gate only `eyebrowSpacing`; sanitize a named strength only when its aggregate named array is empty. [VERIFIED: codebase grep — locked eligibility decisions]
**Warning signs:** left-only fixtures emit zero vertical/thickness/length/head/tilt/peak work, or `.eyes`/other domains become skipped. [VERIFIED: derived directly from acceptance criteria]

### Pitfall 2: Spacing and head spacing share sources
**What goes wrong:** both controls translate complete brows or both move only heads, making them aliases. [VERIFIED: codebase grep — GEOM-04/05 distinction]
**How to avoid:** whole spacing emits every point for two complete traces; head spacing emits only canonical inner neighborhood points per side. [VERIFIED: codebase grep — locked semantics; exact neighborhood [ASSUMED]]
**Warning signs:** identical source sets, identical point counts on a fixed fixture, or pair absence removes head-spacing work. [VERIFIED: derived from required distinction]

### Pitfall 3: Thickness becomes vertical translation
**What goes wrong:** moving trace points in one normal direction shifts the brow instead of changing strip thickness. [VERIFIED: geometry consequence; strip approach [ASSUMED]]
**How to avoid:** emit balanced positive/negative normal-offset samples around an unchanged trace and assert zero mean centerline displacement. [ASSUMED]
**Warning signs:** thickness sources equal vertical-position sources or all target deltas share one sign. [ASSUMED]

### Pitfall 4: Tilt direction flips under mirroring
**What goes wrong:** a constant angle makes the outer tail of one side rise while the other falls, or input mirroring reverses the product sign. [ASSUMED]
**How to avoid:** derive the signed angle from the canonical chord direction and test forward/reversed and mirrored Phase 49 fixtures. [VERIFIED: codebase grep — Phase 49 canonicalization coverage; angle rule [ASSUMED]]
**Warning signs:** positive tilt produces opposite outer-tail Y directions between the two brows after normalization. [ASSUMED]

### Pitfall 5: Apex fallback fabricates peak work
**What goes wrong:** midpoint, max-Y/min-Y, or eye-derived fallback emits peak geometry when `apexIndex` is nil or ambiguous. [VERIFIED: codebase grep — prohibited by GEOM-07 and Phase 49 support contract]
**How to avoid:** require an interior stored apex and a finite nonzero chord-to-apex vector; otherwise return an empty peak array only. [VERIFIED: codebase grep — locked peak eligibility]
**Warning signs:** peak emits on a trace whose semantic `apexIndex` is nil. [VERIFIED: direct acceptance condition]

### Pitfall 6: Conflict values are counted before provider eligibility
**What goes wrong:** absent spacing or peak work changes the shared scale and weakens unrelated domains. [VERIFIED: codebase grep — PIPE-01/02]
**How to avoid:** preflight-sanitize all six provider groups before the first conflict total and repeat the same sanitization order in each convergence pass. [VERIFIED: codebase grep — current resolver pattern]
**Warning signs:** adding an ineligible brow request changes a valid face/nose/mouth effective value, scale, or weakened count. [VERIFIED: direct locked non-interference criterion]

### Pitfall 7: Reuse receives two reductions
**What goes wrong:** eyebrow strength is multiplied by `0.5` both in a freshness helper and again in the provider, then also receives the shared conflict scale. [VERIFIED: codebase grep — prohibited exactly-once freshness decision]
**How to avoid:** apply reuse once in the resolver, keep the provider stateless, and let conflict scaling happen once with the other retained fields. [VERIFIED: codebase grep — current non-eye freshness pattern]
**Warning signs:** an isolated reused brow is `0.25` of fresh rather than `0.5`, before conflict weakening. [VERIFIED: codebase grep — current exact reuse scale]

### Pitfall 8: Geometry point count and dispatch diverge
**What goes wrong:** the resolver counts a provider twice, or the pipeline guard/order omits brow work. [VERIFIED: codebase grep — existing accounting risk and PIPE-02]
**How to avoid:** compare final provider concatenation directly with `BeautyGeometryEffectPipeline.controlPoints` and exact metric count in one 44-field test. [VERIFIED: codebase grep — current Phase 48 combined test pattern]
**Warning signs:** effective strength is nonzero but eyebrow-only facade output reports no geometry points, or metric count differs from dispatch count. [VERIFIED: direct pipeline invariant]

### Pitfall 9: Phase boundaries are overclaimed
**What goes wrong:** compiled vectors are described as visible, natural, final, promoted, or release-ready. [VERIFIED: codebase grep — explicit Phase 50 exclusions]
**How to avoid:** owner documents must say provider/routing/provisional only and preserve Phase 51/52 ownership. [VERIFIED: codebase grep — `AGENTS.md`, `50-CONTEXT.md`]
**Warning signs:** renderer count changes from 59, gallery files appear, caps are called final, or `眉毛` rows become implemented. [VERIFIED: codebase grep — roadmap phase boundaries]

## Code Examples

### Canonical Chord and Pair Axes

```swift
// Source: project-specific recommendation constrained by Phase 49 canonical traces.
func normalized(_ vector: SIMD2<Float>, epsilon: Float = 0.000_001) -> SIMD2<Float>? {
    let length = hypot(vector.x, vector.y)
    guard length.isFinite, length > epsilon else { return nil }
    return vector / length
}

let chordAxis = normalized(trace.outerEndpoint - trace.innerEndpoint)
let pairAxis = normalized(right.center - left.center)
```

[VERIFIED: codebase grep — Phase 49 stores endpoints/centers and uses epsilon `0.000001`; helper shape [ASSUMED]]

### Local Thickness Strip

```swift
// Source: project-specific provisional geometry recommendation.
for index in trace.points.indices {
    let previous = trace.points[max(0, index - 1)]
    let next = trace.points[min(trace.points.count - 1, index + 1)]
    guard let tangent = normalized(next - previous) else { return [] }
    let normal = SIMD2<Float>(-tangent.y, tangent.x)
    let plusSource = trace.points[index] + normal * halfStrip
    let minusSource = trace.points[index] - normal * halfStrip
    let targetOffset = halfStrip + signedThicknessDelta
    // Emit balanced plus/minus targets only after finite/bounds validation.
}
```

[ASSUMED]

### Final Dispatch Agreement

```swift
// Source pattern: CombinedEffectSafetyTests Phase 48 final-provider agreement.
let expectedPoints =
    faceEmissions.points + chinEmissions.points + eyeEmissions.points +
    eyebrowEmissions.points + noseEmissions.points + mouthEmissions.points

XCTAssertEqual(
    BeautyGeometryEffectPipeline.controlPoints(
        for: plan.effectiveStrengths,
        face: face
    ),
    expectedPoints
)
XCTAssertEqual(
    plan.metrics["beauty.effects.geometryPointCount"],
    Double(expectedPoints.count)
)
```

[VERIFIED: codebase grep — current `CombinedEffectSafetyTests.swift` pattern; eyebrow insertion [ASSUMED]]

## State of the Art

| Old Approach | Phase 50 Approach | When Changed | Impact |
|---|---|---|---|
| Seven public eyebrow values intentionally runtime-inert | Seven capped effective strengths with named provider ownership and facade routing | Phase 50 | Replaces the Phase 49 inertness assertion with positive route/zero-neutrality evidence. [VERIFIED: codebase grep — Phase 49 test and Phase 50 goal] |
| No eyebrow provider | One seven-field provider consuming semantic traces only | Phase 50 | Makes source ownership and field-local prerequisites auditable. [VERIFIED: codebase grep — phase goal] |
| 37 geometry fields, total `11.70`, loop bound 37 | 44 geometry fields, provisional total `13.45`, loop bound 44 | Phase 50 | Adds all seven fields exactly once to shared weakening. [VERIFIED: codebase grep — existing exact ledger and Phase 50 count; provisional total [ASSUMED]] |
| Provider order Face/Chin/Eye/Nose/Mouth | Face/Chin/Eye/Eyebrow/Nose/Mouth | Phase 50 | Preserves one dispatch while making eyebrow insertion deterministic. [VERIFIED: codebase grep — current order; new insertion [ASSUMED]] |
| `.faceShape/.eyes/.nose/.mouth` geometry domains | Dedicated `.eyebrows` domain added | Phase 50 | Avoids reporting brow behavior as eye or face behavior. [ASSUMED] |

**Deprecated/outdated:**

- `testBROW02SevenNonzeroEyebrowFieldsRemainRuntimeInert` becomes intentionally outdated and must be replaced by isolated geometry-trigger, zero-neutrality, effective-strength, provider, and route tests. [VERIFIED: codebase grep — `BeautyEffectResolverTests.swift`, Phase 50 goal]
- Phase 49 owner statements saying eyebrow values do not enter providers/resolver/facade must be updated to Phase 50's provisional provider/routing contract without changing output or promotion claims. [VERIFIED: codebase grep — `DESIGN.md`, `ARCHITECTURE.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`]
- Source assertions for `0..<37`, 37 field names, `11.70`, and five-provider concatenation must be evolved together rather than loosened. [VERIFIED: codebase grep — resolver/conflict/combined tests]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|---|---|---|
| A1 | Add public `BeautyEffectDomain.eyebrows` rather than aliasing `.eyes` or `.faceShape`. | Summary / Resolver | This changes a public non-geometry enum surface; omitting it requires a documented alternative for independent active/skipped evidence. |
| A2 | Use provisional cap `0.25` for all seven fields, producing exact eyebrow subtotal `1.75` and combined total `13.45`. | Geometry / Convergence | Different provisional caps change exact capped counts/totals/scales and all combined fixtures. |
| A3 | Use the displacement, angle, radius, strip-width, and falloff constants in the geometry table. | Geometry | Provider vectors remain structurally correct, but Phase 51 visibility or Phase 52 calibration may require replacement. |
| A4 | Positive Y follows the existing image-Y position convention; positive tilt raises both canonical outer tails using chord-derived sign. | Geometry | Product sign expectations could differ; provider/facade tests must lock the chosen contract before output evidence. |
| A5 | Length and head spacing use exactly two endpoint-neighborhood samples with weights `1` and `0.5`; peak uses apex-neighbor weights `0.5/1/0.5`. | Geometry | Different cardinality rules change exact source sets and point-count metrics. |
| A6 | Reused eyebrow geometry follows the existing non-eye exact `0.5` scale rather than the eye-domain skip policy. | Freshness | If eyebrows should skip on reuse, degradation and combined metrics change; Phase 50 context says reuse follows the established freshness scale but does not name the domain policy. |
| A7 | A new Phase 50 boundary checker should be created rather than modifying the historical Phase 49 no-activation checker. | Validation / Security | Without a phase-local checker, scope/privacy gates rely on dispersed shell scans; modifying Phase 49 would corrupt historical evidence. |

## Open Questions (RESOLVED)

1. **RESOLVED — active/skipped planning exposes a dedicated `.eyebrows` domain.**
   - What we know: `BeautyEffectDomain` currently has separate public cases for face, eyes, nose, and mouth; Phase 50 forbids eyebrow aliasing and requires resolver/facade routing. [VERIFIED: codebase grep — `BeautyEffectDomain.swift`, `50-CONTEXT.md`]
   - Resolution basis: CONTEXT.md leaves the non-geometry public enum case to planning discretion while forbidding semantic aliasing and raw-geometry exposure. [VERIFIED: codebase grep — `50-CONTEXT.md`]
   - Adopted choice: add `.eyebrows`; it exposes only an aggregate domain label, not raw geometry, and is the cleanest independent evidence. Plans 50-03, 50-05, and 50-06 implement and verify this choice. [ASSUMED]

2. **RESOLVED — reused eligible eyebrow support scales exactly once by resolver-owned `0.5`; it does not skip.**
   - What we know: current eye geometry skips reused support, while face/nose/mouth use exact `0.5`; Phase 50 says reused eligible geometry follows the established freshness scale exactly once. [VERIFIED: codebase grep — `BeautyEffectResolver.swift`, `50-CONTEXT.md`]
   - Resolution basis: the locked text requires reused eligible geometry to follow the established freshness scale exactly once; eyebrow provider ownership makes the non-eye resolver policy the consistent fit. [VERIFIED: codebase grep — `50-CONTEXT.md`, `BeautyEffectResolver.swift`]
   - Adopted choice: apply the exact non-eye `0.5` scale once in `BeautyEffectResolver` before shared conflict scaling because the text says “scale” and requires eligible reused geometry; `EyebrowWarpProvider` remains stateless and must not apply reuse scaling. Plans 50-03, 50-05, and 50-06 implement and verify this ownership. [ASSUMED]

Both choices are resolved planning inputs for Phase 50 and are recorded in the plan set and corresponding owner-document updates. [ASSUMED]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|---|---|---|---|---|
| Swift | Package implementation/tests | ✓ | 6.3.3 | — [VERIFIED: environment probe] |
| SwiftPM | Focused/full build and test | ✓ | Bundled with Swift 6.3.3 | — [VERIFIED: environment probe] |
| Xcode | Apple frameworks/toolchain host | ✓ | 26.6 (17F113) | SwiftPM-only validation for this phase [VERIFIED: environment probe, scope] |
| Python | Phase checker and fixture preflight | ✓ | 3.9.6 | Direct `rg`/Git scans if the new checker is not created [VERIFIED: environment probe] |
| Git | Scope and diff hygiene | ✓ | 2.50.1 | — [VERIFIED: environment probe] |
| Authorized `e1.png` fixture | Full SwiftPM preflight | ✓ | 929,129 bytes | — [VERIFIED: fixture preflight on 2026-07-24] |

**Missing dependencies with no fallback:** None. [VERIFIED: environment probes]

**Missing dependencies with fallback:** None. [VERIFIED: environment probes]

The current focused resolver baseline passes 23/23 under `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyEffectResolverTests`; its Phase 49 eyebrow inertness test is expected to turn red when Phase 50 activation begins and must be replaced deliberately. [VERIFIED: command run on 2026-07-24, source test name]

## Validation Architecture

### Test Framework

| Property | Value |
|---|---|
| Framework | XCTest from installed Swift 6.3.3 toolchain [VERIFIED: environment/source] |
| Config file | `BeautySDK/Package.swift` [VERIFIED: codebase grep] |
| Quick provider command | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests` [ASSUMED: new test owner] |
| Quick resolver command | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyEffectResolverTests` [VERIFIED: current test target] |
| Full suite command | `swift test --package-path BeautySDK --disable-sandbox --jobs 1` [VERIFIED: current SwiftPM workflow] |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|---|---|---|---|---|
| GEOM-01 | Both signs translate only brow trace points per valid side; eye/other providers remain byte-equal | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests` | ❌ Wave 0 |
| GEOM-02 | Both signs expand/compress balanced normal strip samples with finite local bounds and no resource/color path | unit | same provider command | ❌ Wave 0 |
| GEOM-03 | Both signs affect only outer endpoint neighborhood and preserve inner head/whole-brow scale | unit | same provider command | ❌ Wave 0 |
| GEOM-04 | Pair-only spacing translates both complete traces symmetrically; single-side input is empty | unit | same provider command | ❌ Wave 0 |
| GEOM-05 | Inner-head spacing survives one valid side, touches only inner neighborhood, and differs from whole spacing | unit | same provider command | ❌ Wave 0 |
| GEOM-06 | Per-side nondegenerate-chord rotation has opposite signed direction and survives mirrored canonical fixtures | unit | same provider command | ❌ Wave 0 |
| GEOM-07 | Positive-only peak uses stored unique apex neighborhood; nil/endpoint/degenerate apex is empty | unit | same provider command | ❌ Wave 0 |
| PIPE-01 | Seven caps/effective values, geometry trigger, field-local sanitization, eyebrow domain, redacted warnings/metrics | integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyEffectResolverTests` | ✅ extend |
| PIPE-01 | Missing left/right/both, pair-only failure, apex-only failure, provider-empty, safe siblings | integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.MissingLandmarkDegradationTests` | ✅ extend |
| PIPE-02 | Exact 44 names/subtotals/total/scale/count/signs across conflict resolver | unit | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.GeometryConflictResolverTests` | ✅ extend |
| PIPE-02 | One `0..<44` retained loop, no re-entry/double scale, final provider mask and exact dispatch/metric agreement | integration/static | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.CombinedEffectSafetyTests` | ✅ extend |
| PIPE-01/02 | Eyebrow-only and 44-field final strengths enter unified provider order exactly once | integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyGeometryEffectPipelineTests` | ✅ extend |
| PIPE-01 | Seven isolated public requests invoke detection once, emit aggregate geometry evidence, preserve extent, and stay redacted | facade integration | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | ✅ extend |
| All | No dependency/model/resource/Demo/renderer/gallery/network/persistence/public-geometry drift | static + adversarial | `python3 .planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py` | ❌ Wave 0 [ASSUMED] |

### Required Fixture Matrix

| Fixture | Purpose | Minimum assertions |
|---|---|---|
| Asymmetric valid two-side semantic support | Distinguish all seven providers | Exact named sources, target directions, finite/unit bounds, local radii/falloff, non-alias arrays [VERIFIED: requirements] |
| Left-only and right-only | Per-side survival | Six per-side-capable fields emit surviving-side work; spacing empty; unrelated domains unchanged [VERIFIED: locked eligibility] |
| Both valid, one apex nil | Peak-local failure | Peak emits only eligible side; other six fields retain correct prerequisites [VERIFIED: locked eligibility] |
| Both valid, pair invalid/distinctness failure | Pair-local failure | Spacing zero only; per-side fields survive [VERIFIED: locked eligibility] |
| Degenerate provider chord/target after semantic construction | Provider-empty defense | Dependent field zero before conflict/activity/count; valid sibling remains [VERIFIED: PIPE-01] |
| Fresh / reused / stale / no-face representative set | Freshness routing | Fresh full, reused exact recommended `0.5`, stale/no-face zero, color/filter and eligible unrelated geometry continue [VERIFIED: locked freshness/non-interference; reuse policy [ASSUMED]] |
| Exact all-provider geometry | PIPE-02 ledger | 44 unique names, subgroup totals, `13.45`, `1/13.45`, 44 weakened, final total 1, all emissions nonempty, metric=dispatch count [VERIFIED: exact count requirement; total [ASSUMED]] |
| Deterministic facade raw support | Public routing | One detector call, usable summary, geometry required, positive aggregate point count, extent unchanged, no raw payload [VERIFIED: existing facade pattern] |
| Missing/malformed facade brow support | Safe public degradation | Eyebrow field removed locally, safe sibling still active, aggregate-only result [VERIFIED: PIPE-01] |

### Sampling Rate

- **Per provider task commit:** run the new eyebrow provider suite. [ASSUMED]
- **Per resolver/conflict task commit:** run resolver, conflict, and combined safety suites. [VERIFIED: existing test ownership]
- **Per integration task commit:** run degradation, pipeline, facade, and phase checker suites. [VERIFIED: phase evidence requirements]
- **Per wave merge:** `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests`. [VERIFIED: package test target]
- **Phase gate:** fixture preflight, all focused suites, the phase checker in self-test/live modes, full SwiftPM, `git diff --check`, tracked generated-artifact scan, and scoped owner-document review. [VERIFIED: Phase 49/46 established workflow and Phase 50 guardrails]

### Wave 0 Gaps

- [ ] `BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift` — add asymmetric two-side, one-side, nil-apex, degenerate-chord, mirrored-direction, field-isolation, nearest-neighbor distinction, and immutable sibling-provider fixtures. [VERIFIED: file absent; requirements]
- [ ] Extend `BeautyEngineTestingSupport.swift` with valid raw left/right eyebrow traces and representative missing/malformed support fixtures; `.usableFace` currently carries observed face support but no eyebrow support. [VERIFIED: codebase grep]
- [ ] Replace `testBROW02SevenNonzeroEyebrowFieldsRemainRuntimeInert` with explicit-zero neutrality and Phase 50 positive routing/cap/provider evidence. [VERIFIED: codebase grep]
- [ ] Extend exact key-path/name tables from 37 to 44 fields in conflict/combined tests and add final eyebrow emissions to the provider/dispatch equality fixture. [VERIFIED: codebase grep]
- [ ] Add `check_eyebrow_geometry_boundaries.py` with adversarial self-tests and live classified checks; keep the Phase 49 historical checker unchanged. [ASSUMED]
- [ ] Preserve and run the existing readable/non-empty `e1.png` preflight before the full suite. [VERIFIED: Phase 49 validation contract and current preflight]

No test framework, target, package, resource, model, or fixture image installation is required. [VERIFIED: codebase grep — `BeautySDK/Package.swift`, current fixture preflight]

## Security Domain

ASVS L1 enforcement is active, and Phase 50 converts untrusted biometric-adjacent semantic support into render work; finite validation, fail-closed local eligibility, bounded computation, redaction, and dependency/scope controls therefore belong in implementation verification. [VERIFIED: codebase grep — `.planning/config.json`, `SECURITY.md`]

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---|---|---|
| V2 Authentication | no | No account or authentication surface exists in Phase 50. [VERIFIED: codebase grep — phase scope] |
| V3 Session Management | no | Request-scoped geometry is not a user session and must not persist. [VERIFIED: codebase grep — Phase 49 contract] |
| V4 Access Control | no | No entitlement, VIP, payment, or privileged path is added. [VERIFIED: codebase grep — phase scope] |
| V5 Validation, Sanitization and Encoding | yes | Phase 49 support validation plus provider finite/bounds/chord/apex checks and field-local empty-output sanitization. [VERIFIED: codebase grep — `SECURITY.md`, `50-CONTEXT.md`] |
| V6 Stored Cryptography | no | No storage, key, signature, or cryptographic operation is introduced. [VERIFIED: codebase grep — phase scope] |
| V7 Error Handling and Logging | yes | Fixed reason codes and aggregate numeric metrics only; no side-specific geometry, endpoints, centers, axes, normals, apex indices, or displacements. [VERIFIED: codebase grep — `SECURITY.md`] |
| V10 Malicious Code | boundary check | No dependency, model, resource pack, generated executable, or network path may enter. [VERIFIED: codebase grep — phase guardrails] |
| V12 Files and Resources | limited | Existing fixture input may be read by tests; no output/gallery image may be added or tracked. [VERIFIED: codebase grep — phase guardrails] |
| V13 API and Web Service | limited to SDK API | Public scalars normalize before detection/provider work; no raw support/control point/result surface or network API is permitted. [VERIFIED: codebase grep — public model and security boundary] |

### Known Threat Patterns for Swift Geometry Pipeline

| Pattern | STRIDE | Standard Mitigation |
|---|---|---|
| Eye/synthetic support spoofed as eyebrow provenance | Spoofing | Consume only `FaceGeometry.observedEyebrowSupport`; no legacy fallback. [VERIFIED: codebase grep — Phase 49/50 contract] |
| Malformed/degenerate support creates NaN, huge displacement, or clamped fake validity | Tampering / DoS | Validate every derived scalar/vector and in-bounds target before constructing points; return field-empty on failure. [VERIFIED: codebase grep — `SECURITY.md`; exact helper policy [ASSUMED]] |
| Pair-only requirement bypassed with duplicate/single side | Spoofing / Tampering | Require `pairedEligible`, two distinct side identities, and a finite nonzero pair axis. [VERIFIED: codebase grep — `BeautyEyebrowSemanticSupport`, locked spacing eligibility] |
| Removed field re-enters or is scaled repeatedly | Tampering / Integrity | Retained-baseline monotone loop bounded at 44; sanitize baseline from emissions evaluated at scaled strengths. [VERIFIED: codebase grep — PIPE-02/current resolver pattern] |
| Raw geometry leaks through warning/metric/reflection/facade | Information Disclosure | Preserve aggregate-only carriers and fixed diagnostics; scan public/SPI, Codable, persistence, logs, and result text. [VERIFIED: codebase grep — `SECURITY.md`, Phase 49 checker] |
| Excessive provider work | DoS | Retain Phase 49 max 16 points per side; O(n) local helpers; loop at most 44 removals. [VERIFIED: codebase grep — support ceiling and PIPE-02] |
| Unauthorized package/resource/network/Demo/output expansion | Supply Chain / Information Disclosure | Fail-closed phase checker plus manifest/import/tracked-artifact scans. [VERIFIED: codebase grep — phase guardrails; checker recommendation [ASSUMED]] |

## Recommended Planning Sequence

1. **Wave 0 — failing fixtures and boundary gates:** create provider fixtures/tests, extend facade testing support, replace the inertness test, add 44-field key-path tables, and create the Phase 50 fail-closed checker. [VERIFIED: validation gaps; checker choice [ASSUMED]]
2. **Provider wave — seven independent semantics:** add `EyebrowWarpFieldEmissions`/`EyebrowWarpProvider`, provisional caps, finite local helpers, and exact source/direction/non-alias tests while proving all existing provider arrays unchanged. [VERIFIED: phase requirements; constants [ASSUMED]]
3. **Resolver/convergence wave — one final mask:** add effective strengths/domain/routing/freshness, preflight/final sanitization, all seven conflict entries, exact `0..<44` convergence, and exact 44-field total/count/scale evidence. [VERIFIED: PIPE-01/02; domain/reuse/caps [ASSUMED]]
4. **Integration wave — unified dispatch and facade:** insert the provider exactly once between eye and nose, add partial/malformed/provider-empty degradation, and prove seven isolated public requests with redacted aggregate evidence. [VERIFIED: phase goal; provider order [ASSUMED]]
5. **Contract/security closeout:** run focused/full SwiftPM and fail-closed scope/privacy gates, then synchronize `DESIGN.md`, `ARCHITECTURE.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and `PLANS.md` with provisional provider/routing claims only. [VERIFIED: codebase grep — `AGENTS.md`, Phase 50 scope]

## Sources

### Primary (HIGH confidence)

- `.planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/50-CONTEXT.md` — locked semantics, eligibility, resolver/convergence, evidence, privacy, and scope. [VERIFIED: codebase grep]
- `.planning/REQUIREMENTS.md` and `.planning/ROADMAP.md` — GEOM-01..07, PIPE-01..02, exact 44-field goal, and Phase 51/52 boundaries. [VERIFIED: codebase grep]
- `.planning/phases/49-public-contract-and-observed-eyebrow-support/49-VERIFICATION.md`, `49-VALIDATION.md`, and summaries — predecessor support, privacy, fixture, and test evidence. [VERIFIED: codebase grep]
- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` and `Planning/BeautyFaceGeometryAdapter.swift` — semantic trace/support fields and eligibility boundaries. [VERIFIED: codebase grep]
- `BeautySDK/Sources/BeautyEffects/Warp/{Eye,Nose,Mouth}WarpProvider.swift` — named emissions, provider result, local validation, and sanitization patterns. [VERIFIED: codebase grep]
- `BeautySDK/Sources/BeautyEffects/Planning/{BeautyEffectDomain,BeautyEffectPlan,BeautySafetyCaps,BeautyEffectResolver}.swift` — current runtime ledger, caps, freshness, domain, routing, and convergence. [VERIFIED: codebase grep]
- `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` and `Render/BeautyGeometryEffectPipeline.swift` — current exact 37-field shared scale and unified dispatch. [VERIFIED: codebase grep]
- Current provider/resolver/conflict/combined/degradation/pipeline/facade XCTest sources and `BeautyEngineTestingSupport.swift` — concrete fixture/assertion patterns and Wave 0 gaps. [VERIFIED: codebase grep]
- `AGENTS.md`, `PLANS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md` — repository and owner constraints. [VERIFIED: codebase grep]

### Secondary (MEDIUM confidence)

- `.planning/milestones/v1.11-phases/42-independent-eye-geometry-and-pipeline-integration/42-RESEARCH.md` — closest analogous multi-field provider phase, checked against current source before reuse. [VERIFIED: codebase grep]
- `.planning/milestones/v1.12-phases/46-independent-contour-and-chin-geometry/46-RESEARCH.md` and `46-PATTERNS.md` — closest analogous named-emission/convergence/facade phase, checked against current source. [VERIFIED: codebase grep]

### Tertiary (LOW confidence)

- None. All unsourced geometry constants and policy interpretations are explicitly tagged `[ASSUMED]` and listed in the Assumptions Log. [VERIFIED: document audit]

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH — package manifest and installed toolchain were directly inspected. [VERIFIED: environment/source]
- Architecture: HIGH — every current support/provider/resolver/conflict/pipeline/facade seam was inspected. [VERIFIED: codebase grep]
- Geometry semantics: HIGH for required ownership, prerequisites, locality, and distinction; MEDIUM for provisional formulas/constants. [VERIFIED: codebase grep — context/requirements; constants [ASSUMED]]
- Validation architecture: HIGH — current test owners and analogous Phase 42/46/48 exact-ledger tests were inspected; only the new provider/checker files are prospective. [VERIFIED: codebase grep]
- Security: HIGH — active ASVS L1 config and Phase 49 privacy boundary were inspected. [VERIFIED: codebase grep]

**Research date:** 2026-07-24
**Valid until:** 2026-08-23 for repository seams; provisional geometry constants are valid only until Phase 51/52 evidence.
