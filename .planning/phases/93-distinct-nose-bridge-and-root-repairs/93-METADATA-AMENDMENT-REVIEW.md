---
phase: 93-distinct-nose-bridge-and-root-repairs
reviewed: 2026-09-10T07:55:08Z
depth: standard
scope: metadata-contract-amendment-only
files_reviewed: 5
files_reviewed_list:
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift
  - scripts/check-phase93-nose-repair.py
  - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-METADATA-DISPOSITION.md
  - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-METADATA-AMENDMENT.json
  - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-02-PLAN.md
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
code_review_status: passed
metadata_amendment_review_status: passed
blockers: 0
warnings: 0
---

# Phase 93 Metadata Amendment Review

## Narrative Findings (AI reviewer)

No unresolved **BLOCKER** or **WARNING** was established in the submitted amendment. The requested review concerns are resolved for the exact hashes below. This is independent amendment review, not whole-phase acceptance or runtime/semantic validation.

### Resolved: explicit retained route contract

[BeautyEngineNoseRepairTests.swift](/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift:223) requires an explicit expected color at each helper call, checks the expectation against declared request activity/support, and checks the source as named sRGB. It does not infer expected color from returned metadata or diagnostics. The direct facade, orientation, recovery, neutral, sibling and combined-field calls also declare their expectations.

At lines 264–289, missing color space fails, and model, name, component count and `CFEqual` must match either named sRGB or `CGColorSpaceCreateDeviceRGB()`. Arbitrary RGB is not accepted. CIContext working/output space and bitmap extraction remain the same explicit named sRGB; RGBA8, extent and opaque-alpha assertions remain intact.

Source tracing confirms the distinction: `BeautyEngine.processResult` selects the legacy route when local-retouch admission is empty; its backend request has no canonical carrier. `BeautyCPUBackend` selects the raw color pipeline, which calls the DeviceRGB geometry overload. The canonical-carrier overload names sRGB separately. See `BeautyEngine.swift:140–157,294–315`, `BeautyCPUBackend.swift:23–36`, `BeautyColorEffectPipeline.swift:109–141`, and `BeautyGeometryEffectPipeline.swift:43–88`.

This matches `DESIGN.md:320`, CONTEXT D-04/D-06/D-09 and the parent-selected code/tests-before-plan correction. No production route or color policy was changed.

### Resolved: no concealed scoring relaxation

The Swift diff changes metadata expectations and adds source/route checks. Source and neutral comparisons, all sibling/peer rows, metric evaluation, repeated-byte equality, cap behavior, missing support, recovery, facade/orientation checks and combined protection thresholds remain present. Semantic assertions retain their ordinary failure behavior; the protection assertion remains separate.

The oracle, fixture, SPI, registration tests, scoped adapter regression, corrected adapter, original provider, comparator and manifest are byte-identical to HEAD. The authority check also passed all 186 frozen-file bindings and the two fixture/SPI bindings. No ROI, integer metric, extraction, source recipe or signal/protection threshold changed.

### Resolved: gate carry-forward does not refresh old receipts

[scripts/check-phase93-nose-repair.py](/Users/yakangwang/codes/beauty/scripts/check-phase93-nose-repair.py:243) validates the metadata amendment against actual baseline, prior amendment, registration, gate and amended-test hashes before constructing effective views. Comparing complete objects confirmed that the baseline changes only `gate`; registration changes only `gate` and `immutable[GATE]`. All other fields are identical. Original binding files remain byte-identical to HEAD.

The amendment's prior gate and prior public-test hashes also match their HEAD versions and the historical failure identity. Existing registration/metric receipts still reject as `stale_receipt`. `latest` does not rewrite receipt identities, and `freeze_red` requires current registration, metrics and lifecycle receipts. Synthetic gate-only and test-only stale identities could not pass finish; stale prerequisites could not freeze RED.

### Resolved: exact historical exclusion, unchanged attempt budget

At [gate lines 263–306](/Users/yakangwang/codes/beauty/scripts/check-phase93-nose-repair.py:263), admission requires sequence 15, its canonical event digest, red/assertion-failure classification, the exact first lifecycle method, empty semantic assertion IDs, exact discovery/failure counts and old gate/test identities. The filter removes only the matching sequence **and** digest from finish eligibility. It neither edits history nor manufactures a passed receipt.

In-memory finish probes accepted a synthetic complete current receipt set after excluding this exact event. Repeated assertion, protection, child, hash and aggregate failures still blocked finish. An altered sequence-15 failure also blocked. Rebinding the event digest could not admit a different method, category, kind, semantic assertion list or count shape.

The actual ledger has 15 events, one begin at sequence 8 and zero finishes; sequence 15 remains its original failure. Begin 1, premature begin 2 and begin 3 all rejected in memory. The two-attempt ceiling is unchanged. No RED binding exists.

