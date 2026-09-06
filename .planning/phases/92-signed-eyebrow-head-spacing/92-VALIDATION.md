---
phase: "92"
slug: "signed-eyebrow-head-spacing"
status: draft
nyquist_compliant: false
wave_0_complete: false
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
- **Attempt ceiling:** all implementation summaries must record the same `implementation_attempt: 1` or `2`; failure of attempt two stops for an explicit owner decision.
- **Max feedback latency:** focused unit feedback under 60 seconds when warm; package-host semantic feedback may take several minutes but remains bounded to the two exact cases and their required siblings.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
| --- | --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| 92-01-01 | 01 | 1 | BROW-01 | T-92-01, T-92-02, T-92-03 | Deterministic generated 512×512 explicit-sRGB RGBA8 oracle independently measures both signs, whole-brow siblings, metadata, locality, protected regions, side eligibility, lifecycle, and deterministic bytes. | TDD actual-pixel integration | `swift test --package-path BeautySDK --filter BeautyEngineEyebrowHeadSpacingRepairTests` | ❌ Wave 0 | ⬜ pending |
| 92-01-02 | 01 | 1 | BROW-01 | T-92-04, T-92-05 | Provider tests freeze own-axis sign, inner-half carrier/taper constraints, exact dead zone, cap, peer-independent eligibility, malformed/no-face/provider-empty behavior, and valid-invalid-valid recovery. | unit/mutation | `swift test --package-path BeautySDK --filter EyebrowWarpProviderTests` | ✅ extends | ⬜ pending |
| 92-02-01 | 02 | 2 | BROW-01 | T-92-01, T-92-03, T-92-06 | Only `headSpacingPoints` or its private helper changes; the attempt-one progress-normalized tapered field is finite, unit-safe, locally bounded, and distinct from whole-brow spacing. | implementation + focused integration | `swift test --package-path BeautySDK --filter 'EyebrowWarpProviderTests|BeautyEngineEyebrowHeadSpacingRepairTests' && git diff --check` | provider ✅ / repair test ❌ Wave 0 | ⬜ pending |
| 92-03-01 | 03 | 3 | BROW-01 | T-92-02, T-92-07, T-92-08 | Comparator and manifest remain frozen; their self-test, mutation, inventory, admission, cleanup, and exact preflight contracts still pass. | script boundary/mutation | `swift scripts/compare-face-feature-batches.swift --self-test && python3 scripts/test-face-feature-batch-boundaries.py && bash -n scripts/run-face-feature-batches.sh && bash scripts/run-face-feature-batches.sh --preflight-only` | ✅ | ⬜ pending |
| 92-03-02 | 03 | 3 | BROW-01 | T-92-01, T-92-02, T-92-03, T-92-07 | Exact signed head-spacing cases pass target signal, `+16`/`-16` Q16 direction, four-sibling distinction, outside `128/512`, outer-anchor/eye `64/256`, and background/watermark `0/0`; only fixed aggregates persist. | package-host actual-pixel semantic | exact focused batch command selected by the plan from the existing runner interface | ✅ runner/manifest | ⬜ pending |
| 92-04-01 | 04 | 4 | BROW-01 | T-92-09, T-92-10 | Shared attempt count is 1 or 2, focused and compatibility suites pass, no forbidden API/backend/media surface appears, and SDK-only boundary remains green. | phase compatibility/security | exact plan closeout conjunction covering summaries, focused SwiftPM, compatibility, semantic/boundary, archive, SDK-only, privacy, and diff hygiene | pending prior summaries | ⬜ pending |
| 92-04-02 | 04 | 4 | BROW-01 | T-92-09, T-92-10 | Current-state owner docs record only the verified private geometry, owner-local behavior, recovery/evidence, taxonomy status, attempt, and nonclaims. | documentation | exact owner-section/source-assertion command selected by the plan | existing docs extend | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

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
| T-92-09 | Repeated tuning silently exceeds the two-attempt policy. | One shared summary field checked across all implementation plans; attempt-two failure halts. |
| T-92-10 | Scope expands into public API, shader/backend, UI, live portrait, or release claims. | Tracked-file review, SDK-only boundary, archive verification, owner-doc assertions, and explicit Phase 95 deferral. |

Every HIGH-severity threat blocks completion until its mapped automated evidence passes.

---

## Wave 0 Requirements

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineEyebrowHeadSpacingRepairTests.swift` — deterministic public-facade actual-pixel and metadata oracle for both signs, four sibling distinctions, protected regions, side eligibility, lifecycle, and determinism.
- [ ] `EyebrowWarpProviderTests.swift` additions — own-axis sign, normalized-progress carrier selection, displacement/radius taper, target cutoff, exact dead zone, mixed valid/invalid peer cases, provider-empty behavior, and recovery.
- [ ] Independent test helpers that mirror the frozen integer darkness-centroid and region-delta definitions without deriving expected positions from provider targets.

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

- [ ] All plan tasks have an exact runnable `<automated>` command or an explicit Wave 0 dependency.
- [ ] Every runnable command has a neighboring `<fails_when>` with an observable failure signal.
- [ ] Sampling continuity has no three consecutive tasks without automated feedback.
- [ ] Wave 0 covers the repair-specific missing test file and independent metric helpers.
- [ ] No watch-mode flags or unbounded coefficient-search loops appear.
- [ ] Both exact Phase 89 cases and every required sibling/protected-region fact pass unchanged.
- [ ] All implementation summaries agree on attempt `1` or `2`; no third attempt occurs.
- [ ] Durable evidence contains only fixed aggregates and temporary media/report artifacts are absent after success and failure.
- [ ] `nyquist_compliant: true` and `wave_0_complete: true` are set only after execution supplies all passing evidence.

**Approval:** pending
