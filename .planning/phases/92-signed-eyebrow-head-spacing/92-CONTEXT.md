# Phase 92: Signed Eyebrow-Head Spacing - Context

**Gathered:** 2026-09-06
**Status:** Owner-authorized repair reopened (2026-09-08)

## Owner repair decision — 2026-09-08

After the terminal second-attempt failure and exact production rollback, the
owner explicitly selected `repair`. This supersedes D-18's old implementation
ceiling for Phase 92 and authorizes a newly scoped, independently checked repair
cycle. Prior failure summaries remain unchanged. All other decisions, including
the generic 4.5%-face-width radius ceiling and the frozen actual-pixel thresholds,
remain acceptance requirements. The new cycle records implementation iterations
and evidence without requiring a repeat authorization for routine in-scope fixes.

<domain>
## Phase Boundary

Repair the owner-local `eyebrowHeadSpacing` control so its two documented signs move only the two inner eyebrow-head neighborhoods in opposite measurable directions, preserve outer brow anchors and all non-brow protected regions, and remain observably distinct from whole-brow `eyebrowSpacing`. The phase changes neither the public parameter surface nor unrelated eyebrow controls, adds no application/UI surface, and does not perform the live owner-portrait or milestone-wide closeout owned by Phase 95.

</domain>

<decisions>
## Implementation Decisions

### Signed Direction and Side Eligibility
- **D-01:** Preserve the frozen public sign semantics from Phase 89: positive `eyebrowHeadSpacing` increases the distance between the two inner brow heads, while negative values decrease it.
- **D-02:** Each eligible side moves along its own canonical inner-to-outer eyebrow axis. Positive motion follows that axis away from the facial midline; negative motion reverses it toward the midline.
- **D-03:** Preserve the established per-side eligibility contract for this control. A valid eyebrow may emit head-spacing geometry when its peer is missing or invalid; the provider must not fabricate, mirror, or borrow peer geometry.
- **D-04:** When both sides are eligible, effectiveness evidence must observe the intended bilateral head-gap change. A one-sided or invalid-peer safety case proves local survivability, not the bilateral effectiveness requirement.
- **D-05:** Preserve the existing exact dead zone at `Float.ulpOfOne`, the public magnitude cap of `0.25`, request-local observations, and fail-closed behavior. This phase may repair effective motion inside that contract but must not widen it.

### Local Influence and Outer-Anchor Protection
- **D-06:** Keep the implementation repair inside the narrow `EyebrowWarpProvider.headSpacingPoints` seam, or a private helper owned by that seam. Do not change `Warp.metal`, the shared backend, the public parameters, or the behavior of whole-brow spacing and the other five eyebrow controls.
- **D-07:** Influence must remain centered on the independently observed inner endpoint and only the limited adjacent carriers needed for a stable local deformation. Motion and radius/support must taper before the outer-anchor regions rather than translating the whole trace.
- **D-08:** The exact Phase 89 outer-anchor and non-brow protection limits are immutable acceptance contracts: each outer-anchor region permits at most 64 changed pixels and 256 total RGB delta; eye regions use the same limits; background and watermark regions permit zero change and zero delta.
- **D-09:** Research and planning may choose the exact private displacement scale, taper, number of adjacent carrier points, and anatomy-bounded radius. Those choices must make both signs clear at the frozen thresholds without weakening thresholds or globally expanding support.

### Effectiveness Evidence and Semantic Distinction
- **D-10:** Use the exact Phase 89 frozen cases `eyebrowHeadSpacing_plus0p25` and `eyebrowHeadSpacing_minus0p25` as the end-to-end acceptance oracle. Do not rename the cases, alter their parameters, or lower their thresholds.
- **D-11:** Each case must begin with real target signal in the source and neutral render, then satisfy at least 500 changed target pixels, 2,000 total target RGB delta, and the signed `innerBrowHeadGap` Q16 threshold of magnitude 16 in the documented direction.
- **D-12:** Both signs must be tested from actual rendered pixels and metadata, using deterministic generated 512×512 explicit-sRGB RGBA8 input rather than provider-coordinate assertions alone.
- **D-13:** Each candidate must remain measurably distinct from its opposite-sign sibling and from both whole-brow `eyebrowSpacing` siblings. A repair that merely reproduces whole-brow spacing does not satisfy BROW-01.
- **D-14:** Retain the existing independently declared dark-centroid `innerBrowHeadGap` metric and protected-region comparator as the default proof path. Unlike the retired eye-pixel pupil proxy, this metric directly measures the independently declared brow-head markers in the generated oracle.
- **D-15:** Do not add a renderer report schema or new semantic aggregate by default. Research may recommend one only if it demonstrates a concrete production-output binding gap that the current actual-pixel oracle cannot close; any such addition must stay fixed-size, aggregate-only, and independently asserted.

