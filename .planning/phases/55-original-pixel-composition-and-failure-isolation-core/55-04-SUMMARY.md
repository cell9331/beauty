---
phase: 55-original-pixel-composition-and-failure-isolation-core
plan: "04"
subsystem: facade-composition-integration
tags: [swiftpm, testing-spi, canonical-image, failure-isolation, privacy, asvs]

requires:
  - phase: 55-03
    provides: deterministic request-local Q16 composer with exact six-count summary
provides:
  - one opaque Testing-only facade composer invocation from the exact request-context canonical carrier
  - digest-free Testing observation with dimensions, source match, invocation count, and six aggregates
  - both-entry byte oracles for collision, unit failure, color continuation, recovery, and zero realtime/reset work
affects: [55-05, 56, 57, still-image-local-retouch]

tech-stack:
  added: []
  patterns: [optional opaque facade activation, stack-local compose-once handoff, test-local explicit-sRGB byte comparison]

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift
    - .planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py
    - PLANS.md

key-decisions:
  - "The facade constructs the request-local owner directly from BeautyStillImageRequestContext.canonicalImage and invokes compose exactly once only when an optional opaque Testing scenario is active."
  - "Testing SPI forwards the already-public CIImage for test-local explicit-sRGB byte comparison and exposes no output digest or composition mechanics."
  - "A nil composition scenario preserves the Phase 53 four-event trace; an active scenario adds exactly one compose event between context creation and render."

patterns-established:
  - "Facade adjacency: canonicalize, detect/map, context, optional compose, then the existing canonical color/render handoff."
  - "Lifecycle isolation: begin resets the latest aggregate observation, finish clears the active scenario, and no units, source, owner, result, or output are stored on hooks."

requirements-completed: [COMP-01, COMP-02, COMP-05]

duration: 10min
completed: 2026-08-03
---

# Phase 55 Plan 04: Opaque Facade Composition Integration Summary

**The existing still-image facade now proves one exact-source composition handoff through opaque Testing-only activation while production admission, compatibility inventories, and realtime paths remain unchanged.**

## Performance

- **Duration:** 10 min
- **Started:** 2026-08-03T07:27:47Z
- **Completed:** 2026-08-03T07:37:27Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- Wired `BeautyLocalRetouchCompositionOwner` directly from `BeautyStillImageRequestContext.canonicalImage`, issued opaque bounded mechanics units through that owner, composed once, and forwarded the returned canonical carrier to the existing render handoff.
- Removed `outputDigest` from the Testing SPI. Facade tests now render the returned public `CIImage` locally under explicit sRGB and compare literal RGBA8 arrays.
- Proved both CIImage entries, disjoint/collision/invalid/empty scenarios, opaque whole/subunit abstention, no-face and missing-support brightness/filter continuation, valid-invalid-valid and thrown-call cleanup, exact nil/scenario traces, and pixel-buffer/reset zero work.
- Strengthened facade checker mode to require the exact ten-field observation, direct request-context source construction, one compose call, no digest, and no hook-retained unit/source/result/output state while retaining all T-55 and 59/5/72 gates.

## Task Commits

Each task was committed atomically:

1. **Task 55-04-01: Compose once from the exact request-context canonical source under opaque Testing activation** — `9ce1f83` (feat)
2. **Task 55-04-02: Prove both facade entries, safe color continuation, request recovery, and zero non-still activation** — `773b216` (test)

## Files Created/Modified

- `BeautyEngine.swift` — performs the single optional compose call between request-context creation and render.
- `BeautyEngineTestingSupport.swift` — adds feature-neutral scenarios, exact aggregate observation, request cleanup, and public-output forwarding without a digest.
- `BeautyEngineLocalRetouchCompositionTests.swift` — supplies production-backed literal-byte facade/failure/recovery oracles for both CIImage entries.
- `BeautyEngineLocalRetouchFoundationTests.swift` — replaces SPI digest comparison with test-local explicit-sRGB byte comparison while preserving Phase 53 contracts.
- `check_phase55_composition_boundaries.py` — validates exact facade wiring, observation shape, privacy, retention, and unchanged scope inventories.
- `PLANS.md` — records Wave 3 implementation and current focused evidence.

## Verification Results

- Task 55-04-01 focused tests passed **2/2**; the complete Phase 53 foundation suite passed **16/16**; checker `--facade` and diff hygiene passed.
- The final combined facade/foundation command passed **28/28** with zero failures and skips.
- Parameter/resource/renderer compatibility passed **74/74**: 44 parameter tests, 12 resource tests, and 18 renderer regressions, preserving exact **59 fields / 5 presets / 72 renderer cases**.
- Checker `--facade`, `--privacy`, and default live modes passed all named T-55-01…07 HIGH rows; mutation self-test remained **44/44**.
- Source scans found no Testing `outputDigest`, old RED seam, closed candidate identifier, or production/Demo/realtime composition route.
- Full SwiftPM and Demo regression remain intentionally reserved for Plan 55-05.

## Decisions Made

- Kept composition scenarios feature-neutral and mechanics-shaped (`disjoint`, `collision`, invalid/empty, and unit-absence variants); no anatomy or candidate identity enters production or SPI.
- Kept output bytes out of diagnostic DTOs: the only byte-bearing value crossing the harness is the existing public `CIImage` facade output, rendered transiently inside tests.
- Stored only the latest aggregate observation needed after request return. Active scenario/source-match state is cleared in `finishStillRequest`; mechanics units and composition output never become hook properties.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Repaired state and roadmap drift after SDK updates**

- **Found during:** Plan tracking closeout
- **Issue:** The state handlers correctly counted the fourth Phase 55 summary but rewrote the milestone name, dropped current-phase fields, reported 33% in frontmatter, and left human-readable progress/activity at Plan 55-03; roadmap progress likewise remained 2/5 after marking 55-04 complete.
- **Fix:** Restored the established state schema and synchronized current position, 15/16 (94%) progress, performance totals, decisions, session stop, pending work, and Phase 55 roadmap progress to 4/5.
- **Files modified:** `.planning/STATE.md`, `.planning/ROADMAP.md`
- **Verification:** State/roadmap diff inspection, summary count, requirement status, session fields, and final diff hygiene.
- **Committed in:** final metadata commit

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Tracking now reflects the completed facade plan without changing code, validation scope, or Phase 55 final-gate ownership.

## Issues Encountered

- The installed GSD state CLI accepted named arguments rather than the positional syntax in the executor reference; rerunning with named arguments recorded the metric and decisions before the SDK drift was repaired.

## Known Stubs

None. Nil optional scenarios and empty production admission/scenario collections are intentional fail-closed states, not unwired output.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 55-05 can run the reserved full SwiftPM, Demo, schema/UI, evidence, validation, and root-owner synchronization gates.
- Production admission remains literal `.none`; all three Phase 54 feature decisions remain closed, and no candidate/provider/renderer/preset/Demo/realtime/dependency route exists.

## Self-Check: PASSED

- All six implementation/checker artifacts and this summary exist.
- Task commits `9ce1f83` and `773b216` are present in repository history.
- Both exact plan verification commands, compatibility gate, checker self/privacy/live modes, source scans, and final diff hygiene pass.

---
*Phase: 55-original-pixel-composition-and-failure-isolation-core*
*Completed: 2026-08-03*
