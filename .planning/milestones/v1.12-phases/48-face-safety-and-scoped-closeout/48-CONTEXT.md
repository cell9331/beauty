# Phase 48: Face Safety and Scoped Closeout - Context

**Gathered:** 2026-07-24
**Status:** Ready for planning
**Mode:** Autonomous smart discuss (`$gsd-autonomous --auto`; repository-evidenced decisions selected)

<domain>
## Phase Boundary

Close the reduced-scope v1.12 SDK-core face-shape slice after Phases 45-47 established the exact 52-field public contract, private observed contour/median support, nine-field face/chin provider route, exact 37-field conflict inventory, and strict 413-output public-facade evidence. Phase 48 owns only `SAFE-01` through `SAFE-03` and `DOC-01`: final exact caps and neutral thresholds, exhaustive nine-face-field support/freshness/provider-empty transitions, exact one-baseline 37-field convergence, fail-closed active-source/security/artifact evidence, atomic promotion of exactly four rows, and synchronization of current owners.

This phase does not add public fields, providers, geometry families, renderer cases, Demo work, dependencies, resources/models, network/cloud or commercial paths, tracked generated images, subjective naturalness approval, physical-device parity, optimized-performance certification, packaging, shipping, or launch readiness. The milestone audit/archive/cleanup remain separately owned lifecycle work after phase verification.

</domain>

<decisions>
## Implementation Decisions

### Final Exact Caps and Neutral Behavior

- **D-01:** Finalize all four current provider/output-backed caps at exactly `0.25`: `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper`. Remove the Phase 46 provisional designation only after the exact cap matrix passes.
- **D-02:** All four fields remain positive-only public `0...1` scalars. Zero, negative values, and non-finite values are neutral; exact-cap input does not increment `capped_parameter_count`; finite overflow resolves to `0.25` and increments it exactly once per field.
- **D-03:** No additional product dead zone is introduced. Requested work at zero or `<= Float.ulpOfOne` remains inert through the existing `anyNonZero` and provider thresholds; any provider-empty result at larger values remains authoritative and field-local. This is an algorithmic neutral boundary, not a claim of commercial naturalness.
- **D-04:** The cap matrix covers zero, exact cap, overflow, negative, `NaN`, `+infinity`, and `-infinity`, with exact strengths, capped counts, warnings/metrics, active/skipped domains, named emission presence/absence, and redacted diagnostics.
- **D-05:** Preserve the five shipped face/chin caps and vectors unchanged. Phase 47's four public `0.25` cases, 413/413 decoded output inventory, 18/18 visibility/locality, 49/49 neighbor distinctions, 6/6 ineligible no-ops, and 4/4 no-face no-ops are immutable upstream evidence.

### Nine-Field Support, Degradation, and Transitions

