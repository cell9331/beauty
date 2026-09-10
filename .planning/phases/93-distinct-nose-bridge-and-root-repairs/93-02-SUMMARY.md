---
phase: 93-distinct-nose-bridge-and-root-repairs
plan: "02"
subsystem: testing
tags: [swiftpm, nose, integer-oracle, frozen-baseline, bounded-evidence]
status: complete
tasks_completed: 2
tasks_total: 2
implementation_attempt: 1
attempt_status: open
requires:
  - phase: 93-01
    provides: Frozen 4/0/0 registration, approved adapter correction and shared attempt 1
provides:
  - Independent checked integer oracle with four passing metric tests
  - Six passing public-facade semantic and lifecycle methods
  - Immutable original-provider baseline with both directions baseline_pass
affects: [93-03, 93-04, 93-05]
tech-stack:
  added: []
  patterns: [literal integer metrics, complete comparison conjunction, exact typed reasons, bounded child capture]
key-files:
  created:
    - BeautySDK/Tests/BeautyCoreTests/NoseSemanticMetricTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-RED.json
  modified:
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-ATTEMPTS.md
    - PLANS.md
    - .planning/STATE.md
key-decisions:
  - Record both original-provider semantic directions as baseline_pass; do not manufacture RED.
  - Follow exact retained raw DeviceRGB and public typed-reason contracts under reviewed amendments.
  - Preserve historical failures 15/18 and shared attempt 1; no new begin or finish.
  - Later plan 93-03 may address independently demonstrated safety/scaling regressions only.
requirements-completed: []
requirements-addressed: [NOSE-01, NOSE-02]
duration: 42min
completed: 2026-09-10
coverage:
  - id: D1
    description: Literal metrics, admission and complete conjunction
    verification:
      - kind: unit
        ref: python3 scripts/check-phase93-nose-repair.py metrics
        status: pass
    human_judgment: false
  - id: D2
    description: Public lifecycle and original-provider semantic baseline
    verification:
      - kind: integration
        ref: python3 scripts/check-phase93-nose-repair.py red
        status: pass
    human_judgment: false
  - id: D3
    description: Immutable fresh baseline and sibling digest binding
    verification:
      - kind: other
        ref: python3 scripts/check-phase93-nose-repair.py freeze-red
        status: pass
    human_judgment: false
---

# Phase 93 Plan 02: Frozen Nose Semantic Baseline Summary

**Both nose directions pass the complete frozen actual-pixel oracle on the original provider and corrected adapter; current lifecycle prerequisites pass and the immutable baseline is bound.**

## Tasks and validation

| Task | Result | Commit |
|---|---|---|
| 93-02-01 — independent metrics and adversarial conjunction | Complete, 4/0/0 | `1c9ffd27` |
| 93-02-02 — public pixels, lifecycle and frozen baseline | Complete after reviewed test-contract corrections | `2ed83f1a`, `a1a961c6`, `ccf4c7de`, `6af5d87f` |

Fresh `python3 scripts/check-phase93-nose-repair.py red` passed, followed by `freeze-red`. The second command consumed current receipts and created the binding without another render.

| Current prerequisite | Discovered | Passed | Failed | Skipped |
|---|---:|---:|---:|---:|
| Registration plus retained adapter regression | 4 | 4 | 0 | 0 |
| Integer metric tests | 4 | 4 | 0 | 0 |
| Public lifecycle methods | 4 | 4 | 0 | 0 |
| Public semantic methods | 2 | 2 | 0 | 0 |

Each required method was discovered exactly once. The gate built current tests before execution, captured children only in bounded memory, and admitted no unexpected failure or skip. All four lifecycle methods now pass: neutral/metadata/orientation/determinism, missing support, serialized valid-invalid-valid recovery, and combined-field protection. Direct/current raw image facades, caps, exact typed reasons, finite metrics, detector counts, final point-count metadata, extent and opaque alpha are covered.

The oracle independently implements checked Int64 floor/floor exclusive rasterization, literal nonintegral bounds/partition membership, bridge Q8 mean difference and root negative Q16 half-centroid separation. Invalid regions, denominators, dimensions, arithmetic overflow and missing/extra comparisons fail admission. Handcrafted positive arrays and exact-threshold cases pass; proxy-only changes, protected leaks, every sibling alias and one-unit threshold violations fail. Handcrafted data establishes oracle mechanics only.

## Actual-pixel baseline

Each source and neutral comparison independently produced the values below. Sibling differences are the minimum across every frozen sibling. Protection reports conservative maxima across both baselines and all applicable groups.

| Direction | Verdict | Comparisons | Changed pixels | Absolute RGB delta | Source/neutral margin | Minimum sibling difference |
|---|---|---:|---:|---:|---:|---:|
| Bridge | baseline_pass | 6 | 858 | 56232 | +563 Q8 | 553 Q8 |
| Root | baseline_pass | 5 | 964 | 92187 | +133 Q16 | 133 Q16 |

Both directions report outside **0/0**, protected nose groups **0/0**, background **0/0**, watermark **0/0**, and repeated-byte status **1**. The bridge remains literal Q8 despite the comparator's Q16 report label; no scaling or threshold adjustment occurred.

All five unchanged slim/wing/tip output digests agree between the two semantic methods and are frozen in `93-RED.json`. Both results are honestly `baseline_pass`, not forced semantic RED. The original provider has not been tuned. Under the plan's explicit passing-baseline branch, later 93-03 work may address independently demonstrated safety/scaling regressions; efficacy tuning merely to manufacture RED is prohibited.

## Immutable bindings

