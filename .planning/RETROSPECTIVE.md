# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.0 - MVP

**Shipped:** 2026-06-23
**Phases:** 7 | **Plans:** 28 | **Recorded tasks:** 62

### What Was Built

- Modular `BeautySDK` Swift Package with internal targets and a public facade.
- SwiftUI Demo validation app with camera mode, still-image mode, compare controls, presets, filters, sliders, disabled future states, parameter JSON, and redacted debug overlay.
- Local-first input, detection, metadata, effect, resource, privacy, and reliability paths with automated SDK and Demo tests.
- Milestone traceability covering 33/33 v1 requirements and 7/7 phase verification files.

### What Worked

- Vertical phase slices kept the SDK facade, Demo behavior, tests, and docs moving together.
- Facade-only scans caught boundary regressions cheaply.
- Fixture-based tests made effect and degradation behavior repeatable before relying on manual visual judgment.
- Keeping release-like claims separate from automated evidence prevented overclaiming visual, hardware, or performance readiness.

### What Was Inefficient

- Some early phase verification and validation artifacts were not committed or backfilled at close, which caused a documentation-only audit failure.
- Several planning artifacts remained untracked in the worktree, making milestone closeout noisier than necessary.
- Phase 5/6/7 validation files needed retroactive status cleanup even though implementation tests had already passed.

### Patterns Established

- Public facade imports are enforced by static scans and Demo tests.
- Every phase should close with `*-VERIFICATION.md`, `*-VALIDATION.md`, summary frontmatter `requirements-completed`, and exact command evidence.
- Manual release risks should be tracked as tech debt, not treated as passed automation.

### Key Lessons

1. Verification artifacts are part of the deliverable; missing docs can block a milestone even when code and tests are green.
2. Validation frontmatter and task tables need closeout updates at phase completion, not only at milestone audit time.
3. For user-facing SDK demos, keep three evidence classes separate: automated state tests, human-visible UAT, and hardware/performance release QA.

### Cost Observations

- Model mix: not measured.
- Sessions: multiple phase sessions across v1.0.
- Notable: Retroactive audit repair was more expensive than writing phase verification artifacts during each phase.

---

## Milestone: v1.3 - Meitu Core Beauty Module Design and Implementation

**Shipped:** 2026-06-30
**Phases:** 5 | **Plans:** 14 | **Recorded tasks:** 35

### What Was Built

- Public-facade `BeautyExampleRenderer` evidence path for ignored, watermarked, same-dimension example-image outputs.
- Current authority core beauty blueprint covering branch taxonomy, module ownership, branch status, future parameter needs, Demo-vs-SDK boundaries, and deferred Meitu product areas.
- Promoted Basic skin behavior with focused tests, renderer cases, output checks, and factual visual observations.
- Beauty-shaping provider/resolver/degradation/redaction evidence for existing public shaping fields without public API expansion or geometry renderer cases.
- Editor-shell closeout docs proving app-side Demo ownership for routing, preview chrome, bottom panel, commit flow, rails, sliders, compare/debug, cancel/confirm, and parameter snapshots.

### What Worked

- The no-new-UI boundary kept the milestone focused on SDK behavior, docs, tests, and renderer evidence instead of reopening SwiftUI scope.
- The branch status vocabulary (`implemented`, `partial`, `blocked-by-geometry-output`, `future`) prevented geometry-output overclaims while still recording real provider/resolver progress.
- Example-image output checks gave visible evidence for skin/color/filter cases while keeping generated PNGs ignored and out of git.
- Final scope scans caught the important integration boundaries: facade-only Demo, UI-free SDK internals, unchanged public parameters, and no renderer geometry-case drift.

### What Was Inefficient

- Phase 18 validation frontmatter kept `wave_0_complete: false` after execution because the test file was intentionally created during the phase; the audit had to interpret that note against later evidence.
- Broad sensitive-token scans over geometry implementation code produced expected false positives, so later plans had to narrow the privacy check to emitted warning/metric/debug strings.
- The live roadmap needed manual collapse after the archive primitive because old phase directories remained in place for lookup.

### Patterns Established

- Closeout docs should cite concrete test names, commands, static scans, and renderer evidence instead of broad capability claims.
- Geometry-heavy branches need an explicit evidence ladder: provider/resolver evidence is useful but does not count as saved-image completion.
- Milestone archival should be path-scoped when the repository has unrelated local documentation changes.

### Key Lessons

1. Keep accepted limitations in the same authority docs as completion claims, so future agents do not promote deferred geometry or release-hardening work by accident.
2. When validation depends on files created during execution, update the validation metadata or record a closeout note before milestone audit.
3. Example-image evidence is strongest when it combines build/run output, same-dimension checks, ignored-artifact checks, and narrow factual visual observations.

### Cost Observations

- Model mix: not measured.
- Sessions: multiple phase sessions across v1.3.
- Notable: The archive itself was cheap after Phase 20 because most evidence had already been captured in phase verification files.

