---
phase: 25
slug: security-distribution-review-and-closeout
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-07-03
---

# Phase 25 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, Xcode/xcodebuild, `rg` static scans, `plutil` manifest checks when a manifest is added, GSD traceability checks |
| **Config file** | `BeautySDK/Package.swift`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `.planning/config.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` plus the focused scan for the touched Phase 25 surface |
| **Full suite command** | `swift test --package-path BeautySDK` plus focused Demo privacy/import xcodebuild command or exact blocker record |
| **Estimated runtime** | 10 to 25 minutes for SDK tests, focused Demo checks, active-source scans, manifest lint if applicable, and traceability scans |

## Sampling Rate

- **After every task commit:** Run the focused XCTest or static scan for the touched security/resource/doc surface plus `git diff --check` over touched Phase 25 artifacts.
- **After every plan wave:** Run full `swift test --package-path BeautySDK`, all Phase 25 active-source scans introduced by the wave, and any required `plutil` manifest checks if `PrivacyInfo.xcprivacy` exists.
- **Before `$gsd-verify-work`:** Run full SDK tests, focused Demo privacy/import command or blocker protocol, no-overclaim scans, requirement/decision coverage checks, and final traceability scans over root and `.planning` ledgers.
- **Max feedback latency:** 25 minutes for automated SDK, Demo focused, manifest, artifact, and static checks; unavailable Demo or hardware checks must be recorded with exact blocker and rerun protocol.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 25-01-01 | 01 | 1 | SEC-01, SEC-02, SEC-04 | T-25-01-01 | Privacy assessment records SDK behavior separately from Demo/host responsibility, checks data collection/upload/persistence, and does not defer manifest solely because no upload is found. | scan/artifact | `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print` plus required-reason and active-network/leak `rg` scans from `25-RESEARCH.md` | evidence file pending | pending |
| 25-01-02 | 01 | 1 | SEC-01 | T-25-01-02 | If a manifest is required, the smallest fact-matching `PrivacyInfo.xcprivacy` is added to the correct target resource path and linted; if not required, the evidence artifact records explicit deferral and rerun triggers. | plist/artifact | `plutil -lint <PrivacyInfo.xcprivacy>` and `plutil -p <PrivacyInfo.xcprivacy>` if a manifest exists | conditional | pending |
| 25-02-01 | 02 | 1 | SEC-03 | T-25-02-01 | Bundled presets, metadata filters, resource identifiers, traversal-like IDs, unknown filters/presets, and missing-resource typed errors match `SECURITY.md`. | unit/scan/artifact | `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` plus resource-source scans | yes | pending |
| 25-02-02 | 02 | 1 | SEC-02, SEC-03, SEC-04 | T-25-02-02 | Active SDK/Demo leaks are failures; test guard literals, fixtures, docs examples, and historical artifacts are classified rather than blindly rewritten. | focused XCTest/static scan | Demo focused privacy/import xcodebuild command from `25-RESEARCH.md` or exact blocker record | yes | pending |
| 25-03-01 | 03 | 2 | DOC-01, DOC-02, DOC-03 | T-25-03-01 | Ledgers synchronize only evidence-backed Phase 25 conclusions, close or defer TD-005/TD-010 honestly, and avoid App Store/commercial/all-device/market-quality readiness claims. | doc/traceability scan | `rg -n "SEC-01|SEC-02|SEC-03|SEC-04|DOC-01|DOC-02|DOC-03|Phase 25" QUALITY_SCORE.md PLANS.md .planning/PROJECT.md .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md` | yes | pending |

## Wave 0 Requirements

- [ ] `.planning/phases/25-security-distribution-review-and-closeout/25-SECURITY-CLOSEOUT.md` - evidence artifact for SEC-01 through DOC-03 with exact commands, results, blockers/deferred items, privacy-manifest decision, resource-trust evidence, and ledger sync checklist.
- [ ] Required-reason API scan - execution must cross-check the seed list from `25-RESEARCH.md` against current Apple documentation before final manifest disposition.
- [ ] Active-source security scans - split active SDK/Demo source, package/project declarations, tests, docs, and historical artifacts so guard literals are not misclassified as active leaks.
- [ ] Manifest lint path - if `PrivacyInfo.xcprivacy` is added, record its target ownership, package/project inclusion evidence, and `plutil` lint output.

## Manual-Only Verifications

| Behavior | Requirement | Current Status | Why Manual | Test Instructions |
|----------|-------------|----------------|------------|-------------------|
| Apple required-reason API classification | SEC-01 | pending | Apple policy details can change and the research seed list is not authoritative. | During execution, compare current active-source matches with Apple's required-reason API documentation, record the checked date, and cite the result in `25-SECURITY-CLOSEOUT.md`. |
| Demo focused privacy/import command | SEC-02, SEC-04 | pending | Local Xcode/simulator state can pass or fail independently of SDK source correctness. | Run the exact iPhone 17 / iOS 26.5 command from `25-RESEARCH.md`; if it fails, record command, environment, failure summary, impact, next step, and rerun protocol. |
| Distribution-readiness wording review | DOC-01, DOC-02, DOC-03 | pending | Closeout wording is a claim-control review rather than a unit-testable behavior. | Scan touched ledgers and evidence for forbidden claims: App Store ready, commercial distribution ready, all-device ready, market visual-quality ready, physical-device parity, and broad release-readiness. Keep only audit-ready, traceability-ready, or current-evidence baseline wording when supported. |

## Validation Sign-Off

- [x] All planned Phase 25 requirements have automated verify, artifact verify, static scan, or explicit manual-only rationale.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify, artifact/static scan, or blocker-recording criteria.
- [x] Wave 0 records all missing Phase 25 validation references before execution.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 25 minutes for automated SDK, focused Demo, manifest, artifact, and static checks.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** Pending execution evidence.
