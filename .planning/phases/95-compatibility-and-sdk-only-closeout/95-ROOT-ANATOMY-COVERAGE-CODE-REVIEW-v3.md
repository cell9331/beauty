---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-15T06:40:07Z
depth: standard
reviewer_agent_id: 01a0a3ab-0e69-7953-b5c4-a939ec1d0fcc
files_reviewed: 2
files_reviewed_list:
  - BeautySDK/Tests/BeautyEffectsTests/Phase95GeneratedChild.swift
  - BeautySDK/Tests/BeautyEffectsTests/Phase95GeneratedChildTests.swift
files_reviewed_sha256:
  BeautySDK/Tests/BeautyEffectsTests/Phase95GeneratedChild.swift: ad9511cda2b156076f99fb35e00577c2d2c35b820e9d5cdbe2cb237245e49b93
  BeautySDK/Tests/BeautyEffectsTests/Phase95GeneratedChildTests.swift: 5715d9fb33169f0e6271fe48ea1290f23839745dbffc0d7a0cb685c91e3fa58a
unchanged_hash_checks:
  scripts/phase95-root-anatomy-coverage.py: d4c421e8b5f7f450ef1e3d0f58308fb2a2d3a90c8084302ed26d391341700943
  BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift: 069ac744d1ca2c350f7ef499a85192f5e028c5b6983f9945b35a95e19ab3e99c
  .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-ANATOMY-COVERAGE-SPEC.md: f5f9a5414e7cf15bb9c6da24c65b7d4f5c522d79319d0b93574c871125c5a0a4
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
resolved_prior_findings:
  - WR-03
approval_latch_created: true
---

# Phase 95: Root Anatomy Coverage Code Review v3

## Narrative Findings (AI reviewer)

No BLOCKER or WARNING findings in the two-file repair delta. WR-03 is resolved: the tests now distinguish failure to enter a scenario, an incorrect outcome category, and failure to stop acknowledged processes. The previously cleared coverage diagnostic and root integration were checked by hash only, as requested. This review does not reassess or approve root anatomy, root effectiveness or portrait scoring.

## WR-03 disposition

The observation clears its bounded output and spawned leader identity at the beginning of every run, including rejected-input runs. The helper records the actual spawned PID; scenario records must identify that group, and the leader record must identify the group leader. Roles and counts are checked before process state is credited.

The TERM-ignore scenario acknowledges after installing its handler. The stopped-descendant scenario acknowledges only after the parent confirms the stopped state with `waitpid(WUNTRACED)`. Forked scenarios use a pipe handshake after the descendant installs its handler and acknowledges setup. Both the held-output-pipe timeout and the successful leader exit with descendant stdout closed are exercised. Expected timeout/success categories are explicit; other errors fail.

The live-state predicate uses `sysctl` and treats unknown state as still executing. A one-second observation deadline distinguishes executing processes from absent processes or zombies. Each scenario's independent test defer kills its spawned group and, if necessary, its spawned leader even when assertions fail. Process identities and bounded child output remain ephemeral; this report contains only aggregate evidence.

The helper's early cleanup can recover its fixed readiness prefix with bounded nonblocking reads, and group ownership discovered during signalling is retained for the later KILL. The existing input/output caps, exact success bytes, monotonic deadlines and bounded TERM/reaping observations remain intact. No unbounded `waitUntilExit` was reintroduced.

## Independent reviewer evidence

### Actual current-code SwiftPM run

`PYTHONOPTIMIZE=1 swift test --package-path BeautySDK --filter 'Phase95GeneratedChildTests'`

The reviewer executed the exact current four transport tests: **4 executed, 0 failures, 0 skips**, including the final observation-reset line. XCTest took 6.448 seconds; rebuild took 18.63 seconds; the supervised command finished in 25.96 seconds, exit 0. Its independent 120-second outer deadline did not fire. The observer found zero live owned processes before outer cleanup. This is separate from the main agent's reported runs. Python optimization was enabled; Swift used its debug configuration.

### Independently supervised cleanup mutations

Composed the current helper and test bodies in memory. Replaced XCTest assertion functions with equivalent predicate counters so failures could be inspected without aborting the scenario or bypassing its original test-owned defer. The scenario setup, parser, `sysctl` live-state predicate and test-owned cleanup remained the submitted code. These are predicate-level mutation experiments, not additional SwiftPM test runs.

