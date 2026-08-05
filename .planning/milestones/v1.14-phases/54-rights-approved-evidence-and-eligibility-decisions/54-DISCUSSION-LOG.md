# Phase 54: Rights-Approved Evidence and Eligibility Decisions - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution
> agents. Decisions are captured in CONTEXT.md.

**Date:** 2026-07-31
**Phase:** 54-rights-approved-evidence-and-eligibility-decisions
**Areas discussed:** Evidence bundle completeness, blinded review and
persistence, independent feature decisions, upper-eyelid design qualification

---

## Evidence bundle completeness

| Option | Description | Selected |
| --- | --- | --- |
| Strict complete-bundle gate | Require approved real positive and negative rows with complete predeclared asset triples. | ✓ |
| Allow partial bundle | Let one polarity or incomplete assets contribute to readiness. | |
| Borrow sibling evidence | Use another feature's evidence to fill a missing row. | |

**Auto choice:** Strict complete-bundle gate.
**Notes:** Recommended because it directly enforces EVID-01/EVID-02 and keeps
current evidence shortages honest.

## Blinded review and persistence

| Option | Description | Selected |
| --- | --- | --- |
| Privacy-minimized structured export | Persist opaque IDs, fixed judgments, decisions, reason codes, and aggregates only. | ✓ |
| Path-bearing local report | Persist local media and rights paths for convenience. | |
| Freeform review record | Allow reviewer prose and identity in durable output. | |

**Auto choice:** Privacy-minimized structured export.
**Notes:** Reuses the validated Spike 006 model and satisfies EVID-03/EVID-04.

## Independent feature decisions

| Option | Description | Selected |
| --- | --- | --- |
| Independent closed gates | Close only the feature with missing evidence and continue the milestone. | ✓ |
| Wait for all evidence | Block Phase 54 until every candidate has a full bundle. | |
| Use mechanics substitutes | Count synthetic/spike fixtures toward product readiness. | |

**Auto choice:** Independent closed gates.
**Notes:** Current genuine positives are absent. Closure is a valid deliverable,
not an environment failure, and cannot affect siblings.

## Upper-eyelid design qualification

| Option | Description | Selected |
| --- | --- | --- |
| Close evidence and design gates | Keep the invalidated warp rejected and the partial tone experiment unqualified. | ✓ |
| Promote tone experiment | Treat mechanics texture preservation as a credible product design. | |
| Alias existing eye geometry | Reuse eye/brow movement as `去脂`. | |

**Auto choice:** Close evidence and design gates.
**Notes:** LID-01 requires both genuine semantic evidence and a credible
independent non-warp design; neither exists.

## the agent's Discretion

- Implementation shape for the pure validator, enums, deterministic tests,
  static local reviewer, and aggregate decision ledger.
- Opaque ID and allowlisted reason-code spelling.

## Deferred Ideas

- Acquire additional rights-approved genuine positive/negative fixtures.
- Design an inter-rater/statistical evaluation plan if the feature gates are
  reopened later.
