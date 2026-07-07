# Phase 28: Face Shape Slice Completion and Documentation Closeout - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-07
**Phase:** 28-Face Shape Slice Completion and Documentation Closeout
**Areas discussed:** Jawline alias handling, Per-tool evidence bar, Status/document closeout

---

## Jawline Alias Handling

### What should Phase 28 lock for `下颌线`?

| Option | Description | Selected |
|--------|-------------|----------|
| Alias to `jawSlim` | Document `下颌线` as the same SDK behavior as `下颌角` for v1.5, with shared tests/output evidence and no new public parameter. | ✓ |
| Future distinct behavior | Keep `下颌线` partial/future until a separate product-neutral SDK parameter and behavior are designed. | |
| Agent decides | Use the smallest evidence-backed interpretation during planning. | |
| Other | Freeform preference. | |

**User's choice:** Alias to `jawSlim`.
**Notes:** This preserves the existing public parameter surface and keeps Phase 28 within v1.5 scope.

### How should the alias be represented in docs and evidence?

| Option | Description | Selected |
|--------|-------------|----------|
| Shared evidence, explicit alias note | Use the same `jawSlim` tests/output evidence for `下颌角` and `下颌线`, but mark `下颌线` as alias-backed in the ledger/docs. | ✓ |
| Separate evidence row only | Keep separate ledger wording for `下颌线`, but do not add separate renderer/test cases. | |
| Agent decides | Planner chooses the cleanest wording. | |
| Other | Freeform preference. | |

**User's choice:** Shared evidence, explicit alias note.
**Notes:** The alias needs explicit wording in `SHAPE_FEATURE_LEDGER.md`, the face-shape branch README, and Phase 28 verification.

### If `jawSlim` evidence passes, how should status promotion work?

| Option | Description | Selected |
|--------|-------------|----------|
| Promote both rows with alias note | Mark both `下颌角` and alias-backed `下颌线` implemented, with `下颌线` clearly labeled as alias-backed by `jawSlim`. | ✓ |
| Promote only `下颌角` | Keep `下颌线` partial even though it aliases `jawSlim`. | |
| Agent decides | Planner applies the most conservative evidence rule. | |
| Other | Freeform preference. | |

**User's choice:** Promote both rows with alias note.
**Notes:** Promotion is conditional on `jawSlim` evidence passing.

### What should Phase 28 explicitly not do for this alias?

| Option | Description | Selected |
|--------|-------------|----------|
| No split behavior now | Do not add a new parameter, new Demo label behavior, entitlement/pro handling, or separate algorithm for `下颌线`. | ✓ |
| Allow planner discretion | Planner may split behavior if implementation looks easy. | |
| Agent decides | Enforce only roadmap boundaries. | |
| Other | Freeform preference. | |

**User's choice:** No split behavior now.
**Notes:** A future distinct `下颌线` behavior is deferred outside v1.5.

---

## Per-Tool Evidence Bar

### What output evidence should Phase 28 require?

| Option | Description | Selected |
|--------|-------------|----------|
| One renderer case per distinct SDK parameter | Add/verify separate cases for `faceSlim`, `faceSmall`, `chinLength`, `faceVShape`, and `jawSlim`, with `下颌线` sharing `jawSlim`. | ✓ |
| Combined case plus tests only | Reuse `faceShapeCombo_0p35` for output evidence and add focused tests for each parameter. | |
| Agent decides | Planner chooses the narrowest evidence set that satisfies requirements. | |
| Other | Freeform preference. | |

**User's choice:** One renderer case per distinct SDK parameter.
**Notes:** `chinLength` is handled further below as bidirectional.

### What should each per-parameter renderer case prove?

| Option | Description | Selected |
|--------|-------------|----------|
| Same dimensions plus geometry-vs-baseline delta | Each case must preserve dimensions and differ from `geometryBaseline_noop` above the watermark band on usable portrait fixtures. | ✓ |
| File presence and dimensions only | No per-tool delta threshold, because Phase 27 already proved geometry changes. | |
| Agent decides | Planner sets the helper thresholds. | |
| Other | Freeform preference. | |

