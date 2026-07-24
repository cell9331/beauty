---
phase: 47-public-facade-face-output-evidence
verified: 2026-07-24T01:47:00Z
status: passed
score: 16/16
requirements_verified: [OUT-01, OUT-02, OUT-03]
human_verification_required: false
---

# Phase 47: Public-Facade Face Output Evidence Verification

## Goal

Prove every scoped face capability through decoded public-facade images rather than provider-only assertions.

## Verdict

**PASSED.** All 16 goal-backward truths, required artifacts, key links, three requirements, focused/full regression, strict decoded output, gallery containment, privacy/scope, and diff-hygiene gates are verified. Final cap calibration, exhaustive transition/convergence safety, promotion, root owner synchronization, and branch closeout remain correctly assigned to Phase 48.

## Observable Truths

| # | Truth | Status | Evidence |
|---:|---|---|---|
| 1 | The renderer contains exactly 59 unique ordered cases with all prior 55 preserved. | ✓ VERIFIED | Source inventory XCTest and live renderer/gallery set audit pass. |
| 2 | Four new cases use exactly one matching public field at provisional `0.25`. | ✓ VERIFIED | Snippet-level source contract passes for contour smooth, temple fullness, cheekbone slim, and chin taper. |
| 3 | Every case traverses the same public `BeautySDK` facade route. | ✓ VERIFIED | Renderer import boundary is system frameworks plus `BeautySDK`; exactly one `engine.processResult` call exists. |
| 4 | All four new public requests preserve extent and aggregate degradation on no-face input. | ✓ VERIFIED | Focused renderer regression suite passes fixed summary/warning/metric/redaction assertions. |
| 5 | Missing and malformed observed contour remove all four dependent fields. | ✓ VERIFIED | Testing-only fixtures traverse the production mapper/adapter route; output equals sibling-only baselines. |
| 6 | An eligible shipped face sibling continues when new work is removed. | ✓ VERIFIED | `faceSlim` retains domain, aggregate metric, point count, rendered bytes, and redacted public result in all eight rows. |
| 7 | Live source and fixture discovery freeze an exact 59×7=413 matrix. | ✓ VERIFIED | Missing, extra, stale, duplicate, non-regular, or dimension-changing evidence is rejected. |
| 8 | Saved-image acquisition and decode are bounded and fail closed. | ✓ VERIFIED | Descriptor/no-follow identity checks, 16 MiB file budget, 4096² dimension limit, 64 MiB decoded limit, strict PNG/JPEG tests pass. |
| 9 | Strict regions, floors, eligibility, and comparators are fixed constants. | ✓ VERIFIED | Contract self-tests reject zero/dynamic floors, eligibility drift, wrong comparator families, and watermark overlap. |
| 10 | Every eligible portrait crosses fixed visibility and intended-region locality gates. | ✓ VERIFIED | 18/18 comparisons pass with minimum 0.99 intended RGB share and zero permitted outside signal. |
| 11 | Every new field differs from all locked nearest shipped/new neighbors. | ✓ VERIFIED | Eleven constant families pass 49/49 intended-region comparisons above field-specific floors. |
| 12 | Ineligible portrait/field pairs cannot become weak visibility passes. | ✓ VERIFIED | Frozen eligibility excludes six pairs and requires exact whole watermark-safe no-ops, 6/6. |
| 13 | The explicit no-face output fixture is an exact safe no-op for all four cases. | ✓ VERIFIED | Fixed 2,048-pixel fallback passes 4/4 with zero changed pixels and RGB delta. |
| 14 | The human-review gallery is an exact descriptor-safe renderer bijection. | ✓ VERIFIED | Generator self-test and publication produce exactly 413 regular paths from 59 cases and seven fixture stems. |
| 15 | Generated evidence remains disposable repository-local state. | ✓ VERIFIED | Output/gallery are ignored, untracked, unstaged, non-symlinked; non-ignored generated files and staging/quarantine slots are zero. |
| 16 | Regression is green and Phase 48 boundaries remain untouched. | ✓ VERIFIED | Full SwiftPM passes 371 with three opt-in skips; package, production providers/resolver/render pass, Demo, root owners, feature ledger, final caps, promotion rows, and branch status are unchanged. |

