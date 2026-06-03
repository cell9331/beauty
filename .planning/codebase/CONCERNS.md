---
last_mapped: 2026-06-03
last_mapped_commit: 5e20ce8ea81763f47b5194a69f90ab43a2eab675
focus: concerns
mapping_mode: inline sequential fallback
---

# Concerns

## Summary

The repository has strong architecture and product contracts, but the main worktree implementation is still a minimal SwiftUI template. The main planning risk is confusing documented intent with implemented capability.

## High Priority Concerns

### SDK Package Is Missing

`BeautySDK/Package.swift` does not exist in the main worktree. This blocks most root contract verification:

- No `BeautyCore`.
- No `BeautyDetection`.
- No `BeautyRender`.
- No `BeautyEffects`.
- No `BeautyResources`.
- No facade `BeautySDK`.

This is already recorded as `TD-002` in `PLANS.md` and as the top repair item in `QUALITY_SCORE.md`.

### Demo Is Still The Default Template

The main Demo UI is only:

- `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`.
- `BeautyDemo/BeautyDemo/ContentView.swift`.

It does not implement camera preview, image editor, parameter panel, presets, before/after compare, debug overlay, or SDK integration. This is already recorded as `TD-003` in `PLANS.md`.

### No Tests Exist

No SDK unit tests, render tests, security tests, performance tests, or UI tests exist in the main worktree. This is recorded as `TD-004` in `PLANS.md`.

### Privacy Manifest And Permissions Are Not Implemented

No `PrivacyInfo.xcprivacy` exists. No camera or photo usage strings are currently needed by implemented source, but they are required before future camera/photo flows. This is recorded as `TD-005` in `PLANS.md`.

## Medium Priority Concerns

### Dirty Worktree Before Mapping

`git status --short --branch` showed many pre-existing modified, deleted, and untracked documentation files before `.planning/codebase/` was created. This map preserves those changes.

Downstream agents should inspect status carefully before committing, because a broad `git add -A` would include unrelated user or prior-agent changes.

### Ignored Worktree May Contain Divergent Implementation

`git worktree list` reports `.worktrees/sdk-foundation` on branch `codex/sdk-foundation`. That ignored worktree contains a `BeautySDK/Package.swift` and other implementation artifacts, but it is not part of the main worktree map.

Risk:

- Agents may see the ignored worktree in file-system scans and assume the SDK exists in mainline.
- Merging or copying from it without review may overwrite or conflict with current root docs.

Recommendation:

- Treat `.worktrees/sdk-foundation` as separate branch work.
- Use explicit git/worktree commands before comparing or importing anything from it.

### Xcode Environment Warnings

`xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` succeeded, but emitted warnings and errors about:

- FSEvents stream startup.
- `DARWIN_USER_CACHE_DIR`.
- CoreSimulatorService connection.
- CoreSimulator log file permission.
- Simulator runtime discovery.
- Some provisioning profile loading.

These did not block project listing, but they may affect simulator builds or UI testing in this environment.

### Deployment Target Is Very New

`IPHONEOS_DEPLOYMENT_TARGET = 26.5` appears in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`. That may be intentional for a future SDK environment, but it is unusually high for broad compatibility. Downstream planning should confirm compatibility goals before relying on that deployment target.

## Documentation Drift Concerns

The root docs supersede historical docs, but historical docs remain extensive. `AGENTS.md` and `QUALITY_SCORE.md` already define conflict scanning rules. Future work should keep root docs synchronized and treat `docs/` as background unless a root doc explicitly routes to it.

Examples of drift-sensitive areas:

- Public API shape such as `BeautyEngine`, `BeautyParameters`, and `BeautyError`.
- Shader naming, especially `Warp.metal`.
- Diagnostics location under `BeautyCore/Diagnostics`.
- Realtime path prohibition on `UIImage`.
- 31-field `BeautyParameters` model.

## Security And Reliability Gaps

These are not bugs in current source because the SDK is not implemented yet, but they are required before product readiness:

- Parameter validation for ranges, NaN, infinity, and resource IDs.
- Pixel buffer and image validation.
- Redacted logging and metrics.
- Typed public `BeautyError` mapping.
- Graceful degradation for no-face, missing landmarks, missing resources, GPU overload, and memory pressure.
- Bounded caches and `reset()` behavior.

## Recommended Next Step

After `$gsd-new-project` finishes, the first implementation phase should create the `BeautySDK` Swift Package skeleton with tests. The existing Superpowers plan in `docs/superpowers/plans/2026-05-25-sdk-foundation.md` is the strongest current implementation guide, but it should be reconciled with the new GSD `.planning/` roadmap before execution.
