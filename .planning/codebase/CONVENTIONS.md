---
last_mapped: 2026-06-03
last_mapped_commit: 5e20ce8ea81763f47b5194a69f90ab43a2eab675
focus: quality
mapping_mode: inline sequential fallback
---

# Conventions

## Summary

Current executable code follows default SwiftUI template conventions. Most project-specific conventions are documented in root markdown contracts rather than enforced in source code yet.

## Agent And Documentation Workflow

`AGENTS.md` defines the repository workflow:

- Read `AGENTS.md` first.
- Read `PLANS.md` before changes.
- Read the specialty root doc for the task type.
- Read relevant code, tests, and historical docs.
- Update the owning contract when behavior changes.

`PLANS.md` requires:

- Add or update an Active plan before work.
- Move completed work into Completed with verification evidence.
- Record blockers and skipped verification explicitly.
- Put out-of-scope discoveries into Tech Debt instead of expanding the task.

## Source Of Truth Convention

Precedence from `AGENTS.md`:

1. Code and tests.
2. `PLANS.md`.
3. Root specialty docs.
4. `docs/` historical materials.

This matters because the current code is much smaller than the documented target architecture. Downstream agents should not assume SDK targets exist until `BeautySDK/Package.swift` is present in the main worktree.

## Swift Conventions Observed

The two Swift files use the stock Xcode style:

- Header comment block with filename, target, author, and creation date.
- `import SwiftUI` at the top.
- `@main` app entry in `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`.
- `struct ContentView: View` with a computed `body`.
- SwiftUI preview with `#Preview`.

No custom naming, error handling, async, dependency injection, or module boundary conventions are implemented in source yet.

## Planned Swift Conventions

Root contracts define conventions for future source:

- Public SDK values should prefer `struct`, `enum`, and `protocol`.
- Cross-concurrency values should explicitly satisfy `Sendable`.
- `BeautyParameters` should be `Codable`, `Equatable`, and `Sendable`.
- `BeautyEngine.init` should be `throws`.
- Public errors should map to stable `BeautyError` cases.
- Recoverable failures must not use `fatalError`.
- Realtime frame processing must not route through `UIImage`.
- App UI state should use enum-driven presentation state instead of parallel booleans.

## Documentation Style

Root docs use:

- Short ownership prefaces at the top.
- Numbered sections.
- Tables for invariants, constraints, scorecards, and acceptance criteria.
- Concrete file paths and command examples.
- Explicit decision logs.

`AGENTS.md` is intentionally kept as a navigation file rather than a deep business-rule file.

## Security And Logging Conventions

`SECURITY.md` and `RELIABILITY.md` define future conventions:

- Default local-only processing.
- No image bytes, file paths, landmarks, bounding boxes, tokens, raw JSON, or user identifiers in logs.
- Release log level defaults to `error`.
- Per-frame logs are disabled by default.
- Debug metrics are optional, redacted, and should not persist sensitive payloads.

No logging code is implemented yet.

## Git And Worktree Conventions

The root repository is the main worktree. `.worktrees/` is ignored and used for auxiliary branches. `.codex-backups/` is ignored and stores local migration backups.

Because `.worktrees/sdk-foundation` exists and contains SDK implementation artifacts, future agents should be explicit about whether they are working in mainline or the auxiliary worktree. Do not copy or merge from the auxiliary worktree without reading its state and respecting user changes.

## Naming Conventions

Current naming:

- App target and product: `BeautyDemo`.
- Intended SDK package and facade: `BeautySDK`.
- Intended internal targets: `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`.

Root docs explicitly reject splitting facial-feature effects into separate packages like eye, nose, mouth, or face SDK packages.