**Score:** 16/16 truths verified.

## Required Artifacts

| Artifact | Status | Verification |
|---|---|---|
| `BeautyExampleRenderer/main.swift` | ✓ VERIFIED | Four isolated IDs, exact ordered inventory, public facade only, one process call. |
| `BeautyRendererOutputRegressionTests.swift` | ✓ VERIFIED | Exact source inventory, one-field snippets, and four no-face public requests pass. |
| `BeautyEngineTestingSupport.swift` | ✓ VERIFIED | Testing-only missing/malformed contour fixtures remain aggregate and non-public. |
| `BeautyEngineGeometryFacadeTests.swift` | ✓ VERIFIED | Eight degraded rows preserve sibling-only public evidence and redaction. |
| `check_face_geometry_renderer_outputs.py` | ✓ VERIFIED | Bounded decoder, fixed semantic contracts, strict live gate, and adversarial self-tests pass. |
| `47-FACE-OUTPUT-EVIDENCE.md` | ✓ VERIFIED | Commands, dimensions, regions, floors, denominators, minima, margins, no-ops, containment, and nonclaims agree with fresh execution. |
| `generate_gallery.py` | ✓ VERIFIED | Exact four-ID extension preserves descriptor-safe atomic publication and case equality. |
| Live example-image documentation | ✓ VERIFIED | Exact 59/7/413 contract and Phase 48 nonclaims are synchronized. |
| `47-VALIDATION.md` and planning owners | ✓ VERIFIED | Nyquist rows are executed and OUT-only closure is consistent. |

## Key Link Verification

| From | To | Via | Status |
|---|---|---|---|
| Four new public scalars | Saved PNG output | single shared `BeautyEngine.processResult` loop | ✓ WIRED |
| Saved PNGs | Fixed semantic evidence | strict standard-library decoder and family-specific regions | ✓ WIRED |
| New field output | Baseline and fixed neighbors | eligibility-aware direct RGB comparisons | ✓ WIRED |
| Renderer case inventory | Review gallery | duplicate-free exact group equality and descriptor-relative publication | ✓ WIRED |
| Aggregate evidence | OUT requirements | validation, requirements, roadmap, state, and work ledger | ✓ WIRED |

## Behavioral Evidence

| Gate | Fresh result |
|---|---|
| Renderer focused suite | 15/15 passed |
| Facade focused suite | 16/16 passed |
| Full SwiftPM | 371 executed, 3 opt-in Apple Vision skips, 0 failures |
| Helper self-test / compile | Passed |
| Final strict matrix | 413/413 |
| Visibility/locality | 18/18 |
| Fixed-neighbor independence | 49/49 |
| Ineligible portrait no-ops | 6/6 |
| No-face no-ops | 4/4 |
| Gallery publication/bijection | 413/413 |
| Standard code review | Clean |
| Package/predecessor, scope, artifact, and diff gates | Passed |

## Requirements Coverage

| Requirement | Status | Evidence |
|---|---|---|
| OUT-01 | ✓ SATISFIED | Four isolated public cases, exact 59-case inventory, one shared facade call, and exact output/gallery matrices pass. |
| OUT-02 | ✓ SATISFIED | Bounded strict decode, fixed visibility/locality, eligibility, and all eleven fixed-neighbor families pass. |
| OUT-03 | ✓ SATISFIED | Public no-face/missing/malformed behavior, shipped-sibling continuation, redaction, descriptor-safe gallery, and artifact containment pass. |

No orphaned Phase 47 requirement exists. SAFE-01 through SAFE-03 and DOC-01 remain pending in Phase 48.

## Human Verification

None for the Phase 47 contract. The committed requirements are executable decoded-image and repository-boundary gates. Subjective naturalness, device parity, commercial review, optimized performance, packaging, shipping, and launch readiness are future scope rather than hidden manual acceptance.

## Gaps

No Phase 47 goal gap remains.

---
_Verified: 2026-07-24T01:47:00Z_
_Verifier: the agent (local goal-backward verification because the typed verifier quota was unavailable)_