---

## Milestone: v1.4 - Stability, QA, and Debt Cleanup

**Shipped:** 2026-07-03
**Phases:** 5 | **Plans:** 15 | **Recorded tasks:** 34

### What Was Built

- Current-evidence quality baseline covering SDK tests, renderer commands, Demo simulator blocker status, debt routing, and stale-map disposition.
- Demo QA evidence ledger that preserves exact build/test commands, no-PNG screenshot status, blocked per-state review notes, and disabled-route honesty without claiming screenshot success.
- Performance and reliability gates for 720p SDK timing, backpressure, dropped-frame accounting, reset, quality-mode, degradation, safety caps, redacted metrics, and focused Demo camera behavior.
- Renderer regression coverage through a public-facade matrix test, exact pre-watermark no-op fixture checks, a 45-output invariant helper, and durable example-image validation docs.
- Privacy, active-source security, bundled-resource trust, and traceability closeout with explicit future triggers for manifest, external packages, hardware, long-run, and commercial packaging work.

### What Worked

- Treating blocker-honest evidence as first-class output kept the milestone truthful without stalling on local screenshot tooling or physical-device availability.
- Focused tests and scoped scans gave strong gates for Demo backpressure, SDK degradation, renderer output, product-scope tokens, and resource trust without changing public API.
- The final audit made validation-document drift visible before archival, and the follow-up cleanup closed it without inventing new evidence.
- Archiving ROADMAP/REQUIREMENTS/AUDIT before deleting active requirements preserved traceability while keeping the next milestone context small.

### What Was Inefficient

- Phase 21 and Phase 22 validation files still needed retroactive final-status cleanup after the milestone audit.
- Phase 22 screenshot evidence stayed blocked even after Phase 23 focused Demo camera tests passed; the screenshot protocol needs its own rerun instead of inheriting later build evidence.
- Several no-overclaim scans had to be tuned around self-matching documentation strings, which added planning overhead.
- The working tree had unrelated documentation and asset changes, so final archive commits required strict file scoping.

### Patterns Established

- Current-evidence milestones can pass with accepted blocker paths when commands, environment, impact, non-claims, and rerun protocols are explicit.
- Renderer evidence should combine source-owned case inventory, exact no-op fixture checks, generated-output invariants, ignored-artifact checks, and no geometry overclaim.
- Privacy/resource closeout should separate active SDK/Demo behavior, tests/fixtures, example CLI behavior, policy docs, and future distribution triggers.
- Phase archival is optional; keeping phase directories in place is acceptable when historical path stability matters more than aggressive cleanup.

### Key Lessons

1. Validation metadata must be closed during phase execution; audit-time repair is avoidable documentation debt.
2. A passed build/test in one later scope does not erase an earlier screenshot blocker; each evidence lane needs its own command-backed rerun.
3. Future release-hardening work should split device, screenshot, long-run, optimized profiling, packaging, and external-resource integrity into explicit scoped phases.

### Cost Observations

- Model mix: not measured.
- Sessions: multiple phase sessions across v1.4 plus one archival session.
- Notable: The milestone close was smooth after validation debt was cleared, but unrelated local changes made path-scoped staging mandatory.

---

## Milestone: v1.5 - SDK Geometry Output Foundation and Face Shape Slice

**Shipped:** 2026-07-08
**Phases:** 3 | **Plans:** 12 | **Recorded tasks:** 22

### What Was Built

- Public still-image facade geometry activation through `BeautyEngine.processResult(...)`, with package-internal selected-face routing into geometry planning.
- Deterministic SDK-only saved-output geometry evidence through `BeautyExampleRenderer`, `geometryBaseline_noop`, `faceShapeCombo_0p35`, a no-face fixture, and the Phase 27 helper.
- Per-tool face-shape renderer evidence for `faceSlim`, `faceSmall`, signed `chinLength`, `faceVShape`, and `jawSlim`, with 102 ignored outputs, 30/30 top-region comparisons, and a post-ship correction from global proxy output to local control-point warp.
- Focused safety/degradation/redaction tests for caps, no-face/missing-contour behavior, signed `chinLength`, combined weakening, and `jawSlim` alias evidence.
- Scoped blueprint and planning ledger promotion for exactly six second-level `脸型` rows while keeping branch-level `脸型` partial.

### What Worked

- Splitting v1.5 into facade routing, renderer foundation, and per-tool status promotion prevented premature ledger changes.
- Renderer evidence stayed command-backed and ignored-output based, avoiding committed PNG baselines while still proving dimensions and visible geometry deltas.
- Alias handling for `下颌线` stayed conservative: shared `jawSlim` evidence, no new parameter, no Demo behavior, and no distinct algorithm.
- The milestone audit was cheap because Phase 26-28 verification, validation, summary frontmatter, and requirement traceability were already synchronized.

