---
phase: 16
slug: example-image-validation-harness
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-26
---

# Phase 16 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM executable build/run plus shell static scans |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path BeautySDK --product BeautyExampleRenderer` |
| **Full suite command** | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinWhitening_0p50 && file example-images/input/e2.png example-images/out/e2__skinWhitening_0p50.png` |
| **Estimated runtime** | build depends on local SwiftPM cache; run and shell checks should complete in under 60 seconds after build artifacts exist |

## Sampling Rate

- **After 16-01 task 1:** Build `BeautyExampleRenderer`.
- **After 16-01 task 2:** Run the representative renderer case and confirm output existence.
- **After 16-01 task 3:** Run dimension, ignored-output, facade-only import, and factual visual observation checks.
- **After 16-02:** Run documentation/planning scans and `git diff --check` over touched planning files.
- **Before `$gsd-verify-work`:** Re-run the build, representative renderer command, dimension proof, ignored-output check, and documentation scan.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 16-01-01 | 16-01 | 1 | PREP-01 | T-16-01 | Renderer remains a SwiftPM executable depending on public `BeautySDK`. | build/static | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path BeautySDK --product BeautyExampleRenderer && ! rg -n "import Beauty(Core|Detection|Render|Effects|Resources)|import SwiftUI|import UIKit" BeautySDK/Sources/BeautyExampleRenderer` | W0 | pending |
| 16-01-02 | 16-01 | 1 | PREP-01, PREP-02 | T-16-02 | Renderer writes local ignored output only. | runtime/shell | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinWhitening_0p50 && test -f example-images/out/e2__skinWhitening_0p50.png && git check-ignore example-images/out/e2__skinWhitening_0p50.png` | W0 | pending |
| 16-01-03 | 16-01 | 1 | PREP-02, PREP-03 | T-16-03 | Representative output dimensions match source and watermark is factual local observation only. | shell/manual | `file example-images/input/e2.png example-images/out/e2__skinWhitening_0p50.png` | W0 | pending |
| 16-02-01 | 16-02 | 2 | PREP-04 | T-16-04 | Validation docs preserve geometry limitation and no-new-UI boundary. | static/docs | `rg -n "skinWhitening_0p50|e2__skinWhitening_0p50.png|example-images/out|Geometry Limitation|swift build --package-path BeautySDK --product BeautyExampleRenderer" docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | W0 | pending |
| 16-02-02 | 16-02 | 2 | PREP-01, PREP-02, PREP-03, PREP-04 | T-16-05 | Planning ledger marks completion only after rerun evidence. | static/docs | `rg -n "PREP-01|PREP-02|PREP-03|PREP-04|skinWhitening_0p50|e2__skinWhitening_0p50.png" .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md PLANS.md` | W0 | pending |

## Wave 0 Requirements

- [x] `BeautySDK/Package.swift` already declares the executable product.
- [x] `BeautySDK/Sources/BeautyExampleRenderer/main.swift` already exists.
- [x] `example-images/input/e1.png` through `e5.png` already exist.
- [x] `.gitignore` already ignores `example-images/out/`.
- [x] Shell tools `swift`, `file`, `rg`, and `git check-ignore` cover Phase 16 validation.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Watermark placement | PREP-03 | Shell can prove output existence and dimensions, but not whether the bottom watermark avoids the face. | Open `example-images/out/e2__skinWhitening_0p50.png` after the renderer run and record only factual observations: image is non-empty, watermark is readable, and bottom watermark does not cover the face. |

## Validation Sign-Off

- [x] All planned tasks have automated verify coverage or an explicit manual-only reason.
- [x] Sampling continuity: no three consecutive tasks without automated verify.
- [x] Wave 0 covers existing tooling and fixtures.
- [x] No watch-mode flags.
- [x] Feedback latency target documented.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-26
