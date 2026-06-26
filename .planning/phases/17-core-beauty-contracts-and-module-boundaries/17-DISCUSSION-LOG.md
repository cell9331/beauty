# Phase 17: Core Beauty Contracts and Module Boundaries - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-26
**Phase:** 17-core-beauty-contracts-and-module-boundaries
**Areas discussed:** Taxonomy and status labels, Demo-vs-SDK ownership boundaries, Verification and evidence gates

---

## Taxonomy and Status Labels

### Status Model

| Option | Description | Selected |
|--------|-------------|----------|
| Strict four-state model | Every branch must be exactly one of `implemented`, `partial`, `blocked-by-geometry-output`, or `future`. | ✓ |
| Keep current flexible labels | Preserve labels like `static/future` and `partial/future`. | |
| Use implementation-only labels | Only distinguish `implemented` versus `future`. | |
| Other | Freeform alternative. | |

**User's choice:** Strict four-state model.  
**Notes:** Prevents ambiguous mixed states before Phases 18 and 19.

### Status Granularity

| Option | Description | Selected |
|--------|-------------|----------|
| Branch status plus subtool notes | Each branch gets one status, with notes for covered and future subtools. | ✓ |
| Every subtool gets its own status | Track each mind-map leaf separately. | |
| Branch-only status | Keep one status per branch with no subtool detail. | |
| Other | Freeform alternative. | |

**User's choice:** Branch status plus subtool notes.  
**Notes:** Branch status remains readable while preserving gaps such as uncovered eye/nose/lip subtools.

### Blueprint Treatment

| Option | Description | Selected |
|--------|-------------|----------|
| Tighten and normalize in place | Keep current docs/folders and update status wording, ownership, exclusions, and branch notes. | ✓ |
| Rebuild the blueprint structure | Reorganize docs and branch folders before implementation. | |
| Only append a Phase 17 contract file | Leave current docs mostly untouched and add one summary contract. | |
| Other | Freeform alternative. | |

**User's choice:** Tighten and normalize in place.  
**Notes:** Avoids broad restructuring while making the current blueprint authoritative enough for planning.

### Future Public Parameters

| Option | Description | Selected |
|--------|-------------|----------|
| Mark current-parameter coverage separately | Say what maps to existing `BeautyParameters`; require root contract updates for new public parameters later. | ✓ |
| Let implementation phases decide | Phase 17 names branches only. | |
| Avoid new public parameters in v1.3 | Treat all uncovered subtools as future. | |
| Other | Freeform alternative. | |

**User's choice:** Mark current-parameter coverage separately.  
**Notes:** Later public parameter work must update `DESIGN.md` and acceptance docs.

---

## Demo-vs-SDK Ownership Boundaries

### Product Taxonomy Location

| Option | Description | Selected |
|--------|-------------|----------|
| Docs/Demo taxonomy only; SDK stays product-neutral | Chinese branch names live in blueprint docs and Demo mapping; SDK concepts stay product-neutral. | ✓ |
| Mirror branch names inside SDK planning types | Add Meitu-style labels deeper into SDK effect planning docs/types. | |
| Docs only, not Demo mapping | Keep Meitu names only in docs. | |
| Other | Freeform alternative. | |

**User's choice:** Docs/Demo taxonomy only; SDK stays product-neutral.  
**Notes:** Keeps the SDK facade and internal planning names stable for host apps.

### Demo Responsibilities

| Option | Description | Selected |
|--------|-------------|----------|
| Explicit app-side contract | Enumerate category rails, labels, badges, slider mapping, compare/debug, cancel/confirm, input routing, and parameter snapshots as Demo-owned. | ✓ |
| Light contract only | Say "Demo owns UI" generally. | |
| Defer Demo ownership details to Phase 20 | Finalize editor-support ownership later. | |
| Other | Freeform alternative. | |

**User's choice:** Explicit app-side contract.  
**Notes:** Prevents implementation phases from moving product UI state into SDK targets.

### Mixed SDK Dependencies

| Option | Description | Selected |
|--------|-------------|----------|
| Primary owner plus dependencies | Each branch has one primary owner and dependency notes. | ✓ |
| Multiple co-equal owners | List every involved target as owner. | |
| Owner only, no dependencies | Keep branch docs short. | |
| Other | Freeform alternative. | |

**User's choice:** Primary owner plus dependencies.  
**Notes:** Example: beauty shaping primary owner `BeautyEffects`, with `BeautyDetection` and `BeautyRender` dependencies.

### BeautyResources Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Only mention as dependency/future owner when needed | Keep resource/style systems excluded; mention `BeautyResources` only for validation boundaries or future resource needs. | ✓ |
| Add resource branch planning now | Include resource packs, makeup, stickers, and style assets. | |
| Remove `BeautyResources` from Phase 17 ownership maps | Avoid resource references entirely. | |
| Other | Freeform alternative. | |

**User's choice:** Only mention as dependency/future owner when needed.  
**Notes:** Keeps resource/style systems out of v1.3 while preserving accurate dependency language.

---

## Verification and Evidence Gates

### Phase 17 Verification

| Option | Description | Selected |
|--------|-------------|----------|
| Docs and boundary scans only | Verify docs/root consistency, branch/status normalization, facade-only imports, no new SwiftUI screens, and no internal Demo imports. | ✓ |
| Also run full SDK tests | Add `swift test --package-path BeautySDK` as a Phase 17 gate. | |
| Only markdown checks | Skip code/import scans. | |
| Other | Freeform alternative. | |

**User's choice:** Docs and boundary scans only.  
**Notes:** Phase 17 is a contract phase; algorithm output belongs to implementation phases.

### Later Completion Evidence

| Option | Description | Selected |
|--------|-------------|----------|
| Evidence ladder by capability type | `implemented` requires tests plus example-image output when facade-visible; `partial` can use provider/unit evidence; `blocked-by-geometry-output` records integration blocker; `future` has no implementation claim. | ✓ |
| Single standard for all branches | Every branch needs tests and example-image output before any non-future status. | |
| Docs-only status allowed | Mark implementation status from code reading alone. | |
| Other | Freeform alternative. | |

**User's choice:** Evidence ladder by capability type.  
**Notes:** Gives skin/color and geometry branches different honest evidence paths.

### Geometry Provider Tests

| Option | Description | Selected |
|--------|-------------|----------|
| Provider evidence counts as partial, not visible complete | Existing provider/resolver tests support `partial`; visual completion waits for public facade image output. | ✓ |
| Provider tests count as implemented | Mark geometry branches implemented when provider/unit tests pass. | |
| Ignore provider tests for status | Treat geometry branches without facade-visible output as future. | |
| Other | Freeform alternative. | |

**User's choice:** Provider evidence counts as partial, not visible complete.  
**Notes:** Geometry completion requires `BeautyEngine.processResult(...)` plus detection/geometry render integration through the public facade.

### Root Contract Updates

| Option | Description | Selected |
|--------|-------------|----------|
| Only if the contract changes | Update root docs only when Phase 17 adds or changes a real contract. | ✓ |
| Always update root contracts | Any Phase 17 doc work touches root docs. | |
| Never update root contracts in Phase 17 | Keep edits inside blueprint docs and planning artifacts only. | |
| Other | Freeform alternative. | |

**User's choice:** Only if the contract changes.  
**Notes:** Clarifying existing no-new-UI/core-module boundaries does not require root-doc churn.

---

## the agent's Discretion

- Exact wording, table layout, and cross-reference placement for Phase 17 planning may be chosen by the planner, as long as captured decisions remain intact.

## Deferred Ideas

- None.
