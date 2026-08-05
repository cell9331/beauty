---
phase: 53-canonical-still-image-contract-and-private-request-foundatio
plan: "04"
subsystem: still-image-request-foundation
tags: [swift, canonical-input, request-local-context, vision, privacy]
requires:
  - phase: 53-03
    provides: canonical still carrier plus actual request-local outer/inner lip support
provides:
  - exact-empty feature-neutral production admission
  - one canonicalize-detect-map-context-render route behind the existing CIImage facade
  - stack-local canonical/selected-support ownership with aggregate-only Testing SPI evidence
  - structural pixel-buffer and reset isolation
affects: [53-05, 53-06, 54, 55, 56, 57, 58, still-image, local-retouch]
tech-stack:
  added: []
  patterns: [feature-neutral admission, stack-local request context, opaque counted test injection]
key-files:
  created:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyLocalRetouchAdmission.swift
    - BeautySDK/Sources/BeautySDK/BeautyStillImageRequestContext.swift
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift
    - ARCHITECTURE.md
    - DESIGN.md
    - SECURITY.md
    - RELIABILITY.md
    - PRODUCT_SENSE.md
    - PLANS.md
key-decisions:
  - "Production local-retouch admission is exact-empty; opaque positive Testing demand collapses to one request without naming a candidate."
  - "The admitted CIImage route canonicalizes once, calls the existing detector/mapper once with normalized metadata, owns support in one stack-local context, then renders."
  - "Testing SPI exposes only demand/count/order, output digest, and synthetic aggregate identity; canonical bytes and mapped support remain package-only."
  - "Pixel-buffer and reset paths invoke no canonicalizer, request context, local support, or provider; same-engine concurrency/cancellation remain nonclaims."
patterns-established:
  - "Feature-neutral admission: zero is the unchanged legacy route; any positive opaque count means one shared request."
  - "Request lifecycle: canonicalize → detect/map → context → render, with defer-owned cleanup on success or throw."
requirements-completed: [PATH-01, PATH-04, PATH-05]
coverage:
  - id: D1
    description: Both existing CIImage facade entries share one feature-neutral canonical request for zero/one/many opaque demands
    requirement: PATH-01
    verification:
      - kind: unit
        ref: "BeautyEngineLocalRetouchFoundationTests#testBothExistingCIImageFacadeEntriesReachOnlyTheInjectedPrivateRoute"
        status: pass
      - kind: unit
        ref: "BeautyEngineLocalRetouchFoundationTests#testZeroOneAndMultiplePrivateDemandsShareOneRequest"
        status: pass
    human_judgment: false
  - id: D2
    description: Canonical pixels and selected mapped support remain stack-local, aggregate-only, and recover across invalid/no-face/independent requests
    requirement: PATH-04
    verification:
      - kind: unit
        ref: "BeautyEngineLocalRetouchFoundationTests#ordering/no-face/missing/valid-invalid-valid/independent cases"
        status: pass
      - kind: other
        ref: "check_still_image_foundation_boundaries.py"
        status: pass
    human_judgment: false
  - id: D3
    description: Pixel-buffer and reset routes perform zero local-foundation work and preserve existing summaries
    requirement: PATH-05
    verification:
      - kind: unit
        ref: "BeautyEngineLocalRetouchFoundationTests#testPixelBufferOverloadsAndResetPerformZeroLocalFoundationWork"
        status: pass
      - kind: other
        ref: "Phase 53 live boundary checker pixel-section scan"
        status: pass
    human_judgment: false
duration: 49min
completed: 2026-07-31
status: complete
---

# Phase 53 Plan 04: Feature-Neutral Request Foundation Summary

**The existing CIImage facade now has one exact-empty-gated canonical request route with stack-local selected support, exact ordering, safe degradation, and structural realtime isolation**

## Performance

- **Duration:** 49 min
- **Completed:** 2026-07-31
- **Tasks:** 1
- **Files created:** 2
- **Files modified:** 11

## Accomplishments

