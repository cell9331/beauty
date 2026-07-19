# Phase 44: Eye Geometry Safety and Ledger Closeout - Context

**Gathered:** 2026-07-19
**Status:** Ready for planning
**Mode:** Autonomous smart discuss (`--auto`; repository-evidenced recommendations selected)

<domain>
## Phase Boundary

Close the v1.11 SDK-core eye geometry slice after Phases 41-43 established the ten-field public contract, private observed contour/pupil support, fourteen-field provider/resolver route, and strict public-facade output evidence. Phase 44 owns only `EYE-19` through `EYE-23` and `DOC-01`: final exact caps and dead zones, exhaustive dependency/freshness/provider-empty safety, exact one-baseline convergence through at most twenty-eight eye/nose/mouth removals, fail-closed active-source/security/artifact evidence, atomic promotion of exactly ten rows, and synchronization of current owners.

This phase does not add fields, geometry behavior families, Demo work, dependencies, network/cloud or commercial paths, tracked generated images, device/commercial visual approval, optimized-performance certification, packaging, shipping, launch readiness, milestone audit, archive, tag, or cleanup.

</domain>

<decisions>
## Implementation Decisions

### Final Exact Caps, Normalization, and Neutral Behavior

- **D-01:** Finalize the current provider/output-backed caps without raising them: `eyeHeight = 0.35`, `eyeLength = 0.35`, `upperEyelidLift = 0.30`, `pupilSize = 0.25`, `gazeCorrection = 0.25`, `lowerEyelidDrop = 0.30`, signed `eyeTilt = +/-0.25`, `innerCornerOpen = 0.25`, `outerCornerOpen = 0.25`, and `eyeSymmetry = 0.25`. Remove the "provisional" designation only after the Phase 44 cap matrix passes.
- **D-02:** Public ranges stay `0...1` for nine positive-only fields and `-1...1` for signed `eyeTilt`. Exact-cap input does not increment `capped_parameter_count`; normalized public overflow clamps to the exact cap and increments it once per field. Negative/non-finite positive-only input remains neutral zero; both finite tilt signs survive normalization, cap, conflict scale, and provider emission.
- **D-03:** Zero and values at or below `Float.ulpOfOne` remain inert for requested-work/accounting. Automatic gaze additionally no-ops when pupil-to-own-center distance is `<= 0.002`, and at cap moves an eligible pupil by the existing maximum `0.35` fraction toward its own center. Symmetry no-ops when both measured span delta and tilt delta are `<= 0.0001`; its cap retains the existing maximum `0.30` midpoint blend. These thresholds are exact algorithmic dead zones, not claims of commercial naturalness.
- **D-04:** Cap tests must cover zero, exact cap, overflow, negative positive-only, signed positive/negative tilt, and `NaN`/`+infinity`/`-infinity`, with exact effective values, counts, aggregate warning/metric behavior, named emission presence/absence, and no field-name/raw-geometry diagnostics. Relational-only cap assertions are insufficient.
- **D-05:** Preserve all four shipped eye caps and vectors unchanged. The Phase 43 `0.25` public cases, 385/385 decoded output matrix, 66/66 visibility, 6/6 direct signed tilt, 60/60 semantic distinctions, and the corrected package-internal gaze aggregate from commit `6e4704e` are immutable upstream evidence, not a license to weaken strict output gates or reintroduce the retired RGB mirror score.

### Fourteen-Field Dependency, Degradation, and Transitions

