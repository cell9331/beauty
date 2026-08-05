---
phase: 53-canonical-still-image-contract-and-private-request-foundatio
plan: "01"
subsystem: testing
tags: [swift, xctest, core-image, vision, compatibility, privacy]
requires:
  - phase: 52
    provides: verified public-facade and observed-support baseline
provides:
  - executable Wave 0 RED contract for canonical opaque still-image input
  - executable exactly-once request-local facade and observed-lip specifications
  - exact 59-field, five-preset, no-candidate compatibility gates
  - fail-closed 16-row edge and active-source boundary checker
affects: [53-02, 53-03, 53-04, 53-05, 53-06]
tech-stack:
  added: []
  patterns: [runtime-selectable Wave 0 RED seam, exact closed edge manifest, aggregate-only support assertions]
key-files:
  created:
    - BeautySDK/Tests/BeautyCoreTests/BeautyCanonicalStillImageTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift
    - BeautySDK/Tests/BeautyDetectionTests/StillImageRequestSupportTests.swift
    - .planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/check_still_image_foundation_boundaries.py
  modified:
    - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
    - BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
    - PLANS.md
key-decisions:
  - "Wave 0 RED suites use test-local absent-seam oracles so they compile and run independently while legacy compatibility suites remain green."
  - "The source checker treats device RGB as forbidden only on the admitted canonical route, not on pre-existing inactive legacy/example paths."
patterns-established:
  - "Expected-RED tests must build and fail at the missing production seam, never through syntax or package errors."
  - "All specless edges remain a closed 16 = 13 automated + 3 flagged inventory."
requirements-completed: [PATH-01, PATH-02, PATH-03, PATH-04, PATH-05, PATH-06, PATH-07]
coverage:
  - id: D1
    description: Canonical input and fail-before-Vision Wave 0 contract
    requirement: PATH-02
    verification:
      - kind: unit
        ref: "! swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests"
        status: pass
      - kind: other
        ref: "python3 check_still_image_foundation_boundaries.py --self-test"
        status: pass
    human_judgment: false
  - id: D2
    description: Exactly-once still facade ordering and realtime isolation contract
    requirement: PATH-04
    verification:
      - kind: integration
        ref: "! swift test --package-path BeautySDK --filter BeautyEngineLocalRetouchFoundationTests"
        status: pass
    human_judgment: false
  - id: D3
    description: Request-local observed-lip mapping and privacy contract
    requirement: PATH-04
    verification:
      - kind: unit
        ref: "! swift test --package-path BeautySDK --filter StillImageRequestSupportTests"
        status: pass
    human_judgment: false
  - id: D4
    description: Exact legacy inventory, preset, and renderer compatibility baseline
    requirement: PATH-06
    verification:
      - kind: unit
        ref: "BeautyParametersTests 43/43; BeautyResourceCatalogTests 11/11; BeautyRendererOutputRegressionTests 18/18"
        status: pass
    human_judgment: false
duration: 19min
completed: 2026-07-30
status: complete
---

# Phase 53 Plan 01: Canonical Still-Image Contract and Private Request Foundation Summary

**Compile-clean Wave 0 RED contracts for one opaque canonical still image, one request-local Vision/mapping boundary, and exact legacy compatibility without adding production or candidate surface**

## Performance

- **Duration:** 19 min
- **Started:** 2026-07-30T08:42:28Z
- **Completed:** 2026-07-30T09:01:31Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments

- Added canonical raster tests covering all eight EXIF orientations and mirror variants, explicit sRGB RGBA8 ownership, exact/one-over/overflow extents, unsupported color/range, and every non-opaque alpha rejection before Vision.
- Added opaque facade and observed-lip specifications for both existing CIImage entries, exact request ordering/counts, safe continuation, valid-invalid-valid recovery, pixel-buffer/reset isolation, aggregate-only diagnostics, and independent values.
- Locked the exact 59 stored fields, 58 numeric plus `filterId`, five presets, legacy missing-key neutrality, 72 renderer cases, empty candidate inventory, and the append-only future admission checklist.
- Added a standard-library checker whose self-test proves both unclassified mutations and the closed `16 = 13 automated + 3 flagged` edge inventory.

## Task Commits

1. **Task 1: Specify canonical raster validation and fail-closed source boundaries** - `8ca56f4`
2. **Task 2: Specify public-facade admission, request ordering, and realtime isolation** - `67d0130`
3. **Task 3: Specify observed lip support and exact legacy admission compatibility** - `33dbe7d`

