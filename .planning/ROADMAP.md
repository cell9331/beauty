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
- ✅ **[v1.13 Eyebrow Geometry Controls](milestones/v1.13-ROADMAP.md)** — Phases 49-52, shipped 2026-07-28.
- 📋 **v1.14 Local Facial Retouch** — Phases 53-58, planned.

## Overview

v1.14 establishes one SDK-SPM still-image local-retouch boundary, qualifies feature evidence before visible implementation, proves original-pixel composition, then delivers teeth and sclera as independent vertical slices. Upper-eyelid fullness is acquisition-first and conditional: a closed evidence/design gate adds no field, provider, renderer case, or inert route and does not block qualified teeth or sclera. The milestone closes only the admitted rows through the public facade, privacy and safety gates, exact ledgers, and independent audit; realtime, pixel-buffer, transparent, UI, cloud, external-model, tracked-media, device, commercial, performance-budget, packaging, shipping, and launch claims remain outside v1.14.

## Phases

- [x] **Phase 53: Canonical Still-Image Contract and Private Request Foundation** - Give every admitted retouch effect one compatible facade entry, one opaque canonical raster, and one request-local selected-face support owner. (completed 2026-07-31)
- [x] **Phase 54: Rights-Approved Evidence and Eligibility Decisions** - Decide each visible feature independently from complete rights-approved positive/negative evidence and frozen review criteria. (completed 2026-08-03)
- [x] **Phase 55: Original-Pixel Composition and Failure-Isolation Core** - Prove one mask owner, hard containment, overlap-to-source behavior, and smallest-unit degradation before visible effects compose. (completed 2026-08-03)
- [x] **Phase 56: Independent Teeth Whitening Slice** - Ship `白牙` only if its own containment, naturalness, facade-output, privacy, and evidence gates pass. (completed 2026-08-04)
- [x] **Phase 57: Guarded Sclera Slice and Conditional Upper-Eyelid Work** - Qualify `祛红血丝` per eye and either deliver a separately proven non-warp `去脂` slice or record its complete absence. (completed 2026-08-04)
- [x] **Phase 58: Combined Facade, Safety, Ledger, and Audit Closeout** - Verify the admitted set together without weakening standalone evidence, privacy, compatibility, or scope boundaries. (completed 2026-08-05)

<details>
<summary>✅ v1.13 Eyebrow Geometry Controls (Phases 49-52) — SHIPPED 2026-07-28</summary>

- [x] Phase 49: Public Contract and Observed Eyebrow Support (5/5 plans) — completed 2026-07-24
- [x] Phase 50: Independent Eyebrow Geometry and Pipeline Integration (6/6 plans) — completed 2026-07-24
- [x] Phase 51: Public-Facade Eyebrow Output Evidence (5/5 plans) — completed 2026-07-27
- [x] Phase 52: Eyebrow Safety and Branch Closeout (10/10 plans) — completed 2026-07-27

</details>

Earlier shipped milestones are preserved in their linked archives under `.planning/milestones/`.

## Phase Details

### Phase 53: Canonical Still-Image Contract and Private Request Foundation

**Goal**: SDK integrators can invoke any admitted v1.14 effect through one compatibility-safe still-image request whose validation, pixels, selected face, and private support have a single owner.
**Depends on**: Phase 52 (shipped v1.13 baseline)
**Requirements**: PATH-01, PATH-02, PATH-03, PATH-04, PATH-05, PATH-06, PATH-07
**Success Criteria** (what must be TRUE):

  1. An integrator can request admitted local retouch through the existing public still-image `BeautySDK` facade, while realtime and pixel-buffer requests preserve their previously shipped behavior and cannot activate v1.14 retouch.
  2. Every accepted local-retouch still image becomes one opaque, up-oriented, explicitly managed sRGB RGBA8 raster shared by Vision, private support providers, and rendering.
  3. Transparent, malformed-orientation, non-RGB, oversized, and otherwise unsupported inputs return typed privacy-safe outcomes before Vision or local-mask creation.
  4. A still-image request with any admitted effect performs at most one selected-face landmarks request and one mapping pass, and no mapped support survives or crosses the request.
  5. Legacy 59-field source construction, JSON, presets, defaults, and shipped output remain neutral; every field that is later admitted is independent, positive-only, finite-normalized, default-zero, and counted by an exact compatibility contract.

