---
phase: 43-public-facade-eye-geometry-output-evidence
plan: "01"
subsystem: public-facade-renderer
tags: [swift, renderer, eye-geometry, no-face]
requires: [phase-42-eye-pipeline]
provides: [exact-55-case-renderer-matrix, eye-no-face-facade-evidence]
affects: [43-02, 43-03]
tech-stack:
  added: []
  patterns: [one-field-render-cases, aggregate-redacted-no-face-contract]
key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyExampleRenderer/main.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
key-decisions:
  - "All nine positive-only fields use 0.25 and eyeTilt uses explicit +0.25/-0.25 isolated public cases."
requirements-completed: [EYE-16, EYE-18]
coverage:
  - deliverable: "Exact 55-case public renderer inventory with eleven isolated new eye cases"
    verification:
      - kind: test
        ref: "BeautyRendererOutputRegressionTests#testPhase43EYE16EyeCasesUseExactlyOneNewPublicEyeParameter"
        status: pass
    human_judgment: false
  - deliverable: "No-face extent, diagnostics, and redaction contract for all eleven requests"
    verification:
      - kind: test
        ref: "BeautyRendererOutputRegressionTests#testPhase43EYE18IsolatedEyeCasesPreserveNoFaceFacadeContract"
        status: pass
    human_judgment: false
duration: 6 min
completed: 2026-07-16
status: complete
---

# Phase 43 Plan 01: Exact Renderer Matrix and No-Face Contract Summary

The public-only example renderer now exposes exactly eleven isolated v1.11 eye cases inside the frozen 55-case matrix, with representative no-face behavior remaining extent-safe and aggregate-redacted.

## Accomplishments

- Added nine positive-only `0.25` cases and signed `eyeTilt` `+0.25`/`-0.25` cases without changing the existing 44 IDs or shared `BeautyEngine.processResult` route.
- Added exact ordered inventory, duplicate-free, one-field initializer, alias, and public-import assertions.
- Exercised every new request against `negatives/no-face-gradient.png`, proving preserved extent, `.noFace`, `[.noFaceDetected]`, zero face counts, established warning/metrics, and no raw eye support disclosure.

## Task Commits

- `08df596` — `feat(43-01): add isolated public eye renderer cases`
- `87efdf0` — `test(43-01): lock eye no-face facade behavior`

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` — 13/13 passed.
- Renderer `RenderCase(` inventory — exactly 55.
- `git diff --check` — passed.

## Deviations from Plan

None - plan executed exactly as written.

## Security and Scope

- No internal provider, adapter, observation, raw landmark, Demo, network, or dependency surface was added.
- Exact caps, exhaustive safety transitions, promotion, and branch-level completion remain Phase 44.

## Self-Check: PASSED

- Both modified files exist and both task commits are present.
- Ready for 43-02 strict decoded output evidence.
