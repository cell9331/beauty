---
phase: 05-filters-presets-and-resource-flow
plan: 05-01
subsystem: resources
tags: [swiftpm, resources, presets, filters, schema]
requires:
  - phase: 01-sdk-foundation-and-public-facade
    provides: BeautyCore models, BeautyPreset validation, BeautyResources target
provides:
  - BeautyResources bundled manifest and catalog loader
  - Metadata-only filter registry with two built-in filter definitions
  - Five schema-versioned built-in preset JSON resources
affects: [phase-05, phase-06, resources, presets, filters]
tech-stack:
  added: []
  patterns: [Bundle.module processed resources, schema-versioned preset envelope]
key-files:
  created:
    - BeautySDK/Sources/BeautyCore/Models/BeautyFilterDefinition.swift
    - BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift
    - BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift
    - BeautySDK/Sources/BeautyResources/Resources/manifest.json
    - BeautySDK/Sources/BeautyResources/Resources/Presets/natural.json
    - BeautySDK/Sources/BeautyResources/Resources/Presets/clear.json
    - BeautySDK/Sources/BeautyResources/Resources/Presets/refined.json
    - BeautySDK/Sources/BeautyResources/Resources/Presets/male-natural.json
    - BeautySDK/Sources/BeautyResources/Resources/Presets/id-photo-natural.json
    - BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift
  modified:
    - BeautySDK/Package.swift
    - BeautySDK/Sources/BeautyCore/Models/BeautyPreset.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyPresetTests.swift
key-decisions:
  - "SwiftPM processes the fixed Resources directory for BeautyResources; resource IDs never become arbitrary caller-provided paths."
  - "Preset JSON supports schemaVersion 1 while preserving existing no-schema custom preset decoding."
  - "Built-in filters are metadata-only: soft_clean and warm_light."
patterns-established:
  - "BeautyResourceCatalog.bundled() loads a validated manifest through Bundle.module and decodes preset JSON by manifest reference."
  - "BeautyPreset.decode probes optional schemaVersion and rejects unsupported schemas with presetDecodeFailed(unsupported_schema)."
requirements-completed: ["EFFECT-03", "EFFECT-08"]
duration: 18 min
completed: 2026-06-19
---

# Phase 05 Plan 01: Add Resource Manifest Model and Built-In Preset Resources Summary

**Schema-versioned bundled presets and metadata-only filter catalog loaded through BeautyResources**

## Performance

- **Duration:** 18 min
- **Started:** 2026-06-19T08:36:00Z
- **Completed:** 2026-06-19T08:53:57Z
- **Tasks:** 1
- **Files modified:** 12

## Accomplishments

- Added `BeautyFilterDefinition`, `BeautyResourceManifest`, `BeautyPresetReference`, and `BeautyResourceCatalog`.
- Added processed `BeautyResources/Resources` with a v1 manifest, two metadata filters, and five complete built-in preset JSON files.
- Extended `BeautyPreset.decode` to support strict `schemaVersion: 1` envelopes while retaining existing custom preset compatibility.
- Replaced the historical "no built-in registry" test with positive Phase 5 resource contract tests.

## Task Commits

Each task was committed atomically:

1. **Task 1 RED: Add failing resource catalog tests** - `12b7350` (test)
2. **Task 1 GREEN: Implement bundled resource catalog** - `ab64e10` (feat)

**Plan metadata:** pending (docs: complete plan)

## Files Created/Modified

- `BeautySDK/Package.swift` - Adds processed `BeautyResources` resources and the `BeautyResourcesTests` target.
- `BeautySDK/Sources/BeautyCore/Models/BeautyFilterDefinition.swift` - Host-visible metadata filter value.
- `BeautySDK/Sources/BeautyCore/Models/BeautyPreset.swift` - Adds schema-versioned preset envelope decoding.
- `BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift` - Manifest and preset reference validation.
- `BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift` - Bundled catalog and preset loading API.
- `BeautySDK/Sources/BeautyResources/Resources/**` - Built-in manifest and preset JSON resources.
- `BeautySDK/Tests/BeautyCoreTests/BeautyPresetTests.swift` - Schema and built-in resource contract coverage.
- `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` - Manifest, filter, preset, missing-resource, and traversal-like ID coverage.

## Decisions Made

- SwiftPM flattens processed resource files into the module bundle, so preset lookup uses validated resource names directly against `Bundle.module`.
- `BeautyResourceManifest.isValidResourceIdentifier` rejects traversal-like identifiers in addition to the existing stable ASCII preset identifier rule.
- Built-in preset values remain conservative and natural; no visual rendering or LUT assets were introduced.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Adjusted preset resource bundle lookup**
- **Found during:** Task 1 (resource catalog verification)
- **Issue:** The initial lookup used `subdirectory: "Presets"`, but SwiftPM processed resources were available directly in the generated bundle.
- **Fix:** Changed lookup to `Bundle.module.url(forResource:withExtension:)` while keeping resource names fixed and manifest-validated.
- **Files modified:** `BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift`
- **Verification:** `swift test --package-path BeautySDK --filter BeautyResourceCatalogTests` passed.
- **Committed in:** `ab64e10`

---

**Total deviations:** 1 auto-fixed (blocking verification issue).
**Impact on plan:** No scope expansion; resource IDs remain validated identifiers and no caller-provided paths were introduced.

## Issues Encountered

- RED run failed as expected before implementation because `BeautyResources/Resources` did not exist after adding the package resource declaration.

## User Setup Required

None - no external service configuration required.

## Verification

- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyResourceCatalogTests` - passed, 5 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyPresetTests` - passed, 6 tests.
- `rg -n "schemaVersion|soft_clean|warm_light|id-photo-natural" BeautySDK/Sources/BeautyResources BeautySDK/Tests/BeautyResourcesTests` - returned expected manifest, preset, and test references.

## Next Phase Readiness

Ready for `05-02`: public facade resource APIs can wrap `BeautyResourceCatalog`, and Demo can later consume built-in filters/presets through `BeautySDK`.

---
*Phase: 05-filters-presets-and-resource-flow*
*Completed: 2026-06-19*