### Failure Recovery, Privacy, and Closeout
- **D-16:** Retain or add focused coverage for neutral identity, exact dead zone, no face, missing/stale/reused/malformed support, missing or invalid individual sides, provider-empty behavior, valid-invalid-valid lifecycle recovery, determinism, and package-host execution.
- **D-17:** Persist only counts, bounded deltas, pass/fail facts, and other fixed aggregate evidence. Never persist raw pixels, masks, eyebrow coordinates, private fixture locators, generated images, renderer reports, or child-agent transcripts.
- **D-18:** Phase 92 gets one research pass, one independently checked plan, and at most two implementation attempts shared across all plans and summaries. A second failed implementation attempt ends in an explicit owner decision rather than silent threshold drift or a third attempt.
- **D-19:** Phase 92 closeout is the focused generated/package-host BROW-01 gate plus relevant SwiftPM safety tests and SDK-owned boundary checks. Live owner-controlled portraits and the milestone-wide no-skip closeout remain Phase 95 work.
- **D-20:** Passing this phase supports only the owner-local generated-fixture contract. It does not establish real-device performance, portrait quality, commercial visual quality, packaging, shipping, launch, external distribution, or release readiness.

### the agent's Discretion
- The private local-warp math inside the locked provider seam: displacement curve, carrier taper, bounded radius, and internal helper naming.
- The smallest focused SwiftPM test organization and generated-fixture construction needed to prove the locked contracts without adding production API surface.
- Whether a fixed aggregate report bridge is genuinely necessary after research; the default is to avoid one because the current brow metric is independently declared and pixel-derived.
- Exact ordering of focused tests and SDK-owned scripts, provided the Phase 89 manifest remains the final end-to-end BROW-01 authority.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone Scope and Requirement
- `.planning/ROADMAP.md` § Phase 92 — phase goal, dependency, success criteria, and BROW-01 ownership.
- `.planning/REQUIREMENTS.md` § BROW-01 — traceable signed eyebrow-head-spacing requirement.
- `.planning/PROJECT.md` — v1.22 owner-local milestone boundaries, non-goals, and attempt policy.
- `PLANS.md` — active planning record, repository constraints, and technical-debt routing.

### Frozen Semantic Oracle
- `.planning/phases/89-semantic-validation-baseline/89-VERIFICATION.md` — verified frozen baseline and exact-case acceptance authority.
- `scripts/face-feature-batch-manifest.json` — exact Phase 92 cases, target/protected regions, signed metric, sibling comparisons, and immutable thresholds.
- `scripts/compare-face-feature-batches.swift` — current actual-pixel comparator and `innerBrowHeadGap` implementation.
- `scripts/run-face-feature-batches.sh` — package-host batch orchestration and durable evidence boundaries.
- `scripts/test-face-feature-batch-boundaries.py` — manifest, comparator, fault-injection, and cleanup contract tests.
- `.planning/phases/91-independent-gaze-correction/91-CONTEXT.md` — immediately preceding repair pattern, evidence independence rules, nonclaims, and Phase 95 handoff boundary.

