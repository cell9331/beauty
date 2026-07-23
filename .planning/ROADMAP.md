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
- 🚧 **v1.12 Face Shape Remaining Capabilities** — Phases 45-48, reduced contour-driven scope approved 2026-07-21.

## Phases

- [ ] **Phase 45: Public Contract and Observed Face Support** — Exact 52-field compatibility, actual observed contour/median-line mapping, private validation, and blocker-honest exclusion of semantic-region rows.
- [ ] **Phase 46: Independent Contour and Chin Geometry** — Distinct smooth-contour, temple, cheekbone, and chin-taper emissions through the existing resolver, conflict, warp, and facade pipeline.
- [ ] **Phase 47: Public-Facade Face Output Evidence** — Isolated renderer cases, decoded strict comparisons, safe no-ops, and ignored descriptor-safe gallery evidence for all four controls.
- [ ] **Phase 48: Face Safety and Scoped Closeout** — Final caps, exhaustive field-local transitions, exact multi-domain convergence, four-row promotion, and preserved partial branch status.

## Phase Details

### Phase 45: Public Contract and Observed Face Support

**Goal:** Establish compatibility-safe public semantics and honest observed face support for the four contour-driven controls.

**Requirements:** FACE-07, FACE-08, FACE-09, FACE-12, SUPP-01, SUPP-02, SUPP-04

**Plans:** 1/5 plans executed

Plans:

- [x] 45-01-PLAN.md — Wave 0 fail-closed safeguards, private support contracts, and topology fixtures.
- [ ] 45-02-PLAN.md — Exact 52-field public compatibility and shipped-neutrality contract.
- [ ] 45-03-PLAN.md — Actual Vision contour/median capture and canonical one-mapper mapping.
- [ ] 45-04-PLAN.md — Face-specific topology validation, independent eligibility, and legacy isolation.
- [ ] 45-05-PLAN.md — Owner-contract synchronization and live boundary/requirement closeout.

**Success criteria:**

1. The public model contains exactly 52 stored fields (51 numeric plus `filterId`), every new field defaults to zero, legacy 48-field payloads decode neutrally, and bundled presets remain unchanged.
2. Actual Vision face contour and median line are mapped once, canonicalized across orientation/mirroring, rejected when malformed, and never replaced by the synthetic face-box proxy for new controls.
3. Raw observed support is request-scoped and package-only, while missing support disables only the four new fields and preserves eligible shipped or face-agnostic work.
4. `去双下巴`, `去双下巴 Pro`, and `发际线` remain explicitly future with the missing semantic-resource and clean-clone-fixture blocker recorded.

### Phase 46: Independent Contour and Chin Geometry

**Goal:** Implement four independently observable contour/chin controls without aliasing the five shipped face fields.

**Requirements:** GEOM-01, GEOM-02, GEOM-03, GEOM-04

**Success criteria:**

1. Smooth contour changes local contour continuity without whole-face shrinkage or modification of existing face-field vectors.
2. Temple and cheekbone controls use distinct upper-lateral outward and mid-lateral inward supports, with vector/locality tests against `faceSmall`, `faceSlim`, and `jawSlim`.
3. Chin taper narrows adjacent contour points toward the apex without changing signed chin length or borrowing V-face evidence.
4. All four fields have named provider emissions, field-local eligibility, resolver/conflict/facade routing, and provider-empty removal from effective accounting.

### Phase 47: Public-Facade Face Output Evidence

**Goal:** Prove every scoped face capability through decoded public-facade images rather than provider-only assertions.

**Requirements:** OUT-01, OUT-02, OUT-03

**Success criteria:**

1. The renderer contains one isolated case for each new control with an exact duplicate-free case/fixture/output inventory.
2. A bounded strict helper verifies every output decodes, preserves dimensions, crosses fixed visibility floors, stays inside the intended region, and distinguishes each new field from its nearest shipped/new neighbor.
3. Representative no-face, missing-contour, and malformed-contour cases produce safe public results while eligible sibling domains continue.
4. Gallery generation has an exact renderer/gallery bijection and leaves zero tracked, staged, or non-ignored generated artifacts.

### Phase 48: Face Safety and Scoped Closeout

**Goal:** Freeze final safety and promote the exact four scoped rows only after implementation, output, privacy, and boundary evidence agree.

**Requirements:** SAFE-01, SAFE-02, SAFE-03, DOC-01

**Success criteria:**

1. Exact caps/dead zones and no-face, missing, malformed, provider-empty, fresh, reused, and stale transitions pass for all four new fields and the complete nine-field face inventory.
2. Combined thirty-seven-field face/eye/nose/mouth geometry converges monotonically on provider-eligible work, with exact final strengths, totals, counts, scale, warnings, metrics, and dispatched emissions.
3. Public/SPI, diagnostics, persistence, Demo imports, network/commercial, dependency, generated-artifact, and active-source gates fail closed with no unresolved high-severity issue.
4. Exactly `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴` are promoted; `去双下巴`, `去双下巴 Pro`, `发际线`, and branch-level `脸型` remain future or partial without readiness overclaim.

## Progress

| Phase | Milestone | Requirements | Status | Completed |
| --- | --- | --- | --- | --- |
| 45. Public Contract and Observed Face Support | v1.12 | 1/5 | In Progress|  |
| 46. Independent Contour and Chin Geometry | v1.12 | 4 | Not started | — |
| 47. Public-Facade Face Output Evidence | v1.12 | 3 | Not started | — |
| 48. Face Safety and Scoped Closeout | v1.12 | 4 | Not started | — |

## Backlog

- `去双下巴`, `去双下巴 Pro`, and `发际线` require an approved local semantic-region implementation and reproducible clean-clone fixtures.
- `白牙`, `去脂`, and `祛红血丝` remain future local segmentation/retouch/color slices.
- `比例`, `3D塑颜`, and `眉毛` remain future or partial slices.
- Demo UI, physical-device parity, commercial visual approval, optimized profiling, packaging, shipping, and launch-readiness evidence remain separately scoped.

---
*Last updated: 2026-07-21 after semantic-resource blocker rescope*