**User's choice:** Same dimensions plus geometry-vs-baseline delta.
**Notes:** This carries forward Phase 27's helper strategy but applies it per tool.

### How should Phase 28 handle degradation and safety evidence?

| Option | Description | Selected |
|--------|-------------|----------|
| Focused tests per behavior group | Prove caps, missing contour/no-face degradation, signed `chinLength`, combined weakening, and redaction through XCTest/scans; renderer output does not need every degradation variant. | ✓ |
| Renderer case for every degradation path | Add output files for no-face/missing/stale/reused per tool. | |
| Existing Phase 27 degradation evidence is enough | Only update docs/ledgers. | |
| Other | Freeform preference. | |

**User's choice:** Focused tests per behavior group.
**Notes:** Renderer output should stay focused on happy-path per-tool visible output, while tests/scans cover safety and degradation.

### Should `chinLength` need one renderer case or two?

| Option | Description | Selected |
|--------|-------------|----------|
| Two directions | Test/output both `chinLength` positive and negative, because `下巴长短` is bidirectional. | ✓ |
| Positive only | Enough to prove the public parameter renders. | |
| Agent decides | Planner chooses based on existing tests/helper behavior. | |
| Other | Freeform preference. | |

**User's choice:** Two directions.
**Notes:** Phase 28 should represent both long and short chin directions.

---

## Status/Document Closeout

### If all five distinct SDK parameters pass evidence, what should be promoted?

| Option | Description | Selected |
|--------|-------------|----------|
| Promote the six scoped `脸型` rows only | Mark `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线` implemented; keep the rest of `脸型` future/partial. | ✓ |
| Promote the whole `脸型` branch | Treat branch status as implemented after these scoped tools pass. | |
| Agent decides | Planner chooses conservative promotion. | |
| Other | Freeform preference. | |

**User's choice:** Promote the six scoped `脸型` rows only.
**Notes:** Unscoped `脸型` tools remain out of Phase 28 completion.

### Should `FEATURE_MATRIX.md` branch-level `脸型` status change?

| Option | Description | Selected |
|--------|-------------|----------|
| Stay `partial`, with scoped completion note | Because only six existing-parameter tools are complete and other `脸型` tools remain future. | ✓ |
| Change branch to `implemented` | Because all v1.5-scoped `脸型` tools are done. | |
| Agent decides | Planner chooses based on docs semantics. | |
| Other | Freeform preference. | |

**User's choice:** Stay `partial`, with scoped completion note.
**Notes:** Branch-level matrix semantics remain conservative.

### Which docs must Phase 28 synchronize after evidence passes?

| Option | Description | Selected |
|--------|-------------|----------|
| Full scoped sync | Update `SHAPE_FEATURE_LEDGER.md`, face-shape branch README, branch-level `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, root docs/quality ledger, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, and `PLANS.md`. | ✓ |
| Minimal docs only | Update only `SHAPE_FEATURE_LEDGER.md`, verification, and `PLANS.md`. | |
| Agent decides | Planner picks needed docs based on actual changes. | |
| Other | Freeform preference. | |

**User's choice:** Full scoped sync.
**Notes:** Synchronization is evidence-gated; docs move only after command-backed evidence exists.

### What claims should Phase 28 explicitly avoid?

| Option | Description | Selected |
|--------|-------------|----------|
| No UI/commercial/parity claims | No Demo UI completion, commercial visual quality, device parity, broad Meitu parity, new geometry groups, or release-readiness claims. | ✓ |
| Allow branch-level marketing wording | Ok to say `脸型` is complete in product terms. | |
| Agent decides | Enforce root docs only. | |
| Other | Freeform preference. | |

**User's choice:** No UI/commercial/parity claims.
**Notes:** The evidence can claim scoped SDK-core status only.

---

## the agent's Discretion

- Exact renderer case IDs, moderate strengths, helper filenames, threshold values, test filenames, scan shapes, and final conservative wording are left to the planner.

## Deferred Ideas

- A distinct `下颌线` SDK behavior or product-neutral parameter can be considered in a future phase after v1.5.
- Whole-branch `脸型` completion remains future because other `脸型` tools still need separate design/evidence.
