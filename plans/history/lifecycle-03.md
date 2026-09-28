# Historical lifecycle records 03

### C-2026-08-14-phase-69-public-concurrency-repair-and-sdk-only-closeout

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-15 |
| Scope | Repair the public generic result concurrency contract and record the SDK-only v1.16 closeout without adding Metal/GPU, UI/Demo, device, performance, commercial, packaging, shipping, launch, or release-readiness scope. |
| Plans | 69-01 conditional `BeautyResult` sendability; 69-02 mutation-tested boundary and archive-first no-skip ordering; 69-03 current owner synchronization; 69-04 aggregate ledger/state closeout. |
| Contract | `BeautyResult<Output>` is conditionally `Sendable` only when `Output: Sendable`; public compile/runtime coverage preserves all result fields and existing ordinary source use, while the boundary self-test rejects the historical unconditional generic declaration. |
| Focused evidence | Public concurrency suite passes 3 tests; archive verification, boundary self-test/live scan, public consumer, generated CPU oracle, and `git diff --check` pass. |
| Final aggregate | `bash scripts/run-no-skip-swiftpm.sh` passes archive → boundary self-test/live → consumer → generated CPU oracle → all eight optional fixtures → one SwiftPM child with 702 executed tests, zero failures, and zero skips. |
| Inventory | Active tree: 66 Swift source files / 14,952 source lines and 61 SwiftPM test files / 29,995 test lines. |
| Requirements | CONC-01, CONC-02, CLOSE-01, and CLOSE-02 are marked complete against the focused/static/full evidence. |
| Nonclaims | CPU/Core Image remains the current reference. v1.17 Metal/GPU backend work remains queued; no UI/Demo, simulator/device, performance, commercial, packaging, shipping, launch, or release-readiness claim follows. |
| Lifecycle | Independent verification passed 4/4 and the canonical lifecycle completion command completed on 2026-08-15. |

### C-2026-08-14-phase-68-cpu-algorithm-reference-oracles

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-14 |
| Scope | Freeze the current CPU/Core Image behavior through generated in-memory Swift RGBA8/sRGB fixtures, semantic geometry/color metrics, local-retouch safety/composition oracles, deterministic recovery, and a generated-only preflight. |
| Plans | 68-01 fixture/metric foundations; 68-02 geometry/color semantics; 68-03 local-retouch safety and determinism; 68-04 preflight/owner closeout. |
| CPU requirements | CPU-01..CPU-05 are covered by generated fixture contracts, exact neutral/alpha/extent checks, feature-family metrics, collision/source ownership, sibling isolation, recovery, and optional-fixture separation. |
| Focused aggregate | Generated preflight passes fixture/facade `15`, geometry/color `10`, and local-retouch/determinism `16` tests with zero generated skips. |
| Final aggregate | `bash scripts/run-no-skip-swiftpm.sh` passes archive verification, SDK-only boundary, public consumer, generated CPU preflight, all eight opt-ins, and one SwiftPM child with `699` executed tests, zero failures, zero skips, and a nonzero denominator. |
| Documentation | ARCHITECTURE, SECURITY, RELIABILITY, QUALITY_SCORE, `.planning/codebase/TESTING.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` synchronize the generated-only CPU reference boundary and measured inventory. |
| Nonclaims | No production algorithm, public backend, Metal/GPU, UI/Demo, device, performance, tracked portrait media, raw fixture evidence, packaging, shipping, launch, or release-readiness claim is made. |

### C-2026-08-14-phase-67-swiftpm-consumer-and-cli-validation-contract

| Field | Value |
| --- | --- |
| Status | `completed` |
| Completed | 2026-08-14 |
| Scope | Synchronized current owners/maps and closed the public-only SwiftPM consumer plus deterministic CPU CLI validation contract. |
| Contract | The external local-path consumer imports only public `BeautySDK`, generates a neutral RGBA input, and asserts real public-facade bytes/dimensions. `BeautyExampleRenderer` preserves 61 public fields, five neutral presets, the retained shader digest, CPU/Core Image behavior, and the exact 74-case catalog; it requires an existing output directory, accepts only `--backend cpu`, and writes versioned privacy-safe JSON after persisted PNG reopen/dimension validation. |
| Evidence | SPM-01/SPM-02: clean consumer checker and generated neutral output pass. CLI-01/CLI-02: 24/24 renderer regression and deterministic report/output/failure behavior pass. CLI-03: compiled Foundation `Process` matrix passes 7/7, including invalid matrix, collision, artifact replacement, control-character escaping, and independent render/encode failures. |
| Focused commands | `python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui`; `bash scripts/check-sdk-only-boundary.sh --post-archive`; `bash scripts/check-swiftpm-consumer.sh`; `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests`; `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyExampleRendererProcessTests`. |
| Final aggregate | `bash scripts/run-no-skip-swiftpm.sh` passed archive verification, post-archive boundary, consumer preflight, all eight opt-ins, one SwiftPM child with 658 executed tests, zero failures, zero skips, and a nonzero denominator. |
| Documentation | ARCHITECTURE, SECURITY, RELIABILITY, PRODUCT_SENSE, QUALITY_SCORE, `.planning/PROJECT.md`, and current codebase maps now describe public-only consumer ownership, typed failures, bounded temporary outputs, and archive → boundary → consumer → no-skip ordering. |
| Nonclaims | No public backend selector, GPU/Metal execution, UI/Demo, simulator/device, private-fixture product evidence, performance approval, commercial approval, packaging, shipping, launch, or release-readiness claim is made. Raw child output, paths, environment values, pixels, masks, and fixture metadata remain non-durable. |

