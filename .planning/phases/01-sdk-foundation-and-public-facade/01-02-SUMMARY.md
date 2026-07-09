---
phase: 01-sdk-foundation-and-public-facade
plan: 01-02
subsystem: public-models
tags: [codable, sendable, validation, presets, typed-errors]
requires:
  - phase: 01-sdk-foundation-and-public-facade
    provides: BeautySDK package skeleton and facade target
provides:
  - BeautyConfiguration and log/quality models
  - BeautyParameters 31-field normalized model
  - BeautyPreset decoding and validation
  - BeautyError and redacted diagnostics types
affects: [phase-3-input-pipelines, phase-5-presets-resources, phase-6-effects]
tech-stack:
  added: [Foundation, CoreGraphics]
  patterns: [boundary-normalization, typed-redacted-errors, forward-compatible-json]
key-files:
  created:
    - BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift
    - BeautySDK/Sources/BeautyCore/Models/BeautyRenderQuality.swift
    - BeautySDK/Sources/BeautyCore/Models/BeautyLogLevel.swift
    - BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift
    - BeautySDK/Sources/BeautyCore/Models/BeautyPreset.swift
    - BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift
    - BeautySDK/Sources/BeautyCore/Models/BeautyError.swift
    - BeautySDK/Sources/BeautyCore/Diagnostics/BeautyValidationWarning.swift
    - BeautySDK/Sources/BeautyCore/Diagnostics/BeautyErrorContext.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyPresetTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift
  modified:
    - BeautySDK/Sources/BeautySDK/BeautySDK.swift
    - BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift
    - SECURITY.md
    - PLANS.md
key-decisions:
  - "Non-finite parameter values reset to zero before rendering."
  - "Phase 1 has no built-in preset registry; unknown filter IDs fail validation."
patterns-established:
  - "Every public value model used across concurrency boundaries is Sendable."
  - "Preset JSON unknown fields are ignored, but unknown resources produce typed errors."
requirements-completed: [SDK-02, SDK-03, SDK-05, SDK-06, SDK-07]
duration: 15min
completed: 2026-06-11
---

# Phase 01 Plan 01-02: Implement Public Value Models, Defaults, Validation, and Preset Decoding Summary

**Facade-accessible public model layer with 31 normalized parameters, typed errors, and preset validation tests**

## Performance

- **Duration:** 15 min
- **Started:** 2026-06-11T02:05:00Z
- **Completed:** 2026-06-11T02:13:04Z
- **Tasks:** 4
- **Files modified:** 15

## Accomplishments

- Added `BeautyConfiguration`, `BeautyRenderQuality`, `BeautyLogLevel`, `BeautyResult`, `BeautyError`, `BeautyValidationWarning`, and `BeautyErrorContext`.
- Implemented `BeautyParameters` with the 31-field v1 model, no-op defaults, Codable/Equatable/Sendable conformance, clamping, and non-finite reset behavior.
- Implemented `BeautyPreset.decode(from:)` and validation for conservative IDs, unknown fields, unknown resource references, and no built-in registry.

## Task Commits

Codex runtime executed this plan inline in the main worktree. Per-task commits were not created because this run did not use isolated GSD executor agents.

## Files Created/Modified

- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` - 31-field normalized parameter model.
- `BeautySDK/Sources/BeautyCore/Models/BeautyPreset.swift` - typed preset decoding and validation.
- `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift` - public typed error surface.
- `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` - defaults, ranges, non-finite, Codable, Sendable.
- `BeautySDK/Tests/BeautyCoreTests/BeautyPresetTests.swift` - unknown fields, invalid IDs, unknown filter resources, no built-in registry.

## Decisions Made

- Missing parameter JSON fields decode to default no-op values for forward compatibility.
- Associated error strings are sanitized and length-limited before crossing public error descriptions.

## Deviations from Plan

None - public behavior matches the Phase 1 model and preset contract.

## Issues Encountered

- Swift synthesized `CodingKeys` were private after adding custom decoding; explicit `CodingKeys` were added.
- Foundation imports were required for `LocalizedError` and `CharacterSet`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Public models and typed errors are ready for no-op engine and render primitive work.

---
*Phase: 01-sdk-foundation-and-public-facade*
*Completed: 2026-06-11*
