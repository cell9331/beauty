# Historical lifecycle records 07

### C-2026-07-09-gsd-plan-phase-29-eye-renderer-output-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-09 |
| Scope | Created Phase 29 executable plans for Eye Renderer Output Evidence from Phase 29 context, research, validation strategy, and pattern map artifacts. |
| Requirements | EYE-01, EYE-02, EYE-03 |
| Files | `.planning/milestones/v1.6-phases/29-eye-renderer-output-evidence/29-RESEARCH.md`, `29-VALIDATION.md`, `29-PATTERNS.md`, `29-01-PLAN.md`, `29-02-PLAN.md`, `29-03-PLAN.md`, `29-04-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | User selected research-first. Researcher created `29-RESEARCH.md` and commit `90435c4`. Validation strategy commit `1a9ab03` created `29-VALIDATION.md`; pattern map commit `e521c77` created `29-PATTERNS.md`; planner created four plan files in commit `3a387aa`. Checker pass 1 found unresolved research questions and a missing Phase 28 evidence analog reference; commit `3bc2433` resolved both. Final plan-checker returned `VERIFICATION PASSED` for 4 plans. Requirement scan confirmed EYE-01, EYE-02, and EYE-03 are covered. `check.decision-coverage-plan` passed with `14/14` decisions covered. `phase-plan-index 29` reports waves 1-4: `29-01`, `29-02 -> 29-01`, `29-03 -> 29-01/29-02`, and `29-04 -> 29-03`. Scoped `git diff --check` passed for Phase 29 planning artifacts, `.planning/STATE.md`, and this ledger. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Phase 29 execution plans require focused SDK tests, full `swift test --package-path BeautySDK`, `BeautyExampleRenderer` build/run, Phase 29 helper checks, generated gallery checks, ignored-output checks, raw-leak/no-overclaim scans, and GSD decision coverage. |

Outcome:

- `29-01-PLAN.md` adds exactly six public-facade eye renderer cases plus renderer inventory tests and `check_eye_renderer_outputs.py` for 161/161 outputs and 36/36 eye-vs-baseline comparisons.
- `29-02-PLAN.md` adds ignored generated `eyes/` gallery support and updates example-image validation docs without committing generated PNG baselines.
- `29-03-PLAN.md` records command-backed renderer/helper/gallery/ignore evidence and final validation, mirroring the Phase 28 evidence artifact structure.
- `29-04-PLAN.md` synchronizes requirements, roadmap, state, quality, and ledger notes while keeping `眼睛` rows and branch status partial until Phase 30.
- Phase 29 is ready for `$gsd-execute-phase 29`.

### C-2026-07-09-gsd-discuss-phase-29-eye-renderer-output-evidence

| Field | Value |
| --- | --- |
| Completed | 2026-07-09 |
| Scope | Ran `$gsd-discuss-phase 29` for Eye Renderer Output Evidence. Captured Phase 29 implementation decisions for public-facade eye renderer case matrix, helper evidence gates, generated output/gallery routing, and documentation/status boundaries. |
| Requirements | EYE-01, EYE-02, EYE-03 |
| Files | `.planning/milestones/v1.6-phases/29-eye-renderer-output-evidence/29-CONTEXT.md`, `.planning/milestones/v1.6-phases/29-eye-renderer-output-evidence/29-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.phase-op 29` reported Phase 29 exists with no prior context, research, plans, verification, or phase directory. `todo.match-phase 29` returned zero matches. Prior context from Phases 26, 27, and 28 plus root contracts, blueprint docs, current renderer/eye code, tests, helper, gallery, and ignore policy were read. User selected all three gray areas and chose the recommended option for each detailed question. Scoped `git diff --check` passed for Phase 29 context/log, `.planning/STATE.md`, and this ledger. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 29 planning should include renderer inventory tests, helper verification, `BeautyExampleRenderer` build/run, ignored-output/gallery checks, and no-overclaim/status scans. |

Outcome:

- Phase 29 should add exactly six eye renderer cases: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, and `eyeTailLift_0p25`.
- The Phase 29 helper should validate the full renderer matrix plus 36/36 portrait eye-vs-`geometryBaseline_noop` top-region comparisons, and fail/fix before completion if any comparison fails.
- `example-images/output/` is the canonical generated output path, and generated gallery support should add an ignored `eyes/` group.
- Phase 29 may record renderer evidence but must keep `眼睛` rows and branch status `partial` until Phase 30 safety/degradation/ledger closeout passes.

Next step: `$gsd-plan-phase 29`.

### C-2026-07-09-v1-6-milestone-initialization

| Field | Value |
| --- | --- |
| Completed | 2026-07-09 |
| Scope | Started v1.6 as the Broader `美型 / 五官` SDK Slice - Eyes milestone after converging the dirty worktree. Defined requirements and roadmap for the existing-parameter `眼睛` slice without adding UI, public API, commercial, network, device, release-readiness, or unscoped eye-tool scope. |
| Files | `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `state.milestone-switch --milestone "v1.6" --name "Broader 美型 / 五官 SDK Slice - Eyes"` initialized milestone state. Scoped scans verified v1.6 references, Phase 29/30 routing, and EYE-01 through EYE-08 plus DOC-01 traceability across `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, and `PLANS.md`. `git diff --check` passed. |
| Build | Not run; this was a planning/documentation initialization with no Swift source changes. |

Outcome:

- v1.6 is now the active milestone.
- Phase 29 owns public-facade eye renderer/helper output evidence for `eyeSize`, signed `eyeDistance`, signed `eyeYPosition`, and `eyeTailLift`.
- Phase 30 owns eye caps/degradation/redaction/boundary tests and scoped ledger/documentation closeout.
- Branch-level `眼睛` remains partial until evidence-backed rows are promoted.

Next step: `$gsd-discuss-phase 29`.

### C-2026-07-09-example-input-e6-portrait-fixture

| Field | Value |
| --- | --- |
| Completed | 2026-07-09 |
| Scope | Added user-supplied `e6.jpg` as a sixth committed portrait fixture while preserving the nested example-image contract and generated-output ignore policy. |
| Files | `example-images/input/portraits/e6.jpg`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py`, `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py`, `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`, `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`, `example-images/README.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `e6.jpg` is 1728x2304 and 591,802 bytes. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` regenerated 119 ignored flat outputs. `python3 .planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/output` passed with 77/77 outputs and 6/6 portrait geometry-vs-baseline top-region comparisons. `python3 .planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/output` passed with 119/119 outputs and 36/36 portrait face-shape-vs-baseline top-region comparisons. `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` wrote 119 ignored gallery PNGs. Focused fixture-path tests passed: `BeautyCoreTests.BeautyRendererOutputRegressionTests` 6 tests, `BeautyCoreTests.BeautyEngineGeometryFacadeTests` 8 tests, and `BeautyDetectionTests.VisionFaceDetectorTests` 8 tests. |
| Build | Focused SDK tests, renderer run, Phase 27 helper, Phase 28 helper, and gallery generation passed. Full SDK suite was not rerun because this only added one source fixture and synchronized fixture path inventories/docs. |