### C-2026-08-13-sdk-first-two-milestone-plan

| Field | Value |
| --- | --- |
| Completed | 2026-08-13 |
| Scope | Split the remaining repository/pipeline work into two ordered SDK-only milestones instead of mixing cleanup, API repair, CPU baselining, and Metal implementation in one cycle. |
| v1.16 | `SDK-Only Foundation and CPU Reference`, planned as Phases 66-69: verified legacy UI/Demo ZIP archival and source removal; SwiftPM-only consumer/CLI validation; deterministic CPU algorithm/output oracles; conditional `BeautyResult` sendability; SDK-only debt closeout. Metal source, GPU API, simulator, UI, and device work are excluded. |
| v1.17 | `Dual CPU/GPU Metal Rendering`, queued as Phases 70-74: internal backend-neutral render contract and bounded Metal runtime; Metal color/skin passes; control-point geometry warp; request-local local-retouch composition; public backend selection and parity closeout. |
| Backend decision | Preserve the CPU implementation permanently as the reference backend. Add `BeautyConfiguration.renderBackend: BeautyRenderBackend` only after GPU coverage is complete, with `.cpu` and `.gpu`; default and legacy decode use `.cpu`. Explicit `.gpu` selection fails with `.metalUnavailable` when unavailable and never silently falls back. The execution choice does not enter `BeautyParameters` or preset JSON. |
| Shared semantics | CPU and GPU consume the same validated parameters, resolver plan, observed support, control points, request-local masks, original-pixel ownership, hard containment, failure isolation, and collision-to-source rules. Vision/support discovery may remain CPU; the switch owns rendering/composition execution. |
| Verification plan | v1.16 uses only SwiftPM, `scripts/run-no-skip-swiftpm.sh`, an SDK-only consumer fixture, and `BeautyExampleRenderer` structured input/output reports. v1.17 runs the same cases through both backends; exact gates own no-op/alpha/extent/outside-region/containment/collision/failure behavior, with explicit affected-pixel tolerances plus direction/locality/monotonicity gates for floating-point Metal output. No Xcode Demo, simulator, UI automation, or physical-device gate is required. |
| Deferred | `去脂`, hairline/semantic masking, double-chin, new models, commercial visual approval, packaging, shipping, and launch readiness remain separate future milestones. CPU/GPU infrastructure cannot promote proxy algorithms. |
| Records | `.planning/ROADMAP.md`, `.planning/PROJECT.md`, and `.planning/STATE.md` record the queued sequence. Neither milestone is active until v1.16 is initialized through the milestone workflow. |

### C-2026-08-13-document-state-drift-repair

| Field | Value |
| --- | --- |
| Completed | 2026-08-13 |
| Scope | Repaired documentation and planning-state drift against the live post-v1.15 repository without changing SDK or Demo behavior. |
| Maps | Regenerated all seven `.planning/codebase/*` maps from current source and tests: 1,162 lines covering stack, architecture, structure, conventions, testing, integrations, and concerns. TD-011 is closed. |
| Current state | Root owners, `.planning/PROJECT.md`, `.planning/STATE.md`, quality scorecards, feature matrices, module/feature READMEs, and the example-image validation inventory now agree on 61 public fields, five presets, 74 renderer cases, 650-test current no-skip evidence, bounded SDK-core teeth/sclera implementation, completed mouth, and eyes partial solely because `去脂` remains future. Historical phase snapshots are explicitly time-bounded. |
| Path repair | Repointed active documentation commands and evidence references from archived, nonexistent numbered `.planning/phases/*` locations to their real `.planning/milestones/v1.x-phases/*` locations. Remaining numbered `.planning/phases/*` mentions outside archives are historical lifecycle prose only. |
| Verification | `scripts/run-no-skip-swiftpm.sh` passed 650/650 with all eight opt-ins executed, zero skips, and zero failures. Renderer source and `Current Built-In Cases` both contain exactly 74 IDs. All seven maps are non-empty and total 1,162 lines. Every newly referenced archived phase directory exists. Current-claim and dead-active-phase scans found no unresolved current drift; secret-pattern scan and `git diff --check` passed. |
| Boundary | Documentation and planning-state accuracy only; no SDK, Demo, archived milestone, tag, distribution, shipping, launch, commercial, or release-readiness behavior changed. |

### C-2026-08-11-v1-15-review-remediation

