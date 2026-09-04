---
phase: "91"
slug: "independent-gaze-correction"
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-09-04"
---

# Phase 91 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest from the Swift toolchain plus SDK-owned Swift/Bash/Python gates |
| **Config file** | `BeautySDK/Package.swift`; frozen semantic contract in `scripts/face-feature-batch-manifest.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter 'BeautyFaceGeometryAdapterTests|EyeWarpProviderTests|GeometryConflictResolverTests|BeautyEngineGazeCorrectionRepairTests|BeautyExampleRendererProcessTests'` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Estimated runtime** | ~180 seconds for the focused loop; full suite is run at the phase gate |

---

## Sampling Rate

- **After every task commit:** Run the narrow filter for the edited seam plus `git diff --check`.
- **After every plan wave:** Run the combined focused Swift filter, comparator self-test, renderer-process tests, and runner boundary suite.
- **Before phase verification:** Run the full SwiftPM suite, comparator self-test, runner boundary suite, `--preflight-only`, focused compatibility, archive verification, and the post-archive SDK-only boundary.
- **Max feedback latency:** 180 seconds for the focused loop.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 91-01-01 | 01 | 1 | EYE-01 | T-91-01 | Invalid peer support cannot erase or contaminate a valid gaze side. | unit | `swift test --package-path BeautySDK --filter BeautyFaceGeometryAdapterTests` | ✅ extend | ⬜ pending |
| 91-01-02 | 01 | 1 | EYE-01 | T-91-02 | Every admitted gaze point remains inside source/target aperture clearance and the locked dead-zone/cap law. | unit | `swift test --package-path BeautySDK --filter EyeWarpProviderTests` | ✅ extend | ⬜ pending |
| 91-02-01 | 02 | 2 | EYE-01 | T-91-03 | Aggregate facts describe final admitted work and contain no raw or per-side anatomy. | unit/integration | `swift test --package-path BeautySDK --filter 'GeometryConflictResolverTests|BeautyEffectResolverTests|BeautyExampleRendererProcessTests'` | ✅ extend | ⬜ pending |
| 91-02-02 | 02 | 2 | EYE-01 | T-91-04 | Generated public-facade pixels prove own-eye reduction, rejected-side source identity, protection, metadata, and recovery. | integration | `swift test --package-path BeautySDK --filter BeautyEngineGazeCorrectionRepairTests` | ❌ W0 | ⬜ pending |
| 91-03-01 | 03 | 3 | EYE-01 | T-91-05 | Missing, replayed, contradictory, non-integral, or proxy-only aggregates cannot receive semantic credit. | mutation | `swift scripts/compare-face-feature-batches.swift --self-test` | ✅ extend | ⬜ pending |
| 91-03-02 | 03 | 3 | EYE-01 | T-91-06 | Temporary renderer reports are identity-bound, admitted, consumed before cleanup, and never persisted as anatomy evidence. | boundary | `python3 scripts/test-face-feature-batch-boundaries.py` | ✅ extend | ⬜ pending |
| 91-04-01 | 04 | 4 | EYE-01 | T-91-07 | Public inventories, facades, backend contracts, archive boundary, and nonclaims remain unchanged. | regression | `bash scripts/run-face-feature-batches.sh --preflight-only && python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui && bash scripts/check-sdk-only-boundary.sh --post-archive` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGazeCorrectionRepairTests.swift` — generated in-memory actual-pixel anatomy, per-eye correction, protection, metadata, determinism, and recovery oracle for EYE-01.
- [ ] Extend package-internal detector testing support only if the existing fixture seam cannot express independent valid/invalid eye combinations; no public or Codable geometry type is permitted.
- [ ] Add renderer aggregate binding fixtures for gaze success, neutral, sibling, malformed, and replay cases.
- [ ] Add comparator aggregate builders and mutations while retaining all existing Phase 89 adversaries and probes.
- [ ] Add runner boundary probes for consume-before-cleanup report ownership.

No framework installation is required.

---

## Manual-Only Verifications

All Phase 91 completion behaviors have automated verification. Authorized portrait reruns, real-device feedback, subjective naturalness, population coverage, and commercial quality are explicitly outside this phase; Phase 95 owns the final clean portrait publication.

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verification or explicit Wave 0 dependencies.
- [ ] Sampling continuity: no three consecutive tasks without automated verification.
- [ ] Wave 0 covers all missing test references.
- [ ] No watch-mode flags.
- [ ] Focused feedback latency remains under 180 seconds.
- [ ] Generated image tests assert actual input/output pixels and metadata, not only emitted control points or command success.
- [ ] `nyquist_compliant: true` is set only after every planned verification seam exists and passes.

**Approval:** pending