| In-memory helper variant | Predicate checks | Predicate failures | Live-state failures | Live owned processes before outer cleanup |
| --- | ---: | ---: | ---: | ---: |
| Current bytes | 43 | 0 | 0 | 0 |
| Omit helper's SIGKILL call | 43 | 3 | 3 | 0 |
| Signal only leader instead of group | 43 | 2 | 2 | 0 |

Each variant had its own independent 35-second outer deadline and owned-process-tree observer. No outer deadline fired; no compiler diagnostics were emitted. The mutation harnesses deliberately collected failed predicates and exited normally, so their exit 0 is not a passing verdict for mutated cleanup.

Both requested mutations were detected specifically by the new live-state assertions. Zero surviving owned processes **before** outer cleanup demonstrates that the unchanged test-owned defer prevented stranding even when helper cleanup was broken. The independent supervisors retained force-cleanup fallbacks.

### Scope and preservation

- Read only the two current delta files for narrative review; hash-checked the unchanged diagnostic, integration and spec against v2 identities. Reused the prior project privacy/fixture context.
- Did not rerun the five root tests, nine-test selection, prior exhaustive mathematics, coverage self-tests or private/source execution.
- Recomputed the exact 14-entry admitted dependency snapshot by the existing driver's snapshot function and byte hashes. No source portrait, private fixture path, source registration or scoring entry was invoked.
- Preserved v1 at SHA256 `5e85b462abddfc7b46117e9fcce4ec6f255185d9d04ba1b006bd6e14021aa313` and v2 at `92a70863ee10731178421049f5fb990a1ccd37074151cb3137118c7e171a9510`.
- Only this new review and the new requested coverage latch were written. No repository source edits, persisted process identities/transcripts, commits, installations, external AI or additional agents.

## Coverage-only latch

Created `95-ROOT-ANATOMY-COVERAGE-REVIEW.json` with the exact schema `phase95-root-anatomy-coverage-review-v1`, status `pass`, reviewer ID `01a0a3ab-0e69-7953-b5c4-a939ec1d0fcc`, empty findings and the 14-entry snapshot below. The narrower two-file review scope is retained in this report; it is not incorrectly substituted for the diagnostic's required dependency map.

This latch permits only the existing bounded aggregate source-coverage diagnostic. It grants **no source structural registration, anatomical-boundary qualification, portrait scoring, root acceptance or milestone-completion credit**. No live source inspection was performed by this reviewer.

```yaml
.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROI-REGISTRATION.json: ef066fbe62a8385c137666ea0213284244b05199a9df0a81c8998bed07e4c43d
.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-ANATOMY-COVERAGE-SPEC.md: f5f9a5414e7cf15bb9c6da24c65b7d4f5c522d79319d0b93574c871125c5a0a4
.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-DEFINITION-FREEZE-v2.json: 2035543bcfcec79729415cb4e9a8d5ddf30355c177a84a6d0b3e842ce63dbfe2
.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-IMPLEMENTATION-REVIEW-v3.md: 947645b74934d89898af44c4644b96ff39f628c4eeaa64bdaa1bfb27323402be
.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-SPEC-v2.md: 168394eb55445d770e72fa1de65546ee0c1ba1cceb15721032f14bdaa9ce426b
.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-REGISTRAR-SPEC-v2.md: 93d37da3b4a17c6b5e5087ee54744bb67c5c8dd1ea009704be0e54f1f28db8db
.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-REGISTRAR-SPEC-v3.md: a7151d0d49268a961cf35e7d4c7e1568ed6e7087f419dfa4cd5a49f6484bde46
BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift: 9634829b8630a6b06aa25fcb0f54e73a7c5229a4497eaacf9fcadcb71c1bfeb4
scripts/compare-face-feature-batches.swift: d7c7ccd293d4adb53cc2ea521d676cc6f51acd5215ae3a020862d332d1cfca26
scripts/face-feature-batch-manifest.json: 5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e
scripts/phase95-root-anatomy-coverage.py: d4c421e8b5f7f450ef1e3d0f58308fb2a2d3a90c8084302ed26d391341700943
scripts/phase95-root-edge-metric.swift: 7100a47cc3176035cb097016b252f00be477307f0d75fde932bffa869027287b
scripts/phase95-root-registration-adapter.swift: c19c2cd1384f1cb9ee8200bff9968759be25e02abb18b4bf9e98de6e7c38c4f0
scripts/phase95-root-registration.py: 99a4edb93b9487ce70d13b411f55c12bc766a4175777fc8fdf551750e5d5fe13
```

_Reviewer: 01a0a3ab-0e69-7953-b5c4-a939ec1d0fcc (gsd-code-reviewer)_
