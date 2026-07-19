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

## Current Milestone: v1.11 Eye Remaining Geometry Controls

**Milestone Goal:** Complete ten unresolved SDK-core eye geometry controls through independent public semantics, private observed contour/pupil support, facade-visible output, conservative safety, and exact evidence-backed promotion while keeping `去脂` and `祛红血丝` outside the geometry slice.

## Phases

- [x] **Phase 41: Public Contract and Observed Eye Support** — Add ten compatible public controls, private Vision contour/pupil support, canonical coordinate conversion, strict support validation, and privacy boundaries. (completed 2026-07-16)
- [x] **Phase 42: Independent Eye Geometry and Pipeline Integration** — Implement ten distinct contour/pupil/correction transforms, fourteen named eye emissions, resolver/conflict convergence, and facade routing. (completed 2026-07-16)
- [x] **Phase 43: Public-Facade Eye Geometry Output Evidence** — Prove isolated controls, signed tilt, eligibility-aware correction/symmetry, no-face behavior, strict decoded outputs, and ignored gallery containment. (completed 2026-07-16)
- [ ] **Phase 44: Eye Geometry Safety and Ledger Closeout** — Lock exact caps and transitions, complete the fail-closed boundary gate, promote exactly ten geometry rows, and synchronize all owners.

## Phase Details

### Phase 41: Public Contract and Observed Eye Support

**Goal**: Hosts can configure ten independent eye geometry controls through source- and JSON-compatible public parameters, and the SDK obtains validated private contour/pupil support without exposing biometric-adjacent geometry.
**Depends on**: v1.10 and the shipped v1.6 eye baseline
**Requirements**: EYE-01, EYE-02, EYE-03, EYE-04, EYE-05, EYE-06, EYE-07
**Success Criteria** (what must be TRUE):

  1. Existing source-style initialization, 38-field JSON, and bundled presets remain neutral while hosts can round-trip exactly ten new fields in a 48-field stored model.
  2. Zero-default v1.11 values preserve every shipped eye field, cap, vector, and facade path; all ten new fields remain independently stored and normalized.
  3. Vision left/right contours and optional pupils convert once into finite, bounded, repository-normalized private support with side identity and orientation tests.
  4. The adapter emits deterministic upper/lower/inner/outer/corner/center/pupil support and rejects malformed, duplicate-only, out-of-bounds, implausible, or overlarge input before provider use.
  5. Missing or implausible pupils remove only pupil-dependent requests, while missing either eye contour retains the established complete eye-domain skip and no raw geometry crosses public or diagnostic boundaries.

**Plans**: 4/5 plans executed

Plans:

- [ ] 41-05-PLAN.md

**Wave 1**

- [x] 41-01-PLAN.md — Add the ten compatibility-safe public eye scalars and neutral regression evidence.
- [x] 41-02-PLAN.md — Thread private Vision contour/pupil support through one coordinate-mapping boundary.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 41-03-PLAN.md — Canonicalize/validate support and prove field-local degradation.

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 41-04-PLAN.md — Run fail-closed boundaries and synchronize owning contracts.

### Phase 42: Independent Eye Geometry and Pipeline Integration

**Goal**: Hosts receive ten distinct bounded eye geometry behaviors through the existing resolver, provider, conflict, and public-facade route, with field-local eligibility and automatic correction that never fabricates observed deviation.
**Depends on**: Phase 41
**Requirements**: EYE-08, EYE-09, EYE-10, EYE-11, EYE-12, EYE-13, EYE-14, EYE-15
**Success Criteria** (what must be TRUE):

  1. Height, length, upper/lower lid, tilt, and inner/outer corner vectors use distinct source subsets and remain distinct from shipped size, distance, Y-position, and tail-lift vectors.
  2. Pupil size is local to validated pupil support; gaze correction monotonically reduces an observed offset with a dead zone; neither emits for absent or implausible pupil data.
  3. Symmetry reduces only measured paired-eye differences toward a bounded midpoint and no-ops for neutral/implausible pairs without mirroring identity.
  4. EyeWarpProvider owns fourteen named emissions; missing or final-scale-empty fields are removed from effective strengths and all aggregate accounting while valid siblings survive.
  5. Each isolated new field triggers the existing detection/adapter/resolver/facade route with redacted aggregate evidence and no new pass, target, dependency, or public geometry type.

**Plans**: 4/4 plans complete

Plans:

- [x] 42-01-PLAN.md — Implement independent contour/lid/corner/tilt/pupil/gaze/symmetry provider emissions.
- [x] 42-02-PLAN.md — Integrate fourteen named emissions into resolver, field-local eligibility, and facade routing.
- [x] 42-03-PLAN.md — Extend combined conflict totals and bounded eye/nose/mouth convergence.
- [x] 42-04-PLAN.md — Complete the Phase 42 validation ledger and handoff.

**Wave 1**

- 42-01-PLAN.md

**Wave 2** *(blocked on Wave 1 completion)*

