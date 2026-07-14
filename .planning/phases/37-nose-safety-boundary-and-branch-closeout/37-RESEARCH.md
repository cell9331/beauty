# Phase 37: Nose Safety, Boundary, and Branch Closeout - Research

**Researched:** 2026-07-14
**Confidence:** HIGH
**Question:** What must the planner know to plan Phase 37 well?

## Executive Summary

Phase 37 is primarily a contract-completion and proof phase, not a new geometry-design phase. The current source already contains the intended exact `0.25` caps, six-field provider emissions, per-field sanitization, exact reused `0.5` scaling, stale/no-face zeroing, and monotonic provider/conflict convergence. The remaining work is to turn that implementation into exhaustive, requirement-named evidence; repair only behavior that the stronger matrix disproves; run final fail-closed gates; and then promote the two rows and SDK-core `鼻子` branch atomically.

The plan must not treat Phase 35's broad green tests as sufficient for NOSE-10 through NOSE-12. Existing tests prove many individual seams, but they do not yet provide one explicit all-six matrix for zero, no-face, missing support, provider-empty, stale, reused, and transitions; nor do they prove one exact integrated converged total/count/scale/emission result for the retained set. Phase 37 should add table-driven coverage around the existing implementation before considering production refactors.

Promotion is a final gated transaction. `山根`, `提升`, and branch-level `鼻子` remain unchanged until focused/full SwiftPM, the unchanged Phase 36 renderer/helper regression, ASVS L1, active-source, artifact, compatibility, current-owner, and diff-hygiene gates are all green. The later `$gsd-audit-milestone` remains a separate lifecycle action and its artifact must not be pre-authored here.

## Locked Planning Constraints

- Final exact caps are `BeautySafetyCaps.noseRootNarrowing == 0.25` and `BeautySafetyCaps.noseTipLift == 0.25`; public inputs remain positive-only `0...1`, with default and all non-finite inputs resolving to zero.
- The exact inventory is six fields: `noseSlim`, `noseWingSlim`, signed `noseTipSize`, `noseBridge`, `noseRootNarrowing`, and `noseTipLift`. Both signed tip directions are separate required evidence cases.
- Safety coverage must explicitly include zero, no-face, missing/insufficient field support, provider-empty, stale, reused, fresh-to-reused-to-stale transition, and valid-to-missing/provider-empty transition behavior.
- A field with no provider emission cannot survive in effective strengths, active-domain evidence, conflict total, weakened count, final scale, or final dispatch merely because a sibling emits.
- Reuse values before independent conflict weakening are exact: `0.175`, `0.175`, signed `±0.15`, `0.15`, `0.125`, and `0.125`.
- Conflict evidence describes one converged retained set. Count every retained field once, count a removed field zero times, preserve sign, and assert exact total, exact weakened count, exact scale, exact effective strengths, and final provider emissions.
- Security is ASVS L1 with HIGH blocking. Final `37-SECURITY.md` must contain `threats_open: 0`; any open HIGH blocks verification and promotion.
- Promotion is SDK-core scope only and is all-or-nothing after gates. No Demo, device, commercial-naturalness, performance qualification, packaging, shipping, launch-readiness, or broad parity claim is permitted.
- Phase 37 prepares a repository suitable for the subsequent audit. `$gsd-audit-milestone`, `$gsd-complete-milestone`, tagging, archival, and cleanup remain later lifecycle owners.

## Current Implementation and Evidence Map

### Already implemented in source

