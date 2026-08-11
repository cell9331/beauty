---
phase: 65-combined-facade-privacy-and-milestone-closeout
reviewed: 2026-08-11T01:47:06Z
depth: deep
iteration: 3
files_reviewed: 24
files_reviewed_list:
  - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
  - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineCombinedLocalRetouchCloseoutTests.swift
  - BeautySDK/Sources/BeautyExampleRenderer/main.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
  - .planning/phases/61-teeth-output-safety-and-independent-closeout/check_teeth_renderer_outputs.py
  - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_sclera_renderer_outputs.py
  - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-private-output-runner.js
  - .planning/phases/65-combined-facade-privacy-and-milestone-closeout/check_phase65_combined_closeout.py
  - .planning/phases/65-combined-facade-privacy-and-milestone-closeout/65-CLOSEOUT-EVIDENCE.md
  - .planning/phases/65-combined-facade-privacy-and-milestone-closeout/65-SECURITY.md
  - .planning/phases/65-combined-facade-privacy-and-milestone-closeout/65-VERIFICATION.md
  - .planning/phases/65-combined-facade-privacy-and-milestone-closeout/65-REVIEW-FIX.md
  - .planning/milestones/v1.15-MILESTONE-AUDIT.md
  - .planning/PROJECT.md
  - .planning/REQUIREMENTS.md
  - .planning/ROADMAP.md
  - .planning/STATE.md
  - DESIGN.md
  - SECURITY.md
  - RELIABILITY.md
  - PRODUCT_SENSE.md
  - QUALITY_SCORE.md
  - PLANS.md
findings:
  critical: 2
  warning: 2
  info: 0
  total: 4
status: issues_found
---

# Phase 65: Code Review Report

**Reviewed:** 2026-08-11T01:47:06Z

**Depth:** deep (iteration 3, final allowed loop)

**Files Reviewed:** 24

**Status:** issues_found

## Summary

The runtime byte and color regressions remain green: rejected-eye cases compare
exact unaffected facade bytes against fresh standalone oracles, both public
entries expose named-sRGB carriers before test conversion, and real
presentation-free and watermarked PNG smoke outputs pass strict sRGB decoding.
The prior design wording is also corrected: failed/recovery sequences now say
they recover **without** prior state.

The two iteration-2 blockers are not closed. Final mode passes a currently
contradictory requirements owner and can still accept marker-preserving root
contradictions plus an audit with no requirement/seam/flow evidence. The
privacy scanner handles the exact multiline examples added to its self-test,
but valid Swift extension conformances, canonical `landmarks`/`pupil` names,
custom logger/tracing names and common persistence calls still bypass it.

Verification performed during this review:

- Python compilation, checker mutation self-test 34/34, live mode and final
  mode passed; `git diff --check` passed.
- Focused Swift regression passed 96/96 across combined facade, teeth/sclera
  integration, composition/foundation and renderer-output suites.
- Direct adversarial probes were accepted for a one-paragraph audit with zero
  evidence rows, contradictory/duplicate Phase 65 root sections, multiline
  `extension PupilSupport: Codable`, `logger.info("\(landmarks)")`, custom
  logger calls and `UserDefaults.setValue(rawMask, ...)`.
- The shared strict PNG decoder rejected a missing `sRGB` chunk, but accepted a
  PNG carrying both `sRGB` and a conflicting `iCCP` declaration.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01 [BLOCKER]: Final authority remains neither substantively validated nor converged

**Files:** `.planning/phases/65-combined-facade-privacy-and-milestone-closeout/check_phase65_combined_closeout.py:240-308`; `.planning/REQUIREMENTS.md:143-152`

**Issue:** `validate_requirement_disposition` proves only that eleven checkbox
prefixes exist. The current canonical requirements file therefore passes
`--final` even though its Coverage section simultaneously says only 23/40 are
canonically satisfied, all eleven Phase 65 requirements remain open behind
Phase 64, and the Phase 65 verification/audit are stale. This directly
contradicts the checked rows and the 40/40 final audit.

The remaining validators are similarly structural rather than substantive.
An in-memory probe kept the exact owner marker but added a current claim that
Phase 65 establishes shipping/release authority; another appended a second,
contradictory Phase 65 section. Both passed root convergence. A third probe
replaced the milestone audit with only its frontmatter, heading and one
sentence containing the six expected phrases—zero requirement rows, phase
rows, seam items or flow rows—and passed the complete final authority chain.
Timestamp and SHA-256 bindings authenticate those weak documents but do not
establish the authority they claim.

