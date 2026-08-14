---
phase: 67-swiftpm-consumer-and-cli-validation-contract
plan: "01"
subsystem: testing-and-tooling
tags: [swiftpm, public-api, consumer-fixture, no-skip, privacy]

# Dependency graph
requires:
  - phase: 66-legacy-ui-demo-archive-and-sdk-only-boundary
    provides: archive-first SDK-only boundary and one-child no-skip gate
provides:
  - independent local-path SwiftPM consumer that exercises the public BeautySDK product
  - clean-scratch generated RGBA neutral facade smoke with exact output assertions
  - fail-closed consumer boundary/runtime preflight bound before the no-skip test child
affects: [phase-67-cli-validation, phase-68-cpu-algorithm-reference, phase-69-sdk-only-closeout]

# Tech tracking
tech-stack:
  added: [SwiftPM executable fixture, Swift/CoreImage generated-input smoke]
  patterns: [public-product-only consumer, static dump-package boundary check, bounded scratch preflight]

key-files:
  created:
    - IntegrationTests/BeautySDKConsumer/Package.swift
    - IntegrationTests/BeautySDKConsumer/Sources/BeautySDKConsumer/main.swift
    - scripts/check-swiftpm-consumer.sh
    - .planning/phases/67-swiftpm-consumer-and-cli-validation-contract/67-01-SUMMARY.md
  modified:
    - scripts/run-no-skip-swiftpm.sh

key-decisions:
  - "The consumer remains a separate one-target package with exactly one local path dependency and only the public BeautySDK product dependency." 
  - "Neutral smoke validation asserts the documented empty warnings, active/capped zero metrics, notRun detection summary, exact 4x3 extent, and exact RGBA bytes." 
  - "The consumer preflight runs after archive and SDK-boundary checks but before private fixtures and the sole complete SwiftPM test child." 

patterns-established:
  - "Generate opaque named-sRGB RGBA8 input in Swift and observe the real public facade through a named-sRGB CIContext; do not track image fixtures."
  - "Validate fixture source/imports, local dependency resolution, and public product selection with explicit source checks plus swift package dump-package."
  - "Build and run in a fresh temporary scratch root, bound captured child output, require one fixed aggregate line, and clean up on every exit."

requirements-completed: [SPM-01, SPM-02]

# Metrics
duration: 6min
completed: 2026-08-14
---

# Phase 67 Plan 01: SwiftPM Consumer and CLI Validation Contract Summary

**Independent public-product SwiftPM consumption now proves a generated 4×3 neutral image round-trip and gates the mandatory no-skip suite with static and runtime checks.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-08-14T05:13:05Z
- **Completed:** 2026-08-14T05:19:27Z
- **Tasks:** 2
- **Files modified:** 5 (4 created, 1 modified; summary included separately)

## Accomplishments

- Added `IntegrationTests/BeautySDKConsumer` as a clean Swift 6 executable package outside the `BeautySDK` package root. It has exactly one local `../../BeautySDK` dependency and imports only the public `BeautySDK` project module.
- Generated a finite opaque named-sRGB RGBA8 4×3 pattern entirely in Swift, called `BeautyEngine.processResult(image:metadata:parameters:)` with `.testFixture`, `.up`, and neutral parameters, and asserted success, neutral warnings/metrics/detection semantics, exact extent/dimensions, exact byte count, and byte-for-byte output equality.
- Added a fail-closed checker that rejects symlinked/missing fixture files, non-public imports/SPI/internal targets/Demo/Xcode tokens, remote or non-local dependencies, and non-BeautySDK products using source inspection plus `swift package dump-package`.
- Added clean-scratch build/runtime validation with bounded logs, exact aggregate-line matching, cleanup traps, and mutation-oriented static self-tests; wired it after archive and SDK-only boundary checks and before private fixture checks and the sole complete SwiftPM child.

## Task Commits

Each task was committed atomically:

1. **Task 1: Build the independent public-product consumer smoke** - `da1178a` (feat)
2. **Task 2: Make the consumer smoke a fail-closed mandatory preflight** - `2e9ae63` (chore)
3. **Task 2 cleanup hardening: retain temporary-directory cleanup on process exit** - `baef409` (fix)

**Plan metadata:** `bf19368` (docs: complete plan)

## Files Created/Modified