| Contract | Current source evidence | Planning implication |
| --- | --- | --- |
| Public semantics | `BeautyParameters` stores both new fields, clamps them positive-only to `0...1`, maps non-finite input to zero, and preserves the exact 33-field model. | Do not add or rename public fields. Add final-cap acceptance evidence, not another public-model redesign. |
| Exact caps and counts | `BeautySafetyCaps` already uses exact `0.25`; `BeautyEffectResolver` caps each field through `capUnit`, increments `cappedCount` once per overflowed field, and emits one aggregate `beauty_strength_capped` warning when the total is nonzero. | Lock exact values, counts, warning multiplicity, and metric keys with focused tests. Production code changes should be failure-driven. |
| Six-field provider eligibility | `NoseWarpFieldEmissions` has one emission array per nose field and `sanitizing(_:)` zeros each requested field independently when its own emission is empty. | Build the exhaustive table from these six explicit seams. Do not infer eligibility from aggregate `points`. |
| Independent support | `noseRootNarrowing` consumes only validated `noseRoot`; `noseTipLift` consumes only validated `noseTip`; legacy fields consume the legacy `nose` proxy. | Missing-support tests must use field-specific fixtures and prove siblings cannot lend support. |
| No-face/stale/reuse | Resolver `zeroNoseStrengths` zeros all six; no-face and stale paths use it; `scaleReusableNonEyeGeometryStrengths` scales all six by exact `0.5`. | Existing behavior is aligned, but all-six public-facade and transition assertions are missing. |
| Provider/conflict convergence | Resolver preflights nose and mouth fields, then runs a maximum-nine-pass monotonic retained-baseline loop. Fields can only be removed; `GeometryConflictResolver` recomputes scale and weakened count from the retained baseline. | Preserve this algorithm. Add exact integrated assertions and repair only if a new case finds divergence. |
| Diagnostics | Warnings are stable category messages; metrics are aggregate numeric values; no raw supports/control points are placed in the public plan. | Reuse the existing redaction assertions and expand forbidden payload scans rather than introducing per-field diagnostic detail. |

### Strong existing tests that should be extended

- `BeautySafetyCapsTests` asserts both exact `0.25` constants.
- `BeautyEffectResolverTests.testPhase35NOSE03ExactCapsRoutingWarningsAndCounts` covers overflow-to-cap for all nose fields and both signed tip directions. The same file covers negative positive-only no-ops.
- `MissingLandmarkDegradationTests.testPhase35NOSE03StaleZerosNoseWhileReusedScalesAllFieldsByHalf` already asserts the six exact reused values and all-six stale zeroing.
- Independent root/tip missing-support and supported-sibling cases exist, as do multiple legacy and displacement-based provider-empty cases.
- Phase 35 review regressions prove threshold-crossing removal for root, lift, and both signed tip-size directions and exact recomputed scale/count in selected fixtures.
- `CombinedEffectSafetyTests.testPhase35NOSE03EveryNoseFieldWeakensWithFaceEyeMouthAndPreservesDirection` covers five positive-only fields and both signed tip-size directions.
- `GeometryConflictResolverTests` proves the six new/legacy fields participate in totals/counts at the lower-level resolver seam.
- `BeautyEngineGeometryFacadeTests.testNoseNoFaceRequestPreservesExtentSafeDomainsAndRedactedMetadata` proves public-facade no-face behavior for the four legacy fields.
- Phase 36 already provides the immutable visible-output regression target: 36 cases × 7 fixtures = 252 outputs, 12 baseline comparisons, 6 root/bridge comparisons, 12 lift/signed-tip comparisons, and two new-field no-face checks.

## Missing Coverage and Likely Implementation Gaps

These are planning gaps, not claims that production behavior is currently wrong.

1. **NOSE-10 final-cap matrix is incomplete.** Existing tests cover exact constants, overflow, counts, and warnings, but there is no requirement-named table for both new fields covering zero, exact cap, public finite overflow, negative positive-only input, `NaN`, `+infinity`, and `-infinity`, with exact public normalized value, effective value, capped count, warning multiplicity, active/skipped domains, and aggregate metric keys. Exact-cap inputs must prove `cappedCount == 0`; only values above the effective cap increment it.

2. **Zero and no-face coverage is not all-six explicit.** Generic default/no-op tests exist, but they do not enumerate each of the six fields and prove no `.nose` activation, skip, vector, cap/weaken count, or misleading `nose_inputs_missing`. The public-facade no-face test still requests only the legacy four fields, so it must include the two new fields or be supplemented by an all-six facade case.

3. **Missing support/provider-empty coverage is rich but not exhaustive or uniform.** Root/tip and several legacy edge cases exist, yet there is no one six-field table asserting field-level effective zero, absent emission, removed conflict participation, sibling continuation, domain classification, warning behavior, and redaction using the narrowest correct support fixture for each field.

4. **Transition evidence is absent.** Current resolver calls are stateless, but the requirement still needs sequential fresh → reused → stale and valid → missing/provider-empty tests to demonstrate that no prior vector or strength is carried into the next plan/result. The plan should use consecutive resolver/facade invocations and compare each returned plan/emission set explicitly; it should not invent a cache or state machine.

