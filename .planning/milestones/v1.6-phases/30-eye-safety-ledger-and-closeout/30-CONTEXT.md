# Phase 30: Eye Safety, Ledger, and Closeout - Context

**Gathered:** 2026-07-10
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 30 closes the existing-parameter `眼睛` SDK slice after Phase 29 proved public-facade saved-output behavior. It covers `EYE-04` through `EYE-08` and `DOC-01` by aligning eye-input safety semantics, proving eye-specific caps and degradation behavior, proving combined-geometry weakening, enforcing raw-geometry/import/network/commercial boundaries, promoting exactly the four evidence-backed eye rows, and synchronizing the owning documentation.

This phase may change the internal normalization, resolver, warning/metric, and test behavior needed to make the existing public parameters safe and unambiguous. It must not add public parameter fields, Demo UI, new eye tools, negative-direction visible behavior for positive-only eye parameters, network/cloud behavior, commercial entitlement behavior, committed generated PNG baselines, branch-level `眼睛` completion, device-parity claims, commercial visual-quality claims, broad reference-app parity claims, or launch-readiness claims.

</domain>

<decisions>
## Implementation Decisions

### Negative Input and Cap Semantics
- **D-01:** `eyeSize` is positive-only. Negative public input must normalize to zero and must not produce a misleading `eye_inputs_missing` warning.
- **D-02:** `eyeTailLift` is positive-only. Negative public input must normalize to zero and must not produce a missing-eye warning.
- **D-03:** `eyeDistance` and `eyeYPosition` remain signed, bidirectional parameters. Positive and negative directions must be preserved through normalization, safety caps, weakening, and focused tests.
- **D-04:** Eye cap evidence must lock exact effective values and directions per parameter: positive caps for `eyeSize` and `eyeTailLift`, signed `±cap` behavior for `eyeDistance` and `eyeYPosition`, and zero effective strength for negative `eyeSize` and `eyeTailLift`.
- **D-05:** Cap evidence must also prove the stable capped warning and aggregate capped metric. Relational assertions that only prove `abs(value) <= cap` are insufficient.
- **D-06:** All four eye parameters require finite-overflow and non-finite public-input coverage. `NaN`, positive infinity, and negative infinity must normalize safely to zero.

### Stale, Reused, and Missing-Eye Geometry
- **D-07:** Eye geometry must be skipped completely when face geometry freshness is `.reused`: `.eyes` is not active, no eye control points are generated, and all eye effective strengths are zero.
- **D-08:** Eye geometry must be skipped completely when face geometry freshness is `.stale`, with the same no-active-domain, zero-strength, and no-control-point guarantees.
- **D-09:** The stricter `.reused` policy is eye-specific. Face shape, nose, and mouth keep their established reduced-strength reuse behavior; Phase 30 must not broaden the behavior change to other geometry domains.
- **D-10:** If either the left-eye or right-eye landmark group is missing, skip the entire eye domain rather than applying an asymmetric single-eye effect. Unaffected geometry domains and safe color/filter domains continue according to their existing contracts.
- **D-11:** Missing-eye, reused-eye, and stale-eye skips must have distinct stable, redacted public reasons. Warnings and metrics may expose only the state category and aggregate counts, never landmarks, coordinates, bounds, control points, paths, image bytes, raw framework errors, or raw detector objects.

### Eye-Specific Evidence Gate
- **D-12:** EYE-05 requires layered evidence. Public `BeautyEngine` facade tests prove no-face dimension preservation, redacted results, and continuation of safe domains; resolver/provider tests prove missing-eye, reused, and stale eye-domain skips, zero effective strengths, and no eye control points.
- **D-13:** EYE-06 requires a per-behavior combined-geometry matrix covering `eyeSize`, positive and negative `eyeDistance`, positive and negative `eyeYPosition`, and `eyeTailLift` with representative face-shape geometry. Each case must preserve signed direction where applicable and prove additional weakening below its normal capped strength.
- **D-14:** Add one all-eye, multi-geometry-domain combined case to prove the stable combined-weakening warning and aggregate weakened metric.
- **D-15:** Reuse existing tests when their assertions exactly satisfy a Phase 30 requirement. Add focused assertions for the newly locked positive-only semantics, four-parameter abnormal-input matrix, strict reused-eye skip, and per-behavior combined weakening. Verification evidence must map `EYE-04`, `EYE-05`, and `EYE-06` to exact tests.
- **D-16:** Phase 30 closeout must run focused tests, the full `swift test --package-path BeautySDK` suite, `BeautyExampleRenderer` build/run, and the Phase 29 helper expecting 161/161 outputs and 36/36 eye-vs-baseline comparisons. Gallery generation is rerun only if gallery logic changes.