| Field | Value |
| --- | --- |
| Completed | 2026-08-11 |
| Scope | Remediated all five findings from the fresh `v1.14..v1.15` review without moving or reinterpreting the archived `v1.15` tag. |
| Production | Malformed observed-eye support now fails per eye while valid peers and lips continue. Teeth ownership is fixed-inner-aperture only, adaptive outer-lip growth is removed, source luminance `>= 0.90` is an exact no-op, and concave/boundary-crossing polygon relationships fail closed. |
| Fixture evidence | Shared reviewed-mask validation rejects non-finite, translated, wrong-size, and non-up-orientation masks before output rendering or measurement in both private real-fixture suites. |
| Verification | Focused mapping/provider/adversarial/mask tests pass 45/45; broader combined/integration/renderer/private-host tests pass 59/59 with two expected private opt-in skips; full SwiftPM passes 641/641 with eight documented opt-in skips and zero failures; `git diff --check` and fresh post-fix review pass. |
| Contracts | `DESIGN.md`, `PRODUCT_SENSE.md`, `SECURITY.md`, `RELIABILITY.md`, `QUALITY_SCORE.md`, and the teeth-whitening spike reference record the narrowed fixed-only claim and new fail-closed boundaries. |
| Historical boundary | The archived Phase 60 adaptive-growth checker is historical after this safety correction. The `v1.15` tag and milestone archive remain unchanged; no Demo, realtime, release, shipping, or commercial scope is added. |

### C-2026-08-11-v1-15-milestone-archive

| Field | Value |
| --- | --- |
| Completed | 2026-08-11 |
| Scope | Archived the passed v1.15 roadmap, 40/40 requirements, formal audit and all Phase 59-65 execution artifacts after closing both audit debts. |
| Inventory | 7 phases, 51 plans and 97 task IDs; 40/40 requirements, 12/12 integration seams and 7/7 flows. |
| Records | `.planning/milestones/v1.15-ROADMAP.md`, `v1.15-REQUIREMENTS.md`, `v1.15-MILESTONE-AUDIT.md`, `v1.15-PHASE65-BOUND-AUDIT.md`, and `v1.15-phases/`. |
| Boundary | Internal SDK milestone lifecycle only. Archive/tag state does not claim product distribution, shipping, launch, commercial approval or release readiness. |

### C-2026-08-11-v1-15-audit-tech-debt-remediation

| Field | Value |
| --- | --- |
| Completed | 2026-08-11 |
| Scope | Closed both nonblocking findings from the formal v1.15 milestone audit without changing product behavior or requirement scope. |
| Phase 64 checker | Added `--post-downstream`: exact canonical Phase 64 fields, SHA-256-bound chronological Phase 65 verification, and the current Phase 65 final gate replace the inapplicable candidate-era source/owner equality for downstream revalidation. The immutable terminal candidate contract remains unchanged. |
| Lifecycle ledger | Active now contains only the current Phase 65 owner disposition. Completed and superseded Phase 64 records are explicitly labeled under Historical Lifecycle Ledger with `H-*` identifiers and no stale current-authority wording. |
| Verification | Python compile; Phase 64 self-test including 6/6 downstream-binding and 8/8 strict child-payload mutations; aggregate `--post-downstream`; isolated T-64-01 through T-64-08; Phase 65 final; diff hygiene. |
| Boundary | Documentation/checker lifecycle maintenance only. No SDK/Demo behavior, public API, product promotion, archive, tag, cleanup, shipping, launch or release-readiness action/claim. |

### C-2026-08-11-v1-15-fully-automated-phase65-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-11 |
| Scope | Closed the five user-specified contracts with deterministic code/image gates and a fresh authority chain. |
| Implementation | `BeautyExampleRenderer` now renders and encodes named sRGB instead of DeviceRGB; presentation-free and watermarked paths preserve the CGImage color space. Teeth and sclera strict PNG decoders reject output without an explicit `sRGB` declaration. |
| Automated evidence | Renderer 23/23; actual PNG profile `sRGB IEC61966-2.1`, no EXIF orientation, unchanged dimensions and opaque output; teeth helper 20/20 plus 6/6; sclera helper 15/15 plus 6/6; Phase 65 checker 34/34 and final mode; SwiftPM 638/0/0 with all eight opt-ins; Demo 121/0/0. |
| Contracts | Combined bytes/collision/four failure units, request recovery, production privacy, 61/5/74/3 compatibility and product boundaries pass. The bound milestone audit passes 40/40 requirements, 7/7 phases, 12/12 seams and 7/7 flows. |
| Product | Bounded SDK-core opaque still-image `白牙` and `祛红血丝` are implemented; `嘴唇` is implemented; `眼睛` remains partial solely because `去脂` remains future; all three Demo rows remain disabled and nil-mapped. |
| Boundary | Completion-ready only. No Demo activation, realtime/pixel-buffer, model/network, population/device/performance/commercial, packaging, shipping, launch, archive, tag or release-readiness claim/action. |
| Preserve | The pre-existing uncommitted Phase 65 review and review-fix reports were preserved and not overwritten. |

### C-2026-08-08-v1-15-phase-63-verification-refresh

