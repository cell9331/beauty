---
phase: 90-face-contour-and-chin-repairs
verified: 2026-09-04T05:25:00Z
status: passed
score: 25/25 must-haves verified
overrides_applied: 0
---

# Phase 90: Chin Repair and Contour Deferral Verification Report

**Phase Goal:** The owner can rely on the proven chin-taper repair while the bounded `faceContourSmooth` attempt is closed honestly as deferred/partial without a false GREEN claim.
**Verified:** 2026-09-04T05:25:00Z
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

The runtime repair and the honest deferral are real, substantive, and wired.
All roadmap and PLAN truths pass. `ROADMAP.md` and `STATE.md` are intentionally
still at their pre-completion positions because the canonical execute-phase
workflow runs `verify_phase_goal` first and invokes `query phase.complete` only
after this report returns `passed`; their next-step mutation is workflow-owned
bookkeeping, not an implementation gap.

### Observable Truths

| # | Roadmap truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Positive `chinTaper` is detectable, centerline-gated, sibling-distinct, exactly capped, neutral, and source-safe. | ✓ VERIFIED | `ChinWarpProvider.swift:71-193` implements request-local centerline ownership, exact cap, X-only inward motion, apex exclusion, bilateral pairing, and fail-closed validation. Fresh focused execution passed `142/0/0`; generated Effects and public-facade tests assert real pixels, frozen ROI/direction/protection bounds, siblings, metadata, determinism, and recovery. |
| 2 | FACE-01 ends at revision 22 without retry, source/threshold/public/backend change, or GREEN claim; the callable safe field stays `partial` and future-authorized. | ✓ VERIFIED | `90-01-ATTEMPT.md` has one revision-22 suffix and no revision 23; diagnostic verifier hash is `7766f6d...d8c3f6` and all three self-tests pass. Temporary diagnostic symbols are absent. Current contour source and Phase 89 manifest/comparator/runner have no Phase-90 diff. Only the two safe/current contour tests ran; the frozen effectiveness test was deliberately excluded. Taxonomy and boundary checker both say `partial`. |
| 3 | Requirements, roadmap, project/state ledgers, taxonomy, owners, summaries, and gates agree on FACE-02 complete plus FACE-01 deferred. | ✓ VERIFIED | Requirements, PROJECT, PLANS, QUALITY_SCORE, five owner contracts, taxonomy, summaries, and all fresh gates agree semantically. The current `ROADMAP.md`/`STATE.md` progress markers are the expected pre-update state: canonical `execute-phase.md` routes `passed` from `verify_phase_goal` to `update_roadmap`, where `query phase.complete` marks the checkbox/count/status, advances STATE, and updates requirements traceability. Plan 90-04 Task 2 likewise reserves these writes for the orchestrator. |

**Score:** 25/25 merged roadmap/PLAN must-haves verified.

### PLAN Must-Haves Audit

| Plan | Result | Evidence |
| --- | --- | --- |
| 90-01 | 9/9 historical diagnostic/rollback truths verified | Immutable verifier hash and three self-tests pass; attempt record retains the exact terminal suffix; `prior_stop_not_reproduced`, `20/20` admissions, 20 final points, zero render/oracle, no revision 23, rollback, and temporary-symbol absence are durable. The later owner-authorized terminal summary is explicitly non-GREEN and completes no requirement. |
| 90-02 | 4/4 FACE-02 truths verified | Provider code and fresh generated provider/CPU/public-facade tests cover exact `0.25`, half strength, centerline ownership, pixels, sibling distinction, protections, deterministic neutral/repeat behavior, invalid support, redaction, and recovery. |
| 90-03 | 5/5 owner-contract truths verified | DESIGN, PRODUCT_SENSE, taxonomy, SECURITY, and RELIABILITY contain the exact Phase 90 sections and consistently preserve `62` fields, five presets, `75` cases, both facades, CPU/GPU policy, retained `Warp.metal`, privacy/non-distribution, and Phase 95 handoff. |
| 90-04 | 4/4 bounded-closeout truths verified | Predecessor, quality, completed-PLANS-entry, owner-contract, focused, compatibility, comparator, preflight, archive, boundary, regression, and diff gates all pass. The frozen FACE-01 effectiveness, live portrait, and complete no-skip commands were not run or credited. |

