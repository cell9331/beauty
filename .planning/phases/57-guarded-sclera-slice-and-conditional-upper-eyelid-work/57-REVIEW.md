---
phase: 57-guarded-sclera-slice-and-conditional-upper-eyelid-work
reviewed: 2026-08-04T03:27:14Z
depth: deep
files_reviewed: 21
files_reviewed_list:
  - .planning/REQUIREMENTS.md
  - .planning/ROADMAP.md
  - .planning/STATE.md
  - .planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/57-01-SUMMARY.md
  - .planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/57-02-SUMMARY.md
  - .planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/57-03-SUMMARY.md
  - .planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/57-04-SUMMARY.md
  - .planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/57-CLOSED-EYE-GATES-EVIDENCE.md
  - .planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/57-THREAT-INVENTORY.json
  - .planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/57-VALIDATION.md
  - .planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/check_phase57_eye_gate_boundaries.py
  - BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
  - BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
  - PLANS.md
  - PRODUCT_SENSE.md
  - QUALITY_SCORE.md
  - RELIABILITY.md
  - SECURITY.md
findings:
  critical: 7
  warning: 0
  info: 0
  total: 7
status: fixed_pending_verification
---

# Phase 57: Code Review Report

**Reviewed:** 2026-08-04T03:27:14Z  
**Depth:** deep  
**Files Reviewed:** 21  
**Status:** fixed_pending_verification

## Summary

The submitted live checker, decision mode, and advertised 220-case self-test all
pass on the current tree. Adversarial tests outside that fixed matrix expose
seven blocking fail-open paths, however. Unauthorized candidate aliases and
neutral Demo routes can evade the source boundary; the affirmative LID-04
proxy rule does not recognize the product's own Chinese label; validated
evidence can contain contradictory activation claims or sensitive eye support;
an unreadable fixture leaks a raw traceback/path; and the claimed owner-equality
gate neither validates root-owner content nor catches an owner inconsistency
already present in `ROADMAP.md`.

The current `.none`, 59 fields, five presets, 72 renderer cases, both still
facades, disabled rows, and future/future/partial ledgers are intact. The review
is blocked because the HIGH gates intended to preserve those facts can report
green after representative prohibited changes.

## Critical Issues

### CR-01: Direct candidate aliases bypass the complete-production scan

**Classification:** BLOCKER  
**File:** `.planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/check_phase57_eye_gate_boundaries.py:72-101`  
**Issue:** `SCLERA_PATTERN` recognizes `scleraRednessReduction` and selected
long forms but not the direct `scleraRedness` route. `EYELID_PATTERN` similarly
recognizes reduction/removal forms but not the direct
`upperEyelidFullness` route. In an isolated copy of the real fixture tree,
adding either `package var scleraRedness: Float = 0` or
`package var upperEyelidFullness: Float = 0` in a neutrally named new file left
`classified_live_failures()` empty. The Phase 57 Swift negative-name arrays
repeat the same omissions, so the focused tests do not compensate. This
invalidates T-57-02/T-57-03's claim that canonical and strong synonym routes
cannot enter any production Swift file.  
**Fix:** Define normalized, explicit candidate-family token sets that include
the unsuffixed semantic nouns as well as reduction/removal/provider suffixes;
apply them to every `BeautySDK/Sources/**/*.swift` file and supplemental
surface. Add neutral-file mutations for `scleraRedness`, `conjunctivaRedness`,
`ocularRedness`, `upperEyelidFullness`, `upperEyelidFat`, and equivalent
declared aliases, and mirror the complete set in the Swift boundary tests.

### CR-02: New Demo files can activate both disabled rows without detection

