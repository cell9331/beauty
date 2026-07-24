---
phase: 49-public-contract-and-observed-eyebrow-support
plan: "05"
subsystem: owner-contracts-and-blocked-validation-closeout
tags: [documentation, validation, eyebrow, security, fixture-blocker]
status: blocked

requires:
  - phase: 49-01
    provides: Fail-closed checker, private carriers, fixture preflight, and Wave 0 matrices
  - phase: 49-02
    provides: Exact neutral 59-field public contract and legacy/preset compatibility
  - phase: 49-03
    provides: Actual Vision eyebrow capture, exactly-once mapping, and canonical side/order
  - phase: 49-04
    provides: Brow-specific open-path validation and request-scoped semantic attachment
provides:
  - Authoritative Phase 49 public/support owner contracts
  - Fresh focused, checker, owner, diff, and ASVS L1 evidence
  - Reproducible noncompliant closeout record for the missing e1.png prerequisite
affects: [phase-49-resume, phase-50-eyebrow-geometry]

tech-stack:
  added: []
  patterns: [single-owner contracts, fail-closed evidence, blocker-honest fixture preflight]

key-files:
  created:
    - .planning/phases/49-public-contract-and-observed-eyebrow-support/49-05-SUMMARY.md
  modified:
    - DESIGN.md
    - ARCHITECTURE.md
    - SECURITY.md
    - RELIABILITY.md
    - PRODUCT_SENSE.md
    - PLANS.md
    - .planning/phases/49-public-contract-and-observed-eyebrow-support/49-VALIDATION.md

key-decisions:
  - "Keep Phase 49 blocked and all five requirement-closeout rows open because the mandatory e1.png fixture preflight failed before full SwiftPM."
  - "Record independently green focused/checker/ASVS evidence without converting it into a full-suite, provider, output, promotion, or release-readiness claim."

requirements-completed: []

coverage:
  - id: owner-contracts
    description: "Exact 59/58 public model, actual Vision eyebrow provenance, request-local mapping/validation boundary, privacy, reliability, and integrator nonclaims are synchronized."
    verification:
      - kind: command
        ref: "python3 .planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py"
        status: pass
      - kind: command
        ref: "git diff --check"
        status: pass
    human_judgment: false
  - id: focused-evidence
    description: "Public compatibility, preset neutrality, resolver inertness, actual mapping, topology, redaction, and lifecycle evidence are freshly executable."
    verification:
      - kind: test
        ref: "BeautyParametersTests 37/37; BeautyResourceCatalogTests 10/10; BeautyEffectResolverTests 23/23"
        status: pass
      - kind: test
        ref: "BeautyDetectionTests 66 executed, 2 opt-in skips; BeautyFaceGeometryAdapterTests 45 executed, 1 opt-in skip"
        status: pass
      - kind: command
        ref: "check_eyebrow_support_boundaries.py --self-test 42/42"
        status: pass
    human_judgment: false
  - id: phase-closeout
    description: "Fixture-backed full SwiftPM and Phase 49 requirement closure."
    verification:
      - kind: command
        ref: "check_eyebrow_support_boundaries.py --preflight-fixtures: exit 1 required_fixture_missing_or_unsafe=1"
        status: fail
    human_judgment: true
    rationale: "The required example-images/input/portraits/e1.png is absent; full SwiftPM was correctly not run and closeout remains blocked."

# Metrics
duration: 9 min
completed: 2026-07-24
---

# Phase 49 Plan 05: Owner Contracts and Blocked Validation Closeout Summary

**All independently executable Phase 49 owner, focused, checker, and ASVS gates are recorded, while the missing authorized portrait fixture keeps full SwiftPM, Nyquist, and requirement closure explicitly noncompliant.**

## Performance

- **Duration:** 9 min
- **Started:** 2026-07-24T08:50:42Z
- **Completed:** 2026-07-24T08:59:42Z
- **Tasks:** 3
- **Files modified:** 7 plus this summary

## Accomplishments

- `DESIGN.md` now owns the exact seven public identifiers, six signed/one unit ranges, non-finite-zero behavior, 59 stored/58 numeric inventory, real legacy 52-key and preset compatibility, actual Vision provenance, exactly-once mapping, mapper-axis side/order canonicalization, exact validator constants, semantic fields, and Phase 49 inertness.
- `ARCHITECTURE.md` now owns the one-request `BeautyDetection` copy/map seam, target-internal `BeautyEffects` validation/attachment seam, immutable request lifetime, dependency direction, and explicit absence of downstream consumers.
- `SECURITY.md`, `RELIABILITY.md`, and `PRODUCT_SENSE.md` route untrusted-input/proxy/privacy rules, bounded failure/isolation/evidence rules, and SDK-integrator acceptance/nonclaims to one owner each.
- `49-VALIDATION.md` and `PLANS.md` record fresh focused/checker/ASVS evidence and the exact failed fixture preflight without claiming the full suite or five requirements complete.