- **D-06:** Treat the eye inventory as exactly fourteen fields: the four shipped fields plus the ten new fields. Missing/no face, explicit missing either observed contour, invalid side order, malformed contour/support, reused eye geometry, and stale eye geometry invoke the established complete-eye-domain skip: all fourteen effective strengths/emissions are zero, `.eyes` is skipped/inactive as applicable, and safe face/nose/mouth/color/filter siblings continue under their existing policies.
- **D-07:** Missing or implausible pupil support removes only `pupilSize` and `gazeCorrection`; all contour-dependent shipped/new siblings remain eligible. Neutral gaze removes only `gazeCorrection`; a neutral measured pair removes only `eyeSymmetry`. No field may borrow a shipped proxy, sibling support, fabricated pupil, mirror score, or cached prior vector to remain active.
- **D-08:** Provider-empty output is authoritative per field after both preflight and final conflict scale. Empty work is removed before active domains, totals, counts, `capped_parameter_count`/weakened evidence, warnings, metrics, point counts, and dispatch; valid siblings remain. Nil legacy observed payload preserves only the already-shipped compatibility path established in Phase 41, while explicit invalid observed payload fails closed with no synthetic fallback.
- **D-09:** Reused geometry keeps the existing complete-eye skip rather than applying the non-eye `0.5` reuse scale to any eye field. Eligible face/nose/mouth work may retain their established exact `0.5` reuse behavior; stale/no-face work is removed according to existing domain policies. Tests must cover fresh->reused, reused->fresh, fresh->stale, stale->fresh, face->no-face, valid->missing contour, valid->missing/implausible pupil, and valid->provider-empty without carrying prior strengths or vectors.
- **D-10:** Diagnostics remain stable, aggregate, and redacted. Tests must reject coordinates, contours, pupils, bounds, side labels, control points, detector/provider types, image bytes, paths, or per-field failure payloads in public results, warnings, metrics, descriptions, persistence, or logs.

### One-Baseline Conflict Convergence

- **D-11:** Combined geometry uses one provider-eligible retained baseline for exactly five face, fourteen eye, six nose, and eight mouth fields. With every field eligible at its exact cap, the focused fixture must prove an unscaled total of `10.70`, a retained count of `33`, and scale `1 / 10.70`; signed values retain polarity. Any fixture-driven removal must have a separately stated exact total/count/scale.
- **D-12:** The convergence loop is monotonic and bounded by exactly twenty-eight possible provider removals: fourteen eye + six nose + eight mouth. A field may be weakened once per resolve or removed; it is never re-added or weakened through a second path. The five face fields are retained baseline participants but not part of the provider-removal ceiling.
- **D-13:** Preflight and final-scale sanitization must agree with final effective strengths and emitted control points. Unsupported or below-provider-threshold fields contribute zero to the total, retained count, weakened count, scale, warnings, metrics, active domains, geometry-point count, and dispatch. Tests must include complete, missing-pupil, neutral-gaze/symmetry, contour-missing, nose/mouth provider-empty, and adversarial late-removal cases.
- **D-14:** No new public total/count metric is required. Focused tests may mirror private exact arithmetic, but public diagnostics retain only their established aggregate keys and messages.

### Fail-Closed Boundary and Evidence Gate

- **D-15:** Create a Phase 44-owned Python checker, following the hardened Phase 40 mouth and Phase 37 nose closeout helpers, with `--self-test`, default pre-promotion live mode, `--allow-promotion` live mode, and optional fixture root. It must distinguish subprocess match/no-match/error states, classify every active-source match, reject wrong roots/symlinks/scope escapes, and exercise positive plus one-failure-per-boundary/owner/status fixtures.
- **D-16:** Both live modes fail closed on public/SPI eye-support types, raw/derived eye or pupil geometry leakage, Codable/persistence/cached landmark state, Demo or renderer imports of internal SDK targets, network/cloud behavior, account/payment/VIP/entitlement/commercial paths, new dependencies/package targets/render passes, 48-field compatibility drift, unclassified active-source matches, and tracked/staged/non-ignored generated output/gallery/quarantine artifacts.
- **D-17:** Default live mode requires all ten target rows to remain unpromoted and branch `眼睛` partial. `--allow-promotion` replaces only that guard and requires exactly the ten named rows implemented, `去脂`/`祛红血丝` future, branch `眼睛` partial, complete EYE-19..23/DOC-01 evidence, finalized validation/security/review/verification, synchronized current owners, and no claim that milestone audit/lifecycle or excluded setup/commercial work has passed.
- **D-18:** Before promotion, run nonzero focused suites, full `swift test --package-path BeautySDK`, the unchanged Phase 43 strict helper/self-test and gallery containment gates, boundary checker compile/self-test/default live mode, review, ASVS L1 security (HIGH blocking, `threats_open: 0`), validation rows, artifact/ignore scans, and `git diff --check`. A failed or unavailable required gate blocks promotion and is recorded honestly.

### Atomic Ten-Row Promotion and DOC-01 Owners

