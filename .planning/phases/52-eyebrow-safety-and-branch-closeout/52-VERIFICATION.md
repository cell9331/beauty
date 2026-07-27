---
phase: 52-eyebrow-safety-and-branch-closeout
verified: 2026-07-27T05:45:55Z
status: gaps_found
score: 12/16 must-haves verified
overrides_applied: 0
gaps:
  - truth: "The seven-field cap/dead-zone/direction/radius oracle exercises production-valid, canonically ordered observed eyebrow support."
    status: failed
    reason: "The shared and duplicated provider fixtures reverse the production inner-to-outer endpoint meaning, and the adjacency fixtures use 0.0004-wide traces that the production adapter rejects below its 0.08 minimum chord. Passing tests therefore do not prove the claimed real support-path behavior."
    artifacts:
      - path: "BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift"
        issue: "Default traces label anatomically outer points as inner endpoints; adjacency traces bypass BeautyFaceGeometryAdapter with adapter-ineligible chords."
      - path: "BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift"
        issue: "Maintains the same reversed direct FaceGeometry trace helper instead of consuming an adapter-validated canonical fixture."
    missing:
      - "Construct the shared safety traces through BeautyFaceGeometryAdapter.validatedBrowTrace or an equivalent production mapping fixture."
      - "Use adapter-valid chord/span values and assert inner endpoints are closer to face center than outer endpoints."
      - "Reuse the corrected canonical fixture in EyebrowWarpProviderTests and rerun SAFE-01 evidence."
  - truth: "Parallel and interrupted eyebrow work enters the request path and cannot leak support, warnings, metrics, or results into concurrent or subsequent requests."
    status: failed
    reason: "The cancellation branch cancels a throwing Task.sleep before BeautyEffectResolver.resolve executes. It proves cancellation of the artificial delay, not isolation during resolver/provider/facade work."
    artifacts:
      - path: "BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift"
        issue: "Lines 1297-1308 never reach the resolver after immediate cancellation."
    missing:
      - "Use a deterministic barrier proving the request entered the actual asynchronous request/facade path before cancellation."
      - "Verify the cancelled request is discarded or completed safely, then verify concurrent and subsequent request identities and aggregate diagnostics."
  - truth: "Late provider-empty eyebrow removal is exercised through the production 44-pass retained-baseline convergence path with no re-entry or double scaling."
    status: failed
    reason: "The named test manually calls GeometryConflictResolver, provider sanitization, and GeometryConflictResolver again. It never calls BeautyEffectResolver.resolveGeometryConflict; its half-ULP expected value also uses a full-ULP tolerance, so an incorrect zero passes."
    artifacts:
      - path: "BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift"
        issue: "Lines 88-128 reproduce an approximation of the algorithm instead of executing the production convergence loop, with an ineffective numeric assertion."
    missing:
      - "Drive every eyebrow row through the real resolver convergence path using adapter-valid precision-boundary geometry, or expose the production helper through a testable internal seam."
      - "Assert a strictly nonzero pre-sanitization scaled value with accuracy smaller than that value, final field removal, and no re-entry on repeated resolution."
  - truth: "Runtime, output, privacy/security, review, validation, product, and planning evidence all agree before the seven-row promotion remains accepted."
    status: failed
    reason: "The final standard review is status issues_found with three unresolved warnings, while PROJECT, REQUIREMENTS, STATE, and PLANS still claim a clean review and complete requirements. Before this corrected report, the independent final checker failed its standard-review gate at 34/35; with this report truthfully set to gaps_found it fails the review and expected verification-status gates at 33/35. The required evidence agreement does not hold."
    artifacts:
      - path: ".planning/phases/52-eyebrow-safety-and-branch-closeout/52-REVIEW.md"
        issue: "status: issues_found; warning: 3."
      - path: ".planning/PROJECT.md"
        issue: "Still claims clean review and all Phase 52 requirements complete."
      - path: ".planning/REQUIREMENTS.md"
        issue: "SAFE-01 and SAFE-02 remain checked complete despite evidence gaps."
      - path: ".planning/STATE.md"
        issue: "States no active Phase 52 blocker despite the failed final checker."
    missing:
      - "Resolve WR-01 through WR-03, rerun the affected focused suites and full regression, and obtain a clean follow-up review."
      - "Rerun check_eyebrow_safety_boundaries.py --allow-promotion to 35/35."
      - "Only then resynchronize requirement, project, state, PLANS, validation, quality, and verification claims."
