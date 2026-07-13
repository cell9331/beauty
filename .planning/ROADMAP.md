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
- 🚧 **v1.9 Nose Remaining Tools and Branch Closeout** — Phases 35-37.

## Current Milestone: v1.9 Nose Remaining Tools and Branch Closeout

### Phase 35: Public Contract and Independent Geometry

**Goal:** Freeze compatibility-safe public semantics for `noseRootNarrowing` and `noseTipLift`, route both fields through the existing facade and safety model, and prove two bounded, deterministic, non-aliased nose geometry paths.

**Requirements:** NOSE-01, NOSE-02, NOSE-03, NOSE-04, NOSE-05, NOSE-06

**Status:** Planned

**Plans:** 0/4 plans complete

**Wave 1**

- [ ] `35-01-PLAN.md` — public contract, 33-field compatibility, effective values, and provisional caps

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] `35-02-PLAN.md` — package-internal root/tip supports and independent fail-closed provider geometry

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] `35-03-PLAN.md` — resolver, degradation, conflict, and redacted public-facade routing

**Wave 4** *(blocked on Wave 3 completion)*

- [ ] `35-04-PLAN.md` — full verification, security/Nyquist finalization, and current-owner synchronization without promotion

**Success Criteria:**

1. Hosts can set independent positive-only `noseRootNarrowing` and `noseTipLift` values in `0...1`; defaults, finite clamping, non-finite fallback, and the 33-stored-field inventory are verified without aliasing either field to legacy nose controls.
2. Existing 31-field JSON, bundled presets, and source-style initializer calls remain neutral and compatible, while new 33-field values round-trip with both fields intact.
3. Either new field independently activates the established public-facade geometry route and propagates through effective strengths, metrics, degradation, and conflict handling without exposing raw geometry.
4. Provider evidence proves root narrowing is bounded symmetric horizontal-only motion in an upper-root subset and tip lift is bounded upward vertical-only motion in a lower-tip subset, with deterministic non-empty output distinct from `noseBridge` and signed `noseTipSize`.
5. Missing or insufficient root/tip geometry fails closed without substituting legacy control points, while valid output stays finite and bounded.

### Phase 36: Public-Facade Output Evidence

**Goal:** Produce deterministic public-facade renderer, output-helper, and ignored-gallery evidence that both new nose tools remain visible, independent, extent-preserving, and artifact-contained across the established fixtures.

**Requirements:** NOSE-07, NOSE-08, NOSE-09

**Status:** Not started

**Success Criteria:**

1. `BeautyExampleRenderer` adds exactly one isolated public-facade case per new field, yielding 36 cases and 252 ignored outputs when the current seven-fixture inventory is unchanged.
2. A v1.9-owned helper derives the actual case-by-fixture inventory and verifies every expected PNG is decodable, non-empty, and same-dimension.
3. Both new cases differ from `geometryBaseline_noop` on every usable portrait above the watermark and differ from their nearest legacy nose effects within a documented nose ROI.
4. Representative no-face outputs preserve extent and degrade safely; output/gallery routes remain ignored and no generated PNG is tracked.

### Phase 37: Nose Safety, Boundary, and Branch Closeout

**Goal:** Lock exact safety behavior for all six nose fields, pass fail-closed boundary and regression gates, and atomically promote the two remaining rows plus SDK-core branch status only after all current evidence owners agree.

**Requirements:** NOSE-10, NOSE-11, NOSE-12, NOSE-13, NOSE-14, DOC-01

**Status:** Not started

**Success Criteria:**

1. Focused evidence locks exact natural caps, normalization, capped counts, warnings, and aggregate metrics for both new public fields while preserving the public `0...1` contract.
2. All six nose fields fail closed for no-face, missing, stale, insufficient, or provider-empty geometry; reused geometry scales each field by exactly `0.5`, diagnostics remain redacted, and independent safe domains continue.
3. Combined face, eye, mouth, and six-field nose geometry weakens every active geometry field exactly once and preserves all shipped signed directions without regressing prior face/eye/nose/mouth behavior.
4. Full SDK tests plus active-source scans pass for raw/public geometry, imports, compatibility, network/cloud, commercial paths, dependencies, diagnostics, and generated artifacts.
5. `山根`, `提升`, and SDK-core branch-level `鼻子` are promoted only after their own evidence passes, and every owning contract, planning ledger, verification, validation, security record, and milestone audit agrees while preserving explicit Demo/device/commercial/packaging/launch non-claims.

## Progress

- [ ] Phase 35: Public Contract and Independent Geometry
- [ ] Phase 36: Public-Facade Output Evidence
- [ ] Phase 37: Nose Safety, Boundary, and Branch Closeout

| Phase | Plans Complete | Status | Completed |
| --- | --- | --- | --- |
| 35. Public Contract and Independent Geometry | 0/TBD | Planning | — |
| 36. Public-Facade Output Evidence | 0/TBD | Not started | — |
| 37. Nose Safety, Boundary, and Branch Closeout | 0/TBD | Not started | — |

## Backlog

- Remaining mouth tools: `上下`, `倾斜`, `左右`, `M唇`, true `丰唇`, and `白牙` require separate parameter, geometry, segmentation, or ownership design.
- `比例`, `3D塑颜`, and `眉毛` remain future or partial slices.
- Device, commercial visual, packaging, performance, and launch-readiness evidence remains separately scoped.

---
*Roadmap created: 2026-07-13*
*Last updated: 2026-07-13 for Phase 35 planning completion*
