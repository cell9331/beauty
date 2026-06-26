---
phase: 17-core-beauty-contracts-and-module-boundaries
plan: 17-01
subsystem: docs
tags: [core-beauty, blueprint, module-boundaries, documentation]
requires:
  - phase: 16-example-image-validation-harness
    provides: BeautyExampleRenderer command/output contract and geometry-output limitation
provides:
  - Strict branch status vocabulary for v1.3 core beauty blueprint docs
  - Branch-level feature matrix with owner, dependencies, parameters, future needs, and evidence expectations
  - Demo-vs-SDK ownership notes for editor shell, beauty shaping, and skin retouch
  - Explicit deferred-family exclusions for non-core product/resource areas
affects: [phase-18, phase-19, phase-20, core-beauty-contracts]
tech-stack:
  added: []
  patterns: [markdown-contract-scan, facade-output-evidence-ladder]
key-files:
  created:
    - docs/meitu-function-blueprint/FEATURE_MATRIX.md
    - docs/meitu-function-blueprint/MINDMAP.md
    - docs/meitu-function-blueprint/README.md
    - docs/meitu-function-blueprint/features/beauty-shaping/README.md
    - docs/meitu-function-blueprint/features/editor-shell/README.md
    - docs/meitu-function-blueprint/features/skin-retouch/README.md
    - docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md
  modified:
    - docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md
    - docs/meitu-function-blueprint/MODULES.md
key-decisions:
  - "Branch statuses are limited to implemented, partial, blocked-by-geometry-output, and future."
  - "Geometry provider/resolver evidence remains partial until public facade saved-image output exists."
  - "Meitu branch labels stay in blueprint/Demo taxonomy while SDK references stay product-neutral."
patterns-established:
  - "Feature matrix rows carry status, primary owner, dependencies, current public parameters, future parameter needs, and evidence expectation."
  - "BeautyResources is documented only as a dependency/future resource participant, not an active owner for deferred product/resource systems."
requirements-completed: [CBT-01, CBT-02, CBT-03, MOD-01]
duration: 8 min
completed: 2026-06-26
---

# Phase 17 Plan 17-01: Normalize Core Beauty Blueprint Contracts Summary

**Strict v1.3 core beauty blueprint contracts with branch statuses, ownership, parameter coverage, future needs, and geometry-output evidence gates.**

## Performance

- **Duration:** 8 min
- **Started:** 2026-06-26T09:11:00Z
- **Completed:** 2026-06-26T09:19:36Z
- **Tasks:** 4
- **Files modified:** 9

## Accomplishments

- Replaced the mixed blueprint status vocabulary with `implemented`, `partial`, `blocked-by-geometry-output`, and `future`.
- Expanded `FEATURE_MATRIX.md` into the branch-level source of truth for active family scope, owner, dependencies, current public `BeautyParameters`, future parameter needs, and evidence expectation.
- Clarified Demo ownership for input routing, preview chrome, bottom panel, category rails, labels, badges, slider mapping, compare/debug, cancel/confirm, and parameter snapshots.
- Preserved active families as exactly `editor-shell`, `beauty-shaping`, and `skin-retouch`, with explicit exclusions for Home/discovery, resource/style systems, AI/background, video/body, gallery/account, search, VIP, payment, and entitlement behavior.

## Task Commits

1. **Task 1: Normalize status vocabulary and evidence ladder** - `d11a3bf`
2. **Task 2: Finalize branch-level feature matrix** - `d11a3bf`
3. **Task 3: Clarify module ownership and dependency boundaries** - `d11a3bf`
4. **Task 4: Preserve active family scope and deferred exclusions** - `d11a3bf`

All four documentation tasks were committed together because the status table, ownership rows, and family READMEs cross-reference the same Markdown contract edits.

## Files Created/Modified

