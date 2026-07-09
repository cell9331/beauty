# Documentation Index

`docs/` stores long-form planning and historical design material for `beauty`.
Root-level documents remain the current contract for agents and implementation work.

## Authority

Use documents in this order:

1. Code and tests.
2. Root-level contracts: `AGENTS.md`, `PLANS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`.
3. `.planning/PROJECT.md` for the active GSD project definition.
4. This `docs/` index and the long-form documents below as background.
5. `docs/_source/` only as imported source material.

If a long-form doc conflicts with a root-level contract, follow the root-level contract and update the drifting doc or record the conflict in `PLANS.md`.

## Current Repository State

Last audited: 2026-06-10.

- `BeautyDemo/` exists and contains one iOS Xcode project with target / scheme `BeautyDemo`.
- `BeautyDemo/BeautyDemo/ContentView.swift` is still the default SwiftUI `Hello, world!` template.
- The main worktree has no `BeautySDK/Package.swift`.
- `.planning/PROJECT.md` exists and defines v1 as the SDK API + minimal Demo integration foundation.
- `.planning/STATE.md` and `.planning/ROADMAP.md` do not exist yet; GSD workflow preferences, requirements, and roadmap are still pending.
- `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` succeeds with the currently selected full Xcode.
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` was verified on 2026-06-10 and succeeded.
- The generic `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo build` command may fail locally if Xcode selects an incompatible `My Mac` destination; pass an explicit simulator destination.

## Long-Form Docs

0. [Meitu Core Beauty Module Plan](meitu-function-blueprint/README.md)
1. [Beauty SDK Product Feature Plan](01_product_feature_plan.md)
2. [iOS Beauty SDK Development Stages Full Plan](02_development_stages_full_plan.md)
3. [iOS Beauty SDK Architecture SPM Skeleton](03_architecture_spm_skeleton.md)
4. [iOS Beauty SDK Development Spec](04_development_spec.md)
5. [Beauty SDK Public API Design](05_public_api_design.md)
6. [Beauty Parameters Spec](06_beauty_parameters_spec.md)
7. [Beauty SDK Face Landmarks Coordinate System](07_face_landmarks_coordinate_system.md)
8. [Beauty SDK Metal Render Pipeline Design](08_metal_render_pipeline_design.md)
9. [Beauty SDK Algorithm Effects Implementation](09_algorithm_effects_implementation.md)
10. [Document Audit Report](10_document_audit_report.md)

## Historical Planning Docs

The `docs/superpowers/` files are execution planning artifacts from 2026-05-25. They are useful for implementation sequencing, but their environment observations can become stale. Current toolchain and build facts should be taken from `PLANS.md`, `QUALITY_SCORE.md`, this index, and fresh command output.

## Source Import File

- `docs/_source/docs_total.json` is kept only as the original imported source, not as the reading entry.
