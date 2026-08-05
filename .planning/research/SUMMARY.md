# Project Research Summary

**Project:** Beauty
**Domain:** Local-first iOS still-image teeth whitening and sclera redness reduction
**Researched:** 2026-08-05
**Confidence:** HIGH for architecture/safety; MEDIUM for calibration pending genuine evidence
**Execution note:** Completed inline because this Codex session exposed no GSD subagent dispatch tool; no typed researcher/synthesizer guarantees were available.

## Executive Summary

v1.15 should add no new dependency, model, detector request, image normalization path, or composition engine. The technically sound path is to activate the v1.14 foundation in two strictly serial, independently qualified slices: complete `白牙` evidence and production behavior first, close its public-output/safety/promotion gates, then repeat the same lifecycle for per-eye `祛红血丝`. Apple Vision lip, eye, and pupil landmarks are coarse request-local support, not semantic masks; each provider must conservatively derive its own target candidates inside hard anatomical envelopes.

The dominant risk is not implementing a color formula. It is promoting from insufficient real evidence or allowing protected-region leakage that ordinary image colors hide. `portrait_002` is useful candidate context but does not open either gate. Each feature still needs a genuine positive and negative with complete original/mask/after assets, predeclared polarity, frozen structured original-detail review, and an independent decision. Teeth must protect lip, gum, tongue, braces, hair, skin, texture, and already-light negatives. Sclera must fail independently per eye and prove iris/pupil/highlight/lash/skin safety with both color-independent and recolored-iris final-output oracles.

The roadmap should therefore be evidence-first and serial: teeth evidence → teeth implementation → teeth output/safety/promotion → sclera evidence → sclera implementation → sclera output/safety/promotion → combined closeout. `去脂`, Demo activation, realtime/pixel-buffer, external model/cloud, tracked portrait media, device/commercial/performance-budget/packaging/shipping/launch work remain outside v1.15.

## Key Findings

### Recommended Stack

Keep the current Swift/SwiftPM package and existing Apple Vision/Core Image path. Reuse one canonical explicit-sRGB RGBA8 image, one selected-face landmark request, actual request-local lip/eye/pupil support, and the v1.14 immutable-original composition owner. Add deterministic feature-specific providers and bounded color transforms in `BeautyEffects`, append public fields in `BeautyCore` only after their own gates pass, and verify via existing XCTest, boundary checkers, local ignored review tooling, and `BeautyExampleRenderer`.

**Core technologies:**

- Swift/SwiftPM — existing public contracts, providers, deterministic transforms, and tests.
- Apple Vision — one request supplying optional lip, eye-contour, and pupil support; no second request or beta-revision migration.
- Core Image — existing reused context and explicit-sRGB canonical/output ownership.
- v1.14 local-retouch composer — immutable source, hard containment, local abstention, and collision-to-source behavior.

### Expected Features

**Must have:**

- Independent rights-approved positive/negative evidence and promotion authority per feature.
- Independent positive-only zero-default public fields with source/Codable/preset compatibility.
- Conservative target mask, hard post-filter containment, bounded source-derived color transform, and natural no-op behavior.
- Teeth protected-tissue safety and sclera per-eye protected-region/adversarial safety.
- Isolated public-facade saved output, original-detail review, full regression, privacy, and exact ledger promotion.
- Combined requests that preserve standalone equivalence and source pixels on unexpected overlap.

**Should have:**

- Side-tooth adaptive connected growth without dropping the fixed strong baseline.
- Independent left/right eye failure and recovery.
- Aggregate-only reason/timing/count diagnostics and complete request nonretention.

**Defer:**

- `去脂`, learned segmentation, Demo activation, realtime/pixel-buffer, transparent/HDR/multi-face expansion, device optimization, and release claims.

### Architecture Approach

Public intent enters the existing still-image facade, which canonicalizes once and maps one selected face. A teeth provider or two independent sclera-eye units consume only that request context, create hard-clipped ephemeral proposals, and send source-bound edits to the existing composer. The composer is the only owner of overlap and final source-derived blending. Rendering/public reconstruction remains existing infrastructure. Evidence tooling is an offline admission authority and never becomes a runtime dependency.

**Major components:**

