---
phase: 53
slug: canonical-still-image-contract-and-private-request-foundation
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-30
---

# Phase 53 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest through Swift Package Manager (Swift tools 6.0) |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Estimated runtime** | ~180 seconds for the full suite; focused filters provide task-level feedback |

---

## Sampling Rate

- **After every task commit:** Run the focused XCTest class named in that task plus `git diff --check`
- **After every plan wave:** Run the focused Phase 53 suites plus existing parameter, resource, facade, detector, mapping, selection, and renderer regressions named below
- **Before `$gsd-verify-work`:** `swift test --package-path BeautySDK` must be green
- **Max feedback latency:** 180 seconds for a focused/wave check; the full suite is the phase gate

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 53-01-W0 | 01 | 0 | PATH-02, PATH-03 | T-53-01, T-53-02, T-53-03 | Reject invalid size/orientation/color/range/alpha before Vision; canonical output is one opaque zero-origin sRGB RGBA8 raster | unit/adversarial | `swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests` | ❌ W0 | ⬜ pending |
| 53-02-W0 | 02 | 0 | PATH-04 | T-53-04, T-53-05 | Actual lip/eye/brow/face support remains package-only and request-local; one detector/mapping pass; no stale support | detection integration | `swift test --package-path BeautySDK --filter StillImageRequestSupportTests` | ❌ W0 | ⬜ pending |
| 53-03-W0 | 03 | 0 | PATH-01, PATH-05 | T-53-06 | Existing public image facade owns admission; pixel-buffer/realtime paths cannot construct or invoke local request support | facade regression | `swift test --package-path BeautySDK --filter BeautyEngineLocalRetouchFoundationTests` | ❌ W0 | ⬜ pending |
| 53-03-COMPAT | 03 | 1 | PATH-06, PATH-07 | — | No Phase 53 candidate field/provider/renderer case; exact 59-field, legacy payload, preset, default, and no-local output behavior remains neutral | compatibility/regression | `swift test --package-path BeautySDK --filter BeautyParametersTests && swift test --package-path BeautySDK --filter BeautyResourceCatalogTests && swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` | ✅ extend | ⬜ pending |
| 53-WAVE-GATE | all | each | PATH-01..PATH-07 | T-53-01..T-53-06 | Focused foundation, detector, metadata, geometry, selection, resource, parameter, facade, and output regressions all pass | integration/regression | `swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests && swift test --package-path BeautySDK --filter BeautyEngineLocalRetouchFoundationTests && swift test --package-path BeautySDK --filter StillImageRequestSupportTests && swift test --package-path BeautySDK --filter BeautyEngineMetadataCompatibilityTests && swift test --package-path BeautySDK --filter BeautyEngineGeometryFacadeTests && swift test --package-path BeautySDK --filter VisionFaceDetectorTests && swift test --package-path BeautySDK --filter FaceObservationMappingTests && swift test --package-path BeautySDK --filter FaceSelectionPolicyTests` | mixed | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyCanonicalStillImageTests.swift` — synthetic orientation/color/alpha/ceiling/error-order cases for PATH-02 and PATH-03
- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift` — public-facade admission, safe continuation, exactly-once collaborator, and pixel-buffer isolation cases for PATH-01, PATH-04, and PATH-05
- [ ] `BeautySDK/Tests/BeautyDetectionTests/StillImageRequestSupportTests.swift` — actual mapped-lip provenance, aggregate diagnostics, valid-invalid-valid isolation, and independent request-value cases for PATH-04
- [ ] Extend `BeautyParametersTests.swift`, `BeautyResourceCatalogTests.swift`, and public-facade/output regressions with exact-59/no-candidate/no-local byte-neutral assertions for PATH-06 and PATH-07
- [ ] Add a focused static/source-boundary assertion only if direct XCTest cannot prove no public/SPI raw support, no pixel-buffer local call, and no candidate API inventory

---

## Manual-Only Verifications

All Phase 53 behaviors have automated verification. Rights-approved original-detail naturalness review belongs to Phase 54 and later visible-feature phases, not this foundation phase.

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 180s for focused/wave checks
- [ ] Full SwiftPM suite, privacy/public-surface scans, exact 59-field/preset inventory, and no-candidate-provider checks pass at the phase gate
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
