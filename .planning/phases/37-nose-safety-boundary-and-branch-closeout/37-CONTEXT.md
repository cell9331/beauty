# Phase 37: Nose Safety, Boundary, and Branch Closeout - Context

**Gathered:** 2026-07-14
**Status:** Ready for planning
**Mode:** Autonomous `--auto`; safe defaults locked from repository evidence

<domain>
## Phase Boundary

Phase 37 closes the v1.9 SDK-core `鼻子` branch after Phase 35 established independent public root/tip contracts and Phase 36 proved isolated public-facade output. It covers `NOSE-10` through `NOSE-14` and `DOC-01`: final exact caps, exhaustive six-field degradation and emission safety, exactly-once combined weakening, fail-closed active-source boundaries, atomic row and branch promotion, and current-owner synchronization.

This phase may change SDK safety/resolver/provider tests and the authoritative contracts needed to lock the observed behavior. It must not add another public field, public/SPI geometry, Demo UI or controls, dependencies, network/cloud behavior, account/payment/VIP/entitlement/commercial behavior, tracked generated PNGs, physical-device evidence, subjective commercial-naturalness approval, packaging/shipping readiness, launch readiness, or broad reference-product parity.

</domain>

<decisions>
## Implementation Decisions

### Exact Caps and Public Semantics

- **D-01:** Finalize `BeautySafetyCaps.noseRootNarrowing` and `BeautySafetyCaps.noseTipLift` at exact `0.25`. Phase 36 proved that isolated public `0.25` inputs produce visible, same-dimension, non-aliased facade output on all six portrait fixtures: root and lift each pass 6/6 baseline comparisons, root passes 6/6 against bridge, and lift passes 12/12 against both signed tip-size directions.
- **D-02:** The `0.25` evidence supports an exact conservative SDK safety cap and branch completion; it does not prove subjective naturalness, device parity, commercial approval, or production-quality tuning.
- **D-03:** Both fields remain positive-only public `0...1` values with default/non-finite zero. Inputs above the effective cap resolve to exactly `0.25`, each contributes exactly one capped field to `capped_parameter_count`, and any nonzero capped count produces the existing stable aggregate capped warning without exposing field names or geometry.
- **D-04:** All exact-cap tests must assert resolved values, counts, warning behavior, and aggregate metrics. Relational-only assertions such as `<= 0.25` are insufficient.

### Exhaustive Six-Field Degradation and Emission Safety

- **D-05:** Treat the nose inventory as exactly six fields: positive-only `noseSlim`, `noseWingSlim`, `noseBridge`, `noseRootNarrowing`, and `noseTipLift`, plus signed `noseTipSize` with both positive and negative directions preserved.
- **D-06:** Zero input for each field remains inert: it does not activate `.nose`, add capped/weakened counts, create control points, or emit a misleading `nose_inputs_missing` warning.
- **D-07:** No-face and stale geometry fail closed for all six fields together: `.nose` is inactive, all six effective strengths are zero, no nose vectors are emitted, safe independent color/filter domains continue, output extent is preserved at the public facade, and diagnostics remain category/aggregate-only.
- **D-08:** Missing or insufficient support fails closed at the narrowest correct field boundary. Legacy fields require their established legacy nose support; `noseRootNarrowing` requires its explicit symmetric upper-root pair; `noseTipLift` requires its explicit lower-tip support. An unsupported field is zeroed and cannot borrow a sibling's support, while supported siblings and safe domains may continue.
- **D-09:** Provider-empty is a final eligibility boundary for every one of the six fields, not only the two new fields. A requested/effective field whose provider emits no vectors must be removed from the retained baseline, final effective strengths, active-domain evidence, conflict total, weakened count, and final dispatch. No field may survive only because another nose sibling emits.
- **D-10:** Reused non-eye geometry retains each eligible nose field at exactly `0.5` of its normal capped strength: `0.175` slim, `0.175` wing, signed `±0.15` tip size, `0.15` bridge, `0.125` root narrowing, and `0.125` tip lift before any independent combined-geometry weakening. Missing support/provider-empty removal still applies after reuse scaling.
- **D-11:** Transition evidence must cover fresh-to-reused-to-stale and valid-to-missing/provider-empty cases without carrying prior vectors or strengths forward. Reusing an eligible current geometry snapshot is not permission to reuse stale prior emissions.
- **D-12:** Stable public warnings and metrics may expose only categories, aggregate counts, and bounded numeric totals/scales. They must not expose coordinates, supports, landmarks, bounds, control points, paths, image bytes, detector objects, provider types, or per-field failure payloads.

