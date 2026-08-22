---
phase: 80-genuine-evidence-and-qualification-gate
plan: "01"
subsystem: qualification
tags: [node, canonical-json, sha256, private-evidence, fail-closed, privacy]

requires:
  - phase: v1.18/75-semantics-and-genuine-evidence-contract
    provides: frozen semantic, evidence-category, metric, and blinded-review authorities
  - phase: v1.18/77-deterministic-editor-and-safety-evidence
    provides: bounded deterministic editor and immutable-original composition mechanics
  - phase: v1.18/79-conditional-productization-and-sdk-only-closeout
    provides: current deterministic-editor digests, focused-test identity, and exact 61/5/74 absence
provides:
  - frozen Phase-80 private bundle, metric, color, review, canonicalization, and decision contract
  - standard-library local CLI with bounded descriptor admission and aggregate-only decisions
  - fail-closed Node coverage for admission, metrics, review, bindings, privacy, and non-fabrication
affects: [80-02, 80-03, 80-04, 80-05, 80-06, phase-81-public-activation]

tech-stack:
  added: []
  patterns: [strict schema allowlists, canonical UTF-8 JSON, descriptor-bound SHA-256, normalized aggregate failures]

key-files:
  created:
    - .planning/phases/80-genuine-evidence-and-qualification-gate/80-QUALIFICATION-CONTRACT.md
    - .planning/phases/80-genuine-evidence-and-qualification-gate/80-qualification-decision.js
    - .planning/phases/80-genuine-evidence-and-qualification-gate/80-qualification-decision.test.js
    - .planning/phases/80-genuine-evidence-and-qualification-gate/80-01-SUMMARY.md
  modified: []

key-decisions:
  - "A blinded pass is polarity-specific: genuine positives require visible target reduction, while negative and stress rows require target absence plus natural/protected source preservation."
  - "Color qualification is frozen to opaque named-sRGB RGBA8 integer RGB deltas: target maximum 16, protected maximum 0, and zero tolerance."
  - "Generated and mechanics-only inputs retain evidence weight zero; only complete external genuine facts can reach promotion-ready-deterministic-editor."

patterns-established:
  - "External private facts enter only through the two fixed environment locators and never appear in output or errors."
  - "Invalid/incomplete input is blocking and cannot replace the decision artifact; complete honestly failing evaluation remains a valid executable non-promotion result."

requirements-completed: []

coverage:
  - id: D1
    description: Frozen qualification contract with exact admission, metric, review, canonical encoding, baseline binding, and durable-output rules.
    verification:
      - kind: integration
        ref: python3 contract marker/JSON/hash/color/review assertions
        status: pass
    human_judgment: false
  - id: D2
    description: Standard-library fail-closed qualification CLI with bounded asset admission, live baseline/public-absence binding, and aggregate-only output.
    verification:
      - kind: unit
        ref: .planning/phases/80-genuine-evidence-and-qualification-gate/80-qualification-decision.test.js (27 tests)
        status: pass
      - kind: integration
        ref: node 80-qualification-decision.js --self-test --repo-root .
        status: pass
    human_judgment: false
  - id: D3
    description: Promotion non-fabrication and privacy boundary for missing, mechanics-only, malformed, and sensitive inputs.
    verification:
      - kind: unit
        ref: .planning/phases/80-genuine-evidence-and-qualification-gate/80-qualification-decision.test.js#mechanics-only decision is deterministic and can never reach promotion constant
        status: pass
      - kind: unit
        ref: .planning/phases/80-genuine-evidence-and-qualification-gate/80-qualification-decision.test.js#output allowlist rejects sensitive keys, path-like values, timestamps, prose, and row data
        status: pass
    human_judgment: false

duration: 16 min
completed: 2026-08-23
status: complete
---

# Phase 80 Plan 01: Qualification Contract and Local Gate Summary

**A frozen genuine-evidence qualification contract and standard-library local gate now enforce descriptor-safe admission, exact color/review bounds, live baseline binding, and aggregate-only non-fabricating decisions.**

## Performance

- **Duration:** 16 min
- **Started:** 2026-08-22T16:14:52Z
- **Completed:** 2026-08-22T16:30:58Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Froze exact bundle, asset, metric, polarity-specific review, canonical hash, public-absence, and sanitized decision schemas before private outcomes.
- Implemented local standard-library validation with UTF-8/duplicate-key rejection, bounded regular-descriptor hashing, symlink/traversal/TOCTOU defenses, independent row evaluation, and atomic mode-0600 valid-decision writes.
- Passed 27 focused Node tests plus an 11-check self-test with five isolated binding mutation rejections while retaining `qualification-not-passed` and zero promotion fixtures.

## Task Commits

Each task was committed atomically; the TDD task retained its RED/GREEN sequence:

1. **Task 1: Freeze the complete qualification and canonical-binding contract** - `2d6532b` (docs)
2. **Task 1 correctness follow-up: polarity-specific review predicates** - `4bd1d2f` (fix)
3. **Task 2 RED: failing qualification-gate coverage** - `d5bde2c` (test)
4. **Task 2 GREEN: fail-closed local qualification CLI** - `c2522e1` (feat)

