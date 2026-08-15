---
phase: 66-legacy-ui-demo-archive-and-sdk-only-boundary
plan: "01"
subsystem: tooling
tags: [archive, taxonomy, sdk-boundary, swiftpm, fail-closed]

requires: []
provides:
  - Deterministic, digest-bound archive creation and verification for the two legacy UI roots
  - SDK-owned exact effect taxonomy independent of deletable Demo/UI sources
  - Pre-archive and post-archive SDK-only boundary scanner with mutation self-tests
affects: [66-02-archive-retirement, 66-03-sdk-only-closeout, phase-67]

tech-stack:
  added: []
  patterns: [standard-library deterministic ZIPs, exact inventory manifests, fail-closed static boundary scanning]

key-files:
  created:
    - scripts/archive-legacy-ui.py
    - archives/legacy-ui/README.md
    - docs/SDK_EFFECT_TAXONOMY.md
    - scripts/check-sdk-only-boundary.sh
  modified: []

key-decisions:
  - "The current SDK taxonomy owns exact legacy algorithm/control meanings and public mappings without inheriting visual layout or application behavior."
  - "The v1.16 boundary pins the retained Warp.metal bytes and rejects Xcode, SwiftUI, UI-test, generated-media, and GPU/backend drift."

patterns-established:
  - "Archive transaction: enumerate live files, create deterministic artifacts, independently verify and reproduce, then permit digest-bound exact-target retirement."
  - "Boundary mutation tests: each forbidden restoration or scope drift must make the scanner fail non-zero."

requirements-completed: [BOUNDARY-02, ARCHIVE-01, ARCHIVE-02]

duration: 18min
completed: 2026-08-14
---

# Phase 66 Plan 01: Archive and SDK-Only Boundary Tooling Summary

**Deterministic dual-root ZIP verification plus an exact 61-parameter SDK taxonomy and fail-closed SDK-only repository scanner**

## Performance

- **Duration:** 18 min
- **Started:** 2026-08-14T01:52:47Z
- **Completed:** 2026-08-14T02:10:19Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Added deterministic `create`, `verify`, `reproduce`, self-test, and digest-bound guarded-retirement tooling for exactly `BeautyDemo/` and `meituxiuxiu/`.
- Preserved all current legacy shaping/facial-feature rows, branch meanings, and canonical mappings in an SDK-owned taxonomy backed by the exact 61-field `BeautyParameters` inventory.
- Added pre-archive inventory validation and post-archive rejection of restored UI/Demo sources, Xcode/SwiftUI/UI-test dependencies, tracked media, and Metal/GPU drift.
- Expanded scanner mutation coverage for restored roots, UI-test artifacts and symbols, SwiftUI source, and modification of the one retained Metal file.

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement deterministic archive creation and verification** - `e193f59` (feat)
2. **Task 2: Preserve the SDK effect taxonomy and add the boundary scanner** - `ae5f210` (docs)

## Files Created/Modified

- `scripts/archive-legacy-ui.py` - Enumerates, archives, verifies, reproduces, and safely retires the two exact legacy roots.
- `archives/legacy-ui/README.md` - Defines archive scope, exclusions, verification, retirement, and restoration commands.
- `docs/SDK_EFFECT_TAXONOMY.md` - Owns the current product-neutral effect groups, statuses, and canonical SDK parameter mappings.
- `scripts/check-sdk-only-boundary.sh` - Validates taxonomy/archive preconditions and the post-retirement SDK-only boundary.

## Decisions Made

- Kept `去脂` future and explicitly prohibited proxying it through existing eye, brow, smoothing, eye-bag, or dark-circle behavior, following the project spike constraints.
- Treated white-teeth and sclera-redness mappings as bounded opaque still-image controls only; no realtime/pixel-buffer or public geometry claim was added.
- Pinned the pre-v1.17 `Warp.metal` SHA-256 so modifications to the existing allowed Metal path fail just as new Metal files do.
- Allowed archived milestone/phase history and the retained archive documentation to mention historical UI/Xcode paths while scanning current owners and active source fail-closed.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Metadata state] Corrected malformed state-handler output**
- **Found during:** Plan metadata update
- **Issue:** The state handler left progress at 0%, placed the metric row in the Deferred Items table, and left ROADMAP plan progress as `TBD` despite detecting one of three summaries.
- **Fix:** Corrected the progress counters/bar and milestone totals, removed the misplaced row, and recorded Phase 66 as 1/3 plans complete.
- **Files modified:** `.planning/STATE.md`, `.planning/ROADMAP.md`
- **Verification:** Summary count, current plan, progress percentage, metrics, and roadmap plan count agree.
- **Committed in:** Plan metadata commit

---

**Total deviations:** 1 auto-fixed (1 metadata state bug)
**Impact on plan:** Metadata only; Task 1 and Task 2 implementation scope remained unchanged.

## Issues Encountered

- Serena tools were not exposed in this executor session, so structural inspection used repository text/source reads and `rg`.
- The shell wrapper `gsd-tools` was not on `PATH`; the canonical Node CLI at `~/.codex/get-shit-done/bin/gsd-tools.cjs` supplied state queries.

## Verification

- `bash scripts/check-sdk-only-boundary.sh --self-test` - passed.
- `bash scripts/check-sdk-only-boundary.sh --pre-archive` - passed.
- `git diff --check` and `git diff --cached --check` - passed.
- `bash -n scripts/check-sdk-only-boundary.sh` - passed.

## User Setup Required

None - no external service configuration is required.

## Threat Flags

| Flag | File | Description |
| --- | --- | --- |
| threat_flag: archive-extraction | `scripts/archive-legacy-ui.py` | Reads and extracts retained ZIP content behind safe-path, manifest, size, and SHA-256 equality checks. |
| threat_flag: destructive-file-operation | `scripts/archive-legacy-ui.py` | The guarded `retire` operation deletes exactly two digest-approved roots only after fresh verification/reproduction and checks deletion postconditions. |

## Next Phase Readiness

- Phase 66 Plan 02 can materialize both archive bundles, reproduce them byte-for-byte, and invoke guarded retirement.
- No original UI/Demo source was removed by this plan; both roots remain present for the archive transaction.
- Metal/GPU implementation, UI/Demo work, device/commercial validation, packaging, shipping, and release readiness remain out of scope.

## Self-Check: PASSED

- All four plan-owned files and this summary exist.
- Task commits `e193f59` and `ae5f210` exist in repository history.
- Both live archive source roots still exist, and the verification/diff checks are green.

---
*Phase: 66-legacy-ui-demo-archive-and-sdk-only-boundary*
*Completed: 2026-08-14*
