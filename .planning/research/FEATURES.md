# Feature Research

**Domain:** Existing-parameter mouth/lip slice for a local-first iOS beauty SDK.
**Researched:** 2026-07-13
**Confidence:** HIGH for repository-local scope, boundaries, and predecessor patterns; MEDIUM for final fixture-level visual strength until the output matrix is run.

## Feature Landscape

### Table Stakes (Milestone Completion Requires These)

| Feature | Why Expected | Complexity | Notes |
| --- | --- | --- | --- |
| Public-facade mouth renderer cases | Existing public controls are not complete at the ledger level until visible output is exercised through `BeautySDK`, not only providers or Demo mappings. | MEDIUM | Add isolated cases for signed `mouthSize`, signed `mouthWidth`, and positive `smile`; include both directions for each signed field. |
| Lip-color public-facade evidence | `lipColor` is an existing public capability and must remain visibly verifiable while mouth geometry is expanded. | MEDIUM | Treat it as a color-domain case with mouth-region containment, not as geometry evidence. |
| Deterministic ignored output/gallery verification | v1.6/v1.7 established non-empty, decodable, same-dimension, baseline-difference, gallery-routing, and no-tracked-PNG gates. | MEDIUM | Extend the established fixture matrix and helper rather than introducing a second evidence system. Signed outputs should differ from baseline and from each other on usable portraits. |
| Exact normalization and caps | Host apps require predictable conservative strengths and preserved signed direction. | MEDIUM | Lock effective caps for all four existing fields in focused tests; do not infer values from display labels or renderer case names alone. |
| Conservative mouth-geometry degradation | Face-dependent warps must fail safely when mouth geometry is missing or stale and weaken when geometry is reused. | HIGH | Cover no face, missing mouth landmarks, stale geometry, reused geometry at the established reduced scale, preserved dimensions, and safe-domain continuation. |
| Combined-geometry weakening | Mouth effects must remain conservative when face, eye, or nose geometry is also active. | HIGH | Cover both directions of `mouthSize` and `mouthWidth`, plus `smile`, without sign reversal. Keep `lipColor` outside geometry-strength weakening unless its own color policy requires reduction. |
| Redacted diagnostics and containment | SDK diagnostics must prove what degraded without exposing raw landmarks, coordinates, pixels, paths, or identifiers. | MEDIUM | Lock warning/metric summaries and ensure mouth-only failures do not suppress safe independent domains. |
| Exact scoped ledger promotion | Completion must reflect evidence, not taxonomy similarity. | LOW | Promote only `大小`, `宽度`, and `微笑`; keep branch-level `嘴唇` partial and all unmapped rows future/partial. |

### Differentiators (Aligned With Core Value)

| Feature | Value Proposition | Complexity | Notes |
| --- | --- | --- | --- |
| Signed-safe mouth shaping | Gives host apps bidirectional, controllable mouth resizing and width adjustment rather than a one-way cosmetic toggle. | HIGH | Preserve positive/negative direction through normalization, degradation, combination, rendering, and output comparison. |
| Domain-separated lip color | Prevents a common SDK integration error: treating tint as structural plumping. | MEDIUM | `lipColor` should have color containment and visible-output evidence but must never promote or substantiate `丰唇`. |
| Failure isolation | A missing mouth region can disable mouth geometry while safe color/skin/filter domains continue. | HIGH | This supports robust realtime and still-image processing instead of all-or-nothing failure. |
| Evidence-backed taxonomy honesty | Users and integrators can distinguish shipped SDK behavior from reference-app labels and future ambitions. | LOW | Exact row promotion and explicit non-claims are part of the product quality, not documentation polish. |

### Anti-Features (Explicitly Excluded)

