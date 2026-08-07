# Phase 61: Teeth Output, Safety, and Independent Closeout - Context

**Gathered:** 2026-08-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Prove the Phase 60 teeth-whitening implementation through saved images produced only by the public still-image facade, close the remaining protected-tissue and original-detail review gates, and promote exactly `白牙` plus its now-complete `嘴唇` product branch. This phase may extend the command-line example renderer and disposable local evidence tooling, but it does not add public parameters, alter the provider algorithm, enable the Demo, add models or network behavior, or begin sclera/upper-eyelid production work.

</domain>

<decisions>
## Implementation Decisions

### Public output matrix
- **D-01:** Add exactly one isolated renderer case, `teethWhitening_1p00`, using only `BeautyParameters(teethWhitening: 1)` through the existing public `BeautySDK` facade. Reuse `geometryBaseline_noop` as the comparator; do not add lower-strength variants or a teeth-specific rendering path.
- **D-02:** The renderer inventory advances from exactly 72 to exactly 73 cases. Existing case IDs, the 60-field contract, five presets, one canonical still-image pass, and every non-teeth result remain unchanged.
- **D-03:** The strict Phase 61 matrix renders only the baseline and teeth case for three roles: one rights-approved discoloration positive, one rights-approved already-light negative, and one separate no-face input. It therefore expects exactly six decoded PNG outputs, not a broad rerender of every existing case.
- **D-04:** A private runner may discover and stage the authorized originals into a temporary opaque input root, but paths, media, fixture metadata, hashes, support, geometry, and pixels must never become tracked or staged. Generated output and review media remain ignored and disposable.

### Strict decoded acceptance
- **D-05:** Freeze the strict helper and its self-tests before accepting live output. It must decode all six files, enforce exact inventory and regular-file containment, and reject duplicates, stale files, symlinks, scope escapes, malformed images, and dimension/alpha changes.
- **D-06:** The genuine positive must show nonzero tooth-local change, lower yellow excess, a small positive luminance delta, bounded channel movement, preserved texture, and zero reviewed-mask exterior changes. The already-light negative and no-face case must remain within tight no-op/natural bounds.
- **D-07:** Public-output acceptance may reuse the reviewed mask only as a private evaluation oracle. Runtime ownership continues to come exclusively from the Phase 60 production provider; no Testing-only mask, composition hook, or observation may activate, suppress, or alter output.
- **D-08:** Decoded output metrics corroborate the already-open evidence decision; they do not replace Phase 54/59 evidence authority and never become an admission predicate.

### Adversarial protected-tissue safety
- **D-09:** Add a color-independent geometry perturbation oracle that varies accepted lip support while retaining unperturbed protected truth for lips, tongue, gums, braces, facial hair, skin, and aperture exterior. Any accepted candidate overlap with protected truth fails the phase.
- **D-10:** Add a recolored-protected final-output oracle that exercises the real score, growth, feather, hard re-clip, transform, and one-owner composition path. Every protected and outside pixel must remain byte-identical, including alpha.
- **D-11:** Keep deterministic challenge fixtures separate from product naturalness evidence. They prove safety and recovery behavior only and retain zero product/evidence weight.
- **D-12:** Malformed, partial, stale, implausible, absent, and unsafe lip support must fail locally; safe unrelated color work must continue, and no failure may trigger guessing, cached support, a second detector request, or a second composition owner.

### Original-detail review
- **D-13:** Generate a blinded local review set from fresh production-facade output after numeric gates are frozen. The executing agent must open the genuine positive and negative original/baseline/after views at original detail and compare tooth locality, visible improvement, enamel texture, shading, edge quality, and protected tissue.
- **D-14:** The positive must visibly reduce discoloration without a porcelain-flat or blue/gray result. The already-light negative must remain natural and nearly unchanged. A contradictory visual observation blocks closeout even if numeric checks pass.
- **D-15:** Durable review evidence contains only opaque roles, fixed categorical judgments, pass/fail decisions, and aggregates. It contains no local path, media, reviewer identity, free-form prose, rights detail, hashes, landmarks, masks, or pixel data.
- **D-16:** The user's earlier acceptance of the calibrated candidate is relevant prior evidence, but Phase 61 still performs a fresh review of the production-facade result; no post-review tuning is allowed without regenerating and repeating every affected gate.

