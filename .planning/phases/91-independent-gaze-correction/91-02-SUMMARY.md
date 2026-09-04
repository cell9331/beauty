---
phase: 91-independent-gaze-correction
plan: "02"
implementation_attempt: 1
subsystem: rendering-validation
tags: [swift, gaze-correction, final-metrics, generated-pixel-oracle]
requires:
  - phase: 91-independent-gaze-correction
    plan: "01"
    provides: Independent per-eye gaze fields and exact final-admission aggregate primitive
  - phase: 89-semantic-validation-baseline
    provides: Frozen target, locality, protection, and signed-direction thresholds
provides:
  - Six bounded final post-conflict gaze metrics on the existing result channel
  - Deterministic testing-only request-local gaze observation cases
  - Generated 512x512 public-facade pixel proof of independent own-eye correction
affects: [91-03-renderer-comparator-binding, 91-04-phase-verification, EYE-01]
tech-stack:
  added: []
  patterns: [post-conflict aggregate reconciliation, independent chromatic pixel oracle, request-local testing SPI fixtures]
key-files:
  created:
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGazeCorrectionRepairTests.swift
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
key-decisions:
  - "Attach gaze evidence only after conflict convergence and final eye-emission recomputation, using the exact effective strength and exact final points."
  - "Collapse any inconsistent or out-of-range aggregate to the fixed abstaining form instead of repairing individual fields."
  - "Identify generated pupils only through independently declared chromatic marker identities and test both own-center reduction and peer-center rejection."
patterns-established:
  - "Final metric transport: validate one six-key integral aggregate at the resolver boundary and reuse the existing BeautyEffectPlan-to-BeautyResult path."
  - "Public-pixel proof: in-memory explicit-sRGB RGBA8 input, independent marker centroids, frozen target/protection regions, and byte-exact recovery."
requirements-completed: [EYE-01]
duration: 16min
completed: 2026-09-05
---

# Phase 91 Plan 02: Final Gaze Metrics and Public-Pixel Proof Summary

**The existing still-image facade now reports privacy-safe final gaze evidence and demonstrably moves each generated chromatic pupil toward its own declared eye center while preserving unsupported peers and protected pixels.**

## Performance

- **Duration:** 16 min
- **Started:** 2026-09-04T22:51:03Z
- **Completed:** 2026-09-04T23:06:47Z
- **Tasks:** 2
- **Files created/modified:** 4

## Accomplishments

- Attached exactly six gaze metrics after conflict convergence, effective-strength sanitization, and final eye-emission recomputation. Invalid algebra fails closed to one deterministic abstaining aggregate.
- Added private, non-Codable, request-local testing observations for bilateral, single-side, missing, malformed, pair-ratio-implausible, centered, invalid-pupil, dead-zone, and cap scenarios without introducing product-public anatomy.
- Added a generated 512x512 RGBA8 public-facade oracle whose independently declared red/blue pupil markers prove each eligible side moves toward its own center and cannot pass against the peer center.
- Kept invalid peers, eye contours, brows, background, watermark, alpha, neutral requests, and recovery paths within the frozen protection contract without writing media.

## Task Commits

Each TDD task was committed as a failing-test gate followed by its implementation:

1. **Task 1 RED: final gaze aggregate behavior** — `56636d0`
2. **Task 1 GREEN: post-conflict aggregate attachment** — `3a38bd9`
3. **Task 2 RED: generated public-facade pixel oracle** — `de5a63d`
4. **Task 2 GREEN: testing observations and pixel proof** — `7675721`

## Final Six-Key Aggregate Evidence

The result metric allowlist contains exactly these integral `Double` values:

| Case | eligible | corrected | rejected | allReduced | abstained | minimumReductionQ16 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Bilateral final field | 2 | 2 | 0 | 1 | 0 | 688 |
| Single final field | 1 | 1 | 0 | 1 | 0 | 688 |
| No credit / abstaining | 0 | 0 | 0 | 0 | 1 | 0 |

The six keys are `beauty.effects.gazeEligibleCount`, `beauty.effects.gazeCorrectedCount`, `beauty.effects.gazeRejectedCount`, `beauty.effects.gazeAllReduced`, `beauty.effects.gazeAbstained`, and `beauty.effects.gazeMinimumReductionQ16`. Zero/omitted gaze and sibling controls add none of them. Removing a final point, stale/reused support, no face, centered-only support, invalid evidence, or zero effective strength cannot retain pre-conflict credit.

## Generated Actual-Pixel Evidence