- **D-19:** Promotion is one evidence-gated transaction. Mark exactly `眼高` (`eyeHeight`), `长度` (`eyeLength`), `提肌` (`upperEyelidLift`), `眼瞳大小` (`pupilSize`), `眼神矫正` (`gazeCorrection`), `眼睑下至` (`lowerEyelidDrop`), `倾斜` (`eyeTilt`), `内眼角` (`innerCornerOpen`), `外眼角` (`outerCornerOpen`), and `对称` (`eyeSymmetry`) implemented only after D-18 passes. Each row cites its own Phase 41 contract/support, Phase 42 provider, Phase 43 output, and Phase 44 safety/boundary evidence; no aliases or borrowed shipped evidence.
- **D-20:** Keep `去脂` and `祛红血丝` future because they require separate retouch/color/segmentation ownership, and keep branch-level `眼睛` partial. Preserve the four previously implemented eye rows unchanged; the exact eye taxonomy ends with fourteen implemented geometry rows plus the two future retouch rows.
- **D-21:** Synchronize the authoritative blueprint owners (`SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, eye README, beauty-shaping README, `EXAMPLE_IMAGE_VALIDATION.md`, `example-images/README.md` when current commands/counts require it), root contracts (`ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`), and current planning owners (`PLANS.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, Phase 44 validation/security/review/verification/evidence). Update each owner only for its contract; archived Phase 30/37/40 evidence stays immutable.
- **D-22:** Phase 44 closes the phase and prepares the repository for the independent milestone audit. It must not author the milestone audit, mark v1.11 audited/archived/shipped, create a tag, clean phase directories, or claim Demo/device/commercial/performance/packaging/shipping/launch readiness.

### the agent's Discretion

- Choose the smallest table-driven XCTest extensions and exact helper/evidence filenames that follow current Phase 40/37 patterns. Execution order must keep product/status owners read-only until runtime, convergence, output, boundary, review, security, and validation gates are green.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Current Phase and Upstream v1.11 Evidence

- `AGENTS.md` — repository reading order, verification, and record rules.
- `PLANS.md` — active/completed ledger and conservative scope boundary.
- `.planning/PROJECT.md` — v1.11 goal, exclusions, and local-first contract.
- `.planning/REQUIREMENTS.md` — EYE-19 through EYE-23 and DOC-01 acceptance.
- `.planning/ROADMAP.md` — Phase 44 goal and five success criteria.
- `.planning/STATE.md` — current Phase 43 evidence and Phase 44 handoff.
- `.planning/phases/41-public-contract-and-observed-eye-support/41-CONTEXT.md` — ten-field public/support contract and fail-closed support decisions.
- `.planning/phases/41-public-contract-and-observed-eye-support/41-VERIFICATION.md` — compatibility, mapping, private support, and boundary proof.
- `.planning/phases/42-independent-eye-geometry-and-pipeline-integration/42-CONTEXT.md` — provider semantics, field eligibility, and Phase 44 deferrals.
- `.planning/phases/42-independent-eye-geometry-and-pipeline-integration/42-VERIFICATION.md` — fourteen named emissions and field-local sanitization proof.
- `.planning/phases/43-public-facade-eye-geometry-output-evidence/43-CONTEXT.md` — frozen 55-case/385-output evidence contract.
- `.planning/phases/43-public-facade-eye-geometry-output-evidence/43-EYE-OUTPUT-EVIDENCE.md` — fixed ROI/floors, exact output/comparison counts, eligibility, and aggregate gaze proof.
- `.planning/phases/43-public-facade-eye-geometry-output-evidence/43-VERIFICATION.md` — post-`6e4704e` authoritative output/gaze verdict.

### Archived Closeout Precedents

- `.planning/milestones/v1.10-phases/40-mouth-geometry-safety-and-ledger-closeout/40-CONTEXT.md` — closest safety/convergence/boundary/partial-branch closeout pattern.
- `.planning/milestones/v1.10-phases/40-mouth-geometry-safety-and-ledger-closeout/40-PATTERNS.md` — exact cap table, retained-set convergence, and promotion transaction.
- `.planning/milestones/v1.10-phases/40-mouth-geometry-safety-and-ledger-closeout/check_mouth_geometry_boundaries.py` — hardened self-tested checker to adapt.
- `.planning/milestones/v1.9-phases/37-nose-safety-boundary-and-branch-closeout/37-CONTEXT.md` — exact arithmetic, owner-window, ASVS, and lifecycle-preparation precedent.
- `.planning/milestones/v1.9-phases/37-nose-safety-boundary-and-branch-closeout/check_nose_safety_boundaries.py` — fail-closed classifier precedent.
- `.planning/milestones/v1.6-phases/30-eye-safety-ledger-and-closeout/30-EYE-SAFETY-EVIDENCE.md` — immutable four-shipped-eye closeout baseline and branch-partial policy.