### What Was Inefficient

- The final archive still needed manual live-doc cleanup because the archive primitive did not collapse `ROADMAP.md` or evolve `PROJECT.md` fully.
- Local Swift LOC counting included build-derived `.build` files; future closeout stats should use an explicit source-only path filter when precision matters.
- The working tree still contains unrelated historical documentation and asset changes, requiring strict path-scoped commits.

### Patterns Established

- Geometry-heavy feature completion requires facade-visible saved-output evidence before `implemented` status.
- Generated-output helpers should report counts, dimensions, fixture/case IDs, and comparison counts without hashes, raw pixels, or raw geometry payloads.
- Top-region pixel comparisons are not sufficient by themselves for geometry completion; face-shape evidence also needs a spatial assertion that control points move local pixels while unaffected pixels remain unchanged.
- Branch-level status can remain partial while scoped second-level rows become implemented from evidence.

### Key Lessons

1. Do not promote feature-ledger status from provider/resolver evidence alone; require public-facade saved-output evidence for geometry-heavy rows.
2. Alias-backed features need explicit non-claims so future work does not accidentally split API, renderer, or algorithm behavior.
3. Milestone archive tooling is useful for canonical files, but PROJECT/ROADMAP/RETROSPECTIVE still need human review.

### Cost Observations

- Model mix: not measured.
- Sessions: multiple phase sessions across v1.5 plus audit/archive sessions.
- Notable: The v1.5 closeout benefited from prior v1.4 blocker-honest evidence patterns and required no new Swift verification during archive.

---

## Milestone: v1.6 - Broader 美型 / 五官 SDK Slice - Eyes

**Shipped:** 2026-07-13
**Phases:** 2 | **Plans:** 11 | **Recorded tasks:** 19

### What Was Built

- Six public-facade eye renderer cases plus a 23-case/7-fixture helper path with 161/161 outputs and 36/36 portrait comparisons.
- Conservative public eye normalization, exact caps, missing/reused/stale eye-domain degradation, no-face continuation, and combined-geometry weakening.
- Active-source boundary evidence for raw geometry, internal imports, network/cloud behavior, commercial paths, public inventory, and generated artifacts.
- Exact implementation promotion for `大小`, `上下`, `眼距`, and `眼尾上扬`, while branch-level `眼睛` remains `partial`.
- Synchronized root, blueprint, quality, project, roadmap, requirements, state, validation, work-ledger, and audit owners.

### What Worked

- The evidence-before-promotion sequence kept runtime verification ahead of ledger changes.
- Exact row-count, boundary, redaction, and generated-artifact guards made the four-tool scope enforceable.
- The final comprehensive integration checker combined source wiring, tests, renderer/helper evidence, and current-owner documentation checks.

### What Was Inefficient

- Initial Phase 30 closeout scans were too narrowly bounded and missed stale current-state text in several owner documents.
- Repeated audit/fix cycles found one contradiction at a time before the work switched to a comprehensive current-owner scan.
- Phase 29 summaries 03/04 used `requirements` rather than `requirements-completed`, requiring audit-time interpretation despite complete evidence elsewhere.

### Patterns Established

- Milestone closeout scans should cover every current owner and contract table, not only files touched by the final plan.
- Parent branch contracts and child feature contracts must be checked together whenever second-level status changes.
- Markdown table structure, relative links, and historical-vs-current wording belong in documentation verification gates.

### Key Lessons

1. Run one comprehensive current-owner consistency audit before declaring DOC requirements complete; narrow scans invite serial repair loops.
2. Keep historical evidence wording, current contracts, and future-scope boundaries explicitly distinguishable.
3. Use `requirements-completed` consistently in every summary to keep three-source milestone audits mechanical.

### Cost Observations

- Model mix: not measured.
- Sessions: multiple Phase 29/30 sessions plus audit and remediation sessions.
- Notable: Runtime work was stable; documentation reconciliation dominated final closeout cost.

---

## Milestone: v1.7 - Broader 美型 / 五官 SDK Slice - Nose

**Shipped:** 2026-07-13
**Phases:** 2 | **Plans:** 11

### What Was Built

- Five public-facade nose renderer cases with 196/196 output, 30/30 portrait, 6/6 signed-tip, and ignored-gallery evidence.
- End-to-end signed `noseTipSize` correction plus exact caps and normalization for all four existing fields.
- Missing/stale fail-closed zeroing, reused `0.5`, safe no-face continuation, combined weakening, and redacted diagnostics.
- Exact implementation promotion for `大小`, `鼻翼`, `鼻梁`, and `鼻尖`, while `山根`, `提升`, and branch-level `鼻子` remain partial/future.

### What Worked

- The shared-contract scan found the sign-folding call before planning and enumerated every renderer/helper/current-owner consumer.
- Phase 31 output evidence preceded Phase 32 safety and ledger promotion.
- The comprehensive pre-audit scan collected the complete documentation defect set, repaired it in one batch, and enabled a single passing final audit.

