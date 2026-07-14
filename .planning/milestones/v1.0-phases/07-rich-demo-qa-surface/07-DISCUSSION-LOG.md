# Phase 7: Rich Demo QA Surface - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-06-22T09:37:41Z
**Phase:** 7-Rich Demo QA Surface
**Areas discussed:** Parameter JSON workflow, Preset and reset semantics, Debug overlay surface, Final Demo readiness polish

---

## Parameter JSON Workflow

### Entry Shape

| Option | Description | Selected |
|--------|-------------|----------|
| Copy/paste JSON sheet | Minimal QA surface around `BeautyParameters: Codable`; no file importer/exporter scope. | yes |
| Local file import/export | More realistic tool flow, but wider UI and file-error scope. | |
| Both copy/paste and file import/export | More complete Demo, larger Phase 7 scope. | |
| Other | Freeform alternative. | |

**User's choice:** Copy/paste JSON sheet.
**Notes:** The workflow should support SDK QA rather than become file management.

### JSON Shape

| Option | Description | Selected |
|--------|-------------|----------|
| Versioned parameter envelope | `schemaVersion` plus `parameters`; safest future compatibility while still using `BeautyParameters`. | yes |
| Raw `BeautyParameters` only | Simplest round trip, less room for version/error messaging. | |
| Preset-like JSON | Includes id/name/version, useful for saved looks but becomes custom preset scope. | |
| Other | Freeform alternative. | |

**User's choice:** Versioned parameter envelope.
**Notes:** The payload should wrap `BeautyParameters`, not duplicate the parameter model.

### Import Validation

| Option | Description | Selected |
|--------|-------------|----------|
| Preview then apply only valid JSON | Decode into preview state, show redacted friendly errors, explicit Apply mutates parameters. | yes |
| Apply immediately when decode succeeds | Fewer taps but easier to surprise users/testers. | |
| Best-effort partial import | Flexible but harder to reason about for QA. | |
| Other | Freeform alternative. | |

**User's choice:** Preview then apply only valid JSON.
**Notes:** Current parameters must stay unchanged on failure.

### Export Payload

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal deterministic payload | `schemaVersion` plus `parameters`; stable round-trip is the priority. | yes |
| Human-readable metadata | Adds source/app/build/labels/timestamp for debugging. | |
| Debug bundle | Adds detection/debug summaries, but mixes preferences with runtime diagnostics. | |
| Other | Freeform alternative. | |

**User's choice:** Minimal deterministic payload.
**Notes:** Avoid timestamps and debug payloads in exported parameter JSON.

---

## Preset and Reset Semantics

### Single-Parameter Reset

| Option | Description | Selected |
|--------|-------------|----------|
| Reset to zero default | Matches current `BeautyParameterStore.reset(...)`; deterministic and preset-independent. | yes |
| Reset to selected preset baseline | Better for fine-tuning presets, but requires storing baselines. | |
| Offer both default and preset reset | More complete, more UI/state complexity. | |
| Other | Freeform alternative. | |

**User's choice:** Reset to zero default.
**Notes:** Single reset should not depend on preset history.

### Reset All

| Option | Description | Selected |
|--------|-------------|----------|
| Always reset to SDK zero defaults | Current behavior; clears filter and selected preset/import state. | yes |
| Reset to last applied preset/import baseline | Better for undoing tweaks, but changes Reset All meaning. | |
| Separate Reset All vs Revert to Applied | Clearer semantics but larger UI surface. | |
| Other | Freeform alternative. | |

**User's choice:** Always reset to SDK zero defaults.
**Notes:** Reset All clears selected preset/import state.

### Imported JSON Source State

| Option | Description | Selected |
|--------|-------------|----------|
| No selected preset | Imported parameters apply as a custom snapshot; preset chips deselect. | yes |
| Temporary Imported chip | Clear provenance but adds pseudo-preset state. | |
| Preserve matching preset | Avoids losing selection, but confusing and hard to test. | |
| Other | Freeform alternative. | |

**User's choice:** No selected preset.
**Notes:** Imported JSON is custom parameter state, not a preset.

### Manual Edits

| Option | Description | Selected |
|--------|-------------|----------|
| Clear applied-source state | Current preset behavior; any manual edit means custom snapshot. | yes |
| Keep source label until Reset All | Shows origin, but no longer means exact values. | |
| Keep source plus modified state | Precise but adds extra UI/state modeling. | |
| Other | Freeform alternative. | |

**User's choice:** Clear applied-source state.
**Notes:** Slider/filter edits after preset or import make the snapshot custom.

---

## Debug Overlay Surface

### Toggle

| Option | Description | Selected |
|--------|-------------|----------|
| Single debug button on preview surface | One unobtrusive read-only toggle near compare, shared by camera/photo preview. | yes |
| Debug row inside parameter panel | Easier to test, but mixes debug with editing controls. | |
| Always-on in debug builds only | Low UI work, less useful for Demo validation/screenshots. | |
| Other | Freeform alternative. | |

