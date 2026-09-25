# Documentation Index

`docs/` stores long-form planning and historical design material for `beauty`.
Root-level documents remain the current contract for agents and implementation work.
The current [image-effect acceptance policy](IMAGE_EFFECT_ACCEPTANCE.md) allows
authorized generated portraits as full effect inputs; older real-image-only
requirements in historical plans or spike notes are superseded for new work.

## Authority

Use documents in this order:

1. Code and tests.
2. Root-level contracts: `AGENTS.md`, `PLANS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`.
3. `docs/SDK_EFFECT_TAXONOMY.md` for effect status and
   `docs/IMAGE_EFFECT_ACCEPTANCE.md` for current image-input acceptance.
4. `.planning/PROJECT.md` for the active GSD project definition.
5. This `docs/` index and the other long-form documents below as background.
6. `docs/_source/` only as imported source material.

If a long-form doc conflicts with a root-level contract, follow the root-level contract and update the drifting doc or record the conflict in `PLANS.md`.

## Current Repository State

Last audited: 2026-08-25 after the owner-only/non-distributed SDK contract was adopted.

- The active repository is SDK-only. `BeautySDK/Package.swift` is the sole build
  graph and SwiftPM is the sole current build/test runner.
- `BeautySDK` is a Swift-public library for the project owner's locally
  controlled App/tools; `BeautyExampleRenderer` is the SDK-owned command-line
  consumer. It is not offered to third parties, and no SDK binary, model,
  weight, private fixture, or derived data is published or distributed.
- `public` throughout current documents means Swift access level and the
  owner-local integration surface. Any customer, package-registry, App Store,
  model-transfer, or external-release scope requires a new explicit license/
  security/product review. Internal commercial use is allowed only when every
  admitted data/model license covers it; research-only inputs do not.
- The two retired UI/Demo histories exist only as independently pinned artifacts
  under `archives/legacy-ui/`; verify and restore them only through that
  directory's README into a fresh outside-repository temporary directory.
- `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, and the
  seven `.planning/codebase/` maps describe the current SDK-only boundary.
- The mandatory closeout is `bash scripts/run-no-skip-swiftpm.sh`; it verifies
  archives and the boundary scanner before its bounded one-child SwiftPM run.

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