All three Roadmap Success Criteria and every additional PLAN truth are verified.
Roadmap criteria remain non-negotiable; their semantic contract is already
satisfied, while progress-position mutation belongs to the immediately
following canonical `phase.complete` step.

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift` | Substantive centerline-owned taper | ✓ VERIFIED | 253 lines; exact input validation, cap, displacement/radius/falloff, pairing, median interpolation, inward checks, and named-field fail-closed behavior. Wired into resolver and geometry pipeline. |
| `BeautySDK/Tests/BeautyEffectsTests/ChinTaperRepairTests.swift` | Generated provider and CPU semantic oracle | ✓ VERIFIED | 374 lines; five fresh tests pass, including actual 512×512 pixel measurements and frozen protection thresholds. |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineChinTaperRepairTests.swift` | Public-facade pixels, metadata, siblings, redaction, recovery | ✓ VERIFIED | 295 lines; three fresh tests pass through `BeautyEngine.processResult`. |
| `scripts/verify-phase90-face01-diagnostic.py` | Immutable diagnostic/rollback gate | ✓ VERIFIED | 1,178 lines; exact expected SHA-256 and all three independent self-test modes pass. |
| `.planning/phases/90-face-contour-and-chin-repairs/90-01-ATTEMPT.md` | Aggregate-only revision history and terminal revision-22 suffix | ✓ VERIFIED | 311 lines; exact terminal classification and zero-render/oracle boundary retained, with no private geometry or media evidence. |
| `BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift` | Retained callable/fail-closed contour source | ✓ VERIFIED | No Phase-90 source diff; two allowlisted safe/current tests pass. The frozen effectiveness method remains a deliberate RED and is not credited. |
| `DESIGN.md`, `PRODUCT_SENSE.md`, `SECURITY.md`, `RELIABILITY.md` | Consistent owner contracts | ✓ VERIFIED | Exact Phase 90 sections pass automated content/nonclaim checks. |
| `docs/SDK_EFFECT_TAXONOMY.md` | `chinTaper=implemented`, `faceContourSmooth=partial` | ✓ VERIFIED | Rows 99 and 105 plus the Phase 90 section match the current contract. |
| `scripts/check-sdk-only-boundary.sh` | Enforce current taxonomy and SDK-only boundary | ✓ VERIFIED | Expected tuple is `("脸型", "面部流畅", "partial", "faceContourSmooth")`; the Phase-90 commit changes exactly this tuple, and fresh post-archive scan passes. |
| `QUALITY_SCORE.md` and `PLANS.md` | Bounded evidence and terminal execution ledger | ✓ VERIFIED | Automated section assertions pass and preserve exact scope/nonclaims and Phase 91/95 handoffs. |
| `.planning/ROADMAP.md` and `.planning/STATE.md` | Workflow-owned phase/progress ledgers | ✓ VERIFIED (pre-update state) | Their semantic decisions agree. Execution/progress/session fields correctly remain pre-completion until this `passed` report returns; canonical `query phase.complete` must now advance them. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `BeautyParameters.chinTaper` | `BeautyEffectResolver` | normalization and `BeautySafetyCaps.chinTaper` | ✓ WIRED | Public field is normalized, decoded, copied, capped, counted, and included in geometry demand. |
| `BeautyEffectResolver` | `ChinWarpProvider` | field-local emission sanitization and final retained emissions | ✓ WIRED | Resolver invokes `fieldEmissions` before and after conflict resolution and removes only an empty named field. |
| `ChinWarpProvider` | `BeautyGeometryEffectPipeline` | exactly-once provider dispatch | ✓ WIRED | Pipeline concatenates `ChinWarpProvider().makeControlPoints(...)` into the unified warp. |
| Public facade | generated output bytes | detection → resolver → provider → CPU geometry render | ✓ WIRED | Fresh public-facade tests measure target pixels, signed Q16 direction, protected regions, metadata, redaction, and valid-invalid-valid recovery. |
| Phase 89 FACE-02 contract | independent test constants | `chinTaper_0p25`, `centerlineTaper`, exact ROI/sibling/threshold values | ✓ WIRED | Manifest and both test targets carry matching target/protection constants and sibling semantics; comparator/manifest had no Phase-90 change. |
| Terminal FACE-01 summary | owner contracts/taxonomy | completed-deferred, promotion-ineligible, zero requirement, FUTURE-04 | ✓ WIRED | Exact content assertions pass; no owner section promotes revision 22 or safe/current tests to effectiveness. |
| Taxonomy | boundary checker | exact legacy taxonomy tuple | ✓ WIRED | Both enforce `faceContourSmooth=partial`; boundary scan passes after archive verification. |
| Passed Phase 90 verification | ROADMAP/STATE progress | canonical `update_roadmap` → `query phase.complete` | ✓ WIRED (next workflow step) | `execute-phase.md` dispatches this mutation only after verifier status is `passed`; requiring it beforehand would create a circular impossible gate. |