Outcome:

- `example-images/input/portraits/` now has six portrait fixtures: `e1.png` through `e5.png` plus `e6.jpg`.
- The Python helpers support PNG and JPEG input fixture dimensions while still requiring generated outputs to be PNG.
- Generated output and gallery artifacts remain ignored.

### C-2026-07-09-example-input-fixture-compression

| Field | Value |
| --- | --- |
| Completed | 2026-07-09 |
| Scope | Reduced committed `example-images/input` source fixture dimensions and file sizes so every original input image is below 1 MB while preserving renderer/test usefulness. |
| Files | `example-images/input/portraits/e1.png`, `example-images/input/portraits/e2.png`, `example-images/input/portraits/e3.png`, `example-images/input/portraits/e4.png`, `example-images/input/portraits/e5.png`, `example-images/input/negatives/no-face-gradient.png`, `example-images/README.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | Size/dimension inspection confirmed `e1.png` is 675x900 and 929,129 bytes; `e2.png`, `e3.png`, `e4.png`, and `e5.png` are 506x900 and 650,316/680,540/731,951/717,292 bytes; `no-face-gradient.png` is 64x64 and 381 bytes. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` regenerated 102 ignored flat outputs from compressed inputs. `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` wrote 102 ignored gallery PNGs. Focused fixture-path tests passed: `BeautyCoreTests.BeautyRendererOutputRegressionTests` 6 tests, `BeautyCoreTests.BeautyEngineGeometryFacadeTests` 8 tests, and `BeautyDetectionTests.VisionFaceDetectorTests` 8 tests. Phase 27 helper passed with 66/66 outputs and 5/5 portrait geometry-vs-baseline top-region comparisons. Phase 28 helper passed with 102/102 outputs and 30/30 portrait face-shape-vs-baseline top-region comparisons. `find` counted 102 output PNGs and 102 gallery PNGs. `git check-ignore` confirmed representative output and gallery PNGs are ignored. |
| Build | Focused SDK tests and renderer run passed. Full SDK suite was not rerun because this changed only committed example image fixtures, ignored regenerated artifacts, and docs. |

