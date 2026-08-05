---
phase: 58-combined-facade-safety-ledger-and-audit-closeout
reviewed: 2026-08-04T10:00:00Z
depth: deep
files_reviewed: 18
files_reviewed_list:
  - .planning/PROJECT.md
  - .planning/REQUIREMENTS.md
  - .planning/ROADMAP.md
  - .planning/STATE.md
  - .planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/58-CLOSEOUT-EVIDENCE.md
  - .planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/58-THREAT-INVENTORY.json
  - .planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py
  - BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift
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
  critical: 5
  warning: 2
  info: 0
  total: 7
status: issues_found
---

# Phase 58: Code Review Report

**Reviewed:** 2026-08-04T10:00:00Z  
**Depth:** deep  
**Files Reviewed:** 18  
**Status:** issues_found

## Summary

The automated closeout passes its recorded happy-path runs, but the checker is
not fail-closed for several adversarial inputs. In particular, the Phase 57
integrity gate can be skipped, valid candidate/privacy identifiers evade the
scanners, and a malformed authority schema value is accepted. These defects
make the reported HIGH audit and zero-admission claims unreliable until fixed.

## Critical Issues

### CR-01: Non-Git roots bypass the frozen Phase 57 integrity proof

**File:** `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py:793-800`

**Issue:** `phase57_failures()` only compares the current checker to the pinned
Git revision and runs the verified 519-case pre-transition fixture when
`ROOT/.git` exists. A copied or exported non-Git root therefore skips both
checks and can still report `--lifecycle` as passed. This contradicts the
locked frozen-integrity requirement and lets a closeout run omit the 519-case
proof entirely.

**Fix:** Require a valid Git repository and an exact `git show` blob for live
and lifecycle modes, or package the pinned Phase 57 checker/revision and run
the 519-case fixture independently of repository metadata. Fail closed when
the provenance source is unavailable; reserve non-Git roots for an explicit
mutation-test mode.

### CR-02: Candidate scanner misses valid teeth/eye feature names

**File:** `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py:78-85,333-341,553-575`

**Issue:** `CANDIDATE_PATTERN` only recognizes a narrow set of prefixes such as
`teethWhitening` and `scleraRedness`. Names used by the prior Phase 57 identity
inventory, including `whitenTeeth`, `eyeRednessReduction`,
`upperEyelidFullnessRemoval`, and `removeUpperEyelidFat`, are not covered. A
neutral source containing `public let whiteTeethRoute = true` was accepted by
the live checker (`mode=live status=passed`). Thus a candidate route can be
introduced while T-58-01/T-58-05 still report clean.

**Fix:** Reuse one complete, exact identity inventory (including camelCase,
snake_case, aliases, dotted Demo IDs, and owned labels) across authority,
output, compatibility, and Demo scans. Add representative mutations for every
identity and require all source/supplemental/Demo surfaces to fail closed.

### CR-03: Privacy scanner misses public landmark/support aliases

**File:** `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py:86-89,114-119,360-382`

**Issue:** The privacy patterns only name a small set of exact fields
(`rawLandmarks`, `publicRawLandmarks`, `spiSupportCoordinates`, etc.). A public
payload such as `public var publicLandmarkSupport: [Float] = []` is not matched
by any boundary or durable-output pattern; inserting that file into a copied
root produced `mode=live status=passed`. This allows precisely the raw support
data SAFE-01 forbids to evade T-58-02.

**Fix:** Scan token families and declaration boundaries for landmark/support/
geometry/point/observation payloads in public, SPI, Codable, persistence,
network, log, metric, and artifact contexts. Keep the scanner deny-by-default
for unknown anatomy payload names and add alias mutations to the HIGH matrix.

### CR-04: JSON boolean schema version is accepted as integer `1`

**File:** `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py:290-296`

**Issue:** `document.get("schema_version") != 1` uses Python equality, where
`True == 1`. Replacing the Phase 54 authority value with JSON `true` therefore
passes the decision gate, despite the checker claiming exact schema equality.
This is an authority-tampering fail-open path under T-58-01.

**Fix:** Enforce the type explicitly (`type(document.get("schema_version")) is
int and document.get("schema_version") == 1`) and add boolean/null/string
schema-version mutations to the authority matrix.

### CR-05: Git archive extraction permits symlink-based writes outside the fixture

**File:** `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py:659-675`

**Issue:** The archive-member check rejects absolute and `..` names but accepts
symlink and hard-link members before calling `extractall`. A malicious Git
revision can replace an expected checker/fixture path with a symlink to an
external file; subsequent `read_text`/`read_bytes` calls follow it, and the
Phase 57 subprocess adapter can execute the external target. The checker runs
this path as part of the security audit, so untrusted repository content can
escape the disposable fixture and execute/read outside it.

**Fix:** Reject `member.issym()` and `member.islnk()` (or resolve every target
against the extraction root and verify containment) before extraction, and
extract regular files with a no-follow, per-file safe writer.

## Warnings

### WR-01: Lifecycle owner metadata contradicts its own completion totals

**File:** `.planning/ROADMAP.md:200-221`; `.planning/STATE.md:41-53,83-86`

**Issue:** The roadmap says `Plans: 4/4 executed` and lists `58-04-PLAN.md` as
complete, but the Wave 3 row remains unchecked. STATE simultaneously reports
27 completed plans in frontmatter, 26 in the metrics section, and only 3 plans
for Phase 58 while listing a completed P04 row; its `last_activity_desc` still
says Plan 03 is complete. Downstream lifecycle tooling can therefore treat the
final owner as incomplete or compute inconsistent progress despite the
validated evidence.

**Fix:** Regenerate roadmap/state from one source of truth: mark the Wave 3 row
complete and reconcile all total/phase plan counts before phase transition.
Add an owner-equality check that rejects contradictory checklist and metric
values.

### WR-02: Lifecycle coverage is lexical marker presence, not executable test coverage

**File:** `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py:398-469`

**Issue:** `lifetime_failures()` proves lifecycle tests by counting method names
and searching raw source fragments. The fragments can remain in comments while
the test bodies/assertions are removed or made no-ops, yet the checker still
passes. The same marker-only strategy is used for several compatibility and
output owners. This makes the claimed request-lifetime/HIGH matrix vulnerable
to vacuous test mutations.

**Fix:** Execute the focused test owners (and assert exact test counts/results)
from the checker, or validate Swift syntax/AST and assertion bodies rather than
string markers. Keep lexical scans as supplemental checks only.

---

_Reviewed: 2026-08-04T10:00:00Z_  
_Reviewer: the agent (gsd-code-reviewer)_  
_Depth: deep_