### Data-Flow Trace (Level 4)

| Artifact | Data variable | Source | Produces real data | Status |
| --- | --- | --- | --- | --- |
| `ChinWarpProvider` | `chinTaper` control points | request-local observed contour, median line, apex, bounds, and effective strength | Yes — finite bilateral X-only points or empty named-field failure | ✓ FLOWING |
| `BeautyGeometryEffectPipeline` | unified control-point array | resolver-retained provider emissions | Yes — actual CPU pixel output is asserted | ✓ FLOWING |
| `BeautyEngineChinTaperRepairTests` | output RGBA bytes and result metadata | generated explicit-sRGB input through real public facade and testing detector | Yes — target/protection/sibling/neutral/repeat/recovery assertions pass | ✓ FLOWING |
| `faceContourSmooth` current field | current provider emission | request-local observed contour | Safe/current behavior only | ✓ FLOWING (partial by contract) |

### Behavioral Spot-Checks

| Behavior | Command | Fresh result | Status |
| --- | --- | --- | --- |
| Phase 90 focused chin + safe/current contour + geometry regression | Phase 90 focused SwiftPM filter | `142` executed, `0` failures, `0` skips | ✓ PASS |
| Phase 90 compatibility | Phase 90 compatibility SwiftPM filter | `154` executed, `0` failures, `1` existing Vision opt-in skip | ✓ PASS |
| Semantic comparator mutation gate | `swift scripts/compare-face-feature-batches.swift --self-test` | `PASS`, `mutations=554`, `inventories=5/65/8` | ✓ PASS |
| Inventory-only admission | `bash scripts/run-face-feature-batches.sh --preflight-only` | `PASS live=75 selected=65 semantic=8` | ✓ PASS |
| Archive trust | `python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui` | Both pinned hashes verified | ✓ PASS |
| SDK-only boundary | `bash scripts/check-sdk-only-boundary.sh --post-archive` | `POST-ARCHIVE SDK BOUNDARY PASSED` | ✓ PASS |
| Phase 88 regression | `swift test --package-path BeautySDK --filter BeautyEngineUpperEyelidFullnessIntegrationTests` | `4/0/0` | ✓ PASS |
| Phase 89 focused regression | Phase 89 62/5/75 compatibility filter | `107/0/0` | ✓ PASS |
| Runner adversarial boundary self-test | `python3 scripts/test-face-feature-batch-boundaries.py` | `PASS`; stale/alias/symlink/component/preflight probes passed | ✓ PASS |
| FACE-01 diagnostic verifier | SHA check plus three verifier self-tests | Expected hash; all self-tests pass | ✓ PASS |
| Diff hygiene | `git diff --quiet -- BeautySDK` and `git diff --check` | exit 0 | ✓ PASS |

The compatibility skip is the pre-existing authorized local Vision opt-in and
is not a Phase 90 skip. The live portrait command, frozen FACE-01 effectiveness
method, plain full SwiftPM run, and complete no-skip wrapper were intentionally
excluded by the approved phase contract.

### Probe Execution

No conventional or phase-declared `probe-*.sh` exists for Phase 90. The
phase-declared runnable checks are recorded under Behavioral Spot-Checks.

### Requirements Coverage