### What Was Inefficient

- The first focused combined-suite run experienced a one-off 374-second preset test; the fresh full suite completed normally in 30 seconds.
- GSD summary extraction reported zero tasks because the compact plan/summary artifacts did not encode task counts, so archive stats use plans and direct verification evidence.

### Patterns Established

- Signed geometry requires distinct normalization, effective-strength, provider-target, renderer-baseline, and positive-vs-negative evidence.
- Non-eye reuse policy must remain explicit when a nearby eye domain uses a stricter skip contract.
- Historical evidence sections must carry time-qualified counts once the canonical renderer inventory grows.

### Key Lessons

1. Scan all shared consumers before planning any renderer inventory expansion.
2. Treat sign preservation as an end-to-end contract, not merely a resolver test.
3. Collect the whole current-owner defect set before final audit and batch repair once.

### Cost Observations

- Model mix: not measured.
- Sessions: autonomous milestone initialization, Phase 31/32 execution, audit, and archive.
- Notable: Runtime implementation was small; output decoding and comprehensive documentation evidence dominated elapsed time.

---

## Milestone: v1.8 - Broader 美型 / 五官 SDK Slice - Mouth

**Shipped:** 2026-07-13
**Phases:** 2 | **Plans:** 6

### What Was Built

- Six isolated public-facade mouth/lip cases plus 238/238 decoded same-dimension output and ignored-gallery evidence.
- Signed `mouthSize` and `mouthWidth` geometry with 30/30 ROI and 12/12 opposite-direction comparisons.
- Exact caps, missing/no-face/stale fail-closed zeroing, reused `0.5`, combined weakening, and redacted diagnostics.
- Color-only `lipColor` containment with 6/6 checks and an explicit boundary against true `丰唇` geometry.
- Exact promotion for `大小`, `宽度`, and `微笑`, while branch-level `嘴唇` remains partial.

### What Worked

- The output-evidence phase preceded safety and ledger promotion, keeping visible proof ahead of status changes.
- Exact matrix, signed-pair, inventory, artifact, and future-row guards made the narrow slice mechanically verifiable.
- The final independent audit rechecked runtime, cross-phase wiring, current owners, Nyquist, security, and all conservative non-claims.

### What Was Inefficient

- Early audit passes surfaced documentation-owner contradictions sequentially rather than in one complete current-owner scan.
- Compact summaries omitted task counts and one-line metadata, so automatic archive statistics required manual enrichment.

### Patterns Established

- Every phase handoff must be updated after downstream completion; historical verification must not describe completed gates as pending.
- Milestone audits should scan PROJECT and QUALITY_SCORE current snapshots alongside phase-local evidence.
- Color-domain evidence and geometry-domain evidence need separate claims, freshness policy, and promotion rules.

### Key Lessons

1. Run a comprehensive current-owner contradiction scan before the first milestone audit.
2. Treat positive/negative geometry as an end-to-end output contract, not only a normalization test.
3. Keep future rows and branch-level status explicit even when all existing public parameters are verified.

### Cost Observations

- Model mix: not measured.
- Sessions: autonomous phase execution plus audit, one bounded closure attempt, and archive.
- Notable: Runtime behavior stabilized quickly; documentation consistency dominated closeout effort.

---

## Milestone: v1.9 - Nose Remaining Tools and Branch Closeout

**Shipped:** 2026-07-14
**Phases:** 3 | **Plans:** 11 | **Sessions:** 1 autonomous chain

### What Was Built

- Added independent positive-only `noseRootNarrowing` and `noseTipLift` public contracts with legacy decoding neutrality and package-only support geometry.
- Proved isolated public-facade output across a strict 36 × 7 matrix and closed exact all-six safety, degradation, convergence, privacy, and artifact boundaries.
- Promoted exactly the two remaining rows and the exact six-row SDK-core `鼻子` branch after an independent 15/15 milestone audit.

### What Worked

- Requirement-named matrices and fixed numeric output thresholds made every promotion claim command-verifiable.
- Fail-closed review loops caught provider-emission threshold bugs and gallery filesystem races that ordinary green suites did not expose.
- Keeping promotion last preserved truthful current-owner state throughout implementation and made the final transaction auditable.

### What Was Inefficient

- Repeated deep review iterations on shared conflict and gallery helpers added substantial cycle time; threat modeling these seams earlier would have reduced rework.
- Several planner/executor agents lingered after artifacts existed, requiring filesystem/commit fallback and one quota-driven main-thread recovery.

### Patterns Established

- Provider eligibility, effective strengths, conflict totals/count/scale, and final emissions must converge on one retained set.
- Generated-evidence tools require bounded same-descriptor reads and descriptor-anchored atomic publication, not pathname prechecks.
- Product-row promotion is a final transaction after runtime, security, owner, and lifecycle gates all pass.

