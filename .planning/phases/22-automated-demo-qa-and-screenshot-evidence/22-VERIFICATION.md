---
phase: 22-automated-demo-qa-and-screenshot-evidence
verified: 2026-07-01T06:53:40Z
status: passed
score: 4/4 must-haves verified
overrides_applied: 0
---

# Phase 22: Automated Demo QA and Screenshot Evidence Verification Report

**Phase Goal:** Add repeatable Demo visual/layout evidence for current Home and Editor surfaces.  
**Verified:** 2026-07-01T06:53:40Z  
**Status:** passed  
**Re-verification:** No - initial verification

## Goal Achievement

Phase 22 achieved the roadmap goal through the blocker-honest path allowed by `22-CONTEXT.md` decisions D-15/D-16. Current screenshots are not claimed because the exact Demo simulator build still exits 65 while compiling `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` due to the missing local Metal Toolchain. The evidence artifact records exact commands, destination, environment, failure summary, impact, next step, rerun protocol, route/model honesty checks, per-state blocked review notes, and the no-PNG invariant.

`gsd-tools` was unavailable in this shell (`command not found`), so roadmap, artifact, and link checks were performed directly from files and command output.

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Stable launch routes and explicit simulator destinations capture or verify Home first screen, Home sticky state, and editor tool-panel evidence. | VERIFIED | `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` records destination `platform=iOS Simulator,name=iPhone 17,OS=26.5`, the exact Demo build command, reproduced exit 65 blocker, required states, and rerun commands. Independent rerun of the build reproduced the same `Warp.metal` / missing Metal Toolchain failure. |
| 2 | Selected target simulator sizes verify controls, labels, badges, and panels do not clip or overlap. | VERIFIED | Under the accepted blocker path, each required state has a blocked per-state review note with `Screenshot path`, `Command`, `Framing`, `Clipping / overlap`, `Disabled honesty`, `Route scope`, and `Non-claims`; no visual pass is claimed. |
| 3 | `.planning/evidence/v1.4/` records screenshots or documented local blockers with commands, framing, and review notes. | VERIFIED | `VISUAL-EVIDENCE.md` exists with 183 lines. `find .planning/evidence/v1.4 -maxdepth 1 -type f -iname '*.png'` returned no PNGs, matching `Screenshot capture status: blocked`. |
| 4 | Unsupported/future product areas stay inactive and honest; no new UI route is accidentally enabled. | VERIFIED | Source scans confirm `ContentView.swift` maps only existing editor routes and returns `nil` for disabled/unknown routes; `MeituHomeModels.swift` keeps future Home tools on `.disabled`; `MeituEditorToolModels.swift` keeps unsupported tools at `controlID: nil` with unavailable copy. Focused Demo view-state XCTest is correctly recorded as blocked by the same build prerequisite. |

**Score:** 4/4 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` | Current v1.4 evidence ledger with commands, blocker/pass status, review notes, route/model honesty, non-claims, and rerun protocol. | VERIFIED | Exists, 183 lines, includes all required blocker metadata and status markers: `Demo simulator build: blocked`, `Demo focused view-state test: blocked`, and `Screenshot capture status: blocked`. |
| `.planning/evidence/v1.4/home-first-screen.png` | Conditional screenshot only after successful build/install/launch/capture. | VERIFIED | Correctly absent under blocker path. |
| `.planning/evidence/v1.4/home-sticky-state.png` | Conditional screenshot only after successful build/install/launch/capture. | VERIFIED | Correctly absent under blocker path. |
| `.planning/evidence/v1.4/editor-tool-panel.png` | Conditional screenshot only after successful build/install/launch/capture. | VERIFIED | Correctly absent under blocker path. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `VISUAL-EVIDENCE.md` | `BeautyDemo/BeautyDemo.xcodeproj` | Exact `xcodebuild` build/test commands | WIRED | Commands are present in evidence and were independently rerun; both fail with exit 65 at the missing Metal Toolchain. |
| `VISUAL-EVIDENCE.md` | `BeautyDemoViewStateTests.swift` | Focused test command and static fallback scans | WIRED | Evidence names `BeautyDemoViewStateTests`; test methods exist at lines 30, 62, 521, and 543. |
| `VISUAL-EVIDENCE.md` | Demo route/model sources | Static route and disabled-honesty scans | WIRED | Source scans match the evidence claims for launch routes, disabled Home tools, unsupported editor controls, and inactive future categories. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` | Evidence status markers and review fields | Direct command output plus source scans | Yes | VERIFIED |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| SDK package tests still pass | `swift test --package-path BeautySDK` | 141 tests, 0 failures | PASS |
| Demo build blocker is real | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` | Exit 65; `Warp.metal`; `cannot execute tool 'metal' due to missing Metal Toolchain` | PASS |
| Focused Demo view-state test is blocked by build prerequisite | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test -only-testing:BeautyDemoTests/BeautyDemoViewStateTests` | Exit 65; same missing Metal Toolchain; testing cancelled because build failed | PASS |
| No PNGs exist under blocker path | `find .planning/evidence/v1.4 -maxdepth 1 -type f -iname '*.png' -print` | No output | PASS |
| Overclaim scan | `rg` for forbidden pass claims in `VISUAL-EVIDENCE.md` | No matches | PASS |

### Probe Execution

| Probe | Command | Result | Status |
| --- | --- | --- | --- |
| None declared | `find scripts -path '*/tests/probe-*.sh' -type f` and phase plan/summary probe scan | No probes found | SKIP |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| QA-01 | 22-01, 22-02 | Deterministic Demo visual evidence for required Home/Editor states where local simulator tooling allows it. | SATISFIED | Exact iPhone 17 destination, build/test commands, blocker, required states, and rerun protocol are recorded. |
| QA-02 | 22-02 | Verify current controls, labels, badges, and panels do not clip or overlap. | SATISFIED | Accepted blocker path records blocked review notes for every required state instead of false visual pass claims. |
| QA-03 | 22-01, 22-02 | Store v1.4 evidence under `.planning/evidence/v1.4/` with commands, framing, and notes. | SATISFIED | Evidence ledger exists under the required directory with command, environment, framing, review notes, no-PNG inventory, and rerun protocol. |
| QA-04 | 22-01, 22-02 | Unsupported product areas stay honest and inactive; no accidental new route. | SATISFIED | Static source scans and existing test names substantiate route/model disabled honesty while XCTest is blocked by the Metal Toolchain. |

No orphaned Phase 22 requirements were found in `.planning/REQUIREMENTS.md`; QA-01 through QA-04 are all mapped to Phase 22 and appear in plan frontmatter.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | Debt markers, placeholder text, empty implementations, hardcoded empty rendered data, console-only handlers | - | Phase artifacts scanned clean. |

### Human Verification Required

None. The phase is passing specifically through the documented blocker-honest protocol, not through a visual screenshot pass that would require human image review.

### Gaps Summary

No blocking gaps found. The current local Metal Toolchain blocker remains, but it is the explicitly allowed Phase 22 completion path when documented with exact command, destination, environment, failure summary, impact, next step, rerun protocol, no PNGs, and no false pass claim. All required blocker metadata and route/model honesty evidence are present.

---

_Verified: 2026-07-01T06:53:40Z_  
_Verifier: the agent (gsd-verifier)_
