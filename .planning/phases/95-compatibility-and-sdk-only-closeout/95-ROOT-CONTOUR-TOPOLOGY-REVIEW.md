---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-22T06:37:09Z
depth: standard
files_reviewed: 2
files_reviewed_list:
  - scripts/phase95-root-contour-topology.py
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-CONTOUR-TOPOLOGY-SPEC.md
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
approval_scope: one-invocation-two-source-only-topology-diagnostic-runs
source_registration: false
measurement_admission: false
portrait_acceptance: false
---

# Declared contour topology diagnostic review

## Narrative Findings (AI reviewer)

No unresolved BLOCKER or WARNING was found in the scoped diagnostic successor.
The independent reviewer read both files, compared the successor with the
previously reviewed open-path diagnostic and traced the reused source-admission
and bounded transport dependencies. No private source or output was read.

The installed macOS SDK was independently inspected:
VNFaceLandmarks.h:82-84 describes pointsClassification as how to interpret region
points; VNTypes.h:106-110 defines disconnected, openPath and closedPath.
The properties are available from macOS 13. This supports consulting the actual
classification rather than assuming that every region is an open sequence.
It does not supply a semantic root-side label or localization error bound.

The loop adds exactly one last-to-first segment only for closedPath. openPath
retains consecutive segments only. disconnected and the unknown-default branch
throw unavailable before producing support counts. No topology is chosen by
effect output, endpoint proximity or whether closing improves paired counts.
Original sixteen rows, clipping, midpoint and count partition are retained.
Horizontal overlaps and excess crossings remain ambiguous, not qualified pairs.

The historical paired0 observation describes the open-sequence convention.
It is not a complete conclusion about the SDK-declared topology. Respecting a
declared closed path is materially different from inventing a closing edge for
an open path. However, a closed polygon's cap or connecting edge is not thereby
a visible root side. Even paired16 cannot establish structural ownership,
anatomical precision, eye exclusion, correspondence or effectiveness.

## Verification

- Independently ran the generated Swift self-test with temporary module caches:
  23 checks, exit 0. Its entry point calls contourTests, not sourceOnly.
  The prior ten checks remain; thirteen additions cover topology dispatch,
  disconnected rejection, the open-versus-closed rectangle and all eight cyclic
  start/orientation variants of that closed rectangle.
- Both open and closed aggregate protocol positive controls accepted.
- Twenty-five malformed protocol cases rejected, including old status, missing
  or invalid topology, changed identities, promoted qualification flags,
  noninteger/boolean or invalid counts, invalid revision, duplicate JSON keys,
  trailing records and nonzero child exit.
- A mocked inspect positive control invoked exactly two child calls.
- Eight review/stability mutations rejected: five invalid review receipts before
  any child call, changed count partition, changed topology between runs and
  post-run snapshot drift.
- Final --review-inputs recomputation matched all fifteen bound files.

Only fixed generated counts, reasons and hashes are retained. No raw child
transcripts, private locators, image data or geometry were persisted.

## Bounded execution permission

The adjacent independent JSON permits one invocation of the unchanged reviewed
--inspect-source entry point, containing exactly the existing two source-only
calls, using the already-established local Vision execution environment outside
the managed sandbox, subject to platform execution controls. The earlier
generated environment diagnosis is contextual evidence reported by the executing
agent; no new environment or private-image test was run in this review.

Both results and final snapshots must agree. A rejection, mismatch or input
change supplies no successful observation and no permission for automatic
retries. Prior failed invocations and open-convention observations remain
unaltered. This successor has its own diagnostic identity and cannot upgrade
old records.

The receipt grants no structural registration, measurement amendment, contour
cohort selection, effect PASS, NOSE-02 acceptance or milestone completion.
The source may still have no qualifying paired support.

## Exact reviewed snapshot

| File | SHA-256 |
| --- | --- |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROI-REGISTRATION.json | ef066fbe62a8385c137666ea0213284244b05199a9df0a81c8998bed07e4c43d |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-CONTOUR-TOPOLOGY-SPEC.md | 58992f3043e68c10625da74fe2140606a3fd94e1b94343aa0602a0ec2717da7c |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-DEFINITION-FREEZE-v2.json | 2035543bcfcec79729415cb4e9a8d5ddf30355c177a84a6d0b3e842ce63dbfe2 |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-IMPLEMENTATION-REVIEW-v3.md | 947645b74934d89898af44c4644b96ff39f628c4eeaa64bdaa1bfb27323402be |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-SPEC-v2.md | 168394eb55445d770e72fa1de65546ee0c1ba1cceb15721032f14bdaa9ce426b |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-REGISTRAR-SPEC-v2.md | 93d37da3b4a17c6b5e5087ee54744bb67c5c8dd1ea009704be0e54f1f28db8db |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-REGISTRAR-SPEC-v3.md | a7151d0d49268a961cf35e7d4c7e1568ed6e7087f419dfa4cd5a49f6484bde46 |
| BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift | 9634829b8630a6b06aa25fcb0f54e73a7c5229a4497eaacf9fcadcb71c1bfeb4 |
| scripts/compare-face-feature-batches.swift | d7c7ccd293d4adb53cc2ea521d676cc6f51acd5215ae3a020862d332d1cfca26 |
| scripts/face-feature-batch-manifest.json | 5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e |
| scripts/phase95-root-anatomy-coverage.py | d4c421e8b5f7f450ef1e3d0f58308fb2a2d3a90c8084302ed26d391341700943 |
| scripts/phase95-root-contour-topology.py | 50c78fd8135335b1a383ba8378da92241d726b1a615b64b734bb721f5cd6b687 |
| scripts/phase95-root-edge-metric.swift | 7100a47cc3176035cb097016b252f00be477307f0d75fde932bffa869027287b |
| scripts/phase95-root-registration-adapter.swift | c19c2cd1384f1cb9ee8200bff9968759be25e02abb18b4bf9e98de6e7c38c4f0 |
| scripts/phase95-root-registration.py | 99a4edb93b9487ce70d13b411f55c12bc766a4175777fc8fdf551750e5d5fe13 |

_Independent reviewer: closeout-review-20260922. Diagnostic permission only._