1. Feature-specific evidence decision — grants, media completeness, polarity, structured review, and exact admission outcome.
2. Public field + admission — append-only compatibility and exact nonzero private demand.
3. Request-local provider + bounded transform — tooth unit or independent eye units.
4. Existing composition/facade output — one immutable source, one owner per pixel, aggregate-only summary.
5. Standalone and combined verification — protected regions, naturalness, lifecycle, privacy, compatibility, and ledger equality.

### Critical Pitfalls

1. **Candidate status mistaken for product evidence** — require complete feature-specific positive/negative bundles before any production route.
2. **Vision polygon mistaken for target segmentation** — use support only, then derive conservative candidates and re-clip after filtering.
3. **Native colors hide sclera leakage** — require color-independent geometry and recolored-iris final-output oracles.
4. **Weak strength hides a bad mask** — prove containment at maximum admitted strength independently of transform tuning.
5. **Teeth and sclera become coupled** — keep separate fields, evidence, providers, failure units, output cases, and promotion decisions.
6. **Private mechanics mistaken for a completed product** — public facade, saved output, human review, regression, and ledgers all must agree.

## Implications for Roadmap

### Suggested Phase 59: Teeth Evidence and Admission Contract

**Rationale:** Production cannot begin until candidate inputs become a complete rights-approved positive/negative bundle and an exact decision.
**Delivers:** Frozen review criteria; complete teeth bundle; teeth-only decision; public/compatibility RED contracts; no sclera or `去脂` route.
**Avoids:** Candidate-as-proof and evidence borrowing.

### Suggested Phase 60: Teeth Provider and Production Integration

**Rationale:** Mask selection must be separable from the color transform and facade wiring.
**Delivers:** Positive-only field, exact admission, lip-supported fixed+adaptive provider, hard mouth containment, bounded immutable-original transform, local abstention.
**Avoids:** Whole-aperture whitening, global brightness, protected-tissue leakage, and Testing-only behavior.

### Suggested Phase 61: Teeth Output, Safety, and Promotion

**Rationale:** Internal mechanics do not complete an SDK feature.
**Delivers:** Isolated public-facade renderer/decoder evidence, protected-tissue and negative/challenge matrix, original-detail review, full regression, exact `白牙` promotion and mouth-branch disposition.
**Avoids:** Over-whitening and premature ledger activation.

### Suggested Phase 62: Sclera Evidence and Admission Contract

**Rationale:** Sclera starts only after teeth closes and requires independent positive/negative evidence.
**Delivers:** Complete sclera bundle, per-eye review criteria, exact sclera decision, public/compatibility RED contracts; no reuse of teeth proof.
**Avoids:** Coupled qualification and weak-positive claims.

### Suggested Phase 63: Guarded Per-Eye Sclera Production Integration

**Rationale:** Eye safety depends on support validation before color scoring and local side failure.
**Delivers:** Positive-only field, exact admission, independent eye units, guarded iris/highlight exclusions, redness score, feather + hard re-clip, bounded immutable-original transform.
**Avoids:** Whole-eye whitening, guessed pupils, cross-eye repair, and blur leakage.

### Suggested Phase 64: Sclera Output, Adversarial Safety, and Promotion

**Rationale:** Native-color output alone cannot prove iris/highlight safety.
**Delivers:** Public-facade renderer/decoder evidence, geometry-open and recolored-iris grids, blink/gaze/glasses/highlight challenges, original-detail review, full regression, exact `祛红血丝` promotion and honest eye-branch partial disposition because `去脂` remains future.
**Avoids:** Hidden protected leakage and false eye-branch closure.

### Suggested Phase 65: Combined Facade, Privacy, and Milestone Closeout

**Rationale:** Two standalone features must coexist without sharing state, output order, evidence, or failure.
**Delivers:** Standalone/fused equivalence, overlap-to-source, injected mouth/left-eye/right-eye failures, repeated/parallel/reset isolation, compatibility, Demo-disabled honesty, owner-ledger equality, full regression, independent verification, and milestone audit readiness.
**Avoids:** Cross-feature coupling, stale masks, and broad release claims.

### Phase Ordering Rationale