Outcome:

- Portrait source fixtures now use a 900 px maximum edge.
- The no-face negative fixture is now a 64x64 generated gradient.
- Every committed input PNG is under 1 MB.

### C-2026-07-08-example-images-structured-layout

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Finished the example-image directory design with committed nested input fixtures, ignored flat generated output, ignored generated gallery view, and synchronized renderer/test/helper/docs paths. |
| Files | `example-images/input/`, `example-images/README.md`, `example-images/generate_gallery.py`, `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`, `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py`, `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py`, `.gitignore`, `ARCHITECTURE.md`, `SECURITY.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed. Focused fixture-path tests passed: `BeautyCoreTests.BeautyRendererOutputRegressionTests` 6 tests, `BeautyCoreTests.BeautyEngineGeometryFacadeTests` 8 tests, and `BeautyDetectionTests.VisionFaceDetectorTests` 8 tests. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` regenerated 102 flat ignored PNG outputs from nested fixtures. `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` wrote 102 ignored gallery PNGs. Phase 27 helper passed with 66/66 outputs and 5/5 portrait geometry-vs-baseline top-region comparisons. Phase 28 helper passed with 102/102 outputs and 30/30 portrait face-shape-vs-baseline top-region comparisons. `find` counted 102 output PNGs and 102 gallery PNGs. `git check-ignore` confirmed representative output and gallery PNGs are ignored. A scoped scan found no active references to the legacy `example-images/out/` path or the old flat `example-images/input/e*.png` and `example-images/input/no-face-gradient.png` fixture paths. |
| Build | SDK renderer build and focused SDK tests passed. Full SDK suite was not rerun because this changed example fixture organization, renderer fixture discovery, helper scripts, ignored generated artifacts, and docs only. |

Outcome:

- Source fixtures are now committed under `example-images/input/portraits/` and `example-images/input/negatives/`.
- `BeautyExampleRenderer` recursively reads nested input fixtures and keeps generated PNG names flat under ignored `example-images/output/`.
- `example-images/gallery/` is an ignored generated review view grouped by feature family and case ID.

### C-2026-07-08-example-images-output-directory-rename

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Renamed the current generated example-image directory contract from `example-images/out` to `example-images/output` while keeping `example-images/input` as the source fixture directory. |
| Files | `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, `.gitignore`, `example-images/README.md`, `ARCHITECTURE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input` used the new default and wrote 102 ignored PNG outputs under `example-images/output`. `python3 .planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/output` passed with 102/102 outputs and 30/30 portrait face-shape comparisons. `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 6 tests. `git check-ignore` confirmed representative `example-images/output/*.png` files are ignored. A scoped scan found no legacy `example-images/out/` path in active renderer source, the example-image README, root contract docs, current quality snapshot, or SDK tests; older Completed ledger/history entries still preserve their original command text. |
| Build | SDK renderer build and focused renderer tests passed. Full SDK suite was not rerun because this changed the renderer default output path, ignore policy, local generated artifact directory, and docs only. |

Outcome:

- `example-images/input/` remains the committed fixture source directory.
- `example-images/output/` is now the ignored generated-output directory.
- Local generated PNGs were moved from `out/` to `output/`; the legacy `example-images/out/` directory was removed.