### Key Lessons

1. Test threshold-crossing and provider-empty behavior after conflict scaling, not only before it.
2. Treat local evidence tooling as security-sensitive whenever it deletes, copies, decodes, or publishes filesystem content.
3. Preserve explicit non-claims in every current owner so SDK-core completion cannot be mistaken for release readiness.

### Cost Observations

- Model mix: quality profile across planning, execution, review, and audit agents.
- Sessions: one autonomous milestone chain with resumptions after user interruptions.
- Notable: independent review found high-value defects, but bounded agent timeouts and earlier adversarial fixtures would improve efficiency.

---

## Milestone: v1.10 - Mouth Remaining Geometry Controls

**Shipped:** 2026-07-14
**Phases:** 3 | **Plans:** 11 | **Sessions:** 1 autonomous chain

### What Was Built

- Added independent signed mouth Y/tilt/X controls and positive-only lip peak/plump controls through an exact 38-field compatibility contract.
- Added package-private outer/inner and upper/lower lip supports plus eight independently eligible mouth emissions with final `0.25` caps.
- Proved the five controls through a strict 44 × 7 public-facade output matrix, exhaustive degradation/convergence evidence, and exact five-row promotion.

### What Worked

- Keeping promotion until the final phase preserved clean nonclaims while public, provider, output, safety, and boundary evidence accumulated.
- One retained-set convergence contract aligned requested work, provider eligibility, conflict arithmetic, effective strengths, and final emissions.
- Frozen non-circular output thresholds and a fixed mouth ROI made visual evidence reproducible without committing binary baselines.

### What Was Inefficient

- The external plan checker timed out despite deterministic plan-structure validation passing, so execution needed an explicit recorded fallback.
- The strict 308-output decoder is deliberately thorough and took over two minutes during the final audit; progress reporting should account for that expected quiet interval.
- Automatic milestone statistics counted one summary per plan as a task, so the archive entry required correction to the actual 23 plan tasks.

### Patterns Established

- Local lip-shape effects must declare their exact support dependencies; missing inner support removes only peak/plump work while whole-mouth siblings remain eligible.
- Milestone audits should rerun the unchanged generated-output gate, not only trust phase evidence or regenerate thresholds.
- Cleanup must use archived roadmap membership and remain limited to the just-completed phase range when unrelated historical directories remain active.

### Key Lessons

1. For multi-field geometry, treat provider eligibility as the canonical retained set before computing aggregate conflict evidence.
2. Preserve signed direction through every stage and verify it in saved output, not only normalization and vector unit tests.
3. Keep teeth whitening separate from mouth warp geometry until teeth-region segmentation and retouch ownership are explicitly scoped.

### Cost Observations

- Model mix: quality profile across planning, implementation, review, verification, and lifecycle audit.
- Sessions: one autonomous milestone chain with sequential phase agents and an independent lifecycle audit.
- Notable: fixed evidence owners and adversarial boundary self-tests made the final audit a rerun rather than a repair phase.

---

## Milestone: v1.11 - Eye Remaining Geometry Controls

**Shipped:** 2026-07-19
**Phases:** 4 | **Plans:** 18

### What Was Built

- Added ten independent eye controls to the 48-field public model while retaining legacy source/JSON/preset neutrality.
- Added request-scoped, package-internal Vision contour/pupil support with one coordinate-mapping boundary, deterministic canonicalization, and redaction.
- Wired fourteen named eye emissions through resolver/provider/conflict/facade paths with field-local eligibility and safe sibling continuation.
- Proved 55 public-facade cases across seven fixtures (385 outputs), strict semantic distinctions, correction/no-op behavior, and ignored-gallery containment.
- Locked caps, dead zones, freshness/degradation, combined 10.70/33 retained arithmetic, fail-closed boundary gates, and exact promotion of ten geometry rows while keeping retouch rows future.

### What Worked

- Keeping the public contract, private observed support, provider eligibility, output evidence, and ledger promotion as separate gates prevented proxy-only or documentation-only overclaims.
- Independent audit rechecked all 24 requirements, 10 integration seams, 6 end-to-end flows, and all phase artifacts before lifecycle closeout.
- Self-tested active-source and generated-artifact boundaries made privacy and repository hygiene reproducible without tracking binary output.

### What Was Inefficient

- A coordinate-frame review finding required a Phase 41 gap-closure plan after the initial implementation, showing that local Vision point coordinates need explicit translated-bounding-box fixtures early.
- Archive tooling created canonical files and moved phase directories but still required manual ROADMAP/PROJECT/RETROSPECTIVE evolution and path-scoped lifecycle commits.
- Automatic task extraction from compact summaries was not reliable enough for milestone statistics; plan counts and verification evidence are the authoritative closeout metrics.

### Patterns Established

