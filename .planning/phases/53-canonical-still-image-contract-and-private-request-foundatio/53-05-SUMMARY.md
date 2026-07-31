---
phase: 53-canonical-still-image-contract-and-private-request-foundatio
plan: "05"
subsystem: canonical-still-render-handoff
tags: [swift, core-image, srgb, canonical-input, compatibility]
requires:
  - phase: 53-04
    provides: feature-neutral admitted still route and stack-local canonical request context
provides:
  - canonical-carrier-aware admitted color and geometry render handoff
  - detector/render carrier identity and explicit-sRGB geometry raster evidence
  - exact inactive bytes, dimensions, warnings, metrics, and summary regression
affects: [53-06, 54, 55, 56, 57, 58, still-image, local-retouch]
tech-stack:
  added: []
  patterns: [canonical carrier render overload, explicit managed-color admitted raster, exact legacy branch regression]
key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift
    - BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
    - DESIGN.md
    - RELIABILITY.md
    - PLANS.md
key-decisions:
  - "Admitted rendering accepts the canonical carrier itself; the legacy CIImage overload remains the exact-empty production route."
  - "Only admitted geometry rasterization changes color ownership, using explicit sRGB for CIContext working/output, bitmap, and reconstructed-image spaces."
  - "Testing exposes only aggregate identity/sRGB booleans; carrier identities, canonical bytes, and mapped support stay package-private."
  - "Phase 55 retains original-pixel composition, mask ownership, and overlap failure semantics."
patterns-established:
  - "Canonical render handoff: detector consumes canonical.ciImage while admitted rendering consumes the owning canonical carrier."
  - "Inactive compatibility: exact RGBA bytes/dimensions plus warnings, metrics, and summary are asserted together."
requirements-completed: [PATH-02, PATH-06]
coverage:
  - id: D1
    description: Detector and renderer share one canonical carrier/view and admitted geometry rasterization is explicit sRGB
    requirement: PATH-02
    verification:
      - kind: unit
        ref: "BeautyEngineLocalRetouchFoundationTests#testAdmittedDetectorAndRendererShareCanonicalCarrierAndExplicitSRGB"
        status: pass
      - kind: other
        ref: "canonical geometry source scan plus live Phase 53 boundary checker"
        status: pass
    human_judgment: false
  - id: D2
    description: Exact no-admission bytes, dimensions, warnings, metrics, summary, and renderer inventory remain unchanged
    requirement: PATH-06
    verification:
      - kind: unit
        ref: "BeautyRendererOutputRegressionTests#testDefaultParametersPreserveCurrentFixturePixelsBeforeWatermark"
        status: pass
      - kind: unit
        ref: "BeautyRendererOutputRegressionTests#testPhase53NoLocalCandidateRendererCasesRemainAbsent"
        status: pass
    human_judgment: false
duration: 7min
completed: 2026-07-31
status: complete
---

# Phase 53 Plan 05: Canonical Render Handoff Summary

**Admitted still rendering now consumes the detector-shared canonical carrier with explicit sRGB geometry rasterization while the exact inactive facade result remains unchanged**

## Performance

- **Duration:** 7 min
- **Started:** 2026-07-31T07:03:21Z
- **Completed:** 2026-07-31T07:10:27Z
- **Tasks:** 1
- **Files modified:** 9

## Accomplishments

- Added package-only canonical-carrier overloads to the existing color and geometry pipelines and called them only from the admitted still branch.
- Proved the detector receives the canonical carrier's exact `CIImage` object, the renderer receives the same backing, canonicalization/render remain exactly once, dimensions remain stable, and admitted geometry rasterization names sRGB throughout.
- Locked the production exact-empty path to identical rendered RGBA bytes and dimensions, empty warnings, exact zero active/capped metrics, `.notRun` detection summary, and the unchanged 72-case renderer inventory.
- Preserved Phase 55 ownership: no candidate, public field/facade, mask, provider, overlap resolver, original-pixel transform, renderer case, Demo/UI, realtime/pixel-buffer route, target, dependency, or performance/device/release claim was added.

## Task Commits

