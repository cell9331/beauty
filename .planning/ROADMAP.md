# Roadmap: Beauty

## Milestones

- ✅ **v1.0 MVP** — Phases 1-7, shipped 2026-06-23.
- ✅ **v1.1 Meitu UI** — Phases 8-10, shipped 2026-06-24.
- ✅ **v1.2 HTML Reference Fidelity** — Phase 11 completed and Phases 12-15 canceled, 2026-06-26.
- ✅ **v1.3 Meitu Core Beauty Module Design and Implementation** — Phases 16-20, shipped 2026-06-30.
- ✅ **v1.4 Stability, QA, and Debt Cleanup** — Phases 21-25, shipped 2026-07-03.
- ✅ **v1.5 SDK Geometry Output Foundation and Face Shape Slice** — Phases 26-28, shipped 2026-07-08.
- ✅ **[v1.6 Broader `美型 / 五官` SDK Slice - Eyes](milestones/v1.6-ROADMAP.md)** — Phases 29-30, shipped 2026-07-13.
- ✅ **[v1.7 Broader `美型 / 五官` SDK Slice - Nose](milestones/v1.7-ROADMAP.md)** — Phases 31-32, shipped 2026-07-13.
- ✅ **[v1.8 Broader `美型 / 五官` SDK Slice - Mouth](milestones/v1.8-ROADMAP.md)** — Phases 33-34, shipped 2026-07-13.
- ✅ **[v1.9 Nose Remaining Tools and Branch Closeout](milestones/v1.9-ROADMAP.md)** — Phases 35-37, shipped 2026-07-14.
- ✅ **[v1.10 Mouth Remaining Geometry Controls](milestones/v1.10-ROADMAP.md)** — Phases 38-40, shipped 2026-07-14.
- ✅ **[v1.11 Eye Remaining Geometry Controls](milestones/v1.11-ROADMAP.md)** — Phases 41-44, shipped 2026-07-19.
- ✅ **[v1.12 Face Shape Remaining Capabilities](milestones/v1.12-ROADMAP.md)** — Phases 45-48, shipped 2026-07-24.
- 🚧 **v1.13 Eyebrow Geometry Controls** — Phases 49-52, SDK-SPM-only.

## Phases

- [ ] **Phase 49: Public Contract and Observed Eyebrow Support** — Exact 59-field compatibility, actual left/right Vision eyebrow mapping, open-trace validation, side/order canonicalization, and private lifecycle.
- [ ] **Phase 50: Independent Eyebrow Geometry and Pipeline Integration** — Seven distinct named transforms, field-local eligibility, exact 44-field convergence, unified dispatch, and redacted facade routing.
- [ ] **Phase 51: Public-Facade Eyebrow Output Evidence** — Thirteen isolated cases, strict 504-output direction/locality/distinction evidence, safe no-ops, and ignored gallery containment.
- [ ] **Phase 52: Eyebrow Safety and Branch Closeout** — Final caps, complete transitions, active-source/privacy gates, exact seven-row promotion, and implemented branch status.

## Phase Details

### Phase 49: Public Contract and Observed Eyebrow Support

**Goal:** Establish compatibility-safe public eyebrow semantics and honest request-scoped support from actual Apple Vision eyebrow traces.

**Depends on:** Nothing (first phase of v1.13)

**Requirements:** BROW-01, BROW-02, SUPP-01, SUPP-02, SUPP-03

**Plans:** 1/5 plans executed

- [x] 49-01-PLAN.md
- [ ] 49-02-PLAN.md
- [ ] 49-03-PLAN.md
- [ ] 49-04-PLAN.md
- [ ] 49-05-PLAN.md

**Success criteria:**

1. `BeautyParameters` contains exactly 59 stored fields (58 numeric plus `filterId`); all seven additions default to zero, normalize finitely, round-trip, and preserve legacy 52-field JSON/source/preset neutrality.
2. The existing single selected-face Vision landmarks request copies actual left/right eyebrow regions and maps accepted points exactly once through request-local orientation/mirror metadata.
3. Eyebrow open traces are independently bounded, validated, and canonicalized for side and inner/outer order; malformed evidence fails locally and is never replaced by eye contours or synthetic proxies.
4. Raw/derived eyebrow support remains package-only, ephemeral, non-Codable, non-persistent, non-networked, and aggregate-only in diagnostics; no provider/output/promotion claim is made in this phase.

### Phase 50: Independent Eyebrow Geometry and Pipeline Integration

