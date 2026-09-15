---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-15T06:28:16Z
depth: standard
reviewer_agent_id: 01a0a3ab-0e69-7953-b5c4-a939ec1d0fcc
files_reviewed: 4
files_reviewed_list:
  - scripts/phase95-root-anatomy-coverage.py
  - BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/Phase95GeneratedChild.swift
  - BeautySDK/Tests/BeautyEffectsTests/Phase95GeneratedChildTests.swift
files_reviewed_sha256:
  scripts/phase95-root-anatomy-coverage.py: d4c421e8b5f7f450ef1e3d0f58308fb2a2d3a90c8084302ed26d391341700943
  BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift: 069ac744d1ca2c350f7ef499a85192f5e028c5b6983f9945b35a95e19ab3e99c
  BeautySDK/Tests/BeautyEffectsTests/Phase95GeneratedChild.swift: ea657202e12e863d31c33cbf1d1884ec4ebad8e1a31278699fb72f281e142567
  BeautySDK/Tests/BeautyEffectsTests/Phase95GeneratedChildTests.swift: 8e42dcaf748ec575f098b1bb5ed0442f0fe1b2474b9e24ee68a8f5160fb9814d
findings:
  critical: 0
  warning: 1
  info: 0
  total: 1
status: issues_found
source_diagnostic_findings: 0
approval_latch_created: false
resolved_prior_findings:
  - WR-01
  - WR-02
---

# Phase 95: Root Anatomy Coverage Code Review v2

## Narrative Findings (AI reviewer)

The two v1 implementation defects are resolved. One new test-reliability finding remains: the cleanup regression's assertions accept a helper that leaves children alive. This is a defect in the test's verification, not a claim that the submitted helper currently leaks those processes. No defect was found in the unchanged source-coverage diagnostic. Because the four-file review has a finding, no coverage approval JSON was created.

### WR-03: WARNING — Cleanup test can pass while unresponsive children remain alive

**File:** `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyEffectsTests/Phase95GeneratedChildTests.swift:25-32`

**Issue:** The test checks only that `run` throws some error and returns in less than four seconds. It never verifies that the TERM-ignore/STOP/fork scenario actually became active, or that its child and descendant stopped running. Removing `signalOwned(SIGKILL)` still satisfies these assertions: the helper's bounded two-second observation loop expires, the original timeout is thrown, and the test passes with unresponsive processes left behind. An early launch/transport error can also satisfy the same assertions without exercising the intended scenario. This leaves the central termination and descendant-cleanup guarantee unprotected by the new regression test.

**Evidence:** In a standalone, in-memory copy only, omitted the single SIGKILL call from the submitted helper. Extracted the cleanup test's exact loop body and reproduced the semantics of its two assertion functions without XCTest. All six predicates passed (`checks=6 failures=0`), while an independent process-tree observer found two still-live owned processes after the helper returned. A 25-second outer supervisor then killed the owned groups and reaped its direct process. This is a predicate-level mutation reproduction, not a claim that a mutated SwiftPM suite was executed. Two earlier attempts to load standalone XCTest lacked its usable Swift overlay and supplied no test evidence. No repository source was changed.

**Fix:** Add a generated scenario acknowledgement after the ignore handler, stop setup or descendant creation is established; retain only ephemeral process/group identities. Check the expected timeout category, then independently assert that the acknowledged child and descendants are no longer executing within a bounded grace period. Include the normal-leader-exit case whose descendant closes stdout, as well as the timeout case whose descendant holds the pipe open. Keep an independent outer deadline and supervisor cleanup so a failing regression cannot strand processes. The test must fail when KILL is omitted or when cleanup targets only the leader.

## Disposition of v1 findings

