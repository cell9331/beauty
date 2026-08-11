---
phase: 65
slug: combined-facade-privacy-and-milestone-closeout
status: ready
researched: 2026-08-08
confidence: high
discovery_level: 0
security_standard: OWASP ASVS Level 1
planner_fallback: main-thread-sequential
---

# Phase 65 Research — Combined Facade, Privacy, and Milestone Closeout

## Summary

The production architecture already has the required combined path. Direct
teeth and sclera intent are resolved independently, current support comes from
one canonical Vision request, both providers receive one request-local
`BeautyLocalRetouchCompositionOwner`, and composition is original-pixel,
order-independent and collision-to-source. Phase 65 should primarily prove and
audit this behavior rather than add another algorithm or renderer case.

The smallest implementation delta is one combined closeout XCTest file, one
Testing-only no-lip/paired-eye fixture for the missing teeth-failure quadrant,
and a strict mutation-backed checker. Existing Phase 55 opaque composition,
Phase 59/62 evidence, Phase 60/63 provider and Phase 61/64 output gates remain
authoritative and must be rerun rather than copied.

## Requirement Mapping

| Requirement | Evidence |
| --- | --- |
| SEQ-02 | Separate fields, decisions, providers, failure observations, standalone outputs and owner rows plus a combined non-borrowing test. |
| SEQ-03 | Whole-source alias/proxy/route scan keeps `去脂` absent and its Demo row disabled. |
| SEQ-04 | No realtime/pixel-buffer provider work, Demo activation, model/network or release claim. |
| SAFE-04 | Public/SPI/Codable/log/metric/network/tracked privacy scans and aggregate-only reflection tests. |
| SAFE-05 | Repeated, parallel, thrown, malformed, reset, pixel-buffer, cancellation-publication and mixed-request recovery. |
| SAFE-06 | Dimensions/orientation/alpha/sRGB, typed errors, no-op and unrelated-color continuation. |
| SAFE-07 | Exact 61/5/74/three-disabled and `0/1/1/2` inventories with legacy-byte compatibility. |
| OUT-06 | Independent standalone merge oracle, collision-to-source and four failure quadrants. |
| OUT-07 | Focused/private/opt-in/full/Demo/privacy/security/review/verification conjunction. |
| OUT-08 | Exact product-owner equality and bounded nonclaims. |
| OUT-09 | Separate milestone audit after canonical Phase 65 verification. |

## Current Architecture Findings

- `BeautyEngine.processResult` clears both provider observations, normalizes
  once, canonicalizes/detects/maps once, creates one request context, calls each
  directly requested provider once, and composes all emitted units once.
- `BeautyLocalRetouchCompositionOwner` binds the exact immutable canonical
  source, rejects foreign/duplicate/malformed units locally, sorts claims,
  writes only unique owners and preserves source on multi-owner collisions.
- Existing Testing support can inject paired, partial and malformed eye support
  while keeping valid lip support. Only paired-eye/no-lip is missing for the
  explicit teeth-failure quadrant.
- The renderer already has independent `teethWhitening_1p00` and
  `scleraRednessReduction_1p00` cases. Keeping 74 cases preserves separate
  output evidence and avoids implying a new product control.

## Verification Architecture

Use four serial waves:

1. Freeze the combined literal-byte/failure contracts and eight-HIGH checker.
2. Complete the real-provider combined facade, recovery and collision matrix.
3. Close privacy, compatibility, private/opt-in gates, code review and fixed
   aggregate security evidence.
4. Run full regression, independent phase verification, exact lifecycle/owner
   equality, then invoke a separate milestone audit before completing OUT-09.

No external research or dependency is needed; all relevant contracts are
repository-defined and already compiled/tested in Phases 53-64.
