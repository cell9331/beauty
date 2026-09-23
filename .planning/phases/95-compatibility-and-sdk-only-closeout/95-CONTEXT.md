# Phase 95: Compatibility and SDK-Only Closeout - Context

**Gathered:** 2026-09-11
**Status:** Complete 2026-09-23; verified95-COMPLETE.json
**Mode:** Auto-generated (discuss skipped via workflow.skip_discuss)

Current completion: [verified COMPLETE](95-COMPLETE.json); [V1.22-CURRENT.md](../../V1.22-CURRENT.md). No old diagnostic or manual-confirmation action remains.
The original gathered context below is historical; it is not the current blocker or command list.

<domain>
## Phase Boundary

The owner can rely on every repaired control as deterministic, fail-closed, compatibility-preserving behavior within the unchanged owner-local SDK boundary.

Requirements: SAFE-01, COMPAT-01, CLOSE-01

Success Criteria (what must be TRUE):

1. Every repaired control proves neutral identity; deterministic recovery; source-safe no-face and missing, malformed, or stale support handling; exact caps; protected regions; output extent, orientation, color space, and alpha preservation; and privacy-safe diagnostics without proxy support.
2. Existing owner-local integrations retain the same Codable/default behavior, five presets, 62 parameter fields, 75 renderer cases, still-image facade signatures, CPU/GPU contract, SDK-only target boundary, and non-target behavior.
3. A clean authorized-portrait rerun completes 65/65 outputs, reports all seven active directions effective against neutral through their semantic and protection gates, and reports `faceContourSmooth` as deferred/partial without promoting it.
4. Focused tests, full SwiftPM tests, archive-first boundary checks, and the zero-failure/zero-skip closeout gate pass, and every changed behavior contract agrees with its current owner document.

</domain>

<decisions>
## Implementation Decisions

### Claude's Discretion
All implementation choices are at Claude's discretion — discuss phase was skipped per user setting. Use ROADMAP phase goal, success criteria, and codebase conventions to guide decisions.

The seven active directions owned by Phases 90–94 are:
- `chinTaper` (FACE-02, Phase 90)
- `gazeCorrection` (EYE-01, Phase 91)
- `eyebrowHeadSpacing` both signs (BROW-01, Phase 92)
- `noseBridge` (NOSE-01, Phase 93)
- `noseRootNarrowing` (NOSE-02, Phase 93)
- `mouthWidth` negative direction (MOUTH-01, Phase 94)

`faceContourSmooth` remains explicit deferred/partial (FUTURE-04).

Closeout must preserve: 62 parameter fields, 5 presets, 75 renderer cases, still-image facade signatures, CPU/GPU contract, SDK-only target boundary.

</decisions>

<code_context>
## Existing Code Insights

Codebase context will be gathered during plan-phase research. Known anchors:
- Phase 89 built the 65-case semantic acceptance baseline (5 batches × 13 cases)
- Phases 90–94 each authored focused tests and frozen contracts per direction
- The retained `FACE01_STOP_VERIFIED` verifier style applies similarly to MOUTH-01 stop verification
- Archive-first boundary checks use the existing archive command path

</code_context>

<specifics>
## Specific Ideas

No specific requirements — discuss phase skipped. Refer to ROADMAP phase description and success criteria.

</specifics>

<deferred>
## Deferred Ideas

None — discuss phase skipped.

</deferred>

<!-- beauty-v122-complete-sha256: 33b49fee25b4156b8a947ac437822ac33f7e5473a61ed74b1015c393035862d4 -->