- Observed geometry must be transformed from face-local Vision coordinates into image-normalized coordinates exactly once before support validation.
- Field-local eligibility is the retained-set source of truth for totals, counts, warnings, metrics, domains, and final dispatch.
- Geometry promotion is a final transaction after contract, provider, facade-output, safety, privacy, owner, and independent-audit gates all pass.

### Key Lessons

1. Add translated-bounding-box and orientation/mirror fixtures at the first detection-support plan, not only during review.
2. Keep archive, roadmap, project, state, and retrospective updates explicit after the CLI archive primitive; lifecycle completion is not only a file move.
3. Preserve future retouch and partial-branch language in every owner document when a geometry slice ships.

### Cost Observations

- Model mix: quality profile across autonomous planning, implementation, review, verification, and lifecycle agents.
- Sessions: one autonomous v1.11 chain with phase resumptions and an independent milestone audit.
- Notable: Runtime implementation and tests were stable; strict saved-output evidence and current-owner documentation synchronization dominated closeout time.

## Milestone: v1.12 - Face Shape Remaining Capabilities

**Shipped:** 2026-07-24
**Phases:** 4 | **Plans:** 20

### What Was Built

- Added four independent positive-only face controls to an exact 52-field public model while preserving legacy source, JSON, preset, and shipped resolver behavior.
- Added request-scoped, package-internal observed face contour and median support with bounded mapping, canonicalization, topology validation, and region-local fail-closed behavior.
- Added four distinct contour/chin providers and one provider-eligible 37-field/11.70 convergence and dispatch path without changing shipped face/chin arrays.
- Proved 59 public-facade cases across seven fixtures (413 outputs), strict face-local comparisons, safe no-ops, and ignored-gallery containment.
- Locked final caps, complete nine-field transitions, redacted diagnostics, exact four-row promotion, synchronized owners, and an 18/18 independent audit while preserving three semantic-region blockers.

### What Worked

- Splitting public compatibility, observed support, provider behavior, saved-output evidence, and final promotion into separate phases kept provenance and completion claims independently testable.
- RED-first provider/resolver/degradation contracts exposed missing routing before production changes and made the final 37-field accounting measurable.
- Self-tested boundary checkers plus immutable aggregate evidence owners made the independent audit a deterministic rerun across runtime, privacy, output, and documentation.

### What Was Inefficient

- The original semantic-region scope required an early feasibility correction because no approved local model and clean-clone fixtures existed; recording that blocker before implementation prevented larger rework.
- Code-review convergence in Phase 45 required several small topology and redaction fixes that would have been cheaper with adversarial open-path and reflection fixtures in the first plan.
- The archive primitive moved canonical artifacts but still required explicit ROADMAP, PROJECT, STATE, PLANS, retrospective, requirements-removal, and tag lifecycle work.

### Patterns Established

- New observed face semantics must live beside, never replace, the shipped seven-point compatibility proxy.
- Open-path biometric-adjacent support needs exact point ceilings, topology predicates, request-local lifetime, aggregate-only diagnostics, and structural-reflection redaction.
- Promotion remains an atomic final transaction after public compatibility, provider eligibility, decoded output, safety transitions, active-source boundaries, owner synchronization, and independent audit all agree.

### Key Lessons

1. Run feasibility checks for semantic-resource rows before roadmap lock; when approved local resources are absent, narrow scope explicitly instead of substituting geometric proxies.
2. Treat provider-eligible named emissions as the sole retained-set authority for totals, weakening, metrics, and dispatch.
3. Keep lifecycle archive work explicit after the CLI move so root planning files cannot continue to advertise an already-shipped milestone as active.

### Cost Observations

- Model mix: quality profile across autonomous planning, implementation, review, verification, security, and lifecycle audit.
- Sessions: one autonomous v1.12 chain with phase resumptions and an independent milestone audit.
- Notable: Phase 45 review convergence dominated corrective work; later phases benefited from stable boundary checkers and exact owner gates.

## Milestone: v1.13 - Eyebrow Geometry Controls

**Shipped:** 2026-07-28
**Phases:** 4 | **Plans:** 26 | **Recorded tasks:** 54

### What Was Built

- Added seven compatibility-safe eyebrow controls to the exact 59-field public model.
- Added actual request-scoped Vision eyebrow support with exactly-once mapping, open-path validation, and aggregate-only diagnostics.
- Added seven distinct provider emissions through one exact 44-field/13.45 retained set and stable unified dispatch.
- Added strict 72-portrait output evidence, thirteen separate no-face comparisons, fourteen actual-image reviews, and an ignored 144-file gallery.
- Locked final caps, lifecycle/degradation/concurrency behavior, clean review, ASVS L1 boundaries, exact product promotion, and a passing 21/21 independent audit.

### What Worked