---

# Phase 52: Eyebrow Safety and Branch Closeout Verification Report

**Phase Goal:** Freeze conservative behavior and promote exactly the seven eyebrow rows only after runtime, output, privacy, and owner evidence agree.
**Verified:** 2026-07-27T05:45:55Z
**Status:** gaps_found
**Re-verification:** No — initial goal-backward verification of the final post-review repository state. This report supersedes the earlier pre-final-review passing record.

## Verdict

Phase 52 does not currently satisfy its goal. The production cap/provider code,
strict public output, privacy boundaries, exact product-row transaction, and
owner documents are largely present. However, the final review found three
observable test-evidence defects in mandatory SAFE-01/SAFE-02 claims, and the
complete Phase 52 checker failed its clean-review gate at 34/35 before this
report and now reports 33/35 because it also correctly observes this
`gaps_found` verification status.

The warnings are phase-goal blockers, not merely non-blocking debt:

- WR-01 invalidates the production-path eligibility of the shared SAFE-01
  oracle.
- WR-02 leaves the explicit interrupted-request isolation truth untested.
- WR-03 leaves the explicit late-removal production convergence truth untested.
- Their unresolved presence makes the review/evidence/owner transaction
  disagree, directly contradicting the phase goal and Plans 52-03, 52-04, and
  52-06.

The fresh post-review full SwiftPM result (450 executed, six opt-in skips, zero
failures) and wave-by-wave Demo simulator build/test results are valuable
regression evidence, but they do not close these gaps: all three defective
tests pass while failing to exercise the behavior named by their assertions.

## Goal Achievement

### Observable Truths