**Plans**: 6/6 plans executed

- [x] 53-01-PLAN.md
- [x] 53-02-PLAN.md
- [x] 53-03-PLAN.md
- [x] 53-04-PLAN.md
- [x] 53-05-PLAN.md
- [x] 53-06-PLAN.md

### Phase 54: Rights-Approved Evidence and Eligibility Decisions

**Goal**: Each candidate feature has an auditable, independent go/no-go decision before its visible implementation can be promoted.
**Depends on**: Phase 53; rights acquisition may begin during Phase 53, but eligibility resolves here
**Requirements**: EVID-01, EVID-02, EVID-03, EVID-04, EVID-05, LID-01
**Success Criteria** (what must be TRUE):

  1. Each candidate feature's product gate opens only for a complete opaque rights-approved bundle containing genuine positive and negative cases with original, mask, after, and predeclared-polarity evidence.
  2. Mechanics-only and synthetic fixtures can still exercise deterministic safety checks but contribute nothing to product-effectiveness or naturalness aggregates.
  3. A reviewer can perform the frozen blinded original-detail review and persist only opaque identifiers, structured judgments, fixed reason codes, decisions, and aggregates—never media, paths, rights records, raw support, or freeform text.
  4. Teeth, sclera, and upper-eyelid eligibility are decided separately, so a closed or failed gate cannot lend evidence to or block a qualified sibling.
  5. `去脂` receives a deterministic go/no-go decision only after genuine upper-eyelid-fullness positives/negatives and a credible independent non-warp design are both reviewed.

**Plans**: 5/5 plans executed

- [x] 54-01-PLAN.md
- [x] 54-02-PLAN.md
- [x] 54-03-PLAN.md
- [x] 54-04-PLAN.md
- [x] 54-05-PLAN.md

### Phase 55: Original-Pixel Composition and Failure-Isolation Core

**Goal**: Admitted providers can contribute bounded local edits without sequential feedback, ambiguous ownership, or cross-region failure coupling.
**Depends on**: Phase 54 (eligibility decisions may remain closed)
**Requirements**: COMP-01, COMP-02, COMP-03, COMP-04, COMP-05
**Success Criteria** (what must be TRUE):

  1. Teeth, each sclera eye, and any admitted eyelid band independently accept or abstain at the smallest anatomical unit without disabling eligible siblings or shipped face-agnostic effects.
  2. Every accepted edit is derived from immutable original canonical pixels under exactly one request-local mask owner, never from another effect's output.
  3. Hard anatomical envelopes remain authoritative after growth, blur, and feathering, and every pixel outside the final owned union stays byte-identical to the canonical source.
  4. An unexpected cross-provider overlap increments only an aggregate count and leaves the source pixel unchanged, with no priority rule or double edit.
  5. Fused disjoint output byte-matches standalone/merged oracles, and injected teeth, whole-sclera, left-eye, or right-eye failure leaves every unaffected result unchanged.

**Plans**: 5 plans

**Wave 0**

- [x] 55-01-PLAN.md — Freeze literal-byte composition/facade RED contracts and the fail-closed T-55 boundary checker.

**Wave 1** *(blocked on Wave 0 completion)*

- [x] 55-02-PLAN.md — Bind opaque request-local units to the exact canonical source and validate them with checked arithmetic.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 55-03-PLAN.md — Implement deterministic Q16 original-pixel composition, hard re-clipping, collision-to-source, and unit-local abstention.

**Wave 3**

- [x] 55-04-PLAN.md — Prove same-request facade adjacency through opaque Testing-only wiring while production admission remains empty.

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 55-05-PLAN.md — Run final-only regression/security gates, seal evidence, and synchronize contract-owner documents.