- **D-06:** Treat the face inventory as exactly nine fields: shipped `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, signed `chinLength`, plus the four new fields. The five shipped fields retain the seven-point compatibility path. The three contour-only additions require observed contour eligibility, and `chinTaper` additionally requires centerline/apex eligibility.
- **D-07:** Missing/no face and stale geometry remove all nine final emissions, mark requested geometry domains skipped as established, and allow color/filter and other safe face-agnostic siblings to continue. Missing or malformed observed contour removes only the four new fields; missing/malformed centerline removes only `chinTaper`; the five shipped fields continue from their compatibility geometry.
- **D-08:** Eligible reused geometry applies the existing exact non-eye reuse scale `0.5` to all nine face fields. Reused support must still satisfy the same field-local provider eligibility; unsupported fields remain zero rather than borrowing cached, proxy, or sibling evidence.
- **D-09:** Provider-empty output is authoritative per field before and after conflict scaling. Empty work is removed before active domains, totals, counts, weakened evidence, warnings, metrics, geometry point counts, and dispatch; valid shipped/new siblings continue.
- **D-10:** Cover fresh->reused, reused->fresh, fresh->stale, stale->fresh, face->no-face, no-face->face, valid->missing contour, valid->malformed contour, valid->missing/malformed centerline, and valid->provider-empty transitions. Every resolve is stateless: no prior strength, vector, support, warning, metric, or active-domain value carries forward.
- **D-11:** Diagnostics remain fixed, aggregate, and redacted. Tests reject coordinates, contour/median/apex data, bounds, source indices, detector/provider types, image bytes, paths, per-field failure payloads, and identity/biometric-profiling claims.

### One-Baseline 37-Field Convergence

- **D-12:** Combined geometry uses one provider-eligible retained baseline for exactly nine face/chin, fourteen eye, six nose, and eight mouth fields. A fully eligible exact-cap fixture has unscaled total `11.70`, retained count `37`, and scale `1 / 11.70`; signed values retain polarity.
- **D-13:** The convergence loop is monotonic and bounded by exactly 37 possible field removals. Each field may be removed once; no removed field re-enters and no retained field receives a second weakening path.
- **D-14:** Preflight and final-scale sanitization must agree with final effective strengths and emitted control points. Unsupported or below-provider-threshold fields contribute zero to total, count, weakened count, scale, warnings, metrics, active domains, geometry-point count, and dispatch.
- **D-15:** Exact complete and representative removal fixtures must state retained totals/counts/scales and compare final strengths with face/chin/eye/nose/mouth named emissions from the same converged mask. No new public total/count metric is added.

### Fail-Closed Boundary and Evidence Gate

- **D-16:** Create a Phase 48-owned standard-library Python checker with `--self-test`, default pre-promotion live mode, `--allow-promotion`, optional fixture root, and owner/status/artifact gates. It distinguishes subprocess match/no-match/error states, rejects wrong roots/symlinks/scope escapes, classifies every active-source match, and includes positive plus one-failure-per-boundary fixtures.
- **D-17:** Both live modes fail closed on public/SPI observed-support types, raw/derived face geometry leakage, Codable/persistence/cache state, Demo or renderer imports of internal SDK targets, network/cloud behavior, account/payment/VIP/entitlement/commercial paths, new dependencies/package targets/render passes, 52-field compatibility drift, unclassified active-source matches, and tracked/staged/non-ignored generated output/gallery/quarantine artifacts.
- **D-18:** Default live mode requires all four target rows unpromoted and branch `脸型` partial. `--allow-promotion` replaces only that guard and requires exactly the four named rows implemented, the three semantic-region rows future with their blocker, branch `脸型` partial, complete SAFE/DOC evidence, finalized validation/review/security/verification, synchronized owners, and no lifecycle/readiness overclaim.
- **D-19:** Before promotion, run nonzero focused suites, full `swift test --package-path BeautySDK`, the unchanged Phase 47 strict helper/self-test and gallery containment gates, checker compile/self-test/default live, standard review, ASVS L1 with HIGH blocking and `threats_open: 0`, validation rows, active-source/artifact scans, and `git diff --check`. Any unavailable required gate blocks promotion and must be recorded honestly.

### Atomic Four-Row Promotion and Owner Synchronization

- **D-20:** Promotion is one evidence-gated transaction. Mark exactly `面部流畅` (`faceContourSmooth`), `太阳穴` (`templeFullness`), `颧骨` (`cheekboneSlim`), and `尖下巴` (`chinTaper`) implemented. Every row cites Phase 45 contract/support, Phase 46 provider, Phase 47 output, and Phase 48 safety/boundary evidence.
- **D-21:** Keep `去双下巴`, `去双下巴 Pro`, and `发际线` future because the approved local semantic-region implementation and reproducible clean-clone fixtures do not exist. Keep branch-level `脸型` partial. Preserve the five previously implemented face/chin rows unchanged.
- **D-22:** Synchronize the four authoritative blueprint owners, current example-image owners, root architecture/design/security/reliability/product/quality contracts, `PLANS.md`, and `.planning/{PROJECT,ROADMAP,REQUIREMENTS,STATE}.md`. Phase 48 closes the phase and hands off to the independent milestone audit; it does not itself claim audit/archive/tag/cleanup or release readiness.

### the agent's Discretion

- Choose the smallest table-driven XCTest extensions and helper/evidence structure that follow Phase 40/44. Keep product/status owners read-only until runtime, convergence, output, boundary, review, security, and validation gates are green.

</decisions>

<canonical_refs>
## Canonical References

- `AGENTS.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`
- `.planning/phases/45-public-contract-and-observed-face-support/{45-CONTEXT.md,45-VERIFICATION.md}`
- `.planning/phases/46-independent-contour-and-chin-geometry/{46-CONTEXT.md,46-VERIFICATION.md,46-SECURITY.md}`
- `.planning/phases/47-public-facade-face-output-evidence/{47-CONTEXT.md,47-FACE-OUTPUT-EVIDENCE.md,47-VERIFICATION.md,47-SECURITY.md,check_face_geometry_renderer_outputs.py}`
- `.planning/milestones/v1.11-phases/44-eye-geometry-safety-and-ledger-closeout/` and `.planning/milestones/v1.10-phases/40-mouth-geometry-safety-and-ledger-closeout/`
- `BeautySDK/Sources/BeautyEffects/Planning/{BeautySafetyCaps.swift,BeautyEffectResolver.swift,BeautyEffectPlan.swift}`
- `BeautySDK/Sources/BeautyEffects/Warp/{FaceShapeWarpProvider.swift,ChinWarpProvider.swift,GeometryConflictResolver.swift}`
- `BeautySDK/Tests/BeautyEffectsTests/{BeautySafetyCapsTests.swift,BeautyEffectResolverTests.swift,FaceShapeWarpProviderTests.swift,MissingLandmarkDegradationTests.swift,GeometryConflictResolverTests.swift,CombinedEffectSafetyTests.swift}`
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`
- `docs/meitu-function-blueprint/{SHAPE_FEATURE_LEDGER.md,FEATURE_MATRIX.md,EXAMPLE_IMAGE_VALIDATION.md}`
- `docs/meitu-function-blueprint/features/beauty-shaping/{README.md,face-shape/README.md}`
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`

</canonical_refs>

<code_context>
## Existing Code Insights

- The four intended final constants already exist at `0.25`; production change should normally be only the ownership comment after exact tests pass.
- `FaceShapeWarpFieldEmissions` and `ChinWarpFieldEmissions` expose all nine fields independently and sanitize unsupported work field-locally.
- `BeautyEffectResolver.resolveGeometryConflict` already uses one retained baseline and the exact `0..<37` monotone ceiling; `GeometryConflictResolverTests` already proves `11.70`, 37, and `1/11.70`.
- Reused non-eye geometry already scales by exact `0.5`; stale/no-face zero new face work, and provider preflight preserves shipped compatibility behavior.
- Phase 47's renderer/helper/gallery artifacts are pinned immutable regression evidence; generated PNGs remain ignored and disposable.
- Phase 40/44 provide the exact six-plan evidence-first closeout structure and hardened boundary-checker architecture.

</code_context>

<deferred>
## Deferred Ideas

- `去双下巴`, `去双下巴 Pro`, and `发际线` until an approved bundled local semantic-region implementation and reproducible clean-clone fixtures exist.
- Demo UI, new public geometry/result types, semantic models/resources, network/cloud, account/payment/entitlement interpretation, tracked media baselines, physical-device/commercial approval, optimized performance, packaging, shipping, and launch readiness.

</deferred>

---

*Phase: 48-face-safety-and-scoped-closeout*
*Context gathered: 2026-07-24 via autonomous smart discuss*
