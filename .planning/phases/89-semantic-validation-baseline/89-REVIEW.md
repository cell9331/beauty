---
phase: 89-semantic-validation-baseline
reviewed: 2026-08-26T03:42:31Z
depth: standard
files_reviewed: 8
files_reviewed_list:
  - scripts/face-feature-batch-manifest.json
  - scripts/compare-face-feature-batches.swift
  - scripts/run-face-feature-batches.sh
  - example-images/README.md
  - QUALITY_SCORE.md
  - SECURITY.md
  - RELIABILITY.md
  - PLANS.md
findings:
  critical: 5
  warning: 2
  info: 0
  total: 7
status: issues_found
---

# Phase 89: Code Review Report

**Reviewed:** 2026-08-26T03:42:31Z
**Depth:** standard
**Files Reviewed:** 8
**Status:** issues_found

## Summary

The Phase 89 harness is not safe to credit as a frozen, complete semantic gate. The review found five blocker-level correctness/privacy defects and two robustness warnings. Most importantly, the supposedly frozen regions and thresholds can be weakened without failing the 180-mutation self-test, and the current live baseline credits an unmeasurable gaze direction (`metric_admission`) as a complete deterministic semantic failure. Output admission and cleanup also do not enforce the documented one-attempt, PNG-only retention boundary.

Verification performed during review: the unmodified self-test, Swift type-check, shell syntax check, JSON parse, and `git diff --check` pass. An isolated manifest mutation lowered the contour signal floors to `1` and raised its outside ceilings to `999999999`; the comparator still reported `PASS mutations=180`, proving CR-01. The ignored aggregate report was inspected only through its allowlisted fixed fields and currently records `gazeCorrection_0p25` as `semantic_fail` solely because of `metric_admission`, proving CR-02. No private pixels, paths, or fixture identity were copied into this review.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: BLOCKER — “Frozen” thresholds and regions are mutable without detection

**Files:** `scripts/compare-face-feature-batches.swift:249-266`, `scripts/compare-face-feature-batches.swift:336-412`, `scripts/face-feature-batch-manifest.json:104-235`

**Issue:** The compiled expected contract pins only case ID, metric, polarity, and comparison IDs. `validateManifest` accepts any non-empty, non-overlapping regions and any positive minimum/non-negative maximum thresholds (apart from forcing the named background/watermark ceilings to zero). It never compares the target rectangles, protection rectangles, signal floors, locality ceilings, or protection ceilings with canonical values. The self-test then derives all “exact boundary” probes from whichever values are currently in the manifest, so weakening the manifest also weakens the tests. The runner reconciles two attempts against that same mutated manifest and has no independent expected digest. This directly contradicts the frozen/no-threshold-weakening claims in `example-images/README.md:76-79,108-112`, `QUALITY_SCORE.md:61-76`, and `PLANS.md:517-529`, and can turn a defective repair into `semantic_pass`.

**Fix:** Make the complete eight-contract value set an independent authority. Either compile every region and threshold into Swift and require exact `SemanticContract` equality, or pin a canonical semantic-manifest digest outside the manifest and verify it before self-test/render/report work. Add mutations that change every scalar, region edge, region membership/order, and ceiling by one unit and require contract admission to fail rather than recalculating expectations from the mutated input.

### CR-02: BLOCKER — An unmeasurable metric is published as a complete semantic result

**Files:** `scripts/compare-face-feature-batches.swift:1451-1502`, `scripts/compare-face-feature-batches.swift:2438-2472`, `scripts/run-face-feature-batches.sh:450-477`

**Issue:** `semanticDirectionSummary` catches `SemanticContractError.admission`, drops that fixture's measurements, inserts `metric_admission`, but still reports the original full `fixtureCount` and returns a normal `semantic_fail`. The comparator exits its semantic-failure code and the runner converts that to creditable public exit `3`. The current aggregate report demonstrates the defect: `gazeCorrection_0p25` has no measurements and fails solely with `metric_admission`, yet Phase 89 documents all seven failures as complete trustworthy measurements. This contradicts `SECURITY.md:296-304` and `RELIABILITY.md:318-327`, which route admission faults to non-creditable infrastructure failure, and it makes downstream repair decisions from missing evidence.

**Fix:** Do not swallow metric admission. Track measured fixture count separately and require it to equal the admitted fixture count for every direction. Propagate source/neutral/metric admission failures to the comparator infrastructure code (and runner exit `2` with a sanitized envelope). If candidate-only non-measurability is intentionally a semantic defect, distinguish it from source/neutral/contract admission and still report an exact measured/abstained count; never label an abstained row complete.

### CR-03: BLOCKER — The gaze oracle measures arbitrary dark pixels, not pupil-to-eye geometry

**File:** `scripts/compare-face-feature-batches.swift:519-541,597-619`