**Cross-cutting constraints:** exact-empty production admission; immutable current-request source ownership; OWASP ASVS Level 1 with every T-55 HIGH row blocking; aggregate-only digest-free observations; no candidate field/provider/renderer/preset/Demo/realtime/pixel-buffer route; full SwiftPM and Demo regression only in Wave 4.

### Phase 56: Independent Teeth Whitening Slice

**Goal**: An independently eligible `白牙` slice reaches the public facade with conservative tooth-only output, or remains unpromoted without affecting other candidates.
**Depends on**: Phase 55 and the teeth decision from Phase 54; no sclera or eyelid evidence is accepted
**Requirements**: TEETH-01, TEETH-02, TEETH-03, TEETH-04, TEETH-05, TEETH-06
**Success Criteria** (what must be TRUE):

  1. If and only if the teeth gate passes, an integrator receives an independent `teethWhitening` control that cannot alias global whitening, brightness, lip color, or geometry.
  2. Qualified support starts from actual mapped lip context, retains the conservative fixed strong baseline, and grows only connected color-qualified candidates inside a hard mouth-local envelope.
  3. Deterministic and rights-approved challenge cases show zero changes to lips, tongue, gums, braces, facial hair, skin, and all pixels outside the owned teeth mask.
  4. Genuine discoloration positives receive bounded yellow-excess and luminance improvement with natural texture, shading, edges, and color, while already-light, closed, occluded, unsupported, no-face, and unsafe cases abstain or remain natural.
  5. Public-facade output, strict saved-output evidence, original-detail review, privacy checks, regression tests, and the exact `白牙`/`嘴唇` ledger all reach the same independent promotion decision.

**Plans**: 3/3 plans executed

- [x] `56-01-PLAN.md` — Freeze SDK/facade/59-5-72 exact absence, the disabled Demo taxonomy, and the seven-row fail-closed checker/threat inventory.
- [x] `56-02-PLAN.md` — Enforce the immutable closed Phase 54 teeth row and complete production/API/Demo/ledger/privacy live mutations plus a draft evidence projection.
- [x] `56-03-PLAN.md` — Run final-only SwiftPM/Demo/security/traceability gates, seal closed-gate evidence, and synchronize owner documents.

**Cross-cutting constraints:** exact conditional false branch; TEETH-02..05 remain `not_applicable_closed_gate`; TEETH-06 is `no_promotion`; literal `.none`, 59/5/72, disabled `白牙`, `白牙 = future`, and `嘴唇 = partial` remain exact; OWASP ASVS Level 1 with all T-56 HIGH rows blocking; no browser, file selection, human image review, production teeth route, or full regression before `56-03-01`.

### Phase 57: Guarded Sclera Slice and Conditional Upper-Eyelid Work

**Goal**: `祛红血丝` qualifies through independent per-eye safety and evidence, while `去脂` is either separately proven as a non-warp effect or remains entirely absent and future.
**Depends on**: Phase 55 and the sclera/upper-eyelid decisions from Phase 54; does not depend on teeth qualification
**Requirements**: SCLERA-01, SCLERA-02, SCLERA-03, SCLERA-04, SCLERA-05, SCLERA-06, LID-02, LID-03, LID-04, LID-05
**Success Criteria** (what must be TRUE):

  1. If and only if its own gate passes, an integrator receives an independent `scleraRednessReduction` control that cannot alias whitening, brightness, eye geometry, or skin color.
  2. Each eye independently validates actual eye and pupil support, builds a hard guarded sclera envelope, scores redness only inside it, feathers, re-clips, and can fail without disabling an eligible peer eye.
  3. Color-independent geometry and color-adversarial final-output oracles both show zero changes to iris, pupil, highlights, lashes, skin, and outside-mask pixels across blink, gaze, eyewear, occlusion, and malformed-support challenges.
  4. Genuine redness positives receive bounded red-excess reduction with natural luminance and vessel/detail variation, while closed, occluded, unsupported, or unsafe eyes abstain without guessed or stale support; facade output, review, privacy, regression, and exact ledger evidence agree.
  5. A closed `去脂` gate leaves no `upperEyelidFullnessReduction` field, provider, renderer case, or inert route and keeps `去脂` future plus `眼睛` partial; an open gate must instead prove a distinct public-facade non-warp effect that preserves eye/brow geometry, aperture, crease, texture, and identity and rejects lift, smoothing, eye-bag, dark-circle, or warp substitutes.