- Separating public contract, observed provenance, provider routing, decoded output, and final promotion kept every claim evidence-owned.
- The real output route caught top-left image-Y and Vision endpoint-order defects that provider-only fixtures missed.
- Production-path gap closure for adapter-valid fixtures, in-flight cancellation, and retained-mask tracing turned an initially weak verifier result into reproducible 16/16 acceptance.
- The milestone audit surfaced governance-only debt before archive; explicit human judgment and validation normalization cleared it without changing runtime behavior.

### What Was Inefficient

- Phase 52's executor checker encoded a pre-verification lifecycle state, so post-verification owner synchronization initially reduced 35/35 to 31/35 until the gate was advanced and adversarially retested.
- Two small example-document inconsistencies required a review/fix/re-review loop after implementation was otherwise complete.
- The typed follow-up reviewer hit a platform usage limit, requiring a transparently labeled inline delta review instead of pretending independent coverage.
- The milestone primitive generated an overlong accomplishment list and did not move phases; explicit cleanup and owner polishing remained necessary.

### Patterns Established

- Observed biometric-adjacent support needs a source-provenance judgment in addition to automated privacy scans when a plan explicitly reserves ethical/scope questions.
- Lifecycle-aware checkers should model pre-verification, post-verification/pre-audit, and post-audit states explicitly rather than freezing one transition.
- Current review reports must distinguish independent base review from any fallback delta review and pair both with executable evidence.
- Cleanup must update runnable documentation paths when phase-owned helpers move into milestone archives.

### Key Lessons

1. Put production adapter validity into shared fixtures before provider tests become the main oracle.
2. Exercise cancellation only after real request-owned work begins, then join and prove request isolation.
3. Normalize validation lifecycle vocabulary during phase closeout, not at milestone audit.
4. Treat archive tooling as a primitive: verify its output, then explicitly collapse live owners, move phases, update paths, and record the retrospective.

### Cost Observations

- Model mix: quality profile across implementation, review, verification, integration audit, and lifecycle closeout.
- Sessions: one multi-day milestone with gap-closure and audit-remediation loops.
- Notable: strict output and governance reconciliation dominated closeout after the runtime path stabilized.

---

## Milestone: v1.14 — Local Facial Retouch

**Shipped:** 2026-08-05
**Phases:** 6 | **Plans:** 27

### What Was Built

- Established a canonical still-image/request-local boundary with exact legacy
  compatibility and no realtime or pixel-buffer expansion.
- Built feature-neutral original-pixel composition and failure isolation while
  preserving literal-empty production admission.
- Closed teeth, sclera, and upper-eyelid feature gates independently from
  insufficient evidence, preserving disabled taxonomy rows and zero promotion.
- Completed adversarial safety review/fix, independent verification `12/12`,
  full SwiftPM/Demo regression, and a `41/41` milestone audit.

### What Worked

- Exact aggregate-only checker outputs kept sensitive source and fixture data
  out of diagnostics while still exercising live mutation cases.
- The frozen Phase 57 adapter plus a strict completed-state path preserved prior
  provenance across the combined closeout.
- Sequential wave ownership and final-only full regression prevented premature
  claims and made the archive decision reproducible.

### What Was Inefficient

- The checker lifecycle initially encoded the pre-verifier state, requiring
  adversarial fixes and a second document reconciliation before archive.
- Archive tooling required explicit root-owner cleanup, roadmap collapsing, and
  phase-directory verification after the primitive completed.

### Patterns Established

- Exact-empty admission is a valid positive closeout outcome when evidence
  gates are closed; mechanics remain testable only behind opaque Testing hooks.
- Lifecycle evidence must distinguish plan checkpoint, review/fix, independent
  verification, milestone audit, and archive states.
- Cross-phase audit reports should map integration seams to requirements and
  explicitly state when no product E2E flow is expected by design.

### Key Lessons

1. Keep evidence, verification, and archive lifecycle states synchronized before
   invoking milestone completion.
2. Preserve frozen prior-phase checkers byte-for-byte and add compatibility
   adapters for post-transition owners.
3. Treat closed feature gates as exact absence requirements, not invitations to
   add inert fields or proxy behavior.

### Cost Observations

- Model mix: autonomous implementation, adversarial review, verification,
  integration audit, and lifecycle closeout.