- **WR-01 resolved:** `Phase95GeneratedChild.isSuccess` compares complete canonical byte records. Type coercions, duplicate fields and trailing data cannot match either success record. Both integration children use this exact check; neither parses success through Foundation's permissive numeric/boolean bridging.
- **WR-02 resolved in the submitted helper:** input and output use nonblocking file descriptors, input writes suppress SIGPIPE, and the loop bounds payload/output sizes and uses monotonic elapsed time. The fixed Python preamble establishes a process group before its acknowledgement. Cleanup signals that group, observes a 0.2-second TERM grace, sends KILL even after leader exit, and observes Foundation reaping for at most two seconds. There is no `waitUntilExit`. The new WR-03 concerns the missing regression assertions for that behavior.

## Independent reviewer execution

- Read all four complete scoped files. Continued the previously loaded project privacy/fixture rules and `spike-findings-beauty` review context. No source portrait, fixture location or private media was inspected.
- The first reviewer-selected SwiftPM run used a 180-second outer deadline, rebuilt in 64.64 seconds, and exceeded the remaining envelope. Its supervisor killed the owned process groups. It is an incomplete run, not passing test evidence and not proof of an implementation timeout defect.
- The subsequent completed reviewer command was `PYTHONOPTIMIZE=1 swift test --skip-build --package-path BeautySDK --filter 'Phase95GeneratedChildTests|Phase95RootImageFormationTests'`, using the completed debug build. Under an independent 360-second outer supervisor it executed **9 tests, 0 failures, 0 skips**: four transport tests and five root-image tests. XCTest elapsed time was 199.97 seconds; the outer command finished in 202.38 seconds, exit 0, without firing its deadline. Its process-tree observer found zero live owned processes afterward. This is the reviewer's execution, separate from the main agent's reported 9/0/0. `PYTHONOPTIMIZE=1` describes the Python mode, not a Swift release build.
- A separate 25-second supervised probe ran the actual helper bytes against TERM-ignore, STOP, unresponsive 200,000-byte input, fork/held-pipe, successful-leader/forked-descendant, full-duplex 4,096-byte output, 4,097-byte overflow, nonzero exit and broken-input conditions (the unresponsive-input condition shared the TERM-ignore scenario). All eight call outcomes matched their expected acceptance/rejection. Three scenario processes acknowledged themselves through ephemeral localhost datagrams; none remained live afterward. These acknowledgements carried only generated process identities and were not persisted.
- Because the short fork/held-pipe scenario could time out before setup, independently repeated that scenario with a 1.5-second helper deadline and a 10-second outer deadline. Both parent and TERM-ignoring descendant acknowledged setup; the helper rejected, and neither acknowledged process remained live afterward. The outer deadline did not fire. This establishes current descendant cleanup separately from the defective repository regression assertions.
- Independently reran the unchanged diagnostic with `python3 -B -O scripts/phase95-root-anatomy-coverage.py --self-test`: **6 generated coverage checks and 20 admission checks**. Rechecked generated entry assembly: no `sourceOnly()` entry call and no source structural-registration call are present in the self-test dispatch.
- Repeated missing/stale review tests with review bytes mocked and both source assembly and execution replaced by forbidden-call sentinels. Both rejected before assembly/execution. No live `--inspect-source` command was executed.
- Recomputed the actual 14-entry source diagnostic snapshot below. The diagnostic, spec and pinned admission dependencies retain their v1 identities. The original source-only/aggregate/privacy/error/double-run/snapshot/transport assessment is unchanged; this does not authorize source registration, anatomical qualification, scoring or portrait acceptance. The generated boundary rows, conservative interval calculation and finite `m/M` admission in the root integration remain unchanged from v1.
- No full test suite, private fixtures, source execution, external AI, installations, commits or additional agents were used. All mutation work was composed in memory. Only this new report was written; no approval latch was created. The v1 report remains byte-identical at SHA256 `5e85b462abddfc7b46117e9fcce4ec6f255185d9d04ba1b006bd6e14021aa313`.

## Exact diagnostic dependency snapshot

This is review evidence, not an approval receipt. It is the actual 14-entry `{**adapter.snapshot(), DRIVER: sha(read(DRIVER)), SELF: sha(read(SELF)), SPEC: sha(read(SPEC))}` map.

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
