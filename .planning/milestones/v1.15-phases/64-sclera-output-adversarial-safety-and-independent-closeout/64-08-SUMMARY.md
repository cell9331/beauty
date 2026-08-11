---
phase: 64-sclera-output-adversarial-safety-and-independent-closeout
plan: "08"
subsystem: sclera-security
tags: [privacy-scanner, git-objects, source-freeze, strict-helper, fail-closed]
requires:
  - phase: 64-07
    provides: corrected historical leak containment and inclusive contour validation
provides:
  - four-state content scanner over HEAD blobs, index blobs, working files, and non-ignored untracked files
  - immutable relevant-source tree/blob binding for original-detail review authority
  - distinct strict-helper self-test and live-child execution evidence
  - exact thirteen-plan and twenty-four-task serial closeout inventory
affects: [64-09, 64-10, 64-11, 64-12, 64-13]
tech-stack:
  added: []
  patterns: [nul-safe-git-inventory, bounded-nofollow-read, immutable-review-manifest, exact-child-json-classification]
key-files:
  created:
    - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-08-SUMMARY.md
  modified:
    - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py
    - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-private-output-runner.js
key-decisions:
  - "Repository privacy authority scans bytes from each Git/filesystem state independently and never substitutes one state for another."
  - "A stale review is accepted only as proof of quarantine; review authority requires the exact sorted relevant-source tree/blob manifest to match the frozen tree, current index, and bounded working bytes."
  - "Strict-helper self-test and live output are separate child invocations with role-specific exact JSON schemas; neither result can stand in for the other."
patterns-established:
  - "T-64-06 emits only status and four aggregate counts; every failure emits the same path-free zero-count object."
  - "T-64-05 permits later non-relevant owner synchronization while invalidating review after any relevant source/index/working-byte change."
requirements-completed: [SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05]
coverage:
  - id: D1
    description: "All four repository states are content-scanned with bounded fail-closed object and filesystem reads, private digest/media/anatomy detection, and fixed aggregate output."
    requirement: SCLERA-18
    verification:
      - kind: unit
        ref: "check_phase64_sclera_closeout.py --self-test (23 content-scan mutations)"
        status: pass
      - kind: integration
        ref: "check_phase64_sclera_closeout.py --pre-promotion --threat T-64-06 (1464/1464/0/0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Original-detail review authority is bound to an immutable exact relevant-source tree/blob manifest and rejects stale, malformed, future, or changed-source state."
    requirement: SCLERA-16
    verification:
      - kind: unit
        ref: "check_phase64_sclera_closeout.py --self-test (7 source-freeze mutations)"
        status: pass
      - kind: other
        ref: "check_phase64_sclera_closeout.py --pre-promotion (stale review remains quarantined)"
        status: pass
    human_judgment: false
  - id: D3
    description: "The private runner proves strict-helper self-test and real six-output live execution separately without forwarding child evidence."
    requirement: OUT-05
    verification:
      - kind: unit
        ref: "64-private-output-runner.js --self-test"
        status: pass
      - kind: integration
        ref: "PHASE64_REQUIRE_LOCAL_EVIDENCE=1 64-private-output-runner.js (outputs 6; both strict fields pass)"
        status: pass
    human_judgment: false
  - id: D4
    description: "The checker owns exactly thirteen plans and twenty-four ordered tasks while later promotion-pending and final authority remain unavailable."
    requirement: SCLERA-18
    verification:
      - kind: integration
        ref: "check_phase64_sclera_closeout.py --pre-promotion; pending/final negative gates"
        status: pass
    human_judgment: false
duration: 20min
completed: 2026-08-09
status: complete
---

# Phase 64 Plan 08: Content Trust and Strict-Helper Live Proof Summary

**Phase 64 now reads every active repository byte state fail-closed, binds review authority to immutable relevant source blobs, and separately proves real strict-helper live execution.**

## Performance

