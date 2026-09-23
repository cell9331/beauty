---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-22T06:48:53Z
depth: standard
files_reviewed: 2
files_reviewed_list:
  - scripts/phase95-root-contour-sides.py
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-CONTOUR-SIDES-SPEC.md
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
approval_scope: one-invocation-two-source-only-lateral-support-diagnostic-runs
source_registration: false
measurement_admission: false
portrait_acceptance: false
---

# Declared contour lateral-support review

## Narrative Findings (AI reviewer)

No unresolved BLOCKER or WARNING was found in the scoped source-only successor.
The independent reviewer read both files and traced the previously reviewed
topology, source-admission and bounded transport behavior. No implementation
or historical record was modified and no private image was accessed.

Each original segment supplies a lateral label only when both endpoints lie
strictly on the corresponding side of the unchanged midpoint. Crossing the
midpoint or touching it yields label zero. All geometrically coincident
intersections remain subject to incident-label agreement; once disagreement
produces zero, a later lateral label cannot restore support. The count requires
both the left and right crossing to have their corresponding labels.
This rule applies equally to every segment, including the SDK-declared
last-to-first edge; there is no special favorable treatment of that edge.

The geometric paired/ambiguous/unsupported partition remains sixteen.
side_supported_rows and cap_dependent_rows are nonnegative integers whose sum
must equal paired_rows. Strict protocol validation enforces both identities,
the original source/contracts hashes, actual open/closed enum and false
qualification flags. The latter cap-dependent name denotes failure of this
specific lateral-support rule, including incident-label conflict; it is not an
independent anatomical classification of a physical cap.

The diagnostic is a conservative geometric feasibility test. Its success
cannot identify root anatomy, establish a width cohort, calibrate detector
error or prove pixel correspondence. Its failure cannot prove the source image
has no root or that the production effect is ineffective. Previous three-pair
topology observations retain their original meaning.

## Independent verification

- Independently ran all 34 final generated Swift checks with temporary module caches:
  exit 0. The entry point invokes contourTests rather than sourceOnly.
- Added in-memory generated checks against the actual Swift CORE: 30 cases
  across cyclic starts and both orientations. They cover a lateral/non-lateral
  shared vertex, repeated coincident incidents ensuring zero remains absorbing,
  and compatible same-side incidents that preserve positive support.
  All returned their independently specified aggregate counts.
- Six protocol positive controls covered open/closed topology and all-cap,
  mixed and fully lateral paired cohorts.
- Thirty-seven protocol mutations rejected, including noninteger/boolean,
  negative, excessive or missing new counters, disagreement between the two
  partitions, wrong identities, promoted qualification, invalid topology,
  duplicate JSON keys, trailing records and failed child exit.
- Mocked inspect invoked exactly two children on its positive control.
  Eight invalid-review/stability cases rejected: five before any child call,
  changed side/cap partition, changed topology and final snapshot drift.
- Final --review-inputs recomputation matched all fifteen bound input hashes.

Before final delivery, the author added two incident-conflict regression cases
and advanced the generated count from 32 to 34 without changing diagnostic
logic. The reviewer inspected that delta and reran the final Swift self-test;
the new count is accepted and a stale 32-check record is rejected. This final
report and receipt bind the 34-check version, before any authorized source run.

Only fixed aggregate test counts, reasons and hashes are retained. Independent
incident probes were compiled and run in memory; no generated source file,
raw child transcript, private geometry or image was persisted.

## Bounded permission and limits

The adjacent independent JSON authorizes one invocation of the unchanged
--inspect-source entry point, containing its two source-only child calls,
in the previously established local Vision environment outside the managed
sandbox, subject to platform execution controls. This review did not rerun
the earlier environment diagnosis.

Both results and final snapshots must agree. Failure or drift ends this
permission without a successful observation or automatic retry. Earlier
open-path, topology and failed-execution records remain unchanged.
The receipt authorizes no further experiment, output scoring, source
registration, measurement amendment, NOSE-02 acceptance or milestone completion.
An observed nonempty lateral cohort still needs versioned width/uncertainty
semantics and actual pixel validation. Half-pixel quantization supplies no
detector localization error guarantee.

## Exact reviewed snapshot

| File | SHA-256 |
| --- | --- |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROI-REGISTRATION.json | ef066fbe62a8385c137666ea0213284244b05199a9df0a81c8998bed07e4c43d |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-CONTOUR-SIDES-SPEC.md | 990a43d00b4dcb0a1be4cab19d0c49dd886d3e7060c863a46fe963dcc3035c5c |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-DEFINITION-FREEZE-v2.json | 2035543bcfcec79729415cb4e9a8d5ddf30355c177a84a6d0b3e842ce63dbfe2 |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-IMPLEMENTATION-REVIEW-v3.md | 947645b74934d89898af44c4644b96ff39f628c4eeaa64bdaa1bfb27323402be |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-SPEC-v2.md | 168394eb55445d770e72fa1de65546ee0c1ba1cceb15721032f14bdaa9ce426b |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-REGISTRAR-SPEC-v2.md | 93d37da3b4a17c6b5e5087ee54744bb67c5c8dd1ea009704be0e54f1f28db8db |
| .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-REGISTRAR-SPEC-v3.md | a7151d0d49268a961cf35e7d4c7e1568ed6e7087f419dfa4cd5a49f6484bde46 |
| BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift | 9634829b8630a6b06aa25fcb0f54e73a7c5229a4497eaacf9fcadcb71c1bfeb4 |
| scripts/compare-face-feature-batches.swift | d7c7ccd293d4adb53cc2ea521d676cc6f51acd5215ae3a020862d332d1cfca26 |
| scripts/face-feature-batch-manifest.json | 5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e |
| scripts/phase95-root-anatomy-coverage.py | d4c421e8b5f7f450ef1e3d0f58308fb2a2d3a90c8084302ed26d391341700943 |
| scripts/phase95-root-contour-sides.py | bd8c8b3ccc05423a9619fc20d02ffc57f5c4c4d23ea171590b1e8fd24de28246 |
| scripts/phase95-root-edge-metric.swift | 7100a47cc3176035cb097016b252f00be477307f0d75fde932bffa869027287b |
| scripts/phase95-root-registration-adapter.swift | c19c2cd1384f1cb9ee8200bff9968759be25e02abb18b4bf9e98de6e7c38c4f0 |
| scripts/phase95-root-registration.py | 99a4edb93b9487ce70d13b411f55c12bc766a4175777fc8fdf551750e5d5fe13 |

_Independent reviewer: closeout-review-20260922. Diagnostic permission only._
