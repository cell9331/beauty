---
phase: 38-public-contract-and-lip-support-geometry
status: passed
verified: 2026-07-14
requirements: [MOUTH-01, MOUTH-02, MOUTH-03, MOUTH-04, MOUTH-05, MOUTH-06, MOUTH-07, MOUTH-08]
focused_tests: 152
full_tests: 259
review_status: clean
---

# Phase 38 Verification

## Verdict

Passed. Phase 38 proves the public contract, private lip-support seam, eight-field mouth provider eligibility, resolver/conflict convergence, and aggregate-redacted public-facade route. All automated and structural gates completed with nonzero evidence.

## Requirement Evidence

| Requirement | Status | Evidence |
| --- | --- | --- |
| MOUTH-01 | passed | Three independent signed public fields default to zero, normalize finite input to `-1...1`, map non-finite input to zero, preserve mutation/round-trip independence, and route both signs. |
| MOUTH-02 | passed | Independent positive-only peak/plump fields default/non-finite to zero, clamp to `0...1`, and remain distinct from size/width/smile/lip color. |
| MOUTH-03 | passed | Exact 38 stored fields = 37 numeric fields + `filterId`; literal legacy 33-field JSON, unchanged bundled presets, defaulted initializer calls, and unequal current round trip pass. |
| MOUTH-04 | passed | Vision records optional coarse `innerLips`; missing inner remains globally usable; deterministic finite/bounded/distinct upper/lower/inner supports remain package-only and legacy `outerLips` is unchanged. |
| MOUTH-05 | passed | Y and X translations preserve their single axis and both directions; tilt preserves radius and rotates around the stable center; all three use distinct vectors and bounded targets. |
| MOUTH-06 | passed | Peak shaping consumes explicit upper + inner support, moves local flanks/center distinctly, and fails closed without borrowing smile/size/whole-mouth behavior. |
| MOUTH-07 | passed | Plump consumes explicit upper + lower + inner support, moves both surfaces away from the inner opening, and remains distinct from color/size/peak behavior. |
| MOUTH-08 | passed | Eight field emissions sanitize independently before and after conflict scale; provisional cap `0.25`, reused exact `0.5`, fourteen possible removals, final strengths/emissions agreement, sibling continuation, and isolated redacted facade routing pass. |

## Runtime Evidence

- Eleven named focused suites passed **152/152**: parameters 21, resources 8, Vision detection 10, face-support adapter 12, caps 3, mouth provider 16, resolver 17, degradation 33, conflict 10, combined safety 10, and facade 12.
- `swift test --package-path BeautySDK` passed **259/259** XCTest cases with zero failures.
- Standard code review covered 21 changed Swift files and reported 0 critical, 0 warning, and 0 informational findings.

## Structural and Security Evidence

- Exact inventory, five-field manual enumeration, eight-emission ordering/sanitization, and `for _ in 0..<14` convergence checks pass.
- Public/SPI raw geometry and diagnostic scans find no exported upper/lower/inner supports, landmarks, bounds, SIMD arrays, provider types, or control points.
- Dependency/target/network/cloud/commercial, renderer/Demo/package, generated-artifact, archived-evidence, and diff-hygiene checks pass.
- Product ledgers remain unchanged: the five rows and branch-level `嘴唇` are not promoted.

## Boundaries

Phase 39 owns saved public-facade output, strict helper, ROI/signed-direction comparisons, and ignored gallery evidence. Phase 40 owns final exact caps, exhaustive eight-field transition safety, active-source boundary closeout, and exact row promotion. This result does not claim device/commercial naturalness, performance certification, packaging, shipping, launch readiness, a passed milestone audit, or milestone completion.