### C-2026-07-08-v1-5-face-shape-visual-warp-validation

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Corrected the v1.5 face-shape validation gap where saved renderer outputs changed pixels through a global geometry proxy but did not visibly deform face shape. |
| Requirements | GEO-03, FACE-01, FACE-02, FACE-03, FACE-04, FACE-05 |
| Files | `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`, `BeautySDK/Tests/BeautyEffectsTests/BeautyGeometryEffectPipelineTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`, `.planning/MILESTONES.md`, `.planning/RETROSPECTIVE.md`, `ARCHITECTURE.md`, `DESIGN.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | Confirmed the original CIImage path only applied `CIColorMatrix` global color bias after control-point generation. Replaced that path with control-point-driven local CIImage resampling that preserves unaffected pixels. Added `BeautyGeometryEffectPipelineTests/testCIImageGeometryWarpMovesLocalPixelsWithoutGlobalColorBias`. Focused tests passed: new spatial-warp test, `BeautyEffectsTests.GeometryConflictResolverTests`, `BeautyEffectsTests.FaceShapeWarpProviderTests`, and `BeautyCoreTests.BeautyEngineGeometryFacadeTests`. Full `swift test --package-path BeautySDK` passed with 172 tests. `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` regenerated 102 ignored PNG outputs. Phase 28 helper passed with 102/102 outputs and 30/30 portrait face-shape-vs-baseline top-region comparisons. |
| Build | SDK SwiftPM tests and `BeautyExampleRenderer` build/run passed. No Demo build/test was run because the correction changed SDK still-image internals, SDK tests, ignored renderer outputs, and documentation only; no Demo source/UI behavior changed. |

Outcome:

- User-reported validation issue is confirmed and fixed for the still-image public-facade path.
- v1.5 face-shape evidence now includes a spatial regression that rejects global color-only output as geometry evidence.
- Public API, Demo UI, raw geometry exposure, `jawSlim` alias handling, and scoped `脸型` ledger boundaries remain unchanged.

### C-2026-07-08-gsd-complete-milestone-v1-5

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Archived v1.5 SDK Geometry Output Foundation and Face Shape Slice after the milestone audit passed. |
| Requirements | GEO-01, GEO-02, GEO-03, GEO-04, FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/milestones/v1.5-ROADMAP.md`, `.planning/milestones/v1.5-REQUIREMENTS.md`, `.planning/milestones/v1.5-MILESTONE-AUDIT.md`, `.planning/MILESTONES.md`, `.planning/ROADMAP.md`, `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/RETROSPECTIVE.md`, `PLANS.md` |
| Verification | `audit-open` reported all artifact types clear. `roadmap.analyze` reported Phases 26-28 complete with 12/12 plans summarized and 100% progress. `.planning/milestones/v1.5-MILESTONE-AUDIT.md` has `status: passed`. `milestone.complete v1.5 --name "SDK Geometry Output Foundation and Face Shape Slice"` archived roadmap, requirements, and audit files and updated `MILESTONES.md`/`STATE.md`. Follow-up scans verified live roadmap/project/state references route to `$gsd-new-milestone`; archive files exist under `.planning/milestones/`; scoped whitespace/diff checks passed. |
| Build | Not run; this was a milestone archive/documentation workflow. No Swift source changed. |

Outcome:

- v1.5 is archived under `.planning/milestones/`.
- Live `.planning/ROADMAP.md` is constant-size and points to `$gsd-new-milestone`.
- `.planning/PROJECT.md` records v1.5 as the shipped version and moves v1.5 requirements into completed history.
- Phase directories remain in `.planning/phases/` for path-stable execution history, matching the prior v1.4 operator choice.

Next step: `$gsd-new-milestone`.

### C-2026-07-08-gsd-audit-milestone-v1-5

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Ran the v1.5 milestone audit preflight after `$gsd-progress --next` found Phases 26-28 complete and no incomplete execution work. |
| Requirements | GEO-01, GEO-02, GEO-03, GEO-04, FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/milestones/v1.5-MILESTONE-AUDIT.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, `PLANS.md` |
| Verification | Read GSD progress/next/audit workflow instructions, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, and Phase 26-28 verification/validation/summary artifacts. `gsd-tools.cjs query state.json`, `roadmap.analyze`, `phases.list`, and `init.milestone-op` showed v1.5 at 3/3 phases and 12/12 plans complete. Safety checks found no `.planning/.continue-here.md`, no error/failed state, no Phase 28 `FAIL` markers, and no plans without summaries. Requirement, verification, summary-frontmatter, and Nyquist scans confirmed 13/13 v1.5 requirements satisfied, Phase 26/27/28 verifications passed, and all three validation files are `nyquist_compliant: true`. |
| Build | Not run; this was a milestone audit/documentation workflow aggregating existing command-backed phase evidence. No Swift source changed. |

Outcome:

- `.planning/milestones/v1.5-MILESTONE-AUDIT.md` records `status: passed` with 13/13 requirements, 3/3 phases, 4/4 integration checks, and 4/4 E2E flows satisfied.
- No critical requirement, integration, flow, orphan, or Nyquist gaps were found.
- Deferred broader `美型 / 五官`, device, commercial, screenshot, profiling, packaging, and launch-readiness work remains outside v1.5 scope.

Next step completed by `C-2026-07-08-gsd-complete-milestone-v1-5`.