### Exactly-Once Combined Weakening

- **D-13:** Combined face, eye, mouth, and nose geometry must include all six nose fields and both signed `noseTipSize` directions in the focused matrix. Previously shipped face/eye/nose/mouth directions and their established degradation policies must not regress.
- **D-14:** Provider eligibility converges before final conflict evidence. Every retained geometry field is counted and scaled exactly once; a removed provider-empty field contributes zero times. The final `geometryStrengthTotal`, `geometryWeakenedCount`, conflict scale, `combined_geometry_weakened` warning, effective strengths, and emitted vectors must all describe the same converged retained set.
- **D-15:** The existing monotonic bounded convergence remains the implementation model: fields may be removed as scaled work falls below provider eligibility, never re-added during the same resolution, and totals/counts/scale are recomputed from the retained unscaled baseline. Phase 37 tests must assert exact converged counts/totals/scale rather than only checking that values became smaller.

### Security and Active-Source Boundaries

- **D-16:** Phase 37 uses the configured ASVS Level 1 threat model and blocks on HIGH severity. Final `37-SECURITY.md` must record `threats_open: 0`; any open HIGH threat blocks verification and all promotion.
- **D-17:** Active-source scans have zero tolerance for real public/SPI raw-geometry exposure, Demo or renderer imports of internal SDK targets, network/cloud paths, account/payment/VIP/entitlement/commercial paths, unapproved dependencies, compatibility drift, raw diagnostic geometry, or tracked/staged generated output/gallery artifacts.
- **D-18:** Scan scope must distinguish active source from test guard literals, documentation examples, archived milestone evidence, ignored build/worktree state, and disposable generated images. Historical evidence is read-only and must not be rewritten to manufacture current proof.
- **D-19:** Preserve the package/privacy boundary: `BeautyParameters` exposes exactly 33 stored scalar/string fields (32 numeric plus `filterId`); `FaceGeometry`, root/tip support arrays, landmark coordinates, `WarpControlPoint`, provider types, and raw detection objects remain package-internal; Demo and `BeautyExampleRenderer` use only the public `BeautySDK` facade.

### Atomic Promotion and Documentation Closeout

- **D-20:** Promotion is all-or-nothing and occurs only after exact-cap, six-field degradation/provider-empty, exactly-once conflict, full SwiftPM, Phase 36 renderer/helper regression, ASVS/security, active-source, artifact, and diff-hygiene gates pass. If any gate fails, `山根`, `提升`, and branch-level `鼻子` retain their current partial/future states.
- **D-21:** On a green gate set, promote `山根` to `implemented` with independent `noseRootNarrowing` evidence and `提升` to `implemented` with independent `noseTipLift` evidence. Neither row borrows `noseBridge` or signed `noseTipSize` evidence.
- **D-22:** The de-duplicated `鼻子` taxonomy contains exactly six rows (`大小`, `提升`, `鼻翼`, `山根`, `鼻梁`, `鼻尖`). Once both remaining rows are implemented, promote branch-level `鼻子` to `implemented` for SDK-core scope in `FEATURE_MATRIX.md`, the nose README, and the beauty-shaping branch README. This is not a Demo/device/commercial/packaging/launch claim and does not invent additional unnamed nose controls.
- **D-23:** Current authoritative owners must agree in the same closeout: `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, nose and beauty-shaping READMEs, `EXAMPLE_IMAGE_VALIDATION.md`, `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, and Phase 37 validation/security/verification evidence. Update an owner only for the contract it actually owns.
- **D-24:** Phase 37 prepares a consistent, command-backed current repository for the subsequent autonomous milestone audit. The audit artifact is produced by `$gsd-audit-milestone` after phase verification, not pre-authored by Phase 37; milestone archival, annotated tag creation, and phase cleanup remain `$gsd-complete-milestone` / `$gsd-cleanup` lifecycle work and may proceed only after that independent audit passes.