### Current Eyebrow Implementation and Tests
- `BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift` — seven eyebrow field emitters, existing local head-spacing seam, and whole-brow sibling behavior.
- `BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift` — current cap, support, per-side, safety, and lifecycle coverage.
- `BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift` — deterministic eyebrow geometry and safety fixtures.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` — unified geometry integration point that must remain unchanged unless a proven private integration gap exists.
- `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceGeometryOracleTests.swift` — actual geometry-pass pixel oracle patterns.
- `BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift` — package-host CLI contract and renderer process coverage.

### Established Eyebrow Contracts
- `.planning/milestones/v1.13-phases/49-public-contract-and-observed-eyebrow-support/49-CONTEXT.md` — seven-field public contract and request-local observed trace requirements.
- `.planning/milestones/v1.13-phases/50-independent-eyebrow-geometry-and-pipeline-integration/50-CONTEXT.md` — inner-head-only semantics, per-side eligibility, and no-alias/no-synthetic constraints.
- `.planning/milestones/v1.13-phases/52-eyebrow-safety-and-branch-closeout/52-VERIFICATION.md` — verified cap, dead-zone, safety, lifecycle, and branch-closeout history.

### Repository Owners and Taxonomy
- `ARCHITECTURE.md` — SwiftPM target boundaries and dependency direction.
- `DESIGN.md` — parameter, render-state, geometry, and lifecycle contracts.
- `PRODUCT_SENSE.md` — owner-local SDK journey and public behavior language.
- `SECURITY.md` — input, fixture, privacy, resource, and durable-evidence trust boundaries.
- `RELIABILITY.md` — typed failure, logging, recovery, determinism, and performance boundaries.
- `QUALITY_SCORE.md` — SwiftPM and SDK-owned quality-gate expectations.
- `docs/SDK_EFFECT_TAXONOMY.md` — current effect/control status authority.
- `.codex/skills/spike-findings-beauty/SKILL.md` — mandatory local-retouch/privacy/fixture workflow constraints.
- `.codex/skills/spike-findings-beauty/references/still-image-integration.md` — generated fixture and result-level verification guidance.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `EyebrowWarpProvider`: already isolates `eyebrowHeadSpacing` from whole-brow spacing and exposes a narrow private seam suitable for the repair.
- `BeautyEyebrowSemanticTrace` and observed eyebrow support: provide request-local inner/outer endpoint identity without exposing raw geometry through the public API.
- `EyebrowSafetyFixtures`: provides stable synthetic traces for sign, cap, eligibility, recovery, and influence-boundary unit tests.
- Phase 89 manifest/comparator/runner: already encode the exact two signed cases, protected regions, whole-brow siblings, source/neutral preconditions, cleanup, and aggregate evidence.
- CPU reference geometry oracle and renderer process tests: provide established actual-pixel and package-host testing patterns without changing production access levels.

### Established Patterns
- Public controls resolve into request-local immutable render state, then field providers emit private geometry consumed by the unified pipeline.
- Brow-head spacing is locally eligible per side; whole-brow spacing requires paired support and moves a broader trace. That asymmetry is intentional and must remain visible.
- Generated, in-memory, deterministic pixels are the primary mechanics/effect evidence. Private real-media fixtures are optional algorithm-specific inputs and are not authorized for this phase.
- Tests use production behavior through package APIs or internal testable seams; production APIs are not widened for testing.
- Durable validation stores aggregate facts only and cleans temporary reports and rendered images on success and failure.

### Integration Points
- Repair point: `EyebrowWarpProvider.headSpacingPoints` and any tightly scoped private helper it owns.
- Focused safety proof: `EyebrowWarpProviderTests` and `EyebrowSafetyFixtures`.
- Actual-pixel proof: package-host rendering consumed by `run-face-feature-batches.sh` and `compare-face-feature-batches.swift` under the frozen manifest.
- Documentation closeout: `DESIGN.md`, `PRODUCT_SENSE.md`, `RELIABILITY.md`, `QUALITY_SCORE.md`, `docs/SDK_EFFECT_TAXONOMY.md`, and `PLANS.md` only where the implemented contract changes their owned current-state wording.

</code_context>

<specifics>
## Specific Ideas

- Favor an anatomy-scaled displacement with a strong inner-endpoint carrier, a reduced adjacent carrier, and a support radius that is explicitly bounded before the frozen outer-anchor boxes.
- Test the two signed values as paired semantic opposites from the same deterministic input, then compare each with both whole-brow siblings so a broad translated-brow solution cannot pass accidentally.
- If current rendering is visually too weak because displacement and radius interact poorly, repair the local field rather than changing the public cap or relaxing the comparator.

</specifics>

<deferred>
## Deferred Ideas

- Phase 95 owns live owner-controlled portrait runs, optional rights-approved local fixture feedback, milestone-wide integration, and the final SDK-owned no-skip closeout.
- Any model, training data, weight, Metal/GPU backend, application/UI, public API expansion, packaging, commercialization, or external distribution work requires a separately authorized future milestone.

</deferred>

---

*Phase: 92-signed-eyebrow-head-spacing*
*Context gathered: 2026-09-06*