- Sessions: one multi-day milestone with review and lifecycle reconciliation.
- Notable: checker hardening and owner synchronization consumed more closeout
  time than the stable runtime path.

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Sessions | Phases | Key Change |
|-----------|----------|--------|------------|
| v1.0 | multiple | 7 | Established GSD phase execution, facade-boundary scans, Nyquist validation, and milestone archive flow. |
| v1.3 | multiple | 5 | Added example-image renderer evidence and strict branch-status taxonomy for partial geometry work. |
| v1.4 | multiple | 5 | Added blocker-honest hardening gates, renderer output regression, active-source privacy/security scans, and archive-before-delete closeout. |
| v1.5 | multiple | 3 | Added public-facade geometry output evidence and scoped face-shape ledger promotion. |
| v1.6 | multiple | 2 | Added exact eye-slice evidence/promotion and comprehensive current-owner consistency scans. |
| v1.7 | autonomous | 2 | Added signed nose-slice evidence, fail-closed degradation, and single-pass final audit discipline. |
| v1.8 | autonomous | 2 | Added signed mouth evidence, color-vs-geometry separation, and current-owner audit closure. |
| v1.9 | autonomous | 3 | Added independent remaining-nose contracts, adversarial review loops, atomic six-row branch promotion, and a 15/15 audit. |
| v1.10 | autonomous | 3 | Added independent remaining-mouth contracts, explicit private lip supports, strict 308-output evidence, and a 17/17 audit. |
| v1.11 | autonomous | 4 | Added private observed eye support, fourteen named emissions, strict 385-output evidence, exact ten-row promotion, and a 24/24 audit. |
| v1.12 | autonomous | 4 | Added private observed face support, four independent contour/chin providers, strict 413-output evidence, exact four-row promotion, and an 18/18 audit. |
| v1.13 | autonomous | 4 | Added actual observed eyebrow support, seven distinct providers, strict 72-portrait evidence, exact eyebrow-branch promotion, and a 21/21 audit. |
| v1.14 | autonomous | 6 | Added exact-empty still-image retouch safety boundaries, original-pixel mechanics, independent closed feature gates, and a 41/41 audit. |

### Cumulative Quality

| Milestone | Tests | Coverage | Zero-Dep Additions |
|-----------|-------|----------|-------------------|
| v1.0 | 119 SDK tests plus Demo simulator XCTest suite | Requirement traceability 33/33 | No new third-party runtime dependency recorded for v1 Demo QA surface. |
| v1.3 | 141 SDK tests plus renderer matrix evidence | Requirement traceability 20/20 | No new third-party runtime dependency recorded for core beauty closeout. |
| v1.4 | 150 SDK tests, focused Demo privacy/import tests, renderer invariant helper, and milestone audit | Requirement traceability 24/24 | No new third-party runtime dependency recorded for hardening closeout. |
| v1.5 | 171 SDK tests, geometry and face-shape renderer helpers, and milestone audit | Requirement traceability 13/13 | No new third-party runtime dependency recorded for geometry closeout. |
| v1.6 | 178 SDK tests, eye renderer helper, boundary scans, and milestone audit | Requirement traceability 9/9 | No new third-party runtime dependency recorded for eye-slice closeout. |
| v1.7 | 186 SDK tests, 196-output nose helper, boundary scans, and milestone audit | Requirement traceability 9/9 | No new third-party runtime dependency recorded for nose-slice closeout. |
| v1.8 | 190 SDK tests, 238-output mouth helper, signed/color checks, boundary scans, and milestone audit | Requirement traceability 11/11 | No new third-party runtime dependency recorded for mouth-slice closeout. |
| v1.9 | 228 SDK tests, 252-output strict helper, adversarial boundary scans, and milestone audit | Requirement traceability 15/15 | No new third-party runtime dependency recorded for remaining-nose closeout. |
| v1.10 | 265 SDK tests, 308-output strict helper, 63-case boundary self-test, and milestone audit | Requirement traceability 17/17 | No new third-party runtime dependency recorded for remaining-mouth closeout. |
| v1.11 | 314 SDK tests, 385-output strict helper, 57-case boundary self-test, and milestone audit | Requirement traceability 24/24 | No new third-party runtime dependency recorded for remaining-eye closeout. |
| v1.12 | 375 SDK tests, 413-output strict helper, 70-case boundary self-test, and milestone audit | Requirement traceability 18/18 | No new third-party runtime dependency recorded for remaining-face closeout. |
| v1.13 | 450 SDK tests, 72-portrait/13-no-face strict helper, 130-case boundary self-test, and milestone audit | Requirement traceability 21/21 | No new third-party runtime dependency recorded for eyebrow closeout. |
| v1.14 | 553 SwiftPM tests (six expected Vision skips), 6 opt-in Vision tests, 120 Demo tests, and 703-case post-review checker | Requirement traceability 41/41 | No new third-party runtime dependency; production feature admission remains exact-empty. |

### Top Lessons (Verified Across Milestones)

1. Keep facade-boundary and privacy scans cheap enough to run at every phase close.
2. Archive-ready planning artifacts need the same rigor as code and tests.
3. Separate provider/resolver evidence, saved-image evidence, and release-hardening evidence to avoid overclaiming shipped scope.
4. Blocker-honest evidence is useful only when paired with exact rerun commands and clear non-claims.
5. Geometry-heavy status promotion should be staged: routing, saved-output foundation, then per-tool ledger promotion.
6. Documentation closeout should scan all current owners and parent/child contracts in one pass before milestone audit.
7. Semantic-resource feasibility must be established before roadmap lock; absent approved resources should produce an explicit reduced scope, not proxy evidence.
