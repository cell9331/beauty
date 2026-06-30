# Phase 21: Baseline Audit and Quality Ledger Refresh - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-30
**Phase:** 21-baseline-audit-and-quality-ledger-refresh
**Areas discussed:** Baseline evidence bar, Debt triage policy, Stale map cleanup boundary, Hardware/tooling blocker rules

---

## Baseline Evidence Bar

| Option | Description | Selected |
| --- | --- | --- |
| Run full baseline sweep | Actually run SDK tests, Demo `xcodebuild` availability checks, `BeautyExampleRenderer` build/run, import/privacy scans; failures become reproducible blockers. | ✓ |
| Inventory only | Only document commands, existing evidence, and risks without running baseline commands in Phase 21. | |
| Focused smoke only | Run low-cost checks such as SDK tests, key scans, and `xcodebuild -list`; leave simulator tests, renderer runs, and long checks to later phases. | |

**User's choice:** Run full baseline sweep.
**Notes:** Phase 21 baseline should be evidence-first. Failures are acceptable only when exact command, environment, failure summary, impact, and blocker classification are recorded.

---

## Debt Triage Policy

| Option | Description | Selected |
| --- | --- | --- |
| Triage and route | Decide whether TD-005, TD-008, TD-009, and TD-010 are routed to Phase 22-25, deferred, or blocked; do not fix them in Phase 21. | ✓ |
| Fix quick wins now | Fix small debt immediately if it appears easy, such as docs status or privacy manifest assessment. | |
| Promote all into v1.4 | Route all four debt items into v1.4 later phases unless hardware/tooling is explicitly blocked. | |

**User's choice:** Triage and route.
**Notes:** Phase 21 remains audit/baseline work. Later phases own fixes and evidence production.

---

## Stale Map Cleanup Boundary

| Option | Description | Selected |
| --- | --- | --- |
| Flag stale, defer remap | Record `.planning/codebase/*` maps as stale and defer formal remap to a later explicit task or closeout candidate. | ✓ |
| Refresh relevant maps now | Refresh `TESTING.md`, `CONCERNS.md`, `CONVENTIONS.md`, and similar maps during Phase 21. | |
| Ignore maps for v1.4 | Avoid using `.planning/codebase` maps entirely without recording a specific stale-map debt. | |

**User's choice:** Flag stale, defer remap.
**Notes:** Phase 21 should not rewrite codebase maps. Current source, tests, root docs, and current `.planning` artifacts override stale maps.

---

## Hardware/Tooling Blocker Rules

| Option | Description | Selected |
| --- | --- | --- |
| Reproducible blocker only | Exact command, environment, failure output summary, impact, and next step are required. | ✓ |
| Protocol is enough | A future manual/hardware protocol is enough even if no current command was attempted. | |
| Block phase on missing tooling | If key device/tooling is unavailable, Phase 21 remains incomplete until the environment is fixed. | |

**User's choice:** Reproducible blocker only.
**Notes:** Vague local-environment notes do not satisfy Phase 21. Missing hardware/tooling should be classified and routed without overclaiming pass status.

---

## the agent's Discretion

- The planner may choose command order and audit artifact shape.
- The planner may group evidence into one audit document or focused sections.
- The planner should prefer exact commands and scoped scans over broad narrative.

## Deferred Ideas

- Formal refresh of `.planning/codebase/*` maps is deferred.
- Implementation/fixing of TD-005, TD-008, TD-009, and TD-010 is deferred to routed later phases.
- Automated Demo visual evidence, performance gates, renderer regression hardening, and privacy/resource closeout remain in Phases 22-25.