The ROADMAP success criteria were merged with all six plans' frontmatter
truths and deduplicated into sixteen observable must-haves. ROADMAP criteria
remain non-negotiable.

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Seven exact final caps, the exact ULP dead zone, correct direction semantics, bounded radii, and provider maxima are proved through production-valid support. | ✗ FAILED | Source has seven exact `0.25` caps and named provider bindings, but `EyebrowSafetyFixtures.swift:129-138,188-240` reverses endpoint semantics and bypasses the adapter with rejected 0.0004 chords. WR-01 therefore breaks the claimed SAFE-01 oracle. |
| 2 | Fresh, reused, stale, no-face, missing, malformed, provider-empty, sign-transition, and valid-invalid-valid calls are stateless. | ✓ VERIFIED | Real resolver tests cover these sequences and field-local effective results; the review did not identify a defect in these non-cancellation paths. |
| 3 | Parallel and interrupted work cannot leak request-local eyebrow support or results. | ✗ FAILED | Parallel requests execute the resolver, but the cancellation branch throws from `Task.sleep` before resolver/provider work begins (`MissingLandmarkDegradationTests.swift:1297-1308`). |
| 4 | Side/pair/chord/apex failures remove only dependent eyebrow work while safe eyebrow and unrelated domains continue with aggregate-only diagnostics. | ✓ VERIFIED | Resolver/provider/facade source and executable tests show pair-only spacing, per-side continuation, apex-local peak removal, safe siblings, stable extent, and redacted aggregate diagnostics. |
| 5 | The final geometry inventory is exactly 44 unique fields in stable 9/14/7/6/8 domain order. | ✓ VERIFIED | `GeometryConflictResolver` contains all 44 assignments/totals/counts; the final ordered test oracle has 44 unique names. |
| 6 | Final-cap arithmetic is exactly 3.35 + 4.10 + 1.75 + 1.80 + 2.45 = 13.45, with count 44, one `1 / 13.45` scale, final total 1, and preserved signs. | ✓ VERIFIED | Production shared resolver and `GeometryConflictResolverTests` exercise threshold adjacency, exact total/count/scale, warning, and signed polarity. |
| 7 | Late provider-empty eyebrow work is removed through the production retained-baseline loop with at most 44 monotone removals, no re-entry, and no second scaling pass. | ✗ FAILED | The source loop exists, but the Phase 52 late-removal test manually reconstructs a different path and uses a tolerance that accepts zero (`CombinedEffectSafetyTests.swift:88-128`). WR-03 leaves the required production behavior unproved. |
| 8 | Final effective strengths, totals, counts, warnings, metrics, named emissions, point count, and unified Face→Chin→Eye→Eyebrow→Nose→Mouth dispatch agree. | ✓ VERIFIED | Real resolver requests, all-44 final-mask assertions, named provider arrays, and pipeline exact-array/order tests are wired and passing. |
| 9 | The Phase 52 checker fails closed on command, path, source, public/SPI, privacy, dependency, artifact, status, concurrency, interruption, and lifecycle ambiguity. | ✓ VERIFIED | Independent `--self-test` passes 130/130; live final mode fails rather than inferring success from the non-clean review. |
| 10 | Fresh runtime, strict output, gallery, containment, and fourteen-image evidence agree with the frozen cap output. | ✓ VERIFIED | Repository evidence records 450 full tests/6 skips/0 failures, 72/72 portrait outputs, thirteen no-face comparisons, 13/13 visibility, 6/6 direction, 21/21 distinctions, 40/40 direct checks, 144/144 output/gallery files, and 14/14 reviewed images. |
| 11 | Standard review is clean, fourteen-task Nyquist is complete, ASVS L1 has zero open threats, and no unresolved evidence assumption remains. | ✗ FAILED | Nyquist and ASVS markers are present, but `52-REVIEW.md` is `issues_found` with three unresolved warnings; `--allow-promotion` reports `FAIL: standard review` (34/35 before this corrected report; 33/35 afterward because passed-verification status is also correctly absent). |
| 12 | Exactly seven named eyebrow rows and branch `眉毛` are implemented atomically at SDK-core scope. | ✓ VERIFIED | Ledger rows 113-119 are exactly the seven names; matrix and both branch READMEs mark only the SDK-core eyebrow branch implemented. |
| 13 | Each promoted row cites the Phase 49→50→51→52 chain while later milestones and UI/device/commercial/release/lifecycle claims remain excluded. | ✓ VERIFIED | Product-owner text contains the four-phase lineage and explicit SDK-core/nonclaim boundaries. |
| 14 | Example and routed root owners agree on exact 72/13/144 vocabulary, caps, lifecycle, convergence, privacy, product scope, and limitations. | ✓ VERIFIED | Example, architecture, design, security, reliability, product, and quality owner modes pass inside the final checker. |
| 15 | Requirements, roadmap, project, state, PLANS, validation, evidence, and verification agree one-to-one. | ✓ VERIFIED WITH GAP NOTE | Counts and links are present (four requirements, six plans), but their passing dispositions are stale relative to the final review; that contradiction is classified separately in truth 11 and gap 4. |
| 16 | Phase completion hands off only to an independent v1.13 audit and does not claim audit/archive/tag/cleanup or broader readiness. | ✓ VERIFIED | ROADMAP/PROJECT/STATE/PLANS and checker lifecycle scans consistently preserve the independent-audit-only handoff and broader nonclaims. |

**Score:** 12/16 truths verified

## Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `BeautySafetyCaps.swift` | One final authority for seven caps | ✓ VERIFIED | Seven exact `0.25` constants; provider binds each named constant. |
| `EyebrowWarpProvider.swift` | Seven substantive named, bounded emissions | ✓ VERIFIED | Seven named arrays, finite/unit/radius guards, side/pair/apex prerequisites, and shared cap authority are wired to the resolver and pipeline. |
| `EyebrowSafetyFixtures.swift` | Shared production-faithful seven-row oracle | ✗ PARTIAL | Seven substantive rows exist, but canonical endpoints are reversed and adjacency support cannot pass the production adapter. |
| `EyebrowWarpProviderTests.swift` | Cap/dead-zone/direction/radius evidence | ✗ PARTIAL | Substantive and executable, but duplicates the reversed direct-support helper and consumes adapter-ineligible adjacency fixtures. |
| `MissingLandmarkDegradationTests.swift` | Lifecycle, transition, concurrency, interruption evidence | ✗ PARTIAL | All non-interruption paths are substantive; cancellation exits before request work. The generic artifact query's missing lowercase `validInvalidValid` is a casing false negative—the two real `ValidInvalidValid` tests exist. |
| `GeometryConflictResolverTests.swift` | Exact inventory/arithmetic oracle | ✓ VERIFIED | Substantive exact 44/13.45/count/scale/sign assertions. |
| `CombinedEffectSafetyTests.swift` | Production monotone final-mask proof | ✗ PARTIAL | Real final-mask and dispatch cases exist, but the required late-removal row bypasses the production loop. |
| `BeautyGeometryEffectPipelineTests.swift` | Exactly-once stable dispatch proof | ✓ VERIFIED | Explicit source order and exact concatenation assertions. The generic regex query is a formatting false negative; manual source trace verifies the link. |
| `check_eyebrow_safety_boundaries.py` | Fail-closed final checker | ✓ VERIFIED | Self-test 130/130; final mode correctly blocks on review. |
| `52-EYEBROW-SAFETY-EVIDENCE.md` | Fresh runtime/output/visual/containment ledger | ✓ VERIFIED | Substantive hash/count/image evidence; no raw geometry or pixel bytes. |
| `52-REVIEW.md` | Clean final standard review | ✗ FAILED | Current final artifact is `status: issues_found`, critical 0, warning 3. |
| `52-SECURITY.md` | ASVS L1 closure | ✓ VERIFIED | `threats_open: 0`; the final review found no production security/privacy defect. |
| `52-VALIDATION.md` | Fourteen green Nyquist rows | ✓ VERIFIED WITH GAP NOTE | All rows are green, but three rows rely on tests the final review shows are not behaviorally faithful. |
| Four product blueprint owners | Exact seven-row/branch SDK-core transaction | ✓ VERIFIED | Exact rows and branch are present with evidence lineage/nonclaims. |
| Example/root owner set | Routed contract synchronization | ✓ VERIFIED | All bounded owner modes pass. |
| REQUIREMENTS/ROADMAP/PROJECT/STATE/PLANS | Exact closeout and audit handoff | ✗ PARTIAL | Counts and handoff are correct; clean-review and SAFE-01/02 completion claims are stale. |

## Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `BeautySafetyCaps.swift` | `EyebrowWarpProvider.swift` | Seven named cap bindings | ✓ WIRED | Manual source trace finds all seven constants at provider lines 50-56; generic query failure was caused by escaped-pattern handling. |
| Observed Vision eyebrow support | `BeautyFaceGeometryAdapter` | Canonical mapping and validation | ✓ WIRED | Phase 49 production and verification establish actual request-local support and 0.08...0.50 chord validation. |
| `EyebrowSafetyFixtures.swift` | Production adapter contract | Adapter-valid canonical construction | ✗ NOT WIRED | Direct semantic traces bypass the adapter and contradict its endpoint/chord contract. |
| Public parameters | Resolver/provider | Normalization, caps, freshness, sanitization | ✓ WIRED | Same-named fields flow through effective strengths and named provider emissions. |
| Cancellation task | Actual request path | Enter request work before cancellation | ✗ NOT WIRED | Throwing sleep precedes the resolver call. |
| Late-removal test | `resolveGeometryConflict` production helper | Real retained-baseline execution | ✗ NOT WIRED | Test manually calls lower-level pieces; private production loop is never invoked by that case. |
| Final strengths | Named emissions/metrics | One retained mask | ✓ WIRED | Real resolver all-44 and pair/per-side/reuse tests compare final provider work and accounting. |
| Named emissions | Unified pipeline | Stable provider order | ✓ WIRED | Source and pipeline tests prove Face→Chin→Eye→Eyebrow→Nose→Mouth exactly once. |
| Strict outputs | Evidence/gallery | Frozen helper and exact bijection | ✓ WIRED | 72/13/144 vocabulary and containment are present. |
| Final review | Final checker | Clean-review precondition | ✓ WIRED, FAILING | Checker observes `issues_found`; it returned 34/35 before this report and 33/35 after the report also truthfully removed passed-verification status. |
| Safety evidence | Product owners | Exact four-phase lineage | ✓ WIRED | Exact seven ledger rows and branch cite the evidence chain. |
| Product/planning owners | Audit handoff | Independent-audit-only next step | ✓ WIRED | All lifecycle scans pass. |

## Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `EyebrowWarpProvider.swift` | Seven named control-point arrays | Adapter-produced request-local semantic support plus final strengths | Yes on the public facade path | ✓ FLOWING |
| `EyebrowSafetyFixtures.swift` | `pairedSupport` / adjacency faces | Direct test construction, bypassing adapter | Not production-eligible for the reviewed cases | ✗ HOLLOW TEST INPUT |
| `MissingLandmarkDegradationTests.swift` cancellation branch | Cancelled request result | Throwing `Task.sleep` | No resolver/provider data is produced | ✗ DISCONNECTED |
| `CombinedEffectSafetyTests.swift` late-removal branch | Removed retained baseline | Manually composed conflict/provider calls | Does not execute the production helper | ✗ DISCONNECTED |
| Public renderer output | Decoded `e6` images | Public facade, actual support path, unified warp | Yes | ✓ FLOWING |
| Product/owner status | Implemented seven-row state | Evidence ledger plus checker/review gates | Review source currently disagrees | ✗ BLOCKED AGREEMENT |

## Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Checker adversarial behavior | `python3 .../check_eyebrow_safety_boundaries.py --self-test` | `SELF-TEST PASS: 130/130 adversarial checks` | ✓ PASS |
| Complete final evidence gate | `python3 .../check_eyebrow_safety_boundaries.py --allow-promotion` | `FAIL: standard review: clean=0`; expected secondary `FAIL: planning completion/audit handoff: verification`; `RESULT: 33/35 checks passed`; exit 1 | ✗ FAIL |
| Three disputed tests | Focused `swift test --filter` for WR-01/02/03 test methods | 3 executed, 0 failures in 0.005 s after build | ✗ MISLEADING PASS — confirms the tests pass but does not repair their missing production-path coverage |
| Full SwiftPM regression | Fresh orchestrator evidence after final review | 450 executed, 6 opt-in skips, 0 failures | ✓ PASS, non-closing |
| Demo simulator regression | Fresh orchestrator evidence after each completed wave | Build/test passed | ✓ PASS, out-of-phase-scope regression |
| Diff hygiene before report | `git diff --check` | Exit 0 | ✓ PASS |

## Probe Execution

No `probe-*.sh` path is declared by the six plans or summaries, and no
conventional project probe applies. The phase-declared Python checker was run
independently in self-test and final modes as recorded above.

## Requirements Coverage