- `IntegrationTests/BeautySDKConsumer/Package.swift` - independent local-path consumer manifest with one public product dependency.
- `IntegrationTests/BeautySDKConsumer/Sources/BeautySDKConsumer/main.swift` - generated-input public-facade executable smoke.
- `scripts/check-swiftpm-consumer.sh` - static manifest/source classifier and bounded clean-scratch build/runtime gate.
- `scripts/run-no-skip-swiftpm.sh` - archive → SDK boundary → external consumer → private fixture → one-child ordering.

## Decisions Made

- Kept the external fixture free of tracked media and SDK internals so SPM-01 evidence is an actual host-consumption contract.
- Treated the neutral public result's documented metrics as `beauty.effects.activeCount = 0` and `beauty.effects.cappedCount = 0`, with empty warnings and `.notRun` detection.
- Kept all diagnostics aggregate-only: the consumer prints one fixed success line and the checker suppresses compiler/runtime details while checking bounded temporary logs.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Made temporary-path validation canonical across macOS path aliases**

- **Found during:** Task 2 (consumer preflight verification)
- **Issue:** `mktemp` returned a path with a double slash and `/private` aliasing, while SwiftPM normalized its reported build/source paths, causing valid self-test and runtime paths to be rejected.
- **Fix:** Resolve source paths in the static classifier and canonicalize the runtime scratch directory before comparing the `swift build --show-bin-path` result.
- **Files modified:** `scripts/check-swiftpm-consumer.sh`
- **Verification:** static self-test and live clean-scratch consumer check both passed.
- **Committed in:** `2e9ae63` (part of task commit)

**2. [Rule 1 - Bug] Made rejected mutation cases return immediately from the classifier**

- **Found during:** Task 2 mutation self-test
- **Issue:** A failed static Python check could fall through to manifest resolution and incorrectly be treated as valid.
- **Fix:** Return failure immediately for missing/symlinked files and each failed source/dump-package validation branch; self-test expects all three mutations to fail.
- **Files modified:** `scripts/check-swiftpm-consumer.sh`
- **Verification:** source-import, product-selection, and remote-dependency mutations are rejected; valid fixture passes.
- **Committed in:** `2e9ae63` (part of task commit)

**3. [Rule 2 - Missing Critical] Keep temporary scratch cleanup active through process exit**

- **Found during:** Task 2 post-commit hardening
- **Issue:** Function-return cleanup did not cover abnormal process exits, leaving the checker scratch directory without a process-level cleanup guarantee.
- **Fix:** Use value-captured `EXIT` traps for the clean build/runtime and static self-test temporary roots.
- **Files modified:** `scripts/check-swiftpm-consumer.sh`
- **Verification:** syntax, static self-test, live clean-scratch consumer check, and no-skip transcript self-test passed.
- **Committed in:** `baef409` (follow-up fix for Task 2)

---

**Total deviations:** 3 auto-fixed (Rule 1: 2 bugs; Rule 2: 1 missing critical cleanup guarantee)
**Impact on plan:** Both fixes make the required fail-closed checker deterministic and do not expand scope.

## Issues Encountered

- Serena was not exposed in this executor session; repository `rg`, SwiftPM, and SDK-owned scripts were used for structural discovery and verification.
- No authentication, package installation, remote dependency, UI/Demo, simulator/device, Metal/GPU, or tracked media work was required.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- SPM-01 and SPM-02 are covered by compiled external Swift code and a mandatory preflight that cannot reach the complete SwiftPM child when the consumer boundary or runtime smoke drifts.
- The fixture and checker are ready for later Phase 67 CLI plans; no CLI implementation, public backend switch, or generated artifact was added here.

## Verification

- `swift build --package-path IntegrationTests/BeautySDKConsumer --scratch-path <fresh-temp>/build` - passed.
- Compiled consumer executable - passed exact `beauty_sdk_consumer_smoke_passed width=4 height=3 rgba_bytes=48` output.
- `bash -n scripts/check-swiftpm-consumer.sh scripts/run-no-skip-swiftpm.sh` - passed.
- `bash scripts/check-swiftpm-consumer.sh --self-test` - passed mutation classifier checks.
- `bash scripts/check-swiftpm-consumer.sh` - passed clean-scratch build/link/run and exact aggregate output.
- `bash scripts/run-no-skip-swiftpm.sh --self-test` - passed bounded transcript self-test.
- `git diff --check` - passed.

## Self-Check: PASSED

- All plan-created files exist and are regular non-symlink files.
- Task commits `da1178a` and `2e9ae63` exist in repository history.
- No generated `.build`, input, output, report, or private fixture artifact was created under the repository fixture tree.

---
*Phase: 67-swiftpm-consumer-and-cli-validation-contract*
*Completed: 2026-08-14*
