---
phase: "92"
slug: "signed-eyebrow-head-spacing"
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-09-06"
---

# Phase 92 — Validation Strategy

> Per-phase validation contract for the signed eyebrow-head-spacing repair. The frozen Phase 89 actual-pixel oracle remains the final BROW-01 authority; provider geometry is necessary supporting evidence, not a substitute.

---

## Test Infrastructure

| Property | Value |
| --- | --- |
| **Framework** | XCTest via SwiftPM plus SDK-owned Swift/Bash/Python gates |
| **Config file** | `BeautySDK/Package.swift`; frozen semantic contract in `scripts/face-feature-batch-manifest.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter 'EyebrowWarpProviderTests|BeautyEngineEyebrowHeadSpacingRepairTests'` |
| **Compatibility command** | `swift test --package-path BeautySDK --filter 'CPUReferenceGeometryOracleTests|BeautyExampleRendererProcessTests|BeautyRendererOutputRegressionTests'` |
| **Semantic/boundary commands** | `swift scripts/compare-face-feature-batches.swift --self-test`; `python3 scripts/test-face-feature-batch-boundaries.py`; `bash scripts/run-face-feature-batches.sh --preflight-only` |
| **Final boundary command** | `bash scripts/check-sdk-only-boundary.sh --post-archive` |
| **Estimated quick runtime** | ~60 seconds after build cache warm-up |

---

## Sampling Rate

- **After every task commit:** run that task's exact focused command and stop at the first non-zero exit or zero-test run.
- **After provider implementation:** run both the provider suite and the generated public-facade pixel oracle before any frozen batch case is admitted.
- **After each plan wave:** run the combined quick filter plus any SDK-owned script seam exercised in that wave.
- **Before Phase 92 verification:** run both exact Phase 89 eyebrow-head cases through the existing package-host batch path, require all frozen signed/locality/protection/sibling facts to pass, then run the SDK-only boundary gate.
- **Attempt authority:** the original two-attempt stop remains historical. The owner explicitly reopened repair on 2026-09-08; current acceptance binds repair cycle 1 / cumulative attempt 7. Historical failed summaries retain their original values and outcomes.
- **Max feedback latency:** focused unit feedback under 60 seconds when warm; package-host semantic feedback may take several minutes but remains bounded to the two exact cases and their required siblings.

---

## Per-Task Verification Map — current R5 acceptance

Historical 92-01/02/05 outcomes remain immutable failures or RED baselines;
the owner-authorized 92-06 repair supersedes their implementation hypotheses.
This mapping records current coverage, not retrospective success for failures.

| Task | Requirement | Automated evidence | Status |
| --- | --- | --- | --- |
| 92-01-01 / 92-06-01 | BROW-01 frozen pixels and independent fixture | Frozen public suite 3/0/0; registration/peer suite 2/0/0 | COVERED |
| 92-01-02 / 92-02-01 / 92-06-02 | BROW-01 signed local provider and dense safety | Provider suite 18/0/0, includes retained RED-to-GREEN dense regression | COVERED by R5; earlier failures unchanged |
| 92-06-03 | BROW-01 review and compatibility binding | Clean independent review; current hashes; compatibility/freshness 217/0/2 | COVERED within scope |
| 92-03-01 | Frozen semantic/filesystem authority | Comparator 576, cleanup 6, preflight 75/65/8, immutable source comparison | COVERED |
| 92-03-02 | Final pixels and renderer compatibility | Nine BROW methods / 23 focused; CPU/process/output classes included in 120/0/0 | COVERED |
| 92-04-01 | Evidence provenance and closeout | Accepted attempt 7 hashes, historical identity, backend 24+41, archive and SDK-only checks | COVERED |
| 92-04-02 | Design, owner journey, recovery | Exact three owner headings and source/evidence consistency checks | COVERED |
| 92-04-03 | Quality, taxonomy and ledger | Remaining three owners and repeated boundary/preflight/archive/SDK checks | COVERED |

Commands are executable in reconciled 92-03/04 plans. All required generated
focused methods ran without skips. The two adapter portrait-integration methods
remain Phase 95 work and receive no current execution credit.

## Threat Coverage Map

