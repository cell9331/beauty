---
phase: 22
slug: automated-demo-qa-and-screenshot-evidence
status: final
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-01
updated: 2026-07-03
---

# Phase 22 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Xcode/xcodebuild, XCTest, `xcrun simctl`, shell static scans, GSD validators |
| **Config file** | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `.planning/config.json` |
| **Quick run command** | `git diff --check -- .planning/phases/22-automated-demo-qa-and-screenshot-evidence .planning/evidence/v1.4 PLANS.md .planning/STATE.md .planning/ROADMAP.md` |
| **Full suite command** | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` plus Phase 22 evidence commands recorded in `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` |
| **Estimated runtime** | 5 to 20 minutes when Metal Toolchain is installed; under 5 minutes to reproduce the current blocker |

## Sampling Rate

- **After every task commit:** Run the quick diff/check scan and the task's focused evidence scan.
- **After every plan wave:** Run the relevant build/test/screenshot command group or record the exact blocker.
- **Before `$gsd-verify-work`:** `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` must contain current Phase 22 command evidence, screenshot inventory or blocker records, review notes, and non-claims.
- **Max feedback latency:** 20 minutes.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 22-01-01 | 01 | 1 | QA-01, QA-03 | T-22-01-01 | Demo build/test status is recorded as pass or reproducible blocker, never a false pass. | build command | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` | yes | passed-blocker-path |
| 22-01-02 | 01 | 1 | QA-04 | T-22-01-02 | Route/model tests prove unsupported future routes remain inactive. | focused XCTest | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyDemoViewStateTests` | yes | passed-blocker-path |
| 22-01-03 | 01 | 1 | QA-03 | T-22-01-03 | Evidence README records exact commands, destination, environment, impact, and next step. | artifact scan | `rg -n "iPhone 17|OS=26.5|xcodebuild|simctl|blocked|Metal Toolchain|home-first-screen|home-sticky-state|editor-tool-panel" .planning/evidence/v1.4/VISUAL-EVIDENCE.md` | yes | passed |
| 22-02-01 | 02 | 2 | QA-01, QA-02, QA-03 | T-22-02-01 | Required screenshots exist only when the Demo app actually builds, installs, launches, and captures. | simulator screenshot | `find .planning/evidence/v1.4 -maxdepth 1 -type f -name '*.png' | sort` | n/a: no-PNG blocker path | passed-blocker-path |
| 22-02-02 | 02 | 2 | QA-02, QA-04 | T-22-02-02 | Review notes check clipping, overlap, disabled honesty, and route scope without naturalness overclaims. | artifact scan | `rg -n "clipping|overlap|disabled|inactive|future|no production naturalness claim|not current screenshot pass evidence" .planning/evidence/v1.4/VISUAL-EVIDENCE.md` | yes | passed |

## Wave 0 Requirements

Existing infrastructure covers all phase requirements:

- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` exists.
- `BeautyDemo/BeautyDemo/ContentView.swift` has launch-only route hooks.
- `BeautyDemo/BeautyDemo/Home/MeituHomeView.swift` has Home first and sticky preview states.
- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolPanelView.swift` has the current editor tool panel.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` has route/model honesty coverage.
- `.planning/REQUIREMENTS.md` maps `QA-01` through `QA-04` to Phase 22.
- `22-CONTEXT.md` and `22-RESEARCH.md` exist.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Human screenshot review notes | QA-02, QA-03, QA-04 | Current plan intentionally avoids brittle pixel-perfect automation and broad screenshot diff baselines. | For each required screenshot, record the exact file path, route, framing, and factual observations about clipping, overlap, disabled/future honesty, and route scope. |
| Physical iPhone camera/Vision parity | QA-01 / TD-008 | Hardware may not be available and is outside Phase 22 completion unless actual device evidence exists. | If a physical iPhone is available, run the camera route and record preview/crop/status observations. If not, mark blocked with hardware assumption and next step. |
| Production naturalness and effect quality | QA-02 / TD-010 | Phase 22 validates layout/evidence mechanics, not market-grade effect quality. | Record as out of scope or future Phase 24/manual review unless a separate explicit review is performed. |

## Validation Sign-Off

- [x] All tasks have automated verify or explicit blocker-recording criteria.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify.
- [x] Wave 0 covers all missing references.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 20 minutes for automated checks.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** Approved after retroactive validation audit on 2026-07-03. `22-VERIFICATION.md` already records `status: passed`; this update closes the stale draft/pending validation-document state while preserving the blocker-honest no-PNG evidence path.

## Validation Audit 2026-07-03

| Metric | Count |
|--------|-------|
| Gaps found | 1 |
| Resolved | 1 |
| Escalated | 0 |

### Audit Findings

- Existing phase evidence is complete: `22-VERIFICATION.md` reports `status: passed` and `score: 4/4 must-haves verified`.
- The only Nyquist gap was document state drift: this file still had non-final frontmatter and task rows that had not been updated after Phase 22 execution completed.
- No new tests or screenshots were generated. Phase 22 intentionally completed through the accepted blocker-honest path: `VISUAL-EVIDENCE.md` records `Demo simulator build: blocked`, `Demo focused view-state test: blocked`, `Screenshot capture status: blocked`, no current v1.4 PNGs, per-state blocked review notes, route/model disabled-honesty scans, and the rerun protocol.

### Evidence Used

- `phase-plan-index 22` reports both `22-01` and `22-02` have summaries and no incomplete plans.
- `22-VERIFICATION.md` records QA-01 through QA-04 as satisfied through documented blocker evidence and disabled-honesty scans.
- Scoped checks on 2026-07-03 confirmed no `.planning/evidence/v1.4/*.png` files exist and the overclaim scan over `VISUAL-EVIDENCE.md` passed.
