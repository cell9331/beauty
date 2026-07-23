---
phase: 47-public-facade-face-output-evidence
plan: "01"
subsystem: renderer-facade
tags: [swift, renderer, facade, degradation, redaction]

requires:
  - phase: 46-independent-contour-and-chin-geometry
    provides: four independent contour/chin fields and observed-support routing
provides:
  - exact 59-case public renderer inventory with four isolated Phase 47 cases
  - missing/malformed observed-contour public degradation evidence
  - shipped face-sibling continuation and aggregate-only redaction evidence
affects: [47-02, 47-03, public-renderer, public-facade]

tech-stack:
  added: []
  patterns:
    - isolated one-field renderer cases through the shared public facade call
    - fresh-provider sibling-only baselines for degraded observed support

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyExampleRenderer/main.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift

key-decisions:
  - "Use the locked provisional value 0.25 for all four isolated output cases."
  - "Compare each degraded request with a fresh equivalent shipped-sibling-only facade run so removed new-field work cannot hide in aggregate evidence."
  - "Keep missing/malformed support fixtures testing-only and expose only existing aggregate public results."

requirements-completed: []

duration: 5 min
completed: 2026-07-23
---

# Phase 47 Plan 01: Public Renderer and Degradation Contracts Summary

**Exactly four isolated public face cases extend the renderer to 59 while missing or malformed observed contour fails new work closed and preserves a shipped sibling**

## Accomplishments

- Added `faceContourSmooth_0p25`, `templeFullness_0p25`, `cheekboneSlim_0p25`, and `chinTaper_0p25` as isolated public-facade renderer cases without changing the prior 55-case order or the single `BeautyEngine.processResult` route.
- Locked exact ordered inventory, one-field source isolation, no-face extent safety, and aggregate diagnostic redaction in the renderer regression suite.
- Added testing-only missing and malformed observed-contour fixtures that retain complete shipped landmarks.
- Proved all four new fields contribute no output, metric, warning, or geometry evidence when their required contour support is absent or invalid, while an eligible `faceSlim` sibling continues unchanged.

## Task Commits

1. **Task 47-01-01: Add exact isolated renderer cases and public source/no-face contracts** — `3671f50`
2. **Task 47-01-02: Add missing/malformed observed-contour public degradation fixtures** — `2f8fdc4`

## Verification

- `BeautyRendererOutputRegressionTests` — **PASS, 15/15**.
- Exact renderer inventory — **PASS, 59 unique cases**.
- Shared public facade route — **PASS, one `engine.processResult` call**.
- `BeautyEngineGeometryFacadeTests` — **PASS, 16/16**.
- `BeautySDK/Package.swift` git-blob hash — **PASS, unchanged at `6f03b078816ad1f7a426e3f70d4f57503f3152e9`**.
- `git diff --check` — **PASS**.

## Deviations from Plan

None.

## Next Phase Readiness

Plan 47-02 can now discover a frozen 59-case renderer inventory and validate the clean 59 × 7 public output matrix with bounded decoded image evidence.

## Self-Check: PASSED

- All four plan-owned files and this summary exist.
- Both task commits exist in repository history.
- Focused public renderer and facade suites pass without production package or dependency changes.

---
*Phase: 47-public-facade-face-output-evidence*
*Completed: 2026-07-23*