- Evidence precedes production for each feature.
- Teeth completes before sclera production begins, matching the user's requested one-by-one execution.
- Each feature receives a separate implementation phase and a separate output/safety/promotion phase.
- Combined work is last and cannot substitute for standalone evidence.
- Continued numbering starts at Phase 59 because v1.14 ended at Phase 58.

### Research Flags

Phases likely needing deeper phase research:

- **Phase 59:** Determine whether available local assets truly satisfy genuine teeth-positive and negative polarity, and freeze bounded naturalness criteria before outputs are reviewed.
- **Phase 62:** Determine whether available local assets truly satisfy genuine sclera-redness and normal-sclera polarity per eye; calibrate conservative guard seeds without treating them as constants.
- **Phase 64:** Specify the exact adversarial eye matrix and useful-coverage acceptance on rights-approved real inputs.

Phases with established patterns:

- **Phases 60 and 63:** Local spike blueprints and v1.14 architecture define the provider/composer ordering; phase planning should focus on production seams and tests.
- **Phase 65:** Existing v1.14 composition, lifecycle, privacy, compatibility, and audit patterns are reusable.

## Confidence Assessment

| Area | Confidence | Notes |
| --- | --- | --- |
| Stack | HIGH | Existing frameworks and package seams already compile and passed v1.14 verification; no new dependency is needed. |
| Features | HIGH for required contracts; MEDIUM for thresholds | User scope is explicit and research supports separate evidence, containment, and naturalness. |
| Architecture | HIGH | v1.14 implemented and audited the exact canonical/request/composition foundation. |
| Pitfalls | HIGH | Most failure modes were observed in local spikes or are stated by official Vision behavior. |

**Overall confidence:** HIGH for roadmap shape; MEDIUM for eventual product qualification until genuine positive/negative review passes.

### Gaps to Address

- **Teeth bundle completeness:** `portrait_002` is candidate-only; confirm genuine discoloration polarity, an already-light negative, complete mask/after assets, and structured review.
- **Sclera bundle completeness:** confirm genuine redness per eye and a normal negative; candidate visibility is not a decision.
- **Calibration:** adaptive teeth thresholds and sclera `0.30 / 0.14` guard values remain spike seeds, not production constants.
- **Naturalness:** define bounded color/texture/detail criteria before viewing candidate after-images.
- **Device performance:** deliberately deferred; do not convert macOS or test-harness timings into an iOS budget claim.

## Sources

### Primary

- [Apple: VNDetectFaceLandmarksRequest](https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest) — face-landmark request ownership and revisions.
- [Apple: innerLips](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/innerlips) — lip aperture support semantics.
- [Apple: rightPupil](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/rightpupil) — blink inaccuracy warning.
- [Apple: CIContext](https://developer.apple.com/documentation/coreimage/cicontext) — color management and context reuse.
- [Application of digital imaging in tooth whitening randomized controlled trials](https://pubmed.ncbi.nlm.nih.gov/19681252/) — repeatable L*, a*, b* digital tooth-color assessment.
- [Development of a customized whiteness index for dentistry](https://pubmed.ncbi.nlm.nih.gov/26778404/) — perception-oriented whiteness measurement.
- [A New Scale for the Assessment of Conjunctival Bulbar Redness](https://pmc.ncbi.nlm.nih.gov/articles/PMC6574084/) — digital region-specific redness grading.
- [Shape Constrained Network for Eye Segmentation in the Wild](https://openaccess.thecvf.com/content_WACV_2020/papers/Luo_Shape_Constrained_Network_for_Eye_Segmentation_in_the_Wild_WACV_2020_paper.pdf) — sclera/iris segmentation difficulty in unconstrained images.
- [On the use of multispectral conjunctival vasculature as a soft biometric](https://www.cse.msu.edu/~rossarun/pubs/CrihalmeanuRossMSConjunctiva_WACV2011.pdf) — privacy sensitivity of conjunctival vasculature.

### Repository Authority

- `.planning/milestones/v1.14-MILESTONE-AUDIT.md`
- `.planning/milestones/v1.14-REQUIREMENTS.md`
- `.codex/skills/spike-findings-beauty/`
- Root `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, and `PRODUCT_SENSE.md`

---
*Research completed: 2026-08-05*
*Ready for roadmap: yes*