### C-2026-07-08-gsd-execute-phase-28-face-shape-slice-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Ran `$gsd-execute-phase 28` for Face Shape Slice Completion and Documentation Closeout. Completed per-tool face-shape renderer cases/helper evidence, focused safety/degradation/redaction tests, command-backed evidence capture, scoped ledger promotion, final verification, root docs, and planning ledgers. |
| Requirements | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03 |
| Files | `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`, `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift`, `CombinedEffectSafetyTests.swift`, `GeometryConflictResolverTests.swift`, `BeautyEffectResolverTests.swift`, `MissingLandmarkDegradationTests.swift`, `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py`, `28-FACE-SHAPE-RENDERER-EVIDENCE.md`, `28-VERIFICATION.md`, `28-VALIDATION.md`, `28-01-SUMMARY.md`, `28-02-SUMMARY.md`, `28-03-SUMMARY.md`, blueprint docs, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | Focused SDK tests passed: `BeautyRendererOutputRegressionTests` 6 tests, `FaceShapeWarpProviderTests` 8 tests, `CombinedEffectSafetyTests` 5 tests, `GeometryConflictResolverTests` 7 tests, `BeautyEffectResolverTests` 10 tests, and `MissingLandmarkDegradationTests` 14 tests. Full `swift test --package-path BeautySDK` passed with 171 tests. `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` wrote 102 ignored PNG outputs. `check_face_shape_renderer_outputs.py` passed with 102/102 outputs and 30/30 top-region comparisons. Representative `git check-ignore`, public/import boundary scans, hidden public-surface scans, evidence redaction scans, no-overclaim scans, ledger guards, Demo internal-import scan, GSD decision coverage, and scoped `git diff --check` passed. |
| Build | SDK SwiftPM tests and `BeautyExampleRenderer` build/run passed. No Demo build/test was run because Phase 28 changed no Demo source/UI behavior; Demo boundary was covered by static import scans. |
| Commit | Task commits include `4cb9eed`, `2b0bc95`, `c74970c`, `16a2822`, `eb2a419`, `a54d471`, `841ef5a`, `d4c6391`, `685b73e`, `161370f`, and `7d6d1c9`. Post-closeout metadata/review commits: `e707d42`, `9b1562c`, and `b7a7995`; this ledger update records the final commit list. |

Outcome:

- FACE-01 through FACE-05 are complete through existing public parameters `faceSlim`, `faceSmall`, signed `chinLength`, `faceVShape`, and `jawSlim`.
- FACE-06 is complete as a documented `jawSlim` alias for `下颌线`; no separate parameter, renderer case, Demo behavior, commercial gate, or algorithm split was added.
- `SHAPE_FEATURE_LEDGER.md` marks exactly `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线` as implemented.
- `FEATURE_MATRIX.md` keeps branch-level `脸型` partial; unscoped `脸型` rows and broader `美型 / 五官` branches remain future or partial according to their existing evidence.
- Phase 28 records no Demo UI completion, device parity, commercial visual review, broad reference-app parity, new geometry group, launch-readiness, generated PNG baseline, public raw geometry API, or whole-branch `脸型` completion claim.

Next step: run the v1.5 milestone audit/closeout flow.

