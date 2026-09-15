---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-15T06:12:00Z
depth: standard
reviewer_agent_id: 01a0a3ab-0e69-7953-b5c4-a939ec1d0fcc
files_reviewed: 2
files_reviewed_list:
  - scripts/phase95-root-anatomy-coverage.py
  - BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift
files_reviewed_sha256:
  scripts/phase95-root-anatomy-coverage.py: d4c421e8b5f7f450ef1e3d0f58308fb2a2d3a90c8084302ed26d391341700943
  BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift: 9f7cb74d3a8377e6921eff0a91bba97a1b62f8faeaf7585053bb0cf684855f79
findings:
  critical: 0
  warning: 2
  info: 0
  total: 2
status: issues_found
source_diagnostic_findings: 0
approval_latch_created: false
---

# Phase 95: Root Anatomy Coverage Code Review

## Narrative Findings (AI reviewer)

Two reproducible test-reliability defects remain in the Swift integration harness. No defect was found in the coverage diagnostic's reviewed source-admission, entry-point, aggregate-output or identity boundaries. The two-file review is nevertheless `issues_found`; no `95-ROOT-ANATOMY-COVERAGE-REVIEW.json` was created, following the explicit instruction not to autoapprove with findings.

### WR-01: WARNING — Swift aggregate checks accept malformed success records

**File:** `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift:129-141`

**Issue:** `JSONSerialization` represents JSON numbers and booleans through Foundation bridging. Consequently, `as? Int` and `as? Bool` do not enforce the intended JSON types. The exact success checks accept both `{"structural_pairs":true,"passed":1}` and `{"structural_pairs":1.0,"passed":1.0}`. The parser also collapses duplicate keys before the key-set check: on this host, `{"structural_pairs":1,"passed":true,"passed":false}` passes. A malformed or conflicting child summary can therefore supply the success assertion for the interval measurement. The preceding red-channel assertions do not establish that the interval computation itself passed.

**Evidence:** Ran standalone Foundation probes reproducing the parsing and three final assertions from these lines. Both type-substitution payloads and the conflicting duplicate payload were accepted. Only generated aggregate JSON was used; no measurement helper or source file was modified.

**Fix:** Enforce the JSON wire types and reject duplicate keys before collapsing objects. The existing comparator's `strictJSONInteger` / `strictJSONBoolean` functions demonstrate the required Core Foundation boolean distinction; pair equivalent checks with duplicate-key rejection. Alternatively, for this tiny generated protocol, require one exact canonical success record from the child and separately validate the fixed rejection shape. Add malformed-type and duplicate-field rejection controls that remain effective under `PYTHONOPTIMIZE=1`.

### WR-02: WARNING — Timeout cleanup can block indefinitely

**File:** `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift:119-129`

**Issue:** Both cleanup paths call `child.terminate()` followed by an unbounded `child.waitUntilExit()`. The 300-second XCTest expectation only bounds the preceding expectation wait; it does not bound this cleanup. If a child ignores SIGTERM or is stopped, the test can hang after reporting its timeout, preventing the test suite from finishing. This is a lifecycle robustness defect in the test harness, distinct from the coverage diagnostic's already bounded process-group transport.

**Evidence:** An in-memory Swift reproducer used the same `Process.terminate(); Process.waitUntilExit()` sequence after a generated Python child acknowledged startup and installed a SIGTERM-ignore handler. Cleanup exceeded an independent four-second deadline. The reviewer supervisor then sent SIGKILL to its newly owned process group and reaped it. No private input or repository modification was involved.

**Fix:** Give termination a bounded grace period, escalate to SIGKILL, and bound the final reap. Own and clean descendants if the harness permits subprocesses. Keep input delivery and output draining within the same deadline so transport cannot strand the supervising test. Exercise the cleanup with generated unresponsive-child and output-overflow controls under an independent supervisor deadline.

## Verification and scope limits