- 42-02-PLAN.md

**Wave 3** *(blocked on Wave 2 completion)*

- 42-03-PLAN.md

**Wave 4** *(blocked on Wave 3 completion)*

- 42-04-PLAN.md

### Phase 43: Public-Facade Eye Geometry Output Evidence

**Goal**: Hosts can observe every eligible v1.11 eye geometry control in deterministic saved output through the public facade, with signed direction, semantic distinction, automatic-correction behavior, safe no-op cases, and local artifact containment proven.
**Depends on**: Phase 42
**Requirements**: EYE-16, EYE-17, EYE-18
**Success Criteria** (what must be TRUE):

  1. The renderer includes ten isolated positive-only cases plus positive and negative `eyeTilt`, expanding the current 44-case matrix to exactly 55 cases.
  2. A bounded strict helper derives the seven-fixture matrix, decodes every expected non-empty same-dimension output, and distinguishes height/length/lid/corner/pupil/correction/symmetry families in fixed eye-local regions.
  3. Both tilt directions differ from each other and from tail lift; automatic gaze correction reduces measured deviation on an eligible fixture and neutral/ineligible inputs remain safe no-ops.
  4. Representative no-face and field-ineligible outputs preserve extent and safe-domain continuation; all generated outputs/gallery files remain ignored, untracked, and bijective with renderer cases.

**Plans**: TBD

- [x] 43-01-PLAN.md — Freeze the exact 55-case public renderer matrix and representative no-face facade contract.
- [x] 43-02-PLAN.md — Build, calibrate, and strictly accept the bounded 385-output eye-local evidence matrix.
- [x] 43-03-PLAN.md — Publish the ignored gallery and close Phase 43 validation/security/tracking.

### Phase 44: Eye Geometry Safety and Ledger Closeout

**Goal**: Hosts receive conservative, redacted, internally consistent behavior for all fourteen eye geometry fields, and repository owners promote exactly ten evidence-backed rows without overstating the remaining retouch branch.
**Depends on**: Phase 43
**Requirements**: EYE-19, EYE-20, EYE-21, EYE-22, EYE-23, DOC-01
**Success Criteria** (what must be TRUE):

  1. All ten new controls have evidence-backed exact caps, neutral/dead-zone behavior, correct normalization/capped counts, and preserved signed or positive-only directionality.
  2. No-face, missing contours, missing/implausible pupils, malformed support, provider-empty work, reused geometry, stale geometry, and transitions degrade according to field dependency while safe siblings and non-eye domains continue.
  3. Combined face, fourteen-field eye, six-field nose, and eight-field mouth geometry converges on one provider-eligible retained baseline through at most twenty-eight eye/nose/mouth removals, with totals/counts/scales/emissions agreeing.
  4. Full SDK tests and self-tested active-source/security/artifact gates prove no raw geometry leakage, dependency/network/commercial drift, compatibility drift, public support types, or tracked generated artifacts.
  5. Exactly `眼高`, `长度`, `提肌`, `眼瞳大小`, `眼神矫正`, `眼睑下至`, `倾斜`, `内眼角`, `外眼角`, and `对称` become implemented; `去脂`, `祛红血丝`, and branch-level `眼睛` remain partial with conservative non-claims.

**Plans**: 2/6 plans executed

**Wave 1**

- [x] 44-01-PLAN.md

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 44-02-PLAN.md

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 44-03-PLAN.md

**Wave 4** *(blocked on Wave 3 completion)*

- [ ] 44-04-PLAN.md

**Wave 5** *(blocked on Wave 4 completion)*

- [ ] 44-05-PLAN.md

**Wave 6** *(blocked on Wave 5 completion)*

- [ ] 44-06-PLAN.md

## Progress

| Phase | Plans Complete | Status | Completed |
| --- | --- | --- | --- |
| 41. Public Contract and Observed Eye Support | 6/5 | Complete    | 2026-07-16 |
| 42. Independent Eye Geometry and Pipeline Integration | 4/4 | Complete    | 2026-07-16 |
| 43. Public-Facade Eye Geometry Output Evidence | 3/3 | Complete | 2026-07-16 |
| 44. Eye Geometry Safety and Ledger Closeout | 2/6 | In Progress|  |

## Current Status

v1.11 Phase 43 is complete with strict public-facade saved-output evidence. Phase 44 is next for final caps, exhaustive safety/degradation, active-source boundaries, exact promotion, and owner synchronization.

## Backlog

- `白牙` remains a future teeth-region segmentation/color-retouch slice and keeps branch-level `嘴唇` partial after v1.10 geometry completion.
- `去脂` and `祛红血丝` remain future eye retouch/color slices and keep branch-level `眼睛` partial after v1.11 geometry completion.
- `比例`, `3D塑颜`, and `眉毛` remain future or partial slices.
- Device, commercial visual, packaging, performance, and launch-readiness evidence remains separately scoped.

---
*Last updated: 2026-07-16 after Phase 43 public-facade output evidence completion*
