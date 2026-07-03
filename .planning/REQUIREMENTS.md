# Requirements: Beauty

**Defined:** 2026-06-30
**Milestone:** v1.4 Stability, QA, and Debt Cleanup
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.4 Requirements

v1.4 is a hardening and technical-debt cleanup milestone. It converts known post-v1.3 release risks into repeatable evidence, fixes high-value debt, and improves existing reliability without adding new product areas or public API surface by default.

### Audit and Baseline

- [x] **AUD-01**: Maintainers can see an updated quality and debt baseline that distinguishes still-open debt, completed debt, blocked hardware checks, and obsolete historical items.
- [x] **AUD-02**: Maintainers can run or inspect a documented baseline verification sweep for existing SDK tests, Demo build/test commands, import/privacy scans, and renderer commands; any local toolchain blocker is recorded with the failing command.
- [x] **AUD-03**: Current root contracts and `.planning` artifacts describe v1.4 as stability, QA, performance, security, and cleanup work rather than new product-feature work.
- [x] **AUD-04**: Open debt items TD-005, TD-008, TD-009, and TD-010 are triaged into this milestone, explicitly deferred, or marked blocked with evidence.

Phase 21 evidence is recorded in `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` and refreshed into `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/STATE.md`, and `.planning/ROADMAP.md`. Current SDK tests and renderer commands pass; explicit Demo simulator build/test evidence is blocked by the missing local Metal Toolchain; stale `.planning/codebase/*` maps are deferred background. TD-005 routes to Phase 25, TD-008 splits to Phase 22/23 with physical iPhone evidence blocked until hardware exists, TD-009 routes to Phase 22, and TD-010 splits across Phases 22/23/24/25.

Phase 22 evidence is recorded in `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` and `.planning/phases/22-automated-demo-qa-and-screenshot-evidence/22-VERIFICATION.md`. The phase completed through the allowed blocker-honest path: exact iPhone 17 Demo build/test commands reproduce the missing Metal Toolchain blocker, no current v1.4 PNG screenshots are created or claimed, required per-state review notes are present in blocked form, and unsupported/future routes remain inactive through source scans and existing view-state test coverage.

### Automated Demo QA

- [x] **QA-01**: Maintainers can capture or verify deterministic Demo visual evidence for the Home first screen, Home sticky state, and editor tool panel using stable launch routes and explicit simulator destinations where local simulator tooling allows it.
- [x] **QA-02**: Maintainers can verify that current supported Demo controls, labels, future-state badges, and main panels do not clip or overlap across the target simulator sizes selected for v1.4.
- [x] **QA-03**: v1.4 visual evidence is stored under `.planning/evidence/v1.4/` with commands, simulator/device framing, and review notes sufficient for future comparison.
- [x] **QA-04**: Unsupported Meitu-style product areas and future categories remain visibly honest and inactive; v1.4 does not accidentally enable new UI routes or fake capabilities.

### Performance and Reliability

- [x] **PERF-01**: Maintainers can run a repeatable timing check for current 720p or fixture-based processing paths and compare the result to the engineering budgets in `RELIABILITY.md`.
- [x] **PERF-02**: Realtime backpressure, dropped-frame accounting, and latest-frame-wins behavior remain covered by tests or an equivalent reproducible harness.
- [x] **PERF-03**: Quality mode, reset, and degradation behavior are verified against `RELIABILITY.md` so performance improvements do not bypass safety caps or recovery rules.
- [x] **PERF-04**: Long-run preview or processing stability has automated evidence, manual evidence, or an explicit hardware/tooling blocker that records how the 10-minute memory-growth gate should be run.
- [x] **PERF-05**: Logs, warnings, metrics, and performance evidence remain optional, redacted, and free of frame payloads, local paths, face-geometry payloads, unredacted framework errors, and serialized diagnostic payloads.

Phase 23 evidence is recorded in `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` and `.planning/phases/23-performance-and-reliability-gates/23-VALIDATION.md`. The focused SDK performance command passed with 3 tests, the full SDK suite passed with 148 tests, and the focused Demo camera pipeline command passed on `platform=iOS Simulator,name=iPhone 17,OS=26.5`. Current 720p timings are over-budget baseline evidence, the SDK fixture loop has a 600-second rerun protocol, and physical iPhone plus long-run preview evidence remains blocked or not run.

### Renderer Output Regression

