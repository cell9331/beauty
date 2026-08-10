---
phase: 64-sclera-output-adversarial-safety-and-independent-closeout
plan: "14"
subsystem: testing
tags: [swiftpm, xctest, privacy, source-freeze, candidate-guard]
requires:
  - phase: 64-13
    provides: complete fifteen-owner quarantine after the immutable failed candidate
provides:
  - privacy-safe one-child zero-skip SwiftPM runner with exact eight-test opt-in authority
  - source-bound 19-plan/34-task post-repair closeout checker
  - guarded candidate validation and explicit final/quarantine modes
affects: [64-15, 64-16, 64-17, 64-18, 64-19, phase-65]
tech-stack:
  added: []
  patterns: [fixed aggregate child output, exact suite-qualified XCTest identity, pre-write candidate baseline]
key-files:
  created:
    - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-no-skip-swiftpm-runner.js
  modified:
    - .planning/phases/59-teeth-evidence-and-admission-contract/59-private-evidence-runner.js
    - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py
key-decisions:
  - "The full-suite gate accepts one nonzero XCTest aggregate only when failures and skips are zero and all eight suite-qualified opt-ins pass exactly once."
  - "Plans 64-01 through 64-13 retain bounded historical structure treatment; Plans 64-14 through 64-19 use the current schema while the whole 19/34 graph remains exact."
  - "The failed Plan 64-12 candidate remains immutable history and cannot satisfy post-repair authority."
patterns-established:
  - "Private fixture locators enter one child environment and never appear in arguments, forwarded output, or durable logs."
  - "Candidate authority is bound to a random guard nonce, exact owner/source/authority manifests, and a candidate-only repository delta."
requirements-completed: [SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05]
coverage:
  - id: D1
    description: Request-local no-skip SwiftPM execution contract
    requirement: SCLERA-18
    verification:
      - kind: integration
        ref: node 64-no-skip-swiftpm-runner.js --self-test
        status: pass
    human_judgment: false
  - id: D2
    description: Exact post-repair inventory, review-source, candidate, and quarantine authority checker
    requirement: SCLERA-18
    verification:
      - kind: integration
        ref: python3 check_phase64_sclera_closeout.py --self-test
        status: pass
    human_judgment: false
duration: 32 min
completed: 2026-08-10
status: complete
---

# Phase 64 Plan 14: Repair Mandatory Command Gates Summary

**A privacy-safe zero-skip SwiftPM runner and a 19-plan/34-task post-repair authority checker replace both disqualifying Plan 64-12 command gates without changing production behavior.**

## Performance

- **Duration:** 32 min
- **Started:** 2026-08-10T02:13:15Z
- **Completed:** 2026-08-10T02:45:30Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Added one unfiltered SwiftPM child that opts in all six Vision and both rights-gated fixture tests, rejects fail/skip/zero/ambiguous output, and emits only a fixed six-key aggregate.
- Replaced the stale checker RED with positive and negative source-bound review tests, exact 19-plan/34-task graph validation, and distinct post-repair authority paths.
- Added memory-bound candidate baseline, random nonce, exact owner/source/authority manifests, candidate-only delta enforcement, live validation, and final/quarantine modes.

## Task Commits

1. **Task 1 RED: Freeze the failing no-skip runner contract** - `cd4e1c1`
2. **Task 1 GREEN: Implement the request-local no-skip runner** - `d8ac4a9`
3. **Task 2: Repair review, inventory, candidate, and quarantine authority** - `5685bc9`
4. **Task 1 RED follow-up: Cover nested XCTest summaries** - `b72f328`
5. **Task 1 GREEN follow-up: Bind counts to the `All tests` summary** - `dc254ec`

## Files Created/Modified

- `.planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-no-skip-swiftpm-runner.js` - Exact full-suite opt-in executor and parser.
- `.planning/phases/59-teeth-evidence-and-admission-contract/59-private-evidence-runner.js` - Exports the existing unchanged `assertIgnoredBundle` validator.
- `.planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py` - Post-repair source, inventory, candidate, and final-state authority.

## Decisions Made

- The Task 2 RED was the pre-existing reproducible checker self-test failure recorded by the immutable Plan 64-12 candidate; no artificial second failing commit was created.
- Failure output remains aggregate-only. No debug escape hatch can print private runner errors or locators.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Correctness] Strengthened the opt-in mutations to target an exact suite-qualified test**
- **Found during:** Task 1 recovery after executor quota exhaustion
- **Issue:** The partial executor implementation's missing/duplicate/failed mutations initially changed an ordinary XCTest row rather than an exact opt-in row.
- **Fix:** Bound all three mutations to the first exact suite/method identity and removed a debug stderr escape hatch.
- **Files modified:** `64-no-skip-swiftpm-runner.js`
- **Verification:** Runner self-test passes exactly 14 rejection cases; unknown mode returns the fixed six-key failure aggregate.
- **Committed in:** `d8ac4a9`

**2. [Rule 1 - Correctness] Accepted real XCTest output with nested suite summaries**
- **Found during:** Plan 64-15 fresh no-skip execution
- **Issue:** The parser counted every nested suite's `Executed ...` row and rejected a valid full run as ambiguous even though the single `All tests` suite was green.
- **Fix:** Added a nested-suite RED fixture and bound the authoritative count to the one summary immediately following the passed `All tests` line.
- **Files modified:** `64-no-skip-swiftpm-runner.js`
- **Verification:** Runner self-test passes all 14 fail-closed mutations while accepting the realistic nested-suite positive transcript.
- **Committed in:** `dc254ec`

---

**Total deviations:** 2 auto-fixed correctness issues. **Impact:** The repair is narrower and more privacy-safe than the partial implementation; no product, API, Demo, runtime, model, network, dependency, DeviceRGB, or `去脂` behavior changed.

## Issues Encountered

- The typed executor reached its usage limit after the Task 1 RED commit. Safe-resume preserved that commit, verified and completed its partial GREEN changes, then executed Task 2 inline without redispatching duplicate work.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 64-15 to execute the fresh no-skip conjunction and author distinct post-repair evidence, review, code-review, review-fix, security, and eligibility artifacts. Canonical Phase 64 remains `gaps_found`; all product and Phase 65 authority remains quarantined.

## Self-Check: PASSED

- Runner self-test: 14/14 fail-closed mutations plus one positive transcript.
- Checker self-test: 18 aggregate/structure mutations, 23 four-state content-scan rejections, 11 review-source rejections, and 20 candidate rejections.
- Plan structure: Plans 64-14 through 64-19 all valid.
- Live pre-promotion remains closed because fresh Plan 64-15 authority does not yet exist.
- `git diff --check`: pass.

---
*Phase: 64-sclera-output-adversarial-safety-and-independent-closeout*
*Completed: 2026-08-10*
