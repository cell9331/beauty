# Codebase Structure

**Analysis Date:** 2026-06-10

## Directory Layout

```text
beauty/
├── AGENTS.md                         # Agent entry and routing rules
├── ARCHITECTURE.md                   # Target SDK package and dependency contracts
├── DESIGN.md                         # Parameter, frame, result, detection, render design contracts
├── FRONTEND.md                       # SwiftUI Demo app rules and future UI structure
├── SECURITY.md                       # Privacy, validation, resources, logging constraints
├── RELIABILITY.md                    # Error, diagnostics, performance, recovery contracts
├── PRODUCT_SENSE.md                  # Product journeys and acceptance criteria
├── QUALITY_SCORE.md                  # Quality scorecard and recurring scans
├── PLANS.md                          # Work ledger
├── BeautyDemo/
│   ├── BeautyDemo.xcodeproj/         # Only current Xcode project
│   └── BeautyDemo/
│       ├── BeautyDemoApp.swift       # Current SwiftUI app entry
│       ├── ContentView.swift         # Current default "Hello, world!" view
│       └── Assets.xcassets/          # App icon and accent color metadata
├── docs/                             # Long-form and historical planning docs
│   ├── README.md                     # Docs entry and authority notes
│   └── superpowers/                  # Historical planning specs/plans
└── .planning/
    └── codebase/                     # Generated GSD codebase map
```

Ignored but present on disk:

```text
.worktrees/                           # Ignored auxiliary worktrees
.codex-backups/                       # Ignored historical backups
.serena/                              # Local tool metadata
```

## Directory Purposes

**BeautyDemo/**
- Purpose: Current iOS demo app project.
- Contains: Xcode project plus app source directory.
- Key files: `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`, `BeautyDemo/BeautyDemo/ContentView.swift`.
- Subdirectories: `BeautyDemo/BeautyDemo/Assets.xcassets` for generated asset metadata.

**docs/**
- Purpose: Long-form product, architecture, implementation, algorithm, and audit background.
- Contains: `docs/01_product_feature_plan.md` through `docs/10_document_audit_report.md`.
- Key files: `docs/README.md` documents authority and current repo-state notes.
- Subdirectories: `docs/superpowers/` contains historical spec/plan artifacts.

**.planning/codebase/**
- Purpose: Generated GSD map of current repository state.
- Contains: `STACK.md`, `INTEGRATIONS.md`, `ARCHITECTURE.md`, `STRUCTURE.md`, `CONVENTIONS.md`, `TESTING.md`, `CONCERNS.md`.
- Key files: This directory is consumed by `$gsd-new-project` brownfield initialization.
- Subdirectories: None.

**Root markdown files**
- Purpose: Current authoritative contracts and work ledger.
- Contains: Agent workflow, architecture, design, frontend, security, reliability, product, quality, and plan docs.
- Key files: `AGENTS.md` and `PLANS.md` are required reading before changes.

## Key File Locations

**Entry Points:**
- `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`: App `@main` entry.
- `BeautyDemo/BeautyDemo/ContentView.swift`: Initial SwiftUI view.

**Configuration:**
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`: Project target, build phases, generated Info.plist, Swift settings.
- `.gitignore`: Ignores `.worktrees/`, `.codex-backups/`, `.DS_Store`, and `*.xcuserstate`.
- `BeautyDemo/BeautyDemo.xcodeproj/project.xcworkspace/contents.xcworkspacedata`: Xcode workspace metadata.

**Core Logic:**
- No SDK core logic exists yet.
- Future SDK code should go under `BeautySDK/Sources/**` according to `ARCHITECTURE.md`.

**Testing:**
- No test files or test targets exist yet.
- Future SDK tests should go under `BeautySDK/Tests/**` according to `ARCHITECTURE.md`.

**Documentation:**
- `AGENTS.md`: Agent entry and task routing.
- `PLANS.md`: Active/completed work ledger.
- `QUALITY_SCORE.md`: Current quality snapshot and required scans.
- `docs/README.md`: Long-form docs index and authority notes.

## Naming Conventions

**Files:**
- Root contract docs use uppercase names: `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`.
- Long-form docs use numbered snake_case markdown names: `docs/01_product_feature_plan.md`.
- Swift files use PascalCase: `BeautyDemoApp.swift`, `ContentView.swift`.
- Xcode asset metadata uses `Contents.json`.

**Directories:**
- App/project names use PascalCase: `BeautyDemo`.
- Future SDK package should use PascalCase: `BeautySDK`.
- Historical docs use lowercase collection names: `docs/superpowers/specs`, `docs/superpowers/plans`.

**Special Patterns:**
- GSD generated codebase-map files use uppercase document names in `.planning/codebase/`.
- Xcode user UI state `*.xcuserstate` is ignored.
- `.worktrees/` is ignored and must not be counted as current main worktree implementation.

## Where to Add New Code

**New SDK Package:**
- Primary code: `BeautySDK/Sources/<TargetName>/`.
- Tests: `BeautySDK/Tests/<TargetName>Tests/`.
- Package manifest: `BeautySDK/Package.swift`.
- Contract owners: `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`.

**New Demo UI:**
- Implementation: `BeautyDemo/BeautyDemo/`.
- Suggested future organization: `App/`, `Camera/`, `Editor/`, `Panel/`, `State/`, `Debug/`, `Support/` from `FRONTEND.md`.
- Tests: add Xcode test targets or UI test targets before claiming automated UI coverage.

**New Resources:**
- App-only assets: `BeautyDemo/BeautyDemo/Assets.xcassets`.
- Future SDK resources: `BeautySDK/Sources/BeautyResources/Resources/` or Swift Package resource declarations.
- Resource security owner: `SECURITY.md`.

**New Planning Work:**
- GSD project context: `.planning/PROJECT.md`.
- GSD requirements/roadmap/state: `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`.
- Phase artifacts: `.planning/phases/`.

## Special Directories

**.worktrees/**
- Purpose: Auxiliary worktree experiments, including `sdk-foundation`.
- Source: Local ignored workspace.
- Committed: No; ignored by `.gitignore`.
- Caution: Do not treat implementation under `.worktrees/sdk-foundation/` as delivered in the main worktree.

**.codex-backups/**
- Purpose: Historical backups, including the old nested `BeautyDemo` git repository backup.
- Source: Local backup from repository restructuring.
- Committed: No; ignored by `.gitignore`.

**docs/_source/**
- Purpose: Imported source material only.
- Source: Historical import.
- Committed: Currently untracked in this working tree.
- Caution: `AGENTS.md` says it is not a reading entry.

---
*Structure analysis: 2026-06-10*
*Update when the SDK package, tests, CI, or Demo directory structure changes.*
