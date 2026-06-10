# Architecture

**Analysis Date:** 2026-06-10

## Pattern Overview

**Overall:** Documentation-led iOS SDK project with a minimal SwiftUI demo shell.

**Key Characteristics:**
- The only buildable code in the main worktree is `BeautyDemo`, a single iOS app target.
- Current runtime implementation is a generated SwiftUI app shell, not the SDK described by root contracts.
- Root documents define a future `BeautySDK` Swift Package with multiple internal targets.
- `.worktrees/sdk-foundation/` exists on disk but is ignored by `.gitignore`; it must not be treated as main worktree implementation.

## Layers

**Repository Guidance Layer:**
- Purpose: Direct agents and define authoritative workflow/document routing.
- Contains: `AGENTS.md`, `PLANS.md`, `QUALITY_SCORE.md`.
- Depends on: Repository text and command output.
- Used by: All future agent work.

**Root Contract Layer:**
- Purpose: Define target SDK architecture, data models, UI boundaries, security, reliability, and product acceptance.
- Contains: `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`.
- Depends on: Current code/test facts when conflicts exist.
- Used by: GSD planning, phase planning, implementation, and verification.

**Historical Planning Layer:**
- Purpose: Provide background long-form plans and previous implementation design.
- Contains: `docs/README.md`, `docs/01_product_feature_plan.md` through `docs/10_document_audit_report.md`, and `docs/superpowers/`.
- Depends on: Root contracts for authority.
- Used by: Research and implementation sequencing only after checking for drift.

**Demo App Layer:**
- Purpose: Current executable app and future SDK integration sample.
- Contains: `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`, `BeautyDemo/BeautyDemo/ContentView.swift`, `BeautyDemo/BeautyDemo/Assets.xcassets`, and `BeautyDemo/BeautyDemo.xcodeproj`.
- Depends on: SwiftUI only today.
- Used by: Xcode build/list verification and future SDK integration UI.

**Target SDK Layer (not implemented):**
- Purpose: Future host-app-facing beauty SDK.
- Expected location: `BeautySDK/Package.swift`, `BeautySDK/Sources/**`, `BeautySDK/Tests/**`.
- Current status: Missing from main worktree.
- Defined by: `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`.

## Data Flow

**Current Demo App Launch:**

1. iOS launches `BeautyDemo`.
2. `BeautyDemo/BeautyDemo/BeautyDemoApp.swift` enters through `@main`.
3. `WindowGroup` creates `ContentView()`.
4. `BeautyDemo/BeautyDemo/ContentView.swift` renders a `VStack` with a system globe image and `Text("Hello, world!")`.
5. No SDK, camera, image processing, external service, or persistence path runs.

**Current Documentation Flow:**

1. Agents read `AGENTS.md`.
2. Agents read `PLANS.md` before changing code/docs.
3. Task-specific root contracts route detailed constraints.
4. `docs/` files are background and must yield to root contracts.
5. GSD planning will consume `.planning/codebase/` before creating `.planning/PROJECT.md`.

**Future Target SDK Flow (contract only):**

1. Host app imports `BeautySDK`.
2. Host creates `BeautyEngine` and `BeautyParameters`.
3. Host passes image or frame input with explicit orientation.
4. SDK validates input, runs detection/resources/render/effects internally.
5. SDK returns output or typed `BeautyError`.

**State Management:**
- Current SwiftUI code uses no explicit state.
- Future Demo state is specified in `FRONTEND.md` as enum-driven SwiftUI state and app-side stores.
- Future SDK frame processing should use immutable per-frame parameter snapshots per `DESIGN.md`.

## Key Abstractions

**SwiftUI App:**
- Purpose: Current entry point and app shell.
- Examples: `BeautyDemoApp`, `ContentView`.
- Pattern: Xcode-generated SwiftUI app.

**Xcode Target:**
- Purpose: Build and package the current demo app.
- Examples: target and scheme `BeautyDemo`.
- Pattern: Single native app target with file-system-synchronized source group.

**Root Contract:**
- Purpose: Define intended behavior before implementation exists.
- Examples: dependency invariants in `ARCHITECTURE.md`, parameter model in `DESIGN.md`, privacy rules in `SECURITY.md`.
- Pattern: Agent-first documentation used as planning input.

**GSD Planning Artifacts:**
- Purpose: Capture brownfield map and later project/requirements/roadmap.
- Examples: `.planning/codebase/*.md`; future `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`.
- Pattern: Generated markdown references for downstream GSD workflows.

## Entry Points

**App Entry:**
- Location: `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`.
- Triggers: iOS app launch.
- Responsibilities: Create the SwiftUI scene and show `ContentView`.

**Main View:**
- Location: `BeautyDemo/BeautyDemo/ContentView.swift`.
- Triggers: Created by `BeautyDemoApp`.
- Responsibilities: Render the default template UI.

**Build Entry:**
- Location: `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.
- Triggers: Xcode or `xcodebuild`.
- Responsibilities: Define `BeautyDemo` target, Debug/Release configurations, generated Info.plist, asset catalogs, and Swift build settings.

## Error Handling

**Strategy:** No app-specific error handling exists yet.

**Patterns:**
- Current Swift code does not throw, catch, log, or map errors.
- Future public SDK errors are specified in `RELIABILITY.md` as typed `BeautyError`.
- Future protected-resource failures should be represented in Demo UI state per `SECURITY.md` and `FRONTEND.md`.

## Cross-Cutting Concerns

**Logging:**
- None implemented in current code.
- Future local diagnostics are specified under `BeautyCore/Diagnostics`.

**Validation:**
- None implemented in current code.
- Future validation requirements live in `SECURITY.md` and `DESIGN.md`.

**Authentication:**
- None.

**Privacy:**
- Current app does not access camera/photos.
- Future camera/photo access requires purpose strings and runtime authorization.

---
*Architecture analysis: 2026-06-10*
*Update when `BeautySDK/Package.swift`, Demo integration, tests, or app capabilities are added.*