| Threat | Risk | Blocking mitigation |
| --- | --- | --- |
| T-92-01 | Broad pixel disturbance passes while inner-head gap remains semantically weak. | Independently measured final-pixel Q16 direction and minimum target signal for both signs. |
| T-92-02 | Repair changes frozen cases, boxes, thresholds, sibling lists, or comparator behavior. | Manifest/comparator self-test, mutation inventory, source review, and unchanged exact case IDs. |
| T-92-03 | Head spacing becomes an alias for whole-brow spacing. | Compare every candidate with opposite sign and both whole-brow siblings; reject outer-half carriers. |
| T-92-04 | A missing/invalid peer suppresses or contaminates the valid side. | Left-valid/right-invalid and right-valid/left-invalid provider tests with no borrowing or mirroring. |
| T-92-05 | Neutral, dead-zone, malformed, or reused requests leak prior geometry. | Exact `0`/`±Float.ulpOfOne`, no-face/provider-empty, and valid-invalid-valid tests. |
| T-92-06 | Moved target-centered support crosses outer anchors or unit bounds. | Target-based cutoff clearance, finite/unit validation, carrier/radius taper assertions, and pixel protection gates. |
| T-92-07 | Provider intent or self-reported aggregates are mistaken for production output. | Final authority remains package-host rendered pixels and independently declared darkness-centroid regions. |
| T-92-08 | Generated outputs, raw pixels, geometry, reports, or private paths persist. | Existing aggregate-only admission and cleanup fault-injection gates. |
| T-92-09 | Repeated tuning silently exceeds the two-attempt policy. | Historical failures stay immutable; explicit owner repair reopening, candidate ledger, accepted cycle 1 / attempt 7 hashes and independent review govern current acceptance. |
| T-92-10 | Scope expands into public API, shader/backend, UI, live portrait, or release claims. | Tracked-file review, SDK-only boundary, archive verification, owner-doc assertions, and explicit Phase 95 deferral. |

Every HIGH-severity threat blocks completion until its mapped automated evidence passes.

---

## Wave 0 Requirements

- [x] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineEyebrowHeadSpacingRepairTests.swift` — deterministic public-facade actual-pixel and metadata oracle for both signs, four sibling distinctions, protected regions, side eligibility, lifecycle, and determinism.
- [x] `EyebrowWarpProviderTests.swift` additions — own-axis sign, normalized-progress carrier selection, displacement/radius taper, target cutoff, exact dead zone, mixed valid/invalid peer cases, provider-empty behavior, and recovery.
- [x] Independent test helpers that mirror the frozen integer darkness-centroid and region-delta definitions without deriving expected positions from provider targets.

No framework or package installation is required.

---

## Frozen BROW-01 Gates

- Exact cases: `eyebrowHeadSpacing_plus0p25` and `eyebrowHeadSpacing_minus0p25`.
- Target regions: left inner head `x=400000...500000`, right inner head `x=500000...600000`, `y=240000...430000` in millionths.
- Target signal: at least 500 changed pixels and 2,000 total RGB delta from source and neutral.
- Signed semantic metric: `innerBrowHeadGap` Q16 at least `+16` for positive and at most `-16` for negative, with all required sibling differences at least 16.
- Outside target: at most 128 changed pixels and 512 RGB delta.
- Outer anchors and eyes: each region at most 64 changed pixels and 256 RGB delta.
- Background and watermark: exactly zero changed pixels and zero RGB delta.
- Candidate evidence must remain linked to the exact package-host output; provider-coordinate assertions alone cannot pass.

---

## Manual-Only Verifications

All Phase 92 completion behaviors have automated verification. Live owner-controlled portraits and real-device observations are deferred to Phase 95 and are not Phase 92 gates.

---

## Validation Sign-Off

- [x] All plan tasks have an exact runnable `<automated>` command or an explicit Wave 0 dependency.
- [x] Every runnable command has a neighboring `<fails_when>` with an observable failure signal.
- [x] Sampling continuity has no three consecutive tasks without automated feedback.
- [x] Wave 0 covers the repair-specific missing test file and independent metric helpers.
- [x] No watch-mode flags or unbounded coefficient-search loops appear.
- [x] Both exact Phase 89 cases and every required sibling/protected-region fact pass unchanged.
- [x] Current 92-06/03/04 acceptance agrees on repair cycle 1 / cumulative attempt 7 under explicit owner reopening; original failed summaries remain unchanged.
- [x] Durable evidence contains only fixed aggregates and temporary media/report artifacts are absent after success and failure.
- [x] `nyquist_compliant: true` and `wave_0_complete: true` are set only after execution supplies all passing evidence.

**Approval:** pending


## Validation Audit 2026-09-08

One coverage gap was found and resolved: dense same-side additive fields could
fold despite per-point bounds. Commit 4a92373 reproduced 12 expected assertions;
470ae0d passed the independent sampling regression without changing frozen
pixels. No unresolved automated requirement gap or Phase 92 manual-only item
remains. Exact portrait-dependent skips are
`testIntegrationLocalAuthorizedPortraitAggregateFitsLockedFaceValidationEnvelope`
and `testIntegrationLocalAuthorizedPortraitFitsLockedEyebrowValidationEnvelope`.
These are deferred Phase 95 opt-ins, not missing generated-mechanics coverage.
