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
- 🚧 **v1.12 Face Shape Remaining Capabilities** — Phases 45-49, planned 2026-07-21.

## Phases

- [ ] **Phase 45: Public Contract and Local Face Support** — Exact 55-field compatibility, actual observed contour/median-line mapping, private support validation, and a fail-closed local semantic-resource feasibility gate.
- [ ] **Phase 46: Independent Contour and Chin Geometry** — Distinct smooth-contour, temple, cheekbone, and chin-taper emissions through the existing resolver, conflict, warp, and facade pipeline.
- [ ] **Phase 47: Double-Chin and Hairline Region Pipeline** — Basic and refined double-chin behavior plus signed hairline movement using approved local semantic support and bounded containment.
- [ ] **Phase 48: Public-Facade Face Output Evidence** — Isolated renderer cases, decoded strict comparisons, safe no-ops, and ignored descriptor-safe gallery evidence for every new control.
- [ ] **Phase 49: Face Safety and Branch Closeout** — Final caps, exhaustive field-local transitions, exact multi-domain convergence, security/resource gates, seven-row promotion, and SDK-core `脸型` completion.

## Phase Details

### Phase 45: Public Contract and Local Face Support

**Goal:** Establish compatibility-safe public semantics and honest private support before any new face-shape implementation claim.

**Requirements:** FACE-07, FACE-08, FACE-09, FACE-10, FACE-11, FACE-12, FACE-13, SUPP-01, SUPP-02, SUPP-03, SUPP-04

**Success criteria:**

1. The public model contains exactly 55 stored fields (54 numeric plus `filterId`), every new field defaults to zero, legacy 48-field payloads decode neutrally, and bundled presets remain unchanged.
2. Actual Vision face contour and median line are mapped once, canonicalized across orientation/mirroring, rejected when malformed, and never replaced by the synthetic face-box proxy for new controls.
3. A bundled local semantic support implementation proves license, provenance, version, hash, platform, bounded-output, representative-fixture eligibility, and no-network behavior; otherwise mask-dependent rows remain explicitly blocked.
4. Raw contours/masks are request-scoped and package-only, while missing support disables only its dependent new fields and preserves eligible shipped or face-agnostic work.

### Phase 46: Independent Contour and Chin Geometry

**Goal:** Implement four independently observable contour/chin controls without aliasing the five shipped face fields.

**Requirements:** GEOM-01, GEOM-02, GEOM-03, GEOM-04

**Success criteria:**

1. Smooth contour changes local contour continuity without whole-face shrinkage or modification of existing face-field vectors.
2. Temple and cheekbone controls use distinct upper-lateral outward and mid-lateral inward supports, with vector/locality tests against `faceSmall`, `faceSlim`, and `jawSlim`.
3. Chin taper narrows adjacent contour points toward the apex without changing signed chin length or borrowing V-face evidence.
4. All four fields have named provider emissions, field-local eligibility, resolver/conflict/facade routing, and provider-empty removal from effective accounting.

### Phase 47: Double-Chin and Hairline Region Pipeline

**Goal:** Implement the three mask-sensitive remaining rows through bounded local processing and honest failure behavior.

**Requirements:** REGN-01, REGN-02, REGN-03

**Success criteria:**

1. Basic double-chin reduction operates only on eligible lower-contour/submental support and remains distinct from `jawSlim`.
2. Refined double-chin treatment is independently selectable, mask-contained, visibly distinct from basic reduction, and a no-op when refined support is ineligible.
3. Hairline height preserves sign through both directions and changes only an eligible bounded hair/skin region.
4. Missing, malformed, reused, or stale region support removes only dependent work; protected facial features, clothing/background, and face-agnostic effects remain unchanged.

### Phase 48: Public-Facade Face Output Evidence

**Goal:** Prove every new face capability through decoded public-facade images rather than provider-only assertions.

**Requirements:** OUT-01, OUT-02, OUT-03

**Success criteria:**

1. The renderer contains one isolated case for each positive-only control and both `hairlineHeight` directions, with an exact duplicate-free case/fixture/output inventory.
2. A bounded strict helper verifies every output decodes, preserves dimensions, crosses fixed visibility floors, stays inside the intended region, preserves signed direction, and distinguishes nearest-neighbor semantics including basic versus refined double chin.
3. Representative no-face, missing-contour, and missing-mask fixtures produce safe public results and exact no-op behavior for unsupported geometry while eligible sibling domains continue.
4. Gallery generation has an exact renderer/gallery bijection and leaves zero tracked, staged, or non-ignored generated artifacts.

### Phase 49: Face Safety and Branch Closeout

**Goal:** Freeze final safety and promote the exact remaining rows only after implementation, output, privacy, and resource evidence agree.

**Requirements:** SAFE-01, SAFE-02, SAFE-03, DOC-01

**Success criteria:**

1. Exact caps/dead zones and no-face, missing, malformed, provider-empty, fresh, reused, and stale transitions pass for all seven new fields and the complete twelve-field face inventory.
2. Combined forty-field face/eye/nose/mouth geometry converges monotonically on provider-eligible work, with exact final strengths, totals, counts, scale, warnings, metrics, and dispatched emissions.
3. Public/SPI, diagnostics, persistence, Demo imports, resource license/hash, network/commercial, dependency, generated-artifact, and active-source gates fail closed with no unresolved high-severity issue.
4. Exactly `面部流畅`, `太阳穴`, `颧骨`, `去双下巴`, `去双下巴 Pro`, `尖下巴`, and `发际线` plus branch-level `脸型` are promoted across every owning ledger without device/commercial/performance/packaging/shipping/launch overclaim.

## Progress

| Phase | Milestone | Requirements | Status | Completed |
| --- | --- | --- | --- | --- |
| 45. Public Contract and Local Face Support | v1.12 | 11 | Not started | — |
| 46. Independent Contour and Chin Geometry | v1.12 | 4 | Not started | — |
| 47. Double-Chin and Hairline Region Pipeline | v1.12 | 3 | Not started | — |
| 48. Public-Facade Face Output Evidence | v1.12 | 3 | Not started | — |
| 49. Face Safety and Branch Closeout | v1.12 | 4 | Not started | — |

## Backlog

- `白牙`, `去脂`, and `祛红血丝` remain future local segmentation/retouch/color slices after v1.12.
- `比例`, `3D塑颜`, and `眉毛` remain future or partial slices.
- Demo UI, physical-device parity, commercial visual approval, optimized profiling, packaging, shipping, and launch-readiness evidence remain separately scoped.

---
*Last updated: 2026-07-21 after v1.12 roadmap creation*
