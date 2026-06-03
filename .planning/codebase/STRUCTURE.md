---
last_mapped: 2026-06-03
last_mapped_commit: 5e20ce8ea81763f47b5194a69f90ab43a2eab675
focus: arch
mapping_mode: inline sequential fallback
---

# Structure

## Summary

The main worktree is organized around root contracts, a minimal `BeautyDemo` Xcode app, historical docs, and generated GSD map artifacts. There is no mainline `BeautySDK/` directory yet.

## Main Directories

```text
.
├── BeautyDemo/
│   ├── BeautyDemo.xcodeproj/
│   └── BeautyDemo/
├── docs/
│   ├── README.md
│   ├── 01_product_feature_plan.md
│   ├── ...
│   ├── 10_document_audit_report.md
│   ├── _source/
│   └── superpowers/
├── .planning/
│   └── codebase/
├── .worktrees/              ignored local worktrees
├── .codex-backups/          ignored local backups
└── root contract markdown files
```

## Root Contract Files

The root-level documentation system is the primary current contract layer:

- `AGENTS.md` routes agents and defines read order.
- `PLANS.md` records active, completed, and technical debt work.
- `ARCHITECTURE.md` defines SDK target boundaries and dependency direction.
- `DESIGN.md` defines data structures, parameters, coordinates, render graph, and state machines.
- `FRONTEND.md` defines Demo SwiftUI and UI state rules.
- `SECURITY.md` defines privacy, permissions, validation, resources, and logging boundaries.
- `RELIABILITY.md` defines errors, degradation, metrics, performance, reset, and crash policy.
- `PRODUCT_SENSE.md` defines product journeys and acceptance checks.
- `QUALITY_SCORE.md` defines scorecards, scans, and release gates.

`AGENTS.md` states the precedence order as code and tests, then `PLANS.md`, then root specialty docs, then `docs/` history.

## Demo App Structure

Implemented files:

- `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`.
- `BeautyDemo/BeautyDemo/ContentView.swift`.
- `BeautyDemo/BeautyDemo/Assets.xcassets/Contents.json`.
- `BeautyDemo/BeautyDemo/Assets.xcassets/AccentColor.colorset/Contents.json`.
- `BeautyDemo/BeautyDemo/Assets.xcassets/AppIcon.appiconset/Contents.json`.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.
- `BeautyDemo/BeautyDemo.xcodeproj/project.xcworkspace/contents.xcworkspacedata`.

The app source directory has no subfolders for `App/`, `Camera/`, `Editor/`, `Panel/`, `State/`, `Debug/`, or `Support/` yet. Those directories are recommended by `FRONTEND.md` for future work.

## Historical Docs

`docs/README.md` is the long-document index. It points to:

- `docs/01_product_feature_plan.md`.
- `docs/02_development_stages_full_plan.md`.
- `docs/03_architecture_spm_skeleton.md`.
- `docs/04_development_spec.md`.
- `docs/05_public_api_design.md`.
- `docs/06_beauty_parameters_spec.md`.
- `docs/07_face_landmarks_coordinate_system.md`.
- `docs/08_metal_render_pipeline_design.md`.
- `docs/09_algorithm_effects_implementation.md`.
- `docs/10_document_audit_report.md`.

`docs/_source/docs_total.json` is preserved only as an imported source, not a reading entry.

## Superpowers Planning Docs

Existing planning artifacts outside `.planning/`:

- `docs/superpowers/specs/2026-05-25-sdk-foundation-design.md`.
- `docs/superpowers/plans/2026-05-25-sdk-foundation.md`.

These describe a future SDK foundation implementation plan. They are useful for phase planning, but the implementation is not present in the main worktree.

## Ignored Local State

`.gitignore` currently ignores:

- `.DS_Store`.
- `.codex-backups/`.
- `.worktrees/`.
- `*.xcuserstate`.

Local ignored directories observed:

- `.codex-backups/BeautyDemo_git_before_root_init_20260525_190709`.
- `.codex-backups/docs_zh_before_english_20260525_1830`.
- `.worktrees/sdk-foundation`.

`git worktree list` reports:

- `/Users/yakangwang/codes/beauty` on branch `main`.
- `/Users/yakangwang/codes/beauty/.worktrees/sdk-foundation` on branch `codex/sdk-foundation`.

The ignored worktree contains a `BeautySDK/Package.swift`, but it is not part of the main worktree structure.

## Current Git State Caveat

At mapping time, the main worktree was dirty before this task. Existing changes included root docs, renamed docs, deleted historical filenames, and untracked docs. This map adds `.planning/codebase/` and updates `PLANS.md`; it does not normalize or revert pre-existing changes.
