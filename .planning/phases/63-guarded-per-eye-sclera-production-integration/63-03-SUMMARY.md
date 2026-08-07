---
phase: 63-guarded-per-eye-sclera-production-integration
plan: "03"
subsystem: image-effects
tags: [swift, sclera, lifecycle, composition, vision]
requires:
  - phase: 63-02
    provides: guarded zero-to-two-unit sclera provider and bounded transform
provides:
  - one direct sclera-provider invocation from the canonical still-image request
  - shared one-pass teeth and sclera composition with independent activation
  - per-eye failure isolation, aggregate reset and deferred-route absence
affects: [63-04, 64-sclera-output]
tech-stack:
  added: []
  patterns: [single-request-provider, anatomical-side-validation, request-local-aggregate-reset]
key-files:
  modified:
    - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineScleraRednessIntegrationTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineTeethWhiteningIntegrationTests.swift
    - BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift
key-decisions:
  - "One actual eye may establish canonical side ownership against the mapped face-right axis; duplicate, central or side-swapped support remains invalid."
  - "Direct teeth and sclera intent share one immutable-source composition owner and one composition pass without cross-activation."
  - "Provider observations expose only fixed aggregate counts and are cleared before every still-image, pixel-buffer and reset boundary."
patterns-established:
  - "Missing peer support is not ambiguous when the remaining declared side agrees with the current mapped face axis."
  - "Blink, gaze, glare and occlusion fixtures abstain per eye while safe peers and eligible teeth continue."
requirements-completed: [SCLERA-09, SCLERA-13]
coverage:
  - id: D1
    description: "Direct sclera intent uses one canonical request, one provider and one shared composition."
    requirement: SCLERA-09
    verification:
      - kind: integration
        ref: "BeautyEngineScleraRednessIntegrationTests"
        status: pass
    human_judgment: false
  - id: D2
    description: "Per-eye failures, thrown requests, parallel calls and deferred routes retain no stale sclera state."
    requirement: SCLERA-13
    verification:
      - kind: integration
        ref: "94 focused tests; one existing opt-in Vision test skipped"
        status: pass
      - kind: other
        ref: "check_phase63_sclera_provider_boundaries.py --integration"
        status: pass
    human_judgment: false
duration: 7 min
completed: 2026-08-07
status: complete
---

# Phase 63 Plan 03: Production Lifecycle Integration Summary

**Direct sclera intent now consumes current request-local eye support once and joins teeth in one immutable-source composition without cross-eye or cross-request state.**

## Performance

- **Duration:** 7 min
- **Started:** 2026-08-07T10:51:06Z
- **Completed:** 2026-08-07T10:58:23Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Connected the admitted scalar to exactly one package provider call after the
  existing canonicalize/detect/map/context boundary and appended stable per-eye
  units to the existing shared composition owner.
- Made one-eye Vision support independently trustworthy by checking its declared
  side against the mapped anatomical face axis across orientation and mirroring.
- Proved local abstention for missing/malformed peer, blink, severe gaze, glare,
  occlusion, invalid order and no face, including valid-invalid-valid recovery.
- Proved teeth continuation, thrown-request clearing, pixel-buffer/reset absence,
  parallel isolation and aggregate-only observations.

## Task Commits

1. **Task 1: Wire one sclera provider invocation into shared still-image composition** — `bff8765`
2. **Task 2: Prove affected-eye abstention, recovery and deferred-route absence** — `4e67b14`

## Verification

- 94 focused engine, foundation, metadata, geometry, teeth, sclera and mapping
  tests passed; one pre-existing explicit Vision-host integration test skipped.
- Phase 63 integration HIGH mode passed 4/4.
- `git diff --check` passed.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Preserved canonical ownership for a single actual eye**
- **Found during:** Task 1 peer-isolation test.
- **Issue:** The existing detector marked every one-eye payload as invalid order,
  suppressing a safe observed eye when its peer was absent.
- **Fix:** Validate each available side against the mapped face center/right axis;
  duplicates, center-degenerate and swapped sides still fail closed.
- **Verification:** 24 mapping tests plus all orientation/mirror cases pass.
- **Committed in:** `bff8765`

**2. [Rule 1 - Test Fixture] Replaced color-space-free and overlapping synthetic images**
- **Found during:** Focused canonicalization and combined teeth/sclera tests.
- **Issue:** A constant CIImage had no admitted RGB color space, and the first
  synthetic eye/lip locations made independent teeth evidence impossible.
- **Fix:** Use explicit sRGB RGBA8 fixtures with anatomically separated eye and
  mouth regions while retaining bounded glare/occlusion variants.
- **Verification:** All 9 sclera lifecycle tests and 12 teeth integration tests pass.
- **Committed in:** `4e67b14`

**Total deviations:** 2 auto-fixed (one missing critical lifecycle behavior, one test-fixture correction). **Impact:** No public or deferred scope changed.

## User Setup Required

None.

## Next Phase Readiness

Ready for 63-04 private actual-Vision execution and full closeout. No renderer,
Demo, realtime, model, network, upper-eyelid or `去脂` surface was added.

## Self-Check: PASSED

- Both task commits exist.
- One-request/shared-owner and peer-isolation tests are green.
- Integration HIGH mode and tracked diff checks pass.
- No private media, path, coordinates, masks or pixels were recorded.
