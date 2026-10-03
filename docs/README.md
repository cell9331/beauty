# Documentation Index

`docs/` stores long-form planning and historical design material for `beauty`.
Root-level documents and the two authorities below define current contracts;
historical blueprints and experiment logs do not create present work items.
The current [image-effect acceptance policy](IMAGE_EFFECT_ACCEPTANCE.md) allows
authorized generated portraits as full effect inputs; older real-image-only
requirements in historical plans or spike notes are superseded for new work.

Current upper-eyelid availability (2026-10-03): `去脂` is suspended, hidden from
default renderer discovery/batches and omitted from normal integration examples.
Its explicit API compatibility and safety tests remain; natural-appearance
effect qualification has failed. The current mechanism is bounded image-space
luminance correction, without reliable fullness recognition. See the
[current cause and evidence summary](UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md)
and [PLANS.md](../PLANS.md). Old experiments in `docs/history/` preserve their
original findings and never reopen work automatically. The owner has now
explicitly reopened research/planning for this effect and same-colored object
protection in [v1.25](../.planning/ROADMAP.md); see the
[new paper/code comparison](RETOUCH_RESEARCH_AND_V1_25_2026-10-03.md) and the
subsequent owner-authorized [R2 MVP contract](RETOUCH_MVP_REQUIREMENTS.md).
R2 plans finite automatic eyelid-tone and visible-boundary patch protection;
SEG input/oracle preparation passed G0; [four development versions](SEG_DEVELOPMENT_2026-10-03.md)
were then rejected and the SEG budget is exhausted. This branch stops unqualified. The
[G0 validation design](RETOUCH_G0_VALIDATION_PLAN.md) and
[logical case roster](RETOUCH_G0_CASE_MANIFEST.md) define the frozen inputs and measurements. [SEG G0 freeze](SEG_G0_FREEZE_2026-10-03.md) passes 20/0/0
and 96 texture controls across 30 frozen cases; 30 EYE cases remain not_prepared.
Holdouts were used only for G0 controls, with zero candidate evaluations. After planning, the owner
explicitly authorized a [bounded development pilot](../scripts/experiments/retouch-mvp-pilot/README.md);
it does not replace G0 or qualify either branch. The [pilot result](RETOUCH_MVP_PILOT_2026-10-03.md)
is now available: SEG passed one procedural family; E1-v1 failed and stops this round.

## Authority

Current inventory validation uses the [new batch tool](CURRENT_BATCH_VALIDATION.md):
98 default / 99 registered, explicit per-case pixel contracts and separate missing
oracle/failure results. The old 75-case wrapper remains historical. This tooling
does not qualify the SEG/EYE candidates or reclassify suspended effects.

Use documents in this order:

1. Code and tests.
2. `AGENTS.md`, `PLANS.md` and its current plan/debt links, followed by the
   relevant root-level owner contracts.
3. `docs/SDK_EFFECT_TAXONOMY.md` for effect status and
   `docs/IMAGE_EFFECT_ACCEPTANCE.md` for current image-input acceptance.
4. `.planning/PROJECT.md` and `.planning/STATE.md` for current summaries and
   recovery links to PLANS; active v1.25 roadmap/requirements follow that scope.
   Previous snapshots and codebase analyses are historical context.
5. This `docs/` index and the other long-form documents below as background.
6. `docs/_source/` only as imported source material.

If a long-form doc conflicts with a root-level contract, follow the root-level contract and update the drifting doc or record the conflict in `PLANS.md`.

## Current Repository State

完整功能盘点见[全部功能与完成状态清单（2026-10-01）](FEATURE_COMPLETION_INVENTORY_2026-10-01.md)：77 参数、11 配置、资源及 SDK 支撑能力逐项列出，明确完成范围、活跃缺口与暂停事项。该清单是日期快照；现行状态仍以 PLANS 和 taxonomy 为准。

Current follow-up (2026-10-03): the [finite texture-semantic probe](TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md)
rejected its only automatic candidate. General unmasked skin-colored object
identification has no qualified general solution; explicit masks remain supported. A low-contrast
lip outside coarse protection remains a documented limitation. The
[host integration guide](HOST_TEXTURE_PROTECTION.md) verifies known object and
lip pixels together through the existing binary mask API. No automatic
algorithm is credited by that integration. The active R2 plan now targets a finite
automatic patch domain; see PLANS for current scope and independent branch gates.

Last audited: 2026-10-01; see the [project status and drift audit](PROJECT_STATUS_AUDIT_2026-10-01.md).
The six confirmed current-document findings have been repaired; the audit
retains their original observations and links to the repair record.

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
- `.planning/PROJECT.md` and `.planning/STATE.md` route to the current root
  plan. The active v1.25 roadmap/requirements define the new scoped milestone.
  Prior planning snapshots and seven `.planning/codebase/` maps preserve dated
  context; old counts/statuses do not define current execution.
- The mandatory closeout is `bash scripts/run-no-skip-swiftpm.sh`; it verifies
  archives and the boundary scanner before its bounded one-child SwiftPM run.

## Long-Form Docs

0. [Historical Meitu Core Beauty Blueprint](meitu-function-blueprint/README.md) — reference grouping and dated evidence, not the current implementation backlog.
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
