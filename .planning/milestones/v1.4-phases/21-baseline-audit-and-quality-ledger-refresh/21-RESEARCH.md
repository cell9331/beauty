# Phase 21: Baseline Audit and Quality Ledger Refresh - Research

**Researched:** 2026-06-30
**Status:** Complete
**Question:** What must be known to plan Phase 21 well?

## Research Summary

Phase 21 is an audit and ledger-refresh phase. It should produce current evidence and routing decisions before any v1.4 implementation phase changes code. The phase should not repair downstream debt, refresh broad `.planning/codebase/*` maps, add product scope, add public `BeautyParameters`, add renderer cases, or claim release readiness.

The safest plan split is:

1. Run and record the baseline sweep in a dedicated phase artifact.
2. Use that evidence to refresh `QUALITY_SCORE.md`, `PLANS.md`, and current `.planning` ledgers.

This keeps command evidence separate from interpretation and prevents debt-routing edits from preceding the actual baseline.

## Phase Boundary Findings

- `21-CONTEXT.md` locks a full available baseline sweep, not command inventory alone.
- A failing command is acceptable only when the exact command, environment, concise failure summary, impact, and next step are recorded.
- Evidence must distinguish current pass/fail/blocker results from archived v1.3 evidence and deferred later-phase checks.
- TD-005, TD-008, TD-009, and TD-010 are routed, not fixed.
- `.planning/codebase/*` maps are stale and must not be treated as current authority.

## Current Local Probe Results

These probes are discovery evidence for planning only. Execution plans must rerun the relevant commands and record current results.

| Probe | Observed result | Planning implication |
| --- | --- | --- |
| `swift --version` | Apple Swift 6.3.3, target `arm64-apple-macosx26.0` | SDK SwiftPM commands are locally available. |
| `xcodebuild -version` | Xcode 26.6, build `17F113` | Demo commands should record Xcode version in blockers/evidence. |
| `swift test --package-path BeautySDK --list-tests` | Succeeded and listed 141 XCTest entries. The command warns that `--list-tests` is deprecated. | Plan execution should prefer full `swift test --package-path BeautySDK`; optional inventory may use `swift test list` or record the deprecation warning. |
| `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` | Listed `BeautyDemo`, `BeautyDemoTests`, schemes `BeautyDemo`, `BeautyExampleRenderer`, `BeautySDK`; also reported CoreSimulator out-of-date: current `1051.54.0`, required `1051.55.0`. | Demo xcodebuild availability can be inventoried, but simulator build/test may be blocked and must record exact CoreSimulator evidence. |
| `xcrun simctl list devices available` | Listed iOS 26.5 devices after a stale-service/version-change warning and `NSPOSIXErrorDomain code=22`. | Plans should require explicit destination selection and blocker classification if simulator commands fail. |
| `find example-images/input` | 5 input fixtures. | Renderer sweep should expect 5 inputs. |
| `find example-images/out -name '*.png'` | 45 current outputs exist locally. | Existing output count matches 5 inputs times 9 current renderer cases, but execution must rerun or verify fresh status before updating scores. |

## Baseline Sweep Scope

The Phase 21 audit artifact should include a table with at least:

- command or scan name
- exact command attempted
- environment details that matter
- result: `passed`, `failed`, `blocked`, `not attempted`, `deferred`, or `archived`
- concise output summary
- affected requirement or debt item
- next step or routed phase

Minimum command groups:

1. SDK test/build evidence:
   - `swift test --package-path BeautySDK`
   - `swift build --package-path BeautySDK --product BeautyExampleRenderer`
2. Renderer evidence:
   - `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out`
   - output count, ignored-output check, non-empty check, dimension/watermark checks where feasible
3. Demo Xcode evidence:
   - `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj`
   - explicit-destination `xcodebuild ... build`
   - explicit-destination test or focused test where local simulator tooling allows
4. Static boundary and privacy scans:
   - Demo internal target imports
   - SDK non-UI target SwiftUI/UIKit imports
   - no network/upload/raw path/raw framework error scan over active Demo paths
   - public detection/geometry/raw framework leakage scan
   - public `BeautyParameters` inventory
   - renderer geometry-case exclusion
5. Planning/root consistency:
   - `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`
   - stale `.planning/codebase/*` map note

## Debt Routing Recommendations

| Debt | Recommended Phase 21 disposition |
| --- | --- |
| TD-005 Privacy Manifest | Route to Phase 25 unless audit discovers an existing manifest or a concrete required-reason API blocker. Do not add `PrivacyInfo.xcprivacy` in Phase 21. |
| TD-008 Manual Device QA | Split: visual/camera UI evidence to Phase 22, performance/long-run to Phase 23, and physical-device gaps marked blocked if no iPhone is available. |
| TD-009 Manual Visual QA | Route to Phase 22, which owns deterministic Demo visual/layout evidence under `.planning/evidence/v1.4/`. |
| TD-010 Phase 6 Visual and Hardware QA | Split across Phase 22 visual/layout, Phase 23 performance/long-run, Phase 24 renderer output regression, and Phase 25 privacy/security closeout. |

TD-003 and TD-004 appear stale relative to the implemented app/tests, but Phase 21 should audit and update them only if the baseline evidence directly proves the status. It should not expand the task into broad tech-debt cleanup.

## Stale Codebase Map Handling

`.planning/codebase/TESTING.md`, `.planning/codebase/CONCERNS.md`, and `.planning/codebase/CONVENTIONS.md` can be cited as stale-risk inputs only. They should not override:

- actual source and tests
- root contracts
- `.planning/PROJECT.md`
- `.planning/REQUIREMENTS.md`
- `.planning/ROADMAP.md`
- `.planning/STATE.md`
- archived v1.3 verification

Do not refresh those maps in Phase 21. Record a risk or deferred item if their stale state can misroute later agents.

## Validation Architecture

Phase 21 is documentation/audit work, but it has concrete validation:

- Full SDK verification: `swift test --package-path BeautySDK`.
- Renderer build/run: `swift build --package-path BeautySDK --product BeautyExampleRenderer` and `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out`.
- Demo simulator gate: explicit `xcodebuild` build/test destination where CoreSimulator permits it; otherwise record a reproducible blocker.
- Static scans for architecture, privacy, public API, renderer scope, and documentation placeholders.
- GSD gates: plan structure scan, requirement coverage, decision coverage, roadmap/state updates, and post-planning gap analysis.

## Planning Recommendation

Create two plans:

1. `21-01`: Baseline verification sweep and evidence ledger. Produces `21-BASELINE-AUDIT.md`.
2. `21-02`: Quality score, debt routing, stale-map note, planning ledger refresh, and closeout verification. Depends on `21-01`.

Both plans must include threat models because security enforcement is enabled. Both plans should stay autonomous but must stop on unclassified command failures instead of silently marking them passed.

## Research Complete

The planner should use:

- `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-CONTEXT.md`
- this `21-RESEARCH.md`
- current root docs
- current source/test surfaces
- archived Phase 20 verification

The plans must keep Phase 21 as audit and routing work only.
