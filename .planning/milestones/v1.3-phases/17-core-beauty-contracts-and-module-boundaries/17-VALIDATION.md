---
phase: 17
slug: core-beauty-contracts-and-module-boundaries
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-26
---

# Phase 17 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Markdown contract scans plus git scope checks |
| **Config file** | none |
| **Quick run command** | `rg -n "implemented|partial|blocked-by-geometry-output|future" docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` |
| **Full suite command** | `git diff --check -- docs/meitu-function-blueprint .planning/phases/17-core-beauty-contracts-and-module-boundaries .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md PLANS.md` |
| **Estimated runtime** | under 15 seconds |

## Sampling Rate

- **After every contract edit task:** Run the relevant status, folder-scope, or import-boundary scan.
- **After 17-01:** Run all blueprint status, branch-folder, and deferred-family scans.
- **After 17-02:** Run planning-ledger scans, root-contract scope checks, and `git diff --check`.
- **Before `$gsd-verify-work`:** Re-run all Phase 17 verification commands.
- **Max feedback latency:** under 15 seconds for the documentation/static scan set.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 17-01-01 | 17-01 | 1 | CBT-01, BSHAPE-03 | T-17-01 | Status labels are explicit and do not overclaim unsupported behavior. | static/docs | `! rg -n "static/future|partial/future|static/unavailable|planned-doc" docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` | W0 | pending |
| 17-01-02 | 17-01 | 1 | CBT-01, CBT-02, BSHAPE-01, SKIN-01 | T-17-02 | Branch rows separate current public parameters from future needs. | static/docs | `rg -n "BeautyParameters|faceSlim|eyeSize|noseSlim|mouthSize|skinSmoothing|future parameter|blocked-by-geometry-output" docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/features/beauty-shaping/README.md docs/meitu-function-blueprint/features/skin-retouch/README.md` | W0 | pending |
| 17-01-03 | 17-01 | 1 | CBT-02, CBT-03, MOD-01 | T-17-03 | Active folders and ownership exclude deferred product/resource families. | static/docs | `node -e 'const fs=require("fs"); const dirs=fs.readdirSync("docs/meitu-function-blueprint/features",{withFileTypes:true}).filter(d=>d.isDirectory()).map(d=>d.name).sort(); const allowed=["beauty-shaping","editor-shell","skin-retouch"]; if(JSON.stringify(dirs)!==JSON.stringify(allowed)){console.error(dirs); process.exit(1)}'` | W0 | pending |
| 17-01-04 | 17-01 | 1 | MOD-01, EDITOR-01, EDITOR-02, EDITOR-03 | T-17-04 | Demo shell remains app-owned and facade-only. | static/docs | `rg -n "category rails|labels|badges|slider|compare/debug|cancel/confirm|input routing|parameter snapshot|BeautyDemo|BeautySDK facade" docs/meitu-function-blueprint/MODULES.md docs/meitu-function-blueprint/features/editor-shell/README.md` | W0 | pending |
| 17-02-01 | 17-02 | 2 | CBT-01, CBT-02, CBT-03, MOD-01 | T-17-05 | Root contracts are consistent with the normalized blueprint. | static/docs | `rg -n "BeautyDemo|BeautySDK|BeautyEffects|BeautyDetection|BeautyRender|BeautyResources|BeautyParameters" ARCHITECTURE.md DESIGN.md FRONTEND.md docs/meitu-function-blueprint/MODULES.md` | W0 | pending |
| 17-02-02 | 17-02 | 2 | MOD-01 | T-17-06 | Demo and renderer do not import internal SDK targets. | static/code | `! rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests BeautySDK/Sources/BeautyExampleRenderer` | W0 | pending |
| 17-02-03 | 17-02 | 2 | CBT-01, CBT-02, CBT-03, MOD-01 | T-17-07 | Planning ledgers close only after evidence exists. | static/docs | `rg -n "CBT-01|CBT-02|CBT-03|MOD-01|17-01|17-02|blocked-by-geometry-output" .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md PLANS.md .planning/phases/17-core-beauty-contracts-and-module-boundaries` | W0 | pending |

## Wave 0 Requirements

- [x] Existing shell tools `rg`, `node`, and `git` cover all Phase 17 validation.
- [x] Existing blueprint docs exist in `docs/meitu-function-blueprint/`.
- [x] Existing Phase 17 context exists at `.planning/phases/17-core-beauty-contracts-and-module-boundaries/17-CONTEXT.md`.
- [x] No test framework installation is needed for this documentation-only planning phase.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Root contract update decision | MOD-01 | A shell scan can show whether root docs changed, but the executor must judge whether each change represents a real contract change or only duplicate wording. | If any root doc changes, cite the exact contract reason in the summary. If no root doc changes, record that Phase 17 only clarified existing no-new-UI and module boundaries. |

## Validation Sign-Off

- [x] All planned tasks have automated verify coverage or an explicit manual-only reason.
- [x] Sampling continuity: no three consecutive tasks without automated verify.
- [x] Wave 0 covers existing tooling and docs.
- [x] No watch-mode flags.
- [x] Feedback latency target documented.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-26