### C-2026-07-08-gsd-plan-phase-28-face-shape-slice-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-08 |
| Scope | Created Phase 28 executable plans for Face Shape Slice Completion and Documentation Closeout from Phase 28 context, research, validation strategy, and pattern map artifacts. |
| Requirements | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/28-RESEARCH.md`, `28-VALIDATION.md`, `28-PATTERNS.md`, `28-01-PLAN.md`, `28-02-PLAN.md`, `28-03-PLAN.md`, `28-04-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 28` reported Phase 28 pending with `has_context: true`, `has_research: false`, `has_plans: false`, `phase_req_ids: FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03`, `research_enabled: true`, `plan_checker_enabled: true`, `nyquist_validation_enabled: true`, and `commit_docs: true`. User selected research-first. Researcher created `28-RESEARCH.md` and commit `f3dee08`. Validation strategy commit `6df5e40` created `28-VALIDATION.md`; pattern map commit `0f3b640` created `28-PATTERNS.md`; planner created four plan files in commit `80f0705`. Checker pass 1 found unresolved research questions, a false-positive bare `pro` scan, and a stale validation map; commit `a628981` fixed them. Checker pass 2 found shell command-substitution risk in `28-04`; commit `0e3e513` fixed it. Checker pass 3 found missing watermark-only false-positive mitigation in `28-02`/`28-04`; commit `9d1ec34` fixed it. Final plan-checker returned `VERIFICATION PASSED` for 4 plans. `phase-plan-index 28` reports waves 1-3 with `28-01` and `28-02` parallel in Wave 1, `28-03 -> 28-01/28-02`, and `28-04 -> 28-03`. `check.decision-coverage-plan` passed with `15/15` decisions covered. Requirement scan confirmed all nine Phase 28 FACE/DOC IDs are covered. Post-planning gap analysis showed all Phase 28 FACE/DOC IDs and D-01 through D-15 covered; uncovered GEO-01 through GEO-04 rows belong to prior v1.5 phases, not Phase 28 scope. Scoped `git diff --check` passed for Phase 28 planning artifacts, `.planning/STATE.md`, and this ledger. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Phase 28 execution plans require focused SDK tests, full `swift test --package-path BeautySDK`, `BeautyExampleRenderer` build/run, Phase 28 helper checks, ignored-output checks, raw-leak scans, no-overclaim scans, ledger guards, and GSD decision coverage. |
| Commit | Planning commits: `f3dee08`, `6df5e40`, `0f3b640`, `80f0705`, `a628981`, `0e3e513`, `9d1ec34`; final state/ledger commit records this entry. |

Outcome:

- `28-01-PLAN.md` adds per-tool public-facade renderer cases for `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, positive `chinLength`, and negative `chinLength`, plus a Phase 28 top-region helper.
- `28-02-PLAN.md` closes focused safety/degradation/redaction evidence for caps, no-face/missing contour, signed `chinLength`, combined weakening, and raw-geometry leak prevention.
- `28-03-PLAN.md` records command-backed renderer/helper/test evidence before any status promotion.
- `28-04-PLAN.md` promotes only the six scoped `脸型` rows after evidence passes, keeps branch-level `脸型` partial, and synchronizes blueprint/root/planning ledgers without Demo UI, public API, parity, commercial quality, device parity, or release-readiness claims.
- Phase 28 is ready for `$gsd-execute-phase 28`.