### Boundary Scans, Promotion, and Documentation
- **D-17:** Boundary scans use zero tolerance on real matches in public/SPI and active SDK, Demo, and renderer source. Test guard literals, documentation examples, and historical evidence are classified rather than blindly treated as leaks. Build outputs, ignored worktrees, and generated images are outside the active-source scan set.
- **D-18:** Any active EYE-07 violation blocks every eye-row promotion. Blocking violations include public/SPI raw geometry exposure, Demo imports of internal SDK targets, renderer imports of internal SDK targets, network/cloud paths, commercial/VIP/entitlement paths, or new public parameter fields.
- **D-19:** Promote `大小`, `上下`, `眼距`, and `眼尾上扬` atomically only after EYE-04 through EYE-07, the Phase 29 visible-output regression, and all closeout scans pass. If any gate fails, all four rows remain `partial`.
- **D-20:** Branch-level `眼睛` remains `partial` after the four scoped rows become `implemented`; future eye tools remain future because they lack separate product-neutral parameter/resource design and evidence.
- **D-21:** Documentation synchronization is complete but targeted by contract ownership. Always update the eye ledger, branch matrix and eyes README, example-image validation, affected design/security/reliability/product contracts, quality/work ledgers, GSD project state, and Phase 30 evidence. Update `ARCHITECTURE.md` or `FRONTEND.md` only if their owned contracts actually change.

### the agent's Discretion
The planner may choose exact warning code names, test file organization, table-driven helper structure, scan command/regex shapes, evidence artifact names, and whether existing tests are extended or new focused test files are added. These choices must preserve the distinct missing/reused/stale reasons, the locked parameter semantics, the layered evidence gate, active-source hard-failure policy, atomic promotion rule, and conservative no-overclaim boundary.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Current work ledger, active-plan policy, technical debt, and verifiable completion requirements.
- `.planning/PROJECT.md` — Defines v1.6 as an SDK-only existing-parameter eye slice and locks the no-UI/no-public-expansion/no-network boundary.
- `.planning/REQUIREMENTS.md` — Defines `EYE-04` through `EYE-08` and `DOC-01`, including the Phase 30 safety, degradation, boundary, promotion, and synchronization obligations.
- `.planning/ROADMAP.md` — Defines the Phase 30 goal, success criteria, exact four-row promotion scope, branch-level partial status, and non-claims.
- `.planning/STATE.md` — Records Phase 30 as the current planning focus after Phase 29 completion.
- `.planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md` — Locks the six existing eye renderer cases, signed visible directions, generated-output policy, and Phase 30 ownership of safety and promotion.
- `.planning/phases/29-eye-renderer-output-evidence/29-EYE-RENDERER-EVIDENCE.md` — Command-backed 161/161 output, 36/36 comparison, no-face presence, ignored-artifact, and rerun evidence that Phase 30 must regress.
- `.planning/phases/29-eye-renderer-output-evidence/29-VERIFICATION.md` — Final Phase 29 requirement, boundary, and non-claim evidence.
- `.planning/phases/29-eye-renderer-output-evidence/29-SECURITY.md` — Current renderer/output trust boundaries and closed Phase 29 threat register.
- `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md` — Precedent for per-tool safety evidence, scoped atomic ledger promotion, branch-level partial status, and documentation closeout.

### Root Contracts
- `ARCHITECTURE.md` — Owns package boundaries, public `BeautySDK` facade, internal target direction, renderer facade-only imports, and no UI in SDK targets.
- `DESIGN.md` — Owns `BeautyParameters`, parameter ranges, internal geometry freshness, group-specific landmark degradation, warnings/metrics, and the acceptance test matrix.
- `SECURITY.md` — Owns raw face/eye geometry sensitivity, public-result redaction, active-source privacy scans, local-first behavior, and generated-output trust boundaries.
- `RELIABILITY.md` — Owns degrade-before-fail behavior, no-face/missing-landmark handling, stale/reused geometry policy, warning/metric observability, and saved-output regression rules.
- `PRODUCT_SENSE.md` — Owns eye-control user expectations, safe degradation acceptance, evidence-led status claims, and anti-overclaim boundaries.
- `QUALITY_SCORE.md` — Owns current quality evidence, stale-map warning, renderer regression queue, and Phase 30 quality closeout record.