- Read both complete scoped files and the required coverage specification / forward-integration note. Read relevant project privacy, reliability, design and quality contracts and applied `spike-findings-beauty` rules. The referenced bootstrap was found under `.agents/gsd-core`; the configured reviewer skill map is empty. Serena and dedicated Read/Write tools were unavailable; filesystem tools supplied source inspection.
- Independently ran `python3 -B scripts/phase95-root-anatomy-coverage.py --self-test` and its `-O` variant. Each returned exactly 6 generated arithmetic checks and 20 admission checks.
- Four independent entry/gate checks established that the generated self-test has no `RootSourceAdapter.sourceOnly()` call, the coverage source has exactly one such entry call, and missing/stale review records reject before code assembly or child execution. For the negative review tests, source-code assembly and execution were replaced by forbidden-call sentinels, environment lookup was stubbed, and review bytes were mocked. No live inspection entry was executed.
- Independently exercised 59 malformed-output, failing-exit, final-snapshot-drift and environment-drift rejections. Drift tests used generated child responses and verified that no success record was printed before rejection.
- Ran only `PYTHONOPTIMIZE=1 swift test --package-path BeautySDK --filter 'Phase95RootImageFormationTests.testForwardLocalization'`: 2 executed, 0 failures, 0 skips. Row 143's positive case and row 164's unchanged-boundary negative case both passed. These ordinary passes do not resolve the malformed-protocol or unresponsive-child findings.
- Traced `HorizontalInwardWarpSafety.accepts` and the current canonical sampler. For these fixed generated rows, ordered inward linear cones establish the ideal inverse-map lower secant bound `1 - 0.8`; the sum of the two per-cone absolute slope bounds gives the upper bound `1 + 0.8 + 0.8`. The current local supports avoid image-edge clamping. All 18 centers per source boundary are passed to correspondence and forward localization, with no favorable sample dropping; bracketing and conservative interval endpoints govern the width decision. This is finite generated applicability evidence, not a universal production point oracle or a newly certified floating-point/error model.
- Inspected the pinned driver's source assembly, snapshot, decoder and transport. Coverage assembly cuts at the unique marker before the source structural-registration call. The retained source-only admission reconstructs the original contracts; neither the new structural registrar nor a scoring entry is called. Coverage uses the frozen integer row formula and bounded finite support extrema. Output is restricted to the original identities, fixed counts/revision and false/zero qualification flags. Live mode requires the exact snapshot latch before execution, compares two complete records, rechecks source bytes inside each child and rechecks definition/environment identities before publication. Unexpected failures remain generic; native diagnostics stay within the driver's drained, bounded child streams.
- Did not execute live `--inspect-source`, source registration, portrait scoring, a full suite, private fixture tests, external AI, installations or additional agents. No private media or fixture locations were inspected. Previously reviewed helper mathematics was read only as needed for integration contracts; the prior exhaustive mathematical systems were not repeated.
- Only this new review artifact was written. Source files, prior reviews and existing dirty changes were preserved. No commit was made. The absent approval latch is not permission to perform a source run.

## Exact dependency and definition identities

The following is the actual 14-entry `{**adapter.snapshot(), DRIVER: sha(read(DRIVER)), SELF: sha(read(SELF)), SPEC: sha(read(SPEC))}` snapshot inspected during review. It is recorded as review evidence only, not an approval receipt.

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

Additional integration context hashes:

```yaml
scripts/phase95-root-forward-span.py: 0cfac9277c2efdbc47ec65f120c2a43f659d0a8d279e716940ed17051660fa2d
scripts/phase95-root-nonlinear-probe.py: 8be3b6a27d3dab808ffad4dd516ce820e0c1efd16d26f54fdcc4bfd3f11ccbdf
scripts/phase95-root-affine-motion-probe.py: 0d99954325288c2b7da43cb4dcb90412decb7aeb441fcc82ae605d4edfe8f06c
.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-FORWARD-INTEGRATION.md: 06e0eb43ffd343e1a0f53b0dee8ec6b87bc15ad9d041f06db75ea75bbe622d2b
```

_Reviewer: 01a0a3ab-0e69-7953-b5c4-a939ec1d0fcc (gsd-code-reviewer)_