- **Duration:** 20 min
- **Started:** 2026-08-09T07:05:12Z
- **Completed:** 2026-08-09T07:25:33Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Replaced filename inventory trust with NUL-safe HEAD-tree and stage-0 index blob reads plus bounded no-follow working/untracked regular-file reads. Deletions are explicit, merge stages and nonregular entries fail closed, and no state falls back to another.
- Added filename-independent detection for active sensitive fields, structured raw support/mask/geometry/coordinates, vein-like detail, private media signatures/decoded content, and exact authorized local asset digests retained only in memory.
- Added 23 scanner mutations across sensitive HEAD/index/working/untracked states, media/digest/geometry, malformed inventory, Git/object/tool failures, symlink/nonregular/empty/oversize/read failures, and unsafe paths. T-64-06 emits only fixed aggregate counts.
- Bound fresh review authority to an exact sorted sixteen-file relevant-source closure. Seven mutations reject missing, malformed, future, reordered, wrong-blob, staged, and working-source changes while later non-relevant synchronization remains valid.
- Updated the lifecycle authority to exactly 13 plans and 24 ordered task IDs, with Plans 09 through 13 retaining pre-promotion, product/root, lifecycle/validation, candidate, and final ownership respectively.
- Added a strict-helper child classifier and 14 mutation rejections for process failure, timeout, ambiguous/malformed output, wrong cardinality, self-test/live swapping, forged live status, path leakage, raw stderr, suppression, and invalid roles.
- Executed the actual private six-output route: the runner returned only fixed `outputs: 6`, `strict_helper_self_test: pass`, and `strict_helper_live: pass` fields.

## Task Commits

Each TDD task was committed at its RED and GREEN gates:

1. **Task 1 RED: Freeze content trust and immutable-review contracts** — `923b0d8`
2. **Task 1 GREEN: Bind privacy and review gates to immutable content** — `402e482`
3. **Task 2 RED: Freeze strict-helper live execution contracts** — `db60ca8`
4. **Task 2 GREEN: Prove strict-helper live child execution** — `80dd191`

## Files Created/Modified

- `.planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py` — owns the four-state content scanner, source-freeze validator, 13/24 lifecycle graph, fixed privacy output, and mutation suites.
- `.planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-private-output-runner.js` — owns exact role-specific helper-child classification and distinct fixed self-test/live results.
- `.planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-08-SUMMARY.md` — records bounded execution evidence and the Plan 09 handoff.

## Decisions Made

- Read immutable HEAD/index bytes through Git objects and live working/untracked bytes through bounded no-follow descriptors. A clean filename or allowlisted path never grants content trust.
- Keep the current stale review visibly quarantined. It satisfies no review authority; only a later exact tree/blob manifest can make T-64-05 current.
- Treat the relevant-source manifest as the narrow review invalidation boundary. Product/root/lifecycle-only synchronization can follow review, but provider/transform/composition/engine/renderer/test/helper/checker/runner/gallery changes cannot.
- Validate helper children by exact role-specific schemas and suppress all raw stdout/stderr. A self-test result cannot be relabeled as live proof.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Initial scanner development exposed two self-referential fixture hazards: resolving a symlink before `O_NOFOLLOW` bypassed the descriptor guard, and an inline base64 mutation seed matched its own working source. The implementation now preserves the lexical target for no-follow open and constructs the seed from split source fragments; both cases are covered by passing mutations.

## Verification Evidence

- Checker self-test: 18 retained aggregate mutations, 23 content-scanner mutations, and seven relevant-source review mutations passed.
- Live pre-promotion checker: all eight HIGH owners passed with nonzero counts; stale review remained explicitly ineligible and all product owners remained quarantined.
- Isolated T-64-06: fixed aggregate reported `1464` HEAD blobs, `1464` index blobs, `0` working files, and `0` untracked files after task commits.
- Strict runner self-test: fixed `strict_helper_self_test: pass` after 14 rejected child mutations.
- Strict runner live: six decoded outputs passed with distinct fixed self-test and live-child fields.
- Promotion-pending and final modes both failed as required before Plans 09 through 13 create independent authority.
- JavaScript syntax, Python compilation/execution, all isolated HIGH selectors, and `git diff --check` passed.

## Known Stubs

None.

## Threat Flags

None. Git object/filesystem reads and strict-helper child execution are the exact trust boundaries mapped by T-64-05, T-64-06, T-64-02, and T-64-08; no new network, authentication, schema, public API, or durable private-evidence surface was introduced.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 64-09 can run the complete fresh output/native/private/full-regression conjunction, perform independent code/security review, create the immutable relevant-source freeze, and conduct a new blinded original-detail review.
- The current review remains stale, product owners remain quarantined, canonical verification remains `gaps_found`, and Phase 65 stays blocked.
- DeviceRGB/named-sRGB and SAFE-06 remain exclusive Phase 65 scope.

## Self-Check: PASSED

- Both modified implementation files and this summary exist.
- TDD commits `923b0d8`, `402e482`, `db60ca8`, and `80dd191` exist in repository history.
- Plan-prescribed self-test, live pre-promotion, isolated HIGH, privacy, strict live-child, pending/final negative, syntax, and diff-hygiene gates passed.

---
*Phase: 64-sclera-output-adversarial-safety-and-independent-closeout*
*Completed: 2026-08-09*
