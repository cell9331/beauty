---
phase: 20
slug: core-module-closeout
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-30
---

# Phase 20 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, shell static scans, renderer output checks, and factual visual observations |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyEffectsTests` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Renderer command** | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` |
| **Estimated runtime** | Focused scans should complete in seconds; full SDK suite and renderer matrix depend on local SwiftPM cache state. |

## Sampling Rate

- **After editor-shell docs/root-contract edits:** Run editor ownership scans, Demo facade-only import scans, no-new-UI/source scans, and `git diff --check`.
- **After renderer evidence generation:** Check output existence, ignored status, non-empty files, dimensions against inputs, and factual watermark/visual observations for representative outputs.
- **After ledger edits:** Run requirement traceability scans, `roadmap.analyze`, `phase-plan-index 20`, `verify.schema-drift 20`, and `git diff --check`.
- **Before `$gsd-verify-work`:** Run `swift test --package-path BeautySDK`, all current renderer cases, final scope scans, and planning consistency checks.
- **Max feedback latency:** under 2 minutes for static scans and focused tests after build artifacts exist; full suite/render matrix may run longer.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 20-01-01 | 20-01 | 1 | EDITOR-01, EDITOR-02 | T-20-01-01 | Editor-shell docs document input routing, preview chrome, bottom panel, and commit flow as implemented app-side support without SDK ownership creep. | static/docs | `rg -n "Input routing|Preview chrome|Bottom panel|Commit flow|BeautyDemo/Editor|BeautyDemo/Panel|BeautyDemo/State|BeautySDK facade" docs/meitu-function-blueprint/features/editor-shell docs/meitu-function-blueprint/MODULES.md` | W0 | pending |
| 20-01-02 | 20-01 | 1 | EDITOR-03, MOD-03 | T-20-01-02 | Root/current authority docs describe cancel/confirm, compare/debug, sliders, rails, and snapshots as app-side support logic, not SDK algorithm logic. | static/docs | `rg -n "cancel|confirm|compare|debug|slider|category rail|parameter snapshot|app-side|Demo" FRONTEND.md PRODUCT_SENSE.md docs/meitu-function-blueprint/features/editor-shell docs/meitu-function-blueprint/MODULES.md` | W0 | pending |
| 20-02-01 | 20-02 | 2 | MOD-04 | T-20-02-01 | Full SDK tests and all current renderer cases prove visible skin/color/filter outputs without adding geometry cases. | full suite + renderer | `swift test --package-path BeautySDK` and `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` | W0 | pending |
| 20-02-02 | 20-02 | 2 | EDITOR-01, EDITOR-02, EDITOR-03, MOD-03, MOD-04 | T-20-02-02 | Final negative scans prove no new SwiftUI screens, public parameters, renderer cases, SDK ownership creep, internal Demo imports, or sensitive diagnostics. | static/code/docs | Public-parameter exact-field scan, `git diff --name-only -- BeautyDemo`, renderer geometry-case scan, Demo internal-import scan, SDK SwiftUI/UIKit scan, and redaction scan. | W0 | pending |
| 20-02-03 | 20-02 | 2 | MOD-02, MOD-03, MOD-04 | T-20-02-03 | Planning ledgers close only after verification evidence exists and maintain v1.3 no-new-UI/core-module wording. | docs/GSD | `node "$HOME/.codex/get-shit-done/bin/gsd-tools.cjs" query roadmap.analyze`, `phase-plan-index 20`, `verify.schema-drift 20`, and traceability scans. | W0 | pending |

## Wave 0 Requirements

- [x] Phase 20 `CONTEXT.md` exists.
- [x] SwiftPM package and current SDK test inventory exist.
- [x] `BeautyExampleRenderer` exists and current built-in cases are listed.
- [x] Editor-shell blueprint docs exist.
- [x] Demo editor/source/test files exist for app-side evidence.
- [x] No UI-SPEC is required because Phase 20 explicitly forbids new UI behavior; the workflow's repo-local UI safety helper is absent and did not block planning.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Renderer watermark readability and visible natural output changes | MOD-04 | Shell checks prove dimensions/existence but not visual readability. | Inspect representative generated PNGs. Record only factual observations: readable bottom watermark, watermark below face, non-empty output, same dimensions, and visible natural change for cases expected to affect output. |
| Real-device camera/Vision parity and production visual naturalness | Release hardening, not Phase 20 | Deferred by current `PLANS.md` tech debt and Phase 20 scope. | Do not block Phase 20; keep as release-risk wording/tech debt. |

## Validation Sign-Off

- [x] All task areas have automated verification or explicit manual-only reason.
- [x] Sampling continuity: no three consecutive task areas without automated verification.
- [x] Wave 0 covers all known test/doc/fixture prerequisites.
- [x] No watch-mode flags.
- [x] Feedback latency target documented.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-30
