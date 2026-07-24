---
phase: 46-independent-contour-and-chin-geometry
verified: 2026-07-23T10:48:04Z
status: passed
score: 18/18
requirements_verified: [GEOM-01, GEOM-02, GEOM-03, GEOM-04]
human_verification_required: false
---

# Phase 46: Independent Contour and Chin Geometry Verification

## Goal

Implement four independently observable contour/chin controls without aliasing the five shipped face fields.

## Verdict

**PASSED.** All 18 goal-backward truths, required artifacts, key links, four requirements, focused suites, full SwiftPM regression, privacy/scope checker, and phase-range diff hygiene are verified. Decoded image visibility and final safety/promotion are correctly absent because Phases 47 and 48 own them.

## Observable Truths

| # | Truth | Status | Evidence |
|---:|---|---|---|
| 1 | Smooth contour reduces local lateral irregularity without global shrink. | ✓ VERIFIED | Mean-centered neighbor-chord deltas, one shared bounded scale, preserved endpoints/extrema/Y values, and strict roughness-reduction tests pass. |
| 2 | Temple fullness is upper-lateral and outward. | ✓ VERIFIED | Named temple emission uses the two exact upper-lateral bands and every target increases distance from the contour axis. |
| 3 | Cheekbone slim is mid-lateral and inward. | ✓ VERIFIED | Named cheekbone emission uses disjoint mid-lateral bands and every target decreases distance from the contour axis. |
| 4 | Chin taper changes only apex-neighbor X positions. | ✓ VERIFIED | Complete contour/median/apex evidence gates two neighbor points; targets preserve Y and move toward interpolated median X. |
| 5 | All nine face/chin fields have independent named emissions. | ✓ VERIFIED | `FaceShapeWarpFieldEmissions` owns seven fields and `ChinWarpFieldEmissions` owns two; live checker reports 7/7, 2/2, and 2/2 methods. |
| 6 | The five shipped face/chin arrays are unchanged. | ✓ VERIFIED | Compatibility comparison tests pass with all four new strengths at zero and when emitted alongside the shipped fields. |
| 7 | New work requires observed support and never borrows the seven-point proxy. | ✓ VERIFIED | Contour-only, centerline-missing/ineligible, and proxy-only provider matrices pass field-locally. |
| 8 | Four effective strengths use exact provisional 0.25 caps. | ✓ VERIFIED | Resolver cap/overflow/zero/negative matrix and live source checker pass; owner docs call them provisional. |
| 9 | Every new public intent triggers the existing geometry facade route. | ✓ VERIFIED | `requiresFaceGeometry` includes all four fields; facade tests prove one detection route and positive aggregate evidence. |
| 10 | No-face and stale input zero all four new fields. | ✓ VERIFIED | Resolver/degradation matrices pass without reviving prior request state. |
| 11 | Eligible reused input applies exact non-eye 0.5 scaling. | ✓ VERIFIED | Every new field resolves from 0.25 to exact 0.125 with the existing generic reuse warning/metric. |
| 12 | Provider-empty work is removed before final evidence. | ✓ VERIFIED | Preflight and post-scale sanitization remove the corresponding baseline field; isolated provider-empty requests add no active/skipped domain, warning, metric, point, or dispatch evidence. |
| 13 | Conflict convergence is monotone and bounded by the exact 37-field inventory. | ✓ VERIFIED | Resolver contains one `0..<37` loop, removed fields never re-enter, and exact all-field total/count/scale tests pass. |
| 14 | Final accounting derives from one retained named-emission set. | ✓ VERIFIED | Strengths, total, count, scale, weakened count, domains, warnings, metrics, and point counts agree across resolver/conflict tests. |
| 15 | One existing unified geometry pipeline dispatches every final point once. | ✓ VERIFIED | Pipeline concatenates final face, chin, eye, nose, and mouth provider points; the exact dispatch oracle passes. |
| 16 | Observed support remains request-scoped and diagnostics remain aggregate-only. | ✓ VERIFIED | No public/Codable/cache/network/model/resource surface was added; inherited redacted carrier descriptions and Phase 46 checker pass. |
| 17 | Full regression and boundary evidence are green. | ✓ VERIFIED | Fresh full SwiftPM rerun executes 368 with 3 opt-in skips and 0 failures; checker passes 24/24 self and 14/14 live. |
| 18 | Downstream scope remains honestly deferred. | ✓ VERIFIED | No renderer case, output helper/gallery, final cap, exhaustive promotion matrix, Demo change, or feature-ledger promotion exists in Phase 46. |

