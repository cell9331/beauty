---
last_mapped: 2026-06-03
last_mapped_commit: 5e20ce8ea81763f47b5194a69f90ab43a2eab675
focus: tech
mapping_mode: inline sequential fallback
---

# Integrations

## Summary

The main worktree currently has no live external service integrations, no network dependencies, and no SDK package dependencies. Existing integrations are limited to local Apple platform tooling, Xcode project generation, asset catalogs, git/GSD workflow metadata, and documentation references.

## Runtime Integrations

| Integration | Current State | Evidence |
| --- | --- | --- |
| SwiftUI | Implemented for the demo shell | `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`, `BeautyDemo/BeautyDemo/ContentView.swift` |
| Xcode project | Implemented as a single iOS app project | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` |
| Asset catalog | Present with default metadata only | `BeautyDemo/BeautyDemo/Assets.xcassets/` |
| Generated Info.plist | Enabled by build settings | `GENERATE_INFOPLIST_FILE = YES` in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` |
| XCTest or Swift Testing | Not implemented | No test target or test source exists in main worktree |
| Swift Package Manager | Intended, not implemented in mainline | No `BeautySDK/Package.swift` in main worktree |

## Apple Framework Boundaries

Implemented Swift source imports only `SwiftUI`.

Frameworks documented for future work but not used in current source:

- `AVFoundation` for camera capture, owned by future Demo camera code per `FRONTEND.md`.
- `Metal`, `CoreImage`, and optional `MPS` for future rendering per `ARCHITECTURE.md`.
- `Vision` and optional Core ML for future detection per `ARCHITECTURE.md`.
- `OSLog` / `Logger` for future diagnostics per `RELIABILITY.md`.

## Protected Resource Integration

No camera or photo-library code exists in the main worktree today. As a result:

- No `NSCameraUsageDescription` is currently required by implemented source.
- No `NSPhotoLibraryUsageDescription` is currently required by implemented source.
- `SECURITY.md` requires these purpose strings before future camera or photo access.
- Permission states for Demo camera flow are documented in `SECURITY.md` but not implemented.

## Network And Remote Services

Current policy and implementation both indicate no network integration:

- `SECURITY.md` states the SDK has no network dependency.
- The main Swift source contains no URL loading, upload, analytics, auth, webhook, or backend client code.
- No API keys, endpoints, service manifests, or environment files are present in the main worktree scan.

Before adding network behavior, `SECURITY.md`, `RELIABILITY.md`, and `PRODUCT_SENSE.md` require explicit updates for endpoint, payload, retention, authentication, retry, timeout, offline behavior, and user-facing disclosure.

## Resource And Asset Integration

Current bundled assets are default placeholders:

- `BeautyDemo/BeautyDemo/Assets.xcassets/AccentColor.colorset/Contents.json` contains one universal color entry with no concrete color value.
- `BeautyDemo/BeautyDemo/Assets.xcassets/AppIcon.appiconset/Contents.json` declares universal iOS icon slots, including dark and tinted appearances, with no image filenames.
- `BeautyDemo/BeautyDemo/Assets.xcassets/Contents.json` is default metadata.

Future SDK resource handling is documented but absent:

- LUT, shader, model, preset, and makeup package validation belong to future `BeautyResources`.
- `SECURITY.md` requires schema, size, type, path traversal, checksum, and version checks for external resources.
- `RELIABILITY.md` requires missing optional resources to degrade gracefully.

## GSD And Planning Integrations

The repository now contains this generated map under `.planning/codebase/`.

Existing project-level planning and historical context live outside `.planning/`:

- Root contracts: `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md`.
- Historical long docs: `docs/README.md` plus `docs/01_product_feature_plan.md` through `docs/10_document_audit_report.md`.
- Superpowers planning artifacts: `docs/superpowers/specs/2026-05-25-sdk-foundation-design.md` and `docs/superpowers/plans/2026-05-25-sdk-foundation.md`.

## Local Auxiliary Integrations

The repository has a local ignored worktree:

- `.worktrees/sdk-foundation` on branch `codex/sdk-foundation`.
- `.worktrees/` is ignored by `.gitignore`.
- It contains a `BeautySDK/Package.swift` and other files, but those are not part of the main worktree codebase map.

Downstream agents should inspect that worktree only when explicitly working on branch reconciliation or recovering prior implementation work.
