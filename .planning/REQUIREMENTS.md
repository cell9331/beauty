# Requirements: Beauty

**Defined:** 2026-06-30
**Milestone:** v1.4 Stability, QA, and Debt Cleanup
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.4 Requirements

v1.4 is a hardening and technical-debt cleanup milestone. It converts known post-v1.3 release risks into repeatable evidence, fixes high-value debt, and improves existing reliability without adding new product areas or public API surface by default.

### Audit and Baseline

- [ ] **AUD-01**: Maintainers can see an updated quality and debt baseline that distinguishes still-open debt, completed debt, blocked hardware checks, and obsolete historical items.
- [ ] **AUD-02**: Maintainers can run or inspect a documented baseline verification sweep for existing SDK tests, Demo build/test commands, import/privacy scans, and renderer commands; any local toolchain blocker is recorded with the failing command.
- [ ] **AUD-03**: Current root contracts and `.planning` artifacts describe v1.4 as stability, QA, performance, security, and cleanup work rather than new product-feature work.
- [ ] **AUD-04**: Open debt items TD-005, TD-008, TD-009, and TD-010 are triaged into this milestone, explicitly deferred, or marked blocked with evidence.

### Automated Demo QA

- [ ] **QA-01**: Maintainers can capture or verify deterministic Demo visual evidence for the Home first screen, Home sticky state, and editor tool panel using stable launch routes and explicit simulator destinations where local simulator tooling allows it.
- [ ] **QA-02**: Maintainers can verify that current supported Demo controls, labels, future-state badges, and main panels do not clip or overlap across the target simulator sizes selected for v1.4.
- [ ] **QA-03**: v1.4 visual evidence is stored under `.planning/evidence/v1.4/` with commands, simulator/device framing, and review notes sufficient for future comparison.
- [ ] **QA-04**: Unsupported Meitu-style product areas and future categories remain visibly honest and inactive; v1.4 does not accidentally enable new UI routes or fake capabilities.

### Performance and Reliability

- [ ] **PERF-01**: Maintainers can run a repeatable timing check for current 720p or fixture-based processing paths and compare the result to the engineering budgets in `RELIABILITY.md`.
- [ ] **PERF-02**: Realtime backpressure, dropped-frame accounting, and latest-frame-wins behavior remain covered by tests or an equivalent reproducible harness.
- [ ] **PERF-03**: Quality mode, reset, and degradation behavior are verified against `RELIABILITY.md` so performance improvements do not bypass safety caps or recovery rules.
- [ ] **PERF-04**: Long-run preview or processing stability has automated evidence, manual evidence, or an explicit hardware/tooling blocker that records how the 10-minute memory-growth gate should be run.
- [ ] **PERF-05**: Logs, warnings, metrics, and performance evidence remain optional, redacted, and free of image bytes, local paths, face geometry, raw framework errors, and raw JSON.

### Renderer Output Regression

- [ ] **RENDER-01**: `BeautyExampleRenderer` keeps a documented public-facade matrix for all current visible skin/color/filter output cases.
- [ ] **RENDER-02**: Default/no-op processing has a regression check that verifies near-copy output within the documented tolerance for current fixture images.
- [ ] **RENDER-03**: Visible-output cases verify non-empty outputs, same dimensions as inputs, readable parameter watermarks, and factual visible changes without claiming production naturalness.
- [ ] **RENDER-04**: Geometry-heavy branches remain `partial`, `blocked-by-geometry-output`, or `future` unless public facade detection plus geometry rendering produces saved same-dimension, watermarked outputs.

### Security and Distribution Review

- [ ] **SEC-01**: The repository contains a documented privacy manifest assessment, and `PrivacyInfo.xcprivacy` is added or explicitly deferred based on actual SDK/Demo behavior and Apple required-reason API usage.
- [ ] **SEC-02**: No-network, no-upload, no raw-path, no raw framework error, no face-geometry leak, and no raw JSON leak checks pass for active SDK and Demo surfaces.
- [ ] **SEC-03**: Resource trust boundaries are reviewed so bundled presets, metadata filters, identifiers, missing resources, and future external resource assumptions match `SECURITY.md`.
- [ ] **SEC-04**: v1.4 adds no hidden third-party SDK, analytics, remote config, cloud processing, dynamic downloads, payment, VIP, or entitlement behavior.

### Traceability and Closeout

- [ ] **DOC-01**: `QUALITY_SCORE.md` is refreshed after v1.4 evidence exists, with score increases only where code, tests, command output, or recorded manual checks support them.
- [ ] **DOC-02**: `PLANS.md` records each v1.4 phase outcome, closed or deferred debt, verification evidence, and any unrun checks with reasons.
- [ ] **DOC-03**: `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` maintain 100% v1.4 requirement traceability and next-step routing.

## Future Requirements

Deferred to later milestones unless explicitly promoted.

### Product and SDK Expansion

- **FUT-GEOMETRY-01**: Public facade saved-image geometry output for face-shape, eye, nose, mouth, and 3D sculpt branches.
- **FUT-API-01**: New public `BeautyParameters` for promoted advanced shaping, skin repair, teeth/hairline, makeup, segmentation, body, or video features.
- **FUT-DIST-01**: Commercial SDK packaging, XCFramework distribution, compatibility matrix, checksum/signature, and host integration docs.
- **FUT-PRODUCT-01**: Home/discovery, style resources, AI/background, video/body, gallery/account, search, VIP, payment, and entitlement planning.

## Out of Scope

| Feature | Reason |
| --- | --- |
| New Meitu product surfaces | v1.4 is hardening and debt cleanup only. |
| New public `BeautyParameters` by default | Public API expansion adds compatibility risk and must be promoted explicitly. |
| Geometry-heavy saved-image completion | Still blocked until public facade detection plus geometry render integration exists. |
| Cloud upload, AI service calls, analytics, or remote config | Current security posture is local-first and no-network by default. |
| Commercial distribution packaging | v1.4 reviews readiness and privacy needs; packaging itself remains future unless separately approved. |
| Broad historical-document normalization | Only current owner docs and planning artifacts should change unless a phase explicitly scopes wider doc cleanup. |
| New SwiftUI redesign | v1.4 may add QA/screenshot harnesses but does not redesign Home or Editor. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| AUD-01 | Phase 21 | Planned |
| AUD-02 | Phase 21 | Planned |
| AUD-03 | Phase 21 | Planned |
| AUD-04 | Phase 21 | Planned |
| QA-01 | Phase 22 | Planned |
| QA-02 | Phase 22 | Planned |
| QA-03 | Phase 22 | Planned |
| QA-04 | Phase 22 | Planned |
| PERF-01 | Phase 23 | Planned |
| PERF-02 | Phase 23 | Planned |
| PERF-03 | Phase 23 | Planned |
| PERF-04 | Phase 23 | Planned |
| PERF-05 | Phase 23 | Planned |
| RENDER-01 | Phase 24 | Planned |
| RENDER-02 | Phase 24 | Planned |
| RENDER-03 | Phase 24 | Planned |
| RENDER-04 | Phase 24 | Planned |
| SEC-01 | Phase 25 | Planned |
| SEC-02 | Phase 25 | Planned |
| SEC-03 | Phase 25 | Planned |
| SEC-04 | Phase 25 | Planned |
| DOC-01 | Phase 25 | Planned |
| DOC-02 | Phase 25 | Planned |
| DOC-03 | Phase 25 | Planned |

**Coverage:**

- v1.4 requirements: 24 total
- Mapped to phases: 24
- Unmapped: 0

---
*Requirements defined: 2026-06-30*
*Last updated: 2026-06-30 after v1.4 roadmap creation*