**Score:** 18/18 truths verified.

## Required Artifacts

| Artifact | Status | Verification |
|---|---|---|
| `BeautyEffectiveStrengths` / `BeautySafetyCaps` | ✓ VERIFIED | Four fields exist with exact provisional caps and resolver ownership. |
| `FaceShapeWarpProvider.swift` | ✓ VERIFIED | Seven named emissions include independent smooth, temple, and cheekbone vectors with finite/local bounds. |
| `ChinWarpProvider.swift` | ✓ VERIFIED | Two named emissions preserve signed chin length and add centerline-gated X-only taper. |
| `BeautyEffectResolver.swift` | ✓ VERIFIED | Trigger, caps, reuse/stale/no-face, provider preflight, convergence, domains, metrics, and point accounting are wired. |
| `GeometryConflictResolver.swift` | ✓ VERIFIED | Exact 37-field total/count/scale includes the four new fields once. |
| `BeautyEngineTestingSupport.swift` | ✓ VERIFIED | Deterministic asymmetric support traverses the production mapper/adapter/facade route. |
| Seven focused test files | ✓ VERIFIED | Provider, resolver, conflict, combined, pipeline, degradation, and facade evidence pass. |
| `check_face_geometry_boundaries.py` | ✓ VERIFIED | Self-tested fail-closed privacy, scope, ownership, convergence, artifact, and deferral gate passes. |
| Root owner documents and `46-VALIDATION.md` | ✓ VERIFIED | Architecture, mechanics, trust, reliability, product acceptance, execution history, and command evidence agree. |

## Key Link Verification

| From | To | Via | Status |
|---|---|---|---|
| Four public parameter values | Effective strengths | normalization plus exact provisional caps | ✓ WIRED |
| Effective strengths | Observed contour/centerline | face/chin named provider eligibility | ✓ WIRED |
| Provider emissions | Conflict baseline | preflight sanitization and post-scale monotone removal | ✓ WIRED |
| Retained baseline | Final plan evidence | exact 37-field resolver plus final named emissions | ✓ WIRED |
| Final effective strengths | Public image processing | existing `BeautyGeometryEffectPipeline` | ✓ WIRED |
| Public result | Diagnostics | fixed warnings and aggregate metrics only | ✓ WIRED |

## Behavioral Evidence

| Gate | Fresh result |
|---|---|
| Six focused effects suites | 110/110 passed |
| Public facade suite | 15/15 passed |
| All `BeautyEffectsTests` | 205 executed, 1 opt-in skip, 0 failures |
| Full SwiftPM verifier rerun | 368 executed, 3 opt-in Apple Vision skips, 0 failures |
| Phase 46 boundary checker | 24/24 self-tests; 14/14 live |
| Standard code review | Clean after one whitespace-only research fix |
| Complete phase-range diff hygiene | Passed |

## Requirements Coverage

| Requirement | Status | Evidence |
|---|---|---|
| GEOM-01 | ✓ SATISFIED | Independent mean-centered smoothing emission, roughness/bound/source/non-alias tests, facade route, and degradation lifecycle pass. |
| GEOM-02 | ✓ SATISFIED | Independent upper-lateral outward emission, disjoint-source tests, facade route, and lifecycle pass. |
| GEOM-03 | ✓ SATISFIED | Independent mid-lateral inward emission, disjoint-source tests, facade route, and lifecycle pass. |
| GEOM-04 | ✓ SATISFIED | Centerline/apex-gated adjacent X-only taper, unchanged Y/signed chin-length tests, facade route, and lifecycle pass. |

No orphaned Phase 46 requirement exists. `OUT-*` remains mapped to Phase 47 and `SAFE-*` to Phase 48.

## Human Verification

None for the Phase 46 contract. Visual visibility, ROI locality, naturalness, and final calibration are explicit downstream automated/product gates, not hidden manual acceptance for this phase.

## Gaps

No Phase 46 gap remains. The three repository-specific governance statements entered the independent security audit as explicit inputs; `46-SECURITY.md` verifies all three for current repository scope and records `threats_open: 0`.

---
_Verified: 2026-07-23T10:48:04Z_
_Verifier: the agent (local goal-backward verification because the typed verifier quota was unavailable)_