**Classification:** BLOCKER  
**File:** `.planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/check_phase57_eye_gate_boundaries.py:348-378,468-513`  
**Issue:** The generic supplemental scan traverses the Demo tree but only with
the incomplete English candidate regexes. `demo_failures()` then inspects the
exact taxonomy owner plus only three fixed control/panel/store files. A new
neutral Demo Swift file containing either
`("eyes.fat", BeautyControlID.eyeHeight) // 去脂` or
`("eyes.redness", BeautyControlID.brightness) // 祛红血丝` passed the complete
live gate. That is an active control/mapping route explicitly forbidden by
T-57-05, despite the original disabled rows remaining unchanged.  
**Fix:** Scan every `BeautyDemo/BeautyDemo/**/*.swift` file for the exact
disabled IDs/titles and any binding, control, store, processor, reset, or
availability relation. Allow only the two exact disabled taxonomy declarations
in their owning file. Add neutral-filename Demo mutations for both IDs and both
Chinese labels mapped to unrelated shipped controls.

### CR-03: LID-04 does not reject the actual `去脂`-to-proxy relationship

**Classification:** BLOCKER  
**File:** `.planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/check_phase57_eye_gate_boundaries.py:91-110,372-378`  
**Issue:** The proxy relation requires one of the English `EYELID_PATTERN`
tokens near a proxy. It does not treat `去脂` or `eyes.fat` as candidate
semantics. A neutral production source containing
`// eyeHeight implements 去脂` and forwarding to `eyeHeight` passes live with
no rule. LID-04 is therefore not genuinely enforced at the product-label and
Demo-ID boundaries even though the evidence records
`proxy_rejection_enforced`.  
**Fix:** Make the relation classifier understand all owned candidate
identities, including `去脂` and `eyes.fat`, while contextually allowlisting only
the exact disabled taxonomy row. Exercise assignment, forwarding, comment,
mapping, route, and evidence forms for each label/ID against every prohibited
proxy, plus clean proxy-only and disabled-row controls.

### CR-04: Finalized evidence accepts contradictory open/active claims

**Classification:** BLOCKER  
**File:** `.planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/check_phase57_eye_gate_boundaries.py:598-693`  
**Issue:** `has_affirmative_eye_candidate_claim()` only rejects a narrow status
vocabulary such as implemented, shipped, and production-ready. It does not
reject `active`, `enabled`, `available`, `open`, or conflicting projection
rows. Appending either `Sclera redness reduction is active in production.` or
`| sclera_redness | open |` to the currently validated evidence still returns
no live failure because required closed anchors are checked by inclusion rather
than by exact parsed section equality. A structurally finalized artifact can
therefore assert both closed and open states and remain green.  
**Fix:** Parse the decision, disposition, task, HIGH, and final-result tables as
exact schemas with unique rows and allowlisted values. Reject any extra feature
status or affirmative candidate claim, including active/enabled/available/open,
instead of relying on a short prose keyword list. Add table and prose
contradiction mutations for both features and both evidence lifecycle states.

### CR-05: The evidence privacy gate allows sensitive support in prose and tables

**Classification:** BLOCKER  
**File:** `.planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/check_phase57_eye_gate_boundaries.py:695-706`  
**Issue:** The privacy expression only catches a sensitive word when it begins
a key/value-like line. Appending `Observed pupil coordinates were (12, 34).` to
the validated evidence passes `evidence_failures()` and the live gate. Similar
narrative or table-cell forms can retain iris, landmark, mask, pixel, reviewer,
or raw-scanner data while the evidence still claims a fixed aggregate-only
allowlist. This violates T-57-06 and the repository's request-local sensitive
support boundary.  
**Fix:** Prefer an exact parsed allowlist for every evidence section and reject
unrecognized rows/paragraph shapes. At minimum, scan sensitive vocabulary and
coordinate/path/digest forms anywhere in non-authorized text, with narrowly
enumerated nonclaim sentences rather than line-start matching. Add prose,
bullet, quoted, and Markdown-table mutations for every sensitive family.

### CR-06: Unreadable fixtures leak raw traceback and filesystem paths