| Field | Value |
| --- | --- |
| Completed | 2026-08-08 |
| Scope | Refreshed Phase 63 canonical verification after its final summary had a newer filesystem timestamp than the already-passed report. No implementation plan or production behavior was re-executed or changed. |
| Human gate | Conversational UAT passed 8/8, including confirmation that the pre-frozen per-eye guard, reclip and immutable-source contracts were not weakened. |
| Fresh evidence | Standard 10-file review clean; focused provider/integration/mapping 44/44; required private native-Vision pair passed; full current SwiftPM 630/0/8; `git diff --check` passed. |
| Threat transition | T-63-01 through T-63-07 remain green. Historical T-63-08 now observes Phase 64's authorized renderer/promotion; the Phase 64 post-promotion and Phase 65 final checkers pass, so this is not a regression or override. |
| Result | `63-VERIFICATION.md` is fresh against `63-04-SUMMARY.md` and remains `status: passed` with all 11/11 must-haves and five requirements verified. |

### C-2026-08-08-v1-15-combined-audited-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-08 |
| Scope | Closed Phase 65 and audited v1.15 after independently completing teeth, then sclera, then their combined public still-image facade behavior. |
| Integration | Combined output matches an independent standalone merge; collisions preserve source; teeth, whole-sclera, left-eye and right-eye failure retain unaffected work; lifecycle recovery reuses no prior state. |
| Verification | Combined 13/13; focused 94/94; private output 6/6 per feature; two private native-Vision suites; opt-in suites 95/95; full SwiftPM 630/0/8; Demo build and 121/0/0; HIGH 8/8. |
| Audit | 40/40 requirements, 7/7 phases, 12/12 cross-phase seams and 7/7 end-to-end flows pass with no blocker, orphan or open HIGH. |
| Product | Exact 61/5/74/3 compatibility; `白牙` and `祛红血丝` implemented; `嘴唇` implemented; `眼睛` partial solely because `去脂` is future. |
| Boundary | The milestone is completion-ready but is not archived, tagged, cleaned up, shipped or release-ready. |

### C-2026-08-08-v1-15-phase-64-sclera-output-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-08 |
| Scope | Closed the bounded still-image SDK-core sclera slice through one exact public renderer case, strict decoded saved output, adversarial protected-anatomy safety, fresh original-detail review, exact product promotion and separate post-promotion verification. |
| Product delta | Promoted only `眼睛 | 祛红血丝` to `implemented`. Aggregate `眼睛` remains `partial` solely because `去脂` is future; all three local-retouch Demo rows remain disabled with nil mappings. |
| Evidence | Required positive/negative/no-face baseline/active matrix 6/6; renderer 21/21; helper 14/14; adversarial/provider/facade 5/11/9; actual Vision private pair; four-item visual review; checker 8/8 mutations and all eight isolated HIGH modes pass. |
| Verification | Post-promotion full SwiftPM 617/0/8; explicit iPhone 17e / iOS 26.5 Demo build and 121/0/0 tests; tracked/staged privacy scans 1,424 files; exact 61 fields, five presets and 74 renderer cases; syntax, JSON and diff gates pass. |
| Requirements | SCLERA-14 through SCLERA-18 and OUT-05 verified. Phase 65 may start combined teeth+sclera closeout but may not borrow either standalone feature's evidence or relax its guards. |
| Boundary | No population sufficiency, realtime/pixel-buffer, target-device quality/performance, commercial approval, Demo activation, external model/network, packaging, shipping, launch or release readiness is claimed. |
| Re-verification | Superseded on 2026-08-08: fresh canonical verification is `gaps_found` at 3/6. SCLERA-14/15 and therefore SCLERA-18/product promotion remain open until a complete bilateral adversarial oracle and independent rerun pass. |

### C-2026-08-07-v1-15-phase-63-sclera-provider-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-07 |
| Scope | Implemented the package-only stateless zero-to-two-unit sclera provider, actual current per-eye ownership, pre-score hard guard, bounded immutable-source redness transform and one-request Engine integration without activating Demo, realtime, model or network surfaces. |
| Safety | Finite simple contour and actual pupil validation, 12% contour erosion, conservative circular pupil/iris exclusion, expanded highlight/lash guards, score-inside-only, radius-one hard reclip, Q16-once composition, collision-to-source and affected-eye-only abstention are enforced. |
| Evidence | The final authorized positive/negative native-Vision gate passes with zero reviewed-mask escape. Provider/integration 20/20, checker mutations 8/8, live 8/8 and all eight isolated HIGH modes pass. |
| Verification | Full SwiftPM 612/0/8; explicit iPhone 17e / iOS 26.5 Demo build and 121/0/0 tests; decisions 16/16, requirements 5/5, tasks 8/8, threats 8/8, plans 4/4; tracked/staged privacy, syntax, JSON, inventory and diff gates pass. |
| Requirements | SCLERA-09 through SCLERA-13 verified. Phase 64 alone owns strict public output, adversarial final-output safety, new original-detail review and exact `祛红血丝` promotion. |
| Boundary | This is bounded provider integration, not final visible product acceptance, population sufficiency, realtime/device/performance readiness, commercial quality, packaging, shipping, launch or release readiness. `去脂` remains future. |

