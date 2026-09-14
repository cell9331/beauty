---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-14T03:53:00Z
reviewer_agent_id: 01a09e09-b580-7261-8338-8d83471b2807
depth: standard
review_scope: narrow-source-only-registrar-integration
base_commit: a205d97307784a4b7edf91b182d94223a2be26df
files_reviewed: 4
files_reviewed_list:
  - scripts/phase95-root-registration.py
  - scripts/phase95-root-registration-adapter.swift
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-REGISTRAR-SPEC-v2.md
  - .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-DEFINITION-FREEZE-v2.json
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

# Phase 95 source-only registrar integration review v2

## Narrative Findings (AI reviewer)

Approve source-only registration through the exact reviewed driver and adapter below. No concrete unresolved BLOCKER or WARNING was found in this narrow integration review. The companion JSON is this independent reviewer's approval receipt, with the complete current eleven-entry `snapshot()` dictionary and no findings.

This approval permits the main implementer to attempt the two source-only registrations. Registration may still reject as unavailable, ambiguous, invalid or mismatched. It does not establish source measurability, anatomical correspondence, portrait effectiveness, candidate/neutral/sibling scoring, a metric amendment, downstream consumer approval or Phase 95 completion. The independently approved generic mathematics at `a205d973` was treated as a frozen dependency and was not re-reviewed.

## Integration reasoning

- **Admission and executable slicing:** `scripts/phase95-root-registration.py:34` rejects symlinked, missing, empty and oversized reviewed inputs. Lines 57–68 bind all pinned dependencies and four integration files to the review receipt. Lines 70–86 require exactly one of each fixed dispatcher marker and append only the selected adapter entry. The comparator prefix has definitions/imports rather than an independently executed CLI; the frozen metric dispatcher is also excluded. Lines 202–218 admit only the two exact command forms, validate the review before source execution, compare two complete child records and recheck reviewed files and compiler/OS identity before emitting success.

- **Legacy canonicalization and unchanged ROI:** `scripts/phase95-root-registration-adapter.swift:34` uses the existing regular-file, inventory and manifest admission helpers and requires the fixed single-source byte identity. Lines 47–58 reuse the comparator's oriented, integral-extent, managed-sRGB rasterization and complete original `portraitContracts` recipe, verify the full original contract digest before selecting the root ROI, and enforce the existing watermark boundary. The original ROI rasterizer, signs, thresholds and protection definitions are reused. Lines 9–18 bound dimensions, sample count and RGBA shape, reject any nonopaque alpha byte, and divide the original integer `lumaQ8` by exactly 256.

- **Explicit source-bound exclusions:** Adapter lines 60–83 use the same admitted, orientation-applied source and sRGB context for the second Vision request, require equal carrier dimensions and exactly one face, validate two finite 3–32-point contours, and apply the legacy Y mapping once. Lines 21–30 conservatively rasterize the new exclusion boxes outward. These boxes are passed explicitly to the frozen registration API, which sorts and commits exclusions, ROI, source-plane digest, row set and source profiles. They do not replace legacy acceptance rectangles. The two Vision requests are the explicit legacy-reuse integration contract; identical results are checked across two independent full child executions rather than assumed.

- **Binding and output schema:** Driver lines 127–155 reject duplicate JSON fields, nonobjects, unexpected keys, old schemas, incorrect enums, invalid SHA strings, booleans masquerading as integer registration counts/revisions, wrong original source/contracts identities, and enabled scoring. Lines 210–217 compare the complete registrations, attach the reviewed-input digest and environment identity, and reject changes. Adapter lines 84–94 re-admit and hash the source after each registration and export commitments/counts only. The generic freeze's listed dependency hashes agree with the fixed driver pins and the prior independent review.

- **Privacy and process lifecycle:** Driver lines 88–125 bound stdin to 1 MiB and combined stdout/stderr to 16 MiB, use a separate writer to avoid pipe deadlock, and enforce the 180-second wall/monotonic deadline. The finally path terminates the owned process group, escalates to KILL including after direct-child exit, joins the writer and closes output. Arbitrary Swift/compiler/legacy diagnostic text stays in the captured buffer and cannot pass the aggregate schema. Environment probes use fixed commands with 15-second timeouts and validate their status and returned length. No source-registration result, image, raw geometry, profile, private locator or transcript is written by this workflow.

These checks concern the owner-controlled local workflow and exact admitted files. They do not claim protection against a compromised operating system/toolchain or a hostile concurrent writer that changes and restores files between identity checks.

## Executed validation

