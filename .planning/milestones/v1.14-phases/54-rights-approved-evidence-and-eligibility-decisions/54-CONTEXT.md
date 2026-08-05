# Phase 54: Rights-Approved Evidence and Eligibility Decisions - Context

**Gathered:** 2026-07-31
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 54 freezes one privacy-minimized evidence contract, exercises it against
the locally available rights-approved inventory, and records independent
go/no-go decisions for teeth whitening, sclera redness reduction, and
upper-eyelid fullness reduction. A closed gate is a complete and valid phase
outcome. This phase adds no public field, provider, renderer case, production
mask, Demo control, realtime path, network service, tracked portrait media, or
visible product behavior.

</domain>

<decisions>
## Implementation Decisions

### Evidence bundle completeness

- **D-01:** A feature gate can open only when one feature-specific local bundle
  contains at least one genuine positive and one genuine negative, every
  included fixture is `approved_internal_evaluation`, polarity was declared
  before review, and every fixture has complete original/mask/after assets.
- **D-02:** Bundle validation is fail-closed for absolute/traversal paths,
  duplicate or non-opaque IDs, unsupported enums, incomplete asset triples,
  missing rights records, mixed features, or missing positive/negative
  coverage. A structurally valid partial bundle remains visibly closed.
- **D-03:** `mechanics_only`, synthetic, AI-generated, disabled, parked, or
  historically authorized fixtures may exercise deterministic schema, safety,
  and reviewer mechanics but contribute zero rows and zero weight to
  product-effectiveness or naturalness aggregates.
- **D-04:** `portrait_001` is a real rights-approved fixture. It may contribute
  as an already-light-teeth/over-whitening negative only after a complete
  teeth-specific asset triple and frozen review pass. It is not a genuine
  discoloration positive and has no automatic sclera or upper-eyelid polarity.
  Even a qualified teeth-negative row cannot open the teeth gate without an
  independent genuine positive.

### Frozen blinded review

- **D-05:** Freeze the review schema and pass rules before opening any outcome.
  Each row records only target presence, mask coverage on the fixed 1–5 scale,
  protected leakage, naturalness on the fixed 1–5 scale, structure change,
  accept/reject, and one allowlisted reason code.
- **D-06:** An accepted positive must have the target present, mask coverage at
  least 4, no protected leakage, naturalness at least 4, no structure change,
  and an accept decision. An accepted negative must have its predeclared target
  absence/challenge confirmed and show no protected leakage, no structure
  change, naturalness at least 4, and an accept decision. Every selected
  genuine row must pass; post-hoc threshold changes are forbidden.
- **D-07:** Review remains browser-local, static, single-reviewer, and
  original-detail. It uses local File API object URLs only—no server, upload,
  fetch, XHR, WebSocket, beacon, analytics, or external dependency.
- **D-08:** Durable export contains only opaque fixture/feature/polarity IDs,
  the fixed structured judgments, decision, allowlisted reason code, and
  per-feature aggregates. It excludes media, filenames, filesystem paths,
  rights/documentation IDs, retention text, raw geometry or masks, reviewer
  identity, timestamps, and freeform text. Sensitive media and intermediate
  events remain local, ignored, and ephemeral.

### Independent feature decisions

- **D-09:** Teeth, sclera, and upper-eyelid decisions use separate bundle
  inventories, denominators, reason codes, and gate records. A sibling cannot
  borrow evidence, and one closed gate cannot block another feature's decision.
- **D-10:** The teeth gate closes in the current inventory because there is no
  genuine discoloration positive with a complete approved asset triple. The
  fixed reason code must distinguish the missing positive from containment or
  naturalness failure.
- **D-11:** The sclera gate closes independently because there is no genuine
  redness positive and no complete approved positive/negative bundle.
  Mechanics/jitter evidence remains excluded from product aggregates.
- **D-12:** Closed decisions are inputs—not blockers—to Phases 55–58. Downstream
  phases must preserve exact absence for closed features: no public parameter,
  admission, provider, renderer case, preset key, inert route, or promotion.

### Upper-eyelid design qualification

- **D-13:** `去脂` requires two independent prerequisites: a complete genuine
  upper-eyelid-fullness positive/negative bundle and a credible non-warp design.
  Either missing prerequisite deterministically closes the gate.
- **D-14:** The tested interior vertical warp remains invalidated and cannot be
  reconsidered, renamed, or proxied through eye/brow geometry. `eyeHeight`,
  `upperEyelidLift`, brow translation, aperture change, global smoothing,
  dark-circle work, and eye-bag work are explicit non-substitutes.
- **D-15:** The tone/frequency experiment remains partial: it preserved texture
  in mechanics fixtures but did not prove the intended fullness semantic on a
  genuine positive. It therefore does not yet qualify as the independent
  non-warp design required by LID-01.
- **D-16:** The current `去脂` decision closes for both missing genuine evidence
  and unqualified non-warp design. Phase 54 records both fixed reason codes;
  Phase 57 must keep `upperEyelidFullnessReduction` absent, `去脂` future, and
  branch `眼睛` partial unless a separately approved future phase reopens both
  prerequisites.

### the agent's Discretion

- Choose the smallest repository-native implementation shape for the pure
  validator, fixed enums, deterministic tests, local review shell, and aggregate
  decision ledger.
