---
phase: 59
slug: teeth-evidence-and-admission-contract
status: complete
researched: 2026-08-05
discovery_level: 0
security_standard: OWASP ASVS Level 1
---

# Phase 59 Research — Teeth Evidence and Admission Contract

## Executive Summary

Phase 59 is an existing-pattern extension, not a new-framework or new-package
choice. The authoritative evidence implementation is the Phase 54 local-only
evidence core and aggregate decision ledger. The authoritative runtime seams
are the append-only `BeautyParameters` model and the single
`BeautyEffectResolver.localRetouchAdmission(parameters:)` handoff.

The current Phase 54 teeth row is closed with both
`missing_genuine_positive` and `missing_genuine_negative`, all product counts
zero, and zero naturalness weight. `portrait_002/original.png` is explicitly a
C2PA-declared AI mechanics candidate and cannot change that result. This is a
real execution precondition: an executor must not create a synthetic passed
row, use `portrait_002` as product evidence, or add an inert public field while
the canonical row is closed. If the required bundle is still unavailable,
execution records a valid closed decision and leaves production admission
absent; only an exact `open` decision unlocks the positive branch.

## Existing Authority and Interfaces

### Evidence authority

- `.planning/milestones/v1.14-phases/54-rights-approved-evidence-and-eligibility-decisions/54-evidence-core.js`
  owns structural validation, complete original/mask/after binding, fixed
  review predicates, independent feature reduction, and the positive-allowlist
  durable export.
- `54-EVIDENCE-DECISIONS.json` is the current aggregate-only authority. Phase
  59 must consume or update this authority through the existing serializer; it
  must not create a competing decision source.
- `.codex/skills/spike-findings-beauty/references/licensed-fixture-evaluation.md`
  requires opaque IDs, approved-internal-evaluation rights, predeclared
  polarity/target, exact asset triples, frozen criteria, local blinded review,
  and sanitized structured output.

### Runtime authority

- `BeautyParameters` currently has 59 stored/Codable fields. Its initializer,
  custom decoder, and `normalized()` construction all preserve source order
  and default missing numeric keys to neutral values.
- `BeautyEffectResolver.localRetouchAdmission(parameters:)` is the sole
  production admission authority and currently returns `.none`.
- `BeautyLocalRetouchAdmission` carries only an opaque package-private demand
  count. It has no public feature name, support, mask, evidence, or provider
  state.
- `BeautyEngine.processResult(image:metadata:parameters:)` already turns a
  non-empty admission into one request-local canonicalize → detect/map →
  request-context → render handoff. Phase 59 may open that existing neutral
  seam but does not add a provider, mask, transform, renderer output, or Demo
  route.

## Recommended Approach

1. Freeze a teeth-only evidence/admission contract and checker using Phase 54
   as the canonical authority. Require one genuine discolored positive and one
   genuine already-light negative, each with the exact original/mask/after
   triple and independently bound rights. Reject candidate-only, synthetic,
   mechanics, authorization-only, historical, rejected, and sibling rows.
2. Require structured criteria to be frozen before blinded original-detail
   review. Durable output is field-by-field and contains only opaque IDs,
   fixed judgments/reasons, decisions, and aggregates.
3. Gate runtime edits on the canonical teeth row being `open`. On the open
   branch, append exactly one finite-normalized positive-only `Float` field at
   the model tail, preserve legacy missing-key/default behavior, and derive
   one opaque demand only from its normalized nonzero value. On the closed
   branch, preserve exact absence and `.none`.
4. Extend existing model, preset, renderer/facade, lifecycle, and Demo tests;
   do not rewrite the five bundled preset JSON files or add a renderer case.
   Preserve exact sclera/`去脂` absence and the three disabled Demo taxonomy
   rows.
5. Use a standard-library Python boundary checker with fail-closed scanner
   classification and temporary-copy mutations. Keep review media local and
   ignored; committed evidence remains sanitized.

## Constraints and Nonclaims

- No package install, external SDK, model, cloud path, network path, realtime
  path, pixel-buffer path, SwiftUI activation, or release-readiness claim is
  required or authorized.
- Teeth mechanics findings and adaptive thresholds are calibration context for
  later work, not Phase 59 admission constants or effectiveness claims.
- No teeth provider, mask, transform, renderer output, protected-tissue claim,
  visible-output claim, or promotion is made here.
- Sclera and `去脂` remain exact production absence; their evidence and
  runtime state are not borrowed by teeth.

## Confidence and Open Precondition

| Area | Confidence | Basis |
| --- | --- | --- |
| Evidence validation pattern | High | Phase 54 core, tests, ledger, and licensed-fixture reference |
| Parameter/Codable compatibility | High | Current `BeautyParameters` source and Phase 53/56 tests |
| Admission integration | High | Current resolver, opaque admission, and `BeautyEngine` lifecycle |
| Real teeth qualification | Blocked by missing input | STATE/PLANS record no rights-approved genuine positive/negative bundle |

The missing bundle is the only material blocker. It is handled as a blocking
checkpoint in Plan 59-01 and as a precondition in later plans; it is not
silently replaced by `portrait_002` or by synthetic test media.

## Package Legitimacy Audit

Not applicable. The plan adds no npm, SwiftPM, Python, Core ML, network, or
other external dependency.