| Feature | Why Requested | Why Problematic | Alternative |
| --- | --- | --- | --- |
| Claim `lipColor` as true `丰唇` | The current Demo/reference mapping makes the label look superficially covered. | Tint changes perceived fullness but does not deform upper/lower lip geometry; using it as proof would corrupt the feature ledger. | Keep `丰唇` partial and either define a distinct geometry parameter later or relabel the Demo mapping. |
| Promote all mouth rows together | A branch-level completion claim is simpler to communicate. | `上下`, `倾斜`, `左右`, `M唇`, `丰唇`, and `白牙` lack independent public parameter/algorithm evidence. | Promote exactly `大小`, `宽度`, and `微笑`; retain branch status `partial`. |
| Add new public mouth parameters now | It could fill the visible taxonomy faster. | Expands the stable 31-field API, compatibility surface, and algorithm scope beyond this existing-parameter slice. | Design future controls in separate milestones with neutral semantics and evidence plans. |
| Couple lip tint to geometry warp | A combined “lip enhancement” control may appear convenient. | Conflates color and geometry safety/degradation, makes failures harder to isolate, and blocks independent host control. | Keep color containment and geometry shaping as separately testable domains. |
| Demo UI or makeup-resource expansion | Visible controls may make the milestone feel more complete. | The milestone is SDK-core only; UI/resource placement introduces unrelated ownership and shared-region-model questions. | Validate through the public facade and defer UI/resource work. |
| Track generated PNG baselines | Checked-in images seem convenient for review. | Bloats the repository and differs from the established runtime evidence policy. | Keep outputs/gallery ignored and commit helpers plus command-backed evidence records. |
| Commercial/device/parity claims | The feature names resemble mature consumer-editor tools. | Simulator/fixture evidence does not establish device parity, commercial naturalness, packaging, or broad Meitu parity. | State these as separate future evidence gates. |

## Feature Dependencies

```text
Existing 31-field public BeautyParameters inventory
    ├──> mouthSize / mouthWidth / smile geometry normalization
    │       └──> BeautyDetection mouth landmarks
    │               └──> BeautyRender unified warp
    │                       └──> public-facade renderer cases
    │                               └──> output helper + ignored gallery evidence
    │                                       └──> safety/degradation closeout
    │                                               └──> exact ledger promotion
    └──> lipColor normalization
            └──> mouth-region color containment
                    └──> public-facade color output evidence

lipColor evidence ──conflicts-with──> claiming true 丰唇 geometry
missing/stale mouth geometry ──disables──> mouth geometry only
reused mouth geometry ──weakens──> mouth geometry
other geometry domains ──weakens──> combined mouth geometry
```

### Dependency Notes

- **Renderer evidence requires the existing public facade and mouth landmarks:** provider-only behavior or Demo-only mapping cannot satisfy the ledger's implementation rule.
- **Safety closeout depends on isolated renderer and normalization evidence:** signed direction, exact caps, and fixture behavior must be observable before rows are promoted.
- **`mouthSize`, `mouthWidth`, and `smile` share geometry dependencies:** they rely on mouth landmarks and unified warp output, so missing/stale/reused rules should be enforced consistently.
- **`lipColor` has a separate dependency chain:** it depends on a bounded mouth color region, not on proof of upper/lower lip displacement. Mouth-geometry failure must not automatically convert it into geometry or suppress unrelated safe domains.
- **Ledger promotion depends on all evidence gates:** output alone is insufficient without cap, degradation, redaction, boundary, and artifact-containment checks.

## v1.8 Definition

### Launch With

- [ ] Isolated public-facade cases for positive/negative `mouthSize`, positive/negative `mouthWidth`, `smile`, and `lipColor`.
- [ ] Helper evidence across the established fixture matrix: expected output count, decode/non-empty/dimension checks, portrait differences, signed-pair differences, representative no-face preservation, ignored gallery routing, and zero tracked generated PNGs.
- [ ] Focused exact-cap and signed-semantics tests for all four existing public fields.
- [ ] Missing/stale fail-closed, reused reduced-strength, combined weakening, redaction, containment, and safe-domain-continuation evidence.
- [ ] Promotion of exactly `大小`, `宽度`, and `微笑`, with branch-level `嘴唇` remaining `partial`.
- [ ] Explicit documentation that `lipColor` is color-domain evidence and not true `丰唇` geometry.

