---
phase: 35
status: passed
score: 6/6
verified_at: 2026-07-13T16:07:14+0800
verified_commit: 6a69b11
---

# Phase 35 Verification

## Goal Verdict

Phase 35 passes at **6/6 requirements**. The implementation freezes compatibility-safe independent public semantics for `noseRootNarrowing` and `noseTipLift`, routes both through the existing resolver/provider/public-facade safety boundary, and proves deterministic bounded non-aliased upper-root and lower-tip geometry. No blocker or human-only verification remains for the Phase 35 scope.

This is a fresh verification of the repository at `6a69b11`, including the four review-fix iterations through `f6f9172` and the clean final review recorded by `6a69b11`. It supersedes the earlier Phase 35 execution counts without rewriting their historical summaries.

## Fresh Automated Evidence

Apple Swift 6.3.3 was observed. Every filtered XCTest command executed a nonzero suite; repeated suite/module/package footer counts were counted once. The separate Swift Testing footer reporting `0 tests in 0 suites` is not used as evidence.

| Command | Fresh result |
| --- | --- |
| `swift test --package-path BeautySDK --filter BeautyParametersTests` | passed, 14/14 XCTest cases |
| `swift test --package-path BeautySDK --filter BeautyResourceCatalogTests` | passed, 7/7 |
| `swift test --package-path BeautySDK --filter BeautySafetyCapsTests` | passed, 1/1 |
| `swift test --package-path BeautySDK --filter NoseWarpProviderTests` | passed, 15/15 |
| `swift test --package-path BeautySDK --filter BeautyEffectResolverTests` | passed, 14/14 |
| `swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` | passed, 26/26 |
| `swift test --package-path BeautySDK --filter GeometryConflictResolverTests` | passed, 8/8 |
| `swift test --package-path BeautySDK --filter CombinedEffectSafetyTests` | passed, 10/10 |
| `swift test --package-path BeautySDK --filter BeautyEngineGeometryFacadeTests` | passed, 11/11 |
| `swift test --package-path BeautySDK --filter MouthWarpProviderTests` | passed, 6/6 |
| `swift test --package-path BeautySDK` | passed, **219/219**, zero failures, 30.726 s XCTest |

The nine Phase 35 focused suites now pass **106/106**. The final-review affected aggregate (`MouthWarpProviderTests`, `NoseWarpProviderTests`, `MissingLandmarkDegradationTests`, `GeometryConflictResolverTests`, `CombinedEffectSafetyTests`, and `BeautyEffectResolverTests`) passes **79/79**, matching `35-REVIEW.md` and `35-REVIEW-FIX.md`.

## Requirement Verification

| Requirement | Status | Actual-code and test evidence |
| --- | --- | --- |
| NOSE-01 | passed | `BeautyParameters` has exactly 33 stored fields: 32 numeric fields plus `filterId`. Both new stored `Float` fields are independent positive-only `0...1` values, default to zero, clamp finite overflow, map all non-finite inputs to zero, and re-normalize after mutation. |
| NOSE-02 | passed | The literal legacy payload remains exactly 31 keys and decodes both fields as zero; all five unchanged bundled presets remain neutral; unequal `0.21` / `0.37` values round-trip in the 33-field model; defaulted labeled initializer arguments preserve source-rebuild compatibility. Precompiled-binary ABI compatibility is not claimed. |
| NOSE-03 | passed | Both fields have distinct effective storage, provisional exact `0.25` caps, geometry-required detection, activation/degradation/reuse/conflict/provider routing, and isolated public-facade evidence. Reused non-eye geometry applies exact `0.5`, producing `0.125` from either cap. Facade evidence contains counts and aggregate metrics only. |
| NOSE-04 | passed | Explicit `noseRoot` support requires a finite bounded symmetric same-Y pair on opposite sides of the centerline. The provider emits deterministic equal horizontal inward displacement, unchanged Y, no center crossing, capped strength, and complete-vector non-aliasing versus `noseBridge`. |
| NOSE-05 | passed | Explicit `noseTip` support requires distinct finite bounded points in the lower half. The provider emits deterministic upward motion with unchanged X and strictly smaller target Y; complete-vector comparisons distinguish it from both signed directions of `noseTipSize`. |
| NOSE-06 | passed | Default-empty, insufficient, non-finite, duplicate, same-side, asymmetric, misplaced, out-of-bounds, and displacement-blocked supports fail closed before output clamping, with no legacy `FaceGeometry.nose` fallback. Unsupported work is zeroed field-by-field while valid siblings and face-agnostic domains continue. |