## Files Created/Modified

- `BeautyCanonicalStillImageTests.swift` - deterministic orientation/color/alpha/extent RED contract.
- `BeautyEngineLocalRetouchFoundationTests.swift` - opaque facade counters, trace, recovery, and realtime isolation RED contract.
- `StillImageRequestSupportTests.swift` - observed-lip boundary, isolation, order, and privacy RED contract.
- `check_still_image_foundation_boundaries.py` - exact edge manifest, mutation self-tests, and live active-source checks.
- `BeautyParametersTests.swift` - PATH06/PATH07 exact stored/Codable order and admission checks.
- `BeautyResourceCatalogTests.swift` - exact five-preset and absent-candidate checks.
- `BeautyRendererOutputRegressionTests.swift` - exact no-candidate 72-case renderer inventory.
- `PLANS.md` - command-level Wave 0 RED and green compatibility evidence.

## Decisions Made

- Used test-local missing-seam oracles for Wave 0. This lets every new suite compile and execute as intended RED while unrelated compatibility filters remain runnable and green.
- Scoped the device-RGB checker to the future admitted canonicalizer. Existing legacy/example device-RGB usage is not misclassified as activation of the absent local-retouch route.
- Kept `PATH01-CONCURRENCY`, `PATH04-CONCURRENCY`, and `PATH05-CONCURRENCY` flagged under TD-013; independent values are tested without claiming same-engine parallel safety or cancellation.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Replaced compile-time missing symbols with runtime absent-seam oracles**
- **Found during:** Task 3 compatibility verification
- **Issue:** Compile-time RED types prevented the required legacy filters from building, so the plan could not simultaneously prove RED foundation suites and green compatibility suites.
- **Fix:** Added private test-local seam shapes that throw explicit `absent` errors until Plans 53-02 through 53-04 replace them with production/test SPI behavior.
- **Files modified:** `BeautyCanonicalStillImageTests.swift`, `BeautyEngineLocalRetouchFoundationTests.swift`, `StillImageRequestSupportTests.swift`
- **Verification:** All three RED suites build and execute; the three compatibility suites pass 43/43, 11/11, and 18/18.
- **Committed in:** `33dbe7d`

**2. [Rule 1 - Bug] Scoped device-RGB detection to the admitted route**
- **Found during:** Overall live checker verification
- **Issue:** A global source scan incorrectly flagged pre-existing inactive legacy/example device-RGB code.
- **Fix:** The checker now rejects device RGB specifically in `BeautyStillImageCanonicalizer.swift` once that active route exists.
- **Files modified:** `check_still_image_foundation_boundaries.py`
- **Verification:** Checker self-test passes; live mode now fails only for the three intentionally missing production owner files.
- **Committed in:** `33dbe7d`

**Total deviations:** 2 auto-fixed (1 blocking issue, 1 checker bug). **Impact on plan:** Both fixes were required to preserve honest expected-RED semantics and did not add production behavior or visible candidates.

## Issues Encountered

- SwiftPM compiler caches were sandbox-restricted; focused suites were rerun with `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache` outside the sandbox.
- The first preset assertion expected 59 encoded keys even when optional `filterId` is nil; it was corrected to assert 59 stored fields and 58/59 encoded keys according to optional presence while preserving the exact five-preset contract.

## Known Stubs

- The three private `Phase53Missing*Seam.absent` test oracles are intentional Wave 0 RED fixtures. Plans 53-02, 53-03, and 53-04 replace them with the real canonicalizer, observed-lip mapping, and facade request foundation; they do not exist in production source or block this plan's specification goal.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 53-02 can implement the immutable canonical carrier and canonicalizer directly against a compile-clean RED suite.
- The live checker remains intentionally RED for the missing carrier, canonicalizer, and request-context owner paths.
- No candidate field, provider, renderer case, preset key, public/SPI raw support, or realtime route was added.

## Self-Check: PASSED

- All four created artifacts exist.
- Task commits `8ca56f4`, `67d0130`, and `33dbe7d` exist in history.
- Checker self-test passes with exact `16 = 13 automated + 3 flagged` equality.
- Three new suites build and fail only at explicit Wave 0 absent seams; legacy compatibility suites pass.
- `git diff --check` passes.

---
*Phase: 53-canonical-still-image-contract-and-private-request-foundatio*
*Completed: 2026-07-30*