### Add After Validation

- [ ] A distinct true `丰唇` geometry parameter and upper/lower-lip shaping design, or an explicit product decision to relabel the current Demo mapping.
- [ ] Independent neutral parameters and geometry designs for `上下`, `倾斜`, `左右`, and `M唇`.
- [ ] Teeth whitening through a local teeth segmentation/color-retouch owner, potentially under `skin-retouch/teeth-hairline` rather than lip geometry.

### Future Consideration

- [ ] SwiftUI controls and broader mouth/makeup resource placement after a shared mouth-region ownership model exists.
- [ ] Physical-device parity, commercial visual approval, optimized performance profiling, packaging, and launch-readiness evidence.
- [ ] Broader Meitu/Xingtu feature parity or any cloud/account/payment/VIP/entitlement path.

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
| --- | --- | --- | --- |
| Signed `mouthSize` evidence and safety | HIGH | HIGH | P1 |
| Signed `mouthWidth` evidence and safety | HIGH | HIGH | P1 |
| `smile` evidence and safety | HIGH | MEDIUM | P1 |
| `lipColor` containment and color evidence | HIGH | MEDIUM | P1 |
| Output helper/gallery/artifact gates | HIGH | MEDIUM | P1 |
| Exact three-row promotion and docs synchronization | HIGH | LOW | P1 |
| True `丰唇` geometry | MEDIUM | HIGH | P2 |
| `上下` / `倾斜` / `左右` / `M唇` | MEDIUM | HIGH | P2 |
| Teeth whitening | MEDIUM | HIGH | P2 |
| Demo UI and commercial/device review | MEDIUM | HIGH | P3 |

## Repository Feature Comparison

| Capability | v1.6 Eyes Pattern | v1.7 Nose Pattern | v1.8 Mouth Approach |
| --- | --- | --- | --- |
| Existing public fields only | Four eye parameters | Four nose parameters | `mouthSize`, `mouthWidth`, `smile`, `lipColor` |
| Signed output proof | `eyeDistance`, `eyeYPosition` | `noseTipSize` | Both `mouthSize` and `mouthWidth` |
| Geometry degradation | Missing/stale fail closed; reused reduced; combined weakened | Same, including all signed tip directions | Apply to the three geometry behaviors and both signed directions |
| Independent non-geometry domain | None central to slice | None central to slice | `lipColor` remains contained color evidence |
| Ledger promotion | Exactly four eye rows | Exactly four nose rows | Exactly `大小`, `宽度`, `微笑`; never infer `丰唇` from tint |
| Branch status | `partial` | `partial` | Remains `partial` |

## Sources

- `.planning/PROJECT.md` — v1.8 goal, active requirements, exclusions, and existing 31-field boundary.
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` — authoritative mouth rows, current statuses, promotion rule, and `lipColor`/`丰唇` gap.
- `docs/meitu-function-blueprint/features/beauty-shaping/lips/README.md` — mouth branch ownership, dependencies, public coverage, and future parameter needs.
- `.planning/milestones/v1.6-REQUIREMENTS.md` and `.planning/milestones/v1.6-ROADMAP.md` — predecessor renderer, output-helper, safety, degradation, and exact-promotion pattern.
- `.planning/milestones/v1.7-REQUIREMENTS.md` and `.planning/milestones/v1.7-ROADMAP.md` — latest signed geometry, reused/stale behavior, boundary gates, ignored-artifact, and closeout pattern.
- `$HOME/.codex/get-shit-done/templates/research-project/FEATURES.md` — research structure and prioritization guidance.

---
*Feature research for: v1.8 Broader `美型 / 五官` SDK Slice - Mouth*
*Researched: 2026-07-13*
