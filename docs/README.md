# Documentation Index

`docs/` stores long-form planning and historical design material for `beauty`.
Root-level documents and the two authorities below define current contracts;
historical blueprints and experiment logs do not create present work items.
The current [image-effect acceptance policy](IMAGE_EFFECT_ACCEPTANCE.md) allows
authorized generated portraits as full effect inputs; older real-image-only
requirements in historical plans or spike notes are superseded for new work.

Current terminal disposition (2026-10-03): [v1.25 closed with unmet objectives](RETOUCH_FINAL_DISPOSITION_2026-10-03.md).
Both automatic targets exhausted two methods/four versions without qualification.
Upper-eyelid correction remains suspended/default-hidden with explicit compatibility;
automatic skin-colored object/patch recognition is not integrated. Existing
[host object + lip masks](HOST_TEXTURE_PROTECTION.md) remain an assisted capability.
The [industry comparison](RETOUCH_INDUSTRY_DECISION_2026-10-03.md) explains alternative
information/model requirements without claiming untested models failed.
No EYE G0 continuation, fifth candidate or training job is queued.

[PLANS](../PLANS.md), the [terminal requirement ledger](../.planning/REQUIREMENTS.md)
and [R3 scope](RETOUCH_TERMINAL_SCOPE_2026-10-03.md) own current disposition.
The frozen [R2 contract](RETOUCH_MVP_REQUIREMENTS.md), [SEG freeze](SEG_G0_FREEZE_2026-10-03.md),
[SEG development](SEG_DEVELOPMENT_2026-10-03.md) and [pilot](RETOUCH_MVP_PILOT_2026-10-03.md)
retain original thresholds and outcomes; their earlier pending/next-step wording
is historical and cannot reopen development. Candidate holdout evaluations remain zero.

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
   recovery links to PLANS; v1.25 is closed and there is no active milestone.
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
algorithm is credited by that integration. The later finite patch-domain repair
also failed and closed; see PLANS for the terminal result, not an automatic retry.

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
  plan. v1.25 roadmap/requirements now record terminal closure with unmet objectives;
  there is no active milestone.
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