## Files Created/Modified

- `.planning/phases/80-genuine-evidence-and-qualification-gate/80-QUALIFICATION-CONTRACT.md` - Marker-delimited canonical contract for external facts, metrics, review, encoding, bindings, decisions, and privacy.
- `.planning/phases/80-genuine-evidence-and-qualification-gate/80-qualification-decision.js` - Local standard-library evaluator and CLI.
- `.planning/phases/80-genuine-evidence-and-qualification-gate/80-qualification-decision.test.js` - Admission, filesystem, metric, color, review, CLI, privacy, and mutation coverage.
- `.planning/phases/80-genuine-evidence-and-qualification-gate/80-01-SUMMARY.md` - Plan execution evidence and nonclaims.

## Decisions Made

- Negative and stress review passes require no visible target reduction, no proxy, preserved protected structures, and natural original detail; genuine positives alone require visible target reduction.
- Phase-75 evidence hashing uses the live Node-normalized canonical bytes, and the Phase-80 rubric uses the contract's recursive canonical encoding.
- The CLI accepts no private path flag: only `BEAUTY_PHASE80_BUNDLE_MANIFEST` and `BEAUTY_PHASE80_REVIEW_RECORD` may locate external inputs.
- `--write-decision` may replace the fixed artifact only for evaluation-complete input, including an honest valid negative outcome; malformed or incomplete input never replaces it.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Corrected review pass semantics for negative and stress categories**
- **Found during:** Task 2 design review
- **Issue:** An all-true predicate for the Phase-75 target-reduction field would make a safe no-op negative/stress judgment impossible to pass.
- **Fix:** Froze separate positive and negative/stress predicates and rebound the rubric hash.
- **Files modified:** `80-QUALIFICATION-CONTRACT.md`
- **Verification:** Contract JSON/hash assertion and review validator tests pass.
- **Committed in:** `4bd1d2f`

**2. [Rule 1 - Bug] Bound hashes to the executable canonical encodings**
- **Found during:** Task 2 live binding verification
- **Issue:** Initial prose-time hashes preserved Python float spelling/array order instead of the current Phase-75 Node normalization and Phase-80 schema sorting.
- **Fix:** Recomputed the Phase-75 evidence and Phase-80 rubric hashes from their executable canonical bytes and verified live source/evidence digests.
- **Files modified:** `80-QUALIFICATION-CONTRACT.md`, `80-qualification-decision.js`
- **Verification:** `verifyBindings('.')` passes with exact 61/5/74 and pinned source/evidence digests.
- **Committed in:** `c2522e1`

---

**Total deviations:** 2 auto-fixed (2 Rule 1 correctness bugs).
**Impact on plan:** Both fixes were required for an executable, polarity-correct, byte-bound gate; no SDK, archive, dependency, or private-evidence scope was added.

## Issues Encountered

- The first RED-shell wrapper used zsh's reserved `status` name; it was immediately rerun with a task-local variable. The intended RED failure remained the absent implementation module, followed by the passing GREEN suite.

## TDD Gate Compliance

- RED: `d5bde2c` records the failing test suite before the CLI existed.
- GREEN: `c2522e1` follows RED and passes all 27 tests.
- No refactor commit was needed.

## Known Stubs

None. No placeholder, TODO, mock data source, generated decision artifact, or promotion override remains.

## Security and Privacy Result

- Threats T-80-01 through T-80-07 are represented by environment-only locators, exact schemas, bounded descriptor admission, canonical hashes, live baseline/public binding, strict durable allowlists, and non-promotion tests.
- No new threat surface outside the plan's threat register was introduced.
- Durable output contains fixed versions/hashes/enums, opaque fixture IDs, aggregate counts/metrics, normalized reasons, exact 61/5/74, and one decision only.

## Requirement and Product Nonclaims

No genuine evidence, rights assertion, private review, reviewer identity, or human judgment was supplied by this plan. Therefore EVID-03/EVID-04/EVID-05 and QUAL-03/QUAL-04/QUAL-05 remain pending external execution despite the completed gate mechanics. This plan makes no efficacy, naturalness, device, commercial, packaging, shipping, launch, or release-readiness claim and changes no public SDK surface.

## User Setup Required

None for Plan 80-01. Later private checkpoint plans supply external bundle/review locators without committing them.

## Next Phase Readiness

- Ready for `80-02-PLAN.md` to exercise the private genuine-bundle admission path.
- Phase 81 remains blocked unless the complete external bundle and blinded review produce the exact passing bound decision.

## Self-Check: PASSED

- All four plan artifacts exist.
- Commits `2d6532b`, `4bd1d2f`, `d5bde2c`, and `c2522e1` exist in history.
- Contract verification, 27/27 Node tests, 11-check self-test, privacy scan, live baseline binding, exact 61/5/74 absence, and `git diff --check` passed.

---
*Phase: 80-genuine-evidence-and-qualification-gate*
*Completed: 2026-08-23*
