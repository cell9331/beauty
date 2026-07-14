# Phase 20: Core Module Closeout - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-30
**Phase:** 20-Core Module Closeout
**Areas discussed:** Editor-shell closeout strictness, Visible-evidence threshold, Ledger/root-contract sync depth

---

## Editor-Shell Closeout Strictness

| Option | Description | Selected |
|--------|-------------|----------|
| Blueprint + root acceptance | Tighten `docs/meitu-function-blueprint/features/editor-shell/**`, then reconcile `FRONTEND.md` and `PRODUCT_SENSE.md` only where Phase 20 needs explicit acceptance/evidence wording. | ✓ |
| Blueprint only | Keep closeout focused on editor-shell blueprint docs and avoid root docs unless scans prove inconsistency. | |
| Broad root sweep | Re-read and reconcile all root contracts as part of closeout. | |

**User's choice:** Blueprint + root acceptance.
**Notes:** Root contracts are touched only where Phase 20 needs explicit editor acceptance or evidence wording.

| Option | Description | Selected |
|--------|-------------|----------|
| Document + verify existing behavior | No new SwiftUI screens or interaction rewrites; cite existing Demo code/tests and only fix docs or clear inconsistencies. | ✓ |
| Allow small app-state fixes | Still no new screens, but planner may patch missing cancel/confirm, compare/debug, slider, or snapshot behavior if closeout finds a real gap. | |
| Docs only | Do not touch Demo code/tests under any condition; record any behavior gap as future work. | |

**User's choice:** Document + verify existing behavior.
**Notes:** Editor-shell support is treated as existing app-side behavior, not a place for new Demo behavior.

| Option | Description | Selected |
|--------|-------------|----------|
| Hard boundary | Editor shell owns routing, chrome, rails, sliders, compare/debug, cancel/confirm, and snapshots; SDK owns public parameters, processing, result warnings/metrics, and resources through the public facade. | ✓ |
| Interface contract | Same boundary plus a handoff table showing public SDK values the Demo may read/write for each editor concern. | |
| Minimal wording | Keep current tables and only remove wording that sounds SDK-owned. | |

**User's choice:** Hard boundary.
**Notes:** Phase 20 should phrase ownership as a strict Demo-vs-SDK boundary.

| Option | Description | Selected |
|--------|-------------|----------|
| Existing tests + scope scans | Cite/rerun existing Demo view-state/import-boundary tests where practical, plus scans for no new SwiftUI screens, no internal SDK imports, and no SDK ownership creep. | ✓ |
| Documentation scans only | Verify editor docs and root docs are consistent, but do not rerun Demo tests. | |
| Full Demo verification | Run the broader Demo simulator test/build path in addition to docs and scans. | |

**User's choice:** Existing tests + scope scans.
**Notes:** Full Demo verification is not required unless later changes justify it.

---

## Visible-Evidence Threshold

| Option | Description | Selected |
|--------|-------------|----------|
| Full SDK + current renderer matrix | Run `swift test --package-path BeautySDK`, rerun all current visible renderer cases, dimension/watermark checks, and factual visual observations. | ✓ |
| Focused evidence only | Rerun focused skin/color/filter renderer cases and relevant tests, but skip the full SDK suite unless failures point there. | |
| Audit prior evidence | Do not rerun renderer outputs; only verify Phase 16/18/19 evidence and docs are consistent. | |

**User's choice:** Full SDK + current renderer matrix.
**Notes:** Phase 20 closeout should produce fresh full SDK and renderer evidence.

| Option | Description | Selected |
|--------|-------------|----------|
| Keep them explicitly partial/blocked | Verify tests and docs, but state that provider/resolver evidence is not saved-image visual completion until facade detection plus geometry render output exists. | ✓ |
| Accept provider evidence as closeout | Treat shaping as complete for v1.3 if provider/resolver tests pass, while still noting missing renderer output. | |
| Try to add geometry renderer cases | Let Phase 20 attempt public facade geometry saved-image output if it looks small. | |

