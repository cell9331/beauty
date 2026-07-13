# Architecture Research

**Domain:** Existing-parameter iOS beauty SDK mouth slice (`mouthSize`, `mouthWidth`, `smile`, `lipColor`)
**Researched:** 2026-07-13
**Confidence:** HIGH

## Architectural Recommendation

Extend the shipped v1.5-v1.7 public-facade evidence path; do not introduce a new target, public model, render pass, or Demo dependency. Mouth shaping already has an internal provider and is already routed through the unified geometry pipeline. `lipColor` already has a separate color-domain implementation. The milestone should therefore add evidence at the public facade, close mouth-specific resolver/degradation gaps, and promote only the three geometry rows that the existing parameters actually prove.

```text
Committed portrait / negative fixtures
                    │
                    ▼
 BeautyExampleRenderer (imports BeautySDK only)
                    │ BeautyParameters snapshot
                    ▼
 BeautyEngine.processResult(image:metadata:parameters:)
                    │ package-only selected observation
                    ▼
 BeautyEffectResolver ───────────────┐
        │                             │
        │ `.mouth`                    │ `.lipColor`
        ▼                             ▼
 MouthWarpProvider             BeautyColorEffectPipeline
        │ control points              │ mouth-region tint/mask
        ▼                             │
 BeautyGeometryEffectPipeline        │
        │ local CIImage warp          │
        └──────────────┬──────────────┘
                       ▼
 same-dimension public-facade output + redacted summary/warnings/metrics
                       │
             ignored output/gallery evidence
```

This preserves the root invariants: Detection supplies internal image-normalized geometry, Effects owns planning and providers, Render performs the unified warp/color work, the public facade hides landmarks, and the Demo remains facade-only and unchanged.

## Component Impact

### Modified components

| Component | Change | Architectural boundary |
| --- | --- | --- |
| `BeautyExampleRenderer` | Add locked single-parameter cases for positive/negative `mouthSize`, positive/negative `mouthWidth`, `smile`, and `lipColor`. | Continues to import only `BeautySDK`; no internal provider access. |
| Phase-owned output helper | Validate expected flat PNG inventory, decode/non-empty/same-dimension invariants, mouth-region comparisons above the watermark, signed-direction separation, representative no-face preservation, and lip-color evidence. | Generated output and gallery remain ignored and untracked. Historical Phase 29/31 helpers and counts remain immutable. |
| Gallery routing | Add an ignored mouth/lip review group using deterministic filenames. | Convenience evidence only; not a committed baseline or commercial visual approval. |
| `BeautyEffectResolver` | Make missing/no-face/stale mouth geometry fail closed by zeroing all three mouth geometry strengths; retain reused geometry at the established non-eye `0.5` scale; define lip-color stale/reuse behavior explicitly and keep safe domains active. | Changes internal effective strengths only; public normalized ranges and 31-field inventory stay stable. |
| Mouth/facade/safety tests | Lock exact caps, signed preservation, provider direction, combined weakening, redaction, missing/reused/stale behavior, and safe-domain continuation. | Tests observable plans/results without exposing raw geometry publicly. |
| Blueprint/root contracts | Promote exactly `大小`, `宽度`, `微笑` after all gates pass; record `lipColor` as color evidence while leaving `丰唇` partial. | Branch-level `嘴唇` remains `partial`; no alias-based promotion. |

### Existing components reused unchanged unless evidence finds a defect

| Component | Existing responsibility |
| --- | --- |
| `BeautyParameters` | Already declares signed `mouthSize`/`mouthWidth` and unit `smile`/`lipColor`, including finite/non-finite normalization. |
| `BeautySafetyCaps` | Already declares exact internal caps: mouth size `0.35`, width `0.35`, smile `0.50`, lip color `0.50`. |
| `BeautyEngineGeometryDetection` | Already triggers selected-face detection for all four mouth/lip fields and keeps raw observations package-internal. |
| `BeautyFaceGeometryAdapter` | Already maps selected detection output to internal `FaceGeometry.outerLips`. |
| `MouthWarpProvider` | Already preserves both signs for size/width and creates smile corner control points. |
| `GeometryConflictResolver` | Already weakens all three mouth geometry strengths during combined geometry while using absolute magnitude for conflict load. |
| `BeautyGeometryEffectPipeline` | Already accepts `.mouth` and applies unified local control-point warps. |
| `BeautyColorEffectPipeline` | Already applies `lipColor` only in a bounded mouth region and keeps it out of `.mouth` geometry/control points. |