### Atomic promotion and sequencing
- **D-17:** The Phase 61 checker has two fail-closed modes. Default pre-promotion mode requires `白牙` to remain future and `嘴唇` partial. Post-promotion mode requires every Phase 61 artifact complete and permits only the exact intended owner changes.
- **D-18:** Before promotion, require nonzero focused provider/transform/facade tests, strict helper self-test and fresh live run, private genuine-pair verification, both adversarial oracles, original-detail review, compatibility/privacy/active-source checks, full SwiftPM and Demo regressions, standard review/fix, security review with all HIGH threats closed, and diff/artifact hygiene.
- **D-19:** Promotion is one atomic product-evidence transaction: mark exactly `白牙` implemented and change the `嘴唇` branch from partial to implemented because all its child rows are then implemented. Cite the Phase 59 evidence/admission, Phase 60 provider/integration, and Phase 61 output/safety/verification chain.
- **D-20:** Preserve `祛红血丝` and `去脂` as future/disabled and keep `眼睛` partial. Product-ledger promotion does not authorize a Demo control, realtime/pixel-buffer path, model/resource, public alias, or new rendering pass.
- **D-21:** Phase 62 cannot begin until a fresh independent post-promotion verification confirms TEETH-15 and TEETH-16, exact product-owner agreement, zero open HIGH threats, no privacy/artifact leak, and no borrowed or conditional evidence.

### the agent's Discretion
Exact helper decomposition, temporary opaque fixture names, challenge pixel layouts, blinded review layout, fixed metric thresholds within the already-accepted Phase 60 bounds, and the smallest table-driven XCTest organization may follow established repository patterns. These choices may not weaken any exact count, zero-leakage, evidence-authority, privacy, or sequencing decision above.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Scope and requirements
- `.planning/ROADMAP.md` — Phase 61 goal, success criteria, dependency on Phase 60, and Phase 62 sequencing gate.
- `.planning/REQUIREMENTS.md` — TEETH-15 and TEETH-16 plus the preserved sclera and shared safety boundaries.
- `.planning/PROJECT.md` — current milestone scope and product constraints.

### Upstream teeth authority
- `.planning/phases/59-teeth-evidence-and-admission-contract/59-CONTEXT.md` — exact-open evidence decision, privacy, and one-demand boundaries.
- `.planning/phases/59-teeth-evidence-and-admission-contract/59-VERIFICATION.md` — canonical evidence/admission verification.
- `.planning/phases/59-teeth-evidence-and-admission-contract/59-private-evidence-runner.js` — private ignored-bundle discovery and fixed-output execution pattern.
- `.planning/phases/60-teeth-provider-and-production-integration/60-CONTEXT.md` — locked provider, transform, production-path, and genuine-pair decisions.
- `.planning/phases/60-teeth-provider-and-production-integration/60-VERIFICATION.md` — completed provider/integration/security/regression evidence.
- `.planning/phases/60-teeth-provider-and-production-integration/60-SECURITY.md` — Phase 60 threat boundaries that Phase 61 must retain.

### Validated implementation findings
- `.codex/skills/spike-findings-beauty/references/teeth-whitening.md` — mask construction, fixed baseline, adaptive growth, post-filter clipping, and bounded color transform.
- `.codex/skills/spike-findings-beauty/references/still-image-integration.md` — one canonical request, request-local support, one composition owner, and immutable-original rules.
- `.codex/skills/spike-findings-beauty/references/licensed-fixture-evaluation.md` — rights-approved fixture and privacy-safe evaluation requirements.