**User's choice:** Keep them explicitly partial/blocked.
**Notes:** Shaping branches retain honest partial/blocked status.

| Option | Description | Selected |
|--------|-------------|----------|
| All current built-in cases | Run every case currently exposed by `BeautyExampleRenderer`; do not add new cases. | ✓ |
| Skin cases only | Since Phase 18 owns skin visible output, rerun only the Basic skin cases. | |
| Representative subset | Run one or two representative cases, then rely on full SDK tests for the rest. | |

**User's choice:** All current built-in cases.
**Notes:** Current renderer cases are the fixed matrix for Phase 20.

| Option | Description | Selected |
|--------|-------------|----------|
| Factual observation only | Confirm non-empty output, same dimensions, readable watermark, watermark not covering face, and visible natural changes where expected; no production-quality or market-grade claims. | ✓ |
| Stronger visual judgment | Include subjective pass/fail notes about whether the beauty effect looks good enough. | |
| Mechanical checks only | Use dimensions/watermark/file checks and avoid visual observation wording. | |

**User's choice:** Factual observation only.
**Notes:** Visual notes should remain factual and limited.

---

## Ledger / Root-Contract Sync Depth

| Option | Description | Selected |
|--------|-------------|----------|
| Traceability closeout sweep | Update/check `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, blueprint docs, plus only root contracts that need wording for editor acceptance or evidence limitations. | ✓ |
| Planning ledgers only | Only update/check `.planning/*` and `PLANS.md`; keep blueprint/root docs unchanged unless tests fail. | |
| Everything broad | Reconcile all root docs, blueprint docs, planning ledgers, and historical docs as part of closeout. | |

**User's choice:** Traceability closeout sweep.
**Notes:** Root contracts are touched only when needed.

| Option | Description | Selected |
|--------|-------------|----------|
| Explicit limitations table | Close satisfied v1.3 requirements while preserving limitations/deferred table for geometry saved output, future parameters, release QA, and deferred Meitu product areas. | ✓ |
| Only requirement statuses | Mark pending requirements complete where evidence passes and rely on existing docs for limitations. | |
| Keep some requirements pending | Leave `MOD-04` or editor items pending if any limitation remains, even if requirement wording is satisfied. | |

**User's choice:** Explicit limitations table.
**Notes:** Limitations should stay visible at v1.3 close.

| Option | Description | Selected |
|--------|-------------|----------|
| Do not normalize historical docs | Only update current authority docs; record stale historical-doc issues as deferred/tech debt unless they directly misroute current agents. | ✓ |
| Patch obvious stale lines | Allow small edits in historical docs if they contradict v1.3 closeout. | |
| Full docs cleanup | Normalize historical docs so the whole repository reads current. | |

**User's choice:** Do not normalize historical docs.
**Notes:** Historical cleanup is out of scope unless it affects current routing.

| Option | Description | Selected |
|--------|-------------|----------|
| Evidence + scans + ledger checks | Full SDK tests, current renderer matrix, dimension/watermark/factual visual notes, Demo editor contract tests/scans where practical, no-new-UI/API/import scans, requirement traceability, and state/roadmap consistency. | ✓ |
| Tests and renderer only | Full SDK tests plus current renderer matrix are enough; planning consistency can be checked manually. | |
| Ledger checks only | Since prior phases tested implementation, closeout should only verify documentation/state consistency. | |

**User's choice:** Evidence + scans + ledger checks.
**Notes:** Final closeout requires tests, renderer evidence, scans, and ledger consistency.

## the agent's Discretion

- Choose exact plan split, scan commands, test filters, and wording updates.
- Keep Phase 20 conservative and avoid expanding behavior.

## Deferred Ideas

- Public facade geometry saved-image output.
- New public beauty parameters and advanced Meitu subtools.
- Release-readiness QA and automated visual diffing.
- Deferred Meitu product areas.
- Historical docs cleanup unless stale wording misroutes current agents.