### C-2026-07-07-gsd-discuss-phase-28-face-shape-slice-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-07-07 |
| Scope | Ran `$gsd-progress --next`, which passed safety gates after Phase 27 completion and routed to `$gsd-discuss-phase 28` for Face Shape Slice Completion and Documentation Closeout. Captured decisions for `下颌线` alias handling, per-tool renderer/test evidence, and scoped status/document closeout. |
| Requirements | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-01, DOC-02, DOC-03 |
| Files | `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md`, `.planning/milestones/v1.5-phases/28-face-shape-slice-completion-and-documentation-closeout/28-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `$gsd-progress --next` found no unresolved `.planning/.continue-here.md`, no error/failed state, no unresolved Phase 27 verification failures, and no Phase 26/27 plans without summaries. `init.phase-op 28` reported Phase 28 exists in the roadmap with no context, research, plans, verification, or phase directory. `todo.match-phase 28` returned zero matches. Prior context from Phases 27, 26, and 25 plus root contracts, blueprint docs, and relevant renderer/face-shape code/tests were read. User selected all three gray areas and chose the recommended option for each detailed question. Scoped `git diff --check` passed for Phase 28 context/log, `.planning/STATE.md`, and this ledger. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 28 planning should include per-parameter renderer cases, geometry-vs-baseline helper evidence, focused SDK tests for safety/degradation/redaction, full SDK tests where local tooling allows, and scoped ledger/doc synchronization after evidence exists. |
| Commit | Included in the Phase 28 context/session ledger commits. |

Outcome:

- `下颌线` is locked as an alias-backed `jawSlim` behavior for v1.5; Phase 28 must not add a separate public parameter, Demo behavior, entitlement/pro path, or distinct algorithm.
- Phase 28 evidence should include one renderer case per distinct face-shape SDK parameter: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and both positive and negative `chinLength`; `下颌线` shares `jawSlim`.
- Each renderer case must preserve dimensions and show a geometry-vs-`geometryBaseline_noop` delta above the watermark band on usable portrait fixtures.
- Focused XCTest/scans should cover caps, missing contour/no-face degradation, signed `chinLength`, combined weakening, redaction, and raw-geometry leak prevention.
- If evidence passes, promote only `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`; keep branch-level `脸型` as `partial` and avoid UI, commercial quality, device parity, broad Meitu parity, new geometry group, or release-readiness claims.

Next step: `$gsd-plan-phase 28`.

### C-2026-07-07-gsd-execute-phase-27-geometry-render-output-harness

| Field | Value |
| --- | --- |
| Completed | 2026-07-07 |
| Scope | Ran `$gsd-execute-phase 27` for Geometry Render Output and Verification Harness. Completed four dependent waves: real still-image Vision input seam, selected-face still-image geometry output routing, renderer matrix/helper/no-face fixture, and final evidence plus root/planning ledger synchronization. |
| Requirements | GEO-03, GEO-04 |
| Files | `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautyEngineGeometryDetection.swift`, `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`, `BeautyGeometryEffectPipeline.swift`, `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, focused SDK tests, `example-images/input/no-face-gradient.png`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py`, `27-GEOMETRY-RENDERER-EVIDENCE.md`, `27-VERIFICATION.md`, `27-VALIDATION.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md` |
| Verification | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` passed with 8 tests; `BeautyRendererOutputRegressionTests` passed with 4 tests; focused missing-landmark, no-face/stale/reused, combined-strength, and face-shape conflict-cap tests each passed; full `swift test --package-path BeautySDK` passed with 167 tests. `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed. `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` wrote 66 ignored PNG outputs. `check_geometry_renderer_outputs.py` passed with 66/66 outputs, same dimensions, 5/5 portrait geometry-vs-baseline top-region comparisons, and no-face output presence. Public/SPI raw geometry export scans, active-source redaction scans, renderer public-import scans, renderer scope scans, Demo internal-import scans, evidence raw-leak scans, overclaim scans, face-shape ledger guard, GSD decision coverage, and scoped `git diff --check` passed. |
| Build | SDK SwiftPM tests and `BeautyExampleRenderer` build/run passed. No Demo build/test was run because Phase 27 changed no Demo source/UI behavior; Demo boundary was covered by static import scans. |
| Commit | Task commits include `2355587`, `cd21ba3`, `5ae3bbe`, `3a3e0fd`, `21639fd`, `761283d`, `14ec1f5`, `160702a`, `acbf066`, and `3d8f9e2`; final docs/ledger synchronization and review/fix are committed with this entry. |

Outcome:

- GEO-03 is complete: `BeautyExampleRenderer` now emits `geometryBaseline_noop` and `faceShapeCombo_0p35`, and the helper verifies same-dimension saved-output geometry evidence without hashes or committed PNG baselines.
- GEO-04 is complete: no-face saved-output evidence plus missing-landmark, stale/reused, combined-strength, and face-shape conflict-cap tests pass with redacted summaries and aggregate metrics.
- Phase 27 remains SDK-only: no Demo UI work, no public raw geometry API, no eye/nose/mouth/lip saved-output expansion, no generated PNG baselines, no quality/parity/launch claims, and no `SHAPE_FEATURE_LEDGER.md` implemented-status promotion.
- Phase 28 is the next owner for per-tool `脸型` completion, `下颌线` alias handling, and status ledger promotion.

Next step: `$gsd-discuss-phase 28`.

### C-2026-07-07-gsd-plan-phase-27-geometry-render-output-harness

| Field | Value |
| --- | --- |
| Completed | 2026-07-07 |
| Scope | Created Phase 27 executable plans for Geometry Render Output and Verification Harness from existing Phase 27 context, research, validation, and pattern-map artifacts. |
| Requirements | GEO-03, GEO-04 |
| Files | `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-01-PLAN.md`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-02-PLAN.md`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-03-PLAN.md`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-04-PLAN.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `init.plan-phase 27` reported Phase 27 pending with context present, no research, no plans, `phase_req_ids: GEO-03, GEO-04`, `research_enabled: true`, `plan_checker_enabled: true`, `nyquist_validation_enabled: true`, and `commit_docs: true`. User selected research-first. Researcher created `27-RESEARCH.md` and commit `b1f2596`. Validation strategy commit `f3aa8e4` created `27-VALIDATION.md`. Pattern mapper created `27-PATTERNS.md` and commit `de2928e`. Planner created four plan files in commit `5e12547`. The `gsd-plan-checker` subagent was spawned but did not return after the wait windows and was closed; inline checker pass found invalid negative scan semantics in `27-03` and `27-04`, fixed in commit `70084fa`. `phase-plan-index 27` reports four plans across waves 1-4 with dependencies `27-02 -> 27-01`, `27-03 -> 27-02`, and `27-04 -> 27-03`. `check.decision-coverage-plan` passed with 17/17 Phase 27 decisions covered. Requirement scan confirmed GEO-03 and GEO-04 appear in all four plan files. Threat-model, Artifacts, read-first, and acceptance-criteria scans passed across all four plans. Post-planning gap analysis showed GEO-03/GEO-04 and D-01 through D-17 covered; uncovered DOC/FACE/GEO-01/GEO-02 rows belong to other v1.5 phases, not Phase 27 scope. Scoped `git diff --check` passed for Phase 27 planning artifacts, `.planning/STATE.md`, and this ledger. |
| Build | Not run; this was a GSD planning/documentation workflow with no Swift source changes. Phase 27 execution plans require focused SDK tests, full `swift test --package-path BeautySDK`, renderer build/run, Phase 27 helper checks, ignored-output checks, raw-leak scans, no-overclaim scans, and ledger-status guards. |
| Commit | Planning commits: `b1f2596`, `f3aa8e4`, `de2928e`, `5e12547`, `70084fa`; final state/ledger commit records planning completion. |

Outcome:

- `27-01-PLAN.md` creates the real still-image detection input seam and public-facade fixture probe.
- `27-02-PLAN.md` carries selected-face geometry into the internal still-image render path and proves pre-watermark geometry output differs from a no-geometry baseline.
- `27-03-PLAN.md` appends the renderer baseline and combined face-shape case, adds a dedicated no-face input fixture, and creates the Phase 27 geometry output helper.
- `27-04-PLAN.md` records final renderer/degradation evidence and synchronizes root docs and planning ledgers without promoting Phase 28 `脸型` status.
- Phase 27 remains SDK-only: no Demo UI work, no public raw geometry API, no committed generated PNG baselines, no quality/parity/release claims, and no `SHAPE_FEATURE_LEDGER.md` `implemented` promotion.

Next step: `$gsd-execute-phase 27`.

### C-2026-07-07-gsd-discuss-phase-27-geometry-output-harness

| Field | Value |
| --- | --- |
| Completed | 2026-07-07 |
| Scope | Ran `$gsd-progress --next`, which passed safety gates after Phase 26 completion and routed to `$gsd-discuss-phase 27` for Geometry Render Output and Verification Harness. Captured user decisions for renderer-first geometry saved-output evidence, face-shape-first scope, mechanical evidence bar, degradation evidence split, and no-overclaim/privacy boundaries before planning. |
| Requirements | GEO-03, GEO-04 |
| Files | `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md`, `.planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-DISCUSSION-LOG.md`, `.planning/STATE.md`, `PLANS.md` |
| Verification | `$gsd-progress --next` found no unresolved `.planning/.continue-here.md`, no error/failed state, no unresolved Phase 26 verification failures, and no prior plans without summaries. `init.phase-op 27` reported Phase 27 exists in the roadmap with no context, research, plans, verification, or phase directory. `todo.match-phase 27` returned zero matches. Prior contexts from Phases 26, 25, and 24 plus root contracts and relevant renderer/geometry code were read. User selected all four gray areas, then selected the recommended option for each detailed question and selected finish context. The temporary `27-DISCUSS-CHECKPOINT.json` parsed successfully while in use and was removed after canonical context/log creation. `state.record-session --stopped-at "Phase 27 context gathered" --resume-file ".planning/milestones/v1.5-phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md"` reported `recorded: true`; `state.update "Status" "Ready for Phase 27 planning"` reported `updated: true`. |
| Build | Not run; this was a GSD discussion/context workflow with no Swift source changes. Phase 27 planning should include renderer/helper tests, real-facade `BeautyExampleRenderer` build/run evidence, geometry-output helper checks, focused degradation/redaction tests, no-overclaim scans, and full SDK tests where local tooling allows. |
| Commit | Included in the Phase 27 context/session ledger commits. |

Outcome:

- Phase 27 should use a renderer-first hybrid: append geometry cases to `BeautyExampleRenderer`, back them with focused tests/helper checks, and add a narrow fallback verifier only if real-facade fixture detection cannot cover a required degradation case.
- Saved-output scope is face-shape first with one combined moderate-strength case for existing `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`; Phase 28 still owns per-tool `脸型` evidence and ledger promotion.
- A saved-output pass means same dimensions, non-identical geometry output against a no-geometry baseline, redacted geometry metrics, ignored generated PNGs under `example-images/out/`, and representative factual notes only.
- GEO-04 evidence must cover no-face, missing-landmark, stale/reused, and combined-strength paths; renderer PNGs are required for happy path and no-face, while the remaining paths may use focused XCTest plus helper/evidence Markdown summaries.
- Phase 27 must not add Demo UI work, public raw geometry APIs, committed PNG baselines, subjective quality claims, commercial/release readiness claims, full Meitu parity claims, or `SHAPE_FEATURE_LEDGER.md` implementation-status promotion.
