# Project Research Summary

**Project:** Beauty
**Domain:** Local-first iOS beauty SDK hardening, QA automation, performance, and technical-debt cleanup.
**Researched:** 2026-06-30
**Confidence:** HIGH for local project gaps and Apple platform constraints; MEDIUM for exact implementation effort.

## Executive Summary

v1.4 should be a hardening milestone, not a feature milestone. v1.3 closed core beauty module design and implementation with strong unit/renderer evidence, but the current project documents still identify release-hardening gaps: automated visual QA, physical-device camera/Vision smoke, 720p timing budgets, long-run memory checks, production render regression, privacy manifest review, and root-doc/debt cleanup.

The recommended approach is evidence-first: refresh the quality/debt baseline, add stable automated QA and output-regression gates, then add performance/reliability checks and security/distribution cleanup. This avoids optimizing without a baseline and prevents future feature work from building on unknown release risks.

The main risk is overclaiming release readiness from simulator-only or fixture-only evidence. v1.4 should explicitly distinguish automated simulator/SwiftPM evidence from physical-device or manual evidence, and record blocked hardware checks when hardware is unavailable.

## Key Findings

### Recommended Stack

Use the existing Apple-native stack: SwiftPM, XCTest/XCUITest/XCTMetric, xcodebuild/simctl, Instruments/xctrace, Metal/Core Image/AVFoundation/Vision, OSLog/OSSignposter/MetricKit, and the local `BeautyExampleRenderer`. Do not add third-party beauty SDKs, network services, or UI testing frameworks unless a later phase proves native tooling insufficient.

**Core technologies:**

- SwiftPM / XCTest: existing SDK test backbone.
- XCUITest / simulator screenshots: best fit for deterministic Demo QA.
- Instruments / XCTMetric: repeatable performance and memory evidence.
- Metal best-practice checks: persistent objects, bounded per-frame work, and no realtime blocking waits.
- Privacy manifests and security scans: required for distribution-like SDK review.

### Expected Features

**Must have:**

- Baseline quality/debt audit.
- Full SDK/Demo verification sweep or reproducible local blocker notes.
- Automated or documented visual QA evidence.
- Performance and long-run reliability checks.
- Renderer output regression.
- Privacy/resource/logging review.

**Should have:**

- Physical-device smoke protocol and evidence when hardware is available.
- Updated quality scores after evidence exists.
- Negative scans for no new API/UI/network/product scope.

**Defer:**

- New public `BeautyParameters`.
- Geometry-heavy saved-image completion.
- New Meitu product areas.
- SDK packaging/XCFramework distribution beyond assessment.

### Architecture Approach

Keep the existing boundary architecture. Demo QA stays in `BeautyDemo` and imports only `BeautySDK`. Renderer regression uses public facade paths. Performance/reliability improvements respect `RELIABILITY.md` budgets and `SECURITY.md` redaction. Diagnostics and metrics stay local, sampled, redacted, and opt-in.

**Major components:**

1. Baseline ledger and root-doc audit.
2. Demo visual/UI QA harness.
3. SDK/Demo performance and long-run gates.
4. `BeautyExampleRenderer` output regression matrix.
5. Security/distribution review and closeout scans.

### Critical Pitfalls

1. **Optimizing without baseline evidence** - prevent with Phase 21 audit and commands.
2. **Flaky screenshot QA** - prevent with stable routes, explicit destinations, and scoped evidence.
3. **Simulator-only release claims** - separate simulator evidence from physical-device evidence.
4. **Privacy manifest drift** - tie manifest review to actual logs, metrics, resource, and network behavior.
5. **Scope creep** - negative-scan new APIs, UI routes, network behavior, and feature-completion claims.

## Implications for Roadmap

### Phase 21: Baseline Audit and Quality Ledger Refresh

**Rationale:** Establish the true debt and verification baseline before fixing anything.
**Delivers:** Updated quality/debt ledger, stale-doc status, current command inventory, and scoped hardening decisions.
**Addresses:** Audit and docs requirements.
**Avoids:** Optimizing without baseline evidence.

