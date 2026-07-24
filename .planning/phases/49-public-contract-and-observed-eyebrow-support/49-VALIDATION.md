---
phase: 49
slug: public-contract-and-observed-eyebrow-support
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-24
---

# Phase 49 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Estimated runtime** | Focused suites: under 2 minutes; full suite: host dependent |

The current full-suite baseline is blocked by the missing untracked `e1.png` portrait fixture. Focused parameter, mapping, and adapter suites are green. Execution must restore/provision the authorized fixture or record the reproducible environmental block; it must not claim a green full suite while the fixture is absent.

## Sampling Rate

- **After every task commit:** Run the narrow owning XCTest suite and `python3 .planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py`.
- **After every plan wave:** Run parameter, resource, resolver, mapping, adapter, and detector focused suites plus `git diff --check`.
- **Before phase verification:** Run the full SwiftPM suite after fixture preflight, every focused suite, boundary self-tests/live checks, preset hash checks, and the owner-document audit.
- **Max feedback latency:** 2 minutes for the normal focused loop.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 49-01-01 | 01 | 1 | BROW-02, SUPP-03 | T-49-04, T-49-06 | Fail-closed privacy and scope checker | static + adversarial self-test | `python3 .planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py --self-test` | ❌ W0 | ⬜ pending |
| 49-02-01 | 02 | 2 | BROW-01, BROW-02 | — | Exact neutral 59-field contract | unit + resource | `swift test --package-path BeautySDK --filter BeautyCoreTests` | ✅ extend | ⬜ pending |
| 49-03-01 | 03 | 2 | SUPP-01, SUPP-02 | T-49-01, T-49-02, T-49-03 | Direct bounded actual-source mapping exactly once | unit + integration | `swift test --package-path BeautySDK --filter BeautyDetectionTests` | ✅ extend | ⬜ pending |
| 49-04-01 | 04 | 3 | SUPP-02, SUPP-03 | T-49-02, T-49-04, T-49-05 | Open-path validation, redaction, request isolation | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFaceGeometryAdapterTests` | ✅ extend | ⬜ pending |
| 49-05-01 | 05 | 4 | BROW-01, BROW-02, SUPP-01, SUPP-02, SUPP-03 | all | Owner and evidence agreement without downstream claims | full/static | `swift test --package-path BeautySDK && python3 .planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py` | ✅ / fixture preflight | ⬜ pending |

## Wave 0 Requirements

- [ ] `check_eyebrow_support_boundaries.py` — adapt the Phase 45 fail-closed checker with adversarial self-tests for public/SPI visibility, actual eyebrow provenance, forbidden eye substitution, Codable/persistence/network/Demo/manifest/resource/provider/resolver/renderer scope, redaction, lifecycle markers, and exact preset hashes.
- [ ] Brow-specific fixture builders and topology matrices in `BeautyFaceGeometryAdapterTests.swift`.
- [ ] Counting-mapper and orientation × mirror × reversal fixtures in `FaceObservationMappingTests.swift`.
- [ ] Direct actual-property capture and sibling-local-failure fixtures in `VisionFaceDetectorTests.swift`.
- [ ] Environment preflight for `example-images/input/portraits/e1.png`.

## Manual-Only Verifications

All phase behaviors are designed for automated verification. Any unavailable authorized fixture or Apple Vision host capability is an explicit environment blocker, not a manual product-approval substitute.

## Validation Sign-Off

- [ ] All tasks have `<automated>` verification or Wave 0 dependencies.
- [ ] Sampling continuity: no three consecutive tasks without automated verification.
- [ ] Wave 0 covers all missing references.
- [ ] No watch-mode flags.
- [ ] Focused feedback latency remains under two minutes.
- [ ] `nyquist_compliant: true` set in frontmatter.

**Approval:** pending