**Fix:** Make the canonical requirements coverage agree exactly with final
state (40/40 satisfied, zero Phase 65 items open, fresh verification/audit),
then validate it. Require exactly one current Phase 65 owner section in each
root document and reject contradictory completion/release/archive/product
claims outside the structured block. Parse and validate the audit's seven phase
coverage rows totaling 40, twelve numbered seams, seven passed flow rows and
zero blocker/orphan disposition rather than accepting prose tokens. Add the
current contradictory requirements file, marker-preserving contradictory and
duplicate owner sections, and the one-paragraph audit as mutations.

### CR-02 [BLOCKER]: Whole-production Swift privacy scanning still has compile-valid bypasses

**File:** `.planning/phases/65-combined-facade-privacy-and-milestone-closeout/check_phase65_combined_closeout.py:398-580`

**Issue:** The multiline span work covers only a narrow declaration and sink
grammar. Serialization matching ignores extension conformances; the sensitive
identifier classifier does not recognize the repository's canonical raw names
`landmarks`, `faceLandmarks`, `eyeLandmarks` or `pupil`; logger matching accepts
custom logger variables and constructed `Logger(...).info` calls; persistence
matching omits `setValue`; and no general tracing sink is classified.

The reviewer confirmed Swift parsing succeeds and the checker accepts, among
others, `extension PupilSupport: Codable {}`, multiline
`logger.info("\(landmarks)")`, `privacyLogger.info("\(rawMask)")`, and
`UserDefaults.standard.setValue(rawMask, forKey: "mask")`. These are direct
violations of SAFE-04's prohibition on Codable state, logs, persistence and
tracing. Enumerating every production file does not make a fail-open parser
whole-production protection.

**Fix:** Use SwiftSyntax/compiler AST declarations and call expressions, or a
conservative tokenizer with explicit extension-conformance and qualified-call
support. Classify the actual raw carrier types/properties (`landmarks`, pupil,
lip/eye support, masks, geometry, pixels/colors) and track aliases into an
explicit sink inventory covering any Logger/os_log/print, reflection,
Codable/Encodable extensions, UserDefaults/file/archive encoders, metrics and
tracing. Preserve explicit aggregate allowlists for safe counts/booleans. Add
compile-valid mutations for direct canonical names, extension conformances,
custom/constructed loggers, aliases, `setValue`, encoders and tracing, plus
benign multiline aggregate controls.

## Warnings

### WR-01 [WARNING]: The review-fix ledger is stale after the second repair iteration

**File:** `.planning/phases/65-combined-facade-privacy-and-milestone-closeout/65-REVIEW-FIX.md:1-55`

**Issue:** The artifact still declares iteration 1, records only the first four
fix commits, reports a 20/20 checker denominator and says final mode failed as
stale. The current worktree contains the second authority/privacy/wording/saved-
PNG repair iteration, uses 34 self-tests and passes final mode. As the repository
is the system of record, this leaves the final closeout's repair history and
verification evidence materially inaccurate.

**Fix:** Replace or append an iteration-2 disposition that names the actual
second-iteration changes, records 34/34 plus current live/final results, and
does not claim the two blockers closed until the adversarial mutations above
fail.

### WR-02 [WARNING]: Strict saved-PNG decoding accepts ambiguous color authority

**File:** `.planning/phases/61-teeth-output-safety-and-independent-closeout/check_teeth_renderer_outputs.py:91-134`

**Issue:** The shared teeth decoder, also imported by the sclera checker, treats
the mere presence of one `sRGB` chunk before IDAT as sufficient. It does not
require IHDR to be the first chunk and ignores conflicting `iCCP` color
profiles. A CRC-valid probe containing both `sRGB` and a conflicting `iCCP`
chunk passed `require_explicit_srgb=True`. Actual renderer smoke output is
currently valid, but the supposedly strict authority can accept malformed or
ambiguous saved output and falsely satisfy SAFE-06 after future drift.

**Fix:** Enforce PNG critical-chunk ordering with IHDR first, reject unknown
critical chunks, and reject `iCCP` or any inconsistent alternative color-space
metadata when explicit sRGB is required (or parse and prove an exact sRGB ICC
profile). Add wrong-order and conflicting-profile mutations to the shared
decoder self-test so both feature gates inherit them.

---

_Reviewed: 2026-08-11T01:47:06Z_

_Reviewer: the agent (gsd-code-reviewer)_

_Depth: deep_

_Completion: REVIEW COMPLETE — issues found; final iteration exhausted._