### Blueprint and Evidence Contracts
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` — Authoritative second-level `美型 / 五官` status ledger; only the four scoped eye rows may be promoted.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` — Owns branch-level status semantics and must keep `眼睛` at `partial`.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` — Owns renderer commands, the ignored-output path, helper expectations, output matrix, and evidence limitations.
- `docs/meitu-function-blueprint/features/beauty-shaping/eyes/README.md` — Owns the eye branch's current public-parameter coverage, dependencies, privacy boundary, and future tool needs.
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` — Owns beauty-shaping branch evidence expectations and SDK-core boundary.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` — Defines evidence-led promotion, SDK-core/no-UI behavior, and conservative claims.
- `example-images/README.md` — Owns committed fixture, ignored output, gallery, and flat filename contracts.

### Current Code and Test Surfaces
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — Current public eye fields and finite/signed normalization; integration point for positive-only `eyeSize` and `eyeTailLift` semantics.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` — Current eye cap constants: size 0.45, distance 0.30, vertical position 0.25, and tail lift 0.30.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` — Current cap resolution, domain activation, combined weakening, stale/reused handling, warnings, metrics, and eye provider integration.
- `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` — Current eye control-point behavior, positive-only size/tail output, signed distance/vertical output, and missing-eye skip seam.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` — Aggregates geometry control points and applies still-image geometry output through internal paths.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` — Public still-image facade whose no-face result must preserve dimensions and safe-domain behavior.
- `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` — Public-facade detection and internal selected-face routing boundary.
- `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` — Existing exact safety-cap constant coverage.
- `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` — Existing eye control-point, direction, cap, determinism, and missing-eye provider coverage.
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` — Existing combined geometry cap/weakening, warning/metric, and redaction patterns.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` — Existing no-face, missing-eye, stale, reused, selected-face, and redaction patterns; current reused-eye behavior must change.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` — Existing public-facade no-face dimension, detection-summary, safe-domain, and redaction coverage.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` — Locks the renderer case inventory, public-facade import boundary, and six Phase 29 eye cases.
- `.planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py` — Existing full-matrix and 36-comparison output helper to rerun at Phase 30 closeout.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — Existing public-facade renderer and locked eye output cases.
- `example-images/input/` — Committed six-portrait plus no-face fixture set used by the output regression.
- `example-images/output/` — Ignored generated output directory; generated PNG baselines remain uncommitted.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautySafetyCapsTests` and `EyeWarpProviderTests` already lock cap constants, control-point directions, determinism, and missing-eye provider behavior; extend or complement them instead of duplicating the entire suite.
- `MissingLandmarkDegradationTests` already constructs missing-left-eye, stale, and reused geometry and asserts redacted warnings/metrics. Its current reused-eye reduction expectation is the main policy seam Phase 30 must change.
- `CombinedEffectSafetyTests` already produces capped multi-domain plans and checks `combined_geometry_weakened`, capped/weakened counts, point counts, and redaction; it provides the pattern for the required per-eye-behavior matrix.
- `BeautyEngineGeometryFacadeTests` already has deterministic detection fixtures and no-face dimension/redaction assertions suitable for the facade layer of EYE-05.
- Phase 29's renderer executable and helper already provide the complete visible-output regression path; Phase 30 does not need new renderer cases.

### Established Patterns
- `BeautyParameters` currently normalizes every eye field as signed, while `EyeWarpProvider` only emits visible output for positive `eyeSize` and positive `eyeTailLift`. Phase 30 aligns that mismatch by making those two parameters positive-only without adding fields or new visible directions.
- The existing global freshness policy reduces all geometry on `.reused` and skips strong geometry on `.stale`. Phase 30 introduces a deliberately narrower safety exception: eyes skip on both states while other domains keep current reuse behavior.
- Missing either eye group currently skips the entire eye provider, matching the locked asymmetric-output avoidance decision.
- Generated outputs and galleries remain ignored. Status promotion is evidence-led and uses command facts, counts, redacted metrics, and conservative limitations rather than committed image hashes or subjective quality claims.
- `.planning/codebase/*` maps are stale background and must not override current source, root contracts, Phase 29 evidence, or current planning ledgers.

### Integration Points
- Align positive-only public semantics in `BeautyParameters` normalization and keep resolver effective strengths/warnings consistent with that boundary.
- Update `BeautyEffectResolver` so `.reused` and `.stale` zero and skip eye strengths without changing reuse behavior for face shape, nose, or mouth.
- Preserve `EyeWarpProvider`'s both-eyes-required contract and ensure missing groups cannot produce partial eye control points.
- Extend focused effects tests and public-facade tests, then map exact tests to EYE-04/05/06 in Phase 30 verification evidence.
- Run active-source boundary scans before changing the authoritative eye ledger and synchronize owning contracts only after every evidence gate passes.

</code_context>

<specifics>
## Specific Ideas

- Treat the six Phase 29 visible behaviors as the regression inventory: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, and `eyeTailLift_0p25`.
- The combined-weakening matrix mirrors those six behavior directions, paired with representative face-shape geometry, plus one all-eye/multi-domain case.
- Keep Phase 29's closeout expectations at 161/161 generated outputs and 36/36 portrait eye-vs-`geometryBaseline_noop` top-region comparisons.
- Use distinct redacted missing-eye, reused-eye, and stale-eye reasons; exact stable code names are left to planning.
- Promote `大小`, `上下`, `眼距`, and `眼尾上扬` together or not at all.

</specifics>

<deferred>
## Deferred Ideas

- Negative `eyeSize` as visible eye shrinking needs a future phase with explicit product semantics, implementation, safety policy, renderer cases, and saved-output evidence.
- Negative `eyeTailLift` as visible downward tail movement needs a future phase with explicit product semantics, implementation, safety policy, renderer cases, and saved-output evidence.
- A stricter reused-geometry policy for face shape, nose, mouth, or every geometry domain is outside this eye-only phase.
- Eye height, eye length, fat removal, muscle lift, pupil/gaze, lid, redness, corner, tilt, and symmetry tools remain future because they need separate product-neutral parameter/resource design and evidence.
- Demo UI, commercial quality review, device parity, broad reference-app parity, committed generated PNG baselines, network/cloud behavior, entitlement behavior, and launch-readiness claims remain out of scope.

</deferred>

---

*Phase: 30-Eye Safety, Ledger, and Closeout*
*Context gathered: 2026-07-10*