### C-2026-08-07-v1-15-phase-61-teeth-output-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-07 |
| Scope | Closed the bounded still-image SDK-core teeth slice through one exact public renderer case, strict decoded saved output, adversarial final-output safety, original-detail review, exact product promotion, and separate post-promotion verification. |
| Product delta | Promoted only `嘴唇 | 白牙` and aggregate branch `嘴唇` to `implemented`. `眼睛` remains `partial`; `祛红血丝` and `去脂` remain `future`; all three local-retouch Demo rows remain disabled with nil mappings. |
| Evidence | Required positive/negative/no-face baseline/active matrix passes 6/6; renderer 21/21, provider 12/12, integration 10/10, adversarial 6/6, helper 18/18, checker mutations 8/8, live post assertions 64, and all eight isolated HIGH modes pass. |
| Verification | Post-promotion full SwiftPM 587/0/7; explicit iPhone 17e / iOS 26.5 Demo build and 121/121 tests; Phase 60 retained checker 8 mutations/99 live; tracked/staged privacy 1,357 files; syntax, JSON, artifact, owner, and diff gates pass. |
| Requirements | TEETH-15 and TEETH-16 verified. Phase 62 may start independent sclera evidence/admission work but may not borrow teeth evidence or begin production sclera implementation before its own decision opens. |
| Boundary | No population sufficiency, realtime/pixel-buffer, target-device quality/performance, commercial approval, packaging, shipping, launch, release readiness, production sclera, or upper-eyelid result is claimed. |

### C-2026-08-07-v1-15-phase-60-teeth-provider-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-07 |
| Scope | Implemented the package-only stateless teeth selector, bounded immutable-source transform, and direct-intent still-image Engine integration without activating Demo, realtime, sibling, model, or network surfaces. |
| Safety | Complete actual mapped lips, simple/nested/plausible geometry, fixed `1.5%...94%` baseline, seed-connected growth, post-filter hard re-clip, protected-color no-ops, source-only targets, one Q16 mask owner, collision-to-source, and request-local recovery are enforced. |
| Evidence | The authorized genuine positive/negative pair passes fixed-output aggregate bounds. Provider 12/12, provider+composition 33/33, integration 10/10, focused facade/foundation/composition 49/49, and compatibility 59 tests with one existing opt-in skip pass. |
| Verification | Full SwiftPM 581/0/7; Demo build and 121/0/0 tests on iPhone 17e / iOS 26.5; checker 8/8 mutations, live 99, eight isolated HIGH modes; decisions 16/16; tracked/staged privacy, syntax, inventory, and diff hygiene passed. |
| Requirements | TEETH-09 through TEETH-14 verified. Phase 61 alone owns strict public output, adversarial final review, and exact `白牙` promotion; Phase 62 and production sclera remain blocked. |
| Boundary | This is a bounded provider result, not final product promotion, population sufficiency, realtime/device/performance readiness, commercial quality, packaging, shipping, launch, or release readiness. |

### C-2026-08-07-v1-15-phase-59-open-intent-closeout

| Field | Value |
| --- | --- |
| Completed | 2026-08-07 |
| Scope | Closed Phase 59 on the exact serializer-open teeth intent branch while preserving provider/output, sclera, `去脂`, Demo, realtime, model, and network absence. |
| Decision | The canonical teeth row is open at `2/2/2/0/2`; exactly one trailing default-zero normalized scalar and one opaque request-local demand are admitted. Sclera redness and upper-eyelid fullness remain independently closed. |
| Compatibility | Exact 60 stored/CodingKey/initializer fields, five byte-stable neutral presets, 72 renderer cases, and three disabled Demo rows with nil mappings. |
| Verification | Phase 54 33/33; private Phase 59 contract 9/9; mechanics self-test 24/24 as corroboration only; focused SDK 147/147; full SwiftPM 558/0/6; Demo build and 121/0/0 tests; checker 235/235; decisions 16/16; eight HIGH threats; tracked/staged privacy and diff hygiene passed. |
| Requirements | EVID-07 and TEETH-07/08 verified. SEQ-01 remains enforced by routing only to Phase 60 and blocking Phase 62/production sclera until Phase 61 closes teeth. |
| Boundary | This is intent admission, not visible whitening, provider safety, product promotion, population sufficiency, device/performance readiness, commercial quality, packaging, shipping, launch, or release readiness. |

### C-2026-08-05-local-retouch-candidate-image

| Field | Value |
| --- | --- |
| Completed | 2026-08-05 |
| Scope | Registered the user-supplied portrait as one local-only, AI-generated positive-target mechanics candidate for independent white-teeth and sclera-redness experiments. |
| Files | `example-images/local-retouch-review/candidates/portrait_002/original.png` (ignored local media), `example-images/FIXTURE_AUTHORIZATION.md` |
| Boundary | The candidate stays outside `example-images/input/`, does not alter the exact renderer fixture inventory, and does not enable `白牙` or `祛红血丝`. The shared original does not couple the feature decisions; each feature still requires its own mask, after image, manifest row, review, negative peer, and promotion result. |
| Verification | Original-detail intake inspection, `file`, `sips`, PNG chunk/provenance inspection, `git check-ignore`, `git diff --check`, and focused `BeautyRendererOutputRegressionTests` (21/21) passed. The retained local C2PA block declares `trainedAlgorithmicMedia`; production source and active renderer inputs were unchanged. |