**User's choice:** Single debug button on preview surface.
**Notes:** Debug overlay belongs near preview and compare.

### Overlay Fields

| Option | Description | Selected |
|--------|-------------|----------|
| Safe diagnostic summary | Detection availability, reason codes, face counts, timings, warning count, key frame status. | yes |
| Full SDK metrics table | More complete, but noisy and redaction-heavy. | |
| User-friendly status only | Simple, but not enough QA/debug value beyond status banners. | |
| Other | Freeform alternative. | |

**User's choice:** Safe diagnostic summary.
**Notes:** Keep it QA-useful but privacy-safe.

### Geometry Drawing

| Option | Description | Selected |
|--------|-------------|----------|
| No geometry drawing in Phase 7 | Matches privacy/security contracts; redacted summaries only. | yes |
| Preview-only coarse face box | Useful for QA, but introduces geometry exposure/rendering scope. | |
| Full landmark/control-point overlay | Useful for algorithm debugging, out of v1 Demo QA/privacy scope. | |
| Other | Freeform alternative. | |

**User's choice:** No geometry drawing in Phase 7.
**Notes:** No boxes, landmarks, or control points.

### Recoverable Errors

| Option | Description | Selected |
|--------|-------------|----------|
| Last redacted error code plus friendly status | Enough for QA; no raw framework strings, paths, or stack traces. | yes |
| Counts only | Safest but less useful for diagnosing failed Demo paths. | |
| Detailed internal error context | Developer-useful but conflicts with privacy unless heavily constrained. | |
| Other | Freeform alternative. | |

**User's choice:** Last redacted error code plus friendly status.
**Notes:** Use stable redacted codes and friendly copy only.

---

## Final Demo Readiness Polish

### Category Availability

| Option | Description | Selected |
|--------|-------------|----------|
| Keep current categories, sharpen availability copy | Preserve order; active paths active, future paths disabled with short labels/reasons. | yes |
| Hide future categories for v1 | Simpler UI, loses roadmap signal. | |
| Future categories as info pages | Better storytelling, adds content screens outside QA flow. | |
| Other | Freeform alternative. | |

**User's choice:** Keep current categories, sharpen availability copy.
**Notes:** Preserve the Meitu/Xingtu-style category structure without activating future domains.

### Automated Evidence

| Option | Description | Selected |
|--------|-------------|----------|
| Focused view-state/pipeline tests plus privacy/import scans | Extend current XCTest style for JSON, reset, compare/debug, unavailable states, facade-only/privacy boundaries. | yes |
| Required simulator UI automation/screenshot smoke | Stronger visual evidence, potentially brittle locally. | |
| Both focused tests and screenshots | Best confidence, larger scope. | |
| Other | Freeform alternative. | |

**User's choice:** Focused view-state/pipeline tests plus privacy/import scans.
**Notes:** Simulator screenshot/UI automation can remain optional if cheap.

### Manual QA Risks

| Option | Description | Selected |
|--------|-------------|----------|
| Record as explicit remaining release risks | Honest v1 readiness without claiming unproven release-grade naturalness/hardware completion. | yes |
| Make manual visual/hardware QA a Phase 7 gate | Stronger release confidence, depends on human/device access. | |
| Defer all manual QA notes to v2 | Smaller Phase 7, weaker readiness honesty. | |
| Other | Freeform alternative. | |

**User's choice:** Record as explicit remaining release risks.
**Notes:** Do not claim release-grade visual/hardware readiness without proof.

### Traceability Closure

| Option | Description | Selected |
|--------|-------------|----------|
| Update requirements/docs/quality with evidence | Mark `DEMO-06`/`DEMO-07` complete only after tests pass; update root docs and `.planning`. | yes |
| Only update `.planning` artifacts | Lighter, root contracts would lag. | |
| Only update root docs | Misses GSD milestone traceability. | |
| Other | Freeform alternative. | |

**User's choice:** Update requirements/docs/quality with evidence.
**Notes:** Close both GSD and root contract records after verification.

---

## the agent's Discretion

- Concrete Swift type names for the JSON envelope and import/export state.
- Exact sheet presentation details, labels, and short user-facing copy.
- Exact debug overlay view model names, field labels, and layout.
- Test file organization, as long as focused XCTest/view-state coverage and static scans cover the decisions.

## Deferred Ideas

- Local file import/export for parameter JSON.
- Preset-like saved custom looks.
- Revert-to-preset/import-baseline behavior.
- Geometry overlays with boxes, landmarks, or control points.
- Simulator screenshot/UI automation as a hard Phase 7 gate.
- Release-grade naturalness/hardware claims without manual proof.