| Artifact | SHA-256 |
|---|---|
| 93-RED.json | 571a87141a7ffcf77e2d5c42c7a9e43edd2ac3510a07751775ef4d09ef234f84 |
| Effective reviewed gate | 873dba5aac09040ff6927dfc8aef90c466f87a297f807cf4d8b34f0ad2c4897e |
| Public test | c09e178d7477d65703160db4a0dd19363cf4242fa9510e24f301c38d674acc18 |
| Independent metric test | cd3d59838345cc2f727b55ffa166807c3e1418fd3a8fca5951395b1e738cd584 |
| Original provider | 0684e2689cd5f3b780a69f13f701339879c3f418691a586205f4dda028ea23c8 |
| Corrected adapter | cf191001ae1245a82b042cc54eaca63aa6b3ba2abeed40e86781bc056eb159d9 |
| Original registration binding | 87d1990da6f2c6780dc2bff37784fcca20962ae88824238508f36e7c8d3a0f81 |
| Original baseline binding | a95d281f619bdef97c85dd6935f10b1b2084bce5d795ae9890981692517f4c31 |

The new immutable record also binds fixture/SPI, registration tests, scoped adapter regression, both test files, reviewed gate and all five sibling digests. Original baseline and registration bytes are unchanged; reviewed hash-linked amendments carry forward only effective gate identities in memory. Current registration, metrics, lifecycle and semantic receipts match the final source identity.

The ledger now has 23 events, exactly one begin and zero finishes. Shared implementation attempt 1 remains open; no budget reset, attempt finish, rollback or plan 93-03 execution occurred. NOSE requirements remain active pending later safety, compatibility, owner synchronization and independent phase review/verification.

## Preserved checkpoint history and deviations

The prior checkpoint summaries/commits and original ledger entries remain historical failures. Neither was rewritten into a passing receipt.

1. **[Rule 1 — authored metadata expectation]** Initial `red` passed registration/metrics and stopped in the first lifecycle method, with 24 failures solely at the named-sRGB assertion. The retained raw CPU geometry contract explicitly uses DeviceRGB; named sRGB belongs to admitted canonical carriers. Parent selected and independently reviewed exact route-specific model/name/component/color-space equality. Fixture, neutral and abstaining output retain named sRGB; emitting raw geometry requires exact DeviceRGB. Pixel extraction remains explicitly named sRGB. Parent committed the correction and precise hash-linked sequence-15 disposition as `a1a961c6`; whitespace follow-up `d2dce950`. No production route or pixel threshold changed.
2. **[Rule 1 — authored redaction expectation]** The next fresh run passed metadata but stopped in missing-support coverage with three scanner assertions. The substring `landmark` incorrectly rejected public enum reason `missingLandmarks`. Parent independently reviewed exact reason-array expectations: usable/neutral empty, missing nose singleton missingLandmarks, and no face singleton noFaceDetected. Missing summaries, wrong/extra/duplicate reasons fail; freeform warning/metric raw-data checks remain intact. Parent committed the test correction and successor binding for exact sequence 18 as `ccf4c7de`.
3. **Evidence discipline:** Sequence 15 and 18 plus their exact digests remain unchanged. Only those reviewed authoring mismatches are excluded from later candidate eligibility; repetitions and all other failures remain blocking. Each resumed `red` freshly ran the unchanged gate prerequisites; no stale receipt was promoted. Parent-reported self-tests were 90/0/0 and 108/0/0, and both independent amendment reviews were clean. Those are amendment evidence, separate from this executor's final live 14-method proof.
4. **State scope:** Only scoped PLANS/STATE progress is updated. Parent-owned dirty frontmatter/position, config, state.json, runtime directories and milestone lock remain preserved and unstaged. Broad SDK state resynchronization would touch that work, so progress is applied as a scoped addition; the parent coordinates ROADMAP and requirement state. No requirement or phase completion is inferred from this plan alone.
5. **Workflow advisory:** Serena was unavailable, so local source/rg tracing was used. Read-count hook pauses reset and allowed continuation. The parent's nonblocking root-owner mapping advisory required no action; existing map state was retained.

Task 1 is test-only oracle construction, with four required GREEN admission/polarity tests. Task 2 retains ordinary XCTest semantic assertions; no expected-failure wrapper or production GREEN implementation step was invented when both original-provider outputs passed.

## Commits and timing

- `1c9ffd27` — independent metric oracle
- `2ed83f1a` — public contracts retained at metadata checkpoint
- `e451eb08` — original metadata checkpoint summary
- `7e88f474` — scoped checkpoint state
- `a1a961c6` — parent metadata contract/amendment
- `d2dce950` — parent review whitespace
- `580cbc8d` — retained missing-support checkpoint ledger
- `ccf4c7de` — parent typed-reason contract/successor amendment
- `6af5d87f` — final passing semantic baseline and immutable binding

Approximately 42 minutes elapsed across execution, parent dispositions and independent amendment reviews, ending with the baseline freeze at 2026-09-10T08:08:04Z. Summary and scoped state completion are committed separately.

## Privacy and limits

No production, fixture, SPI, oracle, threshold or authority changed during final continuation. No raw pixels, geometry, masks, private locators, generated media or child transcripts entered durable evidence. Test accumulators and dictionaries are populated from actual requests/measurements; no success-returning stub remains. No new network, authentication, resource or schema trust boundary was introduced.

This plan proves the registered generated-input baseline only. It makes no dense-field safety, portrait, device, naturalness, commercial or distribution qualification. Later plans and phase-wide independent review remain separate.

## Self-Check: PASSED

All three task-created files and recorded commits exist. The final RED SHA-256, current receipt counts and identities agree; the record contains two baseline_pass verdicts and matching five-sibling digests. Original failure entries remain present. Ledger begins/finishes remain 1/0. No later-plan work or unauthorized file changes are included. This self-check establishes 93-02 completion only.
