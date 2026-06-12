# Phase 3: Realtime and Still Input Slice - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-12T01:26:55Z
**Phase:** 3-Realtime and Still Input Slice
**Areas discussed:** Camera/Photo Entry Flow, Permission and Unavailable States, Compare Loading and Error Behavior

---

## Camera/Photo Entry Flow

### Phase 3 First Screen Entry Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Keep Editor Shell, activate Camera/Photo switching | Keep the current shell and make the Phase 2 Camera/Photo entries clickable. | ✓ |
| Default into Camera | Launch directly toward realtime camera. | |
| Default into Photo / Still Image | Make still-image editing the primary entry. | |
| Other | Freeform choice. | |

**User's choice:** Keep the current editor shell and turn Camera/Photo into clickable mode switches.  
**Notes:** Do not request camera permission on launch.

### Photo First-Version Source

| Option | Description | Selected |
|--------|-------------|----------|
| System Photo picker + test fixture | Real user path through picker plus deterministic test/previews. | ✓ |
| System Photo picker only | Real product path only. | |
| Bundle fixture only | Deterministic path only. | |
| Other | Freeform choice. | |

**User's choice:** System Photo picker plus a test fixture path.  
**Notes:** Supports both user realism and automated coverage.

### Camera Permission Timing

| Option | Description | Selected |
|--------|-------------|----------|
| Request permission after Camera tap | Ask only after explicit user intent. | ✓ |
| Precheck authorization on page entry without prompting | Read status early, request later. | |
| Request permission after launch | Prompt immediately after launch. | |
| Other | Freeform choice. | |

**User's choice:** Request camera permission after the user taps Camera.  
**Notes:** App launch must not trigger the permission prompt.

### Live Camera Preview Placement

| Option | Description | Selected |
|--------|-------------|----------|
| Replace shell preview area with live camera preview | Keep shell chrome and replace only the preview content. | ✓ |
| Enter a separate Camera screen | Use a separate camera-first screen. | |
| Only show camera-ready state without live preview | Skip live preview in Phase 3. | |
| Other | Freeform choice. | |

**User's choice:** Replace the existing shell preview area with live camera preview.  
**Notes:** Keep top Camera/Photo entries, bottom categories, and parameter panel visible.

---

## Permission and Unavailable States

### Camera Denied or Restricted State

| Option | Description | Selected |
|--------|-------------|----------|
| Keep editor shell, show permission explanation and Settings action | Preserve shell and Camera selection, show help in preview area. | ✓ |
| Automatically switch back to Photo mode | Avoid blocked Camera state by changing modes. | |
| Show full-screen permission blocking page | Use a dedicated blocking screen. | |
| Other | Freeform choice. | |

**User's choice:** Keep editor shell, leave Camera selected, and show permission explanation plus Settings action in the preview area.  
**Notes:** Photo remains available.

### Camera Unavailable or Session Setup Failure

| Option | Description | Selected |
|--------|-------------|----------|
| Show unavailable state in preview area, preserve Photo fallback | Mirror denied-state shape without auto-switching. | ✓ |
| Automatically switch to Photo with one-time notice | Change modes automatically. | |
| Disable Camera entry and keep preview fixture | Avoid active Camera state. | |
| Other | Freeform choice. | |

**User's choice:** Show unavailable state in the preview area and preserve Photo fallback.  
**Notes:** Keep state stable and testable.

### Photo Picker Cancel or Load Failure

| Option | Description | Selected |
|--------|-------------|----------|
| Cancel is not an error; failures show non-blocking message | Preserve current image or fixture. | ✓ |
| Cancel and failure both show errors | Treat every non-selection as an error. | |
| Any failure resets to preview fixture | Reset to deterministic state on failure. | |
| Other | Freeform choice. | |

**User's choice:** Cancellation is not an error; read/decode failures show a non-blocking message and preserve the current visual state.  
**Notes:** Avoid punishing normal cancellation.

### Info.plist Permission Copy Tone

| Option | Description | Selected |
|--------|-------------|----------|
| Product-like short copy mentioning local/on-device processing | Explain user value and privacy boundary. | ✓ |
| Developer validation copy | Describe SDK Demo validation. | |
| Minimal system-style copy | Use generic access text. | |
| Other | Freeform choice. | |

**User's choice:** Product-like short copy mentioning local/on-device processing.  
**Notes:** Do not imply upload.

---

## Compare Loading and Error Behavior

### Camera and Photo Compare Interaction

| Option | Description | Selected |
|--------|-------------|----------|
| Shared Compare toggle | Same interaction across Camera and Photo. | ✓ |
| Camera press-and-hold, Photo toggle | Different interactions per mode. | |
| Photo compare only, Camera later | Defer Camera compare. | |
| Other | Freeform choice. | |

**User's choice:** Shared Compare toggle for Camera and Photo.  
**Notes:** Toggle input/output without resetting parameters or changing crop/orientation.

### Photo Processing Loading State

| Option | Description | Selected |
|--------|-------------|----------|
| Preserve old image/fixture with loading overlay | Avoid clearing preview while processing. | ✓ |
| Dedicated loading placeholder page | Replace preview with loading state. | |
| Disable editing panel while processing | Block editing until processing finishes. | |
| Other | Freeform choice. | |

**User's choice:** Preserve old image or fixture and overlay loading in the preview area.  
**Notes:** Success replaces processed output; failure keeps previous result.

### SDK No-op Processing Failure Presentation

| Option | Description | Selected |
|--------|-------------|----------|
| Shared lightweight error banner/status | Preserve last usable visual state. | ✓ |
| Camera debug overlay only, Photo banner | Different error surfaces per mode. | |
| Switch to original input and show error page | Clearer but less continuous. | |
| Other | Freeform choice. | |

**User's choice:** Camera and Photo share a lightweight error banner/status.  
**Notes:** Use `BeautyError.code` internally; keep UI copy user-friendly.

### Slider Changes During Processing

| Option | Description | Selected |
|--------|-------------|----------|
| UI updates immediately, pipeline uses latest snapshot | Drop stale realtime work and reprocess stale photo work. | ✓ |
| Disable sliders while processing | Simplest but less interactive. | |
| Process only after slider release | Lower pressure but weaker realtime feel. | |
| Other | Freeform choice. | |

**User's choice:** UI parameter values update immediately; pipelines use the latest snapshot.  
**Notes:** Camera drops stale frames/snapshots; Photo cancels or marks stale work before reprocessing.

---

## the agent's Discretion

None.

## Deferred Ideas

None.