## Exact Contract and Constants

- Public model: 59 stored fields = 58 numeric plus `filterId`; legacy 52-key source/JSON/reset/diff/equality/round-trip behavior and five preset bytes remain compatible.
- Signed fields: `eyebrowYPosition`, `eyebrowThickness`, `eyebrowLength`, `eyebrowSpacing`, `eyebrowHeadSpacing`, `eyebrowTilt` in `-1...1`; `eyebrowPeakDefinition` in `0...1`; all non-finite input becomes zero.
- Source/mapping: actual `leftEyebrow` and `rightEyebrow` from the existing selected-face request; independent 1...16 preflight; every accepted point maps exactly once; canonical side/order uses mapper-derived axes and whole-array reversal only.
- Semantic validator: 4...16 exact-bit-unique finite closed-unit points, chord 0.08...0.50 face width, vertical span at most 0.25 face height, no non-adjacent intersection, and projection epsilon 0.000001.
- Privacy/lifecycle: raw and derived carriers remain immutable, package/internal, non-Codable, non-persistent, non-networked, aggregate-only in diagnostics, and isolated across alternating/repeated/interrupted/stale/no-face/parallel requests.

## Verification

| Gate | Result |
| --- | --- |
| Checker self-test | PASS 42/42 |
| `BeautyParametersTests` | PASS 37/37 |
| `BeautyResourceCatalogTests` | PASS 10/10 |
| `BeautyEffectResolverTests` | PASS 23/23 |
| `BeautyDetectionTests` | PASS 66 executed, 2 opt-in skips, 0 failures |
| `BeautyFaceGeometryAdapterTests` | PASS 45 executed, 1 opt-in skip, 0 failures |
| Live checker | PASS 15/15, no unclassified matches |
| ASVS L1 active-source/diff review | PASS for independently reviewable scope; 0 unresolved HIGH findings |
| `git diff --check` | PASS |
| Fixture preflight | BLOCKED, exit 1: `required_fixture_missing_or_unsafe=1` |
| Full SwiftPM | NOT RUN after failed mandatory preflight |

## Blocker and Requirement Disposition

`example-images/input/portraits/e1.png` is absent. It was not created, replaced, weakened, skipped, or fabricated. The authorized path must become a readable, non-empty regular file before rerunning preflight and `swift test --package-path BeautySDK`.

BROW-01, BROW-02, SUPP-01, SUPP-02, and SUPP-03 have fresh focused evidence but remain open at the Phase 49 closeout gate. `49-VALIDATION.md` remains `status: blocked`, `wave_0_complete: false`, and `nyquist_compliant: false`.

## Task Commits

1. **Task 49-05-01: Synchronize public/support design and package boundaries** — `77a815c`
2. **Task 49-05-02: Synchronize security, reliability, and integrator nonclaims** — `8757315`
3. **Task 49-05-03: Execute fixture-honest ASVS and requirement closeout** — `f026e0d` (blocked closeout branch)

## Deviations from Plan

None - the plan explicitly requires the noncompliant blocked branch when fixture preflight fails.

## ASVS L1 Disposition

No unresolved HIGH finding remains in the independently executable active-source/diff scope: actual-source spoofing, raw-coordinate disclosure, fail-open evidence interpretation, malformed-support denial, and unauthorized public/downstream expansion are covered by focused tests plus 42/42 self-tests and 15/15 live checks. The missing fixture is a blocking environment prerequisite, not an accepted or transferred threat.

## Preserved Nonclaims

Phase 49 establishes neither provider eligibility nor effective caps/strengths, resolver/conflict/facade routing, visible output, renderer/gallery evidence, safety calibration, row or branch promotion, Phase 50-52 completion, v1.14-v1.16 completion, Demo/UI behavior, device parity, commercial approval, optimized performance, packaging, shipping, nor release readiness.

## Known Stubs

None. Phase 49 inertness is an explicit phase boundary, not a stub. The absent `e1.png` is an external fixture blocker and is not represented by substitute data.

## Next Phase Readiness

Blocked. Provision the authorized `example-images/input/portraits/e1.png`, rerun fixture preflight, full SwiftPM, live checker, owner/diff review, and ASVS HIGH review; only then may the five requirements, Wave 0, Nyquist, and Phase 49 closeout be marked complete.

## Self-Check: PASSED

- All seven modified owner/ledger files exist.
- Task commits `77a815c`, `8757315`, and `f026e0d` exist in git history.
- Fresh focused/checker/diff results are recorded exactly and the failed fixture gate is not converted into success.
- No generated or substitute fixture artifact was introduced.
