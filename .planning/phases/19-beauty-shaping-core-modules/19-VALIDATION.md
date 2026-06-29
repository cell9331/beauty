---
phase: 19
slug: beauty-shaping-core-modules
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-29
---

# Phase 19 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest plus shell static scans |
| **Config file** | `BeautySDK/Package.swift` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyEffectsTests` |
| **Full suite command** | `swift test --package-path BeautySDK` |
| **Estimated runtime** | Focused XCTest and shell scans should complete in under 2 minutes after SwiftPM build artifacts exist; full suite runtime depends on local cache state. |

## Sampling Rate

- **After provider or resolver changes:** Run the narrowest affected XCTest filter and `git diff --check` on touched files.
- **After branch documentation changes:** Run branch-status scans across beauty-shaping blueprint docs, feature matrix, and module docs.
- **After diagnostics, warnings, or metrics changes:** Run focused resolver/degradation tests and redaction scans.
- **After any public facade, parameter, Demo, or renderer touch:** Run negative scans proving Phase 19 did not add public shaping parameters, UI/SwiftUI work, geometry renderer cases, or fake saved-image claims.
- **Before `$gsd-verify-work`:** Run `swift test --package-path BeautySDK`, all required negative scans from `19-CONTEXT.md` D-19, and `git diff --check` on generated planning/docs files.
- **Max feedback latency:** under 2 minutes for focused XCTest and shell scans after SwiftPM build artifacts exist.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 19-01-01 | 19-01 | 1 | BSHAPE-01, BSHAPE-03 | T-19-01 | Branch docs keep `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, and `眉毛` in honest implemented/partial/blocked/future status without geometry-output overclaim. | static/docs | `rg -n "3D塑颜|比例|脸型|眼睛|嘴唇|鼻子|眉毛|blocked-by-geometry-output|partial|future" docs/meitu-function-blueprint/features/beauty-shaping docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/MODULES.md` | W0 | pending |
| 19-01-02 | 19-01 | 1 | BSHAPE-02, BSHAPE-03 | T-19-02 | Existing provider, cap, degradation, and resolver coverage gaps are identified before implementation touches code. | unit/static | `swift test --package-path BeautySDK --filter BeautyEffectsTests` plus targeted inventory of shaping provider/test files listed in `19-CONTEXT.md`. | W0 | pending |
| 19-02-01 | 19-02 | 2 | BSHAPE-02 | T-19-03 | Promoted face-shape/chin, eye, nose, mouth, proportion, and lip behavior stays bounded by existing public parameters and safety caps. | unit | `swift test --package-path BeautySDK --filter FaceShapeWarpProviderTests && swift test --package-path BeautySDK --filter EyeWarpProviderTests && swift test --package-path BeautySDK --filter NoseWarpProviderTests && swift test --package-path BeautySDK --filter MouthWarpProviderTests` | W0 | pending |
| 19-02-02 | 19-02 | 2 | BSHAPE-02 | T-19-04 | Missing, stale, reused, or incomplete face geometry degrades safely without leaking landmarks, control points, bounding boxes, raw Vision objects, paths, or image bytes. | unit/static | `swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests && swift test --package-path BeautySDK --filter BeautyEffectResolverTests` plus redaction scans over `BeautySDK/Sources/BeautyEffects` and relevant tests. | W0 | pending |
| 19-02-03 | 19-02 | 2 | BSHAPE-02 | T-19-05 | Combined geometry weakening remains deterministic and avoids exaggerated multi-effect deformation. | unit | `swift test --package-path BeautySDK --filter GeometryConflictResolverTests && swift test --package-path BeautySDK --filter CombinedEffectSafetyTests` | W0 | pending |
| 19-03-01 | 19-03 | 3 | BSHAPE-01, BSHAPE-03 | T-19-06 | No new public `BeautyParameters`, no UI/SwiftUI work, no renderer geometry cases, and no public facade saved-image geometry claim are introduced by Phase 19. | static/code/docs | Negative scans over `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift`, `BeautyDemo/`, `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, and blueprint/planning docs for forbidden status/API/UI/renderer overclaims. | W0 | pending |
| 19-03-02 | 19-03 | 3 | BSHAPE-02, BSHAPE-03 | T-19-07 | Full SDK tests pass after all shaping provider, resolver, degradation, and documentation evidence is complete. | full suite | `swift test --package-path BeautySDK` | W0 | pending |

## Wave 0 Requirements

- [x] `BeautySDK/Package.swift` already declares the tested library targets and XCTest targets.
- [x] Existing shaping provider files exist under `BeautySDK/Sources/BeautyEffects/Warp/`.
- [x] Existing focused shaping tests exist for face-shape/chin, eyes, nose, mouth, geometry conflict resolution, missing landmarks, resolver behavior, and combined safety.
- [x] Existing blueprint docs cover the active beauty-shaping branch family and sub-branches.
- [x] No new test framework, simulator UI harness, renderer case, or public facade geometry-output harness is required for Phase 19.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Saved-image visual geometry output | BSHAPE-03 | Out of scope for Phase 19 by `19-CONTEXT.md` D-04 through D-06; public facade detection plus geometry render integration does not yet produce saved renderer outputs. | Do not attempt manual visual approval for face/facial-feature geometry output in Phase 19. Record the blocker and keep affected branches `partial` or `blocked-by-geometry-output`. |

## Validation Sign-Off

- [x] All planned task areas have automated verification coverage or an explicit manual-only reason.
- [x] Sampling continuity: no three consecutive task areas without automated verification.
- [x] Wave 0 covers all known framework and fixture requirements.
- [x] No watch-mode flags.
- [x] Feedback latency target documented.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-29
