---
phase: 25
slug: security-distribution-review-and-closeout
status: final
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-03
updated: 2026-07-03
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
| 25-01-01 | 01 | 1 | SEC-01, SEC-02, SEC-04 | T-25-01-01 | Privacy assessment records SDK behavior separately from Demo/host responsibility, checks data collection/upload/persistence, and does not defer manifest solely because no upload is found. | scan/artifact | `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print` plus required-reason and active-network/leak `rg` scans from `25-RESEARCH.md` | yes | passed |
| 25-01-02 | 01 | 1 | SEC-01 | T-25-01-02 | Manifest is not required for current evidence; the evidence artifact records explicit deferral and rerun triggers. | artifact | `plutil` not run because no manifest was added | yes | deferred |
| 25-02-01 | 02 | 1 | SEC-03 | T-25-02-01 | Bundled presets, metadata filters, resource identifiers, traversal-like IDs, unknown filters/presets, and missing-resource typed errors match `SECURITY.md`. | unit/scan/artifact | `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` plus resource-source scans | yes | passed |
| 25-02-02 | 02 | 1 | SEC-02, SEC-03, SEC-04 | T-25-02-02 | Active SDK/Demo leaks are failures; test guard literals, fixtures, docs examples, and historical artifacts are classified rather than blindly rewritten. | focused XCTest/static scan | Demo focused privacy/import xcodebuild command from `25-RESEARCH.md` | yes | passed |
| 25-03-01 | 03 | 2 | DOC-01, DOC-02, DOC-03 | T-25-03-01 | Ledgers synchronize only evidence-backed Phase 25 conclusions, close or defer TD-005/TD-010 honestly, and avoid unsupported App Store submission, commercial packaging, broad-device, market-quality, hardware, or release claims. | doc/traceability scan | `rg -n "SEC-01|SEC-02|SEC-03|SEC-04|DOC-01|DOC-02|DOC-03|Phase 25" QUALITY_SCORE.md PLANS.md .planning/PROJECT.md .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md` | yes | passed |

## Wave 0 Requirements

- [x] `.planning/phases/25-security-distribution-review-and-closeout/25-SECURITY-CLOSEOUT.md` - evidence artifact for SEC-01 through DOC-03 with exact commands, results, blockers/deferred items, privacy-manifest decision, resource-trust evidence, and ledger sync checklist.
- [x] Required-reason API scan - execution cross-checked the seed list from `25-RESEARCH.md`; official Apple docs are JavaScript-rendered in this environment, so live category detail remains a packaging/submission rerun item.
- [x] Active-source security scans - split active SDK/Demo source, package/project declarations, tests, docs, and historical artifacts so guard literals are not misclassified as active leaks.
- [x] Manifest lint path - no `PrivacyInfo.xcprivacy` was added; `plutil` is reserved for the rerun protocol if a manifest becomes required.

## Manual-Only Verifications

| Behavior | Requirement | Current Status | Why Manual | Test Instructions |
|----------|-------------|----------------|------------|-------------------|
| Apple required-reason API classification | SEC-01 | recorded with documentation-access limitation | Apple policy details can change and the research seed list is not authoritative. | Current seed scan and official Apple link check are recorded in `25-SECURITY-CLOSEOUT.md`; rerun with browser-readable Apple documentation before packaging or submission work. |
| Demo focused privacy/import command | SEC-02, SEC-04 | passed | Local Xcode/simulator state can pass or fail independently of SDK source correctness. | Rerun the exact iPhone 17 / iOS 26.5 command from `25-RESEARCH.md` if Demo privacy/import surfaces change. |
| Distribution wording review | DOC-01, DOC-02, DOC-03 | passed | Closeout wording is a claim-control review rather than a unit-testable behavior. | Final claim-control scan covers Phase 25 artifacts and synchronized ledgers; keep only audit-ready, traceability-ready, or current-evidence baseline wording when supported. |

## Validation Sign-Off

- [x] All planned Phase 25 requirements have automated verify, artifact verify, static scan, or explicit manual-only rationale.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify, artifact/static scan, or blocker-recording criteria.
- [x] Wave 0 records all missing Phase 25 validation references before execution.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 25 minutes for automated SDK, focused Demo, manifest, artifact, and static checks.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** Final Phase 25 validation evidence is recorded. Remaining screenshot, physical iPhone, 600-second preview, external resource package, live Apple documentation detail, and commercial packaging checks are future or blocked/not-run items, not Phase 25 pass evidence.
