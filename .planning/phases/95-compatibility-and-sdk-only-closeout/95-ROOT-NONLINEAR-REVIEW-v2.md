---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-15T05:29:52Z
depth: standard
review_scope: narrow_WR-01_delta
status: clean
files_reviewed: 1
files_reviewed_list:
  - BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
resolved_findings:
  - id: WR-01
    original_classification: WARNING
    disposition: resolved_independently_verified
hash_algorithm: sha256
reviewed_working_tree_sha256:
  BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift: 7a248d78033679c164755e85966f34956012ad56fecb74839c3ccc1a80ec0c12
unchanged_context_sha256:
  scripts/phase95-root-nonlinear-probe.py: 8be3b6a27d3dab808ffad4dd516ce820e0c1efd16d26f54fdcc4bfd3f11ccbdf
  scripts/phase95-root-affine-motion-probe.py: 0d99954325288c2b7da43cb4dcb90412decb7aeb441fcc82ae605d4edfe8f06c
  .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-NONLINEAR-MODEL.md: 73bbbd8c146c46b3f9d3daa0e5aadcc3b993f625a51432332a20ec070ab14552
  BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift: bbffaffbeecb6432ee1c917e9b7d2143fae8ca46028aedeecb01f5f690b0981a
prior_review:
  path: .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-NONLINEAR-REVIEW-v1.md
  sha256: 762a504792aef1d8c422e9fea9c74e072466dd33624d4fc7957f9462f6809172
prior_swift_sha256: 344dd2f43558b3b2c2482e256375bbfea2417288ebe5374e74c1a6d82d1f45cf
extracted_child_sha256: e154dd99f21d61b7d913ab89f71188c437cddc26bf3375b2b25bdd27c9b99c1d
independent_checks:
  sole_delta_verified_against_prior_hash: true
  wrong_interval_rejections: 2
  wrong_interval_empty_stdout: 2
  valid_interval_successes: 2
  failed_expectations: 0
swiftpm_rerun: false
exhaustive_mathematics_rerun: false
main_results_credited_as_reviewer_execution: false
portrait_scoring_attempts: 0
acceptance_credit: false
phase_complete: false
---

# Phase 95: Narrow nonlinear review v2

## Narrative Findings (AI reviewer)

### Disposition

**WR-01 (original classification: WARNING) is resolved.** No new blocker or
warning was found in the reviewed delta.

At `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift:181-184`,
the child now rejects excluded truth with an unconditional `if` and
`SystemExit('containment_failed')`. The count increment and success output
remain after that guard, which is retained under Python optimization.

Replaced only these two new lines with the former assertion in memory and
hashed the entire reconstructed Swift file. It exactly matches the v1 Swift
hash above, proving this is the sole source delta relative to that review.
The nonlinear implementation, affine dependency, model document and renderer
also retain their v1 identities. The v1 report remains byte-exact.

### Independent execution

Extracted the actual child program from the current Swift bytes, removing its
eight-space Swift multiline-string indentation. Its UTF-8 hash, without an
added terminal newline, is recorded above. Substituted only the interval
provider in memory, keeping the actual containment guard, count, JSON output
and `/usr/bin/python3 -B -c` invocation intact. Used generated in-memory test
records, a ten-second subprocess timeout, and explicit optimization settings.

| PYTHONOPTIMIZE | Interval provider | Exit | Stdout | Result |
| --- | --- | --- | --- | --- |
| 0 | Excludes supplied truths | 1 | Empty | Rejected |
| 1 | Excludes supplied truths | 1 | Empty | Rejected |
| 0 | Contains supplied truths | 0 | Expected containment-count JSON | Passed |
| 1 | Contains supplied truths | 0 | Expected containment-count JSON | Passed |

Both exclusion mutations also produced only the fixed failure reason on
stderr. Child output was inspected in memory; only aggregate outcomes are
recorded. The positive controls establish that the repaired guard still
permits successful containment. This execution tests the extracted adapter
with substituted intervals; it does not rerun the solver or actual renderer.

### Limits

This clean disposition applies to WR-01's narrow repair. The independent
mathematical evidence remains in v1 and was not repeated. The main's reported
optimized SwiftPM 3/0/0, its mutation checks and its running self-test are not
credited as reviewer execution here. No full SwiftPM, broad phase-history
gate, private input, external AI CLI, additional agent, installation, commit
or production/source edit was performed. Only this new report was written.

The generated sampler checks remain distinct from independent anatomical
truth, formal metric qualification, portrait acceptance and Phase 95
completion. No such credit is granted by this review.

_Reviewer: independent gsd-code-reviewer; standard depth, narrow delta._
