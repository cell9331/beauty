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
- 🚧 **v1.10 Mouth Remaining Geometry Controls** — Phases 38-40.

## Current Milestone: v1.10 Mouth Remaining Geometry Controls

**Milestone Goal:** Complete the five unresolved SDK-core mouth geometry controls through independent public semantics, explicit lip-support geometry, facade-visible output, conservative safety, and exact evidence-backed promotion while keeping `白牙` outside the geometry slice.

## Phases

- [x] **Phase 38: Public Contract and Lip-Support Geometry** — Add five compatible public controls and independently eligible whole-mouth/upper/lower lip geometry through the existing facade pipeline.
- [ ] **Phase 39: Public-Facade Mouth Geometry Output Evidence** — Prove all five controls through isolated public-facade output, strict helper checks, and ignored gallery containment.
- [ ] **Phase 40: Mouth Geometry Safety and Ledger Closeout** — Finalize caps, exhaustive degradation/conflict behavior, fail-closed boundaries, and exact five-row promotion without claiming `白牙` or whole-branch completion.

## Phase Details

### Phase 38: Public Contract and Lip-Support Geometry

**Goal**: Hosts can configure five independent remaining mouth geometry controls through source- and JSON-compatible public parameters, and the SDK routes each control only when its package-internal lip support can emit bounded geometry.
**Depends on**: Phase 37 and the shipped v1.8 mouth geometry baseline
**Requirements**: MOUTH-01, MOUTH-02, MOUTH-03, MOUTH-04, MOUTH-05, MOUTH-06, MOUTH-07, MOUTH-08
**Success Criteria** (what must be TRUE):

  1. Existing source-style initialization, 33-field JSON, and bundled presets remain neutral while hosts can round-trip exactly five new fields in a 38-field stored model.
  2. Hosts can request both directions of vertical position, tilt, and horizontal position and observe distinct bounded provider vectors rather than aliases of shipped mouth behavior.
  3. Hosts can request M-lip peak definition and true lip plumping and receive distinct local upper/lower lip geometry rather than mouth-size, smile, or lip-color behavior.
  4. Missing or malformed inner/upper/lower support removes only dependent peak/plump work; supported whole-mouth and shipped sibling controls remain eligible, finite, deterministic, and bounded.
  5. Any new field triggers the established public-facade geometry route, while effective strengths and per-field emissions agree and no raw lip support crosses package or diagnostic boundaries.

**Plans**: 4 plans

- [x] `38-01-PLAN.md` — Public contract, exact 38-field compatibility, effective storage, and provisional caps.
- [x] `38-02-PLAN.md` — Optional inner-lip availability and deterministic package-only supports.
- [x] `38-03-PLAN.md` — Eight-field provider emissions and independent whole/peak/plump geometry.
- [x] `38-04-PLAN.md` — Resolver/conflict/facade integration, review, verification, and contract synchronization.

### Phase 39: Public-Facade Mouth Geometry Output Evidence

**Goal**: Hosts can observe every new mouth geometry control in deterministic saved output through the public `BeautySDK` facade, with direction, semantic distinction, no-face behavior, and local artifact containment proven.
**Depends on**: Phase 38
**Requirements**: MOUTH-09, MOUTH-10, MOUTH-11
**Success Criteria** (what must be TRUE):

  1. Eight isolated public-facade cases cover both directions of all three signed controls plus independent peak-definition and plump controls, expanding the derived renderer matrix to 44 cases.
  2. A guarded clean run produces exactly 308 expected files for the current seven fixtures, and every file is decodable, non-empty, and dimension-preserving.
  3. Every usable portrait differs from baseline in a fixed mouth ROI above the watermark, and each signed pair differs from its opposite direction.
  4. Peak-definition and plump outputs differ from each other and from their nearest shipped size/smile/color controls, so neither new row borrows old evidence.
  5. Representative no-face output degrades safely, gallery routing is a duplicate-free bijection with renderer cases, and all generated output/gallery files remain ignored and untracked.

**Plans**: 3 plans

- [ ] `39-01-PLAN.md` — Exact eight-case public renderer contract and representative no-face facade evidence.
- [ ] `39-02-PLAN.md` — Self-contained strict helper, non-circular calibration, and 308-output visibility/direction/independence evidence.
- [ ] `39-03-PLAN.md` — Safe ignored gallery publication, evidence-owner synchronization, review/security/verification, and Phase 40 handoff.

### Phase 40: Mouth Geometry Safety and Ledger Closeout

**Goal**: Hosts receive conservative, redacted, and internally consistent behavior for all eight mouth geometry fields, and repository owners promote exactly the five evidence-backed rows without overstating the remaining non-geometry branch.
**Depends on**: Phase 39
**Requirements**: MOUTH-12, MOUTH-13, MOUTH-14, MOUTH-15, MOUTH-16, DOC-01
**Success Criteria** (what must be TRUE):

  1. All five new controls have evidence-backed exact caps, correct normalization/capped counts, and preserved signed or positive-only directionality.
  2. No-face, missing outer/inner support, provider-empty work, stale geometry, reused geometry at exact `0.5`, and transitions degrade only dependent mouth fields while safe siblings and color/filter domains continue.
  3. Combined face, eye, six-field nose, and eight-field mouth work converges on one provider-eligible retained set; exact totals, counts, scales, warnings, effective strengths, and emissions exclude unsupported work.
  4. Full tests and active-source scans prove raw geometry, public support types, internal imports, network/cloud, commercial paths, dependencies, compatibility, unclassified matches, and generated artifacts remain fail-closed.
  5. Exactly `上下`, `倾斜`, `左右`, `M唇`, and true `丰唇` become implemented; `白牙` remains future, branch-level `嘴唇` remains partial, and all current contract/planning owners agree without device/commercial/packaging/shipping/launch claims.

**Plans**: TBD

## Progress

| Phase | Plans Complete | Status | Completed |
| --- | --- | --- | --- |
| 38. Public Contract and Lip-Support Geometry | 4/4 | Complete | 2026-07-14 |
| 39. Public-Facade Mouth Geometry Output Evidence | 0/TBD | Not started | - |
| 40. Mouth Geometry Safety and Ledger Closeout | 0/TBD | Not started | - |

## Backlog

- `白牙` remains a future teeth-region segmentation/color-retouch slice and keeps branch-level `嘴唇` partial after v1.10 geometry completion.
- `比例`, `3D塑颜`, and `眉毛` remain future or partial slices.
- Device, commercial visual, packaging, performance, and launch-readiness evidence remains separately scoped.

---
*Roadmap created: 2026-07-14*
*Last updated: 2026-07-14 after v1.10 auto-mode roadmap approval*