**Plans**: 4/4 plans executed

- [x] 57-01-PLAN.md
- [x] 57-02-PLAN.md
- [x] 57-03-PLAN.md
- [x] 57-04-PLAN.md

**Wave 0**

- [x] `57-01-PLAN.md` — Freeze SDK/facade/59-5-72 exact absence, the two disabled Demo rows, proxy-domain preservation, and the eight-row fail-closed checker/threat inventory.

**Wave 1** *(blocked on Wave 0 completion)*

- [x] `57-02-PLAN.md` — Enforce the two immutable independent Phase 54 rows and complete the whole-production sclera activation/alias matrix with draft evidence.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] `57-03-PLAN.md` — Complete upper-eyelid canonical/synonym and LID-04 proxy rejection plus Demo/privacy/ledger/compatibility/evidence/scanner matrices.

**Wave 3** *(blocked on Wave 2 completion)*

- [x] `57-04-PLAN.md` — Run final-only SwiftPM/Demo/security/traceability gates, seal both closed projections, and synchronize requirement and root owners.

**Cross-cutting constraints:** two independent exact conditional false branches; SCLERA-02..05 and LID-03/LID-05 are `not_applicable_closed_gate`, SCLERA-06 is `no_promotion`, and LID-04 is affirmative `proxy_rejection_enforced`; literal `.none`, 59/5/72, both still facades, disabled `祛红血丝`/`去脂`, future/future/partial ledgers, and valid shipped eye/color domains remain exact; OWASP ASVS Level 1 with all T-57 HIGH rows blocking; no production feature route, browser/file/image/human review, or full SwiftPM/complete Demo regression before `57-04-01`.

### Phase 58: Combined Facade, Safety, Ledger, and Audit Closeout

**Goal**: The independently admitted v1.14 rows work together through the public facade and close with conservative privacy, compatibility, regression, ledger, and audit evidence.
**Depends on**: Phase 56 and Phase 57 admitted outcomes; a closed feature gate is a valid input to closeout
**Requirements**: SAFE-01, SAFE-02, SAFE-03, OUT-01, OUT-02, OUT-03, OUT-04
**Success Criteria** (what must be TRUE):

  1. Every admitted feature is exercised only through the public facade by isolated renderer cases, a bounded strict decoded-output helper, disposable ignored review artifacts, and original-detail inspection.
  2. Combined teeth and sclera requests preserve standalone/fused equivalence, collision-to-source behavior, shipped color/geometry output, and exact inventory/default compatibility.
  3. Repeated, parallel, canceled, no-face, missing-support, malformed-support, and mixed-feature requests retain no prior pixels, masks, landmarks, pupils, or vein-like detail and expose only allowlisted aggregate reason codes, counts, and timings.
  4. Local-retouch output preserves dimensions, canonical orientation/alpha/color contracts, safe-domain continuation, typed errors, and deterministic no-op behavior.
  5. Full SwiftPM and opt-in Vision integration, privacy/resource/network scans, adversarial safety, owner checks, and independent verification pass before ledgers promote exactly the qualified rows; `嘴唇` closes only with qualified `白牙`, `眼睛` closes only with both qualified eye rows, and no Demo, realtime, tracked-media, device, commercial, performance-budget, packaging, shipping, or launch claim is inferred.

**Plans**: 4/4 executed

- [x] 58-01-PLAN.md
- [x] 58-02-PLAN.md
- [x] 58-03-PLAN.md
- [x] 58-04-PLAN.md