**Issue:** `pupilToOwnEyeCenter` does not identify a pupil or an eye center. It treats every pixel with luma at or below 80 inside two fixed rectangles as equal-weight “pupil” support and measures that dark-pixel centroid against the rectangle center. Eyelashes, eyeliner, shadows, hair, artifacts, or an injected dark patch can therefore improve the score while the actual pupil is unchanged; conversely a valid gaze repair can fail when the true eye center is not the hard-coded box center. The generated self-test at `scripts/compare-face-feature-batches.swift:1637-1651` uses bare black rectangles with no eye anatomy, so it validates this proxy rather than rejecting the false-pass case. A sufficiently large target-local dark artifact also satisfies the changed-pixel/delta gates while avoiding outside/protected gates. That violates the documented guarantee that arbitrary pixel change cannot accept a direction (`example-images/README.md:108-112`).

**Fix:** Derive request-local pupil and own-eye contour support from an independently validated anatomical source, keep that geometry transient, and measure pupil position relative to the observed eye center. Add adversarial fixtures where lashes/makeup/shadows or a foreign dark patch move while the pupil stays fixed (must fail), the pupil moves correctly with stable eye support (must pass), peer-eye support is missing (must not be borrowed), and anatomical support is absent (must be non-creditable admission rather than a complete result).

### CR-04: BLOCKER — Hidden files bypass exact output admission and can be retained

**Files:** `scripts/compare-face-feature-batches.swift:1100-1140`, `scripts/compare-face-feature-batches.swift:1172-1207`, `scripts/run-face-feature-batches.sh:536-547`

**Issue:** Both fixture and run-root enumeration use `.skipsHiddenFiles`. For run admission this means an unexpected hidden regular file, directory, report, or transcript is invisible to `discovered == expectedPaths`. The runner performs no independent final tree inventory and sets `retain_first_attempt=1`, so a hidden child artifact is retained while the report and documentation claim the attempt contains exactly 66 watermarked PNGs and nothing else (`SECURITY.md:296-300`, `RELIABILITY.md:329-333`, `PLANS.md:522`). This is a privacy leak if a renderer change or failure path emits a hidden transcript/diagnostic.

**Fix:** Enumerate hidden entries and reject every entry not in the exact expected directory/file inventory. Before retention, independently walk the first attempt without hidden-file skipping and require exactly the expected 66×fixture PNG set, zero other regular files, zero symlinks, and only expected directories. Add mutation tests for hidden files, hidden directories, hidden symlinks, and hidden renderer reports.

### CR-05: BLOCKER — Cleanup failures are silently accepted after successful publication

**File:** `scripts/run-face-feature-batches.sh:199-224,536-547`

**Issue:** Cleanup suppresses every `safe_remove_attempt` failure with `|| true` and never verifies that the repeat attempt or temporary workspace is gone. On the successful path, the report is marked finalized and the first attempt is marked retained before the EXIT trap performs cleanup. An `rm -rf` failure, identity-check failure, permissions problem, or filesystem fault can therefore leave repeat portrait media and comparator reports while the command still exits `0` or `3` and publishes the documented “removed on every exit” claim. This violates the Phase 89 privacy and retention boundary.

**Fix:** Perform and verify repeat/workspace/report cleanup before final report publication and before setting the retain flag. Treat any remaining private artifact as `infrastructure_failure`, publish only the sanitized failure envelope, and return exit `2`. Make cleanup return status instead of swallowing it, verify absence with no-follow ownership checks, and add forced cleanup-failure tests that prove semantic success/failure cannot be published when cleanup is incomplete.

## Warnings

### WR-01: WARNING — Report validation does not verify failure reasons against the metrics

**File:** `scripts/compare-face-feature-batches.swift:1339-1394`

**Issue:** `validateStablePayload` checks that reason strings are allowlisted and that empty/non-empty reasons agree with the verdict, but it validates metric gates only in one direction: a `semantic_pass` must satisfy them. A `semantic_fail` with fully passing metrics and an arbitrary allowlisted reason is accepted, as is a failure row whose reason codes do not correspond to its actual failed gates. A deterministic generator regression would survive both attempts and create a stable false failure.

**Fix:** Recompute the exact expected reason set from the aggregate fields and the frozen contract, require equality with `failureReasonCodes`, and derive the verdict from that set. Represent metric admission separately because aggregate numeric fields cannot reconstruct a skipped measurement. Add report mutations for an extra reason, missing reason, wrong reason, and `semantic_fail` with all gates passing.

### WR-02: WARNING — Path checks are vulnerable to check/use replacement

**File:** `scripts/run-face-feature-batches.sh:227-240,370-380,536-538`

**Issue:** Admission validates path components, releases that check, and later performs `mkdir`, `mktemp`, `mv`, and recursive deletion by pathname. `publish_failure_envelope` even runs `mkdir -p` before its second `admit_paths` call. A concurrently replaced parent component can redirect creation, publication, or cleanup outside the previously admitted owner-local root. The same-account/automation-only deployment narrows exploitability, but the implementation does not meet its stated non-symlink trust boundary under filesystem races.

**Fix:** Hold no-follow directory descriptors for admitted roots and use descriptor-relative creation/rename/deletion (`openat`/`mkdirat`/`renameat` with `O_NOFOLLOW`-style checks), or move the orchestration into a helper that provides those primitives. At minimum, re-admit before every mutation, verify the created child's parent identity immediately afterward, and never recursively delete through an unverified pathname. Add a parent-swap mutation test.

---

_Reviewed: 2026-08-26T03:42:31Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