5. **Combined coverage is directional but not exact enough.** The existing seven-entry combined matrix mostly asserts reduced magnitude and sign. Phase 37 needs exact expected totals/counts/scales and an all-six integrated fixture that compares the final effective strengths with `NoseWarpProvider.fieldEmissions` after convergence. Include a removed provider-empty field and a supported sibling so zero-times versus exactly-once accounting is observable.

6. **There is no public `geometryStrengthTotal` metric.** `GeometryConflictResolver` computes its total privately and publishes only weakened count and scale. The locked total can be proven in tests by summing the retained unscaled baseline with the same signed-absolute semantics and asserting `scale == 1 / total`; do not add a new public metric unless a failing acceptance check demonstrates that the current aggregate evidence is insufficient.

7. **Final status owners are intentionally stale.** `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, both shaping READMEs, `EXAMPLE_IMAGE_VALIDATION.md`, `QUALITY_SCORE.md`, project/GSD ledgers, and root contracts still describe provisional caps or the four-row partial branch. This is correct before gates. Their edits belong only in the last plan.

8. **The Phase 37 evidence artifacts do not exist yet.** Planning should produce tasks for a command-backed safety evidence file, `37-SECURITY.md`, `37-VALIDATION.md`, `37-VERIFICATION.md`, and review output. It must not create a v1.9 milestone-audit artifact.

## Recommended Test Design

Use typed table rows rather than repeated one-off XCTest methods:

- A nose-field descriptor should carry the public parameter writable key path, effective-strength key path, provider-emission key path, cap, signed/positive-only policy, valid fixture, missing-support fixture, and exact reused value.
- Treat signed `noseTipSize` as two direction rows for normalization, reuse, combined weakening, and transition checks.
- For provider-empty cases, assert all of: requested value existed before eligibility; final effective value is zero; its emission array is empty; `sanitizing(finalStrengths) == finalStrengths`; retained siblings remain nonzero and emit; final domain/warnings reflect the converged set; final weakened count and scale exclude the removed field.
- For transitions, capture and compare each result independently. Assert stale/missing/provider-empty outputs do not equal or contain the preceding fresh emissions and that effective strengths are derived only from the current input/geometry.
- Reuse the existing `assertRedacted` helpers, but extend forbidden data categories to coordinates, supports, bounds, paths, image bytes, detector objects, provider type names, and per-field failure payloads.
- Keep exact arithmetic expectations in one helper using the existing geometry-total semantics: positive magnitudes plus `abs` for signed fields. Avoid relational-only assertions for final caps and converged conflict evidence.

## Security and Boundary Strategy

The Phase 35/36 threat models and Phase 32/34 closeouts establish the pattern, but Phase 37 needs stricter active-source classification:

- Scan only asserted active source roots for public/SPI raw geometry, forbidden Demo/renderer internal-target imports, network/cloud APIs, account/payment/VIP/entitlement/commercial execution paths, diagnostic leakage, and unapproved dependencies.
- Treat `rg` exit `0` as matches requiring classification, `1` as no matches, and `>1` as a blocking scan failure. Do not use an unguarded negative `rg` whose command error can masquerade as success.
- Keep explicit allowlists for known static documentation/test guard literals. Archived `.planning/milestones/` evidence is read-only precedent, not active-source evidence and not a remediation target.
- Verify exact public inventory (`33 = 32 numeric + filterId`), no `Package.swift` dependency/target drift, no public/SPI `FaceGeometry`, supports, landmarks, bounds, `WarpControlPoint`, raw detector objects, or provider types.
- Verify `git ls-files` and staged-file queries return no generated output/gallery/staging/quarantine artifacts; representative generated paths must remain ignored.
- Run `git diff --check` and a scoped diff audit before setting `threats_open: 0` or editing promotion rows.

## Validation Architecture

Nyquist is enabled. The phase should use existing XCTest/Python infrastructure; no Wave 0 framework install is needed. Wave 0 is limited to adding the missing table helpers/fixtures and, if useful, an owned fail-closed boundary-check script whose self-test proves match/no-match/error handling.

### Focused commands

Run the narrowest relevant suite after each test/code task:

```bash
swift test --package-path BeautySDK --filter BeautySafetyCapsTests
swift test --package-path BeautySDK --filter BeautyEffectResolverTests
swift test --package-path BeautySDK --filter NoseWarpProviderTests
swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests
swift test --package-path BeautySDK --filter CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter GeometryConflictResolverTests
swift test --package-path BeautySDK --filter BeautyEngineGeometryFacadeTests
swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests
```

For production changes in the shared convergence path, also rerun mouth coverage because the loop is shared:

```bash
swift test --package-path BeautySDK --filter MouthWarpProviderTests
```

### Full/runtime/output commands

```bash
swift test --package-path BeautySDK
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output
python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py --self-test
python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py --input example-images/input --output example-images/output
python3 example-images/generate_gallery.py --self-test
```

The final output gate must observe the unchanged inventory unless the actual source inventory changes through separately authorized work: exactly 36 cases, seven fixtures, 252 decoded same-dimension outputs, 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 representative no-face checks. Generated PNGs remain ignored and untracked. Gallery generation itself is not required if the safe helper regression and containment gates prove the current owned route; if it is run, the Phase 36 quarantine protocol must be respected rather than recursively deleting preserved state.

### Wave ordering and sampling

1. **Wave 1 — exact caps and exhaustive six-field degradation/transition tests.** After every task, run the directly affected focused suite; at wave end run resolver, provider, degradation, facade, and safety-cap suites together.
2. **Wave 2 — exact combined convergence.** Depends on Wave 1 fixtures/helpers. After every task run combined/conflict/degradation/provider tests; if shared resolver code changes, add mouth provider/degradation coverage. At wave end run all focused Phase 37 suites.
3. **Wave 3 — full regression, output, security, and evidence.** Depends on Waves 1-2. Run full SwiftPM, renderer build/run, strict helper self-test/live run, boundary scans, artifact checks, review, ASVS, and diff hygiene. Record observed counts; copied historical counts are not evidence.
4. **Wave 4 — atomic promotion and owner synchronization.** Depends on a fully green Wave 3 and `threats_open: 0`. Apply exact row/branch/current-owner edits, rerun owner guards plus focused/full/runtime gates affected by any final code change, and finalize validation/verification. Route next to the independent milestone audit; do not perform it inside the phase.

Sampling rule: no more than one implementation task may pass without an automated focused command. Run the full focused aggregate after each wave, the full SDK suite before the evidence gate and again after any subsequent source change, and the owner/requirement/status scans after every closeout edit. A failed or zero-test command is blocking evidence, not a pass.

### Required evidence and blocking gates

| Gate | Required observed evidence | Blocks |
| --- | --- | --- |
| Exact caps | Exact `0.25`, exact normalized/effective values, counts, warnings, metric keys | Wave 2 and promotion |
| Six-field safety | All six plus both tip directions across zero/no-face/missing/provider-empty/stale/reused/transitions | Wave 3 and promotion |
| Convergence | Exact retained total, weakened count, scale, warning multiplicity, effective/emission equality | Wave 3 and promotion |
| Focused/full tests | Nonzero XCTest suites, zero failures; fresh full-suite count recorded | Promotion and verification |
| Phase 36 regression | Exact 36 × 7 and comparison counts from the live helper | Promotion and verification |
| Security | ASVS L1, no open HIGH, final `threats_open: 0` | Promotion and verification |
| Active-source boundaries | Fail-closed classified scans; exact inventory/dependency/import/privacy/artifact results | Promotion and verification |
| Promotion guards | Exactly six de-duplicated nose rows; only `山根` and `提升` change to implemented; SDK-core branch becomes implemented | DOC-01 completion |
| Owner synchronization | Every current owner links to observed Phase 35/36/37 evidence and preserves non-claims | Phase verification |
| Lifecycle boundary | No pre-authored audit/archive/tag/cleanup claim; next action is `$gsd-audit-milestone` | Phase completion |

Manual-only validation is intentionally empty. Subjective naturalness, device parity, and commercial approval are out of scope rather than manual gates for this phase.

## Recommended Four-Plan Decomposition

### Plan 37-01 — Exact caps and exhaustive six-field safety

Cover NOSE-10 and most of NOSE-11. Add the exact two-field cap/normalization/count/warning/metric table, all-six zero/no-face/missing/provider-empty/stale/reused coverage, and both transition families. Prefer test-first characterization; touch resolver/provider code only for failures against locked behavior.

### Plan 37-02 — Exactly-once converged combined geometry

Cover NOSE-12 and the convergence portion of NOSE-11. Add direction-complete face/eye/mouth/nose cases and one exact all-six retained/removed fixture. Assert total/count/scale/warning/effective/emission equality and regress previously shipped face/eye/nose/mouth policies.

### Plan 37-03 — Command-backed runtime, output, security, and boundary evidence

Cover NOSE-13 and establish the promotion gate for NOSE-14/DOC-01. Run the focused/full suites, unchanged Phase 36 renderer/helper regression, fail-closed active-source scans, compatibility/dependency/import/privacy/artifact checks, code review, and ASVS L1 closeout. Produce Phase 37 safety/security/review evidence with `threats_open: 0`; do not promote yet.

### Plan 37-04 — Atomic SDK-core promotion and current-owner closeout

Cover NOSE-14 and DOC-01 only after Plan 37-03 is green. Promote `山根` using only `noseRootNarrowing` evidence and `提升` using only `noseTipLift` evidence, then mark the exact six-row SDK-core `鼻子` branch implemented. Synchronize each authoritative owner only for its contract, finalize validation/verification/state, preserve every non-claim, and hand off to the subsequent independent milestone audit.

All four plans should be sequential. The dependency order is the safety property: tests and exact convergence first, command-backed/security gates second, promotion last.

## Planning Pitfalls

- Do not rewrite the archived Phase 32/34 artifacts or use the four-field v1.7 evidence to prove the new rows.
- Do not equate aggregate provider points with per-field eligibility; inspect `NoseWarpFieldEmissions` arrays.
- Do not add a second weakening pass or manually scale fields outside the existing resolver/convergence path.
- Do not use only `<= 0.25`, “less than independent,” or nonzero assertions where exact values/counts/scales are locked.
- Do not promote documentation in the same task that is still discovering whether runtime/security gates pass.
- Do not let a scan's tool error become a false no-match success.
- Do not turn excluded device/commercial/readiness work into a manual verification blocker.
- Do not claim milestone audit completion from Phase 37 verification; audit findings may still require a later DOC-01 remediation cycle, as the v1.6/v1.8 precedents demonstrate.

## Canonical Planning Inputs

The planner should read the exact files listed in `37-CONTEXT.md`, with special attention to:

- Current implementation: `BeautyEffectResolver.swift`, `GeometryConflictResolver.swift`, `NoseWarpProvider.swift`, `BeautyParameters.swift`, `BeautyEffectPlan.swift`.
- Focused tests: `BeautySafetyCapsTests.swift`, `BeautyEffectResolverTests.swift`, `NoseWarpProviderTests.swift`, `MissingLandmarkDegradationTests.swift`, `CombinedEffectSafetyTests.swift`, `GeometryConflictResolverTests.swift`, `BeautyEngineGeometryFacadeTests.swift`.
- Phase 35 convergence history: `35-VERIFICATION.md`, `35-SECURITY.md`, `35-REVIEW-FIX.md`.
- Phase 36 fixed output contract: `36-NOSE-OUTPUT-EVIDENCE.md`, `36-VERIFICATION.md`, `36-SECURITY.md`, `36-REVIEW-FIX.md`, and the strict helper.
- Closeout precedents: archived Phase 32 for nose-specific gates and archived Phase 34 for the compact three-plan safety/boundary/docs split. Use their structure, not their old counts or statuses.
- Promotion owners: `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, nose and shaping READMEs, `EXAMPLE_IMAGE_VALIDATION.md`, root contracts, quality/project/work ledgers, and current GSD state.

## Research Conclusion

Plan Phase 37 as a four-wave proof-and-promotion transaction around existing code. The highest-value implementation work is an exhaustive reusable six-field test matrix plus an exact integrated convergence fixture. The highest-risk operational mistake is premature promotion or a fail-open scan. Keeping promotion last, security HIGH-blocking, and the milestone audit outside the phase preserves every locked decision and gives the later audit a coherent repository to evaluate.