| Requirement | Source plan | REQUIREMENTS.md cross-reference | Status | Evidence |
| --- | --- | --- | --- | --- |
| FACE-02 | 90-02, 90-03, 90-04 | Active Face Shape requirement; Phase 90; marked Complete | ✓ SATISFIED | Real provider/public-facade pixels, exact cap/neutral/fail-closed behavior, sibling distinction, protection, compatibility, and boundary evidence all pass. |
| FACE-01 | 90-01 historical diagnostic plan | No current active ID exists. The 2026-09-02 owner contraction replaced it with FUTURE-04. | N/A — SUPERSEDED, NO COMPLETION CREDIT | `90-01-SUMMARY.md` has `requirements-completed: []`; REQUIREMENTS and ROADMAP explicitly route future contour repair to FUTURE-04. This is not an orphan active requirement and must not be counted as satisfied. |

No active Phase 90 requirement is orphaned: ROADMAP and REQUIREMENTS map only
FACE-02 to Phase 90. The stale `requirements: [FACE-01]` in the historical
diagnostic PLAN is preserved for provenance and is explicitly superseded by
FUTURE-04 rather than silently treated as active or complete.

### Exact Scope and Nonclaims

- In scope: existing owner-local opaque still-image facades; repaired
  `chinTaper`; unchanged callable/fail-closed `faceContourSmooth` classified
  `partial`; aggregate-only validation.
- Preserved: 62 stored parameter fields, five presets, 75 renderer cases, both
  still-image facades, CPU-reference/selectable-GPU policy, retained
  `Warp.metal`, Phase 89 thresholds and 75/65/8 inventory.
- Excluded from Phase 90: FACE-01 effectiveness/GREEN, live portrait
  publication, complete no-skip closeout, new public/backend/shader behavior,
  UI/Demo, realtime/video, model/weight/data/network work, and local-retouch
  changes.
- No device, population, performance, thermal, battery, endurance, commercial
  visual-quality, packaging, shipping, launch, release-readiness, or external
  distribution conclusion follows from this package-host evidence.
- Phase 95 owns the clean 65-output seven-effective-plus-one-deferred run, the
  all-opt-ins no-skip gate, and direct `Float.ulpOfOne.nextUp`, cap-adjacent,
  quantization-threshold-adjacent, and strict-tie tests. These are explicit
  later-phase responsibilities, not invented Phase 90 human checks.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| `ChinWarpProvider.swift` | 51, 89, 109, 120, 125, 140, 153, 167, 182, 190 | `return []` | ℹ️ Info | Validated fail-closed branches whose active data path is covered; not stubs. |
| `PLANS.md` Phase 90 section | historical revision-14 row | word `placeholder` | ℹ️ Info | Records a rejected temporary diagnostic scaffold and its stop; no placeholder remains in current production code. |

No unreferenced `TBD`, `FIXME`, or `XXX`, user-visible placeholder, empty
handler, console-only implementation, or hardcoded empty render source was
found in the Phase 90 executable artifacts or current owner sections.

### Disconfirmation Pass

- **Circular-bookkeeping false positive checked:** `ROADMAP.md` and `STATE.md`
  remain pre-completion by design. The canonical workflow reads verifier status
  first, routes only `passed` to `update_roadmap`, and then calls
  `query phase.complete`; Plan 90-04 Task 2 also assigns those writes to the
  orchestrator. This is not a phase artifact failure.
- **Misleading green checked:** the two passing FACE-01 tests prove only
  current emission/fail-closed behavior. The frozen rendered effectiveness
  test is not run and no contour effectiveness is credited.
- **Uncovered boundary checked:** one-step-above-neutral, cap-adjacent, and
  quantization tie branches are source-defined but not directly tested. The
  approved roadmap assigns them to Phase 95; no Phase 90 runtime claim is made
  for those residuals.

### Human Verification Required

None. Device behavior, subjective naturalness, population coverage, and
commercial visual quality are explicit nonclaims, not Phase 90 gates. The
approved phase contract relies on deterministic generated pixels and SDK-owned
automation and explicitly excludes the live portrait/final publication gate.

### Gaps Summary

No gaps. The implementation, tests, taxonomy, boundary checker, owner
documents, terminal summaries, and fresh automated evidence all support the
intended completed-FACE-02 plus deferred-FACE-01 outcome. The canonical
orchestrator must now run `query phase.complete` to advance ROADMAP, STATE, and
requirements tracking; that is the post-verification bookkeeping step enabled
by this `passed` result.

---

_Verified: 2026-09-04T05:25:00Z_
_Verifier: the agent (gsd-verifier)_
