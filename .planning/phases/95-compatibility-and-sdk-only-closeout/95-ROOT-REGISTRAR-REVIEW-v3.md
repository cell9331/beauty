---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-14T04:02:18.447001+00:00
reviewer_agent_id: 01a09e12-0426-7051-aa20-c29287255f54
depth: standard
review_scope: narrow-v3-transport-and-identity-delta
base_commit: 2a96d8f40e50a8a46c549fd8bd915fe149f637c7
files_reviewed: 2
files_reviewed_list:
  - scripts/phase95-root-registration.py
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-REGISTRAR-SPEC-v3.md
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
source_only_registration_approved: true
source_measurability_established: false
portrait_scoring_approved: false
phase95_completion_approved: false
---

# Phase 95 registrar transport review v3

## Narrative Findings (AI reviewer)

No unresolved BLOCKER or WARNING found in the transport and identity delta against `2a96d8f4`. Approve the exact snapshot below for source-only registration through the v3 receipt gate. This independent review does not reuse the old v2 receipt as approval of changed code.

The observed `ambiguous_structure` remains a real source measurement rejection. Transport approval does not waive it or establish source measurability, anatomical correspondence, candidate/neutral/sibling scoring, effect acceptance, downstream measurement-consumer approval, or Phase 95 completion. Generic mathematics and the Swift adapter retain their prior independent approval and were not reopened.

## Transport and identity assessment

- `scripts/phase95-root-registration.py:91-112`: separate stdout/stderr pipes are registered together; each read contributes to the same 16 MiB total before stdout is retained. stderr bytes are discarded in memory and cannot supply a protocol record. EOF unregisters only its own stream, so closing stdout does not bypass later stderr accounting. The existing wall/monotonic timeout and 1 MiB input bound remain.
- `scripts/phase95-root-registration.py:113-129`: the existing owned-process-group TERM/KILL cleanup and writer join remain; both output pipes are now closed in the finally path.
- `scripts/phase95-root-registration.py:131-141`: unchanged strict parsing rejects extra stdout. Fixed typed rejection requires exit 2 and the exact rejection shape; success-shaped JSON with a nonzero exit remains rejected. stderr cannot change either outcome.
- `scripts/phase95-root-registration.py:19-30,58-69,227-243`: the original v2 spec is now a fixed pin and the new v3 spec joins the complete twelve-entry snapshot. The required schema and receipt path both advance to v3. Full file equality remains mandatory; the source path still stops at its first failed registration and only compares a second result after the first succeeds.
- `95-ROOT-REGISTRAR-SPEC-v3.md:3-40`: the successor accurately limits the correction to transport, preserves the original spec/history and forbids treating the earlier protocol failure as evidence that source ambiguity is solved.

## Executed validation

| Check | Result |
| --- | --- |
| `python3 -B scripts/phase95-root-registration.py --self-test` | Exit 0: 8 adapter, 22 admission, 7 transport checks. |
| Independent finite generated probes | 12 assertions passed using the unchanged execute/checked_result/validate_review functions; only Popen's child command was substituted in memory with generated Python for transport isolation. |
| Boundary and channel probes | Exact combined 16 MiB accepted; one extra stderr byte rejected; stdout-first and stderr-first EOF handled; valid-looking stderr alone rejected; two stdout JSON records rejected. |
| Deadline and cleanup probes | Both wall and monotonic expiry independently injected; typed timeout rejection verified. All seven generated child processes/groups ended, both pipes closed, and no writer threads remained. |
| Receipt attacks | Original v2 receipt rejected; v2 schema with the current full file map also rejected. |
| Snapshot identity | Twelve entries unchanged across probes. All ten prior snapshot entries other than the driver matched the v2 receipt, including unchanged adapter, math, v2 spec and freeze. |
| Receipt validation | Companion receipt validated with the unchanged current `validate_review()` against current `snapshot()`; no validation logic was edited. |

Self-test transport cases include generated stderr with valid JSON, typed ambiguity with stderr, extra stdout, nonzero exit, and stdout/stderr/combined overflow. Only aggregate test results are retained here.

## Exact reviewed snapshot

| File | SHA-256 |
| --- | --- |
| `scripts/phase95-root-edge-metric.swift` | `7100a47cc3176035cb097016b252f00be477307f0d75fde932bffa869027287b` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-SPEC-v2.md` | `168394eb55445d770e72fa1de65546ee0c1ba1cceb15721032f14bdaa9ce426b` |
| `BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift` | `9634829b8630a6b06aa25fcb0f54e73a7c5229a4497eaacf9fcadcb71c1bfeb4` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-IMPLEMENTATION-REVIEW-v3.md` | `947645b74934d89898af44c4644b96ff39f628c4eeaa64bdaa1bfb27323402be` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROI-REGISTRATION.json` | `ef066fbe62a8385c137666ea0213284244b05199a9df0a81c8998bed07e4c43d` |
| `scripts/face-feature-batch-manifest.json` | `5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e` |
| `scripts/compare-face-feature-batches.swift` | `d7c7ccd293d4adb53cc2ea521d676cc6f51acd5215ae3a020862d332d1cfca26` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-REGISTRAR-SPEC-v2.md` | `93d37da3b4a17c6b5e5087ee54744bb67c5c8dd1ea009704be0e54f1f28db8db` |
| `scripts/phase95-root-registration.py` | `99a4edb93b9487ce70d13b411f55c12bc766a4175777fc8fdf551750e5d5fe13` |
| `scripts/phase95-root-registration-adapter.swift` | `c19c2cd1384f1cb9ee8200bff9968759be25e02abb18b4bf9e98de6e7c38c4f0` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-DEFINITION-FREEZE-v2.json` | `2035543bcfcec79729415cb4e9a8d5ddf30355c177a84a6d0b3e842ce63dbfe2` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-REGISTRAR-SPEC-v3.md` | `a7151d0d49268a961cf35e7d4c7e1568ed6e7087f419dfa4cd5a49f6484bde46` |

## Scope, privacy and handoff

Read current AGENTS.md, PLANS Active, relevant SECURITY/RELIABILITY/QUALITY owner sections, original v2 spec, and both preceding v2 review artifacts as immutable context. Their git diff against `2a96d8f4` was empty. Neither review target is gitignored; no .codexignore exists. Serena/Read/Write tools were unavailable in this session, so local read-only commands and the explicitly requested apply_patch were used.

Applied gsd-code-review's scoped adversarial review and spike-findings-beauty's request-local privacy and aggregate evidence boundaries. The installed bootstrap at the .agents/gsd-core path returned no additional configured reviewer skills. The project skill inventory contained only spike-findings-beauty.

No register-source execution, private input/output access, source diagnostic, clean65, generic-math rerun or Swift adapter re-review was performed. No image, raw child transcript, raw coordinates, metric output or candidate score was persisted. Only this report and the companion v3 JSON receipt were created; source, old evidence, owner documents and unrelated dirty-tree changes were preserved. No commit. All reviewer-started tests and probes ended.