1. **RED: Add canonical render handoff coverage** - `76635fe` (test)
2. **GREEN: Share canonical carrier with admitted render** - `21f6a60` (feat)

## Files Created/Modified

- `BeautyColorEffectPipeline.swift` - adds the admitted canonical-carrier handoff beside the legacy CIImage route.
- `BeautyGeometryEffectPipeline.swift` - adds explicit-sRGB admitted rasterization while preserving legacy device-RGB behavior.
- `BeautyEngine.swift` - sends the request context's canonical carrier into the admitted renderer.
- `BeautyEngineTestingSupport.swift` - records aggregate-only carrier/view identity and explicit-sRGB evidence.
- `BeautyEngineLocalRetouchFoundationTests.swift` - proves one shared carrier/view, explicit sRGB, exactly-once counts, and dimensions.
- `BeautyRendererOutputRegressionTests.swift` - locks exact inactive warnings, metrics, summary, dimensions, bytes, and renderer inventory.
- `DESIGN.md`, `RELIABILITY.md`, and `PLANS.md` - record D-05/D-08/D-13 ownership and exact verification evidence.

## Decisions Made

- The canonical-aware color overload accepts `BeautyCanonicalStillImage`, not only its `CIImage`, so render ownership remains explicit at the type boundary.
- Existing color filters remain shared, while only the admitted geometry raster selects explicit sRGB; the inactive overload retains shipped behavior and exact regressions.
- Testing observes equality and color-space outcome only as booleans, avoiding raw identities, bytes, coordinates, or support diagnostics.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Extended the existing aggregate Testing seam for carrier identity**

- **Found during:** Task 1 (canonical render handoff)
- **Issue:** The plan required runtime proof that detector and renderer consume the same carrier/view, but its file list omitted the existing hook owner needed to observe both consumers without exposing raw data.
- **Fix:** Added request-local backing/view comparisons and an explicit-sRGB boolean to `BeautyEngineTestingSupport.swift`; public Testing SPI exposes only the two aggregate booleans.
- **Files modified:** `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift`
- **Verification:** The focused identity test and live privacy/boundary checker pass.
- **Committed in:** `21f6a60`

---

**Total deviations:** 1 auto-fixed (1 missing critical).
**Impact on plan:** The existing test seam gained only privacy-safe acceptance evidence; production scope and ownership remained unchanged.

## Issues Encountered

- The first RED compile also exposed a Swift initializer argument-order typo in the new test. It was corrected before the RED commit; the rerun failed only because the planned identity/sRGB seam did not yet exist.

## Verification

- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --package-path BeautySDK --filter 'BeautyEngineLocalRetouchFoundationTests|BeautyRendererOutputRegressionTests'` passed **30/30** with zero failures and zero skips: 12 foundation tests plus 18 renderer regressions.
- `python3 .planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/check_still_image_foundation_boundaries.py` passed in live mode.
- The canonical geometry overload source scan found no `CGColorSpaceCreateDeviceRGB`; explicit sRGB working/output/bitmap/reconstruction anchors were present.
- The production diff scan found no candidate, mask provider, or overlap resolver addition.
- `git diff --check` passed.
- OWASP ASVS L1 HIGH mitigations T-53-03, T-53-04, and T-53-05 are verified with no failure, skip, or not-run result.

## Known Stubs

None. Optional nil values in the Testing seam are request-initialization state and do not flow to UI or production output.

## Next Phase Readiness

- Plan 53-06 can run compatibility/privacy/full-suite closeout over the completed canonical request and render boundary.
- Phase 54 still independently owns feature evidence eligibility; production admission remains exact-empty.
- Phase 55 still owns original-pixel composition, masks, provider overlap, and failure isolation.

## Self-Check: PASSED

- All nine modified files exist.
- RED commit `76635fe` and GREEN commit `21f6a60` exist.
- Focused tests pass 30/30 with no skipped HIGH mitigation.
- Live boundary, explicit-sRGB/no-device-RGB, no-candidate/provider/mask/overlap, and diff-hygiene checks pass.
- No tracked file was deleted.

---
*Phase: 53-canonical-still-image-contract-and-private-request-foundatio*
*Completed: 2026-07-31*