Outcome:

- `portrait_002` is available at the ignored local review path for both `teeth_whitening` and `sclera_redness` mechanics work, with zero genuine-evidence weight.
- Existing active `p1`/negative fixture contracts and the closed v1.14 production boundary remain unchanged.

### C-2026-07-30-authorized-smile-fixture-replacement

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Permanently replaced the opaque local `portrait_001` pixels with the newly supplied smiling portrait, deleted the prior project-local `p1` copy instead of parking it, preserved the active `p1.jpg` path, re-sanitized image metadata, and updated the authorization, dimension, product, quality, and test contracts. Disabled `e1`–`e6` fixtures remain outside active discovery. |
| Local asset | `example-images/input/portraits/p1.jpg` is now a 2628×1778, 1,587,765-byte Display P3 JPEG. It remains local and Git-ignored. The source download remains user-owned and is not copied into tracked history. |
| Rights and privacy | Rights record `user_authorization_20260730_002` records the user's explicit copyright, portrait/likeness, derivative, long-term local-test, and no-planned-replacement authorization without naming the subject or source file. Re-encoding removed GPS, TIFF, orientation, capture/device, author/copyright, and screenshot/user-comment metadata. |
| SDK verification | Fixture/gallery self-tests pass with exactly `p1` plus `no-face-gradient` active and `e1`–`e6` rejected. `BeautyRendererOutputRegressionTests` passes 17/17; opt-in Vision/detection/facade/adapter coverage passes 95/95; full SwiftPM passes 458 tests with six documented opt-in skips. A public renderer smoke run writes only the p1 and no-face `geometryBaseline_noop` outputs, preserving 2628×1778 and 64×64 extents. |
| Local-retouch evidence | Apple Vision provides one usable face with inner/outer lips. Adaptive teeth support contains 13,709 strong pixels versus 9,320 for the fixed baseline with zero outside-mask changes. Guarded fused composition contains 16,639 mask pixels with zero outside, iris, or highlight changes and zero fused/sequential or fail-closed mismatches. Original-detail review found the whitening restrained and the overlay confined to visible teeth without obvious lip or gum spill. Sclera support is weak/asymmetric on this portrait (left rejected, right 640 pixels), so no redness-positive claim is made. |
| Boundary | The exposed smile makes this a durable rights-approved teeth-containment and over-whitening fixture. Its already-light teeth are not a yellow/dark-teeth positive; its eyes and eyelids are not established redness or upper-eyelid-fullness positives. Product feasibility still requires additional rights-approved feature-specific positives/negatives and human original-detail review. |

Outcome:

- Future local tests may keep using this exact opaque `p1.jpg` fixture without another authorization round unless its use expands beyond the recorded internal-evaluation scope.
- The prior project-local neutral portrait is gone and is not an alternate input or parked fallback.
- This replacement materially improves white-teeth containment review while leaving the v1.14 activation and population/calibration gates closed.

### C-2026-07-30-authorized-portrait-fixture-cutover

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Replaced the sole active local portrait fixture with the user-authorized real portrait supplied on 2026-07-30. Stored a metadata-sanitized copy as opaque `p1.jpg`; moved `e6.jpg` beside the already parked `e1`–`e5`; moved the prior 660 MB `e6` output/gallery snapshot outside active paths; updated active tests, gallery discovery, privacy/reliability/product/quality contracts, and a non-identifying authorization record. |
| Local assets | `example-images/input/portraits/p1.jpg` is a 2316×3088, 2,484,953-byte local/Git-ignored JPEG. `example-images/parked-portraits/` contains exactly `e1.png`–`e5.png` plus `e6.jpg`. Prior output/gallery trees are retained under `example-images/parked-generated/2026-07-30-e6/`. Binary assets are not committed. |
| Privacy | The supplied source contained precise GPS plus capture-time/device metadata. The active copy was re-encoded without GPS, TIFF device/time, author, copyright, or orientation fields. Tracked text contains no original download path, coordinates, subject name, or image hash. `example-images/FIXTURE_AUTHORIZATION.md` records only opaque fixture/right IDs, the user's permission statement, local-use scope, retention, and evidence limits. |
| Verification | Active discovery reports exactly `no-face-gradient` and `p1`; `e1`–`e6` rejection and symlink/size/publication self-tests pass; local-ignore, source-path/GPS-leak, metadata, inventory, and diff checks pass. `BeautyRendererOutputRegressionTests` passes 17/17; opt-in Vision/facade/adapter integration passes 95/95; the renamed local-authorized integration tests pass 3/3; full SwiftPM passes 458 tests with six documented opt-in skips; a public renderer smoke run writes only `p1__geometryBaseline_noop.png` and the no-face peer, preserving p1 at 2316×3088. |
| Boundary | Authorization permits future local testing and derivative review, but this single neutral/closed-mouth portrait is not automatically a teeth, sclera-redness, or upper-eyelid positive/negative. It does not establish population coverage, calibration, commercial naturalness, device performance, or v1.14 activation. Feature-specific before/mask/after review and additional positives/negatives remain required. |