## Must-Have and Review-Fix Audit

- Public compatibility is preserved at the source-rebuild, JSON, preset, normalization, equality, and Sendable seams. The provisional internal caps remain exactly `0.25`; Phase 37 still owns final calibration.
- `FaceGeometry.nose` remains the unchanged four-point legacy proxy. Package-internal default-empty `noseRoot` and `noseTip` supports feed only the new helpers and never cross the public facade.
- Each new field appears once in conflict scaling, once in the geometry total, and once in the nonzero count. Representative face/eye/mouth integration proves weakening with redacted warning and scale evidence without claiming Phase 37's exhaustive exactly-once matrix.
- Review fixes `3cf59de`, `bfd7375`, `8f8bda7`, and `05209b3` established pre-conflict per-field provider eligibility for independent and legacy nose work. Fix `33665e6` converged all six retained nose fields so final effective strengths equal final emissions.
- Final fix `f6f9172` extends the same invariant to the three mouth geometry fields. `resolveGeometryConflict` starts from provider-sanitized work and permits at most nine monotonic retained-mask changes; fields can only be removed, never re-added. It recomputes total, scale, weakened count, warning, and final strengths from the retained baseline. Signed `mouthSize`, `mouthWidth`, and `noseTipSize` threshold crossings are tested in both directions; root/tip-lift crossings, skipped-domain behavior, supported siblings, and redaction are also locked.
- Fresh review `6a69b11` is clean: no reachable critical, warning, or informational finding remains after `f6f9172`.

## Boundary and Contract Checks

| Gate | Fresh verdict |
| --- | --- |
| Public inventory | passed: exact 33 public stored properties, 32 numeric plus `filterId` |
| Public/SPI geometry | passed: the Phase 35 added-line scan has only four intended scalar declarations (public model and public effective values); no public/SPI `FaceGeometry`, `WarpControlPoint`, support array, landmark, bounds, SIMD, or provider type |
| Diagnostics/privacy | passed: stable category reason codes plus aggregate counts/numeric metrics; no coordinates, supports, paths, image bytes, or framework objects |
| Dependencies/external paths | passed: no Phase 35 `Package.swift` change and no scoped URLSession, Network, StoreKit, CloudKit, RevenueCat, Alamofire, entitlement, purchase, or payment path |
| Renderer/Demo/product ledgers | passed: no Phase 35 renderer, Demo, blueprint ledger, matrix, or nose-README change |
| Historical evidence | passed: archived v1.7 roadmap, requirements, and phase artifacts are unchanged |
| Generated evidence | passed: no tracked PNG under output/gallery roots |
| Current contracts | passed: `ARCHITECTURE.md`, `DESIGN.md`, `RELIABILITY.md`, `SECURITY.md`, and `PRODUCT_SENSE.md` agree on inventory, semantics, private supports, vectors, reuse, redaction, and deferrals |
| Planning traceability | passed: only NOSE-01 through NOSE-06 are complete; NOSE-07 through NOSE-14 and DOC-01 remain pending; mapping is 15/15; Phase 35 is 4/4 and Phase 36 is next |
| Hygiene | passed: clean worktree before this verifier update and `git diff --check` returned no output |

No Demo build was required because Phase 35 changed no Demo source or UI behavior.

## Non-Promotion and Residual Scope

- `山根` and `提升` have no `implemented` row, and branch-level `鼻子` remains `partial` in the read-only product ledger, matrix, and branch documentation.
- Phase 36 owns renderer cases, output decoding, baseline/legacy ROI comparisons, gallery routing, and ignored generated-output evidence.
- Phase 37 owns final cap calibration, exhaustive six-field degradation, final exactly-once combined safety, active-source boundary closeout, promotion, and SDK-core branch completion.
- Physical-device parity, commercial visual approval, packaging, shipping, and launch readiness remain outside Phase 35.

## Gaps

None within NOSE-01 through NOSE-06. Later-phase work above is explicitly deferred scope, not a Phase 35 verification gap.