- Input and oracle rendering use an in-memory 512x512 explicit-sRGB RGBA8 image with alpha 255. No fixture or output image is written to disk.
- The left marker's own-center reduction is **201 Q16** and the right marker's is **203 Q16**, each above the frozen signed floor of 16. Peer-center checks reject the same outputs, so a symmetric, borrowed-eye, or general-darkness proxy cannot satisfy the oracle.
- The target regions contain **1,316 changed pixels** and **51,731 absolute RGB delta**, exceeding the frozen floors of 256 and 768.
- Protected aggregates are exact: outside `0/0`, eye contours `0/0`, eyebrows `0/0`, background `0/0`, and watermark `0/0` changed-pixel/RGB-delta pairs. These are within the unchanged ceilings of outside 128/512, contours 64/256, brows 32/128, and background/watermark 0/0.
- Bilateral, left-only, right-only, missing/malformed peer, pair-ratio-implausible, centered, invalid pupil, no-face, exact dead-zone, just-above-boundary, and cap behavior passed through `BeautyEngine.processResult`.
- Repeated cap output and the valid-invalid-valid sequence recover byte-identically with matching aggregate and detection metadata. Extent, alpha, and explicit-sRGB input/render-context assertions pass.

## Verification

- Task 1 focused gate: **66 tests executed, 0 failures, 0 skips** across resolver, conflict resolver, and eye-warp provider tests.
- Task 2 focused gate: **35 tests executed, 0 failures, 0 skips** across the generated pixel oracle and resolver tests; `git diff --check` passed.
- Combined Plan 91-02 gate: **117 tests executed, 115 passed, 2 existing opt-in Vision tests skipped, 0 failures** across adapter, provider, resolver, conflict resolver, and generated public-pixel tests.
- The production resolver contains exactly six distinct `beauty.effects.gaze*` keys, the plan diff contains no tracked image, and `git diff --check` passes.

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` — final post-conflict aggregate attachment, validation, and fixed abstention fallback.
- `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` — private testing-only observed-eye fixtures for the generated gaze matrix.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` — six-key algebra, final-admission, abstention, absence, and recovery tests.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGazeCorrectionRepairTests.swift` — in-memory public-facade marker, locality, protection, metadata, determinism, sibling, and recovery oracle.

## Decisions Made

- Used the Plan 91-01 aggregate helper only after the resolver knows the final strength and final admitted `gazeCorrection` points; no pre-conflict provider result or summed offset can authorize credit.
- Applied a whole-aggregate consistency check at the resolver boundary. Counts, booleans, and Q16 must agree exactly or all six values become the fixed abstaining form.
- Kept all gaze anatomy inside the testing SPI fixture implementation and all marker definitions inside the test process. The result carries only bounded aggregate values.
- Asserted explicit sRGB at the generated input and byte-render context while preserving the pre-existing legacy geometry output color-space behavior; no engine/pipeline contract outside the plan was changed.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Test fixture defect] Corrected the malformed ratio case and color-space assertion scope**
- **Found during:** Task 2 GREEN verification
- **Issue:** The initial ratio-implausible fixture also made the right pupil locally ellipse-invalid, so it did not isolate paired-ratio behavior. The initial output-property color-space assertion also conflicted with the existing legacy geometry path, which reports `DeviceRGB` even though the oracle input and byte render are explicitly sRGB.
- **Fix:** Increased only the right pupil's fixture radius enough to remain locally valid while preserving a greater-than-2 pair-width ratio, and asserted explicit sRGB on the generated input and render context without changing production engine/pipeline behavior.
- **Files modified:** `BeautyEngineTestingSupport.swift`, `BeautyEngineGazeCorrectionRepairTests.swift`
- **Verification:** The final 35-test Task 2 gate and 117-test combined gate passed without changing any frozen semantic or protection threshold.
- **Committed in:** `7675721`

---

**Total deviations:** 1 auto-fixed test construction issue.
**Impact on plan:** No effect threshold, clearance factor, peer ownership rule, production color pipeline, public surface, or acceptance boundary changed.

## Security and Scope

- HIGH threats T-91-05 through T-91-08 are mitigated by exact final-point reconciliation, independent marker/center ownership, literal frozen protection assertions, fixed bounded aggregate validation, and non-Codable testing-only support.
- No raw/per-side pupil or contour coordinates, radii, masks, marker bytes, pixels, private locators, paths, or transcripts leave the test process or enter durable evidence.
- No public parameter, preset, renderer case, manifest threshold, backend, shader, retained `Warp.metal`, UI/Demo, realtime/video, network, model, data, weight, or package dependency changed.
- This is generated package-host evidence only. It is not an authorized-portrait result and does not establish Phase-95 publication, device behavior, naturalness, population quality, commercial suitability, packaging, shipping, launch, release, or distribution readiness.

## Known Stubs

None.

## User Setup Required

None - no external service, package, model, fixture, credential, or persistent media is required.

## Next Phase Readiness

- Plan 91-03 can bind the final aggregate and independent public-pixel behavior into the retained renderer/comparator path without changing the public facade or semantic thresholds.
- Plan 91-04 remains responsible for phase-level verification; Phase 95 remains the sole owner of clean authorized-portrait publication and milestone closeout.

## Self-Check: PASSED

- All four declared source/test files and this summary exist.
- Commits `56636d0`, `3a38bd9`, `de5a63d`, and `7675721` exist in repository history.
- The summary contains exactly one machine-readable implementation-attempt line, the production key allowlist has exactly six members, no image was added, and `git diff --check` passes.

---
*Phase: 91-independent-gaze-correction*
*Completed: 2026-09-05*