### Runtime and Tests

- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` — current exact cap constants to finalize.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` — capping, dependency/freshness degradation, retained-baseline convergence, aggregate diagnostics.
- `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` — fourteen named emissions, exact gaze/dead-zone/symmetry semantics, package-only aggregate gaze evidence.
- `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` — exact total/count/scale ownership.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` — effective strength, warning, metric, and active-domain contract.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` — public facade, extent, and diagnostic boundary.
- `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` — exact cap constant precedent.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` — normalization/capped-count and routing tests.
- `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` — named emission, sign/locality, gaze, symmetry, and malformed support evidence.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` — no-face/support/freshness/provider-empty transition evidence.
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` — multi-domain exact retained-set and signed direction evidence.
- `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` — exact arithmetic and weakened-count evidence.
- `.planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py` — unchanged strict output regression gate.
- `example-images/generate_gallery.py` — ignored gallery bijection and artifact containment gate.

### Owner Contracts and Ledgers

- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` — exact eye second-level row/status authority.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` — branch-level `眼睛` status owner.
- `docs/meitu-function-blueprint/features/beauty-shaping/eyes/README.md` — eye branch contract and evidence owner.
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` — parent shaping branch summary.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` — current renderer/helper/gallery evidence and limitations.
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md` — root architecture/design/privacy/reliability/product/quality owners.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- `BeautySafetyCaps` already holds the ten intended final values; Phase 44 must freeze them with exact boundary tests and remove only the provisional wording.
- `EyeWarpFieldEmissions.sanitizing`, `BeautyEffectResolver.resolveGeometryConflict`, and `GeometryConflictResolver` already provide one-baseline monotonic convergence bounded at 28 removals.
- Phase 43's strict output helper and package-only `GazeCorrectionAggregateEvidence` provide direct output and automatic-correction evidence without disclosing geometry.
- Archived Phase 40/37 checkers already implement robust command-state classification, fixture-root isolation, pre-/post-promotion modes, owner windows, and artifact gates.

### Established Patterns

- Final safety phases add exact table-driven tests and evidence first, build/self-test the boundary gate second, and mutate promotion/current-owner documents last.
- Generated outputs and galleries are disposable ignored evidence; no binary baseline becomes tracked.
- Current owner docs state only observed automated evidence and preserve excluded setup/commercial/lifecycle work as not run or future.

### Integration Points

- Runtime work is concentrated in safety-cap comments/constants and test coverage around resolver/provider/conflict behavior; production algorithm redesign requires a failing Phase 44 invariant, not speculative tuning.
- Product promotion is centered on the exact ten rows in `SHAPE_FEATURE_LEDGER.md`, with branch partial status repeated only in its actual owners.
- Final GSD mutation of ROADMAP/REQUIREMENTS/STATE must use registered `gsd-tools.cjs query` handlers rather than direct unsafe state edits during completion.

</code_context>

<specifics>
## Specific Ideas

- Use one exact cap table and one exact dependency matrix across fourteen eye fields; report separate contour, pupil/gaze, and measured-pair eligibility.
- Add a full-eligible 33-field convergence fixture with exact `10.70` total/count/scale, then adversarial removal fixtures proving the 28-removal bound and final emission equality.
- Treat the Phase 43 post-`6e4704e` pupil-to-own-center aggregate as the only authoritative gaze-reduction proof; keep the image-only dark-core experiment diagnostic and the retired mirror score non-accepting.
- Adapt the Phase 40 checker rather than inventing a new scanner architecture, substituting 48-field compatibility, fourteen-eye inventory, ten-row promotion, two future retouch rows, and branch-partial conditions.

</specifics>

<deferred>
## Deferred Ideas

- `去脂` eye-fat retouch/segmentation and `祛红血丝` color/vascular retouch.
- Manual gaze direction, per-eye asymmetry controls, new public support/result types, or persisted raw eye geometry.
- Demo UI, device/commercial visual approval, optimized performance, packaging, shipping, launch readiness, milestone audit, archive, tag, and cleanup.

</deferred>

---

*Phase: 44-eye-geometry-safety-and-ledger-closeout*
*Context gathered: 2026-07-19 via autonomous smart discuss*