**Classification:** BLOCKER  
**File:** `.planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/check_phase57_eye_gate_boundaries.py:710-719,1612-1633`  
**Issue:** `main()` calls `live_failures()` directly. When a required path
exists but is unreadable as a text file (for example, the evidence path is a
directory), `validation_lifecycle_failures()` performs a second unguarded
`read_text(EVIDENCE)` and the CLI exits through a Python traceback. The
isolated direct-CLI reproduction returned no fixed stdout and exposed the full
temporary filesystem path on stderr. The self-test misses this because it calls
`classified_live_failures()` in-process. This contradicts the fixed-rule-only
output and unreadable-fixture guarantees in T-57-06/T-57-08.  
**Fix:** Route every CLI mode through one top-level exception classifier and
emit only an allowlisted rule set; never let raw exceptions reach stderr.
Include the second evidence read inside the protected block. Add subprocess
self-tests for unreadable files/directories and assert exact stdout, exit code,
and empty stderr.

### CR-07: Owner-equality is not checked, and ROADMAP is already inconsistent

**Classification:** BLOCKER  
**File:** `.planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/check_phase57_eye_gate_boundaries.py:235-243,756-768`  
**Issue:** `PRODUCT_SENSE.md`, `SECURITY.md`, `RELIABILITY.md`, and
`QUALITY_SCORE.md` are only required to exist; none of their Phase 57 content is
validated. `PLANS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` are not
part of the live checker at all. Erasing all of `SECURITY.md` or all of
`ROADMAP.md` in an isolated fixture still leaves the live gate green. The
current repository demonstrates the consequence: `.planning/ROADMAP.md:162-167`
says all four plans executed and checks their compact entries, while
`.planning/ROADMAP.md:179` and `:183` still leave 57-03 and 57-04 unchecked.
Nevertheless validation/evidence claim synchronized owner equality and all
eight HIGH gates green.  
**Fix:** Add exact, unique Phase 57 structural anchors for every declared root
owner, PLANS, ROADMAP, STATE, requirements, and both blueprints; reject missing,
duplicate, stale, or contradictory lifecycle/status/count/disposition rows.
Include owner-deletion and contradictory-owner mutations under T-57-08. Repair
the two stale ROADMAP wave checkboxes before re-finalizing evidence.

## Fix Status

All seven blocking findings were fixed in isolated atomic commits and remain
pending the independent Phase 57 verifier; this review status does not complete
or transition the phase.

| Finding | Resolution | Commit |
| --- | --- | --- |
| CR-01 | Unsuffixed sclera/eyelid families now fail across all production Swift and supplemental surfaces; Swift owners mirror the expanded set. | `487c64d` |
| CR-02 | Every Demo Swift file is scanned recursively with only the two exact disabled taxonomy declarations allowlisted. | `123e78f` |
| CR-03 | `去脂` and `eyes.fat` are first-class proxy identities across six relation forms and every prohibited proxy. | `8bb940e` |
| CR-04 | Decision, disposition, task, and HIGH tables use exact unique schemas and reject open/active contradictions. | `8ad2660` |
| CR-05 | Validated evidence is an exact aggregate-only allowlist; prose, bullet, quote, and table sensitive payloads fail closed. | `b59b889` |
| CR-06 | All CLI modes classify exceptions to fixed rules; unreadable-directory subprocess tests require empty stderr. | `648ce7d` |
| CR-07 | Root owners, PLANS, ROADMAP, STATE, requirements, validation, and both blueprints have exact anchors and mutation coverage; stale wave boxes are repaired. | `c32dd07` |

Post-fix checker evidence is 490/490 with per-threat totals
`65 / 38 / 35 / 199 / 23 / 81 / 7 / 42`; live mode is clean. Focused Phase 57
Swift tests pass 5/5 and the focused Demo test passes 1/1. The broader 101-test
Swift filter reached all Phase 57 tests but reported eight unrelated missing
ignored regression fixtures in the isolated worktree; the verifier should run
the canonical full gates from the primary workspace.

---

_Reviewed: 2026-08-04T03:27:14Z_  
_Reviewer: the agent (gsd-code-reviewer)_  
_Depth: deep_
