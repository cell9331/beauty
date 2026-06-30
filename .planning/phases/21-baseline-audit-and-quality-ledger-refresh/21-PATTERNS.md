# Phase 21 Pattern Map

**Generated:** 2026-06-30
**Phase:** 21 - Baseline Audit and Quality Ledger Refresh

## Planning Pattern

Phase 21 should follow the Phase 20 closeout pattern, but with audit-only scope:

- First plan records command/scanning evidence in a phase artifact.
- Second plan updates ledgers only after the evidence artifact exists.
- Requirement completion is gated by exact command results, not by prose.
- Hardware/tooling blockers are allowed only with reproducible command and environment details.

Closest analogs:

| Needed artifact | Closest analog | Pattern to reuse |
| --- | --- | --- |
| `21-BASELINE-AUDIT.md` | `.planning/phases/20-core-module-closeout/20-VERIFICATION.md` | Use command blocks, result summaries, output tables, scope scans, limitations, and no-overclaim notes. |
| `21-01-PLAN.md` | `.planning/phases/20-core-module-closeout/20-02-PLAN.md` | Run full SDK tests, renderer build/run, static scans, and write evidence before ledger closeout. |
| `21-02-PLAN.md` | `.planning/phases/20-core-module-closeout/20-02-PLAN.md` plus `PLANS.md` completed entries | Update `.planning` ledgers and root/current docs after evidence passes; preserve explicit limitations. |
| Debt routing table | `PLANS.md` Tech Debt section | Update only relevant rows and keep the table as the long-lived debt ledger. |
| Score refresh | `QUALITY_SCORE.md` Sections 3, 7, 10, 13, 14 | Score changes require code, tests, command output, current docs, or recorded manual checks. |

## File Ownership

| File | Role in Phase 21 | Editing rule |
| --- | --- | --- |
| `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` | New evidence ledger for current baseline commands, scans, blockers, and deferred checks. | Create in Plan 21-01; Plan 21-02 reads it as source of truth. |
| `QUALITY_SCORE.md` | Root quality baseline and doc-gardening rules. | Update only with evidence from `21-BASELINE-AUDIT.md`; do not raise scores without current proof. |
| `PLANS.md` | Long-lived work/debt ledger. | Route TD-005, TD-008, TD-009, TD-010; do not fix the debt in Phase 21. |
| `.planning/PROJECT.md` | Current milestone/product state. | Clarify v1.4 baseline status only if audit evidence changes current state. |
| `.planning/STATE.md` | GSD current position and next steps. | Update through GSD handlers where possible; record Phase 21 execution outcome at closeout. |
| `.planning/ROADMAP.md` | Phase status and wave dependency annotations. | Use GSD handlers/annotation where possible; keep phase boundaries intact. |
| `.planning/codebase/*` | Stale codebase maps. | Do not refresh; record stale-map risk if needed. |

## Command Patterns

Use exact commands in evidence artifacts:

```bash
swift test --package-path BeautySDK
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out
xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=<Simulator Name>,OS=<OS Version>' build
```

Static scan pattern:

```bash
rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests || true
rg -n "SwiftUI|UIKit" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyRender BeautySDK/Sources/BeautyEffects 2>/dev/null || true
rg -n "URLSession|http://|https://|upload|/private/var|NSError|AVError" BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor BeautyDemo/BeautyDemo/Support 2>/dev/null || true
```

## Evidence Classification Pattern

Each evidence row should use one of:

- `passed`: command or scan ran now and passed.
- `failed`: command ran now and failed because of a repo/code/test issue.
- `blocked`: command could not produce meaningful repo evidence because of local tooling/hardware.
- `not attempted`: command was intentionally not run in Phase 21; explain why.
- `deferred`: check belongs to a later v1.4 phase.
- `archived`: evidence is from prior phase verification and is cited as historical, not current.

## Known Local Tooling Pattern

Current discovery showed:

- SwiftPM is usable.
- Xcode resolves project targets/schemes.
- CoreSimulator reports a version mismatch through `xcodebuild -list`.
- `simctl` can list iOS 26.5 devices after a stale-service warning.

Execution must rerun commands and record current output. Do not assume the mismatch still exists, and do not treat it as a fake pass if an explicit destination build/test fails.

## Anti-Patterns

- Marking TD-005, TD-008, TD-009, or TD-010 fixed in Phase 21.
- Raising quality scores from archived v1.3 evidence without current baseline proof.
- Refreshing `.planning/codebase/*` maps during Phase 21.
- Treating simulator evidence as physical-device evidence.
- Treating renderer skin/color/filter output as geometry saved-image completion.
- Adding Swift code, public parameters, SwiftUI routes, renderer cases, or privacy manifests during baseline planning.