- `docs/meitu-function-blueprint/README.md` - Added allowed status model and tightened active/deferred scope rules.
- `docs/meitu-function-blueprint/MINDMAP.md` - Added to tracked blueprint contract set.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` - Normalized branch status, owner, dependencies, parameter coverage, future needs, and evidence expectations.
- `docs/meitu-function-blueprint/MODULES.md` - Added branch ownership and Demo-vs-SDK dependency boundaries.
- `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md` - Replaced old status wording and preserved no-code/no-output Phase 17 limits.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` - Added the evidence ladder and geometry-output limitation.
- `docs/meitu-function-blueprint/features/editor-shell/README.md` - Enumerated Demo-owned editor shell responsibilities.
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` - Listed branch status, current parameters, future needs, and geometry evidence expectations.
- `docs/meitu-function-blueprint/features/skin-retouch/README.md` - Separated implemented basic skin from future repair and teeth/hairline branches.

## Decisions Made

- Geometry-heavy shaping branches with current parameters are `partial` until public facade saved-image output exists.
- `3D塑颜` is `blocked-by-geometry-output` because it is a documented geometry target with no current public parameters and no facade-visible geometry output path.
- `眉毛`, `Skin repair`, and `Teeth/hairline` remain `future` because they need new parameter/resource/segmentation designs before implementation claims.

## Verification

- `! rg -n "static/future|partial/future|static/unavailable|planned-doc" docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` passed.
- `rg -n "implemented|partial|blocked-by-geometry-output|future" docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` passed.
- `rg -n "provider|resolver|facade|saved-image|geometry" docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` passed.
- `rg -n "3D塑颜|比例|脸型|眼睛|嘴唇|鼻子|眉毛|Basic skin|Skin repair|Teeth/hairline|Input routing|Preview chrome|Bottom panel|Commit flow" docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/MINDMAP.md` passed.
- `rg -n "BeautyParameters|faceSlim|faceSmall|eyeSize|eyeDistance|noseSlim|noseBridge|mouthSize|mouthWidth|skinSmoothing|skinWhitening" docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/features/beauty-shaping/README.md docs/meitu-function-blueprint/features/skin-retouch/README.md` passed.
- `rg -n "facade|saved-image|blocked-by-geometry-output|partial" docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/features/beauty-shaping/README.md` passed.
- `rg -n "BeautyDemo|BeautySDK|BeautyCore|BeautyDetection|BeautyRender|BeautyEffects|BeautyResources" docs/meitu-function-blueprint/MODULES.md docs/meitu-function-blueprint/features/editor-shell/README.md docs/meitu-function-blueprint/features/beauty-shaping/README.md docs/meitu-function-blueprint/features/skin-retouch/README.md` passed.
- `rg -n "category rails|labels|badges|slider mapping|compare/debug|cancel/confirm|input routing|parameter snapshot" docs/meitu-function-blueprint/MODULES.md docs/meitu-function-blueprint/features/editor-shell/README.md` passed.
- `! rg -n "BeautyResources.*(filter|makeup|sticker|template|download|VIP|payment|entitlement)" docs/meitu-function-blueprint/MODULES.md docs/meitu-function-blueprint/features` passed after splitting deferred-family wording onto separate lines.
- `node -e 'const fs=require("fs"); const dirs=fs.readdirSync("docs/meitu-function-blueprint/features",{withFileTypes:true}).filter(d=>d.isDirectory()).map(d=>d.name).sort(); const allowed=["beauty-shaping","editor-shell","skin-retouch"]; if(JSON.stringify(dirs)!==JSON.stringify(allowed)){console.error(dirs); process.exit(1)}'` passed.
- `rg -n "Home/discovery|resource/style|AI/background|video/body|gallery/account|search|VIP|payment|entitlement" docs/meitu-function-blueprint/README.md docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md` passed.
- `test -z "$(git diff --name-only -- BeautyDemo BeautySDK/Sources example-images)"` passed.
- `git diff --check -- docs/meitu-function-blueprint` passed.

## Deviations from Plan

The implementation stayed within the planned documentation scope. The only process deviation was commit granularity: Tasks 1 through 4 landed in one Markdown contract commit (`d11a3bf`) because the same feature matrix and ownership tables satisfy multiple task criteria and would be inconsistent if partially committed.

**Total deviations:** 1 process deviation.
**Impact on plan:** No scope expansion and no source-code changes.

## Issues Encountered

- The negative `BeautyResources` scan initially matched deferred-family wording on the same line. The wording was split so the contract still excludes those areas while satisfying the deterministic scan.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Wave 2 can now verify root-contract consistency, import boundaries, no-code scope, requirement traceability, and planning-ledger closeout.

---
*Phase: 17-core-beauty-contracts-and-module-boundaries*
*Completed: 2026-06-26*