**Goal:** Implement all seven eyebrow semantics as distinct provider-owned geometry through the existing resolver, conflict, warp, and public-facade path.

**Depends on:** Phase 49

**Requirements:** GEOM-01, GEOM-02, GEOM-03, GEOM-04, GEOM-05, GEOM-06, GEOM-07, PIPE-01, PIPE-02

**Plans:** TBD

**Success criteria:**

1. Vertical position, thickness, length, whole-brow spacing, inner-head spacing, tilt, and peak definition own independently testable vectors/local regions and do not modify shipped eye/face arrays.
2. Paired versus per-side prerequisites are explicit; missing/malformed support and provider-empty work remove only dependent eyebrow fields while eligible siblings and safe independent domains continue.
3. All seven named emissions traverse effective strengths, resolver/facade routing, one exact 44-field provider-eligible monotone convergence loop, and exactly-once unified dispatch with totals/counts/scales/metrics in agreement.
4. Focused and full SwiftPM evidence passes without new dependency, model, resource pack, SwiftUI/Demo source, network/cloud path, commercial behavior, or raw geometry exposure.

### Phase 51: Public-Facade Eyebrow Output Evidence

**Goal:** Prove every eyebrow capability through decoded public-facade images with fixed brow-local direction, locality, and distinction evidence.

**Depends on:** Phase 50

**Requirements:** OUT-01, OUT-02, OUT-03

**Plans:** TBD

**Success criteria:**

1. The renderer adds exactly thirteen isolated cases—positive/negative cases for six signed controls plus one peak case—expanding the duplicate-free inventory from 59 to 72.
2. A bounded strict helper accepts exactly 504 decoded same-dimension outputs across seven fixtures and proves visibility inside fixed brow regions with protected eyes, forehead, hair, background, and watermark locality.
3. Positive/negative directions remain distinct and all seven semantic families are distinguishable, including whole-brow spacing versus inner-head spacing and thickness versus peak.
4. Representative no-face, missing, malformed, and partial-support cases remain safe; renderer/output/gallery inventories are bijective and all generated evidence remains ignored, untracked, unstaged, and disposable.

### Phase 52: Eyebrow Safety and Branch Closeout

**Goal:** Freeze conservative behavior and promote exactly the seven eyebrow rows only after runtime, output, privacy, and owner evidence agree.

**Depends on:** Phase 51

**Requirements:** SAFE-01, SAFE-02, SAFE-03, DOC-01

**Plans:** TBD

**Success criteria:**

1. All seven controls have exact final caps/dead zones, correct signed or positive-only directionality, bounded radii, and no-face/missing/malformed/provider-empty/fresh/reused/stale/transition evidence.
2. Exact 44-field combined geometry retains one provider-eligible baseline with no re-entry or double scaling, and final strengths, totals, counts, scale, warnings, metrics, named emissions, and dispatch agree.
3. Public/SPI, diagnostics, persistence, reflection, Demo imports, dependencies, network/cloud, commercial, generated-artifact, and active-source gates fail closed with no unresolved high-severity issue.
4. Exactly `上下`, `粗细`, `长短`, `间距`, `眉头间距`, `倾斜`, and `眉峰` become implemented; branch-level `眉毛` becomes implemented at SDK-core scope while v1.14-v1.16 and all UI/device/commercial/release claims remain future.

## Progress

| Phase | Milestone | Requirements | Status | Completed |
| --- | --- | --- | --- | --- |
| 49. Public Contract and Observed Eyebrow Support | v1.13 | 5 | In Progress|  |
| 50. Independent Eyebrow Geometry and Pipeline Integration | v1.13 | 9 | Not started | — |
| 51. Public-Facade Eyebrow Output Evidence | v1.13 | 3 | Not started | — |
| 52. Eyebrow Safety and Branch Closeout | v1.13 | 4 | Not started | — |

## Backlog

- v1.14 implements `去脂`, `祛红血丝`, and `白牙` through a reusable local mask/color-retouch path.
- v1.15 establishes an approved local semantic-region foundation and implements `发际线`.
- v1.16 implements `去双下巴`, `去双下巴 Pro`, and closes the narrow 51-row facial-feature taxonomy.
- `比例` and `3D塑颜` remain outside the narrow facial-feature sequence.
- SwiftUI/Demo UI, physical-device parity, commercial visual approval, optimized profiling, packaging, shipping, and launch-readiness evidence remain separately scoped.

---
*Last updated: 2026-07-24 after v1.13 roadmap creation*