Outcome:

- Future active SDK and gallery discovery uses only `p1.jpg`; all `e1`–`e6` portraits are disabled and retained only for historical reference outside `input/`.
- The user's broad permission is now durable as a privacy-minimized text contract while the actual portrait and derivatives remain local and ignored.
- The real portrait is proven usable by Apple Vision for face, contour, eye, pupil, lip, and eyebrow integration, but its neutral expression means it is primarily a general/negative fixture until feature-specific polarity is reviewed.

### C-2026-07-30-spike-013-wrap-up

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Appended completed Spike 013 to the project-local `spike-findings-beauty` implementation blueprint without changing production source, public API, feature inventory, milestone scope, or runtime behavior. |
| Outputs | Added exact 013 README/review sources; refreshed the exact shared Swift harness; updated the still-image integration recipe with one EXIF/color owner, explicit RGB rejection, transparent-input policy ownership, fixed-anchor sensitivity isolation, and bounded cross-profile acceptance; refreshed the skill trigger/index, processed inventory, and wrap-up summary. |
| Knowledge shape | The skill now covers thirteen processed spikes across the same five feature areas. All eight lossless EXIF orientations are exact after one canonical render, while equivalent color-profile and background variants require bounded detector/output stability rather than topology identity. Transparent input remains a product composite-or-reject decision. |
| Verification | Four owner/copy sources compare byte-for-byte; the copied Swift package builds in release and passes 23/23 self-tests; the retained Spike 006 review core passes 9/9; copied 013 review JavaScript parses; manifest, skill, and summary inventories are 13/13/13; all five references contain required blueprint sections; skill validation, AGENTS route count, runtime-network, generated-directory, media/model/binary, production-boundary, and diff-hygiene checks pass. |
| Boundary | No fixture media, aggregate run artifact, model/weight, build output, product code, public contract, realtime claim, device budget, licensed-evidence claim, transparent-input policy, HDR/gain-map support, or v1.14 activation was packaged. AI fixtures remain mechanics-only and licensed real review remains mandatory. |

Outcome:

- Future still-image local-retouch planning will auto-load the normalize-once contract and the fixed-anchor oracle that separates Vision drift from color-score/transform drift.
- Exact cross-profile mask topology is preserved as an invalidated acceptance assumption; product criteria must instead bound containment, landmark/output stability, and naturalness on rights-approved inputs.
- `CONVENTIONS.md` remains unchanged because canonical input normalization appears in only Spike 013. The existing AGENTS route remains the single project entry for the skill.

### C-2026-07-30-spike-013-normalized-input-local-retouch

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Added an isolated ImageIO/Core Image canonical input boundary and exercised adaptive-teeth plus guarded-sclera composition across all eight EXIF rotation/mirror values, an 8-bit Display-P3 round trip, transparent borders, invalid orientation, non-RGB input, and no-face behavior. Production normalization and public contracts remain unchanged. |
| Verdict | `PARTIAL`: all lossless EXIF variants normalize to byte-identical input, Vision anchors, masks, alpha, and output; alpha/outside-mask preservation and invalid/non-RGB/no-face failure pass. The stricter cross-profile topology requirement fails because one-byte P3 round-trip differences move Vision anchors and mask edges. |
| Orientation result | Across e6/e2/e3, all 24 encoded EXIF/mirror runs report zero input/output/alpha/topology mismatch and zero anchor delta after canonical up-oriented sRGB RGBA8 normalization. |
| Sensitivity result | P3 round trips stay within 1 input byte but fresh Vision anchors move 0.53–1.56 px, causing 8/15/76 strong-mask topology differences and 9/4/13 maximum output-byte deltas on e2/e3/e6. Holding canonical anchors fixed reduces topology differences to 3/0/11 and output maxima to 2/1/2, isolating detector sensitivity as the larger contributor. Transparent borders preserve alpha/outside pixels but move anchors 0.77–4.89 px; fixed anchors restore zero topology difference. |
| Verification | Official Apple research recorded; release build and 23/23 self-tests pass; e6/e2/e3 metric assertions and exact event allowlists pass; invalid orientation/non-RGB reject before Vision; no-face exits 1; review JavaScript/assets pass; canonical/oriented/P3/alpha outputs were visually inspected; JSON/privacy/network/production-boundary/diff-hygiene checks pass. |
| Evidence | `.planning/spikes/013-normalized-input-local-retouch/`, aggregate comparison/events JSON, local ignored visual artifacts, updated shared isolated harness, manifest verdict, and this ledger. |
| Boundary | AI fixtures and synthetic profile/alpha variants prove mechanics only. Production must retain one orientation/color owner but still needs a transparent-input policy, HDR/gain-map work, licensed real stability/naturalness review, optimized memory, target-device profiling, and explicit bounded—not byte-identical—cross-profile acceptance. |

Outcome:

- Future still-image local-retouch work must normalize once before both Vision and rendering; passing orientation independently to only one side is not an acceptable ownership model.
- Do not promise identical masks for equivalent 8-bit color-profile encodings. Use containment and bounded output/stability criteria, and evaluate detector drift on rights-approved real inputs.
- Transparent canvas/background handling is a product input decision: either composite against a declared background before detection or reject unsupported alpha semantics. This spike does not choose or implement that production policy.
- No new convention is added because canonical input normalization is established by the production security/design contract but appears in only this one spike session.

### C-2026-07-30-spike-012-wrap-up

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Appended completed Spike 012 to the project-local `spike-findings-beauty` implementation blueprint without changing production source, public API, feature inventory, milestone scope, or runtime behavior. |
| Outputs | Added exact 012 README/review sources; refreshed the exact shared Swift harness; updated the still-image integration recipe with original-pixel ownership, byte-level composition/failure oracles, fail-closed overlap handling, and the CPU performance nonclaim; refreshed the skill trigger/index, processed inventory, and wrap-up summary. |
| Knowledge shape | The skill now covers twelve processed spikes across the same five feature areas. Accepted local color edits derive from the original pixel under one explicit mask owner; unexpected teeth/sclera overlap retains the source pixel. This validates ownership mechanics only, not optimized execution. |
| Verification | Four owner/copy sources compare byte-for-byte; the copied Swift package builds in release and passes 19/19 self-tests; the retained Spike 006 review core passes 9/9; the copied 012 review JavaScript parses; manifest, skill, and summary inventories are 12/12/12; all five references contain required blueprint sections; skill validation, AGENTS route count, runtime-network, generated-directory, media/model/binary, production-boundary, and diff-hygiene checks pass. |
| Boundary | No fixture media, aggregate run artifact, model/weight, build output, product code, public contract, realtime claim, device budget, licensed-evidence claim, or v1.14 activation was packaged. AI fixtures remain mechanics-only and licensed real review remains mandatory. |

Outcome:

- Future local-retouch planning will auto-load the exact composition rule and will not infer that “one fused loop” is a performance win; the tested CPU path was 2.6–3.1× slower than sparse sequential loops.
- The existing `CONVENTIONS.md` already records the recurring original-pixel/explicit-owner/fail-closed-overlap rule established by Spikes 004 and 012, so wrap-up added no duplicate convention or AGENTS route.
- The next evidence-bearing action remains rights-approved real teeth/sclera positive/negative review through Spike 006; frontier exploration remains optional and does not activate v1.14.

### C-2026-07-30-spike-012-guarded-local-retouch-composition

| Field | Value |
| --- | --- |
| Completed | 2026-07-30 |
| Scope | Integrated Spike 009 adaptive teeth selection and Spike 011 guarded per-eye sclera selection behind one original-image color loop in the isolated Swift harness. Added independent standalone and sequential byte oracles, four local failure injections, and explicit fail-closed mask-overlap handling without changing production source or API. |
| Verdict | Narrowly `VALIDATED`: one Vision request supplies both selectors; disjoint fused output exactly matches both oracles; rejected teeth, whole sclera, left eye, and right eye preserve every unaffected output; unexpected overlap keeps the original pixel. Product coverage, naturalness, and performance are not validated. |
| Safety result | e6/e2/e3 have zero baseline cross-mask overlap, zero oracle mismatch, zero outside-union change, zero protected-iris/highlight change, and zero failure-isolation mismatch. e6/e2 each suppress exactly one injected overlap with zero changed collision pixels; e3 naturally has zero teeth candidates while retaining 56 + 88 sclera candidates. |
| Performance result | The release CPU fused prototype measures 6.634 / 0.774 / 0.789 ms on e6/e2/e3 versus 2.570 / 0.290 / 0.255 ms for the sparse sequential loops. One-owner composition semantics pass, but ROI/Metal optimization and device budgets remain required before product planning. |
| Verification | Release build and 19/19 self-tests pass; all three aggregate metric assertions and exact event allowlists pass; review JavaScript and asset references pass; no-face exits 1 with the expected message; masks and outputs were inspected including e6 at original detail; JSON/privacy/network/production-boundary/diff-hygiene scans pass. |
| Evidence | `.planning/spikes/012-guarded-local-retouch-composition/`, aggregate e6/e2/e3 comparison/events JSON, local ignored visual artifacts, updated shared harness and manifest, and the recurring original-pixel/explicit-owner/fail-closed-overlap convention established by Spikes 004 and 012. |
| Boundary | AI-generated fixtures prove mechanics only. Licensed real teeth/sclera positives and negatives, original-detail blind review, optimized ROI/Metal implementation, device profiling, realtime design, public ownership, v1.14 activation, and `去脂` remain outside this result. |

Outcome:

- Adaptive white-teeth and guarded sclera-redness can share a request-local still-image composition path without hidden ordering semantics or cross-region failure coupling.
- The product gate remains unchanged: acquire rights-approved real evidence through Spike 006 before proposing white-teeth/redness scope; do not activate v1.14 from mechanics fixtures.
- If this spike is wrapped into `spike-findings-beauty`, preserve the performance nonclaim and the explicit rule that unexpected mask overlap leaves the source pixel unchanged.