### Current implementation and tests
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` — public still-image production route.
- `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyTeethWhiteningProvider.swift` — bounded mask provider.
- `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyTeethWhiteningTransform.swift` — immutable-source transform.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — existing 72-case public-facade renderer.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` — exact renderer inventory and facade-boundary tests.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTeethWhiteningIntegrationTests.swift` — production activation, abstention, and isolation tests.
- `BeautySDK/Tests/BeautyCoreTests/BeautyTeethWhiteningRealFixtureTests.swift` — private genuine-pair decoded measurements.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyTeethWhiteningProviderTests.swift` — provider and protected-region unit tests.

### Output and promotion precedents
- `.planning/milestones/v1.13-phases/51-public-facade-eyebrow-output-evidence/51-CONTEXT.md` — strict saved-output and original-detail review pattern.
- `.planning/milestones/v1.13-phases/51-public-facade-eyebrow-output-evidence/51-VALIDATION.md` — decoded-output, inventory, gallery, and review gates.
- `.planning/milestones/v1.12-phases/48-face-safety-and-scoped-closeout/48-CONTEXT.md` — fail-closed pre/post-promotion checker and atomic owner-update pattern.

### Product owners
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` — canonical `嘴唇` / `白牙` status owner.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` — aggregate feature status owner.
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` — beauty-shaping branch summary.
- `docs/meitu-function-blueprint/features/beauty-shaping/lips/README.md` — lips branch capability detail.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyExampleRenderer`: already enumerates flat case IDs, accepts `--case`, loads image files recursively, calls one public `BeautyEngine.processResult`, and writes deterministic PNG names.
- `BeautyRendererOutputRegressionTests`: already parses renderer source, freezes exact case inventory, rejects candidate aliases/internal bypasses, and validates output dimensions.
- `BeautyTeethWhiteningRealFixtureTests`: already canonicalizes private originals, invokes the public engine, decodes RGBA8 output, and measures target improvement, outside-mask change, alpha, channel bounds, and texture.
- Phase 59 private runner: already discovers the ignored authorized bundle without exposing its location and emits fixed child status.
- Historical strict Python helpers/gallery tooling: provide bounded decoder, self-test, exact inventory, containment, and disposable publication patterns.

### Established Patterns
- Freeze contracts and helper self-tests before live measurement; calibration and strict acceptance are separate runs.
- Generated media is ignored and disposable; durable evidence is textual, aggregate, bounded, and privacy-safe.
- Safety oracles and mechanics cannot contribute to product naturalness/admission.
- Product owners remain read-only until all pre-promotion gates pass, then change atomically and undergo a separate post-promotion verification.
- The `.planning/codebase` maps are stale as of 2026-06-10; current code, tests, root contracts, and Phase 59/60 records are authoritative.

### Integration Points
- Add the one renderer case beside existing isolated cases and update the exact case array/tests from 72 to 73.
- Extend Phase 60 genuine-pair support or add Phase 61-owned private output tooling without exposing a private path to tracked code or output.
- Add Phase 61 XCTest safety matrices alongside current provider/integration suites.
- Add a Phase 61 fail-closed checker and verification/security artifacts before touching the four product owner documents.

</code_context>

<specifics>
## Specific Ideas

- The user expects the agent to run the written implementation itself and compare the generated images, not ask for another manual fixture review.
- The accepted calibration is yellow-neutralization factor `1.45` with the Phase 60 luminance target unchanged; Phase 61 validates that production result rather than reopening subjective tuning by default.
- The authorized local positive is visibly discolored and the negative is already light; they need not depict the same person because polarity and product behavior, not identity matching, are the evidence contract.

</specifics>

<deferred>
## Deferred Ideas

- Demo control/mapping for teeth whitening remains deferred beyond this SDK-core closeout.
- Sclera evidence/admission starts in Phase 62 only after this phase is canonically complete.
- Sclera production and output belong to Phases 63–64; upper-eyelid fullness reduction remains absent.

</deferred>

---

*Phase: 61-teeth-output-safety-and-independent-closeout*
*Context gathered: 2026-08-07*