| Requirement | Source Plans | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| SAFE-01 | 52-01, 52-02, 52-03, 52-05, 52-06 | Exact caps, dead zone, direction, and bounded radii | ✗ BLOCKED | Production constants/provider bindings and strict cap output exist, but the shared adjacent-strength/direction oracle uses reversed, adapter-ineligible support. |
| SAFE-02 | 52-01, 52-02, 52-03, 52-05, 52-06 | Stateless degradation/transitions, safe siblings, convergence | ✗ BLOCKED | Most lifecycle and final-mask behavior is covered, but interrupted request work and late provider-empty production convergence are not. |
| SAFE-03 | 52-03, 52-05, 52-06 | Fail-closed public/privacy/dependency/artifact/source gates with no unresolved HIGH | ✓ SATISFIED | Checker self-tests and live classifications fail closed; review reports zero critical/production security findings and ASVS has zero open threats. The checker correctly blocks the separate clean-review promotion precondition. |
| DOC-01 | 52-03, 52-04, 52-05, 52-06 | Exact seven-row and SDK-core branch promotion with nonclaims | ✓ SATISFIED | Exact row/branch transaction and nonclaims exist; acceptance remains blocked at the phase-goal evidence-agreement layer until SAFE-01/02 review gaps close. |

No Phase 52 requirement is orphaned: all four roadmap IDs appear in plan
frontmatter and traceability. There is no later phase in the current milestone
whose goal or success criteria specifically owns these gaps, so none is
deferred under Step 9b.

## Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | ---: | --- | --- | --- |
| `EyebrowSafetyFixtures.swift` | 129-138, 188-240 | Self-consistent but production-invalid oracle | 🛑 Blocker | Expected values can agree with reversed labels and impossible adapter input. |
| `MissingLandmarkDegradationTests.swift` | 1297-1308 | Test name overclaims exercised cancellation path | 🛑 Blocker | Resolver/provider interruption behavior is not executed. |
| `CombinedEffectSafetyTests.swift` | 88-128 | Manual algorithm duplication plus vacuous tolerance | 🛑 Blocker | Production convergence regressions can pass unnoticed. |
| `52-REVIEW.md` | frontmatter | `status: issues_found`, three warnings | 🛑 Blocker | Final review/evidence gate disagrees with promoted owner state. |
| `EyebrowWarpProvider.swift` | multiple guards | `return []` | ℹ️ Info | Classified fail-closed production behavior, not stubs. |

No unreferenced `TBD`, `FIXME`, or `XXX` marker was found in the Phase 52
production/test/checker set. Historical placeholder/debt wording in PLANS and
QUALITY_SCORE is explicitly historical and does not flow into Phase 52 runtime
or user-visible output.

## Disconfirmation Pass

- **Partially met requirement:** SAFE-01 has exact source caps and strict
  full-cap output, but its adjacent-dead-zone/provider fixture does not exist
  on the real adapter path.
- **Passing test that does not test its claim:** the cancellation test passes
  because cancellation stops `Task.sleep`; it never executes eyebrow work.
- **Untested error path:** late provider-empty removal through the actual
  private 44-pass convergence helper has no Phase 52 behavioral test.

These are not speculative uncertainties; each absence is directly observable
in the current test source. No override is present or appropriate.

## Human Verification Required

None. The required fourteen-image review is already recorded and agrees with
the strict output. The remaining gaps are deterministic code/test wiring
defects, not visual or external-service uncertainty.

## Gaps Summary

Four related blockers remain. Three are concrete test-evidence defects from the
final review; the fourth is their governance consequence: the final checker
rejects the now-non-clean review while planning/product owners continue to
claim clean, complete agreement. Because the phase goal explicitly conditions
promotion on runtime, output, privacy, and owner evidence agreeing, the phase
must not proceed to the independent v1.13 milestone audit until WR-01 through
WR-03 are fixed, the review is clean, the complete checker passes 35/35, and
the completion owners are resynchronized.

---

_Verified: 2026-07-27T05:45:55Z_
_Verifier: the agent (gsd-verifier)_