| Check | Result |
| --- | --- |
| `python3 scripts/phase95-root-registration.py --self-test` | Exit 0; 8 Swift generated carrier/exclusion checks and 22 Python admission checks. |
| Independent generated subprocess probes | 6 assertions passed: over-limit stdin rejection, live 17-MiB output rejection, invalid compiler output rejection, both child groups gone, writer threads ended. Child output remained in memory. |
| Independent deadline/cleanup probe | 3 assertions passed: timeout rejection, child group gone, writer thread ended. The module's wall clock was injected to cross the fixed deadline immediately; no three-minute wait or deadline-source edit. |
| Review identity | Eleven-file snapshot unchanged across independent probes; all seven hard-coded dependency hashes matched. |
| Receipt validation | Passed the unchanged `validate_review()` against the current eleven-entry `snapshot()` after writing both review artifacts. |

The generated self-test executes neither source registration nor private-image access. The independent probes use small generated Swift programs and the driver API only. No `--register-source`, comparator CLI, private source/output inspection, diagnostic, clean65, generic 346-check rerun or focused eleven-test rerun was performed.

Review environment: arm64 macOS 26.5.1. Compiler-version output SHA-256: `5fa4b669e41b23b9ad0760253d062493487f93cf5d8ad8c44f0d4fd635137499`. OS-build output SHA-256: `9f01454a441e06792cd7851dcbd23d54b38d2e45ee882e9a612b124d2b6aa404`. Runtime registration independently checks environment stability across its two attempts; this receipt does not certify every other environment.

## Exact reviewed snapshot

The first two files are implementation review targets; the registrar spec and freeze are integration contract targets. Other entries are admitted context/dependencies, not a reopened generic-math review.

| File | SHA-256 |
| --- | --- |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROI-REGISTRATION.json` | `ef066fbe62a8385c137666ea0213284244b05199a9df0a81c8998bed07e4c43d` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-DEFINITION-FREEZE-v2.json` | `2035543bcfcec79729415cb4e9a8d5ddf30355c177a84a6d0b3e842ce63dbfe2` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-IMPLEMENTATION-REVIEW-v3.md` | `947645b74934d89898af44c4644b96ff39f628c4eeaa64bdaa1bfb27323402be` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-METRIC-SPEC-v2.md` | `168394eb55445d770e72fa1de65546ee0c1ba1cceb15721032f14bdaa9ce426b` |
| `.planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-REGISTRAR-SPEC-v2.md` | `93d37da3b4a17c6b5e5087ee54744bb67c5c8dd1ea009704be0e54f1f28db8db` |
| `BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift` | `9634829b8630a6b06aa25fcb0f54e73a7c5229a4497eaacf9fcadcb71c1bfeb4` |
| `scripts/compare-face-feature-batches.swift` | `d7c7ccd293d4adb53cc2ea521d676cc6f51acd5215ae3a020862d332d1cfca26` |
| `scripts/face-feature-batch-manifest.json` | `5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e` |
| `scripts/phase95-root-edge-metric.swift` | `7100a47cc3176035cb097016b252f00be477307f0d75fde932bffa869027287b` |
| `scripts/phase95-root-registration-adapter.swift` | `c19c2cd1384f1cb9ee8200bff9968759be25e02abb18b4bf9e98de6e7c38c4f0` |
| `scripts/phase95-root-registration.py` | `2a269e38820fb2e6ccf18b8d59e999d7c1d7f15f0189f858d42145283c6ab1a8` |

## Review boundaries and handoff

Read AGENTS.md, PLANS Active, relevant current ARCHITECTURE/DESIGN/SECURITY/RELIABILITY/QUALITY owners, the registrar contract and generic freeze/prior review, and the necessary legacy canonicalization, admission, ROI and frozen registration API context. None of the four scoped files is gitignored; no .codexignore was present. Serena was unavailable, so local reads were used.

Used gsd-code-review for scoped adversarial review and exact finding/identity reporting, and spike-findings-beauty for request-local geometry, private-fixture and aggregate-only evidence boundaries. The bootstrap reference was found at the installed .agents/gsd-core path; its read-only agent-skills query added no skills. The project skill directory contains only spike-findings-beauty. The user's explicit narrow scope and two-file write allowance govern this delegated review; no additional workflow artifacts or commits are authorized.

Only this report and `95-ROOT-REGISTRAR-REVIEW-v2.json` were created, using apply_patch. No source, frozen definition/spec/test/review, owner document or unrelated dirty-tree file was modified. No `95-INDEPENDENT-REPAIR-REVIEW.json` was created. All reviewer-started tests and subprocess probes have ended; no review test remains running.