- Added the smallest package-only feature-neutral admission value. Production inventory is exactly empty; Testing may inject only an opaque demand count, and one or many positive demands share a single request.
- Routed both existing CIImage facade entries through exact `canonicalize → detect/map → context → render` ordering when admitted. The detector receives the canonical carrier's `.up`/not-mirrored metadata and the context owns the current selected mapped observation only until the synchronous facade call completes.
- Preserved the inactive legacy route, unrelated color output under no-face/missing-support conditions, payload-free fail-closed errors, valid-invalid-valid recovery, and independent request identity.
- Kept the pixel-buffer overload and `reset()` structurally free of admission, canonicalization, request-context, mapped-support, and provider work.
- Added aggregate-only Testing SPI evidence without candidate names, canonical bytes, mapped coordinates, stable IDs, masks, files, or framework payloads.

## Task Commits

1. **Task 1: Route feature-neutral admitted still requests through one stack-local context** - `3e9908f` (feat)
2. **Post-wave privacy gate: Replace public CGRect evidence with aggregate dimensions** - `0ceb4b5` (fix)

## Verification

- `swift test --package-path BeautySDK --filter 'BeautyEngineLocalRetouchFoundationTests|BeautyEngineMetadataCompatibilityTests|BeautyEngineGeometryFacadeTests'` passed 35 tests with zero failures; the one skip is a pre-existing opt-in live Apple Vision integration test and is not a Plan 53-04 HIGH mitigation.
- All 11 `BeautyEngineLocalRetouchFoundationTests` ran and passed.
- `check_still_image_foundation_boundaries.py` passed in live mode.
- Checker self-test passed 6/6 with exact `16 = 13 automated + 3 flagged`.
- The iPhone 17e / iOS 26.5 Demo build and full simulator test suite passed after the post-wave privacy fix.
- `git diff --check` passed.

## Deviations from Plan

- The typed executor consumed an extended analysis window without producing workspace changes or a completion signal. The parent orchestrator took over the same bounded plan, implemented it directly, and preserved the planned files, contracts, tests, and atomic commit.
- The Wave 0 test fixture used a Core Image constant whose color semantics were not an accepted standard-range sRGB input. The fixture was corrected to explicit opaque sRGB RGBA8 bytes rather than weakening the production color allowlist.
- The Testing result originally exposed rendered bytes while bringing the RED harness online. It was replaced before commit with a deterministic output digest so the final SPI remains aggregate-only.

## Issues Encountered

- The first SwiftPM run inside the filesystem sandbox failed at manifest sandbox setup. The established `/private/tmp` module-cache convention was used for the successful focused runs.
- The live boundary checker rejected Testing properties whose implementation lines contained `RequestContext`; the public SPI names were made feature-neutral while retaining exact internal counters.
- The first post-wave Demo test run found that public `CGRect` evidence violated the existing public-detection geometry scan. The SPI now reports only integer width/height aggregates; the focused privacy test and the full Demo simulator suite then passed.

## Next Phase Readiness

- Plan 53-05 can pass the same canonical carrier/view into the admitted render handoff and prove exact inactive renderer compatibility without adding Phase 55 masks or composition.
- Phase 54 still independently owns evidence eligibility. No teeth, sclera, or upper-eyelid feature has been admitted.
- `PATH01-CONCURRENCY`, `PATH04-CONCURRENCY`, and `PATH05-CONCURRENCY` remain flagged under TD-013. Same-engine concurrency, cooperative cancellation, realtime, device performance, commercial quality, packaging, and release readiness remain unclaimed.

## Self-Check: PASSED

- `BeautyLocalRetouchAdmission.swift` and `BeautyStillImageRequestContext.swift` exist.
- Task commit `3e9908f` exists and contains no tracked deletion.
- All 11 foundation tests and the focused compatibility/geometry suites pass.
- The live boundary checker and six-case checker self-test pass.
- Demo build and the complete simulator test suite pass on iPhone 17e / iOS 26.5.
- Production admission inventory is exactly empty; source scans show no candidate field/provider/renderer case and no pixel-buffer/reset local-foundation route.
- Testing SPI exposes no canonical bytes or mapped support.
- `git diff --check` passes.

---
*Phase: 53-canonical-still-image-contract-and-private-request-foundatio*
*Completed: 2026-07-31*
