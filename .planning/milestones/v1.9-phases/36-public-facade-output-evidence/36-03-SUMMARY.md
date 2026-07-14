---
phase: 36-public-facade-output-evidence
plan: "03"
subsystem: renderer-gallery-closeout
tags: [python, gallery, swiftpm, asvs, nyquist, public-facade]

requires:
  - phase: 36-public-facade-output-evidence
    plan: "02"
    provides: strict discovered 36-by-7 renderer output decoder and fixed ROI evidence
provides:
  - exact duplicate-free renderer-to-gallery case bijection with 252 ignored review PNGs
  - fresh focused/full SwiftPM and post-documentation renderer/helper/gallery closeout evidence
  - passed Phase 36 verification, ASVS L1 zero-open-threat review, and Nyquist validation
affects: [37-nose-safety-boundary, v1.9-audit]

tech-stack:
  added: []
  patterns: [discovered renderer inventory before gallery copy, post-documentation Nyquist rerun, explicit no-promotion baseline guard]

key-files:
  created:
    - .planning/phases/36-public-facade-output-evidence/36-VERIFICATION.md
    - .planning/phases/36-public-facade-output-evidence/36-SECURITY.md
  modified:
    - example-images/generate_gallery.py
    - example-images/README.md
    - docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md
    - .planning/phases/36-public-facade-output-evidence/36-VALIDATION.md
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md
    - .planning/STATE.md
    - PLANS.md

key-decisions:
  - "Require flattened gallery case IDs to be duplicate-free and exactly equal the renderer's discovered RenderCase IDs before any copy."
  - "Set Nyquist compliant only after a second complete focused/full SwiftPM and clean renderer/helper/gallery pass over the written closeout documents."
  - "Close only NOSE-07 through NOSE-09 while leaving every cap, provider, resolver, product ledger, current product snapshot, Demo, and package owner unchanged."

patterns-established:
  - "Gallery inventory drift fails closed before destructive gallery regeneration or copy."
  - "Evidence-only phases guard later promotion owners by exact baseline diff, not wording alone."

requirements-completed: [NOSE-07, NOSE-08, NOSE-09]

duration: 12 min
completed: 2026-07-13
---

# Phase 36 Plan 03: Gallery and Public-Facade Output Closeout Summary

**An exact renderer/gallery inventory produces 252 ignored review PNGs, while fresh 10-test focused, 220-test full, strict output, security, and Nyquist gates close only NOSE-07 through NOSE-09.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-07-13T09:27:19Z
- **Completed:** 2026-07-13T09:38:20Z
- **Tasks:** 2
- **Files modified:** 10

## Accomplishments

- Added `noseRootNarrowing_0p25` and `noseTipLift_0p25` to gallery routing and made gallery generation reject duplicate or mismatched case inventories before copying.
- Regenerated exactly 252 ignored, untracked gallery PNGs from the exact 252-output public-facade matrix and synchronized only the live output-evidence documentation owners.
- Passed the final post-documentation 10/10 focused and 220/220 full SwiftPM suites, renderer build, guarded clean render, strict 252/252 helper, 252-file gallery, containment, privacy/import, dependency/external-path, schema-drift, no-promotion, and diff-hygiene gates.
- Created passed verification, ASVS L1 `threats_open: 0`, and final Nyquist evidence; closed only NOSE-07, NOSE-08, and NOSE-09.

## Task Commits

Each task was committed atomically:

1. **Task 36-03-01: Extend gallery routing and prove exact ignored containment** - `f85227a` (feat)
2. **Task 36-03-02: Run final regression/security/Nyquist gate and close only Phase 36** - `059d3dc` (docs)

## Files Created/Modified

- `example-images/generate_gallery.py` - Discovers renderer IDs and requires exact duplicate-free equality with flattened gallery groups before copy.
- `example-images/README.md` - Records the two new routes, live helper command, exact matrix/comparison counts, and Phase 37 boundary.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` - Adds the Phase 36 cases, observed fixed-ROI evidence, no-face result, containment, and precise non-claims.
- `.planning/phases/36-public-facade-output-evidence/36-VERIFICATION.md` - Records the observed passed NOSE-07 through NOSE-09 verdict.
- `.planning/phases/36-public-facade-output-evidence/36-SECURITY.md` - Records the ASVS L1 threat register and zero open high-severity threats after all gates passed.
- `.planning/phases/36-public-facade-output-evidence/36-VALIDATION.md` - Finalizes every task row, Wave 0 evidence, and post-documentation Nyquist result.
- `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` - Close Phase 36 only and route next to the unstarted Phase 37.

## Verification

- `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests` passed 10/10 with zero failures.
- `swift test --package-path BeautySDK` passed 220/220 with zero failures.
- `BeautyExampleRenderer` built, then a guarded clean run wrote exactly 36 × 7 = 252 PNGs.
- The strict helper fully decoded 252/252 same-dimension PNGs and passed 12/12 baseline, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face comparisons at the fixed thresholds.
- Gallery generation validated the exact renderer bijection and wrote 252/252 ignored, untracked PNGs.
- Public/internal import, raw geometry/privacy, dependency, network/cloud/commercial, generated-artifact, schema-drift, no-promotion, boundary, and `git diff --check` gates passed.
- The complete sequence was rerun after closeout docs were written before `nyquist_compliant: true` was recorded.

## Decisions Made

- Used the renderer source as the executable gallery inventory authority while retaining explicit feature-family grouping for review layout.
- Kept `0.25` factual and provisional; output visibility and independence do not establish final caps.
- Kept Phase 37 entirely unstarted and left `山根`, `提升`, and branch-level `鼻子` unpromoted.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Split representative ignore validation into one path per Git invocation**

- **Found during:** Task 36-03-01 acceptance verification
- **Issue:** The installed Git rejects `git check-ignore -q` with multiple pathnames (`--quiet is only valid with a single pathname`).
- **Fix:** Ran the same fail-closed ignore assertion once for each of the four representative output/gallery paths in both task and final gates.
- **Files modified:** None.
- **Verification:** All four individual `git check-ignore -q` invocations passed; full tracked and staged generated-root queries were empty.
- **Committed in:** No source change required; the task result is in `f85227a`.

---

**Total deviations:** 1 auto-fixed blocking command incompatibility. **Impact on plan:** Verification remained equally strict and every required path was checked; implementation scope and evidence claims were unchanged.

## Issues Encountered

The standard-library helper intentionally takes longer than a header-only scan because it fully decodes all 252 PNG streams. Both clean strict runs completed successfully.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 36 is complete at 3/3 with NOSE-07 through NOSE-09 passed and Phase 37 still unstarted.
- Phase 37 retains final cap calibration, exhaustive six-field degradation/provider-empty behavior, exactly-once combined weakening, final active-source boundary closeout, atomic `山根`/`提升` promotion, branch completion, and DOC-01.
- Product ledgers, nose README, PROJECT, QUALITY_SCORE, providers/resolvers/caps, Package.swift, and Demo remain unchanged from the Phase 36-03 baseline.

## Self-Check: PASSED

---
*Phase: 36-public-facade-output-evidence*
*Completed: 2026-07-13*