### Phase 22: Automated Demo QA and Screenshot Evidence

**Rationale:** v1.1/v1.2 UI evidence exists, but automation and layout sweeps are still future.
**Delivers:** Simulator UI/screenshot route evidence or documented local blockers.
**Addresses:** Visual QA and UI automation requirements.
**Avoids:** Manual-only UI confidence.

### Phase 23: Performance and Reliability Gates

**Rationale:** `RELIABILITY.md` has budgets but current score shows performance tests at 0.
**Delivers:** Timing/memory/backpressure/quality-mode checks and long-run protocol.
**Addresses:** Performance and reliability requirements.
**Avoids:** Release-readiness claims without budgets.

### Phase 24: Renderer Output Regression Hardening

**Rationale:** `BeautyExampleRenderer` exists and should become a stronger regression gate.
**Delivers:** No-op tolerance, visible-output checks, matrix documentation, and geometry-output honesty.
**Addresses:** Render and output requirements.
**Avoids:** Provider tests being mistaken for visual completion.

### Phase 25: Security, Distribution Review, and Closeout

**Rationale:** Privacy manifest, resource trust, redaction, and scope scans are closeout concerns for a hardening milestone.
**Delivers:** Privacy/resource/log review, final negative scans, quality score updates, and milestone closeout evidence.
**Addresses:** Security and traceability requirements.
**Avoids:** Privacy drift and scope creep.

### Phase Ordering Rationale

- Baseline first so later work closes verified gaps.
- Visual QA before UI cleanup so layout changes have evidence.
- Performance before optimization claims so measurements define success.
- Renderer regression before final closeout so output claims are concrete.
- Security/distribution review last so it reflects all v1.4 behavior.

### Research Flags

- **Phase 22:** May need local simulator availability checks before screenshot automation.
- **Phase 23:** May need deeper Instruments/xctrace details during planning.
- **Phase 25:** May need exact `PrivacyInfo.xcprivacy` contents during planning.

## Confidence Assessment

| Area | Confidence | Notes |
| --- | --- | --- |
| Stack | HIGH | Existing Apple-native stack matches official guidance and project constraints. |
| Features | HIGH | Derived from `.planning/PROJECT.md`, `QUALITY_SCORE.md`, `RELIABILITY.md`, `SECURITY.md`, and `PLANS.md`. |
| Architecture | HIGH | v1.4 preserves the established SDK/Demo boundaries. |
| Pitfalls | MEDIUM | Pitfalls are strongly supported locally; exact automation fragility depends on machine/simulator state. |

**Overall confidence:** HIGH

### Gaps to Address

- Hardware availability: physical iPhone checks may be blocked locally; record status explicitly.
- Performance tooling depth: Phase 23 planning should decide between XCTMetric, xctrace, or a narrow command-level harness per target.
- Privacy manifest contents: Phase 25 should inspect actual API/resource/log behavior before writing or changing manifest files.

## Sources

### Primary

- `QUALITY_SCORE.md` - current quality scores and repair queue.
- `RELIABILITY.md` - budgets, degradation, long-run, and release readiness gates.
- `SECURITY.md` - privacy manifest, local-first, resource trust, and logging requirements.
- `.planning/PROJECT.md` and `.planning/STATE.md` - v1.3 completion state and next-milestone candidates.
- Apple Xcode performance documentation: https://developer.apple.com/documentation/xcode/improving-your-app-s-performance
- Apple Metal Best Practices Guide: https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/PersistentObjects.html
- Apple XCTest metrics documentation: https://developer.apple.com/documentation/xctest/xctmetric
- Apple AVFoundation late-frame discard property: https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutput/alwaysdiscardslatevideoframes
- Apple privacy manifest documentation: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
- Apple Vision face landmarks request documentation: https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest

---
*Research completed: 2026-06-30*
*Ready for roadmap: yes*