No new component is required. A phase-specific checker/evidence document is new, but it is verification infrastructure rather than production architecture.

## Key Data Flows

### Public-facade mouth geometry

1. A renderer case creates a `BeautyParameters` value with exactly one mouth geometry field nonzero.
2. `BeautyEngine` detects/selects one usable face because the resolver reports that geometry is required.
3. The package-only observation is adapted to internal image-normalized `FaceGeometry`; no landmarks enter the public result.
4. The resolver normalizes and caps the requested field, applies freshness policy and combined weakening, then activates `.mouth` only if usable outer-lip geometry produces control points.
5. `MouthWarpProvider` emits signed-safe local control points: positive/negative size expand/contract about the lip center, positive/negative width move corners outward/inward, and smile lifts both corners.
6. The unified geometry pipeline applies the local warp and the facade returns an extent-preserving image plus geometry-free diagnostics.

### Lip-color evidence

1. A renderer case sets only `lipColor`; the resolver activates `.lipColor`, not `.mouth`.
2. `BeautyColorEffectPipeline` derives a bounded mouth mask from internal lip geometry and blends color only in that region.
3. Evidence must show visible, same-dimension facade output and containment outside the expected mouth area.
4. This evidence proves a color-domain capability only. It must not be cited as control-point output, volume/plumping, or implementation of `丰唇`.

### Conservative degradation

| Geometry state | Mouth geometry | Lip color | Other safe domains |
| --- | --- | --- | --- |
| Usable/fresh | Apply capped/signed provider output. | Apply bounded mouth tint. | Continue. |
| Reused | Apply established non-eye `0.5` geometry scale, preserving sign. | Must be explicitly tested and documented; do not silently inherit a geometry claim. | Continue. |
| Missing outer lips / no face | Skip and zero all three effective mouth geometry strengths. | Skip and zero effective lip color if inputs are unusable. | Color/filter and other independent domains continue. |
| Stale | Skip and zero mouth geometry strengths. | Fail closed unless a separately documented safe stale-color contract is proven. | Independent domains continue. |

The returned warnings and metrics may expose reason codes, domain counts, aggregate point counts, caps, and timing, but never landmarks, bounding boxes, fixture paths, raw Vision errors, or biometric coordinates.

## Evidence Architecture

The current matrix is 28 cases across seven fixtures. Six locked mouth/lip cases would make 34 cases and 238 expected ignored outputs if the fixture inventory remains seven: two size directions, two width directions, smile, and lip color. Treat those counts as a derived inventory guard, recalculated from the actual case/fixture lists rather than scattered constants.

Geometry comparisons should exclude the watermark band and use a mouth-centered region rather than the broader central-face box used for nose. For each usable portrait, compare every geometry case with `geometryBaseline_noop`; additionally compare positive and negative size outputs directly and positive and negative width outputs directly. The lip-color case should use a color-sensitive comparison plus spatial containment, not the geometry displacement criterion. A representative no-face fixture must retain original dimensions and degrade without fatal failure.

The renderer/output helper remains black-box evidence. Provider/resolver unit tests supply semantic direction, exact-cap, and degradation proof; saved outputs prove those semantics survive the public facade. Neither evidence class substitutes for the other.

## Recommended Build Order

1. **Freeze evidence contracts.** Inventory the current 28 renderer cases, seven fixtures, ignore rules, public imports, and mouth/lip parameter fields. Add tests for the six locked case IDs and single-parameter isolation.
2. **Add black-box renderer/helper evidence.** Extend the renderer and a new Phase-owned checker/gallery route. Prove size/width signed separation, smile visibility, lip-color containment, dimensions, no-face output, and artifact ignore behavior.
3. **Lock normalization and provider semantics.** Add exact-cap and abnormal-input tests for all four fields, signed direction tests for size/width, and confirm lip color never emits geometry control points.
4. **Close resolver degradation gaps.** Add a mouth-strength zeroing helper analogous to nose; cover missing/no-face/stale fail-closed behavior, reused `0.5` geometry scaling, lip-color input/freshness policy, redacted warnings/metrics, and independent-domain continuation.
5. **Lock combined behavior and facade privacy.** Exercise positive and negative mouth fields with face/eye/nose geometry, verify weakening preserves signs, and scan for raw geometry/public API/import/network/commercial drift.
6. **Promote documentation atomically.** Only after runtime and boundary gates pass, promote `大小`, `宽度`, and `微笑`; preserve `上下`, `倾斜`, `左右`, `M唇`, `丰唇`, `白牙`, and branch-level `嘴唇` as partial/future. Synchronize all current owners in the same closeout phase.

