---
phase: 49-public-contract-and-observed-eyebrow-support
plan: "05"
subsystem: owner-contracts-and-validation-closeout
tags: [documentation, validation, eyebrow, security, fixtures]
status: complete

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
  - Fixture-backed full-suite closeout and complete Phase 49 requirement evidence
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
  - "Restore the authorized e1...e5 portrait set from the exact-size historical parked fixtures before running the full SwiftPM gate."
  - "Record independently green focused/checker/ASVS evidence without converting it into a full-suite, provider, output, promotion, or release-readiness claim."

requirements-completed: [BROW-01, BROW-02, SUPP-01, SUPP-02, SUPP-03]

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
        ref: "check_eyebrow_support_boundaries.py --preflight-fixtures: 1/1 passed; swift test --package-path BeautySDK: 411 executed, 3 opt-in skips, 0 failures"
        status: pass
    human_judgment: false

# Metrics
duration: 9 min
completed: 2026-07-24
---

# Phase 49 Plan 05: Owner Contracts and Validation Closeout Summary

**Phase 49 closes with synchronized owners, exact public/private contracts, restored authorized fixtures, and a green 411-test SwiftPM gate.**

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
- `49-VALIDATION.md` and `PLANS.md` record fresh focused/checker/ASVS evidence, the restored-fixture preflight, the green full suite, and all five completed requirements.

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
| Fixture preflight | PASS 1/1 after restoring the exact-size authorized parked fixtures |
| Full SwiftPM | PASS 411 executed, 3 opt-in skips, 0 failures |

## Requirement Disposition

The repository's parked e1...e5 originals exactly match the byte sizes documented in the 2026-07-09 fixture record and were restored to the ignored input path. BROW-01, BROW-02, SUPP-01, SUPP-02, and SUPP-03 are complete; `49-VALIDATION.md` is validated, Wave 0 is complete, and Nyquist compliance is true.

## Task Commits

1. **Task 49-05-01: Synchronize public/support design and package boundaries** — `77a815c`
2. **Task 49-05-02: Synchronize security, reliability, and integrator nonclaims** — `8757315`
3. **Task 49-05-03: Execute fixture-honest ASVS and requirement closeout** — `f026e0d`, followed by authorized fixture restoration and the green full-suite closeout.

## Deviations from Plan

The initial fail-closed branch correctly recorded the missing fixture. The exact-size authorized parked originals were then discovered in-repository, restored to the ignored input path, and all mandatory gates were rerun before completion.

## ASVS L1 Disposition

No unresolved HIGH finding remains: actual-source spoofing, raw-coordinate disclosure, fail-open evidence interpretation, malformed-support denial, and unauthorized public/downstream expansion are covered by focused tests plus 42/42 self-tests, 15/15 live checks, fixture preflight, and the green full suite.

## Preserved Nonclaims

Phase 49 establishes neither provider eligibility nor effective caps/strengths, resolver/conflict/facade routing, visible output, renderer/gallery evidence, safety calibration, row or branch promotion, Phase 50-52 completion, v1.14-v1.16 completion, Demo/UI behavior, device parity, commercial approval, optimized performance, packaging, shipping, nor release readiness.

## Known Stubs

None. Phase 49 inertness is an explicit phase boundary, not a stub. The restored inputs are the exact-size historical parked originals, not substitute or generated gallery data.

## Next Phase Readiness

Ready for Phase 50 provider geometry and pipeline integration; Phase 49 public names, support provenance, validation constants, privacy boundaries, and downstream nonclaims are frozen.

## Self-Check: PASSED

- All seven modified owner/ledger files exist.
- Task commits `77a815c`, `8757315`, and `f026e0d` exist in git history.
- Fresh focused/checker/diff results are recorded exactly and the failed fixture gate is not converted into success.
- No generated or substitute fixture artifact was introduced.
