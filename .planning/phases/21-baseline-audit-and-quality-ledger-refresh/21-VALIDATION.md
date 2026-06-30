---
phase: 21
slug: baseline-audit-and-quality-ledger-refresh
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-30
---

# Phase 21 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, Xcode/xcodebuild, shell static scans, GSD validators |
| **Config file** | `BeautySDK/Package.swift`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `.planning/config.json` |
| **Quick run command** | `git diff --check -- .planning/phases/21-baseline-audit-and-quality-ledger-refresh QUALITY_SCORE.md PLANS.md .planning/PROJECT.md .planning/STATE.md .planning/ROADMAP.md` |
| **Full suite command** | `swift test --package-path BeautySDK` plus the Phase 21 baseline sweep recorded in `21-BASELINE-AUDIT.md` |
| **Estimated runtime** | 5 to 20 minutes depending on Demo simulator state |

## Sampling Rate

- **After every task commit:** Run the quick diff/check scan and the task's static scans.
- **After every plan wave:** Run the relevant command group from `21-BASELINE-AUDIT.md`.
- **Before `$gsd-verify-work`:** `21-BASELINE-AUDIT.md`, `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/STATE.md`, and `.planning/ROADMAP.md` must agree on Phase 21 evidence and debt routing.
- **Max feedback latency:** 20 minutes.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 21-01-01 | 01 | 1 | AUD-02 | T-21-01-01 | Commands are recorded with pass/fail/blocker status and no false pass claims. | command sweep | `swift test --package-path BeautySDK` | yes | pending |
| 21-01-02 | 01 | 1 | AUD-02, AUD-03 | T-21-01-02 | Static scans preserve SDK/Demo/privacy/API scope boundaries. | static scan | `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests || true` | yes | pending |
| 21-01-03 | 01 | 1 | AUD-01, AUD-02 | T-21-01-03 | Baseline artifact classifies current, archived, blocked, deferred, and not-attempted evidence. | artifact check | `rg -n "passed|failed|blocked|deferred|archived" .planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` | yes | pending |
| 21-02-01 | 02 | 2 | AUD-01, AUD-03, AUD-04 | T-21-02-01 | Ledgers route debt without fixing later-phase work. | doc scan | `rg -n "TD-005|TD-008|TD-009|TD-010|Phase 22|Phase 23|Phase 24|Phase 25" QUALITY_SCORE.md PLANS.md .planning/PROJECT.md .planning/STATE.md .planning/ROADMAP.md` | yes | pending |
| 21-02-02 | 02 | 2 | AUD-01, AUD-03 | T-21-02-02 | Quality-score changes cite current command evidence and avoid release-readiness overclaims. | doc scan | `rg -n "2026-06-30|21-BASELINE-AUDIT|blocked|deferred|not attempted" QUALITY_SCORE.md PLANS.md` | yes | pending |

## Wave 0 Requirements

Existing infrastructure covers all phase requirements:

- `BeautySDK/Package.swift` exists.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` exists.
- `.planning/REQUIREMENTS.md` maps `AUD-01` through `AUD-04` to Phase 21.
- `21-CONTEXT.md` exists.
- `21-RESEARCH.md` exists.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Physical iPhone camera/Vision parity | AUD-04 / TD-008 | Hardware may not be available on the executing machine. | If an iPhone is available, run the Demo camera path and record front-camera mirroring, no-face, partial-face, and low-light status behavior. If not available, record a blocker with exact hardware assumption and route to Phase 22 or Phase 23. |
| Human visual/naturalness review | AUD-04 / TD-009 / TD-010 | Automated fixture and simulator evidence does not prove market-grade naturalness. | Record that Phase 21 routes the check to Phase 22/24 unless a current manual review is actually performed with screenshots and notes. |

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or explicit blocker-recording criteria.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify.
- [x] Wave 0 covers all missing references.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 20 minutes for automated checks.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** pending execution evidence