This order separates visible facade evidence from safety closeout, matching v1.6/v1.7's two-phase architecture and preventing documentation promotion before both evidence classes pass.

## Architectural Risks and Mitigations

| Risk | Consequence | Mitigation |
| --- | --- | --- |
| Watermark-only or global-color differences mistaken for geometry | False facade evidence | Exclude watermark; compare a mouth ROI; require provider direction tests and signed pairwise output differences. |
| `lipColor` mislabeled as `丰唇` | False product/ledger claim | Keep `.lipColor` separate from `.mouth`; assert zero geometry points; promote no plump-lip row. |
| Skipped mouth domains retain nonzero effective strengths | Diagnostics/plan contradict rendered output | Zero geometry strengths on missing/no-face/stale paths, as Phase 32 does for nose. |
| Reused/stale policy conflates geometry and color | Unsafe or ambiguous degradation | Specify and test each domain independently; freshness is not inferred from branch naming. |
| Combined resolver runs more than once and over-weakens fields | Unexpected output | Add combined tests that lock one weakening result and preserved sign; avoid adding a mouth-specific second conflict layer. |
| Historical evidence counts drift | v1.6/v1.7 audit regression | Create a new milestone-owned helper; do not edit archived helpers or evidence. |
| Broad branch promotion from four public fields | Scope inflation | Ledger guards assert exactly three geometry rows promoted and branch remains partial. |

## Anti-Patterns

- **Adding a `丰唇` alias to `lipColor`:** color tint has no geometric volume semantics. Design a future neutral geometry parameter instead.
- **Calling providers from the example renderer:** this bypasses the public facade and invalidates SDK integration evidence.
- **Introducing a mouth-specific render pass:** the existing unified warp and color pipelines already own the required behavior; a new pass would duplicate scheduling and degradation logic.
- **Committing generated PNG baselines:** keep fixtures committed but outputs/gallery ignored; evidence is command-backed and reproducible.
- **Changing public ranges to match safety caps:** caps are internal effective limits; the public normalized contract remains signed `[-1,1]` or unit `[0,1]`.
- **Treating a skipped domain with nonzero strengths as harmless:** plans, warnings, and tests must agree with actual execution.

## Integration Boundaries

| Boundary | Communication | Constraint |
| --- | --- | --- |
| `BeautyExampleRenderer` → `BeautySDK` | Public `BeautyEngine` and `BeautyParameters` | No internal target imports. |
| `BeautySDK` → Detection/Effects | Package-only selected observation route | No raw geometry in public result. |
| Detection → Effects | Internal normalized `FaceGeometry` adapter | Mouth evidence depends on `outerLips`; Vision types remain internal. |
| Resolver → Geometry pipeline | `BeautyEffectPlan` / effective strengths | `.mouth` only; signed semantics preserved. |
| Resolver → Color pipeline | `.lipColor` active domain / strength | Never implies geometry/plumping. |
| SDK outputs → checker/gallery | PNG files and public diagnostics | Ignored artifacts, deterministic names, no local paths in diagnostics. |

## Sources

- `ARCHITECTURE.md`, `DESIGN.md`, `PRODUCT_SENSE.md`, `RELIABILITY.md`, `SECURITY.md`
- `.planning/PROJECT.md`
- `.planning/milestones/v1.6-ROADMAP.md` and archived Phase 29/30 evidence
- `.planning/milestones/v1.7-ROADMAP.md` and archived Phase 31/32 evidence
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`
- `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift`
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- Mouth, lip-color, degradation, combined-safety, and facade tests under `BeautySDK/Tests/`
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, and beauty-shaping README

---
*Architecture research for: v1.8 Broader 美型 / 五官 SDK Slice - Mouth*
*Researched: 2026-07-13*
