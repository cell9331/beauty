---
phase: 58-combined-facade-safety-ledger-and-audit-closeout
plan: "01"
subsystem: testing
tags: [swiftpm, xctest, ios-simulator, mutation-testing, asvs, zero-admission, publication-discard]

requires:
  - phase: 54-rights-approved-evidence-and-eligibility-decisions
    provides: exact three closed feature decisions with zero product weight
  - phase: 55-original-pixel-composition-and-failure-isolation-core
    provides: feature-neutral six-counter composition mechanics and literal-empty admission
  - phase: 57-guarded-sclera-slice-and-conditional-upper-eyelid-work
    provides: frozen 519-case closed-eye audit and exact future/partial ledgers
provides:
  - focused zero-admission SDK, facade, publication-discard, compatibility, and neutral-composition specifications
  - exact three-disabled-row Demo zero-promotion specification
  - ordered T-58-01 through T-58-08 ASVS Level 1 HIGH inventory
  - configurable fail-closed Phase 58 checker with representative real-fixture mutations
  - draft aggregate-only closeout evidence with final lifecycle explicitly pending
affects: [58-02, 58-03, 58-04, milestone-closeout, privacy, compatibility, zero-promotion]

tech-stack:
  added: []
  patterns: [host publication discard, exact empty-set conjunction, real-fixture fail-closed mutation testing]

key-files:
  created:
    - .planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py
    - .planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/58-THREAT-INVENTORY.json
    - .planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/58-CLOSEOUT-EVIDENCE.md
  modified:
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
    - BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
    - BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift

key-decisions:
  - "Cancellation evidence is caller publication discard after one intact synchronous opaque invocation; it neither aborts SDK work nor resolves TD-013."
  - "The Phase 58 checker enforces the empty admitted/promotion sets without becoming a second eligibility authority."
  - "Draft evidence contains fixed IDs and aggregate counts only; final suites, review, verifier, and milestone lifecycle remain pending."

patterns-established:
  - "Zero-admission conjunction: extend current owners to assert literal .none, 59/5/72, both facades, no-op output, and zero non-still local work."
  - "Representative HIGH seed: every threat receives a real-owner mutation plus missing, unreadable, and unclassified-scanner failure coverage."

requirements-completed: []

duration: 20min
completed: 2026-08-04
---

# Phase 58 Plan 01: Zero-Admission Boundary Summary

**Exact empty SDK admission, host publication discard, 59/5/72 compatibility, three disabled Demo rows, and an eight-HIGH fail-closed closeout checker**

## Performance

- **Duration:** 20 min
- **Started:** 2026-08-04T06:58:00Z
- **Completed:** 2026-08-04T07:18:00Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments

- Extended existing SDK owners to prove both still-image facades remain deterministic no-ops under literal empty admission, compatibility remains exactly 59 fields / 5 presets / 72 renderer cases, errors remain typed and payload-free, and opaque composition exposes exactly six counters.
- Added deterministic caller-publication cancellation coverage: one synchronous invocation completes intact, canceled publication is discarded, request support is retained nowhere, and a fresh request publishes only its own aggregate value.
- Preserved exactly the disabled `lips.teeth` / `白牙`, `eyes.redness` / `祛红血丝`, and `eyes.fat` / `去脂` Demo rows, current order/icons/badges/unavailable copy, nil controls, and empty promotion set.
- Created the ordered T-58-01 through T-58-08 HIGH inventory, one configurable-root checker, 32 representative real-fixture/missing/unreadable/scanner cases, and draft fixed-ID evidence without production or ledger changes.

## Task Commits

Each task was committed atomically:

1. **Task 58-01-01: Freeze focused zero-admission SDK, facade, privacy, and compatibility specifications** — `bca80fb` (test)
2. **Task 58-01-02: Pin three disabled Demo rows and establish the eight-row fail-closed audit** — `ca5e7c3` (test)

## Files Created/Modified

- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift` — literal empty admission, canonical no-op, typed error, both facade entries, publication discard, fresh-request isolation, and zero retention.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift` — exact six aggregate counters without feature labeling.
- `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` — exact 59 stored/CodingKey/encoded shape and canonical candidate absence.
- `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` — exact five preset IDs/sources with no candidate keys.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` — exact 72 cases and no candidate output route.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` — exact three disabled rows, order, copy, nil mapping, and store neutrality.
- `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/check_phase58_milestone_closeout.py` — configurable-root live classifier, tri-state scanner, fixed-rule output, representative real-fixture mutations, and top-level exception collapse.
- `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/58-THREAT-INVENTORY.json` — exact ordered eight-HIGH ASVS L1 ownership.
- `.planning/phases/58-combined-facade-safety-ledger-and-audit-closeout/58-CLOSEOUT-EVIDENCE.md` — strict draft seven-disposition/task/eight-HIGH aggregate-only evidence.

## Verification Results

- Focused SwiftPM selection passed **156/156**, zero failures/skips.
- Focused `BeautyEngineLocalRetouchFoundationTests` rerun passed **23/23** after the typed-error expectation was aligned with the existing `unsupportedPixelFormat` contract.
- Focused iPhone 17e / iOS 26.5 Demo owner passed **30/30**, zero failures.
- Phase 58 checker aggregate self-test passed **32/32** across eight HIGH identities; each `--self-test --only T-58-0N` passed **4/4**.
- Checker live mode, JSON parsing, Python bytecode compilation, and `git diff --check` passed.
- Full SwiftPM, opt-in Vision, full Demo, completed-state adaptation, root synchronization, review, verifier, phase transition, and milestone audit were intentionally not run; Plans 58-02 through 58-04 and the external lifecycle own them.

## Decisions Made

- Kept the cancellation gate entirely test-local: the synchronous invocation completes before the host publication wrapper observes cancellation, so no cooperative-abort or generic Sendability contract is implied.
- Reused existing test inventories instead of adding a candidate-specific production or parallel inventory.
- Seeded every HIGH identity with the same four fail-closed case classes while reserving complete mutation matrices for their exact Plan 02/03 owners.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Swift's region-isolation checker rejected the first task closure that captured the synchronous harness. The test was reshaped to complete the invocation first and cancel only the publication wrapper, which is also the exact D-58-07 contract.
- The initial transparent-input assertion expected `invalidInput`; the existing canonicalizer correctly returns payload-free `unsupportedPixelFormat`. The test now asserts that exact production contract.
- Xcode emitted the existing empty-supported-platform diagnostic before using the explicit simulator destination; the focused Demo suite still passed 30/30.

## Known Stubs

- `58-CLOSEOUT-EVIDENCE.md` intentionally remains `draft`; Plans 58-02 through 58-04 own the pending lifecycle, full regression, review, and verifier rows.
- The Demo unavailable copy is the required zero-promotion state, not an active implementation stub; all three controls remain nil.

## User Setup Required

None - no browser, file selection, image review, external service, or human checkpoint is required.

## Next Phase Readiness

- Plan 58-02 can extend the single checker and existing foundation/composition owners with complete request-lifetime and T-58-01 through T-58-06 matrices.
- Production source, Phase 54 decisions, Phase 55 mechanics, Phase 57 checker, root owners, ledgers, media, and requirement statuses remain unchanged.

## Self-Check: PASSED

- All nine declared implementation/evidence files exist.
- Task commits `bca80fb` and `ca5e7c3` exist in repository history.
- Focused SDK 156/156, focused Demo 30/30, aggregate checker 32/32, all eight independent threat modes 4/4, checker live, JSON/Python syntax, and diff hygiene passed.

---
*Phase: 58-combined-facade-safety-ledger-and-audit-closeout*
*Completed: 2026-08-04*