**Wave 0**

- [x] `58-01-PLAN.md` — Freeze focused zero-admission SDK/Demo specifications and establish the exact eight-row fail-closed audit boundary.

**Wave 1** *(blocked on Wave 0 completion)*

- [x] `58-02-PLAN.md` — Complete request-lifetime, privacy, compatibility, output-absence, and zero-promotion real-fixture matrices.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] `58-03-PLAN.md` — Audit the frozen Phase 57 pretransition/current lifecycle and complete all HIGH/evidence/owner mutation modes.

**Wave 3** *(blocked on Wave 2 completion)*

- [x] `58-04-PLAN.md` — Run final-only full SwiftPM, exact six-test opt-in Vision, full Demo, checker/GSD/owner gates, and seal execution evidence for external review/verifier.

**Cross-cutting constraints:** the admitted and promoted visible sets are exactly empty; OUT-01/OUT-02 use explicit not-applicable exact-absence dispositions; literal `.none`, 59/5/72, both CIImage facades, feature-neutral Phase 55 mechanics, three disabled Demo rows, future/future/future, partial/partial, and the frozen Phase 57 519-case checker remain exact; OWASP ASVS Level 1 with all T-58 HIGH rows blocking; no production feature route, browser/file/image/human review, TD-013, release claim, or full SwiftPM/opt-in Vision/complete Demo scope expansion is inferred; automated closeout, adversarial code review/fix, and independent verification pass, while the separate milestone audit remains the final lifecycle gate.

## Coverage

All 41 v1.14 requirements map to exactly one phase: 41 mapped, 0 duplicated, 0 unmapped.

| Phase | Requirement count |
| --- | ---: |
| 53. Canonical Still-Image Contract and Private Request Foundation | 7 |
| 54. Rights-Approved Evidence and Eligibility Decisions | 6 |
| 55. Original-Pixel Composition and Failure-Isolation Core | 5 |
| 56. Independent Teeth Whitening Slice | 6 |
| 57. Guarded Sclera Slice and Conditional Upper-Eyelid Work | 10 |
| 58. Combined Facade, Safety, Ledger, and Audit Closeout | 7 |

## Progress

**Execution Order:** Phase 53 → Phase 54 → Phase 55 → Phase 56 → Phase 57 → Phase 58. Teeth and sclera remain independent peer gates even though their recorded execution phases are sequential; neither can borrow the other's evidence. Rights acquisition may begin early, but visible implementation is admitted only after Phase 54 records a passing feature gate.

| Phase | Plans Complete | Status | Completed |
| --- | --- | --- | --- |
| 53. Canonical Still-Image Contract and Private Request Foundation | 6/6 | Complete    | 2026-07-31 |
| 54. Rights-Approved Evidence and Eligibility Decisions | 5/5 | Complete    | 2026-08-03 |
| 55. Original-Pixel Composition and Failure-Isolation Core | 5/5 | Complete    | 2026-08-03 |
| 56. Independent Teeth Whitening Slice | 3/3 | Complete    | 2026-08-04 |
| 57. Guarded Sclera Slice and Conditional Upper-Eyelid Work | 4/4 | Complete    | 2026-08-04 |
| 58. Combined Facade, Safety, Ledger, and Audit Closeout | 4/4 | Complete    | 2026-08-05 |

## Backlog

- v1.15: approved local semantic masking plus `发际线`.
- v1.16: `去双下巴`, `去双下巴 Pro`, and narrow facial-feature closeout.
- `比例` and `3D塑颜` remain outside the narrow facial-feature sequence.
- SwiftUI/Demo UI, realtime/pixel-buffer local retouch, transparent/HDR/gain-map input, external models or cloud processing, tracked fixture/output media, physical-device parity, commercial visual approval, optimized profiling, packaging, shipping, and launch-readiness evidence remain separately scoped.

---
*Last updated: 2026-07-30 after creating the v1.14 execution roadmap*