## Evidence and limits

- Gate self-test: **90 passed / 0 failed / 0 skipped**, executed in an isolated in-memory module.
- Additional reviewer probes: **35 checks**, comprising 34 rejection cases and one positive synthetic finish; no disk writes or Swift children. A fresh module was used after the self-test.
- Actual authority function: passed, with evidence-writing functions disabled; no command-dispatch failure handler was invoked.
- Sixteen supporting source/authority/history files compared byte-exact with HEAD. The original baseline, registration, gate amendment, ledger and 93-02-SUMMARY remain historical records.
- Scoped `git diff --check`: passed. Reviewed files are not ignored; no `.codexignore` exists.
- Read AGENTS/PLANS, the project skill, D-04/D-06/D-09, the retained DESIGN contract, original binding/ledger records, appended plan correction and historical checkpoint. Serena was unavailable; direct source tracing was used.
- No Swift build/test, rendering, ledger-appending gate command, attempt, rollback or commit was run by this reviewer. The parent's Swift build was reported in progress and is not independently certified here. Fresh lifecycle and semantic execution remains required before RED binding or subsequent plan admission.

## SHA-256 bindings

Paths below are repository-relative; phase-local filenames refer to this directory. These are file/event hashes only, with no image, geometry or transcript payload.

| Artifact | SHA-256 |
|---|---|
| Amended gate | e48549d814d1e16927c4a1481f18a12fe95fb32806891e005bdfee8afba9cc59 |
| Amended public test | 2ae92c94ab62300ba5e9e64a7ef4369c47fc6dc3b429b5d8a246ebb6a6865f0e |
| 93-METADATA-AMENDMENT.json | 7a97f17a353ee0811f43045db7da6f64be8b1138a5ad98029f4324da206b0854 |
| 93-METADATA-DISPOSITION.md | 4c3ecfc55e5d2c8349395aeaba998a3243e55abf4f251327fef58a70fc38195d |
| 93-02-PLAN.md | c0ea60ea1698f0cad7be4b62c74a3e9fa1e794db73b0f45fd4800d662059f877 |
| Original 93-BASELINE.json | a95d281f619bdef97c85dd6935f10b1b2084bce5d795ae9890981692517f4c31 |
| Original 93-REGISTRATION.json | 87d1990da6f2c6780dc2bff37784fcca20962ae88824238508f36e7c8d3a0f81 |
| Original 93-GATE-AMENDMENT.json | ae74dd7320b88c7b8a8c61afc73c0ba3b5f5219e69830234c08736c981cba5ca |
| Original 93-ATTEMPTS.md | b3ecbaea2285aa72a29fc42493a3fef774ffcacdffe0c20af19884bd8e40f33c |
| Sequence-15 canonical event | b9153b1dde878d5e2f759f09ea45a13729260e373883ded2dd4ad16f55e73d26 |
| Historical 93-02-SUMMARY.md | 27c1b0fbb213d6bb1b24f375956c2573d2ec344d82bcb52ae6fec5789f09cc79 |
| Previous gate | fcee37289aeba5d657179e2d5a6c02f1caf33a3c514d81887c59b6688a9778e0 |
| Previous public test | dcd2ce940f28f38a2ab398e8a764047fd928187cd340b6992e086a34ac4d3870 |
| NoseSemanticMetricTests.swift | cd3d59838345cc2f727b55ffa166807c3e1418fd3a8fca5951395b1e738cd584 |
| NoseRepairFixture.swift | b75cfa4c22adf12df423fa78c2b5f7af0c5ba10950dcdbc229a95b90faccc7ff |
| BeautyEngineTestingSupport.swift | 834153e717956c63c3f3b62c0ff11af6ad5bd02655486a8e684286d6db51bec8 |
| Corrected BeautyFaceGeometryAdapter.swift | cf191001ae1245a82b042cc54eaca63aa6b3ba2abeed40e86781bc056eb159d9 |
| Original NoseWarpProvider.swift | 0684e2689cd5f3b780a69f13f701339879c3f418691a586205f4dda028ea23c8 |
| scripts/compare-face-feature-batches.swift | 4d51f4727646ae88460ce5d17f9d661fa63a461da1dc6e15e58afa06803a9ffa |
| scripts/face-feature-batch-manifest.json | 5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e |
| 93-CONTEXT.md | 92f9778177350d1e23f76ce7491f76e6715d2670b9f3e810335130095c691891 |
| DESIGN.md | 081af8e973f4f142711bcc92252bc8bf61ef945d88f9e57dc9be9952759b3a8c |

_Reviewer: independent gsd-code-reviewer. Only this review artifact is written._