- Choose opaque identifier spellings and fixed reason-code names, provided they
  are stable, allowlisted, feature-specific, and contain no sensitive payload.
- Reuse Spike 006 assets or port their pure core where that reduces duplication;
  do not mutate the packaged spike source into the production contract.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone and requirement owners

- `.planning/ROADMAP.md` — Phase 54 goal, dependencies, and five success
  criteria; later phases accept closed feature gates.
- `.planning/REQUIREMENTS.md` — EVID-01 through EVID-05 and LID-01, plus
  downstream absence/promotion constraints.
- `.planning/PROJECT.md` — v1.14 milestone scope and core value.
- `.planning/STATE.md` — current blockers and carried-forward decisions.
- `PLANS.md` — active milestone ledger, current fixture limits, and no-scope-
  expansion rule.
- `PRODUCT_SENSE.md` — product-evidence boundary and honest feature-status
  language.
- `SECURITY.md` — sensitive portrait/support data and persistence/network
  prohibitions.
- `RELIABILITY.md` — fail-closed behavior, stable reason codes, and recovery
  expectations.
- `QUALITY_SCORE.md` — evidence/test/document quality gates.

### Authorized local inventory

- `example-images/FIXTURE_AUTHORIZATION.md` — opaque rights record and exact
  permitted/evidence-limited use of `portrait_001`.
- `example-images/README.md` — active/parked fixture discovery and ignored
  output/gallery boundaries.

### Phase 53 dependency

- `.planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/53-CONTEXT.md`
  — exact-empty production admission, request-local privacy, and compatibility
  decisions that Phase 54 must not reopen.
- `.planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/53-VERIFICATION.md`
  — verified still-image foundation and explicit nonclaims.

### Local-retouch findings

- `.codex/skills/spike-findings-beauty/references/licensed-fixture-evaluation.md`
  — approved bundle schema, local blinded reviewer, structured export, and
  mechanics-only exclusion.
- `.codex/skills/spike-findings-beauty/references/teeth-whitening.md` — genuine
  teeth-positive/negative coverage and protected-tissue review needs.
- `.codex/skills/spike-findings-beauty/references/sclera-redness.md` — genuine
  redness evidence, per-eye safety, and strict privacy needs.
- `.codex/skills/spike-findings-beauty/references/upper-eyelid-fullness.md` —
  invalidated warp, partial tone experiment, and non-substitute boundaries.
- `.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/fixture-manifest.schema.json`
  — tested manifest shape available for reuse or porting.
- `.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/review-core.js`
  — tested pure validation/export core.
- `.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/review.html`
  — static offline reviewer reference.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- Spike 006 supplies a 9/9-tested pure manifest/review/export core, JSON schema,
  and static File-API reviewer. Treat it as a reference implementation; port or
  wrap it under a Phase 54 owner rather than editing the packaged source.
- `portrait_001` is already metadata-sanitized, rights-approved, locally
  present, and Git-ignored. Its authorization owner gives Phase 54 a real
  negative/challenge candidate without creating a positive it does not contain.
- Existing privacy/resource scanners and `git check-ignore` patterns already
  enforce that portrait, mask, after, and gallery assets remain untracked.

### Established Patterns

- Compatibility and privacy boundaries are fail-closed and mutation-tested.
- Public/SPI/Codable outputs expose fixed aggregate enums/counts only; raw
  portrait-derived values stay request-local or review-session-local.
- Root documents own durable contracts; planning artifacts record evidence and
  exact nonclaims.
- Feature rows are promoted independently. Absence is the required
  implementation for a closed conditional gate.

### Integration Points

- Phase 54 should add a phase-owned pure evidence validator/reviewer contract,
  deterministic fixtures/tests, a privacy-safe aggregate decision artifact,
  and root-ledger updates.
- It must not connect to `BeautyEngine`, `BeautyParameters`,
  `BeautyLocalRetouchAdmission`, renderer inventories, presets, Demo code, or
  pixel-buffer paths.
- Phase 55 consumes only the independent structured gate results; it does not
  receive paths, media, rights records, masks, or raw review data.

</code_context>

<specifics>
## Specific Ideas

- Prefer an explicit three-row gate table (`teeth_whitening`,
  `sclera_redness`, `upper_eyelid_fullness`) with stable closed reason codes and
  zero cross-feature aggregation.
- Make the current evidence shortage executable: mutation tests should prove
  that adding mechanics-only rows, borrowing a sibling row, omitting one asset,
  or changing polarity after review cannot open a gate.
- Preserve a truthful partial result for `portrait_001`: rights-approved real
  input and teeth negative/challenge eligibility do not imply a complete teeth
  bundle.

</specifics>

<deferred>
## Deferred Ideas

- Acquiring additional rights-approved genuine positive/negative media is a
  separate evidence-acquisition activity. Phase 54 records current absence
  honestly and must not block waiting for it.
- Inter-rater reliability, demographic/statistical sufficiency, device
  calibration, commercial naturalness, and shared review infrastructure require
  separately approved evaluation work.
- Original-pixel composition belongs to Phase 55; visible teeth, sclera, and
  upper-eyelid implementation belongs to Phases 56–57; combined promotion and
  milestone closeout belong to Phase 58.

</deferred>

---

*Phase: 54-rights-approved-evidence-and-eligibility-decisions*
*Context gathered: 2026-07-31*
