---
phase: 92-signed-eyebrow-head-spacing
plan: "05"
status: blocked-attempt-2
semantic_status: not-run-after-provider-block
implementation_attempt: 2
subsystem: eyebrow-geometry-repair
tags: [swift, testing-spi, actual-pixels, terminal-attempt-block]

requires:
  - phase: 92-signed-eyebrow-head-spacing
    provides: Independently reviewed final-attempt plan and reconciled shared attempt count
provides:
  - Correctly registered aggregate-only BROW-01 public-pixel oracle
  - Terminal provider-formula failure evidence with byte-exact production rollback
affects: [BROW-01, owner-repair-defer-stop-decision]

key-decisions:
  - "Keep the aligned public-pixel oracle because it converts the prior zero-signal ambiguity into nonzero, deterministic, protected evidence."
  - "Reject the final production candidate at the first provider gate because its radius exceeded the unchanged generic head-spacing safety ceiling."
  - "Prohibit attempt three and require an explicit owner choice among repair, defer, or stop."

duration: 55min
completed: 2026-09-08
---

# Phase 92 Plan 05: Final Attempt Blocked Summary

**The aligned oracle exposed a valid nonzero RED baseline, but the second and final production candidate violated an unchanged provider safety ceiling; production was restored byte-for-byte and Phase 92 is blocked for owner disposition.**

## Terminal Outcome

- **Status:** blocked-attempt-2
- **Failure class:** `provider_formula`
- **Shared implementation attempt:** 2 of 2
- **Attempt three:** prohibited
- **Required owner choice:** `repair`, `defer`, or `stop`

The semantic pixel suite was not run against the final candidate because the ordered gate stopped at the provider failure. This is not recorded as a semantic failure or success.

## Reviewed Plan and Attempt Accounting

- Final-attempt planning commit: `a04a0d2`.
- Shared-attempt reconciliation commit: `7444f40`.
- Independent plan review: PASS after one BLOCK-and-revision cycle.
- The review confirmed the corrected coordinate registration, one fixed candidate, immutable public-pixel and manifest thresholds, exact rollback, aggregate-only evidence, and terminal no-third-attempt routing.

## Corrected Oracle Boundary

- Aligned-contract commit: `85c7aa7`.
- Testing-SPI post-edit blob: `da5ad1f4560795b5705d68c308b0c8526423be2b`.
- Public repair-test post-edit blob: `101a3ff34e8e746bf4fe6e99232ea5f02b5b45a0`.
- Provider-test post-edit blob: `83f4f48e4af5150efb4596eddbe77b1f7b3cac9b`.
- The frozen manifest and comparator remained byte-identical.

With the restored provider, the corrected public-pixel suite discovered exactly three methods. Its two auxiliary safety/lifecycle methods passed, while its semantic method remained controlled RED with seven intended assertions and zero unexpected failures.

### Corrected RED fixed aggregates

| Aggregate | Positive | Negative |
| --- | ---: | ---: |
| Target changed pixels versus source | 1,417 | 1,446 |
| Target RGB delta versus source | 56,802 | 56,776 |
| Target changed pixels versus neutral | 1,417 | 1,446 |
| Target RGB delta versus neutral | 56,802 | 56,776 |
| Signed source/neutral gap Q16 | 0 / 0 | -2 / -2 |

- Opposite-sign distinction was `2` Q16.
- Cross-family distinctions were `0`, `20`, `2`, and `18` Q16.
- Outside, outer-anchor, eye, background, and watermark maxima were all `0 / 0` changed pixels / RGB delta.
- Valid-left and valid-right unilateral changes were `708` and `709`; both rejected-peer changes were `0`.
- Valid recovery changed `1,417` target pixels; recovered bytes were equal and the invalid middle output was source-equal.
- Neutral identity, metadata, alpha, extent, determinism, provider-empty behavior, request recovery, and redaction remained green.

The revised two-method provider contract also remained controlled RED before the final candidate: one lifecycle/safety method passed and the formula method failed only its expected carrier, displacement, radius, and support predicates.

## Final Candidate and Blocking Failure

- Candidate commit: `c5db3c3`.
- Candidate provider blob: `3c327b6e5fc001c03143b7209e0eb0432f8fa80b`.
- Revert commit: `3a4bcb8`.
- Restored provider blob: `124946d79d380fe7e2eb14a36b3686ebdc1580a3`.

The reviewed candidate retained inner-half progress carriers and the fixed signed displacement, enlarged its tapered nominal support, and used the reviewed outward-envelope clearance. Provider discovery found exactly 16 tests. Fifteen passed; the unchanged generic safety test failed one assertion because head-spacing radius is still contractually capped at `0.045 × face width`, while the final candidate's endpoint nominal formula can reach `0.060 × face width` before its geometry clearance cap.

The plan authorized updating only the focused attempt-two formula expectations. It did not authorize weakening or replacing this generic safety ceiling. The failure therefore blocked immediately; no formula edit, threshold change, or pixel-suite run followed.

## Restored State

- The production provider hash exactly matches the pre-attempt blob.
- The aligned Testing-SPI support and reviewed RED tests remain tracked.
- The combined repair inventory still discovers exactly five methods and exits nonzero in the restored state with 71 intended assertion failures and zero unexpected failures: seven public semantic failures and 64 provider-formula failures.
- The public RED baseline retains nonzero bilateral, unilateral, and recovery signal, exact peer protection, deterministic lifecycle behavior, and aggregate redaction.

## Security, Privacy, and Scope

- Durable evidence contains only test counts, bounded signal/delta values, Q16 margins, hashes, commits, statuses, and named failure classes.
- No raw pixels, masks, eyebrow geometry, private fixture identifiers or locators, generated media, renderer reports, or transcripts were persisted.
- No public production API, package target, manifest row, comparator, runner, shared backend, shader, UI/Demo, model, data, weight, or external dependency changed.
- No live portrait, real-device, milestone-wide no-skip, commercial-quality, packaging, shipping, launch, release-readiness, or distribution claim was made.

## Owner Decision Required

- `repair`: authorize a new milestone or explicitly override the Phase 92 two-attempt ceiling with a newly scoped, independently reviewed repair contract.
- `defer`: keep the restored production behavior and aligned RED evidence, record BROW-01 as deferred, and advance only after updating the project ledger and roadmap.
- `stop`: leave Phase 92 blocked and make no further workflow changes.

Auto mode cannot select among these outcomes. Plans 92-03 and 92-04 must not execute unless a newly authorized repair later succeeds.

## Self-Check: PASSED

- The candidate and revert commits exist.
- The provider pre/restored blob identity is exact.
- The corrected oracle emits nonzero fixed aggregates and the restored five-test inventory remains controlled RED.
- No third candidate, threshold drift, generated media, or report artifact exists.

---
*Phase: 92-signed-eyebrow-head-spacing*
*Completed: 2026-09-08*