### the agent's Discretion

The planner may choose focused test file organization, table-driven fixture helpers, stable evidence-artifact names, scan command/regex shapes, and how the four implementation plans divide safety versus documentation. Those choices must preserve the exact values, six-field inventory, signed directions, converged final-evidence invariant, ASVS/blocking policy, atomic promotion sequence, and lifecycle ownership above.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Current State

- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Active autonomous work record and verifiable completion policy.
- `.planning/PROJECT.md` — v1.9 SDK-core goal, boundaries, and conservative non-claims.
- `.planning/REQUIREMENTS.md` — `NOSE-10` through `NOSE-14` and `DOC-01` acceptance and traceability.
- `.planning/ROADMAP.md` — Phase 37 goal, five success criteria, exact promotion order, and lifecycle scope.
- `.planning/STATE.md` — Phase 35/36 decisions, current provisional-cap status, and Phase 37 ownership.
- `.planning/phases/35-public-contract-and-independent-geometry/35-CONTEXT.md` — Independent public semantics, private support geometry, and Phase 37 deferrals.
- `.planning/phases/35-public-contract-and-independent-geometry/35-VERIFICATION.md` — Passed contract/provider/resolver evidence and final bounded conflict-emission convergence.
- `.planning/phases/35-public-contract-and-independent-geometry/35-REVIEW-FIX.md` — Provider-eligibility fixes that Phase 37 must test exhaustively rather than redesign casually.
- `.planning/phases/36-public-facade-output-evidence/36-CONTEXT.md` — Frozen renderer/helper/gallery decisions and no-promotion boundary.
- `.planning/phases/36-public-facade-output-evidence/36-NOSE-OUTPUT-EVIDENCE.md` — Exact 252-output and comparison results supporting the `0.25` cap decision.
- `.planning/phases/36-public-facade-output-evidence/36-VERIFICATION.md` — Independent Phase 36 passed verdict and remaining Phase 37 owners.
- `.planning/phases/36-public-facade-output-evidence/36-SECURITY.md` — Closed renderer/gallery/output threat model to regress.
- `.planning/milestones/v1.7-phases/32-nose-safety-ledger-and-closeout/32-CONTEXT.md` — Closest nose safety/atomic promotion precedent; its archived four-row scope must remain unchanged.
- `.planning/milestones/v1.8-phases/34-mouth-safety-and-documentation-closeout/34-CONTEXT.md` — Recent combined-geometry and documentation closeout precedent.

### Root Contracts

- `ARCHITECTURE.md` — Package boundaries, facade-only integration, internal geometry ownership, and dependency direction.
- `DESIGN.md` — Public parameter inventory/ranges, safety caps, geometry states, resolver/provider behavior, warnings, metrics, and test matrix.
- `SECURITY.md` — Sensitive geometry, redacted diagnostics, local-first boundaries, source scans, and artifact trust.
- `RELIABILITY.md` — Fail-closed degradation, reuse/stale transitions, provider-empty behavior, recovery, and regression commands.
- `PRODUCT_SENSE.md` — User-visible nose semantics, evidence-led promotion, and anti-overclaim acceptance.
- `QUALITY_SCORE.md` — Current quality evidence, full-suite/renderer expectations, and lifecycle quality record.

### Blueprint and Output Owners

- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` — Authoritative six-row nose taxonomy and second-level status owner.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` — Branch-level status owner; currently `鼻子: partial` pending this phase.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` — Exact current 36 × 7 renderer matrix, comparison evidence, ignored artifacts, limitations, and branch status summary.
- `docs/meitu-function-blueprint/features/beauty-shaping/nose/README.md` — Nose branch coverage, status, dependency, privacy, and evidence owner.
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` — Beauty-shaping branch matrix and SDK-core/no-UI boundary.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` — Evidence-led implementation and conservative status semantics.
- `example-images/README.md` — Fixture, output, gallery, and ignored-artifact contracts.

### Code and Test Surfaces

- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — Exact 33-field public compatibility and positive/signed normalization boundary.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` — Final exact `0.25` constants.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` — Capping, degradation, provider preflight, bounded convergence, warnings, metrics, and final effective strengths.
- `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` — Six-field emission eligibility, independent supports, vectors, and skip reason.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` — Effective-strength, warning, metric, and active-domain evidence contract.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` — Public facade/no-face extent and redacted result boundary.
- `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` — Exact cap constant tests.
- `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` — Field emission, support failure, determinism, direction, and provider-empty seams.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` — Six-field no-face/missing/reused/stale/sibling/provider-empty transition evidence.
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` — Exact-cap and combined-weakening matrix patterns.
- `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` — Conflict totals, scale/count, warning, and redaction evidence.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` — Public no-face, safe-domain continuation, extent, and redaction evidence.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` — Exact renderer inventory and public-facade import/case boundaries.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — Exact 36-case public-facade source inventory.
- `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py` — Strict 252-output, ROI, no-face, and artifact verification helper.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- The safety-cap constants and exact `0.25` assertions already exist; Phase 37 promotes their status by adding requirement-complete cap/count/warning/metric evidence rather than changing the value without contradictory evidence.
- Phase 35 review fixes already implement per-field `fieldEmissions`, sanitization, and bounded retained-mask convergence for all nose and mouth geometry fields. Phase 37's job is to lock the complete six-field matrix and exact converged outputs.
- `MissingLandmarkDegradationTests` already contains exact reused values for all six nose fields and several independent support/provider-empty sibling cases. Extend these patterns into a named requirement matrix; do not duplicate weaker one-off assertions.
- Phase 36's renderer/helper/gallery is the current visible-output source of truth. Regress it unchanged at final closeout; generated files remain ignored and untracked.

### Integration Points

- Keep public normalization in `BeautyParameters`; keep effective caps and counts in `BeautyEffectResolver`; keep actual emission eligibility in `NoseWarpProvider`. Tests must prove those layers converge without moving package-internal geometry into the facade.
- Build the exhaustive matrix from the six field key paths plus the negative signed-tip case. Verify provider emissions alongside `effectiveStrengths`, active domains, warnings, metrics, and final conflict evidence.
- Make promotion edits only in the final documentation plan after all implementation, focused/full runtime, renderer/helper, security, and boundary gates are green.
- Historical v1.7 Phase 31/32 artifacts remain immutable precedent. v1.9 evidence must cite current Phase 35/36/37 owners and cannot rewrite archived evidence to claim the new fields.

</code_context>

<specifics>
## Specific Ideas

- A focused cap table should cover zero, exact cap, public overflow to effective cap, negative positive-only input to zero, and all three non-finite values for both new fields, with exact `capped_parameter_count` and stable warning assertions.
- A six-field degradation table should include zero, no face, missing required support, stale, reused exact values, and field-level provider-empty; separate transition tests should prove no prior emission survives.
- A combined matrix should test five positive-only nose fields plus both signed tip directions against representative active face/eye/mouth work, then include one all-six-field case with exact final count, total, scale, and emitted/effective equality.
- Final output regression remains exactly 36 cases × 7 fixtures = 252 outputs, 12 baseline comparisons, 6 root/bridge comparisons, 12 lift/signed-tip comparisons, and two no-face checks unless actual source inventory changes deliberately (which this phase does not authorize).
- Promotion order is gate evidence → security/validation/verification records → two second-level rows → branch-level SDK-core status → current GSD ledgers → independent milestone audit in the parent lifecycle.

</specifics>

<deferred>
## Deferred Ideas

- SwiftUI Demo controls or screens for the two new fields.
- Physical-device camera/Vision parity, subjective naturalness tuning, commercial visual approval, performance qualification, packaging, shipping, and launch readiness.
- Network/cloud processing, accounts, payments, VIP, entitlements, or remote resources.
- Any nose control not present in the repository's exact six-row de-duplicated taxonomy.
- Milestone archive/tag/cleanup before an independent v1.9 audit passes.

</deferred>

---

*Phase: 37-nose-safety-boundary-and-branch-closeout*
*Context gathered: 2026-07-14 via autonomous smart discuss*