- [x] **RENDER-01**: `BeautyExampleRenderer` keeps a documented public-facade matrix for all current visible skin/color/filter output cases.
- [x] **RENDER-02**: Default/no-op processing has a regression check that verifies exact pre-watermark rendered-pixel equality for current fixture images; no tolerance fallback was required in Phase 24.
- [x] **RENDER-03**: Visible-output cases verify non-empty outputs, same dimensions as inputs, readable parameter watermarks, and factual visible changes without claiming commercial visual quality.
- [x] **RENDER-04**: Geometry-heavy branches remain `partial`, `blocked-by-geometry-output`, or `future` unless public facade detection plus geometry rendering produces saved same-dimension, watermarked outputs.

Phase 24 evidence is recorded in `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md` and `.planning/phases/24-renderer-output-regression-hardening/24-VERIFICATION.md`. The focused renderer regression tests passed, full `swift test --package-path BeautySDK` passed with 150 tests, `BeautyExampleRenderer` built and regenerated 45 ignored local PNG outputs, the generated-output helper passed for all expected outputs, and geometry/no-overclaim scans passed. Phase 24 does not add product features, public parameters, Demo UI, committed PNG baselines, reference-app parity evidence, or geometry saved-output completion.

### Security and Distribution Review

- [x] **SEC-01**: The repository contains a documented privacy manifest assessment, and `PrivacyInfo.xcprivacy` is added or explicitly deferred based on actual SDK/Demo behavior and Apple required-reason API usage.
- [x] **SEC-02**: No-network, no-upload, no unredacted path, no unredacted framework error, no face-geometry payload leak, and no serialized diagnostic payload leak checks pass for active SDK and Demo surfaces.
- [x] **SEC-03**: Resource trust boundaries are reviewed so bundled presets, metadata filters, identifiers, missing resources, and future external resource assumptions match `SECURITY.md`.
- [x] **SEC-04**: v1.4 adds no hidden third-party SDK, analytics, remote config, cloud processing, dynamic downloads, payment, VIP, or entitlement behavior.

Phase 25 security evidence is recorded in `.planning/phases/25-security-distribution-review-and-closeout/25-SECURITY-CLOSEOUT.md` and `25-RESOURCE-TRUST-EVIDENCE.md`. `PrivacyInfo.xcprivacy` is explicitly deferred for current SDK/Demo behavior; active-source scans and focused Demo privacy/import tests pass; bundled-resource trust is verified by focused SwiftPM tests and source scans; external resource package integrity, screenshot, hardware, long-run, and commercial packaging checks remain future or blocked/not-run rows rather than pass evidence.

### Traceability and Closeout

- [x] **DOC-01**: `QUALITY_SCORE.md` is refreshed after v1.4 evidence exists, with score increases only where code, tests, command output, or recorded manual checks support them.
- [x] **DOC-02**: `PLANS.md` records each v1.4 phase outcome, closed or deferred debt, verification evidence, and any unrun checks with reasons.
- [x] **DOC-03**: `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` maintain 100% v1.4 requirement traceability and next-step routing.

Phase 25 closeout evidence refreshes `QUALITY_SCORE.md`, `SECURITY.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` from command-backed privacy, resource, security, and traceability evidence. The closeout records TD-005 as explicitly deferred for current behavior and preserves TD-010 follow-ups for screenshot, hardware, long-run, optimized profiling, external-resource integrity, and commercial packaging checks.

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
| AUD-01 | Phase 21 | Complete |
| AUD-02 | Phase 21 | Complete |
| AUD-03 | Phase 21 | Complete |
| AUD-04 | Phase 21 | Complete |
| QA-01 | Phase 22 | Complete |
| QA-02 | Phase 22 | Complete |
| QA-03 | Phase 22 | Complete |
| QA-04 | Phase 22 | Complete |
| PERF-01 | Phase 23 | Complete |
| PERF-02 | Phase 23 | Complete |
| PERF-03 | Phase 23 | Complete |
| PERF-04 | Phase 23 | Complete |
| PERF-05 | Phase 23 | Complete |
| RENDER-01 | Phase 24 | Complete |
| RENDER-02 | Phase 24 | Complete |
| RENDER-03 | Phase 24 | Complete |
| RENDER-04 | Phase 24 | Complete |
| SEC-01 | Phase 25 | Complete |
| SEC-02 | Phase 25 | Complete |
| SEC-03 | Phase 25 | Complete |
| SEC-04 | Phase 25 | Complete |
| DOC-01 | Phase 25 | Complete |
| DOC-02 | Phase 25 | Complete |
| DOC-03 | Phase 25 | Complete |

**Coverage:**

- v1.4 requirements: 24 total
- Mapped to phases: 24
- Unmapped: 0

---
*Requirements defined: 2026-06-30*
*Last updated: 2026-07-03 after Phase 25 security/distribution closeout evidence*
